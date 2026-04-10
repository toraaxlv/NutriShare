import 'package:flutter/material.dart';
import '../widgets/add_food_sheet.dart';

const _kBg    = Color(0xFF1A3528);
const _kCard  = Color(0xFF243D2F);
const _kGreen = Color(0xFFA8E040);
const _kDim   = Color(0xFF6B9080);
const _kLine  = Color(0xFF2B4A38);

class QuickAddSheet {
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _MealPickerSheet(date: DateTime.now()),
    );
  }
}

class _MealPickerSheet extends StatelessWidget {
  final DateTime date;

  const _MealPickerSheet({required this.date});

  static const _meals = [
    ('breakfast',    'Breakfast',    Icons.wb_sunny_outlined),
    ('lunch',        'Lunch',        Icons.lunch_dining_outlined),
    ('dinner',       'Dinner',       Icons.dinner_dining_outlined),
    ('snack',        'Snack',        Icons.cookie_outlined),
    ('uncategorized','Uncategorized',Icons.add_circle_outline),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: _kBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(color: _kLine, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 16),
          const Text(
            'Add to meal',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          for (final (mealType, label, icon) in _meals) ...[
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                Navigator.pop(context);
                AddFoodSheet.show(context, mealType: mealType, date: date);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(color: _kCard, borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    Icon(icon, color: _kGreen, size: 22),
                    const SizedBox(width: 14),
                    Text(label, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
                    const Spacer(),
                    const Icon(Icons.chevron_right, color: _kDim, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}
