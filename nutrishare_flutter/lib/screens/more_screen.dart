import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/nutrition_provider.dart';
import 'edit_profile_screen.dart';
// EditTargetScreen is defined in the same file as EditProfileScreen

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('More', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                  Text(user?.email ?? '(yourname)@gmail.com', style: const TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Row(
                      children: [
                        Expanded(
                          child: TextField(
                            style: TextStyle(color: Colors.white70, fontSize: 14),
                            decoration: InputDecoration(
                              hintText: 'Value',
                              hintStyle: TextStyle(color: Colors.white30),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                          ),
                        ),
                        Icon(Icons.search, color: Colors.white54, size: 20),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            _MenuItem(
              icon: Icons.alternate_email,
              title: 'Account',
              subtitle: 'edit or change your information',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              ),
            ),
            const Divider(color: _kDivider, height: 1, indent: 16, endIndent: 16),
            _MenuItem(
              icon: Icons.person_outline,
              title: 'Profile',
              subtitle: 'change your description',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              ),
            ),
            const Divider(color: _kDivider, height: 1, indent: 16, endIndent: 16),
            _MenuItem(
              icon: Icons.track_changes,
              title: 'Target',
              subtitle: 'change your recent targets',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditTargetScreen()),
              ),
            ),
            const SizedBox(height: 16),
            if (calories != null)
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
                          _TargetChip(label: 'Calories', value: '$calories kkal'),
                          _TargetChip(label: 'Protein',  value: '${proteinG ?? '-'}g'),
                          _TargetChip(label: 'Carbs',    value: '${carbsG ?? '-'}g'),
                          _TargetChip(label: 'Fat',      value: '${fatG ?? '-'}g'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            const Spacer(),
            Center(
              child: TextButton(
                onPressed: () => _logout(context),
                child: const Text('Log out', style: TextStyle(color: Colors.redAccent)),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

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
            Icon(icon, color: _kGreen, size: 28),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: _kDim, fontSize: 12)),
              ],
            ),
            const Spacer(),
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
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: _kDim, fontSize: 11)),
      ],
    );
  }
}
