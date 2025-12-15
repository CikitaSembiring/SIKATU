import 'package:flutter/material.dart';
import 'package:sikatu/screens/dashboard_screen.dart';
import 'package:sikatu/screens/calendar_screen.dart';
import 'package:sikatu/screens/create_task_screen.dart';
import 'package:sikatu/screens/course_screen.dart';
import 'package:sikatu/screens/settings_screen.dart';
import 'package:sikatu/theme/app_colors.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _screens = <Widget>[
    const DashboardScreen(),      // Index 0
    const CalendarScreen(),       // Index 1
    const SizedBox(),             // Index 2 (Placeholder tombol +)
    const CourseScreen(),         // Index 3
    const SettingsScreen(),       // Index 4
  ];

  void _onItemTapped(int index) {
    if (index == 2) {
      Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CreateTaskScreen())
      );
      return;
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // --- LOGIKA DARK MODE ---
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Warna Navbar: Putih (Light) atau Biru Abu Gelap (Dark)
    final navbarColor = isDark ? const Color(0xFF2C3E50) : Colors.white;

    // Warna Background Scaffold
    final scaffoldBg = isDark ? const Color(0xFF1F2937) : Colors.white;

    // Warna Icon
    final activeColor = const Color(0xFFA0C878); // Hijau SIKATU
    final inactiveColor = isDark ? Colors.grey[400] : const Color(0xFFBDBDBD);

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: _screens.elementAt(_selectedIndex),

      floatingActionButton: FloatingActionButton(
        onPressed: () => _onItemTapped(2),
        backgroundColor: activeColor,
        elevation: 4.0,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: navbarColor, // <--- BERUBAH SESUAI TEMA
        elevation: 10, // Tambahkan elevasi agar terlihat batasnya di dark mode
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              // --- KIRI ---
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MaterialButton(
                    minWidth: 40,
                    onPressed: () => _onItemTapped(0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.home_rounded,
                          color: _selectedIndex == 0 ? activeColor : inactiveColor,
                          size: 28,
                        ),
                      ],
                    ),
                  ),
                  MaterialButton(
                    minWidth: 40,
                    onPressed: () => _onItemTapped(1),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          color: _selectedIndex == 1 ? activeColor : inactiveColor,
                          size: 26,
                        ),
                      ],
                    ),
                  )
                ],
              ),

              // --- KANAN ---
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MaterialButton(
                    minWidth: 40,
                    onPressed: () => _onItemTapped(3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.menu_book_rounded,
                          color: _selectedIndex == 3 ? activeColor : inactiveColor,
                          size: 26,
                        ),
                      ],
                    ),
                  ),
                  MaterialButton(
                    minWidth: 40,
                    onPressed: () => _onItemTapped(4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.settings_rounded,
                          color: _selectedIndex == 4 ? activeColor : inactiveColor,
                          size: 26,
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}