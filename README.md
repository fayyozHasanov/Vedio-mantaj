# Vedio-mantaj
 referens based ai vedeo editing

## Videoga avtomatik subtitr (substr) yozish

`src/subtitle.py` — videodagi nutqni sun'iy intellekt (Whisper) yordamida matnga o'giradi,
`.srt` subtitr fayl yozadi va xohlasangiz uni videoga qo'shadi.

### O'rnatish

```bash
pip install -r requirements.txt
# ffmpeg ham kerak: https://ffmpeg.org/download.html
```

### Ishlatish

```bash
# Faqat .srt fayl yaratish (til avtomatik aniqlanadi)
python src/subtitle.py video.mp4

# O'zbekcha nutq, subtitrni videoga kuydirish (doim ko'rinadi)
python src/subtitle.py video.mp4 --language uz --burn

# Subtitrni alohida oqim qilib qo'shish (pleyerda yoqib/o'chirsa bo'ladi)
python src/subtitle.py video.mp4 --language uz --soft

# Aniqroq natija uchun kattaroq model
python src/subtitle.py video.mp4 --language uz --model large-v3 --burn

# Inglizchaga tarjima qilingan subtitr
python src/subtitle.py video.mp4 --translate --burn

# .srt faylni qo'lda tuzatib, keyin videoga kuydirish
python src/subtitle.py video.mp4 --srt video.srt --burn
```

Natija: `video.srt` va (`--burn`/`--soft` bilan) `video_subtitr.mp4`.

| Parametr | Ma'nosi | Default |
|---|---|---|
| `--language`, `-l` | nutq tili (`uz`, `ru`, `en`, ...) | avtomatik |
| `--model`, `-m` | `tiny`, `base`, `small`, `medium`, `large-v3` | `small` |
| `--burn` / `--soft` | videoga kuydirish / alohida oqim | — |
| `--srt` | tayyor `.srt` faylni ishlatish | — |
| `--translate` | inglizchaga tarjima | o'chiq |
| `--max-chars` | bir qatordagi maks. belgi (2 qatorgacha) | 42 |
| `--max-duration` | bir subtitrning maks. davomiyligi (s) | 6.0 |
| `--font`, `--font-size` | kuydirilgan subtitr shrifti | Arial, 22 |
| `--vtt` | qo'shimcha `.vtt` fayl | o'chiq |
| `--output`, `-o` | chiqish video nomi | `<nom>_subtitr.<ext>` |

Maslahat: o'zbek tili uchun `medium` yoki `large-v3` modeli ancha aniqroq ishlaydi.
GPU (CUDA) bo'lsa, u avtomatik ishlatiladi.
