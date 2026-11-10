import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Bottom navigation with the four main sections.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: shell.currentIndex,
          onDestinationSelected: (i) =>
              shell.goBranch(i, initialLocation: i == shell.currentIndex),
          destinations: const [
            NavigationDestination(
              key: Key('tab_home'),
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Bosh sahifa',
              tooltip: 'Bosh sahifa',
            ),
            NavigationDestination(
              key: Key('tab_prayer'),
              icon: Icon(Icons.mosque_outlined),
              selectedIcon: Icon(Icons.mosque),
              label: 'Namoz',
              tooltip: 'Namoz qazolari',
            ),
            NavigationDestination(
              key: Key('tab_fasting'),
              icon: Icon(Icons.nightlight_outlined),
              selectedIcon: Icon(Icons.nightlight_round),
              label: 'Ro‘za',
              tooltip: 'Ro‘za qazolari',
            ),
            NavigationDestination(
              key: Key('tab_zikr'),
              icon: Icon(Icons.donut_large_rounded),
              selectedIcon: Icon(Icons.donut_large_rounded),
              label: 'Zikr',
              tooltip: 'Kunlik zikr',
            ),
            NavigationDestination(
              key: Key('tab_reports'),
              icon: Icon(Icons.insights_outlined),
              selectedIcon: Icon(Icons.insights_rounded),
              label: 'Hisobot',
              tooltip: 'Hisobot',
            ),
          ],
        ),
      ),
    );
  }
}
