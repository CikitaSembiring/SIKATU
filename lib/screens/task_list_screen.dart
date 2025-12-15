import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:sikatu/models/task_model.dart';
import 'package:sikatu/services/task_service.dart';
import 'package:sikatu/theme/app_colors.dart';
import 'package:sikatu/screens/task_detail_flow.dart';
import 'package:sikatu/screens/all_task_screen.dart';
import 'package:sikatu/screens/create_task_screen.dart';

class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userName = user?.displayName ?? 'User';

    // Deteksi Tema
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1F2937) : Colors.white;
    final textColor = isDark ? Colors.white : AppColors.darkText;
    final cardColor = isDark ? const Color(0xFF2C3E50) : const Color(0xFFDDEB9D).withOpacity(0.6);

    final dateFormatter = DateFormat('yyyy-MM-dd');
    final DateTime now = DateTime.now();
    final String todayStr = dateFormatter.format(now);
    final String tomorrowStr = dateFormatter.format(now.add(const Duration(days: 1)));

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: BackButton(color: isDark ? Colors.white : Colors.black),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: CircleAvatar(
              backgroundColor: Colors.grey.shade200,
              child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateTaskScreen()));
        },
        backgroundColor: AppColors.primary,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
      body: StreamBuilder<List<TaskModel>>(
        stream: TaskService.getUserTasks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

          final allTasks = snapshot.data ?? [];
          final todayTasks = allTasks.where((t) => dateFormatter.format(t.deadline) == todayStr).toList();
          final tomorrowTasks = allTasks.where((t) => dateFormatter.format(t.deadline) == tomorrowStr).toList();

          final int totalToday = todayTasks.length;
          final int completedToday = todayTasks.where((t) => t.isCompleted).length;
          final int pendingToday = totalToday - completedToday;

          double progressValue = totalToday > 0 ? completedToday / totalToday : 0.0;
          int progressPercent = (progressValue * 100).toInt();

          String headerText = (totalToday == 0) ? "You have no tasks\nto complete today"
              : (pendingToday == 0) ? "Great job! You finished\nall tasks for today"
              : "You have got $pendingToday tasks\ntoday to complete";

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    headerText,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor),
                  ),
                ),
                const SizedBox(height: 25),
                TextField(
                  style: TextStyle(color: Colors.black), // Text Input Hitam
                  decoration: InputDecoration(
                    hintText: 'Search Task Here',
                    hintStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                    filled: true,
                    fillColor: AppColors.fieldBgColor, // Tetap terang agar teks hitam terbaca
                  ),
                ),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Progress", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                    TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AllTaskScreen())), child: const Text("See All", style: TextStyle(color: AppColors.primary)))
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: AppColors.taskProgressCard, borderRadius: BorderRadius.circular(20)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Daily Task", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black)), // Teks hitam di kartu hijau
                      const SizedBox(height: 5),
                      Text("$completedToday/$totalToday Task Completed", style: const TextStyle(color: Colors.black87)),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("You are almost done go ahead", style: TextStyle(fontSize: 12, color: Colors.black87)),
                          Text("$progressPercent%", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: progressValue, backgroundColor: Colors.white.withOpacity(0.5), color: AppColors.primary, minHeight: 10)),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                Text("Today's Task", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                const SizedBox(height: 15),
                if (todayTasks.isEmpty) Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: Text("No tasks for today.", style: TextStyle(color: textColor))),
                ...todayTasks.map((task) => _buildTaskTile(context, task, cardColor, textColor)).toList(),
                const SizedBox(height: 25),
                Text("Tomorrow Task", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                const SizedBox(height: 15),
                if (tomorrowTasks.isEmpty) Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: Text("No tasks for tomorrow.", style: TextStyle(color: textColor))),
                ...tomorrowTasks.map((task) => _buildTaskTile(context, task, cardColor, textColor)).toList(),
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTaskTile(BuildContext context, TaskModel task, Color bgColor, Color textColor) {
    // Teks dalam kartu pastel harus hitam agar kontras (jika mode terang), atau putih jika mode gelap (kartu gelap)
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tileTextColor = isDark ? Colors.white : Colors.black87;

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => TaskDetailScreen(task: task))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(15)),
        child: Row(
          children: [
            Container(width: 5, height: 40, decoration: BoxDecoration(color: const Color(0xFF318C2A), borderRadius: BorderRadius.circular(10))),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(task.description.isNotEmpty ? task.description : task.courseName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: tileTextColor), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 5),
                  Row(children: [const Icon(Icons.calendar_today, size: 14, color: Colors.grey), const SizedBox(width: 5), Text(DateFormat('d MMM').format(task.deadline), style: const TextStyle(fontSize: 12, color: Colors.grey)), if (task.endTime.isNotEmpty) ...[const SizedBox(width: 10), const Icon(Icons.access_time, size: 14, color: Colors.grey), const SizedBox(width: 5), Text(task.endTime, style: const TextStyle(fontSize: 12, color: Colors.grey))]]),
                ],
              ),
            ),
            Container(width: 26, height: 26, decoration: BoxDecoration(shape: BoxShape.circle, color: task.isCompleted ? Colors.black : Colors.transparent, border: Border.all(color: task.isCompleted ? Colors.black : AppColors.primary, width: 2)), child: task.isCompleted ? const Icon(Icons.check, color: Colors.white, size: 16) : null)
          ],
        ),
      ),
    );
  }
}