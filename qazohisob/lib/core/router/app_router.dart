import 'package:go_router/go_router.dart';

import '../../features/fasting/fasting_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/prayer/prayer_detail_screen.dart';
import '../../features/prayer/prayer_screen.dart';
import '../../features/settings/initial_debt_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/statistics/reports_screen.dart';
import '../../shared/widgets/app_shell.dart';
import '../constants/worship_types.dart';

GoRouter createRouter({required bool onboarded}) => GoRouter(
  initialLocation: onboarded ? '/home' : '/onboarding',
  routes: [
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => AppShell(shell: shell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/prayer',
              builder: (context, state) => const PrayerScreen(),
              routes: [
                GoRoute(
                  path: ':type',
                  builder: (context, state) {
                    final name = state.pathParameters['type'];
                    final type = PrayerType.values.firstWhere(
                      (t) => t.name == name,
                      orElse: () => PrayerType.bomdod,
                    );
                    return PrayerDetailScreen(type: type);
                  },
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/fasting',
              builder: (context, state) => const FastingScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/reports',
              builder: (context, state) => const ReportsScreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
      routes: [
        GoRoute(
          path: 'initial',
          builder: (context, state) => const InitialDebtScreen(),
        ),
      ],
    ),
  ],
);
