// White Box Unit Tests — NutriShare Flutter
// Jalankan: flutter test

import 'package:flutter_test/flutter_test.dart';

// ── Unit konversi (dari add_food_sheet.dart) ──────────────────────────────────

const _unitToG = {'g': 1.0, 'tbsp': 15.0, 'tsp': 5.0, 'cup': 240.0};

double convertToGram(double qty, String unit) => qty * (_unitToG[unit] ?? 1.0);

// ── Kalori status (dari nutrition_provider.dart) ──────────────────────────────

String calorieStatus(double actual, double target) {
  if (target <= 0 || actual == 0) return 'START LOGGING TODAY';
  if (actual > target * 1.15) return 'TOO MUCH FOR TODAY';
  if (actual < target * 0.85) return 'BELOW TARGET TODAY';
  return 'ON TRACK TODAY';
}

// ── Date label (dari diary_screen.dart) ───────────────────────────────────────

String dateLabel(DateTime d) {
  final today = DateTime.now();
  final yesterday = today.subtract(const Duration(days: 1));
  if (d.year == today.year && d.month == today.month && d.day == today.day) {
    return 'Today';
  }
  if (d.year == yesterday.year && d.month == yesterday.month && d.day == yesterday.day) {
    return 'Yesterday';
  }
  const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
  return '${d.day} ${months[d.month - 1]} ${d.year}';
}

// ─────────────────────────────────────────────────────────────────────────────

void main() {
  group('Unit Konversi', () {
    test('gram ke gram tidak berubah', () {
      expect(convertToGram(100, 'g'), equals(100.0));
    });

    test('1 tbsp = 15g', () {
      expect(convertToGram(1, 'tbsp'), equals(15.0));
    });

    test('1 tsp = 5g', () {
      expect(convertToGram(1, 'tsp'), equals(5.0));
    });

    test('1 cup = 240g', () {
      expect(convertToGram(1, 'cup'), equals(240.0));
    });

    test('2 tbsp = 30g', () {
      expect(convertToGram(2, 'tbsp'), equals(30.0));
    });
  });

  group('Kalori Status', () {
    test('actual 0 → START LOGGING TODAY', () {
      expect(calorieStatus(0, 2000), equals('START LOGGING TODAY'));
    });

    test('target 0 → START LOGGING TODAY', () {
      expect(calorieStatus(1500, 0), equals('START LOGGING TODAY'));
    });

    test('actual > 115% target → TOO MUCH FOR TODAY', () {
      expect(calorieStatus(2400, 2000), equals('TOO MUCH FOR TODAY'));
    });

    test('actual < 85% target → BELOW TARGET TODAY', () {
      expect(calorieStatus(1600, 2000), equals('BELOW TARGET TODAY'));
    });

    test('actual dalam range 85–115% → ON TRACK TODAY', () {
      expect(calorieStatus(2000, 2000), equals('ON TRACK TODAY'));
      expect(calorieStatus(1800, 2000), equals('ON TRACK TODAY'));
      expect(calorieStatus(2200, 2000), equals('ON TRACK TODAY'));
    });

    test('tepat di atas batas 115% → TOO MUCH', () {
      expect(calorieStatus(2301, 2000), equals('TOO MUCH FOR TODAY'));
    });

    test('tepat di batas 85% → BELOW TARGET', () {
      expect(calorieStatus(1699, 2000), equals('BELOW TARGET TODAY'));
    });
  });

  group('Date Label', () {
    test('hari ini → Today', () {
      final today = DateTime.now();
      expect(dateLabel(today), equals('Today'));
    });

    test('kemarin → Yesterday', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      expect(dateLabel(yesterday), equals('Yesterday'));
    });

    test('tanggal lain → format D MMM YYYY', () {
      final d = DateTime(2025, 3, 5);
      expect(dateLabel(d), equals('5 Mar 2025'));
    });

    test('1 Januari → format benar', () {
      final d = DateTime(2024, 1, 1);
      expect(dateLabel(d), equals('1 Jan 2024'));
    });
  });
}
