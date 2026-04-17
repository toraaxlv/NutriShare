import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/nutrition_provider.dart';
import 'custom_food_sheet.dart';

const _kBg    = Color(0xFF1A3528);
const _kCard  = Color(0xFF243D2F);
const _kGreen = Color(0xFFA8E040);
const _kDim   = Color(0xFF6B9080);
const _kLine  = Color(0xFF2B4A38);

class AddFoodSheet extends StatefulWidget {
  final String mealType;
  final DateTime date;
  final VoidCallback? onLogged;
  final dynamic preselectedFood;

  const AddFoodSheet({
    super.key,
    required this.mealType,
    required this.date,
    this.onLogged,
    this.preselectedFood,
  });

  static void show(
    BuildContext context, {
    required String mealType,
    required DateTime date,
    VoidCallback? onLogged,
    dynamic preselectedFood,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddFoodSheet(mealType: mealType, date: date, onLogged: onLogged, preselectedFood: preselectedFood),
    );
  }

  @override
  State<AddFoodSheet> createState() => _AddFoodSheetState();
}

const _unitToG = {'g': 1.0, 'tbsp': 15.0, 'tsp': 5.0, 'cup': 240.0};

class _AddFoodSheetState extends State<AddFoodSheet> {
  final _searchCtrl = TextEditingController();
  dynamic _selectedFood;
  final _qtyCtrl = TextEditingController(text: '100');
  String _unit = 'g';
  bool _isLogging = false;
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    if (widget.preselectedFood != null) {
      _selectedFood = widget.preselectedFood;
    }
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchCtrl.dispose();
    _qtyCtrl.dispose();
    super.dispose();
  }

  void _selectFood(dynamic food) {
    setState(() => _selectedFood = food);
    context.read<NutritionProvider>().clearSearch();
    _searchCtrl.clear();
  }

  void _clearSelection() => setState(() => _selectedFood = null);

  Future<void> _log() async {
    final qty = double.tryParse(_qtyCtrl.text);
    if (qty == null || qty <= 0) return;
    final quantityG = qty * (_unitToG[_unit] ?? 1.0);

    setState(() => _isLogging = true);
    final ok = await context.read<NutritionProvider>().addFoodLog(
      food: Map<String, dynamic>.from(_selectedFood),
      mealType: widget.mealType,
      quantityG: quantityG,
      date: widget.date,
    );
    setState(() => _isLogging = false);

    if (!mounted) return;
    if (ok) {
      widget.onLogged?.call();
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menambahkan makanan. Coba lagi.'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final nutrition = context.watch<NutritionProvider>();
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final mealLabel = _mealLabel(widget.mealType);

    return Container(
      decoration: const BoxDecoration(
        color: _kBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(width: 40, height: 4, decoration: BoxDecoration(color: _kLine, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          // Title
          Text(
            'Add to $mealLabel',
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          if (_selectedFood == null) ...[
            // Search bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
              decoration: BoxDecoration(
                color: _kCard,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: _kLine),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: _kDim, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      autofocus: true,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: const InputDecoration(
                        hintText: 'Cari makanan...',
                        hintStyle: TextStyle(color: _kDim),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                      onChanged: (v) {
                        _searchDebounce?.cancel();
                        _searchDebounce = Timer(const Duration(milliseconds: 400), () {
                          context.read<NutritionProvider>().searchFoods(v);
                        });
                      },
                    ),
                  ),
                  if (nutrition.isSearching)
                    const SizedBox(
                      width: 16, height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: _kGreen),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Custom food option
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.add_circle_outline, color: _kGreen),
              title: const Text('Buat Custom Food', style: TextStyle(color: _kGreen, fontSize: 13)),
              onTap: () async {
                final created = await CustomFoodSheet.show(context);
                if (created != null && mounted) _selectFood(created);
              },
            ),
            const Divider(color: _kLine),
            // Results
            if (nutrition.foodSearchResults.isNotEmpty)
              SizedBox(
                height: 220,
                child: ListView.builder(
                  itemCount: nutrition.foodSearchResults.length,
                  itemBuilder: (_, i) {
                    final f = nutrition.foodSearchResults[i];
                    return ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(f['name'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 13)),
                      subtitle: Text(
                        '${(f['calories_per_100g'] as num?)?.toInt() ?? 0} kcal / 100g',
                        style: const TextStyle(color: _kDim, fontSize: 11),
                      ),
                      onTap: () => _selectFood(f),
                    );
                  },
                ),
              )
            else if (_searchCtrl.text.length >= 2 && !nutrition.isSearching)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text('Tidak ditemukan', style: TextStyle(color: _kDim)),
              ),
          ] else ...[
            // Selected food + quantity
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: _kCard, borderRadius: BorderRadius.circular(14)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _selectedFood['name'] ?? '',
                          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                      GestureDetector(
                        onTap: _clearSelection,
                        child: const Icon(Icons.close, color: _kDim, size: 18),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text('${((_selectedFood['calories_per_100g'] as num?)?.toDouble() ?? 0).toInt()} kcal  ', style: const TextStyle(color: _kDim, fontSize: 11)),
                      _MacroChip('P', '${((_selectedFood['protein_per_100g'] as num?)?.toDouble() ?? 0).toInt()}g', const Color(0xFF5B8DEF)),
                      const SizedBox(width: 4),
                      _MacroChip('C', '${((_selectedFood['carbs_per_100g'] as num?)?.toDouble() ?? 0).toInt()}g', const Color(0xFFE0A840)),
                      const SizedBox(width: 4),
                      _MacroChip('F', '${((_selectedFood['fat_per_100g'] as num?)?.toDouble() ?? 0).toInt()}g', const Color(0xFFE05B5B)),
                      const Text('  /100g', style: TextStyle(color: _kDim, fontSize: 11)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      SizedBox(
                        width: 80,
                        child: TextField(
                          controller: _qtyCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            filled: true,
                            fillColor: _kBg,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: _kLine),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: _kLine),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _unitToG.keys.map((u) => Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: GestureDetector(
                                onTap: () => setState(() {
                                  _unit = u;
                                  if (u == 'g') _qtyCtrl.text = '100';
                                  else _qtyCtrl.text = '1';
                                }),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _unit == u ? _kGreen : _kBg,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: _unit == u ? _kGreen : _kLine),
                                  ),
                                  child: Text(
                                    u,
                                    style: TextStyle(
                                      color: _unit == u ? _kBg : Colors.white70,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            )).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Preview kalori & makro — update real-time saat mengetik
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _qtyCtrl,
                    builder: (_, value, __) {
                      final qty = double.tryParse(value.text.replaceAll(',', '.')) ?? 0;
                      final qtyG = qty * (_unitToG[_unit] ?? 1.0);
                      final cal  = ((_selectedFood['calories_per_100g'] as num?)?.toDouble() ?? 0) * qtyG / 100;
                      final pro  = ((_selectedFood['protein_per_100g']  as num?)?.toDouble() ?? 0) * qtyG / 100;
                      final carb = ((_selectedFood['carbs_per_100g']    as num?)?.toDouble() ?? 0) * qtyG / 100;
                      final fat  = ((_selectedFood['fat_per_100g']      as num?)?.toDouble() ?? 0) * qtyG / 100;
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: _kLine,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${cal.toInt()}', style: const TextStyle(color: _kGreen, fontSize: 20, fontWeight: FontWeight.bold)),
                                const Text('kcal', style: TextStyle(color: _kDim, fontSize: 10)),
                              ],
                            ),
                            Container(width: 1, height: 32, color: _kDim.withValues(alpha: 0.3)),
                            _MacroStat('Protein', pro, const Color(0xFF5B8DEF)),
                            _MacroStat('Carbs', carb, const Color(0xFFE0A840)),
                            _MacroStat('Fat', fat, const Color(0xFFE05B5B)),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLogging ? null : _log,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kGreen,
                  foregroundColor: _kBg,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: _isLogging
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Log Makanan', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  static String _mealLabel(String type) {
    const labels = {
      'breakfast': 'Breakfast',
      'lunch': 'Lunch',
      'dinner': 'Dinner',
      'snack': 'Snack',
      'uncategorized': 'Uncategorized',
    };
    return labels[type] ?? type;
  }
}

class _MacroStat extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _MacroStat(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '${value.toStringAsFixed(1)}g',
          style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: _kDim, fontSize: 10)),
      ],
    );
  }
}

class _MacroChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MacroChip(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
          const SizedBox(width: 2),
          Text(value, style: TextStyle(color: color, fontSize: 10)),
        ],
      ),
    );
  }
}
