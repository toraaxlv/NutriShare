import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/nutrition_provider.dart';
import 'edit_profile_screen.dart';

const _kBg      = Color(0xFF1A3528);
const _kCard    = Color(0xFF243D2F);
const _kGreen   = Color(0xFFA8E040);
const _kDim     = Color(0xFF6B9080);
const _kDivider = Color(0xFF2B4A38);

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  void _logout(BuildContext context) {
    context.read<NutritionProvider>().clearDashboard();
    context.read<AuthProvider>().logout();
  }

  @override
  Widget build(BuildContext context) {
    final user      = context.watch<AuthProvider>().user;
    final nutrition = context.watch<NutritionProvider>();

    final calories = (nutrition.targets?['calories'] as num?)?.toInt();
    final proteinG = (nutrition.targets?['protein_g'] as num?)?.toInt();
    final fatG     = (nutrition.targets?['fat_g'] as num?)?.toInt();
    final carbsG   = (nutrition.targets?['carbs_g'] as num?)?.toInt();

    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // ── Header ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('More', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(user?.email ?? '', style: const TextStyle(color: _kDim, fontSize: 14)),
                ],
              ),
            ),

            // ── Menu items ───────────────────────────────────────────────────
            _MenuItem(
              icon: Icons.person_outline,
              title: 'Profile',
              subtitle: 'Edit personal info and body metrics',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen())),
            ),
            const Divider(color: _kDivider, height: 1, indent: 16, endIndent: 16),
            _MenuItem(
              icon: Icons.track_changes,
              title: 'Target',
              subtitle: 'Change your daily nutrition targets',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditTargetScreen())),
            ),
            const Divider(color: _kDivider, height: 1, indent: 16, endIndent: 16),
            _MenuItem(
              icon: Icons.monitor_weight_outlined,
              title: 'Weight Log',
              subtitle: 'Log your weight and track progress',
              onTap: () => _WeightLogSheet.show(context),
            ),
            const Divider(color: _kDivider, height: 1, indent: 16, endIndent: 16),
            _MenuItem(
              icon: Icons.water_drop_outlined,
              title: 'Water Target',
              subtitle: 'Set your daily hydration goal',
              onTap: () => _showWaterTargetDialog(context, nutrition.waterTargetMl),
            ),
            const Divider(color: _kDivider, height: 1, indent: 16, endIndent: 16),
            _MenuItem(
              icon: Icons.info_outline,
              title: 'About',
              subtitle: 'App info and team',
              onTap: () => _AboutSheet.show(context),
            ),

            // ── Daily targets card ───────────────────────────────────────────
            if (calories != null) ...[
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: _kCard, borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Daily Targets', style: TextStyle(color: _kGreen, fontSize: 13, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _TargetChip(label: 'Calories', value: '$calories kcal'),
                          _TargetChip(label: 'Protein',  value: '${proteinG ?? '-'}g'),
                          _TargetChip(label: 'Carbs',    value: '${carbsG ?? '-'}g'),
                          _TargetChip(label: 'Fat',      value: '${fatG ?? '-'}g'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 32),
            Center(
              child: TextButton(
                onPressed: () => _logout(context),
                child: const Text('Log out', style: TextStyle(color: Colors.redAccent)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ── Water target dialog ───────────────────────────────────────────────────────

Future<void> _showWaterTargetDialog(BuildContext context, int currentTarget) async {
  final presets = [1000, 1500, 2000, 2500, 3000, 3500];
  int selected = presets.contains(currentTarget) ? currentTarget : 2000;
  final customCtrl = TextEditingController(
    text: presets.contains(currentTarget) ? '' : currentTarget.toString(),
  );

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setS) => AlertDialog(
        backgroundColor: const Color(0xFF243D2F),
        title: const Text('Water Target', style: TextStyle(color: Colors.white, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Pilih target harian', style: TextStyle(color: _kDim, fontSize: 12)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: presets.map((ml) {
                final isSelected = selected == ml;
                return GestureDetector(
                  onTap: () => setS(() { selected = ml; customCtrl.clear(); }),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: isSelected ? _kGreen.withValues(alpha: 0.2) : _kBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isSelected ? _kGreen : _kDim),
                    ),
                    child: Text(
                      ml >= 1000 ? '${ml ~/ 1000}.${(ml % 1000) ~/ 100}L' : '${ml}ml',
                      style: TextStyle(
                        color: isSelected ? _kGreen : Colors.white70,
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: customCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: const InputDecoration(
                hintText: 'Custom (ml)',
                hintStyle: TextStyle(color: _kDim, fontSize: 13),
                suffixText: 'ml',
                suffixStyle: TextStyle(color: _kDim),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: _kDim)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: _kGreen)),
                isDense: true,
              ),
              onChanged: (v) {
                final n = int.tryParse(v);
                if (n != null) setS(() => selected = n);
              },
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
  final target = int.tryParse(customCtrl.text) ?? selected;
  if (target > 0) {
    await context.read<NutritionProvider>().updateWaterTarget(target);
  }
}

// ── Weight log sheet ──────────────────────────────────────────────────────────

class _WeightLogSheet extends StatefulWidget {
  const _WeightLogSheet();

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _WeightLogSheet(),
    );
  }

  @override
  State<_WeightLogSheet> createState() => _WeightLogSheetState();
}

class _WeightLogSheetState extends State<_WeightLogSheet> {
  final _weightCtrl = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final current = context.read<AuthProvider>().user?.weightKg;
    if (current != null) _weightCtrl.text = current.toStringAsFixed(1);
  }

  @override
  void dispose() {
    _weightCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (_, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(primary: _kGreen),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _save() async {
    final val = double.tryParse(_weightCtrl.text.replaceAll(',', '.'));
    if (val == null || val <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan berat yang valid'), backgroundColor: Colors.orange),
      );
      return;
    }
    setState(() => _isSaving = true);
    final ok = await context.read<NutritionProvider>().logWeight(date: _selectedDate, weightKg: val);
    if (!mounted) return;
    setState(() => _isSaving = false);
    if (ok) {
      await context.read<AuthProvider>().checkLoginStatus();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Berat berhasil dicatat'), backgroundColor: Colors.green),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menyimpan. Coba lagi.'), backgroundColor: Colors.red),
      );
    }
  }

  String _fmtDate(DateTime d) {
    const mo = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${mo[d.month - 1]} ${d.day.toString().padLeft(2,'0')}, ${d.year}';
  }

  String _fmtLogDate(String s) {
    try {
      final d = DateTime.parse(s);
      const mo = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      return '${mo[d.month-1]} ${d.day.toString().padLeft(2,'0')}';
    } catch (_) { return s; }
  }

  @override
  Widget build(BuildContext context) {
    final history = context.watch<NutritionProvider>().weightHistory;
    final bottomPad = MediaQuery.of(context).viewInsets.bottom;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.92,
      builder: (_, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: _kBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(bottom: bottomPad),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: _kDivider, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Weight Log', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),

                  // Weight input
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _weightCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                          decoration: const InputDecoration(
                            hintText: '0.0',
                            hintStyle: TextStyle(color: _kDim),
                            suffixText: 'kg',
                            suffixStyle: TextStyle(color: _kDim, fontSize: 16),
                            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: _kDivider)),
                            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: _kGreen)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Date picker
                  GestureDetector(
                    onTap: _pickDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: _kCard,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _kDivider),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_fmtDate(_selectedDate), style: const TextStyle(color: Colors.white, fontSize: 14)),
                          const Icon(Icons.calendar_today_outlined, color: _kDim, size: 16),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _kGreen,
                        foregroundColor: _kBg,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: _isSaving
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1A3528)))
                          : const Text('Log Weight', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),
            const Divider(color: _kDivider),

            // History list
            Expanded(
              child: history.isEmpty
                  ? const Center(child: Text('Belum ada riwayat berat badan', style: TextStyle(color: _kDim, fontSize: 13)))
                  : ListView.separated(
                      controller: scrollCtrl,
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      itemCount: history.length,
                      separatorBuilder: (_, __) => const Divider(color: _kDivider, height: 1),
                      itemBuilder: (_, i) {
                        final entry = history[history.length - 1 - i];
                        final dateStr = entry['log_date'] as String? ?? '';
                        final weight  = (entry['weight_kg'] as num?)?.toDouble() ?? 0;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_fmtLogDate(dateStr), style: const TextStyle(color: _kDim, fontSize: 13)),
                              Text('${weight.toStringAsFixed(1)} kg',
                                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── About sheet ───────────────────────────────────────────────────────────────

class _AboutSheet extends StatelessWidget {
  const _AboutSheet();

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AboutSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    const team = [
      ('Tora',     'Backend Engineer'),
      ('Evan',     'Frontend Engineer'),
      ('Jeremy',   'Project Manager'),
      ('Daniel',   'UI/UX Designer'),
      ('Josh',     'Algorithm Developer'),
    ];

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.85,
      builder: (_, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: _kBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: ListView(
          controller: scrollCtrl,
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: _kDivider, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 24),

            // App name + tagline
            Center(
              child: Column(
                children: [
                  Container(
                    width: 64, height: 64,
                    decoration: BoxDecoration(
                      color: _kGreen.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                      border: Border.all(color: _kGreen, width: 1.5),
                    ),
                    child: const Icon(Icons.eco_outlined, color: _kGreen, size: 32),
                  ),
                  const SizedBox(height: 12),
                  const Text('NutriShare', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text('Track smarter. Eat better.', style: TextStyle(color: _kDim, fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Section: Team
            const Text('Tim', style: TextStyle(color: _kGreen, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
            const SizedBox(height: 10),
            ...team.map((m) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: _kCard,
                      shape: BoxShape.circle,
                      border: Border.all(color: _kDivider),
                    ),
                    child: Center(
                      child: Text(m.$1[0], style: const TextStyle(color: _kGreen, fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(m.$1, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                      Text(m.$2, style: const TextStyle(color: _kDim, fontSize: 11)),
                    ],
                  ),
                ],
              ),
            )),
            const SizedBox(height: 20),

            // Section: Tech stack
            const Text('Tech Stack', style: TextStyle(color: _kGreen, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ['Flutter', 'FastAPI', 'PostgreSQL', 'USDA FoodData'].map((t) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _kCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _kDivider),
                ),
                child: Text(t, style: const TextStyle(color: Colors.white70, fontSize: 12)),
              )).toList(),
            ),
            const SizedBox(height: 20),

            // Built for
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _kCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _kDivider),
              ),
              child: const Text(
                'Dibuat sebagai proyek mata kuliah Software Engineering, HCI, dan Object-Oriented Modeling.',
                style: TextStyle(color: _kDim, fontSize: 12, height: 1.5),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared widgets ────────────────────────────────────────────────────────────

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuItem({required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: _kGreen, size: 26),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(color: _kDim, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: _kDim, size: 20),
          ],
        ),
      ),
    );
  }
}

class _TargetChip extends StatelessWidget {
  final String label;
  final String value;

  const _TargetChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: _kDim, fontSize: 11)),
      ],
    );
  }
}
