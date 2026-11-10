import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/dialogs.dart';
import '../../shared/widgets/initial_debt_form.dart';

class InitialDebtScreen extends StatelessWidget {
  const InitialDebtScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Boshlang‘ich qarzlar')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Gap.page, Gap.sm, Gap.page, 40),
        children: [
          Text(
            'Bu — sizning taxminiy hisobingiz. Keyin qo‘shilgan qarzlar va ado '
            'qilingan yozuvlar alohida saqlanadi; o‘zgarishlar tarixda '
            'ko‘rinadi.',
            style: context.text.bodySmall,
          ),
          const SizedBox(height: Gap.md),
          InitialDebtForm(
            saveLabel: 'Saqlash',
            onSaved: () {
              showSnack(context, 'Boshlang‘ich qarzlar saqlandi');
              context.pop();
            },
          ),
        ],
      ),
    );
  }
}
