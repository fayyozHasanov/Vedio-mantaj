"""Reference-style motion typography renderer.

Reads a raw vertical video, composites animated typography (kicker + white/gold
headline lines with blur-in word reveals, pill tags, hero cards), a brand logo
badge, a countdown timer, subtle camera push-ins and a branded outro, then
encodes the result with loudness-normalised audio.

Usage:
    python3 -m mantaj.render projects/<name>/project.py
"""
from __future__ import annotations

import importlib.util
import math
import subprocess
import sys
from functools import lru_cache

import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageFont

W, H, FPS = 720, 1280, 30

FONT_DIR = "/usr/share/fonts/opentype/inter/"
F_HEAD = FONT_DIR + "InterDisplay-Bold.otf"
F_KICK = FONT_DIR + "Inter-SemiBold.otf"
F_TAG = FONT_DIR + "Inter-SemiBold.otf"
F_TIMER = FONT_DIR + "Inter-Medium.otf"

WHITE = (255, 255, 255)
GOLD_TOP = (226, 192, 152)
GOLD_BOT = (170, 128, 92)
CREAM = (236, 222, 200)

MARGIN_X = 54
LINE_SIZE = 54
LINE_GAP = 60
HERO_SIZE = 78


# ---------------------------------------------------------------- helpers
def ease_out(p):
    p = min(max(p, 0.0), 1.0)
    return 1 - (1 - p) ** 3


def ease_in_out(p):
    p = min(max(p, 0.0), 1.0)
    return 3 * p * p - 2 * p * p * p


@lru_cache(None)
def font(path, size):
    return ImageFont.truetype(path, size)


def gradient_fill(mask: Image.Image, top, bot) -> Image.Image:
    w, h = mask.size
    g = np.linspace(0, 1, h)[:, None]
    rgb = np.zeros((h, w, 3), np.float32)
    for c in range(3):
        rgb[..., c] = top[c] * (1 - g) + bot[c] * g
    img = Image.fromarray(rgb.astype(np.uint8), "RGB").convert("RGBA")
    img.putalpha(mask)
    return img


PAD = 28  # room for blur around sprites


class Sprite:
    """Pre-rendered text with a soft drop shadow; blur variants are cached."""

    def __init__(self, text, fpath, size, style="w", tracking=0.0):
        f = font(fpath, size)
        if tracking:
            widths = [f.getlength(ch) + tracking * size for ch in text]
            tw = int(sum(widths) - tracking * size) + 2
        else:
            tw = int(f.getlength(text)) + 2
        asc, desc = f.getmetrics()
        th = asc + desc
        mask = Image.new("L", (tw + 2 * PAD, th + 2 * PAD), 0)
        d = ImageDraw.Draw(mask)
        if tracking:
            x = PAD
            for ch, cw in zip(text, widths):
                d.text((x, PAD), ch, font=f, fill=255)
                x += cw
        else:
            d.text((PAD, PAD), text, font=f, fill=255)
        if style == "g":
            body = gradient_fill(mask, GOLD_TOP, GOLD_BOT)
        else:
            col = CREAM if style == "k" else WHITE
            body = Image.new("RGBA", mask.size, col + (0,))
            body.putalpha(mask)
        shadow = Image.new("RGBA", mask.size, (0, 0, 0, 0))
        shadow.putalpha(mask.point(lambda v: int(v * 0.55)))
        shadow = shadow.filter(ImageFilter.GaussianBlur(9))
        base = Image.alpha_composite(shadow, body)
        self.img = base
        self.w = tw
        self.h = th
        self.cache = {}

    def get(self, blur, alpha):
        key = (round(blur * 2) / 2, round(alpha * 20))
        if key not in self.cache:
            im = self.img
            if key[0] > 0.25:
                im = im.filter(ImageFilter.GaussianBlur(key[0]))
            if key[1] < 20:
                a = im.getchannel("A").point(lambda v, k=key[1] / 20: int(v * k))
                im = im.copy()
                im.putalpha(a)
            self.cache[key] = im
        return self.cache[key]


def rounded_rect(size, radius, fill, outline=None, width=1):
    im = Image.new("RGBA", size, (0, 0, 0, 0))
    ImageDraw.Draw(im).rounded_rectangle(
        (0, 0, size[0] - 1, size[1] - 1), radius, fill=fill, outline=outline, width=width
    )
    return im


# ------------------------------------------------------------------ cues
class Cue:
    """A lower-third typography block.

    lines: list of (text, style, at) where style is "w" (white) or "g" (gold)
           and `at` is when the first word of the line appears.
    kicker: optional small tracked caps label (appears at `start`).
    tags: list of (text, at) pill tags under the lines.
    """

    WORD_STAGGER = 0.11
    IN_DUR = 0.45
    OUT_DUR = 0.35

    def __init__(self, start, end, lines, kicker=None, tags=(), y=None):
        self.start, self.end = start, end
        self.words = []  # (sprite, x, y, t)
        top = y if y is not None else 850
        cy = top
        if kicker:
            ks = Sprite(kicker.upper(), F_KICK, 15, "k", tracking=0.42)
            self.words.append((ks, MARGIN_X, cy, start))
            cy += 30
        for text, style, at in lines:
            x = MARGIN_X
            space = font(F_HEAD, LINE_SIZE).getlength(" ")
            for i, wd in enumerate(text.split()):
                sp = Sprite(wd, F_HEAD, LINE_SIZE, style)
                self.words.append((sp, x, cy, at + i * self.WORD_STAGGER))
                x += sp.w + space * 0.92
            cy += LINE_GAP
        self.tags = []
        ty = cy + 18
        tx = MARGIN_X
        for text, at in tags:
            pill = make_pill(text)
            self.tags.append((pill, tx, ty, at))
            tx += pill.width + 10

    def draw(self, canvas, t):
        if t < self.start - 0.05 or t > self.end + self.OUT_DUR:
            return
        out = ease_in_out((t - self.end) / self.OUT_DUR) if t > self.end else 0.0
        for sp, x, y, at in self.words:
            p = ease_out((t - at) / self.IN_DUR)
            if p <= 0:
                continue
            alpha = p * (1 - out)
            blur = (1 - p) * 10 + out * 8
            dy = (1 - p) * 22 - out * 10
            if alpha <= 0.01:
                continue
            im = sp.get(blur, alpha)
            canvas.alpha_composite(im, (int(x - PAD), int(y - PAD + dy)))
        for pill, x, y, at in self.tags:
            p = ease_out((t - at) / 0.4)
            if p <= 0:
                continue
            alpha = p * (1 - out)
            im = pill
            if alpha < 0.99:
                im = pill.copy()
                im.putalpha(pill.getchannel("A").point(lambda v: int(v * alpha)))
            canvas.alpha_composite(im, (int(x), int(y + (1 - p) * 12)))


def make_pill(text):
    f = font(F_TAG, 17)
    tw = int(f.getlength(text))
    w, h = tw + 58, 40
    im = rounded_rect((w, h), 20, (14, 14, 18, 150), outline=(255, 255, 255, 40))
    d = ImageDraw.Draw(im)
    cx, cy, r = 24, h // 2, 6
    d.polygon([(cx, cy - r), (cx + r, cy), (cx, cy + r), (cx - r, cy)], fill=GOLD_TOP)
    d.text((40, h // 2), text, font=f, fill=WHITE, anchor="lm")
    return im


class Hero:
    """Centered large statement over a dimmed, blurred background."""

    def __init__(self, start, end, lines, kicker=None):
        self.start, self.end = start, end
        self.items = []
        total_h = len(lines) * (HERO_SIZE + 6) + (40 if kicker else 0)
        cy = H * 0.44 - total_h / 2
        if kicker:
            ks = Sprite(kicker.upper(), F_KICK, 17, "k", tracking=0.42)
            self.items.append((ks, (W - ks.w) / 2, cy, start))
            cy += 40
        for text, style, at in lines:
            sp = Sprite(text, F_HEAD, HERO_SIZE, style)
            self.items.append((sp, (W - sp.w) / 2, cy, at))
            cy += HERO_SIZE + 6

    def bg_amount(self, t):
        if t < self.start or t > self.end + 0.4:
            return 0.0
        return ease_out((t - self.start) / 0.4) * (1 - ease_in_out((t - self.end) / 0.4))

    def draw(self, canvas, t):
        if t < self.start - 0.05 or t > self.end + 0.4:
            return
        out = ease_in_out((t - self.end) / 0.4) if t > self.end else 0.0
        for sp, x, y, at in self.items:
            p = ease_out((t - at) / 0.55)
            if p <= 0:
                continue
            alpha = p * (1 - out)
            if alpha <= 0.01:
                continue
            im = sp.get((1 - p) * 14 + out * 10, alpha)
            sc = 1.06 - 0.06 * p
            if abs(sc - 1) > 0.002:
                im = im.resize((int(im.width * sc), int(im.height * sc)), Image.BICUBIC)
            canvas.alpha_composite(
                im, (int(x - PAD - (im.width - sp.img.width) / 2), int(y - PAD + (1 - p) * 26))
            )


# ------------------------------------------------------------ static layers
def bottom_gradient():
    g = np.zeros((H, W, 4), np.uint8)
    ys = np.arange(H)
    a = np.clip((ys - H * 0.48) / (H * 0.52), 0, 1) ** 1.4 * 215
    top = np.clip((H * 0.12 - ys) / (H * 0.12), 0, 1) ** 1.6 * 120
    g[..., 3] = np.maximum(a, top)[:, None].astype(np.uint8)
    return Image.fromarray(g, "RGBA")


def frame_border():
    im = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    ImageDraw.Draw(im).rounded_rectangle(
        (20, 20, W - 21, H - 21), 22, outline=(255, 255, 255, 34), width=2
    )
    return im


def logo_badge(path, logo_w):
    logo = Image.open(path).convert("RGBA")
    lh = round(logo.height * logo_w / logo.width)
    logo = logo.resize((logo_w, lh), Image.LANCZOS)
    px, py = 14, 10
    card = rounded_rect((logo_w + 2 * px, lh + 2 * py), 14, (255, 255, 255, 255))
    card.alpha_composite(logo, (px, py))
    sh = Image.new("RGBA", (card.width + 40, card.height + 40), (0, 0, 0, 0))
    m = Image.new("L", sh.size, 0)
    ImageDraw.Draw(m).rounded_rectangle((20, 24, 20 + card.width, 24 + card.height), 14, fill=110)
    sh.putalpha(m.filter(ImageFilter.GaussianBlur(10)))
    sh.alpha_composite(card, (20, 20))
    return sh  # card sits at offset (20,20) inside


# ------------------------------------------------------------------ render
def load_project(path):
    spec = importlib.util.spec_from_file_location("project", path)
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


def probe_duration(path):
    out = subprocess.run(
        ["ffprobe", "-v", "error", "-show_entries", "format=duration", "-of", "csv=p=0", path],
        capture_output=True, text=True,
    ).stdout
    return float(out.strip())


def zoom_at(t, shots, punches):
    """Slow push-in per shot plus eased punch-ins that hold to the shot's end."""
    s0, s1 = shots[0], shots[-1]
    for a, b in zip(shots, shots[1:]):
        if a <= t < b:
            s0, s1 = a, b
            break
    z = 1.0 + 0.035 * (t - s0) / max(s1 - s0, 0.1)
    for pt, amt in punches:
        if s0 <= pt < s1 and t >= pt:
            z += amt * ease_out((t - pt) / 0.3)
    return z


def apply_zoom(img, z, cy=0.42):
    if z <= 1.0005:
        return img
    cw, ch = W / z, H / z
    x0 = (W - cw) / 2
    y0 = min(max(H * cy - ch * cy, 0), H - ch)
    return img.resize((W, H), Image.BICUBIC, box=(x0, y0, x0 + cw, y0 + ch))


def main(project_path, preview=None):
    P = load_project(project_path)
    src = P.RAW
    dur = getattr(P, "DURATION", None) or probe_duration(src)
    outro = getattr(P, "OUTRO", 3.0)
    total = dur + outro
    n_src = int(round(dur * FPS))
    n_tot = int(round(total * FPS))
    t_from, t_to = (preview if preview else (0, total))

    cues = P.cues(Cue, Hero)
    heroes = [c for c in cues if isinstance(c, Hero)]
    shots = [0.0] + list(P.SHOTS) + [dur]
    punches = list(getattr(P, "PUNCHES", []))

    grad = bottom_gradient()
    border = frame_border()
    badge = logo_badge(P.LOGO, getattr(P, "LOGO_W", 112))
    big_badge = logo_badge(P.LOGO, 300)

    dec = subprocess.Popen(
        ["ffmpeg", "-v", "error", "-ss", str(t_from), "-i", src, "-t", str(min(t_to, dur) - t_from),
         "-f", "rawvideo", "-pix_fmt", "rgb24", "-"],
        stdout=subprocess.PIPE,
    )
    out_path = P.OUT if not preview else P.OUT.replace(".mp4", f"_preview_{t_from:g}.mp4")
    afilter = (
        f"loudnorm=I=-14:TP=-1.5:LRA=11,apad,atrim=0:{total:.3f},"
        f"afade=t=out:st={dur - 0.6:.3f}:d={outro + 0.6:.3f}"
    )
    enc = subprocess.Popen(
        ["ffmpeg", "-v", "error", "-y",
         "-f", "rawvideo", "-pix_fmt", "rgb24", "-s", f"{W}x{H}", "-r", str(FPS), "-i", "-",
         "-ss", str(t_from), "-i", src,
         "-map", "0:v", "-map", "1:a", "-af", afilter if not preview else "anull",
         "-c:v", "libx264", "-preset", "medium", "-crf", "17", "-pix_fmt", "yuv420p",
         "-c:a", "aac", "-b:a", "192k", "-movflags", "+faststart", "-shortest", out_path],
        stdin=subprocess.PIPE,
    )

    last = None
    i0, i1 = int(t_from * FPS), int(t_to * FPS)
    for i in range(i0, min(i1, n_tot)):
        t = i / FPS
        if i < n_src:
            buf = dec.stdout.read(W * H * 3)
            if len(buf) < W * H * 3:
                frame = last
            else:
                frame = Image.frombuffer("RGB", (W, H), buf)
                last = frame
            base = apply_zoom(frame, zoom_at(t, shots, punches)).convert("RGBA")
            hb = max((h.bg_amount(t) for h in heroes), default=0.0)
            if hb > 0.01:
                bl = base.filter(ImageFilter.GaussianBlur(16 * hb))
                dim = Image.new("RGBA", (W, H), (6, 10, 22, int(150 * hb)))
                base = Image.alpha_composite(bl, dim)
            base.alpha_composite(grad)
            for c in cues:
                c.draw(base, t)
        else:
            # branded outro: blurred last frame dissolving into deep navy
            k = (t - dur) / outro
            p = ease_out(k / 0.5)
            bl = apply_zoom(last, 1.035 + 0.05 * p).filter(ImageFilter.GaussianBlur(4 + 26 * p))
            base = bl.convert("RGBA")
            base.alpha_composite(Image.new("RGBA", (W, H), (9, 18, 30, int(225 * p))))
            q = ease_out((k - 0.12) / 0.45)
            if q > 0:
                sc = 0.86 + 0.14 * q
                bb = big_badge.resize(
                    (int(big_badge.width * sc), int(big_badge.height * sc)), Image.LANCZOS
                )
                if q < 0.99:
                    bb.putalpha(bb.getchannel("A").point(lambda v: int(v * q)))
                base.alpha_composite(bb, ((W - bb.width) // 2, int(H * 0.45 - bb.height / 2)))
            if getattr(P, "OUTRO_TEXT", None):
                Cue.draw  # noqa
                ks = outro_sprite(P.OUTRO_TEXT)
                r = ease_out((k - 0.35) / 0.4)
                if r > 0:
                    im = ks.get((1 - r) * 8, r)
                    base.alpha_composite(im, (int((W - ks.w) / 2 - PAD), int(H * 0.45 + 120 - PAD)))
        # chrome: frame border, logo badge, countdown
        if i < n_src:
            base.alpha_composite(border)
            base.alpha_composite(badge, (34 - 20, 40 - 20))
            rem = max(0, math.ceil(total - t))
            ts = timer_sprite(f"{rem // 60}:{rem % 60:02d}")
            base.alpha_composite(ts, (W - 40 - ts.width + PAD, 40 + (badge.height - 40) // 2 - 13 - PAD))
        enc.stdin.write(base.convert("RGB").tobytes())
        if i % 150 == 0:
            print(f"frame {i}/{n_tot}", flush=True)
    enc.stdin.close()
    enc.wait()
    dec.kill()
    print("wrote", out_path)


@lru_cache(None)
def timer_sprite(text):
    return Sprite(text, F_TIMER, 22, "w").img


@lru_cache(None)
def outro_sprite(text):
    return Sprite(text.upper(), F_KICK, 17, "k", tracking=0.42)


if __name__ == "__main__":
    pv = None
    if len(sys.argv) > 3:
        pv = (float(sys.argv[2]), float(sys.argv[3]))
    main(sys.argv[1], pv)
