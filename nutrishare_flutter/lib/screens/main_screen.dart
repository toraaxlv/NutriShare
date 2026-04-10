import 'package:flutter/material.dart';
import 'discover_screen.dart';
import 'diary_screen.dart';
import 'foods_screen.dart';
import 'more_screen.dart';
import 'quick_add_sheet.dart';

const _kBg      = Color(0xFF1A3528);
const _kNavBg   = Color(0xFF163022);
const _kGreen   = Color(0xFFA8E040);
const _kOrange  = Color(0xFFF09038);
const _kUnsel   = Color(0xFF4A7060);

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  void _onTap(int index) {
    if (index == 2) {
      QuickAddSheet.show(context);
      return;
    }
    final newIndex = index < 2 ? index : index - 1;
    setState(() => _currentIndex = newIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          DiscoverScreen(),
          DiaryScreen(),
          FoodsScreen(),
          MoreScreen(),
        ],
      ),
      bottomNavigationBar: _buildNavBar(),
    );
  }

  Widget _buildNavBar() {
    return Container(
      decoration: const BoxDecoration(
        color: _kNavBg,
        border: Border(top: BorderSide(color: Color(0xFF2B5040), width: 1)),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              _navItem(0, Icons.home_rounded, 'Home'),
              _navItem(1, Icons.book_rounded, 'Diary'),
              _centerButton(),
              _navItem(3, Icons.restaurant_menu_rounded, 'Foods'),
              _navItem(4, Icons.more_horiz_rounded, 'More'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    final screenIndex = index < 2 ? index : index - 1;
    final selected = _currentIndex == screenIndex;
    final color = selected ? _kGreen : _kUnsel;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _onTap(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _centerButton() {
    return Expanded(
      child: GestureDetector(
        onTap: () => _onTap(2),
        child: Center(
          child: Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              color: _kOrange,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 28),
          ),
        ),
      ),
    );
  }
}
