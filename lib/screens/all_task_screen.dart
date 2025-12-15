import 'package:flutter/material.dart';
import 'package:sikatu/models/task_model.dart';
import 'package:sikatu/services/task_service.dart';
import 'package:sikatu/screens/task_detail_flow.dart';
import 'package:intl/intl.dart';

class AllTaskScreen extends StatelessWidget {
  const AllTaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      // Background auto dari main.dart
      appBar: AppBar(
        leading: BackButton(color: textColor),
        centerTitle: true,
        title: Text(
          "All Task",
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<List<TaskModel>>(
        stream: TaskService.getUserTasks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final tasks = snapshot.data ?? [];

          if (tasks.isEmpty) {
            return Center(child: Text("No tasks found.", style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey)));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              // Kartu pastel tetap terang agar teks hitam terbaca
              final Color boxColor = index % 2 == 0
                  ? const Color(0xFFFFEE93).withOpacity(0.6)
                  : const Color(0xFFADF7B6).withOpacity(0.6);

              return GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => TaskDetailScreen(task: task)));
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
                      Text(
                        task.courseName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87), // Teks hitam di atas pastel
                      ),
                      const SizedBox(height: 5),
                      Text(
                        task.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.black87),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Deadline: ${DateFormat('dd MMM yyyy').format(task.deadline)}",
                            style: TextStyle(fontSize: 12, color: Colors.grey[800]),
                          ),
                          Text(
                            task.isCompleted ? "Done" : "Active",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: task.isCompleted ? Colors.green[900] : Colors.red[900], // Gelapkan dikit biar kontras
                            ),
                          ),
                        ],
                      )
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