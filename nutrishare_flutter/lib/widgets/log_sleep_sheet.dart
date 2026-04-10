import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/nutrition_provider.dart';

const _kBg    = Color(0xFF1A3528);
const _kCard  = Color(0xFF243D2F);
const _kGreen = Color(0xFFA8E040);
const _kDim   = Color(0xFF6B9080);
const _kLine  = Color(0xFF2B4A38);

class LogSleepSheet extends StatefulWidget {
  final DateTime date;
  final VoidCallback? onSaved;

  const LogSleepSheet({super.key, required this.date, this.onSaved});

  static void show(BuildContext context, {required DateTime date, VoidCallback? onSaved}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LogSleepSheet(date: date, onSaved: onSaved),
    );
  }

  @override
  State<LogSleepSheet> createState() => _LogSleepSheetState();
}

class _LogSleepSheetState extends State<LogSleepSheet> {
  TimeOfDay _bedTime  = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _wakeTime = const TimeOfDay(hour: 6,  minute: 0);
  bool _isSaving = false;

  double get _durationHours {
    final bedMinutes  = _bedTime.hour * 60 + _bedTime.minute;
    var   wakeMinutes = _wakeTime.hour * 60 + _wakeTime.minute;
    if (wakeMinutes <= bedMinutes) wakeMinutes += 24 * 60;
    return (wakeMinutes - bedMinutes) / 60.0;
  }

  static String _fmtTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  static TimeOfDay _parseTime(String s) {
    final parts = s.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  @override
  void initState() {
    super.initState();
    // Isi dari data yang sudah ada di provider
    final existing = context.read<NutritionProvider>().sleepData;
    if (existing != null) {
      setState(() {
        _bedTime  = _parseTime(existing['bed_time']  as String? ?? '22:00');
        _wakeTime = _parseTime(existing['wake_time'] as String? ?? '06:00');
      });
    }
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    await context.read<NutritionProvider>().saveSleep(
      widget.date,
      bedTime:       _fmtTime(_bedTime),
      wakeTime:      _fmtTime(_wakeTime),
      durationHours: _durationHours,
    );
    if (mounted) {
      setState(() => _isSaving = false);
      widget.onSaved?.call();
      Navigator.pop(context);
    }
  }

  Future<void> _pickTime(bool isBed) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isBed ? _bedTime : _wakeTime,
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(primary: Color(0xFFA8E040)),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() { if (isBed) _bedTime = picked; else _wakeTime = picked; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final hours = _durationHours;
    final hh    = hours.floor();
    final mm    = ((hours - hh) * 60).round();

    return Container(
      decoration: const BoxDecoration(
        color: _kBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: _kLine, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          const Text('Log Sleep', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _TimePicker(label: 'Tidur', time: _bedTime, onTap: () => _pickTime(true))),
              const SizedBox(width: 16),
              Expanded(child: _TimePicker(label: 'Bangun', time: _wakeTime, onTap: () => _pickTime(false))),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: _kCard, borderRadius: BorderRadius.circular(14)),
            child: Column(
              children: [
                const Icon(Icons.nightlight_round, color: Color(0xFF5B8DEF), size: 32),
                const SizedBox(height: 8),
                Text(
                  '${hh}j ${mm}m',
                  style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const Text('Durasi Tidur', style: TextStyle(color: _kDim, fontSize: 12)),
              ],
            ),
          ),
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
    );
  }
}

class _TimePicker extends StatelessWidget {
  final String label;
  final TimeOfDay time;
  final VoidCallback onTap;

  const _TimePicker({required this.label, required this.time, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: _kCard, borderRadius: BorderRadius.circular(14)),
        child: Column(
          children: [
            Text(label, style: const TextStyle(color: _kDim, fontSize: 12)),
            const SizedBox(height: 8),
            Text('$h:$m', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('Tap untuk ubah', style: TextStyle(color: _kDim, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}
