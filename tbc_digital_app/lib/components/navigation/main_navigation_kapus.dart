import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class MainNavigationKapus extends StatefulWidget {
  final List<Widget> screens;

  const MainNavigationKapus({super.key, required this.screens});

  static MainNavigationKapusState? of(BuildContext context) =>
      context.findAncestorStateOfType<MainNavigationKapusState>();

  @override
  State<MainNavigationKapus> createState() => MainNavigationKapusState();
}

class MainNavigationKapusState extends State<MainNavigationKapus> {
  int index = 0;

  void changeTab(int i) {
    setState(() => index = i);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,

      /// ================= SCREEN =================
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: widget.screens[index],
      ),

      /// ================= MODERN BOTTOM NAV =================
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),

          child: NavigationBarTheme(
            data: NavigationBarThemeData(
              indicatorColor: AppColors.primary,
              labelTextStyle: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: AppColors.primary,
                  );
                }
                return const TextStyle(fontSize: 12, color: AppColors.textSecondary);
              }),
            ),

            child: NavigationBar(
              height: 70,
              backgroundColor: Colors.transparent,
              selectedIndex: index,
              onDestinationSelected: changeTab,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,

              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: "Home",
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person),
                  label: "Profil",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

