import 'package:flutter/material.dart';

import '../calendar/calendar_view.dart';
import 'statistics_view.dart';

/// "Hisobot" tab: statistics and the activity calendar.
class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Hisobot'),
          bottom: const TabBar(
            dividerColor: Colors.transparent,
            tabs: [
              Tab(text: 'Statistika'),
              Tab(text: 'Kalendar'),
            ],
          ),
        ),
        body: const TabBarView(children: [StatisticsView(), CalendarView()]),
      ),
    );
  }
}
