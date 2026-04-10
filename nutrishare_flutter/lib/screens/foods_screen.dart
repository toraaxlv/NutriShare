import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/nutrition_provider.dart';
import '../widgets/custom_food_sheet.dart';
import '../widgets/add_food_sheet.dart';

const _kBg    = Color(0xFF1A3528);
const _kCard  = Color(0xFF243D2F);
const _kGreen = Color(0xFFA8E040);
const _kDim   = Color(0xFF6B9080);
const _kLine  = Color(0xFF2B4A38);

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
    AddFoodSheet.show(
      context,
      mealType: 'uncategorized',
      date: DateTime.now(),
      preselectedFood: food,
    );
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
                  Text(
                    '${calories.toInt()} kcal · P ${protein.toInt()}g · C ${carbs.toInt()}g · F ${fat.toInt()}g  /100g',
                    style: const TextStyle(color: _kDim, fontSize: 11),
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
            leadingWidget: Container(
              width: 48, height: 48,
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: _kGreen, width: 2)),
              child: const Icon(Icons.restaurant_menu, color: _kGreen, size: 22),
            ),
            title: 'Custom meals',
            subtitle: 'Combine all your foods and recipes to one meal for logging',
            buttonLabel: 'CUSTOM MEAL',
            onTap: () {},
          ),
          const SizedBox(height: 12),
          _FoodCard(
            leadingWidget: const SizedBox(
              width: 48, height: 48,
              child: Center(child: Text('🍳', style: TextStyle(fontSize: 32))),
            ),
            title: 'Custom recipe',
            subtitle: 'create new recipes from your cooking for quick logging',
            buttonLabel: 'CUSTOM RECIPE',
            onTap: () {},
          ),
          const SizedBox(height: 12),
          _FoodCard(
            leadingWidget: const SizedBox(
              width: 48, height: 48,
              child: Center(child: Icon(Icons.add, color: _kGreen, size: 32)),
            ),
            title: 'Custom Foods',
            subtitle: "Browse & add your saved custom foods",
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
  const _CustomFoodListSheet();

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _CustomFoodListSheet(),
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
                        return _CustomFoodTile(food: f);
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
  const _CustomFoodTile({required this.food});

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
                Text(
                  '$cal kcal · P ${pro}g · C ${carb}g · F ${fat}g  /100g',
                  style: const TextStyle(color: _kDim, fontSize: 11),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              AddFoodSheet.show(context, mealType: 'uncategorized', date: DateTime.now(), preselectedFood: food);
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

class _FoodCard extends StatelessWidget {
  final Widget leadingWidget;
  final String title;
  final String subtitle;
  final String buttonLabel;
  final VoidCallback onTap;

  const _FoodCard({
    required this.leadingWidget,
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
            leadingWidget,
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
