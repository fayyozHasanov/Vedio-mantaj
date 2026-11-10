import 'package:flutter/material.dart';

import 'worship_types.dart';

abstract final class AppTexts {
  static const appName = 'QazoHisob';

  static const disclaimerTitle = 'Muhim eslatma';
  static const disclaimer =
      'QazoHisob — hisob yuritish vositasi, fatvo manbai emas. Qazo '
      'miqdorlarini siz o‘zingiz kiritasiz: ilova diniy majburiyatlaringizni '
      'o‘zi hisoblab chiqarmaydi va hech narsani avtomatik belgilamaydi.\n\n'
      'Qazo namoz va ro‘zalarni hisoblash usullari hamda ularga oid hukmlar '
      'mazhablar va olimlar o‘rtasida farq qilishi mumkin (masalan, Vitr '
      'namozining hukmi). Shuning uchun Vitr hisobi alohida yoqiladi.\n\n'
      'Shaxsiy diniy savollaringiz bo‘yicha ishonchli, malakali olimga '
      'murojaat qiling.';

  static const privacyTitle = 'Maxfiylik';
  static const privacy =
      'Barcha ma’lumotlaringiz faqat shu qurilmada saqlanadi. Ilova '
      'internetga ulanmaydi, ro‘yxatdan o‘tishni talab qilmaydi va hech '
      'qanday ma’lumotni uchinchi tomonga yubormaydi.\n\n'
      'Eksport va zaxira fayllarini faqat siz o‘zingiz tanlagan joyga '
      'ulashasiz. Eslatmalar ham qurilmaning o‘zida rejalashtiriladi.';
}

IconData prayerIcon(PrayerType type) => switch (type) {
  PrayerType.bomdod => Icons.wb_twilight_rounded,
  PrayerType.peshin => Icons.wb_sunny_rounded,
  PrayerType.asr => Icons.light_mode_outlined,
  PrayerType.shom => Icons.wb_twilight_outlined,
  PrayerType.xufton => Icons.nights_stay_rounded,
  PrayerType.vitr => Icons.auto_awesome_rounded,
};
