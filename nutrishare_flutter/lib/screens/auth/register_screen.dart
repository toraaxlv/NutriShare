import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/nutrishare_logo.dart';
import 'login_screen.dart';

// ─── Warna tema ───────────────────────────────────────────────────────────────
const _kBg     = Color(0xFF1A3528);
const _kBorder = Color(0xFF2B5040);
const _kGreen  = Color(0xFFA8E040);
const _kOrange = Color(0xFFF09038);
const _kError  = Color(0xFFFF5C5C);

// ─── Data antar step ──────────────────────────────────────────────────────────
class RegisterData {
  // Step 1
  String? gender;
  int?    day;
  int?    month;
  int?    year;
  double? heightCm;
  double? weightKg;

  // Step 2
  String? activityLevel;
  double? customExerciseCalories;

  // Step 3
  String? goal;
  double? targetWeightKg;

  // Step 4
  double goalRateKgPerWeek = 0.25;

  // Step 6
  String username = '';
  String email    = '';
  String password = '';
}

// ─── Root screen ──────────────────────────────────────────────────────────────
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  int _step = 0;
  final _data = RegisterData();

  void _next() => setState(() => _step++);
  void _back() {
    if (_step == 0) {
      Navigator.pop(context);
    } else {
      setState(() => _step--);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(child: _buildStep()),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0:
        return _Step1(data: _data, onNext: _next, onBack: _back);
      case 1:
        return _Step2(data: _data, onNext: _next, onBack: _back);
      case 2:
        return _Step3(data: _data, onNext: _next, onBack: _back);
      case 3:
        return _Step4(data: _data, onNext: _next, onBack: _back);
      case 4:
        return _Step5(data: _data, onNext: _next, onBack: _back);
      case 5:
        return _Step6(data: _data, onBack: _back);
      default:
        return Center(
          child: Text(
            'Step ${_step + 1} — coming soon',
            style: const TextStyle(color: Colors.white),
          ),
        );
    }
  }
}

// ─── Header shared ────────────────────────────────────────────────────────────
class RegisterHeader extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final VoidCallback onBack;

  const RegisterHeader({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: onBack,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white38),
                  ),
                  child: const Icon(Icons.chevron_left, color: Colors.white),
                ),
              ),
              const Expanded(
                child: Center(child: NutriShareLogo(compact: true)),
              ),
              const SizedBox(width: 40),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'STEP $currentStep',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(totalSteps, (i) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: 40,
                height: 8,
                decoration: BoxDecoration(
                  color: i < currentStep ? _kOrange : _kBorder,
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ─── Step 1 ───────────────────────────────────────────────────────────────────
class _Step1 extends StatefulWidget {
  final RegisterData data;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const _Step1({required this.data, required this.onNext, required this.onBack});

  @override
  State<_Step1> createState() => _Step1State();
}

class _Step1State extends State<_Step1> {
  bool _showErrors = false;

  static const _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  void _tryNext() {
    if (_canProceed) {
      widget.onNext();
    } else {
      setState(() => _showErrors = true);
    }
  }

  bool get _canProceed =>
      widget.data.gender != null &&
      widget.data.day != null &&
      widget.data.month != null &&
      widget.data.year != null &&
      widget.data.heightCm != null &&
      widget.data.weightKg != null;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RegisterHeader(currentStep: 1, totalSteps: 6, onBack: widget.onBack),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 32),
                const Text(
                  'Set Your Profile',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Please fill the information for your\nnutrition target needs',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white60, fontSize: 14),
                ),
                const SizedBox(height: 32),

                // Gender
                _buildLabel('Gender'),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _buildGenderOption('male', Icons.man, Colors.lightBlueAccent),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildGenderOption('female', Icons.woman, Colors.pinkAccent),
                    ),
                  ],
                ),
                if (_showErrors && widget.data.gender == null) ...[
                  const SizedBox(height: 6),
                  _buildError('Please select your gender'),
                ],
                const SizedBox(height: 24),

                // Date of Birth
                _buildLabel('Date of Birth'),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdown(
                        value: widget.data.day,
                        hint: 'Day',
                        items: List.generate(31, (i) => i + 1),
                        display: (v) => '$v',
                        onChanged: (v) => setState(() => widget.data.day = v),
                        hasError: _showErrors && widget.data.day == null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: _buildDropdown(
                        value: widget.data.month,
                        hint: 'Month',
                        items: List.generate(12, (i) => i + 1),
                        display: (v) => _months[v - 1],
                        onChanged: (v) => setState(() => widget.data.month = v),
                        hasError: _showErrors && widget.data.month == null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildDropdown(
                        value: widget.data.year,
                        hint: 'Year',
                        items: List.generate(100, (i) => DateTime.now().year - i),
                        display: (v) => '$v',
                        onChanged: (v) => setState(() => widget.data.year = v),
                        hasError: _showErrors && widget.data.year == null,
                      ),
                    ),
                  ],
                ),
                if (_showErrors &&
                    (widget.data.day == null ||
                        widget.data.month == null ||
                        widget.data.year == null)) ...[
                  const SizedBox(height: 6),
                  _buildError('Please complete your date of birth'),
                ],
                const SizedBox(height: 24),

                // Height
                _buildLabel('Height'),
                const SizedBox(height: 10),
                _buildSlider(
                  value: widget.data.heightCm,
                  min: 100,
                  max: 220,
                  unit: 'cm',
                  divisions: 120,
                  hasError: _showErrors && widget.data.heightCm == null,
                  onChanged: (v) => setState(() => widget.data.heightCm = v),
                ),
                const SizedBox(height: 24),

                // Weight
                _buildLabel('Weight'),
                const SizedBox(height: 10),
                _buildSlider(
                  value: widget.data.weightKg,
                  min: 30,
                  max: 200,
                  unit: 'kg',
                  divisions: 340,
                  hasError: _showErrors && widget.data.weightKg == null,
                  onChanged: (v) => setState(() => widget.data.weightKg = v),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),

        // Next button
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _tryNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: _kGreen,
                foregroundColor: const Color(0xFF1A3528),
                padding: const EdgeInsets.symmetric(vertical: 17),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Next',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) => Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: const TextStyle(
            color: _kGreen,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      );

  Widget _buildError(String message) => Align(
        alignment: Alignment.centerLeft,
        child: Text(
          message,
          style: const TextStyle(color: _kError, fontSize: 12),
        ),
      );

  Widget _buildGenderOption(String value, IconData icon, Color iconColor) {
    final selected = widget.data.gender == value;
    return GestureDetector(
      onTap: () => setState(() => widget.data.gender = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 64,
        decoration: BoxDecoration(
          border: Border.all(
            color: selected ? _kGreen : _kBorder,
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: selected ? _kGreen.withValues(alpha: 0.08) : Colors.transparent,
        ),
        child: Icon(icon, color: iconColor, size: 36),
      ),
    );
  }

  Widget _buildDropdown({
    required int? value,
    required String hint,
    required List<int> items,
    required String Function(int) display,
    required ValueChanged<int?> onChanged,
    required bool hasError,
  }) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: hasError ? _kError : _kBorder),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: value,
          hint: Text(hint, style: const TextStyle(color: Colors.white38, fontSize: 13)),
          isExpanded: true,
          dropdownColor: const Color(0xFF1F3D2C),
          style: const TextStyle(color: Colors.white, fontSize: 13),
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white38, size: 20),
          items: items
              .map((v) => DropdownMenuItem(value: v, child: Text(display(v))))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildSlider({
    required double? value,
    required double min,
    required double max,
    required String unit,
    required int divisions,
    required bool hasError,
    required ValueChanged<double> onChanged,
  }) {
    final hasValue = value != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
          decoration: BoxDecoration(
            border: Border.all(
              color: hasError ? _kError : (hasValue ? _kGreen.withValues(alpha: 0.6) : _kBorder),
              width: hasValue ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              // Value display
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    hasValue ? '${value.toStringAsFixed(unit == 'kg' ? 1 : 0)} $unit' : 'Not set',
                    style: TextStyle(
                      color: hasValue ? Colors.white : Colors.white38,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (!hasValue)
                    const Text(
                      'Drag slider to set',
                      style: TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              // Slider
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: _kGreen,
                  inactiveTrackColor: _kBorder,
                  thumbColor: hasValue ? _kGreen : Colors.white38,
                  overlayColor: _kGreen.withValues(alpha: 0.15),
                  trackHeight: 4,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                ),
                child: Slider(
                  value: value ?? min,
                  min: min,
                  max: max,
                  divisions: divisions,
                  onChanged: onChanged,
                ),
              ),
              // Range labels
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${min.toStringAsFixed(0)} $unit',
                    style: const TextStyle(color: Colors.white38, fontSize: 11),
                  ),
                  Text(
                    '${max.toStringAsFixed(0)} $unit',
                    style: const TextStyle(color: Colors.white38, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          _buildError('Please set your ${unit == 'cm' ? 'height' : 'weight'}'),
        ],
      ],
    );
  }
}

// ─── Step 2: Set Your Activity Level ─────────────────────────────────────────
class _ActivityOption {
  final String value;
  final String label;
  final String description;
  final IconData icon;

  const _ActivityOption({
    required this.value,
    required this.label,
    required this.description,
    required this.icon,
  });
}

const _kActivities = [
  _ActivityOption(
    value: 'no_activity',
    label: 'No Activity',
    description: "Choose this if you are in a condition where you don't have the energy to spend on physical activity",
    icon: Icons.airline_seat_flat,
  ),
  _ActivityOption(
    value: 'sedentary',
    label: 'Sedentary',
    description: 'Choose this when you lack of exercise, and your daily activity is limited to desk work and light household activity',
    icon: Icons.chair,
  ),
  _ActivityOption(
    value: 'light',
    label: 'Lightly',
    description: 'Choose this if you do light physical activity plus light exercise',
    icon: Icons.self_improvement,
  ),
  _ActivityOption(
    value: 'moderate',
    label: 'Moderately',
    description: 'Choose this if you do moderate intensity exercise 3-5 days a week, or have a job that requires a lot of physical movement.',
    icon: Icons.directions_run,
  ),
  _ActivityOption(
    value: 'very_active',
    label: 'Very Active',
    description: 'Choose this if you do high intensity exercise 6-7 days a week, or have a heavy physical job.',
    icon: Icons.fitness_center,
  ),
  _ActivityOption(
    value: 'custom',
    label: 'Custom',
    description: 'Set your own fixed daily value for calories burned due to exercise',
    icon: Icons.tune,
  ),
];

class _Step2 extends StatefulWidget {
  final RegisterData data;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const _Step2({required this.data, required this.onNext, required this.onBack});

  @override
  State<_Step2> createState() => _Step2State();
}

class _Step2State extends State<_Step2> {
  late final PageController _pageController;
  final _customCtrl = TextEditingController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    final initial = _kActivities.indexWhere((a) => a.value == widget.data.activityLevel);
    _currentPage = initial < 0 ? 0 : initial;
    _pageController = PageController(initialPage: _currentPage);
    widget.data.activityLevel ??= _kActivities[0].value;
    if (widget.data.customExerciseCalories != null) {
      _customCtrl.text = widget.data.customExerciseCalories!.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _customCtrl.dispose();
    super.dispose();
  }

  bool get _canProceed {
    final activity = _kActivities[_currentPage];
    if (activity.value == 'custom') {
      return widget.data.customExerciseCalories != null &&
          widget.data.customExerciseCalories! > 0;
    }
    return true;
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
      widget.data.activityLevel = _kActivities[page].value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RegisterHeader(currentStep: 2, totalSteps: 6, onBack: widget.onBack),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 28),
                const Text(
                  'Set Your Activity Level',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Please select a baseline level that best\ndescribes your day-to-day life',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white60, fontSize: 13),
                ),
                const SizedBox(height: 24),

                // Card carousel
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // PageView
                      PageView.builder(
                        controller: _pageController,
                        itemCount: _kActivities.length,
                        onPageChanged: _onPageChanged,
                        itemBuilder: (_, i) => _buildCard(_kActivities[i]),
                      ),

                      // Left arrow
                      if (_currentPage > 0)
                        Positioned(
                          left: 0,
                          child: _buildArrow(
                            icon: Icons.chevron_left,
                            onTap: () => _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            ),
                          ),
                        ),

                      // Right arrow
                      if (_currentPage < _kActivities.length - 1)
                        Positioned(
                          right: 0,
                          child: _buildArrow(
                            icon: Icons.chevron_right,
                            onTap: () => _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),

        // Next button
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _canProceed ? widget.onNext : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _kGreen,
                foregroundColor: const Color(0xFF1A3528),
                disabledBackgroundColor: _kGreen.withValues(alpha: 0.35),
                padding: const EdgeInsets.symmetric(vertical: 17),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Next',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCard(_ActivityOption activity) {
    final isCustom = activity.value == 'custom';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF24472F),
          borderRadius: BorderRadius.circular(28),
        ),
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        child: Column(
          children: [
            // Activity name
            Text(
              activity.label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Description
            Text(
              activity.description,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const Spacer(),

            // Custom kcal input
            if (isCustom) ...[
              Container(
                width: 160,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white38),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _customCtrl,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: '0',
                    hintStyle: TextStyle(color: Colors.white38),
                    suffixText: 'kcal',
                    suffixStyle: TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                  onChanged: (v) => setState(() {
                    widget.data.customExerciseCalories = double.tryParse(v);
                  }),
                ),
              ),
              const SizedBox(height: 16),
            ] else ...[
              // Illustration icon
              Icon(activity.icon, color: Colors.white38, size: 80),
              const SizedBox(height: 16),
            ],

            // Dot indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_kActivities.length, (i) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: i == _currentPage ? 12 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: i == _currentPage ? _kOrange : Colors.white24,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArrow({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.15),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

// ─── Step 3: Set a Weight Goal ────────────────────────────────────────────────
class _Step3 extends StatefulWidget {
  final RegisterData data;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const _Step3({required this.data, required this.onNext, required this.onBack});

  @override
  State<_Step3> createState() => _Step3State();
}

class _Step3State extends State<_Step3> {
  final _ctrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.data.targetWeightKg != null) {
      _ctrl.text = widget.data.targetWeightKg!.toStringAsFixed(1);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onChanged(String v) {
    final val = double.tryParse(v);
    setState(() {
      widget.data.targetWeightKg = val;
      // Infer goal dari perbandingan target vs berat saat ini
      if (val != null && widget.data.weightKg != null) {
        final diff = val - widget.data.weightKg!;
        if (diff > 0.5) {
          widget.data.goal = 'gain';
        } else if (diff < -0.5) {
          widget.data.goal = 'lose';
        } else {
          widget.data.goal = 'maintain';
        }
      }
    });
  }

  bool get _canProceed => widget.data.targetWeightKg != null;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RegisterHeader(currentStep: 3, totalSteps: 6, onBack: widget.onBack),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 28),
                const Text(
                  'Set a Weight Goal',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  "Let's calculate your daily calorie budget\nbased on your weight goals",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white60, fontSize: 13),
                ),
                const SizedBox(height: 32),

                // Card
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF24472F),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white38),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
                    child: Column(
                      children: [
                        RichText(
                          textAlign: TextAlign.center,
                          text: const TextSpan(
                            children: [
                              TextSpan(
                                text: "What's your\n",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text: 'weight goal',
                                style: TextStyle(
                                  color: _kOrange,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text: '?',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Input field
                        SizedBox(
                          width: 130,
                          child: TextField(
                            controller: _ctrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white, fontSize: 16),
                            decoration: InputDecoration(
                              hintText: '0',
                              hintStyle: const TextStyle(color: Colors.white38),
                              suffixText: 'kg',
                              suffixStyle: const TextStyle(color: Colors.white54, fontSize: 13),
                              contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: const BorderSide(color: Colors.white38),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: const BorderSide(color: _kGreen),
                              ),
                            ),
                            onChanged: _onChanged,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Next button
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _canProceed ? widget.onNext : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _kGreen,
                foregroundColor: const Color(0xFF1A3528),
                disabledBackgroundColor: _kGreen.withValues(alpha: 0.35),
                padding: const EdgeInsets.symmetric(vertical: 17),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Next',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Step 4: Set a Goal Rate ──────────────────────────────────────────────────
class _Step4 extends StatefulWidget {
  final RegisterData data;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const _Step4({required this.data, required this.onNext, required this.onBack});

  @override
  State<_Step4> createState() => _Step4State();
}

class _Step4State extends State<_Step4> {
  // Steps tersedia per goal
  static const _loseSteps = [0.25, 0.5, 0.75, 1.0];
  static const _gainSteps = [0.25, 0.5];

  List<double> get _steps {
    if (widget.data.goal == 'gain') return _gainSteps;
    if (widget.data.goal == 'lose') return _loseSteps;
    return [0.0]; // maintain
  }

  double get _rate => widget.data.goalRateKgPerWeek;

  void _decrement() {
    final idx = _steps.indexOf(_rate);
    if (idx > 0) setState(() => widget.data.goalRateKgPerWeek = _steps[idx - 1]);
  }

  void _increment() {
    final idx = _steps.indexOf(_rate);
    if (idx < _steps.length - 1) setState(() => widget.data.goalRateKgPerWeek = _steps[idx + 1]);
  }

  bool get _atMin => _steps.indexOf(_rate) <= 0;
  bool get _atMax => _steps.indexOf(_rate) >= _steps.length - 1;

  String get _goalLabel {
    if (widget.data.goal == 'gain') return 'weight gain goal?';
    if (widget.data.goal == 'maintain') return 'maintenance goal?';
    return 'weight loss goal?';
  }

  String get _displayRate {
    if (widget.data.goal == 'maintain') return '0 kg/week';
    final prefix = widget.data.goal == 'gain' ? '+' : '-';
    final val = _rate % 1 == 0 ? _rate.toStringAsFixed(0) : _rate.toString();
    return '$prefix$val kg/week';
  }

  @override
  void initState() {
    super.initState();
    // Pastikan rate valid untuk goal yang dipilih
    if (!_steps.contains(_rate)) {
      widget.data.goalRateKgPerWeek = _steps.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMaintain = widget.data.goal == 'maintain';

    // Compute max achievable loss rate given 1200 kcal floor
    double? maxAchievableRate;
    if (widget.data.goal == 'lose') {
      final tdee = _calcTDEE(widget.data);
      maxAchievableRate = ((tdee - 1200) * 7 / 7700).clamp(0.0, double.infinity);
    }
    final isConstrained = maxAchievableRate != null && _rate > maxAchievableRate;

    return Column(
      children: [
        RegisterHeader(currentStep: 4, totalSteps: 6, onBack: widget.onBack),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 28),
                const Text(
                  'Set a Goal Rate',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  "Let's calculate your daily calorie budget\nbased on your goal rate",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white60, fontSize: 13),
                ),
                const SizedBox(height: 32),

                // Card
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF24472F),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white38),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
                    child: Column(
                      children: [
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            children: [
                              const TextSpan(
                                text: "What's your\n",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text: _goalLabel,
                                style: const TextStyle(
                                  color: _kOrange,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Stepper row
                        if (!isMaintain)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildStepBtn(
                                icon: Icons.remove,
                                onTap: _atMin ? null : _decrement,
                                active: !_atMin,
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.white38),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  _displayRate,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              _buildStepBtn(
                                icon: Icons.add,
                                onTap: _atMax ? null : _increment,
                                active: !_atMax,
                              ),
                            ],
                          )
                        else
                          Text(
                            _displayRate,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                        if (isConstrained) ...[
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: _kOrange.withValues(alpha: 0.12),
                              border: Border.all(
                                  color: _kOrange.withValues(alpha: 0.5)),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.warning_amber_rounded,
                                    color: _kOrange, size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Rate ini melebihi batas aman.\n'
                                    'Dengan TDEE kamu, kalori harian minimum 1,200 kcal hanya bisa mendukung '
                                    '~${(maxAchievableRate * 10).round() / 10} kg/week.',
                                    style: const TextStyle(
                                        color: _kOrange, fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Next button
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: _kGreen,
                foregroundColor: const Color(0xFF1A3528),
                padding: const EdgeInsets.symmetric(vertical: 17),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Next',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStepBtn({
    required IconData icon,
    required VoidCallback? onTap,
    required bool active,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: active ? _kGreen : Colors.white24,
        ),
        child: Icon(
          icon,
          color: active ? const Color(0xFF1A3528) : Colors.white38,
          size: 18,
        ),
      ),
    );
  }
}


// ─── Kalkulasi nutrisi (mirror logic backend) ─────────────────────────────────
const _kActivityMultipliers = {
  'no_activity': 1.0,
  'sedentary':   1.2,
  'light':       1.375,
  'moderate':    1.55,
  'very_active': 1.9,
};

int _calcAge(int year, int month, int day) {
  final today = DateTime.now();
  int age = today.year - year;
  if (today.month < month || (today.month == month && today.day < day)) age--;
  return age;
}

double _calcTDEE(RegisterData d) {
  final age = _calcAge(d.year!, d.month!, d.day!);
  double bmr = 10 * d.weightKg! + 6.25 * d.heightCm! - 5 * age;
  bmr += d.gender == 'male' ? 5 : -161;
  if (d.activityLevel == 'custom' && d.customExerciseCalories != null) {
    return bmr + d.customExerciseCalories!;
  }
  return bmr * (_kActivityMultipliers[d.activityLevel] ?? 1.2);
}

Map<String, double> _calcNutrition(RegisterData d) {
  const minCalories = 1200.0;
  final tdee = _calcTDEE(d);

  final dailyAdj = (7700 * d.goalRateKgPerWeek) / 7;
  double calories = d.goal == 'lose'
      ? tdee - dailyAdj
      : d.goal == 'gain'
          ? tdee + dailyAdj
          : tdee;

  final isClamped = d.goal == 'lose' && calories < minCalories;
  calories = calories.clamp(minCalories, double.infinity);

  final actualRate = isClamped
      ? ((tdee - minCalories) * 7 / 7700).clamp(0.0, double.infinity)
      : d.goalRateKgPerWeek.toDouble();

  return {
    'calories': calories.roundToDouble(),
    'tdee': tdee.roundToDouble(),
    'surplus_deficit': (calories - tdee).roundToDouble(),
    'actual_rate': actualRate,
  };
}

DateTime? _calcForecast(RegisterData d, {double? effectiveRate}) {
  if (d.goal == 'maintain') return null;
  final rate = effectiveRate ?? d.goalRateKgPerWeek;
  if (d.targetWeightKg == null || d.weightKg == null || rate == 0) return null;
  final diff = (d.targetWeightKg! - d.weightKg!).abs();
  if (diff < 0.1) return DateTime.now();
  final weeks = diff / rate;
  return DateTime.now().add(Duration(days: (weeks * 7).round()));
}

String _fmtDate(DateTime dt) {
  const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
  return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
}

// ─── Step 5: Goal Overview ────────────────────────────────────────────────────
class _Step5 extends StatelessWidget {
  final RegisterData data;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const _Step5({required this.data, required this.onNext, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final nutrition   = _calcNutrition(data);
    final actualRate  = nutrition['actual_rate']!;
    final forecast    = _calcForecast(data, effectiveRate: actualRate);
    final calories    = nutrition['calories']!.toInt();
    final surpDef     = nutrition['surplus_deficit']!.toInt();
    final isGain      = data.goal == 'gain';
    final isMaintain  = data.goal == 'maintain';
    final isConstrained = !isGain && !isMaintain &&
        actualRate < data.goalRateKgPerWeek - 0.01;

    final rateLabel = isMaintain
        ? '0 kg/week'
        : '${isGain ? '+' : '-'}${data.goalRateKgPerWeek} kg/week';

    final goalLabel = isGain ? 'Gain Weight' : isMaintain ? 'Maintain Weight' : 'Lose Weight';
    final surpDefLabel = surpDef >= 0 ? 'Daily Energy Surplus' : 'Daily Energy Deficit';

    return Column(
      children: [
        RegisterHeader(currentStep: 5, totalSteps: 6, onBack: onBack),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 28),
                const Text(
                  'Goal Overview',
                  style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  "Here's your plan and goal forecast based on\nthe information provided",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white60, fontSize: 13),
                ),
                const SizedBox(height: 28),

                // Outer card
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF24472F),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Orange section — weight goal
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: _kOrange,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                        child: Column(
                          children: [
                            const Text(
                              'Weight goal\noverview',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Divider(color: Colors.white38, height: 24),
                            Icon(
                              isGain ? Icons.trending_up : isMaintain ? Icons.balance : Icons.trending_down,
                              color: Colors.white,
                              size: 36,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              goalLabel,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            Text(
                              rateLabel,
                              style: const TextStyle(color: Colors.white70, fontSize: 13),
                            ),
                            if (isConstrained) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Effective: ~${(actualRate * 10).round() / 10} kg/week (1,200 kcal min)',
                                style: const TextStyle(
                                    color: Colors.white54, fontSize: 11),
                              ),
                            ],
                            if (forecast != null) ...[
                              const SizedBox(height: 16),
                              const Icon(Icons.flag_outlined, color: Colors.white, size: 36),
                              const SizedBox(height: 6),
                              const Text(
                                'Goal Forecast',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              Text(
                                _fmtDate(forecast),
                                style: const TextStyle(color: Colors.white70, fontSize: 13),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Green section — energy
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: _kGreen,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                        child: Column(
                          children: [
                            const Text(
                              'Energy Target',
                              style: TextStyle(color: Color(0xFF1A3528), fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            Text(
                              '$calories kcal',
                              style: const TextStyle(color: Color(0xFF1A3528), fontSize: 13),
                            ),
                            const SizedBox(height: 12),
                            const Divider(color: Color(0xFF1A3528), height: 1),
                            const SizedBox(height: 12),
                            Text(
                              surpDefLabel,
                              style: const TextStyle(color: Color(0xFF1A3528), fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            Text(
                              '${surpDef.abs()} kcal',
                              style: const TextStyle(color: Color(0xFF1A3528), fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: _kGreen,
                foregroundColor: const Color(0xFF1A3528),
                padding: const EdgeInsets.symmetric(vertical: 17),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                elevation: 0,
              ),
              child: const Text('Next', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Step 6: Account Details ──────────────────────────────────────────────────
class _Step6 extends StatefulWidget {
  final RegisterData data;
  final VoidCallback onBack;

  const _Step6({required this.data, required this.onBack});

  @override
  State<_Step6> createState() => _Step6State();
}

class _Step6State extends State<_Step6> {
  final _usernameCtrl = TextEditingController();
  final _emailCtrl    = TextEditingController();
  final _passCtrl     = TextEditingController();
  final _confirmCtrl  = TextEditingController();
  bool _showPass      = false;
  bool _isLoading     = false;
  String? _error;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      _usernameCtrl.text.trim().isNotEmpty &&
      _emailCtrl.text.trim().isNotEmpty &&
      _passCtrl.text.length >= 6 &&
      _passCtrl.text == _confirmCtrl.text;

  Future<void> _submit() async {
    setState(() { _isLoading = true; _error = null; });

    final auth = context.read<AuthProvider>();
    final d    = widget.data;
    final dob  = '${d.year!}-${d.month!.toString().padLeft(2, '0')}-${d.day!.toString().padLeft(2, '0')}';

    final ok = await auth.registerWithProfile(
      username: _usernameCtrl.text.trim(),
      email:    _emailCtrl.text.trim(),
      password: _passCtrl.text,
      profileData: {
        'gender':                 d.gender,
        'date_of_birth':          dob,
        'weight_kg':              d.weightKg,
        'height_cm':              d.heightCm,
        'activity_level':         d.activityLevel,
        if (d.customExerciseCalories != null)
          'custom_exercise_calories': d.customExerciseCalories,
        'goal':                   d.goal,
        'target_weight_kg':       d.targetWeightKg,
        'goal_rate_kg_per_week':  d.goalRateKgPerWeek,
      },
    );

    if (!mounted) return;

    if (!ok) {
      setState(() { _isLoading = false; _error = auth.errorMessage ?? 'Registrasi gagal'; });
      return;
    }

    // Berhasil → kembali ke WelcomeScreen dengan snackbar
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const _RegisterSuccessScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RegisterHeader(currentStep: 6, totalSteps: 6, onBack: widget.onBack),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 28),
                const Text(
                  'Account Details',
                  style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Enter your username, email and password to\ncreate your Nutrishare account.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white60, fontSize: 13),
                ),
                const SizedBox(height: 24),

                // Form card
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF24472F),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Username'),
                      const SizedBox(height: 8),
                      _buildField(_usernameCtrl),
                      const SizedBox(height: 16),

                      _buildLabel('Email'),
                      const SizedBox(height: 8),
                      _buildField(_emailCtrl, keyboardType: TextInputType.emailAddress),
                      const SizedBox(height: 16),

                      _buildLabel('Password'),
                      const SizedBox(height: 8),
                      _buildField(_passCtrl, obscure: !_showPass),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Switch(
                            value: _showPass,
                            onChanged: (v) => setState(() => _showPass = v),
                            activeColor: _kGreen,
                            inactiveThumbColor: Colors.white,
                            inactiveTrackColor: Colors.white24,
                            trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () => setState(() => _showPass = !_showPass),
                            child: const Text('Show Password', style: TextStyle(color: Colors.white70, fontSize: 13)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      _buildLabel('Confirm Password'),
                      const SizedBox(height: 8),
                      _buildField(_confirmCtrl, obscure: !_showPass),
                    ],
                  ),
                ),

                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: const TextStyle(color: _kError, fontSize: 13)),
                ],
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (_canSubmit && !_isLoading) ? _submit : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _kGreen,
                foregroundColor: const Color(0xFF1A3528),
                disabledBackgroundColor: _kGreen.withValues(alpha: 0.35),
                padding: const EdgeInsets.symmetric(vertical: 17),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20, width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1A3528)),
                    )
                  : const Text('Next', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) => Text(
        text,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
      );

  Widget _buildField(
    TextEditingController ctrl, {
    bool obscure = false,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: ctrl,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.white38),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: _kGreen, width: 1.5),
        ),
      ),
    );
  }
}

// ─── Redirect screen setelah register berhasil ────────────────────────────────
class _RegisterSuccessScreen extends StatefulWidget {
  const _RegisterSuccessScreen();

  @override
  State<_RegisterSuccessScreen> createState() => _RegisterSuccessScreenState();
}

class _RegisterSuccessScreenState extends State<_RegisterSuccessScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Akun berhasil dibuat! Silakan login.'),
          backgroundColor: Color(0xFF24472F),
          duration: Duration(seconds: 3),
        ),
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF1A3528),
      body: Center(
        child: CircularProgressIndicator(color: Color(0xFFA8E040)),
      ),
    );
  }
}
