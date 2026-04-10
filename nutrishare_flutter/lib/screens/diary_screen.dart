import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/nutrition_provider.dart';
import '../widgets/add_food_sheet.dart';
import '../widgets/log_sleep_sheet.dart';
import '../widgets/macro_nutrient_card.dart';

const _kBg     = Color(0xFF1A3528);
const _kCard   = Color(0xFF243D2F);
const _kGreen  = Color(0xFFA8E040);
const _kOrange = Color(0xFFF09038);
const _kDim    = Color(0xFF6B9080);
const _kLine   = Color(0xFF2B4A38);
const _kRed    = Color(0xFFD94F4F);

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  DateTime _date = DateTime.now();
  final Set<String> _expanded = {};
  final _summaryPageCtrl = PageController();
  int _summaryPage = 0;
  int _loadGen = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAll());
  }

  @override
  void dispose() {
    _summaryPageCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    final gen = ++_loadGen;
    final date = _date;
    await context.read<NutritionProvider>().loadDiary(date);
    if (gen != _loadGen || !mounted) return;
  }

  void _prevDay() {
    setState(() { _date = _date.subtract(const Duration(days: 1)); _expanded.clear(); });
    _loadAll();
  }

  void _nextDay() {
    final tomorrow = _date.add(const Duration(days: 1));
    final today    = DateTime.now();
    if (tomorrow.isAfter(DateTime(today.year, today.month, today.day))) return;
    setState(() { _date = tomorrow; _expanded.clear(); });
    _loadAll();
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String get _dateLabel {
    final now = DateTime.now();
    if (_isSameDay(_date, now)) {
      const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      return 'Today, ${months[now.month - 1]} ${now.day}';
    }
    if (_isSameDay(_date, now.subtract(const Duration(days: 1)))) return 'Yesterday';
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${_date.day} ${months[_date.month - 1]} ${_date.year}';
  }

  static const _meals = ['uncategorized', 'breakfast', 'lunch', 'dinner', 'snack'];

  @override
  Widget build(BuildContext context) {
    final nutrition = context.watch<NutritionProvider>();
    final consumed  = (nutrition.diarySummary?['total_calories'] as num?)?.toDouble() ?? 0;
    final target    = (nutrition.diarySummary?['target_calories'] as num?)?.toDouble() ?? 0;
    final remaining = math.max(0.0, target - consumed);

    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top navigation ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Row(
                children: [
                  IconButton(onPressed: _prevDay, icon: const Icon(Icons.chevron_left, color: _kGreen)),
                  Expanded(
                    child: Text(
                      _dateLabel,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: _kGreen, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    onPressed: _isSameDay(_date, DateTime.now()) ? null : _nextDay,
                    icon: Icon(Icons.chevron_right, color: _isSameDay(_date, DateTime.now()) ? _kLine : _kGreen),
                  ),
                ],
              ),
            ),
            const Divider(color: _kLine, height: 1),

            // ── Content ──────────────────────────────────────────────────────
            Expanded(
              child: nutrition.isDiaryLoading
                  ? const Center(child: CircularProgressIndicator(color: _kGreen))
                  : RefreshIndicator(
                      onRefresh: _loadAll,
                      color: _kGreen,
                      backgroundColor: _kCard,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                        children: [
                          _SummaryPageView(
                            consumed: consumed,
                            remaining: remaining,
                            target: target,
                            nutrition: nutrition,
                            pageCtrl: _summaryPageCtrl,
                            currentPage: _summaryPage,
                            onPageChanged: (p) => setState(() => _summaryPage = p),
                          ),
                          const SizedBox(height: 12),
                          _WaterRow(
                            ml: nutrition.waterMl,
                            targetMl: nutrition.waterTargetMl,
                            onAdd: _showWaterDialog,
                          ),
                          const SizedBox(height: 8),
                          _SleepRow(
                            sleepData: nutrition.sleepData,
                            onLog: () => LogSleepSheet.show(context, date: _date),
                          ),
                          const SizedBox(height: 12),
                          for (final meal in _meals)
                            _MealSection(
                              mealType: meal,
                              logs: nutrition.logsForMeal(meal),
                              isExpanded: _expanded.contains(meal),
                              date: _date,
                              onToggle: () => setState(() {
                                if (_expanded.contains(meal)) _expanded.remove(meal);
                                else _expanded.add(meal);
                              }),
                              onDeleteLog: (id) async {
                                final ok = await nutrition.removeLog(id);
                                if (!ok && context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Gagal menghapus log. Coba lagi.'), backgroundColor: Colors.red),
                                  );
                                }
                              },
                            onUpdateLog: (id, qty) => nutrition.updateLog(id, qty),
                            ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showWaterDialog() async {
    final nutrition = context.read<NutritionProvider>();
    int tempMl       = nutrition.waterMl;
    int tempTargetMl = nutrition.waterTargetMl;

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _kCard,
        title: const Text('Log Air Minum', style: TextStyle(color: Colors.white, fontSize: 16)),
        content: StatefulBuilder(builder: (_, setS) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${(tempMl / 1000).toStringAsFixed(1)} L',
              style: const TextStyle(color: _kGreen, fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text('Target: ', style: TextStyle(color: _kDim, fontSize: 12)),
              GestureDetector(
                onTap: () async {
                  int t = tempTargetMl;
                  await showDialog<void>(
                    context: ctx,
                    builder: (ctx2) => AlertDialog(
                      backgroundColor: _kCard,
                      title: const Text('Set Target Air', style: TextStyle(color: Colors.white, fontSize: 14)),
                      content: StatefulBuilder(builder: (_, setS2) => Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove, color: _kDim),
                            onPressed: () => setS2(() => t = math.max(250, t - 250)),
                          ),
                          Text('${(t / 1000).toStringAsFixed(1)} L', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: const Icon(Icons.add, color: _kGreen),
                            onPressed: () => setS2(() => t = t + 250),
                          ),
                        ],
                      )),
                      actions: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: _kGreen, foregroundColor: _kBg),
                          onPressed: () async {
                            await nutrition.updateWaterTarget(t);
                            setS(() => tempTargetMl = t);
                            if (ctx2.mounted) Navigator.pop(ctx2);
                          },
                          child: const Text('Simpan'),
                        ),
                      ],
                    ),
                  );
                },
                child: Text(
                  '${(tempTargetMl / 1000).toStringAsFixed(1)} L ✎',
                  style: const TextStyle(color: _kDim, fontSize: 12, decoration: TextDecoration.underline),
                ),
              ),
            ]),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, color: _kDim),
                onPressed: () => setS(() => tempMl = math.max(0, tempMl - 250)),
              ),
              const Text('±250ml', style: TextStyle(color: _kDim, fontSize: 12)),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, color: _kGreen),
                onPressed: () => setS(() => tempMl = tempMl + 250),
              ),
            ]),
          ],
        )),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal', style: TextStyle(color: _kDim))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _kGreen, foregroundColor: _kBg),
            onPressed: () async {
              await nutrition.updateWater(_date, tempMl);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}

// ── Summary PageView (rings + macros) ─────────────────────────────────────────

class _SummaryPageView extends StatelessWidget {
  final double consumed;
  final double remaining;
  final double target;
  final NutritionProvider nutrition;
  final PageController pageCtrl;
  final int currentPage;
  final ValueChanged<int> onPageChanged;

  const _SummaryPageView({
    required this.consumed,
    required this.remaining,
    required this.target,
    required this.nutrition,
    required this.pageCtrl,
    required this.currentPage,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final calActual  = (nutrition.diarySummary?['total_calories']  as num?)?.toDouble() ?? 0;
    final proActual  = (nutrition.diarySummary?['total_protein_g'] as num?)?.toDouble() ?? 0;
    final fatActual  = (nutrition.diarySummary?['total_fat_g']     as num?)?.toDouble() ?? 0;
    final carbActual = (nutrition.diarySummary?['total_carbs_g']   as num?)?.toDouble() ?? 0;
    final calTarget  = (nutrition.diarySummary?['target_calories']  as num?)?.toDouble() ?? 0;
    final proTarget  = (nutrition.diarySummary?['target_protein_g'] as num?)?.toDouble() ?? 0;
    final fatTarget  = (nutrition.diarySummary?['target_fat_g']     as num?)?.toDouble() ?? 0;
    final carbTarget = (nutrition.diarySummary?['target_carbs_g']   as num?)?.toDouble() ?? 0;

    return Column(
      children: [
        SizedBox(
          height: 162,
          child: PageView(
            controller: pageCtrl,
            onPageChanged: onPageChanged,
            children: [
              _CalorieRings(consumed: consumed, remaining: remaining, target: target),
              MacroNutrientCard(
                calActual: calActual, calTarget: calTarget,
                proActual: proActual, proTarget: proTarget,
                fatActual: fatActual, fatTarget: fatTarget,
                carbActual: carbActual, carbTarget: carbTarget,
                logs: nutrition.diaryLogs,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: currentPage > 0
                  ? () => pageCtrl.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut)
                  : null,
              icon: Icon(Icons.chevron_left, color: currentPage > 0 ? _kGreen : _kLine, size: 20),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            ),
            ...List.generate(2, (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: currentPage == i ? 16 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: currentPage == i ? _kGreen : _kLine,
                borderRadius: BorderRadius.circular(3),
              ),
            )),
            IconButton(
              onPressed: currentPage < 1
                  ? () => pageCtrl.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut)
                  : null,
              icon: Icon(Icons.chevron_right, color: currentPage < 1 ? _kGreen : _kLine, size: 20),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Calorie rings ─────────────────────────────────────────────────────────────

class _CalorieRings extends StatelessWidget {
  final double consumed;
  final double remaining;
  final double target;

  const _CalorieRings({required this.consumed, required this.remaining, required this.target});

  @override
  Widget build(BuildContext context) {
    final consProg = target > 0 ? (consumed / target).clamp(0.0, 1.0) : 0.0;
    final remProg  = target > 0 ? (remaining / target).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(color: _kCard, borderRadius: BorderRadius.circular(16)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _Ring(progress: consProg, color: const Color(0xFFD4A570), value: consumed.toInt(), label: 'consumed'),
          _Ring(progress: remProg,  color: _kOrange,                value: remaining.toInt(), label: 'remaining'),
        ],
      ),
    );
  }
}

class _Ring extends StatelessWidget {
  final double progress;
  final Color color;
  final int value;
  final String label;

  const _Ring({required this.progress, required this.color, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final display = value.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
    return Column(
      children: [
        SizedBox(
          width: 110,
          height: 110,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(size: const Size(110, 110), painter: _RingPainter(progress: progress, color: color)),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(display, style: TextStyle(color: color, fontSize: 17, fontWeight: FontWeight.bold)),
                  const Text('calories', style: TextStyle(color: Colors.white54, fontSize: 10)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;

  const _RingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 8;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0, 2 * math.pi, false,
      Paint()..color = _kLine..style = PaintingStyle.stroke..strokeWidth = 10,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, 2 * math.pi * progress, false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) => old.progress != progress;
}

// ── Water row ─────────────────────────────────────────────────────────────────

class _WaterRow extends StatelessWidget {
  final int ml;
  final int targetMl;
  final VoidCallback onAdd;

  const _WaterRow({required this.ml, required this.targetMl, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final liters       = (ml / 1000).toStringAsFixed(1);
    final targetLiters = (targetMl / 1000).toStringAsFixed(1);
    return GestureDetector(
      onTap: onAdd,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(color: _kCard, borderRadius: BorderRadius.circular(14)),
        child: Row(
          children: [
            const Icon(Icons.water_drop_outlined, color: Color(0xFF5B8DEF), size: 20),
            const SizedBox(width: 10),
            const Text('Water', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(width: 8),
            Text(
              '$liters / $targetLiters liter',
              style: const TextStyle(color: _kDim, fontSize: 13),
            ),
            const Spacer(),
            const Icon(Icons.keyboard_arrow_down, color: _kDim),
          ],
        ),
      ),
    );
  }
}

// ── Sleep row ─────────────────────────────────────────────────────────────────

class _SleepRow extends StatelessWidget {
  final Map<String, dynamic>? sleepData;
  final VoidCallback onLog;

  const _SleepRow({required this.sleepData, required this.onLog});

  @override
  Widget build(BuildContext context) {
    final duration = (sleepData?['duration'] as num?)?.toDouble();
    final String label;
    if (duration != null) {
      final hh = duration.floor();
      final mm = ((duration - hh) * 60).round();
      label = '${hh}j ${mm}m';
    } else {
      label = 'Tap untuk log tidur';
    }

    return GestureDetector(
      onTap: onLog,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(color: _kCard, borderRadius: BorderRadius.circular(14)),
        child: Row(
          children: [
            const Icon(Icons.nightlight_round, color: Color(0xFF5B8DEF), size: 20),
            const SizedBox(width: 10),
            const Text('Sleep', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: _kDim, fontSize: 13)),
            const Spacer(),
            const Icon(Icons.edit_outlined, color: _kDim, size: 16),
          ],
        ),
      ),
    );
  }
}

// ── Meal section ──────────────────────────────────────────────────────────────

class _MealSection extends StatelessWidget {
  final String mealType;
  final List<dynamic> logs;
  final bool isExpanded;
  final DateTime date;
  final VoidCallback onToggle;
  final Future<void> Function(String logId) onDeleteLog;
  final Future<bool> Function(String logId, double quantityG) onUpdateLog;

  const _MealSection({
    required this.mealType,
    required this.logs,
    required this.isExpanded,
    required this.date,
    required this.onToggle,
    required this.onDeleteLog,
    required this.onUpdateLog,
  });

  static String _label(String t) => const {
    'breakfast': 'Breakfast',
    'lunch': 'Lunch',
    'dinner': 'Dinner',
    'snack': 'Snack',
    'uncategorized': 'Uncategorized',
  }[t] ?? t;

  @override
  Widget build(BuildContext context) {
    final totalCal = logs.fold<double>(0, (s, l) => s + ((l['calories'] as num?)?.toDouble() ?? 0));
    final show = isExpanded || logs.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: _kCard, borderRadius: BorderRadius.circular(14)),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => AddFoodSheet.show(context, mealType: mealType, date: date),
                    child: const Icon(Icons.add_circle_outline, color: _kGreen, size: 22),
                  ),
                  const SizedBox(width: 10),
                  Text(_label(mealType),
                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  if (logs.isNotEmpty)
                    Text('${totalCal.toInt()} kcal', style: const TextStyle(color: _kDim, fontSize: 12)),
                  const SizedBox(width: 8),
                  Icon(show ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: _kDim, size: 18),
                ],
              ),
            ),
          ),
          if (show) ...[
            const Divider(color: _kLine, height: 1),
            if (logs.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Belum ada makanan — tap + untuk menambah', style: TextStyle(color: _kDim, fontSize: 12)),
              )
            else
              for (final log in logs)
                _LogEntry(
                  log: log,
                  onDelete: () => onDeleteLog(log['id'].toString()),
                  onUpdate: onUpdateLog,
                ),
          ],
        ],
      ),
    );
  }
}

class _LogEntry extends StatelessWidget {
  final dynamic log;
  final VoidCallback onDelete;
  final Future<bool> Function(String logId, double quantityG) onUpdate;

  const _LogEntry({required this.log, required this.onDelete, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    final name = log['food_name'] as String? ?? '-';
    final qty  = (log['quantity_g'] as num?)?.toDouble() ?? 0;
    final cal  = (log['calories']   as num?)?.toDouble() ?? 0;
    final pro  = (log['protein_g']  as num?)?.toDouble() ?? 0;
    final carb = (log['carbs_g']    as num?)?.toDouble() ?? 0;
    final fat  = (log['fat_g']      as num?)?.toDouble() ?? 0;

    return Dismissible(
      key: Key(log['id'].toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: _kRed.withValues(alpha: 0.2),
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(14)),
        ),
        child: const Icon(Icons.delete_outline, color: _kRed),
      ),
      onDismissed: (_) => onDelete(),
      child: InkWell(
        onTap: () => _LogDetailSheet.show(
          context,
          log: log,
          name: name, qty: qty, cal: cal, pro: pro, carb: carb, fat: fat,
          onDelete: onDelete,
          onUpdate: onUpdate,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              const Icon(Icons.restaurant, color: _kDim, size: 16),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(color: Colors.white, fontSize: 13)),
                    Text(
                      '${qty.toInt()}g · P ${pro.toStringAsFixed(1)}g · C ${carb.toStringAsFixed(1)}g · F ${fat.toStringAsFixed(1)}g',
                      style: const TextStyle(color: _kDim, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Text('${cal.toInt()} kcal', style: const TextStyle(color: _kDim, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Log detail / edit sheet ───────────────────────────────────────────────────

class _LogDetailSheet extends StatefulWidget {
  final dynamic log;
  final String name;
  final double qty, cal, pro, carb, fat;
  final VoidCallback onDelete;
  final Future<bool> Function(String logId, double quantityG) onUpdate;

  const _LogDetailSheet({
    required this.log, required this.name,
    required this.qty, required this.cal, required this.pro,
    required this.carb, required this.fat,
    required this.onDelete, required this.onUpdate,
  });

  static void show(
    BuildContext context, {
    required dynamic log,
    required String name,
    required double qty, required double cal, required double pro,
    required double carb, required double fat,
    required VoidCallback onDelete,
    required Future<bool> Function(String, double) onUpdate,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _LogDetailSheet(
        log: log, name: name, qty: qty, cal: cal,
        pro: pro, carb: carb, fat: fat,
        onDelete: onDelete, onUpdate: onUpdate,
      ),
    );
  }

  @override
  State<_LogDetailSheet> createState() => _LogDetailSheetState();
}

class _LogDetailSheetState extends State<_LogDetailSheet> {
  late final TextEditingController _ctrl;
  bool _saving = false;

  // Per-gram ratios derived from original log
  late final double _calPerG;
  late final double _proPerG;
  late final double _carbPerG;
  late final double _fatPerG;

  double get _currentQty => double.tryParse(_ctrl.text.replaceAll(',', '.')) ?? widget.qty;
  double get _previewCal  => _calPerG  * _currentQty;
  double get _previewPro  => _proPerG  * _currentQty;
  double get _previewCarb => _carbPerG * _currentQty;
  double get _previewFat  => _fatPerG  * _currentQty;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.qty.toInt().toString());
    _ctrl.addListener(() => setState(() {}));
    final g = widget.qty > 0 ? widget.qty : 1;
    _calPerG  = widget.cal  / g;
    _proPerG  = widget.pro  / g;
    _carbPerG = widget.carb / g;
    _fatPerG  = widget.fat  / g;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final val = double.tryParse(_ctrl.text.replaceAll(',', '.'));
    if (val == null || val <= 0) return;
    setState(() => _saving = true);
    final ok = await widget.onUpdate(widget.log['id'].toString(), val);
    if (mounted) {
      setState(() => _saving = false);
      if (ok) {
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memperbarui log. Coba lagi.'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: _kBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: _kLine, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(widget.name, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                ),
                GestureDetector(
                  onTap: () { Navigator.pop(context); widget.onDelete(); },
                  child: const Icon(Icons.delete_outline, color: _kRed, size: 22),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Nutrition grid
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: _kCard, borderRadius: BorderRadius.circular(14)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NutrientBox(label: 'Energy',  value: '${_previewCal.toInt()}', unit: 'kcal', color: _kOrange),
                  _NutrientBox(label: 'Protein',  value: _previewPro.toStringAsFixed(1),  unit: 'g', color: const Color(0xFF5B8DEF)),
                  _NutrientBox(label: 'Carbs',    value: _previewCarb.toStringAsFixed(1), unit: 'g', color: _kGreen),
                  _NutrientBox(label: 'Fat',      value: _previewFat.toStringAsFixed(1),  unit: 'g', color: _kRed),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Gram input
            Row(
              children: [
                const Text('Quantity', style: TextStyle(color: Colors.white70, fontSize: 14)),
                const Spacer(),
                SizedBox(
                  width: 90,
                  child: TextField(
                    controller: _ctrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    decoration: const InputDecoration(
                      suffixText: 'g',
                      suffixStyle: TextStyle(color: _kDim),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: _kDim)),
                      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: _kGreen)),
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kGreen,
                  foregroundColor: _kBg,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: _saving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Simpan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NutrientBox extends StatelessWidget {
  final String label, value, unit;
  final Color color;
  const _NutrientBox({required this.label, required this.value, required this.unit, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
        Text(unit, style: const TextStyle(color: _kDim, fontSize: 10)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
      ],
    );
  }
}
