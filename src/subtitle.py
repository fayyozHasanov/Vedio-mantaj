#!/usr/bin/env python3
"""Videoga avtomatik subtitr (substr) yozish.

Ishlash tartibi:
  1. Whisper (faster-whisper) yordamida videodagi nutqni matnga o'giradi.
  2. Natijani .srt (va ixtiyoriy .vtt) faylga yozadi.
  3. Ixtiyoriy: ffmpeg bilan subtitrni videoning ustiga "kuydiradi" (burn-in)
     yoki alohida subtitr oqimi sifatida qo'shadi (soft).

Misollar:
  python src/subtitle.py video.mp4
  python src/subtitle.py video.mp4 --language uz --burn
  python src/subtitle.py video.mp4 --model medium --soft --max-chars 32
  python src/subtitle.py video.mp4 --srt tayyor.srt --burn   # tayyor srt'ni kuydirish
"""
from __future__ import annotations

import argparse
import shutil
import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path


@dataclass
class Cue:
    start: float
    end: float
    text: str


# ---------------------------------------------------------------- vaqt formati
def _ts(seconds: float, sep: str = ",") -> str:
    ms = int(round(max(seconds, 0.0) * 1000))
    h, ms = divmod(ms, 3_600_000)
    m, ms = divmod(ms, 60_000)
    s, ms = divmod(ms, 1000)
    return f"{h:02d}:{m:02d}:{s:02d}{sep}{ms:03d}"


def write_srt(cues: list[Cue], path: Path) -> None:
    lines = []
    for i, c in enumerate(cues, 1):
        lines += [str(i), f"{_ts(c.start)} --> {_ts(c.end)}", c.text, ""]
    path.write_text("\n".join(lines), encoding="utf-8")


def write_vtt(cues: list[Cue], path: Path) -> None:
    lines = ["WEBVTT", ""]
    for c in cues:
        lines += [f"{_ts(c.start, '.')} --> {_ts(c.end, '.')}", c.text, ""]
    path.write_text("\n".join(lines), encoding="utf-8")


# ------------------------------------------------------------ matnni bo'lish
def _wrap(words: list[str], max_chars: int) -> str:
    """Matnni ko'pi bilan 2 qatorga, muvozanatli bo'ladi."""
    text = " ".join(words)
    if len(text) <= max_chars or len(words) < 2:
        return text
    best, best_diff = 1, None
    for i in range(1, len(words)):
        a, b = " ".join(words[:i]), " ".join(words[i:])
        diff = abs(len(a) - len(b))
        if best_diff is None or diff < best_diff:
            best, best_diff = i, diff
    return " ".join(words[:best]) + "\n" + " ".join(words[best:])


def build_cues(words, max_chars: int, max_duration: float, max_gap: float = 0.8) -> list[Cue]:
    """So'zlar (start, end, word) ro'yxatidan o'qishga qulay bo'laklar yasaydi.

    Bir bo'lak: ko'pi bilan 2 qator * max_chars belgi, max_duration soniya.
    Gap oxiridagi tinish belgisi yoki uzun pauzada yangi bo'lak boshlanadi.
    """
    cues: list[Cue] = []
    cur: list = []
    limit = max_chars * 2

    def flush():
        if cur:
            cues.append(Cue(cur[0][0], cur[-1][1], _wrap([w for _, _, w in cur], max_chars)))
            cur.clear()

    for start, end, word in words:
        word = word.strip()
        if not word:
            continue
        if cur:
            length = len(" ".join(w for _, _, w in cur)) + 1 + len(word)
            if (length > limit
                    or end - cur[0][0] > max_duration
                    or start - cur[-1][1] > max_gap):
                flush()
        cur.append((start, end, word))
        if word[-1] in ".!?…" and len(" ".join(w for _, _, w in cur)) > max_chars // 2:
            flush()
    flush()

    # Juda qisqa ko'rinadigan bo'laklarni biroz uzaytirish (keyingisiga tegmasdan)
    for i, c in enumerate(cues):
        nxt = cues[i + 1].start if i + 1 < len(cues) else c.end + 1.0
        if c.end - c.start < 1.0:
            c.end = min(c.start + 1.0, nxt)
    return cues


# ------------------------------------------------------------- transkripsiya
def transcribe(video: Path, model_name: str, language: str | None, device: str,
               task: str, max_chars: int, max_duration: float) -> tuple[list[Cue], str]:
    try:
        from faster_whisper import WhisperModel
    except ImportError:
        sys.exit("faster-whisper o'rnatilmagan: pip install -r requirements.txt")

    compute = "float16" if device == "cuda" else "int8"
    print(f"[1/3] Model yuklanmoqda: {model_name} ({device}, {compute})")
    model = WhisperModel(model_name, device=device, compute_type=compute)

    print(f"[2/3] Nutq matnga o'girilmoqda: {video.name}")
    segments, info = model.transcribe(
        str(video),
        language=language,
        task=task,
        word_timestamps=True,
        vad_filter=True,
    )
    print(f"      Til: {info.language} (ehtimollik {info.language_probability:.2f}), "
          f"davomiylik {info.duration:.1f}s")

    words = []
    for seg in segments:
        if seg.words:
            words += [(w.start, w.end, w.word) for w in seg.words]
        else:
            words.append((seg.start, seg.end, seg.text))
        print(f"      {_ts(seg.start)}  {seg.text.strip()}")
    return build_cues(words, max_chars, max_duration), info.language


# ------------------------------------------------------------------- ffmpeg
def _escape_filter_path(p: Path) -> str:
    s = str(p.resolve()).replace("\\", "/")
    return s.replace(":", r"\:").replace("'", r"\'").replace(",", r"\,")


def burn(video: Path, srt: Path, out: Path, font_size: int, font: str) -> None:
    style = (f"FontName={font},FontSize={font_size},PrimaryColour=&H00FFFFFF,"
             "OutlineColour=&H00000000,BorderStyle=1,Outline=2,Shadow=0,MarginV=30")
    vf = f"subtitles='{_escape_filter_path(srt)}':charenc=UTF-8:force_style='{style}'"
    cmd = ["ffmpeg", "-y", "-i", str(video), "-vf", vf,
           "-c:v", "libx264", "-crf", "18", "-preset", "medium", "-c:a", "copy", str(out)]
    _run(cmd)


def soft(video: Path, srt: Path, out: Path, lang: str) -> None:
    codec = "mov_text" if out.suffix.lower() in {".mp4", ".m4v", ".mov"} else "srt"
    lang3 = {"uz": "uzb", "ru": "rus", "en": "eng", "tr": "tur", "kk": "kaz"}.get(lang, lang)
    cmd = ["ffmpeg", "-y", "-i", str(video), "-i", str(srt),
           "-map", "0", "-map", "1", "-c", "copy", "-c:s", codec,
           "-metadata:s:s:0", f"language={lang3}", str(out)]
    _run(cmd)


def _run(cmd: list[str]) -> None:
    if not shutil.which("ffmpeg"):
        sys.exit("ffmpeg topilmadi. Uni o'rnating: https://ffmpeg.org/download.html")
    res = subprocess.run(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.PIPE, text=True)
    if res.returncode != 0:
        sys.exit("ffmpeg xatosi:\n" + res.stderr[-2000:])


# --------------------------------------------------------------------- main
def main(argv=None) -> None:
    p = argparse.ArgumentParser(description="Videoga avtomatik subtitr yozish (Whisper + ffmpeg)")
    p.add_argument("video", type=Path, help="kirish video fayli")
    p.add_argument("--language", "-l", default=None,
                   help="nutq tili (uz, ru, en...). Berilmasa avtomatik aniqlanadi")
    p.add_argument("--model", "-m", default="small",
                   help="Whisper modeli: tiny, base, small, medium, large-v3 (default: small)")
    p.add_argument("--device", default="auto", choices=["auto", "cpu", "cuda"])
    p.add_argument("--translate", action="store_true",
                   help="subtitrni ingliz tiliga tarjima qilib yozish")
    p.add_argument("--srt", type=Path, default=None,
                   help="tayyor .srt fayl (berilsa transkripsiya o'tkazib yuboriladi)")
    p.add_argument("--max-chars", type=int, default=42, help="bir qatordagi maks. belgilar")
    p.add_argument("--max-duration", type=float, default=6.0, help="bir subtitr maks. soniya")
    p.add_argument("--vtt", action="store_true", help="qo'shimcha .vtt fayl ham yozish")
    mode = p.add_mutually_exclusive_group()
    mode.add_argument("--burn", action="store_true", help="subtitrni videoga kuydirish")
    mode.add_argument("--soft", action="store_true", help="subtitrni alohida oqim qilib qo'shish")
    p.add_argument("--font", default="Arial")
    p.add_argument("--font-size", type=int, default=22)
    p.add_argument("--output", "-o", type=Path, default=None, help="chiqish video fayli")
    a = p.parse_args(argv)

    if not a.video.exists():
        sys.exit(f"Fayl topilmadi: {a.video}")

    device = a.device
    if device == "auto":
        try:
            import ctranslate2
            device = "cuda" if ctranslate2.get_cuda_device_count() > 0 else "cpu"
        except Exception:
            device = "cpu"

    lang = a.language or "und"
    if a.srt:
        srt_path = a.srt
        print(f"Tayyor subtitr ishlatilmoqda: {srt_path}")
    else:
        cues, lang = transcribe(a.video, a.model, a.language, device,
                                "translate" if a.translate else "transcribe",
                                a.max_chars, a.max_duration)
        if a.translate:
            lang = "en"
        if not cues:
            sys.exit("Videoda nutq topilmadi — subtitr yozilmadi.")
        srt_path = a.video.with_suffix(".srt")
        write_srt(cues, srt_path)
        print(f"      Saqlandi: {srt_path} ({len(cues)} ta subtitr)")
        if a.vtt:
            write_vtt(cues, a.video.with_suffix(".vtt"))

    if a.burn or a.soft:
        out = a.output or a.video.with_name(f"{a.video.stem}_subtitr{a.video.suffix}")
        print(f"[3/3] Video tayyorlanmoqda: {out}")
        if a.burn:
            burn(a.video, srt_path, out, a.font_size, a.font)
        else:
            soft(a.video, srt_path, out, lang)
        print(f"Tayyor: {out}")
    else:
        print("Tayyor. Videoga qo'shish uchun --burn yoki --soft bilan qayta ishga tushiring.")


if __name__ == "__main__":
    main()
