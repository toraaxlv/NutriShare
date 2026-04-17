import 'dart:math' as math;
import 'package:flutter/material.dart';

const _kBg     = Color(0xFF1A3528);
const _kCard   = Color(0xFF243D2F);
const _kGreen  = Color(0xFFA8E040);
const _kOrange = Color(0xFFF09038);
const _kDim    = Color(0xFF6B9080);
const _kLine   = Color(0xFF2B4A38);

// Per-meal colours
const _mealColors = {
  'breakfast':    Color(0xFFF09038),
  'lunch':        Color(0xFFA8E040),
  'dinner':       Color(0xFF5B8DEF),
  'snack':        Color(0xFFD94F4F),
  'uncategorized':Color(0xFF6B9080),
};

const _mealLabels = {
  'breakfast':    'Breakfast',
  'lunch':        'Lunch',
  'dinner':       'Dinner',
  'snack':        'Snack',
  'uncategorized':'Uncategorized',
};

// Maps macro label → food log field key
const _nutrientKey = {
  'Energy':         'calories',
  'Protein':        'protein_g',
  'Carbohydrates':  'carbs_g',
  'Fat':            'fat_g',
};

class MacroNutrientCard extends StatelessWidget {
  final double calActual;
  final double calTarget;
  final double proActual;
  final double proTarget;
  final double fatActual;
  final double fatTarget;
  final double carbActual;
  final double carbTarget;
  final List<dynamic> logs;

  const MacroNutrientCard({
    super.key,
    required this.calActual,
    required this.calTarget,
    required this.proActual,
    required this.proTarget,
    required this.fatActual,
    required this.fatTarget,
    required this.carbActual,
    required this.carbTarget,
    this.logs = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: _kCard, borderRadius: BorderRadius.circular(16)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MacroRow(label: 'Energy',    actual: calActual,  target: calTarget,  unit: 'kcal', color: _kOrange,              logs: logs),
          const SizedBox(height: 8),
          _MacroRow(label: 'Protein',   actual: proActual,  target: proTarget,  unit: 'g',    color: const Color(0xFF5B8DEF),logs: logs),
          const SizedBox(height: 8),
          _MacroRow(label: 'Carbohydrates', actual: carbActual, target: carbTarget, unit: 'g',    color: _kGreen,               logs: logs),
          const SizedBox(height: 8),
          _MacroRow(label: 'Fat',       actual: fatActual,  target: fatTarget,  unit: 'g',    color: const Color(0xFFD94F4F),logs: logs),
        ],
      ),
    );
  }
}

class _MacroRow extends StatelessWidget {
  final String label;
  final double actual;
  final double target;
  final String unit;
  final Color color;
  final List<dynamic> logs;

  const _MacroRow({
    required this.label,
    required this.actual,
    required this.target,
    required this.unit,
    required this.color,
    required this.logs,
  });

  @override
  Widget build(BuildContext context) {
    final progress  = target > 0 ? (actual / target).clamp(0.0, 1.0) : 0.0;
    final pct       = target > 0 ? ((actual / target) * 100).round() : 0;
    final actualStr = unit == 'kcal' ? actual.toInt().toString() : actual.toStringAsFixed(1);
    final targetStr = unit == 'kcal' ? target.toInt().toString() : target.toStringAsFixed(1);
    final valueText = target > 0 ? '$actualStr / $targetStr $unit' : '$actualStr $unit';

    return GestureDetector(
      onTap: () => _MacroBreakdownSheet.show(
        context,
        label: label,
        actual: actual,
        target: target,
        unit: unit,
        color: color,
        logs: logs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: label,
                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold, decoration: TextDecoration.underline, decorationColor: Colors.white54),
                      ),
                      TextSpan(
                        text: '- $valueText',
                        style: const TextStyle(color: _kDim, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text('$pct%', style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: _kLine,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Breakdown bottom sheet ────────────────────────────────────────────────────

class _MacroBreakdownSheet extends StatelessWidget {
  final String label;
  final double actual;
  final double target;
  final String unit;
  final Color color;
  final List<dynamic> logs;

  const _MacroBreakdownSheet({
    required this.label,
    required this.actual,
    required this.target,
    required this.unit,
    required this.color,
    required this.logs,
  });

  static void show(
    BuildContext context, {
    required String label,
    required double actual,
    required double target,
    required String unit,
    required Color color,
    required List<dynamic> logs,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _MacroBreakdownSheet(
        label: label, actual: actual, target: target,
        unit: unit, color: color, logs: logs,
      ),
    );
  }

  Map<String, double> _perMeal() {
    final field = _nutrientKey[label] ?? 'calories';
    final Map<String, double> totals = {};
    for (final log in logs) {
      final meal = (log['meal_type'] as String?) ?? 'uncategorized';
      final val  = (log[field] as num?)?.toDouble() ?? 0;
      totals[meal] = (totals[meal] ?? 0) + val;
    }
    return totals;
  }

  @override
  Widget build(BuildContext context) {
    final meals    = _perMeal();
    final total    = meals.values.fold(0.0, (a, b) => a + b);
    final pct      = target > 0 ? ((actual / target) * 100).round() : 0;
    final actualStr= unit == 'kcal' ? actual.toInt().toString() : actual.toStringAsFixed(1);
    final targetStr= unit == 'kcal' ? target.toInt().toString() : target.toStringAsFixed(1);

    // Sort by value descending
    final sorted = meals.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      decoration: const BoxDecoration(
        color: _kBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(color: _kLine, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 16),

          // Title + summary
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$label Breakdown',
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text('$pct%', style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$actualStr $unit consumed', style: const TextStyle(color: _kDim, fontSize: 12)),
              Text('Goal: $targetStr $unit', style: const TextStyle(color: _kDim, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 20),

          if (meals.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text('Belum ada log hari ini', style: TextStyle(color: _kDim, fontSize: 13)),
            )
          else ...[
            // Pie chart
            SizedBox(
              height: 160,
              child: Row(
                children: [
                  SizedBox(
                    width: 160,
                    height: 160,
                    child: CustomPaint(
                      painter: _PieChartPainter(meals: meals, total: total),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: sorted.map((e) {
                        final mealPct = total > 0 ? ((e.value / total) * 100).round() : 0;
                        final valStr  = unit == 'kcal' ? e.value.toInt().toString() : e.value.toStringAsFixed(1);
                        final mealColor = _mealColors[e.key] ?? _kDim;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Container(width: 10, height: 10, decoration: BoxDecoration(color: mealColor, shape: BoxShape.circle)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _mealLabels[e.key] ?? e.key,
                                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                '$mealPct% ($valStr$unit)',
                                style: TextStyle(color: mealColor, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: target > 0 ? (actual / target).clamp(0.0, 1.0) : 0.0,
                minHeight: 8,
                backgroundColor: _kLine,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('0 $unit', style: const TextStyle(color: _kDim, fontSize: 10)),
                Text('$targetStr $unit', style: const TextStyle(color: _kDim, fontSize: 10)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _PieChartPainter extends CustomPainter {
  final Map<String, double> meals;
  final double total;

  const _PieChartPainter({required this.meals, required this.total});

  @override
  void paint(Canvas canvas, Size size) {
    if (total <= 0) return;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 8;

    double startAngle = -math.pi / 2;
    for (final e in meals.entries) {
      final sweep = 2 * math.pi * (e.value / total);
      final color = _mealColors[e.key] ?? _kDim;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle, sweep, true,
        Paint()..color = color..style = PaintingStyle.fill,
      );
      // Small gap between segments
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle, sweep, true,
        Paint()..color = _kBg..style = PaintingStyle.stroke..strokeWidth = 2,
      );
      startAngle += sweep;
    }

    // Donut hole
    canvas.drawCircle(center, radius * 0.52, Paint()..color = _kBg);
  }

  @override
  bool shouldRepaint(covariant _PieChartPainter old) => old.meals != meals;
}
