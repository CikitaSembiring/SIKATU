import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:sikatu/models/task_model.dart';
import 'package:sikatu/services/task_service.dart';
import 'package:sikatu/screens/profile_screen.dart';
import 'package:sikatu/screens/task_list_screen.dart';
import 'package:sikatu/screens/all_task_screen.dart';
import 'package:sikatu/screens/filtered_task_screen.dart';
import 'package:sikatu/screens/calendar_screen.dart';
import 'package:sikatu/screens/course_screen.dart';
import 'package:sikatu/screens/settings_screen.dart';
import 'package:sikatu/theme/app_colors.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final userName = currentUser?.displayName ?? 'User';

    // Cek Tema Gelap/Terang
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? Colors.white : Colors.black;
    final Color subTextColor = isDark ? Colors.grey[400]! : Colors.grey;
    final Color cardBgColor = isDark ? const Color(0xFF2C3E50) : const Color(0xFFF9F9F9);

    final Color iconBoxColor = const Color(0xFFFFEC5F);
    final Color numberCircleColor = const Color(0xFFA0C878);

    return Scaffold(
      // Background otomatis mengikuti main.dart (Putih/Gelap)
      appBar: AppBar(
        // AppBar Theme otomatis mengikuti main.dart
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: textColor, size: 30),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Column(
          children: [
            Text('Hello', style: TextStyle(color: subTextColor, fontSize: 14)),
            Text(userName, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen())),
              child: CircleAvatar(
                backgroundColor: Colors.grey.shade200,
                child: Text(userName.isNotEmpty ? userName[0].toUpperCase() : "U", style: const TextStyle(color: Colors.black)),
              ),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            SizedBox(
              height: 120,
              child: DrawerHeader(
                decoration: const BoxDecoration(
                  color: Color(0xFFADF7B6),
                ),
                margin: EdgeInsets.zero,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Menu SIKATU',
                    style: TextStyle(
                      color: Colors.white, // Text header tetap putih agar kontras dengan hijau
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            // Menu Items dengan warna dinamis
            _buildDrawerItem(context, Icons.calendar_today_outlined, 'Calendar', const CalendarScreen()),
            _buildDrawerItem(context, Icons.check_circle_outline, 'Task', const TaskListScreen()),
            _buildDrawerItem(context, Icons.school_outlined, 'Courses', const CourseScreen()),
            _buildDrawerItem(context, Icons.settings_outlined, 'Setting', const SettingsScreen()),
          ],
        ),
      ),
      body: StreamBuilder<List<TaskModel>>(
        stream: TaskService.getUserTasks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final tasks = snapshot.data ?? [];
          final int totalTasks = tasks.length;
          final int completedTasks = tasks.where((t) => t.isCompleted).length;
          final int inProgressTasks = totalTasks - completedTasks;
          final now = DateTime.now();
          final int urgentTasks = tasks.where((t) {
            final isNearDeadline = t.deadline.difference(now).inDays <= 2 && t.deadline.isAfter(now.subtract(const Duration(days: 1)));
            return !t.isCompleted && (t.priority == 'High' || isNearDeadline);
          }).length;

          double progressValue = 0.0;
          if (totalTasks > 0) progressValue = completedTasks / totalTasks;
          int progressPercent = (progressValue * 100).toInt();

          final todayTasks = tasks.where((t) =>
          DateFormat('yyyy-MM-dd').format(t.deadline) == DateFormat('yyyy-MM-dd').format(now)
          ).toList();

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: TextStyle(fontSize: 26, color: textColor, fontWeight: FontWeight.w500),
                      children: const <TextSpan>[
                        TextSpan(text: 'Welcome to\n'),
                        TextSpan(text: 'SIKATU!', style: TextStyle(color: Color(0xFFA0C878), fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),

                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 1.4,
                    children: [
                      _buildDashboardCard(context, 'All Task', totalTasks, Icons.assignment_outlined, iconBoxColor, numberCircleColor, cardBgColor, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AllTaskScreen()))),
                      _buildDashboardCard(context, 'Complete', completedTasks, Icons.check_circle_outline, iconBoxColor, numberCircleColor, cardBgColor, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FilteredTaskScreen(title: 'Complete', filterType: TaskFilterType.complete, icon: Icons.check_circle_outline)))),
                      _buildDashboardCard(context, 'In Progress', inProgressTasks, Icons.trending_up, iconBoxColor, numberCircleColor, cardBgColor, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FilteredTaskScreen(title: 'In Progress', filterType: TaskFilterType.inProgress, icon: Icons.trending_up)))),
                      _buildDashboardCard(context, 'Urgent', urgentTasks, Icons.shield_outlined, iconBoxColor, numberCircleColor, cardBgColor, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FilteredTaskScreen(title: 'Urgent', filterType: TaskFilterType.urgent, icon: Icons.shield_outlined)))),
                    ],
                  ),
                  const SizedBox(height: 30),

                  Text('Overall Progress', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: totalTasks == 0 ? 0 : progressValue,
                            backgroundColor: isDark ? Colors.grey[700] : Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                progressValue > 0 ? const Color(0xFFA0C878) : Colors.transparent
                            ),
                            minHeight: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Text('$progressPercent%', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
                    ],
                  ),
                  const SizedBox(height: 30),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Today's Task", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TaskListScreen())),
                        child: const Text('See all >', style: TextStyle(fontSize: 14, color: Colors.blue, fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  if (todayTasks.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text("No tasks for today.", style: TextStyle(color: subTextColor)),
                    ),

                  ...todayTasks.map((t) => Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEE93).withOpacity(0.6), // Tetap Pastel
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 4, height: 25,
                          decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(10)),
                        ),
                        const SizedBox(width: 10),
                        // Text di dalam kartu pastel sebaiknya tetap hitam agar terbaca jelas
                        Expanded(child: Text(t.description, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black87))),
                      ],
                    ),
                  )).toList(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, IconData icon, String title, Widget page) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      leading: Icon(icon, color: isDark ? Colors.white70 : Colors.black87),
      title: Text(title, style: TextStyle(fontSize: 16, color: isDark ? Colors.white : Colors.black)),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
      },
    );
  }

  Widget _buildDashboardCard(BuildContext context, String title, int count, IconData icon, Color iconBoxColor, Color numberCircleColor, Color bgColor, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isDark ? Colors.transparent : Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconBoxColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.black, size: 24),
                ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: numberCircleColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text("$count", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                ),
              ],
            ),
            Text(
              title,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87
              ),
            )
          ],
        ),
      ),
    );
  }
}