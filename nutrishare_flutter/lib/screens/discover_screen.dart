import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/nutrition_provider.dart';
import '../widgets/nutrishare_logo.dart';
import '../widgets/macro_nutrient_card.dart';
import 'edit_profile_screen.dart';

const _kBg     = Color(0xFF1A3528);
const _kCard   = Color(0xFF243D2F);
const _kGreen  = Color(0xFFA8E040);
const _kOrange = Color(0xFFF09038);
const _kRed    = Color(0xFFD94F4F);
const _kDim    = Color(0xFF6B9080);
const _kLine   = Color(0xFF2B4A38);

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NutritionProvider>().loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user       = context.watch<AuthProvider>().user;
    final nutrition  = context.watch<NutritionProvider>();

    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: nutrition.isDashboardLoading
            ? const Center(child: CircularProgressIndicator(color: _kGreen))
            : ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const NutriShareLogo(compact: true),
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                        ),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: _kDim, width: 1.5),
                          ),
                          child: const Icon(Icons.person, color: _kDim, size: 20),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const _StreakCard(),
                  const SizedBox(height: 20),
                  const _SectionLabel('Report'),
                  const SizedBox(height: 8),
                  _ReportCard(nutrition: nutrition),
                  const SizedBox(height: 20),
                  const _SectionLabel('Energy History'),
                  const SizedBox(height: 8),
                  _EnergyHistoryCard(nutrition: nutrition),
                  const SizedBox(height: 8),
                  _MacroBarsCard(nutrition: nutrition),
                  const SizedBox(height: 20),
                  const _SectionLabel('Overview'),
                  const SizedBox(height: 8),
                  _OverviewCard(user: user, nutrition: nutrition),
                  const SizedBox(height: 20),
                  _SectionLabel(_weightChangeLabel(nutrition.weightHistory, user?.targetWeightKg)),
                  const SizedBox(height: 8),
                  _WeightChangeCard(nutrition: nutrition, user: user),
                  const SizedBox(height: 24),
                ],
              ),
      ),
    );
  }
}

String _weightChangeLabel(List<dynamic> history, double? targetWeight) {
  if (history.length < 2) return 'Weight Change';
  final first = (history.first['weight_kg'] as num).toDouble();
  final last  = (history.last['weight_kg']  as num).toDouble();
  final diff  = last - first;
  final sign  = diff >= 0 ? '+' : '';
  return 'Weight Change: $sign${diff.toStringAsFixed(1)} kg';
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(color: _kGreen, fontSize: 16, fontWeight: FontWeight.bold),
    );
  }
}

class _StreakCard extends StatelessWidget {
  const _StreakCard();

  @override
  Widget build(BuildContext context) {
    final streak = context.watch<NutritionProvider>().streak;
    final subtitle = streak == 0
        ? 'Log makanan hari ini untuk mulai streak!'
        : streak == 1
            ? 'Bagus! Terus log setiap hari 🎯'
            : 'Luar biasa! Terus pertahankan! 💪';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(color: _kCard, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Text(streak == 0 ? '🌱' : '🔥', style: const TextStyle(fontSize: 52)),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(children: [
                  TextSpan(
                    text: '$streak ',
                    style: TextStyle(
                      color: streak == 0 ? _kDim : _kOrange,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const TextSpan(
                    text: 'streak days',
                    style: TextStyle(color: _kGreen, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ]),
              ),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(color: _kDim, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final NutritionProvider nutrition;
  const _ReportCard({required this.nutrition});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: _kCard, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            nutrition.calorieStatus,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '"${nutrition.insightText}"',
            style: const TextStyle(color: _kDim, fontSize: 12, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}

class _EnergyHistoryCard extends StatelessWidget {
  final NutritionProvider nutrition;
  const _EnergyHistoryCard({required this.nutrition});

  static const _days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  @override
  Widget build(BuildContext context) {
    final history = nutrition.dailyHistory;
    final target  = history.isNotEmpty
        ? (history.last['target'] as num?)?.toDouble() ?? 0
        : (nutrition.targets?['calories'] as num?)?.toDouble() ?? 0;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      decoration: BoxDecoration(color: _kCard, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('KCAL', style: TextStyle(color: _kDim, fontSize: 11)),
              if (target > 0)
                Text('Target: ${target.toInt()} kcal',
                    style: const TextStyle(color: _kDim, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 100,
            child: history.isEmpty
                ? const Center(
                    child: Text('Log makanan untuk melihat riwayat',
                        style: TextStyle(color: _kDim, fontSize: 12)))
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: history.map((d) {
                      final cal    = (d['calories'] as num?)?.toDouble() ?? 0;
                      final tgt    = (d['target']   as num?)?.toDouble() ?? 1;
                      final ratio  = tgt > 0 ? (cal / tgt).clamp(0.0, 1.5) : 0.0;
                      final isOver = cal > tgt * 1.0 && tgt > 0;
                      final color  = cal == 0 ? _kLine : (isOver ? _kOrange : _kGreen);
                      final dateStr = d['date'] as String? ?? '';
                      final dow    = dateStr.isNotEmpty
                          ? _days[DateTime.parse(dateStr).weekday % 7]
                          : '';

                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (cal > 0)
                                Text('${(cal / 1000).toStringAsFixed(1)}k',
                                    style: TextStyle(color: color, fontSize: 8)),
                              const SizedBox(height: 2),
                              Container(
                                height: ratio * 80,
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(dow, style: const TextStyle(color: _kDim, fontSize: 10)),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
          ),
          const SizedBox(height: 6),
          Row(children: [
            Container(width: 10, height: 10, decoration: BoxDecoration(color: _kGreen, borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 4),
            const Text('On target', style: TextStyle(color: _kDim, fontSize: 10)),
            const SizedBox(width: 12),
            Container(width: 10, height: 10, decoration: BoxDecoration(color: _kOrange, borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 4),
            const Text('Over target', style: TextStyle(color: _kDim, fontSize: 10)),
          ]),
        ],
      ),
    );
  }
}

class _MacroBarsCard extends StatelessWidget {
  final NutritionProvider nutrition;
  const _MacroBarsCard({required this.nutrition});

  @override
  Widget build(BuildContext context) {
    final calActual  = (nutrition.todaySummary?['total_calories']  as num?)?.toDouble() ?? 0;
    final proActual  = (nutrition.todaySummary?['total_protein_g'] as num?)?.toDouble() ?? 0;
    final fatActual  = (nutrition.todaySummary?['total_fat_g']     as num?)?.toDouble() ?? 0;
    final carbActual = (nutrition.todaySummary?['total_carbs_g']   as num?)?.toDouble() ?? 0;

    final calTarget  = (nutrition.targets?['calories']  as num?)?.toDouble() ?? 0;
    final proTarget  = (nutrition.targets?['protein_g'] as num?)?.toDouble() ?? 0;
    final fatTarget  = (nutrition.targets?['fat_g']     as num?)?.toDouble() ?? 0;
    final carbTarget = (nutrition.targets?['carbs_g']   as num?)?.toDouble() ?? 0;

    return MacroNutrientCard(
      calActual: calActual, calTarget: calTarget,
      proActual: proActual, proTarget: proTarget,
      fatActual: fatActual, fatTarget: fatTarget,
      carbActual: carbActual, carbTarget: carbTarget,
      logs: nutrition.todayLogs,
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final dynamic user;
  final NutritionProvider nutrition;

  const _OverviewCard({required this.user, required this.nutrition});

  Future<void> _logWeight(BuildContext context) async {
    final current = user?.weightKg as double?;
    final weightCtrl = TextEditingController(
      text: current != null ? current.toStringAsFixed(1) : '',
    );
    DateTime selectedDate = DateTime.now();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          backgroundColor: _kCard,
          title: const Text('Log Weight', style: TextStyle(color: Colors.white, fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: weightCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  hintText: '0.0',
                  hintStyle: TextStyle(color: _kDim),
                  suffixText: 'kg',
                  suffixStyle: TextStyle(color: _kDim, fontSize: 16),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: _kDim)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: _kGreen)),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    initialDate: selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                    builder: (_, child) => Theme(
                      data: ThemeData.dark().copyWith(
                        colorScheme: const ColorScheme.dark(primary: Color(0xFFA8E040)),
                      ),
                      child: child!,
                    ),
                  );
                  if (picked != null) setS(() => selectedDate = picked);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: _kBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _kDim),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _fmtDate(selectedDate),
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      const Icon(Icons.calendar_today_outlined, color: _kDim, size: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal', style: TextStyle(color: _kDim)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: _kGreen, foregroundColor: _kBg),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final val = double.tryParse(weightCtrl.text.replaceAll(',', '.'));
    if (val == null || val <= 0) return;

    final nutrition = context.read<NutritionProvider>();
    final auth      = context.read<AuthProvider>();

    final ok = await nutrition.logWeight(date: selectedDate, weightKg: val);
    if (!context.mounted) return;
    if (ok) {
      await auth.checkLoginStatus();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menyimpan berat badan. Coba lagi.'), backgroundColor: Colors.red),
      );
    }
  }

  static String _fmtDate(DateTime d) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final currentWeight = user?.weightKg as double?;
    final weightLabel   = currentWeight != null ? '${currentWeight.toStringAsFixed(1)} kg' : 'xx kg';
    final forecastLabel = nutrition.forecastDateLabel;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: _kCard, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _OverviewBox(
                  icon: Icons.monitor_weight_outlined,
                  title: 'Current Weight',
                  value: weightLabel,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _OverviewBox(
                  icon: Icons.flag_outlined,
                  title: 'Goal Forecast',
                  value: forecastLabel,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _logWeight(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: _kGreen,
                foregroundColor: _kBg,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                elevation: 0,
              ),
              child: const Text(
                'LOG WEIGHT',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewBox extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _OverviewBox({required this.icon, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: _kBg, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Icon(icon, color: _kGreen, size: 30),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(color: _kDim, fontSize: 11),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _WeightChangeCard extends StatefulWidget {
  final NutritionProvider nutrition;
  final dynamic user;

  const _WeightChangeCard({required this.nutrition, required this.user});

  @override
  State<_WeightChangeCard> createState() => _WeightChangeCardState();
}

class _WeightChangeCardState extends State<_WeightChangeCard> {
  int? _selectedIndex;
  Timer? _tooltipTimer;

  @override
  void dispose() {
    _tooltipTimer?.cancel();
    super.dispose();
  }

  static const _labelWidth = 32.0;
  static const _gap = 4.0;

  int? _hitTest(Offset localPos, double chartWidth, int n) {
    if (n == 0) return null;
    final chartLeft = _labelWidth + _gap;
    if (localPos.dx < chartLeft) return null;
    // Find closest point by x
    int closest = 0;
    double minDist = double.infinity;
    for (int i = 0; i < n; i++) {
      final px = chartLeft + chartWidth * (n == 1 ? 0.5 : i / (n - 1));
      final dist = (localPos.dx - px).abs();
      if (dist < minDist) { minDist = dist; closest = i; }
    }
    return minDist < 24 ? closest : null;
  }

  static String _shortDate(String iso) {
    try {
      final dt = DateTime.parse(iso);
      const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      return '${m[dt.month - 1]} ${dt.day}, ${dt.year}';
    } catch (_) { return iso; }
  }

  @override
  Widget build(BuildContext context) {
    final history      = widget.nutrition.weightHistory;
    final targetWeight = widget.user?.targetWeightKg as double?;

    if (history.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: _kCard, borderRadius: BorderRadius.circular(16)),
        child: const Center(
          child: Text('Log berat badan untuk melihat grafik', style: TextStyle(color: _kDim, fontSize: 13)),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(color: _kCard, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('KG', style: TextStyle(color: _kDim, fontSize: 11)),
          const SizedBox(height: 6),
          LayoutBuilder(builder: (_, constraints) {
            final chartWidth = constraints.maxWidth - _labelWidth - _gap;
            return GestureDetector(
              onTapDown: (d) {
                final idx = _hitTest(d.localPosition, chartWidth, history.length);
                setState(() => _selectedIndex = idx);
                _tooltipTimer?.cancel();
                _tooltipTimer = Timer(const Duration(seconds: 2), () {
                  if (mounted) setState(() => _selectedIndex = null);
                });
              },
              child: SizedBox(
                height: 130,
                child: CustomPaint(
                  size: Size.infinite,
                  painter: _WeightChartPainter(
                    history: history,
                    targetWeight: targetWeight,
                    selectedIndex: _selectedIndex,
                    lineColor: _kLine,
                    labelColor: _kDim,
                    dataColor: _kOrange,
                    targetColor: _kRed,
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_shortDate(history.first['log_date'] as String), style: const TextStyle(color: _kDim, fontSize: 10)),
              Text(_shortDate(history.last['log_date']  as String), style: const TextStyle(color: _kDim, fontSize: 10)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 24, height: 3, color: _kOrange),
              const SizedBox(width: 6),
              const Text('Weight (kg)', style: TextStyle(color: Colors.white70, fontSize: 11)),
              if (targetWeight != null) ...[
                const SizedBox(width: 16),
                Container(width: 24, height: 3, color: _kRed),
                const SizedBox(width: 6),
                Text('Target: ${targetWeight.toStringAsFixed(1)} kg', style: const TextStyle(color: Colors.white70, fontSize: 11)),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _WeightChartPainter extends CustomPainter {
  final List<dynamic> history;
  final double? targetWeight;
  final int? selectedIndex;
  final Color lineColor;
  final Color labelColor;
  final Color dataColor;
  final Color targetColor;

  const _WeightChartPainter({
    required this.history,
    required this.targetWeight,
    required this.selectedIndex,
    required this.lineColor,
    required this.labelColor,
    required this.dataColor,
    required this.targetColor,
  });

  static const _labelWidth = 32.0;
  static const _gap = 4.0;

  @override
  void paint(Canvas canvas, Size size) {
    if (history.isEmpty) return;

    final chartLeft  = _labelWidth + _gap;
    final chartWidth = size.width - chartLeft;

    final weights = history.map((e) => (e['weight_kg'] as num).toDouble()).toList();
    double minW = weights.reduce((a, b) => a < b ? a : b);
    double maxW = weights.reduce((a, b) => a > b ? a : b);
    if (targetWeight != null) {
      minW = minW < targetWeight! ? minW : targetWeight!;
      maxW = maxW > targetWeight! ? maxW : targetWeight!;
    }
    final range    = (maxW - minW).abs();
    final paddedMin = minW - (range * 0.1 + 0.5);
    final paddedMax = maxW + (range * 0.1 + 0.5);
    final span     = paddedMax - paddedMin;

    double toY(double w) => size.height * (1 - (w - paddedMin) / span);

    final n = history.length;
    Offset point(int i) {
      final x = chartLeft + chartWidth * (n == 1 ? 0.5 : i / (n - 1));
      return Offset(x, toY(weights[i]));
    }

    // Grid
    final gridPaint = Paint()..color = lineColor..strokeWidth = 1;
    for (int i = 0; i <= 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(chartLeft, y), Offset(size.width, y), gridPaint);
      final val = paddedMax - span * i / 4;
      final tp = TextPainter(
        text: TextSpan(text: val.toStringAsFixed(1), style: TextStyle(color: labelColor, fontSize: 9)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(0, y - tp.height / 2));
    }

    // Target line
    if (targetWeight != null) {
      canvas.drawLine(
        Offset(chartLeft, toY(targetWeight!)), Offset(size.width, toY(targetWeight!)),
        Paint()..color = targetColor..strokeWidth = 1.5..style = PaintingStyle.stroke,
      );
    }

    // Data line
    final linePaint = Paint()..color = dataColor..strokeWidth = 2..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    final path = Path()..moveTo(point(0).dx, point(0).dy);
    for (int i = 1; i < n; i++) path.lineTo(point(i).dx, point(i).dy);
    canvas.drawPath(path, linePaint);

    // Dots
    for (int i = 0; i < n; i++) {
      final isSelected = i == selectedIndex;
      canvas.drawCircle(point(i), isSelected ? 5 : 3,
          Paint()..color = isSelected ? Colors.white : dataColor);
      if (isSelected) {
        canvas.drawCircle(point(i), 5,
            Paint()..color = dataColor..style = PaintingStyle.stroke..strokeWidth = 2);
      }
    }

    // Tooltip
    if (selectedIndex != null && selectedIndex! < n) {
      final pt      = point(selectedIndex!);
      final weight  = weights[selectedIndex!];
      final dateStr = history[selectedIndex!]['log_date'] as String? ?? '';
      String shortDate = dateStr;
      try {
        final dt = DateTime.parse(dateStr);
        const mo = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
        shortDate = '${mo[dt.month - 1]} ${dt.day}';
      } catch (_) {}

      final label = '$shortDate · ${weight.toStringAsFixed(1)} kg';
      final tp = TextPainter(
        text: TextSpan(text: label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
        textDirection: TextDirection.ltr,
      )..layout();

      const padH = 8.0, padV = 5.0, radius = 6.0;
      final boxW = tp.width + padH * 2;
      final boxH = tp.height + padV * 2;

      // Position: above the dot, clamped to chart bounds
      double bx = pt.dx - boxW / 2;
      bx = bx.clamp(chartLeft, size.width - boxW);
      double by = pt.dy - boxH - 10;
      if (by < 0) by = pt.dy + 10;

      // Vertical crosshair
      canvas.drawLine(
        Offset(pt.dx, 0), Offset(pt.dx, size.height),
        Paint()..color = Colors.white.withValues(alpha: 0.15)..strokeWidth = 1,
      );

      // Bubble
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(bx, by, boxW, boxH), const Radius.circular(radius)),
        Paint()..color = const Color(0xFF1A3528),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(bx, by, boxW, boxH), const Radius.circular(radius)),
        Paint()..color = _kOrange..style = PaintingStyle.stroke..strokeWidth = 1.2,
      );
      tp.paint(canvas, Offset(bx + padH, by + padV));
    }
  }

  @override
  bool shouldRepaint(covariant _WeightChartPainter old) =>
      old.history != history || old.targetWeight != targetWeight || old.selectedIndex != selectedIndex;
}

class _SleepCard extends StatelessWidget {
  const _SleepCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: _kCard, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'This is your sleep breakdown',
            style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(color: _kBg, borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                const Text(
                  'Duration',
                  style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 14),
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF1E3060)),
                  child: const Icon(Icons.nightlight_round, color: Color(0xFF5B8DEF), size: 28),
                ),
                const SizedBox(height: 10),
                const Text('No data available', style: TextStyle(color: _kDim, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
