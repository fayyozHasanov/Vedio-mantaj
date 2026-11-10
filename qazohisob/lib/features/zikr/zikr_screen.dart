import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/worship_types.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utilities/date_utils.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/dialogs.dart';
import '../../core/widgets/islamic_pattern.dart';
import '../../core/widgets/progress.dart';
import '../../shared/domain/zikr.dart';
import '../../shared/providers.dart';

/// Daily wird counter (Naqshbandiya: 6 tasbihs × 101, twice a day).
class ZikrScreen extends ConsumerStatefulWidget {
  const ZikrScreen({super.key});

  @override
  ConsumerState<ZikrScreen> createState() => _ZikrScreenState();
}

class _ZikrScreenState extends ConsumerState<ZikrScreen>
    with WidgetsBindingObserver {
  late DateTime _day;
  late ZikrSession _session;
  List<int> _counts = List.filled(NaqshbandiyaWird.items.length, 0);
  int _selected = 0;
  bool _loaded = false;

  // Taps are saved in batches so fast counting stays smooth.
  final Set<int> _dirty = {};
  Timer? _saveTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final now = ref.read(clockProvider)();
    _day = dateOnly(now);
    _session = sessionFor(now);
    _load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _flush();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) _flush();
  }

  Future<void> _load() async {
    final progress = await ref
        .read(zikrRepositoryProvider)
        .load(_day, _session);
    if (!mounted) return;
    setState(() {
      _counts = [...progress.counts];
      _selected = progress.nextItem;
      _loaded = true;
    });
  }

  void _scheduleSave(int item) {
    _dirty.add(item);
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 500), _flush);
  }

  void _flush() {
    _saveTimer?.cancel();
    if (_dirty.isEmpty) return;
    final repo = ref.read(zikrRepositoryProvider);
    final day = _day;
    final session = _session;
    final items = [..._dirty];
    final counts = [..._counts];
    _dirty.clear();
    for (final i in items) {
      unawaited(repo.save(day, session, i, counts[i]));
    }
  }

  Future<void> _switchSession(ZikrSession session) async {
    if (session == _session) return;
    _flush();
    setState(() {
      _session = session;
      _loaded = false;
    });
    await _load();
  }

  ZikrProgress get _progress => ZikrProgress(_counts);

  void _tap() {
    final item = NaqshbandiyaWird.items[_selected];
    if (_counts[_selected] >= item.target) {
      // Already finished: move on instead of counting past the target.
      if (!_progress.isComplete) setState(() => _selected = _progress.nextItem);
      return;
    }
    setState(() => _counts[_selected]++);
    _scheduleSave(_selected);
    if (_counts[_selected] >= item.target) {
      HapticFeedback.heavyImpact();
      if (!_progress.isComplete) {
        final next = _progress.nextItem;
        Future.delayed(const Duration(milliseconds: 450), () {
          if (mounted) setState(() => _selected = next);
        });
      }
    } else {
      HapticFeedback.selectionClick();
    }
  }

  void _undo() {
    if (_counts[_selected] == 0) return;
    setState(() => _counts[_selected]--);
    _scheduleSave(_selected);
  }

  Future<void> _resetItem() async {
    final ok = await showConfirmDialog(
      context,
      title: 'Hisobni nolga tushirasizmi?',
      message:
          '“${NaqshbandiyaWird.items[_selected].latin}” hisobi '
          '(${_session.label.toLowerCase()}) 0 dan boshlanadi.',
      confirmLabel: 'Nolga tushirish',
      destructive: true,
    );
    if (!ok || !mounted) return;
    setState(() => _counts[_selected] = 0);
    _scheduleSave(_selected);
  }

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(zikrHistoryProvider).value ?? const {};
    final today = dateOnly(ref.watch(clockProvider)());
    final todayDay = history[today];
    return Scaffold(
      appBar: AppBar(title: const Text('Kunlik zikr')),
      body: !_loaded
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: pagePadding(context, top: Gap.sm, bottom: 32),
              children: [
                _WirdHeader(
                  session: _session,
                  onSession: _switchSession,
                  morning: _session == ZikrSession.morning
                      ? _progress
                      : todayDay?[ZikrSession.morning] ?? ZikrProgress.empty(),
                  evening: _session == ZikrSession.evening
                      ? _progress
                      : todayDay?[ZikrSession.evening] ?? ZikrProgress.empty(),
                ),
                const SizedBox(height: Gap.lg),
                _Counter(
                  item: NaqshbandiyaWird.items[_selected],
                  index: _selected,
                  count: _counts[_selected],
                  allDone: _progress.isComplete,
                  onTap: _tap,
                  onUndo: _undo,
                  onReset: _resetItem,
                ),
                const SectionHeader('Tasbihlar'),
                AppCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Gap.md,
                    vertical: Gap.sm,
                  ),
                  child: Column(
                    children: [
                      for (var i = 0; i < NaqshbandiyaWird.items.length; i++)
                        _ItemRow(
                          index: i,
                          item: NaqshbandiyaWird.items[i],
                          count: _counts[i],
                          selected: i == _selected,
                          onTap: () => setState(() => _selected = i),
                        ),
                    ],
                  ),
                ),
                const SectionHeader('So‘nggi 7 kun'),
                _History(history: history, today: today),
                const SizedBox(height: Gap.lg),
                Text(
                  'Vazifa matni foydalanuvchi tomonidan kiritilgan. Zikr va '
                  'vird masalalarida o‘z ustozingiz yoki malakali olimga '
                  'murojaat qiling.',
                  textAlign: TextAlign.center,
                  style: context.text.bodySmall,
                ),
              ],
            ),
    );
  }
}

class _WirdHeader extends StatelessWidget {
  const _WirdHeader({
    required this.session,
    required this.onSession,
    required this.morning,
    required this.evening,
  });

  final ZikrSession session;
  final ValueChanged<ZikrSession> onSession;
  final ZikrProgress morning;
  final ZikrProgress evening;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [p.heroStart, p.heroEnd],
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          const Positioned.fill(child: IslamicPattern()),
          Padding(
            padding: const EdgeInsets.all(Gap.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  NaqshbandiyaWird.title.toUpperCase(),
                  style: TextStyle(
                    color: p.gold,
                    fontSize: 11,
                    letterSpacing: 1.4,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  NaqshbandiyaWird.note,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 14,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: Gap.lg),
                Row(
                  children: [
                    for (final s in ZikrSession.values) ...[
                      Expanded(
                        child: _SessionChip(
                          session: s,
                          selected: s == session,
                          progress: s == ZikrSession.morning
                              ? morning
                              : evening,
                          onTap: () => onSession(s),
                        ),
                      ),
                      if (s == ZikrSession.morning)
                        const SizedBox(width: Gap.md),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionChip extends StatelessWidget {
  const _SessionChip({
    required this.session,
    required this.selected,
    required this.progress,
    required this.onTap,
  });

  final ZikrSession session;
  final bool selected;
  final ZikrProgress progress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final fg = selected ? p.heroEnd : Colors.white;
    return Material(
      color: selected ? p.gold : Colors.white.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        key: Key('session_${session.name}'),
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(Gap.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      session.label,
                      style: TextStyle(color: fg, fontWeight: FontWeight.w700),
                    ),
                  ),
                  if (progress.isComplete)
                    Icon(Icons.check_circle_rounded, color: fg, size: 18),
                ],
              ),
              Text(
                session.until,
                style: TextStyle(
                  color: fg.withValues(alpha: 0.75),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: Gap.sm),
              Text(
                '${progress.doneItems} / ${NaqshbandiyaWird.items.length} tasbih',
                key: Key('sessionDone_${session.name}'),
                style: TextStyle(color: fg, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Counter extends StatelessWidget {
  const _Counter({
    required this.item,
    required this.index,
    required this.count,
    required this.allDone,
    required this.onTap,
    required this.onUndo,
    required this.onReset,
  });

  final ZikrItem item;
  final int index;
  final int count;
  final bool allDone;
  final VoidCallback onTap;
  final VoidCallback onUndo;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final done = count >= item.target;
    return AppCard(
      padding: const EdgeInsets.all(Gap.xl),
      child: Column(
        children: [
          Text('${index + 1}-tasbih', style: context.text.labelSmall),
          const SizedBox(height: Gap.sm),
          Text(
            item.arabic,
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 30,
              height: 1.7,
              color: context.colors.onSurface,
            ),
          ),
          Text(
            item.latin,
            key: const Key('zikrLatin'),
            textAlign: TextAlign.center,
            style: context.text.titleMedium,
          ),
          const SizedBox(height: Gap.xl),
          Semantics(
            button: true,
            label: 'Tasbih: $count / ${item.target}',
            child: GestureDetector(
              key: const Key('zikrTap'),
              behavior: HitTestBehavior.opaque,
              onTap: onTap,
              child: ProgressRing(
                value: count / item.target,
                size: 210,
                stroke: 12,
                colors: [p.prayer, p.gold],
                child: Container(
                  width: 168,
                  height: 168,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: done
                        ? p.gold.withValues(alpha: 0.15)
                        : context.colors.primary.withValues(alpha: 0.07),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$count',
                        key: const Key('zikrCount'),
                        style: context.text.displaySmall?.copyWith(
                          fontSize: 52,
                          color: done ? p.gold : context.colors.primary,
                        ),
                      ),
                      Text('/ ${item.target}', style: context.text.bodySmall),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: Gap.md),
          Text(
            allDone
                ? 'Bu vaqtning vazifasi bajarildi. Alloh qabul qilsin!'
                : done
                ? 'Tasbih tugadi — keyingisiga o‘tilmoqda'
                : 'Sanash uchun doirani bosing',
            key: const Key('zikrStatus'),
            textAlign: TextAlign.center,
            style: allDone
                ? context.text.titleSmall?.copyWith(color: p.gold)
                : context.text.bodySmall,
          ),
          const SizedBox(height: Gap.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                key: const Key('zikrUndo'),
                onPressed: count > 0 ? onUndo : null,
                icon: const Icon(Icons.remove_rounded),
                label: const Text('1'),
              ),
              const SizedBox(width: Gap.md),
              TextButton.icon(
                key: const Key('zikrReset'),
                onPressed: count > 0 ? onReset : null,
                icon: const Icon(Icons.restart_alt_rounded),
                label: const Text('Nolga'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({
    required this.index,
    required this.item,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final int index;
  final ZikrItem item;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final done = count >= item.target;
    return Material(
      color: selected
          ? context.colors.primary.withValues(alpha: 0.07)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        key: Key('zikrItem_$index'),
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Gap.sm, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done ? p.gold : p.track,
                ),
                child: done
                    ? const Icon(
                        Icons.check_rounded,
                        size: 18,
                        color: Colors.white,
                      )
                    : Text(
                        '${index + 1}',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
              ),
              const SizedBox(width: Gap.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.latin,
                      style: context.text.titleSmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    ProgressBar(value: count / item.target, height: 5),
                  ],
                ),
              ),
              const SizedBox(width: Gap.md),
              Text(
                '$count / ${item.target}',
                key: Key('zikrItemCount_$index'),
                style: context.text.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _History extends StatelessWidget {
  const _History({required this.history, required this.today});

  final Map<DateTime, ZikrDay> history;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final streak = zikrStreak(history, today: today);
    final days = [
      for (var i = 6; i >= 0; i--)
        DateTime(today.year, today.month, today.day - i),
    ];
    Widget dot(bool on) => Container(
      width: 10,
      height: 10,
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: on ? p.gold : p.track,
      ),
    );
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.local_fire_department_rounded, color: p.gold),
              const SizedBox(width: Gap.sm),
              Text(
                'Ketma-ket: $streak kun',
                key: const Key('zikrStreak'),
                style: context.text.titleSmall,
              ),
            ],
          ),
          const SizedBox(height: Gap.md),
          Row(
            children: [
              for (final d in days)
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        uzWeekdaysShort[d.weekday - 1],
                        style: context.text.bodySmall,
                      ),
                      const SizedBox(height: 4),
                      dot(history[d]?[ZikrSession.morning].isComplete ?? false),
                      dot(history[d]?[ZikrSession.evening].isComplete ?? false),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: Gap.sm),
          Text(
            'Yuqori nuqta — bomdoddan keyin, pastki — asrdan keyin.',
            style: context.text.bodySmall,
          ),
        ],
      ),
    );
  }
}
