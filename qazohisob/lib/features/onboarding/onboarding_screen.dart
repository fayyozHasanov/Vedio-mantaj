import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_texts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/islamic_pattern.dart';
import '../../shared/providers.dart';
import '../../shared/widgets/initial_debt_form.dart';

/// First-launch flow: welcome, prayer intro, fasting intro, initial debt
/// entry (skippable) and start.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _controller = PageController();
  int _page = 0;
  bool _debtSaved = false;

  static const _debtPage = 3;
  static const _lastPage = 4;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goTo(int page) {
    FocusScope.of(context).unfocus();
    _controller.animateToPage(
      page,
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _finish() async {
    await ref.read(settingsRepositoryProvider).setOnboardingCompleted(true);
    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              children: [
                SizedBox(
                  height: 52,
                  child: Row(
                    children: [
                      if (_page > 0)
                        IconButton(
                          tooltip: 'Orqaga',
                          onPressed: () => _goTo(_page - 1),
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 20,
                          ),
                        ),
                      const Spacer(),
                      if (_page < _debtPage)
                        TextButton(
                          key: const Key('skipOnboarding'),
                          onPressed: () => _goTo(_debtPage),
                          child: const Text('O‘tkazib yuborish'),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView(
                    controller: _controller,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (p) => setState(() => _page = p),
                    children: [
                      const _IntroPage(
                        hero: AppMark(size: 112),
                        title: 'QazoHisob’ga\nxush kelibsiz',
                        text:
                            'Qazo namoz va ro‘zalaringizni tartibli, xotirjam '
                            'va maxfiy tarzda hisoblab boring.',
                        bullets: [
                          'Internetsiz ishlaydi',
                          'Ma’lumotlar faqat qurilmangizda',
                          'Har bir yozuv sana va vaqti bilan saqlanadi',
                        ],
                      ),
                      const _IntroPage(
                        hero: _IconHero(icon: Icons.mosque_rounded),
                        title: 'Namoz qazolari',
                        text:
                            'Bomdod, Peshin, Asr, Shom va Xufton alohida '
                            'hisoblanadi. Vitrni xohlasangiz alohida yoqasiz.',
                        bullets: [
                          'Qazo ado qilganingizda o‘zingiz belgilaysiz',
                          'Keyin aniqlangan qazolarni qo‘shish mumkin',
                          'Xato yozuvni bekor qilish va tuzatish mumkin',
                        ],
                      ),
                      const _IntroPage(
                        hero: _IconHero(
                          icon: Icons.nightlight_round,
                          gold: true,
                        ),
                        title: 'Ro‘za qazolari',
                        text: 'Ramazondan qolgan ro‘zalarni kunma-kun qayd eting.',
                        bullets: [
                          'Har bir tutilgan kun qarzni aynan 1 kunga kamaytiradi',
                          'Ro‘za tutilgan sanani o‘zingiz tanlaysiz',
                          'Hech narsa avtomatik belgilanmaydi',
                        ],
                      ),
                      _DebtPage(
                        onSaved: () {
                          setState(() => _debtSaved = true);
                          _goTo(_lastPage);
                        },
                        onSkip: () => _goTo(_lastPage),
                      ),
                      _IntroPage(
                        hero: const AppMark(size: 112),
                        title: 'Hammasi tayyor',
                        text: _debtSaved
                            ? 'Qarzlaringiz saqlandi. Endi har bir ado qilgan '
                                  'qazongizni belgilab borishingiz mumkin.'
                            : 'Qarz miqdorlarini istalgan vaqtda Sozlamalar → '
                                  '“Boshlang‘ich qarzlar” bo‘limida kiritishingiz '
                                  'mumkin.',
                        bullets: const [
                          'Ilova fatvo bermaydi va hukm chiqarmaydi',
                          'Shaxsiy savollar bo‘yicha malakali olimga murojaat '
                              'qiling',
                        ],
                      ),
                    ],
                  ),
                ),
                if (_page != _debtPage)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      Gap.page,
                      Gap.sm,
                      Gap.page,
                      Gap.lg,
                    ),
                    child: Column(
                      children: [
                        _Dots(count: 5, index: _page),
                        const SizedBox(height: Gap.lg),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            key: const Key('onboardingNext'),
                            onPressed: _page == _lastPage
                                ? _finish
                                : () => _goTo(_page + 1),
                            child: Text(
                              _page == _lastPage ? 'Boshlash' : 'Davom etish',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IntroPage extends StatelessWidget {
  const _IntroPage({
    required this.hero,
    required this.title,
    required this.text,
    required this.bullets,
  });

  final Widget hero;
  final String title;
  final String text;
  final List<String> bullets;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: Gap.lg),
      child: Column(
        children: [
          const SizedBox(height: Gap.xl),
          hero,
          const SizedBox(height: Gap.xxl),
          Text(
            title,
            textAlign: TextAlign.center,
            style: context.text.headlineMedium,
          ),
          const SizedBox(height: Gap.md),
          Text(
            text,
            textAlign: TextAlign.center,
            style: context.text.bodyLarge?.copyWith(
              color: context.palette.textSecondary,
            ),
          ),
          const SizedBox(height: Gap.xxl),
          AppCard(
            child: Column(
              children: [
                for (final b in bullets)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          size: 20,
                          color: context.palette.gold,
                        ),
                        const SizedBox(width: Gap.md),
                        Expanded(child: Text(b)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IconHero extends StatelessWidget {
  const _IconHero({required this.icon, this.gold = false});

  final IconData icon;
  final bool gold;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      width: 112,
      height: 112,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [p.heroStart, p.heroEnd],
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Positioned.fill(child: IslamicPattern(tile: 28, opacity: 0.12)),
          Icon(icon, size: 52, color: gold ? p.gold : Colors.white),
        ],
      ),
    );
  }
}

class _DebtPage extends StatelessWidget {
  const _DebtPage({required this.onSaved, required this.onSkip});

  final VoidCallback onSaved;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: pagePadding(context, top: Gap.sm, bottom: Gap.xxl),
      children: [
        Text('Boshlang‘ich qarzlar', style: context.text.headlineSmall),
        const SizedBox(height: 4),
        Text(
          'Taxminiy qazo miqdorlarini kiriting. Keyinroq istalgan vaqtda '
          'o‘zgartirishingiz mumkin.',
          style: context.text.bodySmall,
        ),
        const SizedBox(height: Gap.md),
        AppCard(
          color: context.colors.secondaryContainer,
          child: Text(
            AppTexts.disclaimer.split('\n\n').last,
            style: context.text.bodySmall?.copyWith(
              color: context.colors.onSecondaryContainer,
            ),
          ),
        ),
        const SizedBox(height: Gap.md),
        InitialDebtForm(saveLabel: 'Saqlash va davom etish', onSaved: onSaved),
        const SizedBox(height: Gap.sm),
        TextButton(
          key: const Key('skipDebt'),
          onPressed: onSkip,
          child: const Text('Keyinroq kiritaman'),
        ),
      ],
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: i == index ? 22 : 7,
            height: 7,
            decoration: BoxDecoration(
              color: i == index
                  ? context.colors.primary
                  : context.palette.track,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
      ],
    );
  }
}
