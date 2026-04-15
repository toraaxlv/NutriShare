import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/nutrition_provider.dart';

const _kBg    = Color(0xFF1A3528);
const _kCard  = Color(0xFF243D2F);
const _kGreen = Color(0xFFA8E040);
const _kDim   = Color(0xFF6B9080);
const _kLine  = Color(0xFF2B4A38);

class CustomRecipeSheet extends StatefulWidget {
  const CustomRecipeSheet({super.key});

  static Future<Map<String, dynamic>?> show(BuildContext context) {
    return showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CustomRecipeSheet(),
    );
  }

  @override
  State<CustomRecipeSheet> createState() => _CustomRecipeSheetState();
}

class _CustomRecipeSheetState extends State<CustomRecipeSheet> {
  final _nameCtrl   = TextEditingController();
  final _searchCtrl = TextEditingController();
  Timer? _debounce;
  final List<Map<String, dynamic>> _ingredients = [];
  bool _isSaving = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _nameCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged(String q) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      context.read<NutritionProvider>().searchFoods(q);
    });
  }

  void _addIngredient(dynamic food) {
    final id = food['id']?.toString();
    if (id == null) return;
    if (_ingredients.any((f) => f['id']?.toString() == id)) return;
    setState(() {
      _ingredients.add({...Map<String, dynamic>.from(food as Map), 'quantity_g': 100.0});
    });
  }

  void _removeIngredient(int idx) => setState(() => _ingredients.removeAt(idx));

  void _updateQty(int idx, double qty) => setState(() => _ingredients[idx]['quantity_g'] = qty);

  // Hitung makro per 100g resep berdasarkan total bahan
  Map<String, double> get _calculatedMacros {
    if (_ingredients.isEmpty) return {'cal': 0, 'pro': 0, 'carb': 0, 'fat': 0, 'total_g': 0};

    double totalG = 0, totalCal = 0, totalPro = 0, totalCarb = 0, totalFat = 0;
    for (final ing in _ingredients) {
      final qty  = (ing['quantity_g'] as num).toDouble();
      final cal  = ((ing['calories_per_100g'] as num?)?.toDouble() ?? 0);
      final pro  = ((ing['protein_per_100g']  as num?)?.toDouble() ?? 0);
      final carb = ((ing['carbs_per_100g']    as num?)?.toDouble() ?? 0);
      final fat  = ((ing['fat_per_100g']      as num?)?.toDouble() ?? 0);
      totalG    += qty;
      totalCal  += cal  * qty / 100;
      totalPro  += pro  * qty / 100;
      totalCarb += carb * qty / 100;
      totalFat  += fat  * qty / 100;
    }

    if (totalG == 0) return {'cal': 0, 'pro': 0, 'carb': 0, 'fat': 0, 'total_g': 0};

    return {
      'cal':     totalCal  / totalG * 100,
      'pro':     totalPro  / totalG * 100,
      'carb':    totalCarb / totalG * 100,
      'fat':     totalFat  / totalG * 100,
      'total_g': totalG,
    };
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan nama resep'), backgroundColor: Colors.orange),
      );
      return;
    }
    if (_ingredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tambahkan minimal 1 bahan'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isSaving = true);
    final macros = _calculatedMacros;
    final food = await context.read<NutritionProvider>().createFood(
      name: name,
      caloriesPer100g: macros['cal']!,
      proteinPer100g:  macros['pro']!,
      carbsPer100g:    macros['carb']!,
      fatPer100g:      macros['fat']!,
    );
    setState(() => _isSaving = false);

    if (mounted) Navigator.pop(context, food);
  }

  @override
  Widget build(BuildContext context) {
    final nutrition = context.watch<NutritionProvider>();
    final results   = nutrition.foodSearchResults;
    final searching = nutrition.isSearching;
    final query     = _searchCtrl.text;
    final macros    = _calculatedMacros;
    final bottomPad = MediaQuery.of(context).viewInsets.bottom;

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
                      Text('Custom Recipe', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      Text('Simpan sebagai 1 custom food', style: TextStyle(color: _kDim, fontSize: 12)),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: _isSaving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kGreen,
                      foregroundColor: _kBg,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: _isSaving
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Simpan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Recipe name input
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextFormField(
                controller: _nameCtrl,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Nama resep (contoh: Nasi Goreng Spesial)',
                  hintStyle: const TextStyle(color: _kDim, fontSize: 13),
                  filled: true,
                  fillColor: _kCard,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _kLine)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _kLine)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _kGreen)),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Macro preview (muncul kalau ada bahan)
            if (_ingredients.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: _kGreen.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _kGreen.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${macros['cal']!.toInt()} kcal', style: const TextStyle(color: _kGreen, fontSize: 16, fontWeight: FontWeight.bold)),
                          Text('${macros['total_g']!.toInt()}g total', style: const TextStyle(color: _kDim, fontSize: 10)),
                        ],
                      ),
                      _MacroStat('Protein', macros['pro']!, const Color(0xFF5B8DEF)),
                      _MacroStat('Karbo', macros['carb']!, const Color(0xFFE0A840)),
                      _MacroStat('Lemak', macros['fat']!, const Color(0xFFE05B5B)),
                      const Text('/100g', style: TextStyle(color: _kDim, fontSize: 10)),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 10),

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
                          hintText: 'Cari bahan...',
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
                  // Added ingredients
                  if (_ingredients.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.only(top: 4, bottom: 8),
                      child: Text('Bahan', style: TextStyle(color: _kDim, fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                    ..._ingredients.asMap().entries.map((e) => _IngredientTile(
                      ingredient: e.value,
                      onRemove: () => _removeIngredient(e.key),
                      onQtyChanged: (q) => _updateQty(e.key, q),
                    )),
                    const Divider(color: _kLine, height: 24),
                  ],

                  // Search results
                  if (query.length >= 2) ...[
                    if (results.isEmpty && !searching)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(child: Text('Bahan tidak ditemukan', style: TextStyle(color: _kDim))),
                      )
                    else
                      ...results.map((f) => _IngredientResultTile(food: f, onAdd: () => _addIngredient(f))),
                  ] else if (_ingredients.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Column(
                          children: [
                            Text('🍳', style: TextStyle(fontSize: 40)),
                            SizedBox(height: 12),
                            Text('Cari dan tambahkan bahan-bahan\nuntuk resepmu', textAlign: TextAlign.center, style: TextStyle(color: _kDim, fontSize: 13)),
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

class _IngredientTile extends StatefulWidget {
  final Map<String, dynamic> ingredient;
  final VoidCallback onRemove;
  final ValueChanged<double> onQtyChanged;

  const _IngredientTile({required this.ingredient, required this.onRemove, required this.onQtyChanged});

  @override
  State<_IngredientTile> createState() => _IngredientTileState();
}

class _IngredientTileState extends State<_IngredientTile> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: (widget.ingredient['quantity_g'] as num).toInt().toString());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.ingredient['name'] as String? ?? '-';
    final cal  = (widget.ingredient['calories_per_100g'] as num?)?.toDouble() ?? 0;
    final qty  = (widget.ingredient['quantity_g'] as num).toDouble();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kLine),
      ),
      child: Row(
        children: [
          const Icon(Icons.egg_alt_outlined, color: _kDim, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                Text('${(cal * qty / 100).round()} kcal', style: const TextStyle(color: _kDim, fontSize: 11)),
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
                suffixText: 'g',
                suffixStyle: const TextStyle(color: _kDim, fontSize: 10),
                filled: true,
                fillColor: _kBg,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: _kLine)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: _kLine)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: _kGreen)),
              ),
              onChanged: (v) {
                final parsed = double.tryParse(v);
                if (parsed != null && parsed > 0) widget.onQtyChanged(parsed);
              },
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: widget.onRemove,
            child: const Icon(Icons.remove_circle_outline, color: Color(0xFFE05B5B), size: 20),
          ),
        ],
      ),
    );
  }
}

class _IngredientResultTile extends StatelessWidget {
  final dynamic food;
  final VoidCallback onAdd;

  const _IngredientResultTile({required this.food, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final name = food['name'] as String? ?? '-';
    final cal  = (food['calories_per_100g'] as num?)?.toInt() ?? 0;

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
                Text('$cal kcal/100g', style: const TextStyle(color: _kDim, fontSize: 11)),
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

class _MacroStat extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _MacroStat(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('${value.toStringAsFixed(1)}g', style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: _kDim, fontSize: 10)),
      ],
    );
  }
}
