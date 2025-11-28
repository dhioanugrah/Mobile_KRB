import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

enum AppTab { home, found, add, library, profile }


class AppBottomNavBar extends StatelessWidget {
  final AppTab currentTab;

  const AppBottomNavBar({
    super.key,
    required this.currentTab,
  });

    void _onTap(BuildContext context, AppTab tab) {
      switch (tab) {
        case AppTab.home:
          context.go('/home');
          break;
        case AppTab.found:
          context.go('/found');      // halaman flora ditemukan (nanti kita buat)
          break;
        case AppTab.add:
          // buka form tambah moment / note
          context.go('/moments/add'); // route form add, nanti kita buat
          break;
        case AppTab.library:
          context.go('/moments');    // list semua note/moment
          break;
        case AppTab.profile:
          // nanti ke /profile kalau sudah ada
          break;
      }
    }


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              blurRadius: 16,
              offset: const Offset(0, 8),
              color: Colors.black.withOpacity(0.08),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavIcon(
              icon: Icons.home_rounded,
              isActive: currentTab == AppTab.home,
              onTap: () => _onTap(context, AppTab.home),
            ),
            _NavIcon(
              icon: Icons.map_outlined,          // nanti bisa kamu ganti icon lain kalau mau
              isActive: currentTab == AppTab.found,
              onTap: () => _onTap(context, AppTab.found),
            ),
            _NavIcon(
              icon: Icons.add_circle_rounded,
              isHighlighted: true,
              onTap: () => _onTap(context, AppTab.add),
            ),
            _NavIcon(
              icon: Icons.menu_book_outlined,
              isActive: currentTab == AppTab.library,
              onTap: () => _onTap(context, AppTab.library),
            ),
            _NavIcon(
              icon: Icons.person_outline_rounded,
              isActive: currentTab == AppTab.profile,
              onTap: () => _onTap(context, AppTab.profile),
            ),

          ],
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final bool isHighlighted;
  final VoidCallback onTap;

  const _NavIcon({
    required this.icon,
    required this.onTap,
    this.isActive = false,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isHighlighted
        ? Colors.green.shade600
        : (isActive ? Colors.green.shade700 : Colors.grey.shade500);

    return InkWell(
      borderRadius: BorderRadius.circular(32),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(
          icon,
          size: isHighlighted ? 32 : 26,
          color: color,
        ),
      ),
    );
  }
}
