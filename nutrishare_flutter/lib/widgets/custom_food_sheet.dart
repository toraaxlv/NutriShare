import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/nutrition_provider.dart';

const _kBg    = Color(0xFF1A3528);
const _kCard  = Color(0xFF243D2F);
const _kGreen = Color(0xFFA8E040);
const _kDim   = Color(0xFF6B9080);
const _kLine  = Color(0xFF2B4A38);

class CustomFoodSheet extends StatefulWidget {
  const CustomFoodSheet({super.key});

  /// Returns the created food map, or null if cancelled.
  static Future<Map<String, dynamic>?> show(BuildContext context) {
    return showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CustomFoodSheet(),
    );
  }

  @override
  State<CustomFoodSheet> createState() => _CustomFoodSheetState();
}

class _CustomFoodSheetState extends State<CustomFoodSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _calCtrl  = TextEditingController();
  final _proCtrl  = TextEditingController();
  final _carbCtrl = TextEditingController();
  final _fatCtrl  = TextEditingController();
  bool _isSaving  = false;

  @override
  void dispose() {
    for (final c in [_nameCtrl, _calCtrl, _proCtrl, _carbCtrl, _fatCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final food = await context.read<NutritionProvider>().createFood(
      name: _nameCtrl.text.trim(),
      caloriesPer100g: double.parse(_calCtrl.text),
      proteinPer100g: double.parse(_proCtrl.text),
      carbsPer100g: double.parse(_carbCtrl.text),
      fatPer100g: double.parse(_fatCtrl.text),
    );

    setState(() => _isSaving = false);
    if (mounted) Navigator.pop(context, food);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: _kBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomInset),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: _kLine, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            const Text('Custom Food', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('Per 100g', style: TextStyle(color: _kDim, fontSize: 12)),
            const SizedBox(height: 16),
            _Field(ctrl: _nameCtrl, label: 'Nama Makanan', isText: true),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: _Field(ctrl: _calCtrl, label: 'Kalori (kcal)')),
              const SizedBox(width: 10),
              Expanded(child: _Field(ctrl: _proCtrl, label: 'Protein (g)')),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: _Field(ctrl: _carbCtrl, label: 'Karbo (g)')),
              const SizedBox(width: 10),
              Expanded(child: _Field(ctrl: _fatCtrl, label: 'Lemak (g)')),
            ]),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kGreen,
                  foregroundColor: _kBg,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: _isSaving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Simpan', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final bool isText;

  const _Field({required this.ctrl, required this.label, this.isText = false});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: ctrl,
      keyboardType: isText ? TextInputType.text : const TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(color: Colors.white, fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: _kDim, fontSize: 12),
        isDense: true,
        filled: true,
        fillColor: _kCard,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _kLine)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _kLine)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _kGreen)),
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Wajib diisi';
        if (!isText && double.tryParse(v) == null) return 'Angka tidak valid';
        return null;
      },
    );
  }
}
