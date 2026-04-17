import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/nutrition_provider.dart';
import '../widgets/custom_food_sheet.dart';
import '../widgets/add_food_sheet.dart';
import '../widgets/custom_meal_sheet.dart';
import '../widgets/custom_recipe_sheet.dart';

const _kBg    = Color(0xFF1A3528);
const _kCard  = Color(0xFF243D2F);
const _kGreen = Color(0xFFA8E040);
const _kDim   = Color(0xFF6B9080);
const _kLine  = Color(0xFF2B4A38);

Future<void> _showMealPicker(BuildContext context, dynamic food) async {
  const meals = [
    ('breakfast', 'Breakfast', Icons.wb_sunny_outlined),
    ('lunch',     'Lunch',     Icons.lunch_dining_outlined),
    ('dinner',    'Dinner',    Icons.dinner_dining_outlined),
    ('snack',     'Snack',     Icons.cookie_outlined),
  ];
  await showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) => Container(
      decoration: const BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: _kLine, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),
          const Text('Tambah ke', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...meals.map((m) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(m.$3, color: _kGreen, size: 20),
            title: Text(m.$2, style: const TextStyle(color: Colors.white, fontSize: 14)),
            onTap: () {
              Navigator.pop(ctx);
              AddFoodSheet.show(context, mealType: m.$1, date: DateTime.now(), preselectedFood: food);
            },
          )),
        ],
      ),
    ),
  );
}

class FoodsScreen extends StatefulWidget {
  const FoodsScreen({super.key});

  @override
  State<FoodsScreen> createState() => _FoodsScreenState();
}

class _FoodsScreenState extends State<FoodsScreen> {
  bool _searchMode = false;
  final _searchCtrl = TextEditingController();
  Timer? _searchDebounce;

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _searchMode = !_searchMode;
      if (!_searchMode) {
        _searchDebounce?.cancel();
        _searchCtrl.clear();
        context.read<NutritionProvider>().clearSearch();
      }
    });
  }

  void _onSearchChanged(String query) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      context.read<NutritionProvider>().searchFoods(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final nutrition = context.watch<NutritionProvider>();

    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Foods',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Add new meals',
                            style: TextStyle(color: _kDim, fontSize: 14),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: Icon(
                          _searchMode ? Icons.close : Icons.search,
                          color: _kGreen,
                          size: 26,
                        ),
                        onPressed: _toggleSearch,
                        padding: const EdgeInsets.only(top: 4),
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  if (_searchMode) ...[
                    const SizedBox(height: 12),
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
                                hintStyle: TextStyle(color: _kDim, fontSize: 14),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                              onChanged: _onSearchChanged,
                            ),
                          ),
                          if (nutrition.isSearching)
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: _kGreen),
                            ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                ],
              ),
            ),
            Expanded(
              child: _searchMode
                  ? _SearchResults(results: nutrition.foodSearchResults, isSearching: nutrition.isSearching, query: _searchCtrl.text)
                  : _QuickActions(),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Search results ────────────────────────────────────────────────────────────

class _SearchResults extends StatelessWidget {
  final List<dynamic> results;
  final bool isSearching;
  final String query;

  const _SearchResults({
    required this.results,
    required this.isSearching,
    required this.query,
  });

  @override
  Widget build(BuildContext context) {
    if (query.trim().length < 2) {
      return const Center(
        child: Text(
          'Ketik minimal 2 karakter untuk mencari',
          style: TextStyle(color: _kDim, fontSize: 14),
        ),
      );
    }
    if (!isSearching && results.isEmpty) {
      return const Center(
        child: Text(
          'Makanan tidak ditemukan',
          style: TextStyle(color: _kDim, fontSize: 14),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: results.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) => _FoodResultCard(food: results[i]),
    );
  }
}

class _FoodResultCard extends StatelessWidget {
  final dynamic food;
  const _FoodResultCard({required this.food});

  void _onTap(BuildContext context) {
    _showMealPicker(context, food);
  }

  @override
  Widget build(BuildContext context) {
    final name     = food['name'] as String? ?? '-';
    final calories = (food['calories_per_100g'] as num?)?.toDouble() ?? 0;
    final protein  = (food['protein_per_100g'] as num?)?.toDouble() ?? 0;
    final carbs    = (food['carbs_per_100g'] as num?)?.toDouble() ?? 0;
    final fat      = (food['fat_per_100g'] as num?)?.toDouble() ?? 0;
    final source   = food['source'] as String? ?? '';
    final isCustom = source == 'custom';

    return GestureDetector(
      onTap: () => _onTap(context),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: _kCard, borderRadius: BorderRadius.circular(14)),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: isCustom ? _kGreen : _kDim, width: 1.5),
              ),
              child: Icon(Icons.restaurant, color: isCustom ? _kGreen : _kDim, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text('${calories.toInt()} kcal  ', style: const TextStyle(color: _kDim, fontSize: 11)),
                      _MacroChip('P', '${protein.toInt()}g', const Color(0xFF5B8DEF)),
                      const SizedBox(width: 4),
                      _MacroChip('C', '${carbs.toInt()}g', const Color(0xFFE0A840)),
                      const SizedBox(width: 4),
                      _MacroChip('F', '${fat.toInt()}g', const Color(0xFFE05B5B)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (source.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: isCustom ? _kGreen.withValues(alpha: 0.15) : _kLine,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  source,
                  style: TextStyle(color: isCustom ? _kGreen : _kDim, fontSize: 9, letterSpacing: 0.3),
                ),
              ),
            const SizedBox(width: 6),
            const Icon(Icons.add_circle_outline, color: _kGreen, size: 20),
          ],
        ),
      ),
    );
  }
}

// ── Quick action cards ────────────────────────────────────────────────────────

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _FoodCard(
            icon: Icons.set_meal,
            title: 'Custom Meal',
            subtitle: 'Combine multiple foods into one meal for quick logging',
            buttonLabel: 'CUSTOM MEAL',
            onTap: () => CustomMealSheet.show(context),
          ),
          const SizedBox(height: 12),
          _FoodCard(
            icon: Icons.menu_book_outlined,
            title: 'Custom Recipe',
            subtitle: 'Build a recipe from ingredients and save its nutrition',
            buttonLabel: 'CUSTOM RECIPE',
            onTap: () => CustomRecipeSheet.show(context),
          ),
          const SizedBox(height: 12),
          _FoodCard(
            icon: Icons.bookmarks_outlined,
            title: 'Custom Foods',
            subtitle: 'Browse and log your saved custom food items',
            buttonLabel: 'CUSTOM FOOD',
            onTap: () => _CustomFoodListSheet.show(context),
          ),
        ],
      ),
    );
  }
}

// ── Custom food list sheet ────────────────────────────────────────────────────

class _CustomFoodListSheet extends StatefulWidget {
  final BuildContext screenContext;
  const _CustomFoodListSheet({required this.screenContext});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CustomFoodListSheet(screenContext: context),
    );
  }

  @override
  State<_CustomFoodListSheet> createState() => _CustomFoodListSheetState();
}

class _CustomFoodListSheetState extends State<_CustomFoodListSheet> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NutritionProvider>().loadCustomFoods();
    });
  }

  @override
  Widget build(BuildContext context) {
    final nutrition = context.watch<NutritionProvider>();
    final foods = nutrition.customFoods;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (_, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: _kBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: _kLine, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Custom Foods', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  TextButton.icon(
                    onPressed: () async {
                      final created = await CustomFoodSheet.show(context);
                      if (created != null && mounted) {
                        // Already refreshed in provider; list updates reactively
                      }
                    },
                    icon: const Icon(Icons.add, color: _kGreen, size: 18),
                    label: const Text('Baru', style: TextStyle(color: _kGreen, fontSize: 13)),
                  ),
                ],
              ),
            ),
            const Divider(color: _kLine),
            Expanded(
              child: foods.isEmpty
                  ? const Center(
                      child: Text(
                        'Belum ada custom food.\nTap "+ Baru" untuk membuat.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: _kDim, fontSize: 13),
                      ),
                    )
                  : ListView.separated(
                      controller: scrollCtrl,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      itemCount: foods.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (ctx, i) {
                        final f = foods[i];
                        return _CustomFoodTile(food: f, screenContext: widget.screenContext);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomFoodTile extends StatelessWidget {
  final dynamic food;
  final BuildContext screenContext;
  const _CustomFoodTile({required this.food, required this.screenContext});

  @override
  Widget build(BuildContext context) {
    final name = food['name'] as String? ?? '-';
    final cal  = (food['calories_per_100g'] as num?)?.toInt() ?? 0;
    final pro  = (food['protein_per_100g']  as num?)?.toInt() ?? 0;
    final carb = (food['carbs_per_100g']    as num?)?.toInt() ?? 0;
    final fat  = (food['fat_per_100g']      as num?)?.toInt() ?? 0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: _kCard, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          const Icon(Icons.restaurant, color: _kGreen, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text('$cal kcal  ', style: const TextStyle(color: _kDim, fontSize: 11)),
                    _MacroChip('P', '${pro}g', const Color(0xFF5B8DEF)),
                    const SizedBox(width: 4),
                    _MacroChip('C', '${carb}g', const Color(0xFFE0A840)),
                    const SizedBox(width: 4),
                    _MacroChip('F', '${fat}g', const Color(0xFFE05B5B)),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () async {
              final foodMap = Map<String, dynamic>.from(food as Map);
              if (foodMap['has_ingredients'] == true) {
                await CustomRecipeSheet.show(context, existingFood: foodMap);
              } else {
                await CustomFoodSheet.show(context, existingFood: foodMap);
              }
            },
            child: const Icon(Icons.edit_outlined, color: _kDim, size: 18),
          ),
          const SizedBox(width: 10),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showMealPicker(screenContext, food);
            },
            style: TextButton.styleFrom(
              backgroundColor: _kGreen.withValues(alpha: 0.15),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text('Log', style: TextStyle(color: _kGreen, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
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

class _FoodCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String buttonLabel;
  final VoidCallback onTap;

  const _FoodCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(color: _kCard, borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: _kGreen, width: 1.5),
                color: _kGreen.withValues(alpha: 0.08),
              ),
              child: Icon(icon, color: _kGreen, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: _kDim, fontSize: 12)),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      border: Border.all(color: _kDim.withValues(alpha: 0.6)),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      buttonLabel,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: _kGreen, size: 22),
          ],
        ),
      ),
    );
  }
}
