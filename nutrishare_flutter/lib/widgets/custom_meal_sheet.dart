import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/nutrition_provider.dart';

const _kBg    = Color(0xFF1A3528);
const _kCard  = Color(0xFF243D2F);
const _kGreen = Color(0xFFA8E040);
const _kDim   = Color(0xFF6B9080);
const _kLine  = Color(0xFF2B4A38);
const _unitToG = {'g': 1.0, 'tbsp': 15.0, 'tsp': 5.0, 'cup': 240.0};

class CustomMealSheet extends StatefulWidget {
  const CustomMealSheet({super.key});

  static Future<bool?> show(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CustomMealSheet(),
    );
  }

  @override
  State<CustomMealSheet> createState() => _CustomMealSheetState();
}

class _CustomMealSheetState extends State<CustomMealSheet> {
  final _searchCtrl = TextEditingController();
  Timer? _debounce;
  String _mealType = 'breakfast';
  final List<Map<String, dynamic>> _selected = [];
  bool _isLogging = false;

  static const _mealTypes = ['breakfast', 'lunch', 'dinner', 'snack'];

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged(String q) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      context.read<NutritionProvider>().searchFoods(q);
    });
  }

  void _addFood(dynamic food) {
    final id   = food['id']?.toString();
    final name = food['name']?.toString() ?? '';
    final isDupe = id != null
        ? _selected.any((f) => f['id']?.toString() == id)
        : _selected.any((f) => f['name']?.toString() == name);
    if (isDupe) return;
    setState(() {
      _selected.add({...Map<String, dynamic>.from(food as Map), 'quantity_g': 100.0});
    });
  }

  void _removeFood(int idx) => setState(() => _selected.removeAt(idx));

  void _updateQty(int idx, double qty) {
    setState(() => _selected[idx]['quantity_g'] = qty);
  }

  Future<void> _logAll() async {
    if (_selected.isEmpty) return;
    setState(() => _isLogging = true);

    final provider = context.read<NutritionProvider>();
    int ok = 0;
    for (final f in _selected) {
      final success = await provider.addFoodLog(
        food: Map<String, dynamic>.from(f),
        mealType: _mealType,
        quantityG: (f['quantity_g'] as num).toDouble(),
        date: DateTime.now(),
      );
      if (success) ok++;
    }

    setState(() => _isLogging = false);
    if (mounted) {
      if (ok > 0) {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal log makanan. Coba lagi.'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final nutrition  = context.watch<NutritionProvider>();
    final results    = nutrition.foodSearchResults;
    final searching  = nutrition.isSearching;
    final query      = _searchCtrl.text;
    final bottomPad  = MediaQuery.of(context).viewInsets.bottom;

    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.5,
      maxChildSize: 0.96,
      builder: (_, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: _kBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(bottom: bottomPad),
        child: Column(
          children: [
            // Handle + header
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: _kLine, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Custom Meal', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      Text('Pilih beberapa makanan sekaligus', style: TextStyle(color: _kDim, fontSize: 12)),
                    ],
                  ),
                  if (_selected.isNotEmpty)
                    ElevatedButton(
                      onPressed: _isLogging ? null : _logAll,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _kGreen,
                        foregroundColor: _kBg,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: _isLogging
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                          : Text('Log (${_selected.length})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Meal type chips
            SizedBox(
              height: 34,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: _mealTypes.map((m) {
                  final active = m == _mealType;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _mealType = m),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: active ? _kGreen.withValues(alpha: 0.18) : _kCard,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: active ? _kGreen : _kLine),
                        ),
                        child: Text(
                          m[0].toUpperCase() + m.substring(1),
                          style: TextStyle(color: active ? _kGreen : _kDim, fontSize: 12, fontWeight: active ? FontWeight.bold : FontWeight.normal),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
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
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: const InputDecoration(
                          hintText: 'Cari makanan untuk ditambahkan...',
                          hintStyle: TextStyle(color: _kDim, fontSize: 13),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                        onChanged: (v) {
                          setState(() {});
                          _onSearchChanged(v);
                        },
                      ),
                    ),
                    if (searching)
                      const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: _kGreen)),
                    if (!searching && _searchCtrl.text.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          _searchCtrl.clear();
                          setState(() {});
                          context.read<NutritionProvider>().clearSearch();
                        },
                        child: const Icon(Icons.close, color: _kDim, size: 16),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4),
            const Divider(color: _kLine),

            // Content list
            Expanded(
              child: ListView(
                controller: scrollCtrl,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                children: [
                  // Selected foods
                  if (_selected.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.only(top: 4, bottom: 8),
                      child: Text('Dipilih', style: TextStyle(color: _kDim, fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                    ..._selected.asMap().entries.map((e) => _SelectedTile(
                      food: e.value,
                      onRemove: () => _removeFood(e.key),
                      onQtyChanged: (q) => _updateQty(e.key, q),
                    )),
                    const Divider(color: _kLine, height: 24),
                  ],

                  // Search results
                  if (query.length >= 2) ...[
                    if (results.isEmpty && !searching)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(child: Text('Makanan tidak ditemukan', style: TextStyle(color: _kDim))),
                      )
                    else
                      ...results.map((f) => _ResultTile(food: f, onAdd: () => _addFood(f))),
                  ] else if (_selected.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.restaurant_menu, color: _kDim, size: 40),
                            SizedBox(height: 12),
                            Text('Cari dan tambahkan makanan\nke meal ini', textAlign: TextAlign.center, style: TextStyle(color: _kDim, fontSize: 13)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectedTile extends StatefulWidget {
  final Map<String, dynamic> food;
  final VoidCallback onRemove;
  final ValueChanged<double> onQtyChanged;

  const _SelectedTile({required this.food, required this.onRemove, required this.onQtyChanged});

  @override
  State<_SelectedTile> createState() => _SelectedTileState();
}

class _SelectedTileState extends State<_SelectedTile> {
  late final TextEditingController _ctrl;
  String _unit = 'g';

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: (widget.food['quantity_g'] as num).toInt().toString());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _notifyQty(String v) {
    final parsed = double.tryParse(v);
    if (parsed != null && parsed > 0) {
      widget.onQtyChanged(parsed * (_unitToG[_unit] ?? 1.0));
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.food['name'] as String? ?? '-';
    final cal  = (widget.food['calories_per_100g'] as num?)?.toDouble() ?? 0;
    final qty  = (widget.food['quantity_g'] as num).toDouble();
    final totalCal = (cal * qty / 100).round();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kGreen.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle, color: _kGreen, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                    Text('$totalCal kcal total', style: const TextStyle(color: _kDim, fontSize: 11)),
                  ],
                ),
              ),
              SizedBox(
                width: 64,
                child: TextField(
                  controller: _ctrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    isDense: true,
                    suffixText: _unit,
                    suffixStyle: const TextStyle(color: _kDim, fontSize: 10),
                    filled: true,
                    fillColor: _kBg,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: _kLine)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: _kLine)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: _kGreen)),
                  ),
                  onChanged: _notifyQty,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: widget.onRemove,
                child: const Icon(Icons.remove_circle_outline, color: Color(0xFFE05B5B), size: 20),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: _unitToG.keys.map((u) => Padding(
              padding: const EdgeInsets.only(right: 6),
              child: GestureDetector(
                onTap: () => setState(() {
                  _unit = u;
                  _ctrl.text = u == 'g' ? '100' : '1';
                  _notifyQty(_ctrl.text);
                }),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _unit == u ? _kGreen : _kBg,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: _unit == u ? _kGreen : _kLine),
                  ),
                  child: Text(u, style: TextStyle(color: _unit == u ? _kBg : Colors.white60, fontSize: 10, fontWeight: FontWeight.w600)),
                ),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }
}

class _ResultTile extends StatelessWidget {
  final dynamic food;
  final VoidCallback onAdd;

  const _ResultTile({required this.food, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final name = food['name'] as String? ?? '-';
    final cal  = (food['calories_per_100g'] as num?)?.toInt() ?? 0;
    final pro  = (food['protein_per_100g']  as num?)?.toInt() ?? 0;
    final carb = (food['carbs_per_100g']    as num?)?.toInt() ?? 0;
    final fat  = (food['fat_per_100g']      as num?)?.toInt() ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(color: _kCard, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          const Icon(Icons.restaurant, color: _kDim, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text('$cal kcal  ', style: const TextStyle(color: _kDim, fontSize: 11)),
                    _Chip('P', '${pro}g', const Color(0xFF5B8DEF)),
                    const SizedBox(width: 4),
                    _Chip('C', '${carb}g', const Color(0xFFE0A840)),
                    const SizedBox(width: 4),
                    _Chip('F', '${fat}g', const Color(0xFFE05B5B)),
                    const Text('  /100g', style: TextStyle(color: _kDim, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onAdd,
            child: const Icon(Icons.add_circle_outline, color: _kGreen, size: 22),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label, value;
  final Color color;
  const _Chip(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(5)),
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
