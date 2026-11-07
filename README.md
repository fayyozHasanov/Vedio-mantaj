# Vedio-mantaj
 referens based ai vedeo editing

## Ishlatish

```bash
pip install pillow numpy
RAW=xom_video.mp4 OUT=natija.mp4 python3 -m mantaj.render projects/salohiddin/project.py
# faqat bir qismini ko'rish (masalan 30–40 s):
RAW=xom_video.mp4 OUT=natija.mp4 python3 -m mantaj.render projects/salohiddin/project.py 30 40
```

- `mantaj/render.py` — referens uslubidagi tipografiya dvigateli (kicker, oq/oltin qatorlar,
  so'zma-so'z blur animatsiya, teglar, hero kartalar, logo badge, taymer, outro).
- `projects/<nom>/project.py` — har bir video uchun cue'lar (nutq vaqtiga sinxron), kadr
  almashinuvlari va punch-in zoomlar.
