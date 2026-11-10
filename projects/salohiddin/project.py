"""Salohiddin Ayyubiy — himmat haqida. Yuksalish Kitoblari.

Cue timings are synced to word timestamps from a Whisper large-v3 transcript
of the raw footage.
"""
import os

HERE = os.path.dirname(os.path.abspath(__file__))
RAW = os.environ.get("RAW", os.path.join(HERE, "raw.mp4"))
LOGO = os.path.join(HERE, "logo.png")
OUT = os.environ.get("OUT", os.path.join(HERE, "final.mp4"))
LOGO_W = 112
OUTRO = 3.0

# camera cuts already present in the raw footage (ffmpeg scene detection)
SHOTS = [2.133, 9.933, 22.0, 29.733, 33.367, 42.6, 48.967, 52.967, 68.667, 76.033,
         85.133, 95.367, 102.667, 111.167, 118.367, 128.133, 136.733, 150.933,
         157.7, 160.367, 168.033]

# (time, extra zoom) — punch-ins on key words
PUNCHES = [(38.64, 0.06), (63.62, 0.05), (82.82, 0.06), (100.12, 0.05),
           (124.94, 0.06), (145.22, 0.05)]


def cues(Cue, Hero):
    W, G = "w", "g"
    return [
        # hook
        Cue(0.0, 2.55, [("Juftliklar bor", W, 0.0), ("birlashish uchun", G, 1.02),
                        ("kurashadi", W, 2.14)]),
        Cue(2.68, 5.55, [("Juftliklar bor", W, 2.68), ("kurash uchun", G, 3.78),
                         ("birlashadi", W, 4.86)]),
        Cue(5.72, 12.45, [("Salohiddin Ayyubiyning", W, 5.72), ("ota-onasi", G, 8.36),
                          ("bir-birini topgani", W, 10.26)], kicker="Qiziq voqea"),
        # the father
        Cue(12.64, 22.4, [("Falon qizni", W, 15.36), ("nima uchun", G, 16.34),
                          ("rad qilding?", W, 16.76)], kicker="Otasidan so‘rashadi",
            tags=[("Aqlli", 18.5), ("Taqvoli", 18.98), ("Ilmli", 20.08)]),
        Cue(23.16, 29.2, [("U qiz taqvoli,", W, 24.84), ("aqlli ekan,", W, 25.54),
                          ("lekin himmati past", G, 27.32)], kicker="Uning javobi"),
        Cue(29.26, 37.1, [("Menga bir o‘g‘il", W, 33.4), ("farzand tug‘ib bersa", G, 34.54)],
            kicker="Shunday qizga uylanmoqchimanki", tags=[("Sher qilib tarbiyalasak", 35.6)]),
        Hero(37.28, 41.5, [("Quddusni", G, 38.64), ("egallasa", W, 39.46)],
             kicker="va u katta bo‘lib"),
        Cue(41.9, 43.4, [("Unaqa qizni", W, 41.9), ("qayerdan topasan?", G, 42.6)]),
        # the mother
        Cue(43.44, 50.9, [("Ulug‘ shayxni", W, 47.7), ("ziyorat qilganda", G, 49.48)],
            kicker="Oradan vaqtlar o‘tadi"),
        Cue(51.06, 56.15, [("Bir suhbatni", W, 51.66), ("eshitib qoladi", G, 52.34)],
            tags=[("To‘siq ortida bir qiz", 54.24)]),
        Cue(56.26, 61.9, [("Shogirdimni", W, 58.12), ("nega rad qilding?", G, 59.0)],
            kicker="Shayx so‘raydi", tags=[("Ilmli", 60.52), ("Taqvoli", 60.84)]),
        Cue(62.0, 64.85, [("U yigitning", W, 62.0), ("himmati past ekan", G, 63.62)]),
        Cue(64.94, 75.3, [("O‘z nafsini yengan,", W, 69.02), ("hayotida maqsadi bor", G, 70.9),
                          ("inson", W, 72.04)], kicker="Men shunday erkakka chiqaman"),
        Cue(75.62, 81.85, [("Uni sher qilib", W, 80.46), ("tarbiyalasak", G, 81.3)],
            kicker="Undan farzand bo‘lsa"),
        Hero(81.92, 84.1, [("Quddusni", G, 82.82), ("egallasa", W, 83.16)],
             kicker="va u katta bo‘lib"),
        Cue(87.78, 96.0, [("Nikohga olishni", W, 89.72), ("izhor qiladi", G, 92.2)],
            kicker="Darhol shayxning oldiga borib", tags=[("To‘y bo‘ladi", 94.82)]),
        Hero(98.6, 101.55, [("Salohiddin", G, 100.12)], kicker="Farzandining ismi"),
        # the son
        Cue(101.68, 112.4, [("Ko‘chada", W, 104.64), ("o‘ynab yurgan payt", G, 105.42)],
            kicker="Salohiddin katta bo‘lib", tags=[("Shomga yaqin", 108.9)]),
        Cue(112.56, 116.5, [("Yoqasidan ushlab", W, 115.28), ("ko‘taradi", G, 116.04)],
            kicker="Otasi"),
        Cue(116.62, 123.95, [("Biz seni ko‘chada", W, 119.74), ("o‘ynashing uchun", G, 121.34),
                             ("katta qildikmi?", W, 122.36)], kicker="Ey Salohiddin!"),
        Hero(124.06, 127.3, [("Buyuk ishlar", G, 124.94), ("qilishing kerak!", W, 125.62)],
             kicker="Sen"),
        Cue(127.56, 130.9, [("Yiqilib tushadi", W, 129.22)], kicker="Qo‘yib yuboradi"),
        Cue(131.02, 139.55, [("Og‘ridimi?", W, 133.26), ("Nega yig‘lamaysan?", G, 137.98)],
            kicker="Ustozlari so‘raydi"),
        Cue(139.68, 144.3, [("Buyuk ishlarni", W, 140.66), ("qiladigan inson", W, 141.88),
                            ("yig‘lamaydi", G, 143.1)], kicker="Javobi"),
        # the lesson
        Hero(144.46, 149.05, [("Himmati buyuk", W, 145.22), ("odamlardan", W, 146.18),
                              ("buyuk insonlar", G, 147.62), ("chiqadi", W, 148.42)],
             kicker="Tushunyapsizmi?"),
        Cue(149.2, 154.2, [("insoniyat tarixida", W, 151.02), ("katta ishlar qilgan", G, 152.44),
                           ("odamlardan biri", W, 153.28)], kicker="Salohiddin Ayyubiy"),
        Cue(154.32, 157.95, [("Himmati zo‘r", G, 155.74), ("odamlardan bo‘ladi", W, 156.32)]),
        Cue(158.08, 163.9, [("Himmati baland,", W, 159.14), ("insoniyat taqdirini", W, 160.08),
                            ("yaxshi tomonga", G, 161.82), ("o‘zgartira oladigan", W, 162.38)],
            kicker="Alloh taolo"),
        Cue(164.1, 171.55, [("Bayrog‘imizni", W, 165.28), ("baland ko‘taradigan", G, 166.4)],
            kicker="Aziz O‘zbekistonimiz",
            tags=[("Ilmda", 167.52), ("Iqtisodda", 169.1), ("Ijtimoiy hayotda", 170.62)]),
        Cue(171.72, 174.4, [("Har tarafdan", W, 171.72), ("yurtimizni", G, 172.7),
                            ("rivojlantiradigan", W, 173.9)]),
        Cue(174.5, 182.3, [("Buyuk zotlarni", W, 174.5), ("tug‘adigan", W, 176.08),
                           ("qizu o‘g‘illarni", G, 177.18)],
            tags=[("Yurtimizda ko‘paytirsin", 181.18)]),
    ]
