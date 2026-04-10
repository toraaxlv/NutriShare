import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/nutrition_provider.dart';
import '../models/user.dart';

const _kBg    = Color(0xFF1A3528);
const _kCard  = Color(0xFF243D2F);
const _kGreen = Color(0xFFA8E040);
const _kDim   = Color(0xFF6B9080);
const _kLine  = Color(0xFF2B4A38);

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _nameCtrl  = TextEditingController();
  final _weightCtrl= TextEditingController();
  final _heightCtrl= TextEditingController();

  String? _gender;
  String? _activityLevel;
  DateTime? _dob;
  bool _isSaving = false;

  static const _genders = [
    {'value': 'male',   'label': 'Male'},
    {'value': 'female', 'label': 'Female'},
  ];

  static const _activities = [
    {'value': 'no_activity', 'label': 'No Activity'},
    {'value': 'sedentary',   'label': 'Sedentary'},
    {'value': 'light',       'label': 'Light'},
    {'value': 'moderate',    'label': 'Moderate'},
    {'value': 'very_active', 'label': 'Very Active'},
  ];

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    if (user != null) _populate(user);
  }

  void _populate(User user) {
    _nameCtrl.text   = user.name ?? '';
    _weightCtrl.text = user.weightKg?.toStringAsFixed(1) ?? '';
    _heightCtrl.text = user.heightCm?.toStringAsFixed(1) ?? '';
    _gender          = user.gender;
    _activityLevel   = user.activityLevel;
    if (user.dateOfBirth != null) {
      try { _dob = DateTime.parse(user.dateOfBirth!); } catch (_) {}
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _weightCtrl.dispose();
    _heightCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDob() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(2000),
      firstDate: DateTime(1930),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(primary: Color(0xFFA8E040)),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _dob = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final data = <String, dynamic>{};
    if (_nameCtrl.text.isNotEmpty) data['name'] = _nameCtrl.text.trim();
    if (_gender != null) data['gender'] = _gender;
    if (_dob != null) {
      data['date_of_birth'] =
          '${_dob!.year}-${_dob!.month.toString().padLeft(2,'0')}-${_dob!.day.toString().padLeft(2,'0')}';
    }
    final w = double.tryParse(_weightCtrl.text);
    if (w != null) data['weight_kg'] = w;
    final h = double.tryParse(_heightCtrl.text);
    if (h != null) data['height_cm'] = h;
    if (_activityLevel != null) data['activity_level'] = _activityLevel;

    final ok = await context.read<NutritionProvider>().updateProfile(data);
    if (ok) await context.read<AuthProvider>().checkLoginStatus();

    if (!mounted) return;
    setState(() => _isSaving = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok ? 'Profil berhasil diperbarui' : 'Gagal menyimpan', style: const TextStyle(color: Colors.white)),
      backgroundColor: ok ? const Color(0xFF243D2F) : Colors.redAccent,
    ));
    if (ok) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kBg,
        foregroundColor: Colors.white,
        title: const Text('Edit Profile', style: TextStyle(color: Colors.white, fontSize: 18)),
        iconTheme: const IconThemeData(color: _kGreen),
        elevation: 0,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _Section('Informasi Dasar'),
              _TF(ctrl: _nameCtrl, label: 'Nama'),
              const SizedBox(height: 12),
              _Dropdown(
                label: 'Gender',
                value: _gender,
                items: _genders,
                onChanged: (v) => setState(() => _gender = v),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _pickDob,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: _kCard,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _kLine),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _dob != null
                              ? '${_dob!.day}/${_dob!.month}/${_dob!.year}'
                              : 'Tanggal Lahir',
                          style: TextStyle(
                            color: _dob != null ? Colors.white : _kDim,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const Icon(Icons.calendar_today_outlined, color: _kDim, size: 16),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _Section('Fisik'),
              Row(children: [
                Expanded(child: _TF(ctrl: _weightCtrl, label: 'Berat (kg)', isNum: true)),
                const SizedBox(width: 12),
                Expanded(child: _TF(ctrl: _heightCtrl, label: 'Tinggi (cm)', isNum: true)),
              ]),
              const SizedBox(height: 24),
              _Section('Aktivitas'),
              _Dropdown(
                label: 'Level Aktivitas',
                value: _activityLevel,
                items: _activities,
                onChanged: (v) => setState(() => _activityLevel = v),
              ),
              const SizedBox(height: 32),
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
      ),
    );
  }
}

// ── Edit Target Screen ─────────────────────────────────────────────────────────

class EditTargetScreen extends StatefulWidget {
  const EditTargetScreen({super.key});

  @override
  State<EditTargetScreen> createState() => _EditTargetScreenState();
}

class _EditTargetScreenState extends State<EditTargetScreen> {
  final _formKey       = GlobalKey<FormState>();
  final _targetWtCtrl  = TextEditingController();
  String? _goal;
  double _ratePerWeek  = 0.5;
  bool _isSaving       = false;

  static const _goals = [
    {'value': 'lose',     'label': 'Turunkan Berat'},
    {'value': 'maintain', 'label': 'Pertahankan'},
    {'value': 'gain',     'label': 'Naikkan Berat'},
  ];

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      _goal = user.goal;
      _targetWtCtrl.text = user.targetWeightKg?.toStringAsFixed(1) ?? '';
      _ratePerWeek = user.goalRateKgPerWeek ?? 0.5;
    }
  }

  @override
  void dispose() {
    _targetWtCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final data = <String, dynamic>{};
    if (_goal != null) data['goal'] = _goal;
    final tw = double.tryParse(_targetWtCtrl.text);
    if (tw != null) data['target_weight_kg'] = tw;
    data['goal_rate_kg_per_week'] = _ratePerWeek;

    final ok = await context.read<NutritionProvider>().updateProfile(data);
    if (ok) await context.read<AuthProvider>().checkLoginStatus();

    if (!mounted) return;
    setState(() => _isSaving = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok ? 'Target berhasil diperbarui' : 'Gagal menyimpan', style: const TextStyle(color: Colors.white)),
      backgroundColor: ok ? const Color(0xFF243D2F) : Colors.redAccent,
    ));
    if (ok) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final rates = _goal == 'gain'
        ? [0.25, 0.5]
        : _goal == 'lose'
            ? [0.25, 0.5, 0.75, 1.0]
            : <double>[];

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kBg,
        foregroundColor: Colors.white,
        title: const Text('Edit Target', style: TextStyle(color: Colors.white, fontSize: 18)),
        iconTheme: const IconThemeData(color: _kGreen),
        elevation: 0,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _Section('Goal'),
              _Dropdown(
                label: 'Tujuan',
                value: _goal,
                items: _goals,
                onChanged: (v) => setState(() { _goal = v; _ratePerWeek = 0.5; }),
              ),
              const SizedBox(height: 16),
              _TF(ctrl: _targetWtCtrl, label: 'Berat Target (kg)', isNum: true),
              if (rates.isNotEmpty) ...[
                const SizedBox(height: 24),
                _Section('Kecepatan (kg/minggu)'),
                Wrap(
                  spacing: 8,
                  children: rates.map((r) => ChoiceChip(
                    label: Text('$r kg', style: TextStyle(color: _ratePerWeek == r ? _kBg : Colors.white70)),
                    selected: _ratePerWeek == r,
                    selectedColor: _kGreen,
                    backgroundColor: _kCard,
                    side: const BorderSide(color: _kLine),
                    onSelected: (_) => setState(() => _ratePerWeek = r),
                  )).toList(),
                ),
              ],
              const SizedBox(height: 32),
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
      ),
    );
  }
}

// ── Shared widgets ────────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  final String text;
  const _Section(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(text, style: const TextStyle(color: _kGreen, fontSize: 13, fontWeight: FontWeight.bold)),
    );
  }
}

class _TF extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final bool isNum;

  const _TF({required this.ctrl, required this.label, this.isNum = false});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: ctrl,
      keyboardType: isNum ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
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
    );
  }
}

class _Dropdown extends StatelessWidget {
  final String label;
  final String? value;
  final List<Map<String, String>> items;
  final ValueChanged<String?> onChanged;

  const _Dropdown({required this.label, required this.value, required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      dropdownColor: _kCard,
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
      items: items.map((m) => DropdownMenuItem(
        value: m['value'],
        child: Text(m['label']!, style: const TextStyle(color: Colors.white)),
      )).toList(),
      onChanged: onChanged,
    );
  }
}
