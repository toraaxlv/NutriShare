import 'package:flutter/material.dart';

const _kGreen = Color(0xFFA8E040);

/// Logo NutriShare reusable.
/// [compact] = header register (lebih kecil)
/// default   = welcome screen (lebih besar)
class NutriShareLogo extends StatelessWidget {
  final bool compact;

  const NutriShareLogo({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/LogoNutrishare.png',
      height: compact ? 32.0 : 180.0,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => Text(
        'NutriShare.',
        style: TextStyle(
          color: _kGreen,
          fontSize: compact ? 18 : 34,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
