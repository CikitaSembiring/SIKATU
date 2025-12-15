import 'package:flutter/material.dart';
import 'package:sikatu/models/task_model.dart';
import 'package:sikatu/services/task_service.dart';
import 'package:sikatu/screens/task_detail_flow.dart';

enum TaskFilterType { complete, inProgress, urgent }

class FilteredTaskScreen extends StatelessWidget {
  final String title;
  final TaskFilterType filterType;
  final IconData icon;

  const FilteredTaskScreen({
    super.key,
    required this.title,
    required this.filterType,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    // --- LOGIKA DARK MODE ---
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Warna Background: Putih (Light) vs Gelap (Dark)
    final backgroundColor = isDark ? const Color(0xFF1F2937) : Colors.white;

    // Warna Teks Header: Hitam (Light) vs Putih (Dark)
    final headerTextColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: backgroundColor, // Background dinamis
      appBar: AppBar(
        backgroundColor: backgroundColor, // AppBar mengikuti background
        elevation: 0,
        leading: BackButton(color: headerTextColor), // Icon back menyesuaikan
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: headerTextColor, size: 24),
            const SizedBox(width: 10),
            Text(
              title,
              style: TextStyle(color: headerTextColor, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: StreamBuilder<List<TaskModel>>(
        stream: TaskService.getUserTasks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final allTasks = snapshot.data ?? [];
          List<TaskModel> filteredTasks = [];

          // Logika Filter
          switch (filterType) {
            case TaskFilterType.complete:
              filteredTasks = allTasks.where((t) => t.isCompleted).toList();
              break;
            case TaskFilterType.inProgress:
              filteredTasks = allTasks.where((t) => !t.isCompleted).toList();
              break;
            case TaskFilterType.urgent:
              final now = DateTime.now();
              filteredTasks = allTasks.where((t) {
                final isNearDeadline = t.deadline.difference(now).inDays <= 2 &&
                    t.deadline.isAfter(now.subtract(const Duration(days: 1)));
                return !t.isCompleted && (t.priority == 'High' || isNearDeadline);
              }).toList();
              break;
          }

          if (filteredTasks.isEmpty) {
            // Teks kosong menyesuaikan mode gelap
            return Center(
                child: Text(
                    "No $title tasks found.",
                    style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey)
                )
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: filteredTasks.length,
            itemBuilder: (context, index) {
              final task = filteredTasks[index];

              // Warna Kartu (Pastel) - Tetap terang agar konsisten
              final Color boxColor = index % 2 == 0
                  ? const Color(0xFFFFEE93).withOpacity(0.6)
                  : const Color(0xFFADF7B6).withOpacity(0.6);

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TaskDetailScreen(task: task),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: boxColor,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              task.courseName,
                              // PENTING: Teks di dalam kartu pastel harus HITAM agar terbaca
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        task.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        // PENTING: Teks deskripsi juga HITAM
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}