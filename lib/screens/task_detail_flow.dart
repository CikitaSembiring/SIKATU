import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart'; // PENTING: Untuk cek setting notifikasi
import 'package:sikatu/models/task_model.dart';
import 'package:sikatu/services/task_service.dart';
import 'package:sikatu/screens/all_task_screen.dart';

// ==========================================
// SCREEN 1: DETAIL TUGAS
// ==========================================
class TaskDetailScreen extends StatefulWidget {
  final TaskModel task;
  const TaskDetailScreen({super.key, required this.task});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late String currentDescription;

  @override
  void initState() {
    super.initState();
    currentDescription = widget.task.description;
  }

  @override
  Widget build(BuildContext context) {
    // --- LOGIKA DARK MODE ---
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF1F2937) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    // Warna kotak tetap hijau muda transparan (Pastel)
    final boxColor = const Color(0xFFCFF3CC).withOpacity(0.6);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: BackButton(color: textColor),
        actions: [
          // MENU EDIT / DELETE
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: textColor),
            color: isDark ? const Color(0xFF2C3E50) : Colors.white, // Background menu
            onSelected: (value) {
              if (value == 'edit') {
                _showEditDialog(context, isDark);
              } else if (value == 'delete') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ConfirmDeleteScreen(task: widget.task),
                  ),
                );
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 18, color: textColor),
                    const SizedBox(width: 8),
                    Text('Edit', style: TextStyle(color: textColor)),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 18, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Deadline
            Text(
              "Deadline: ${DateFormat('MMMM d, hh:mm a').format(widget.task.deadline)}",
              style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
            ),
            const SizedBox(height: 20),

            // Nama Mata Kuliah
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: boxColor,
                  borderRadius: BorderRadius.circular(15)
              ),
              // PENTING: Teks di dalam kotak hijau harus HITAM agar terbaca
              child: Text(
                widget.task.courseName,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
              ),
            ),
            const SizedBox(height: 20),

            // Deskripsi Tugas
            Container(
              width: double.infinity,
              height: 200,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: boxColor,
                  borderRadius: BorderRadius.circular(15)
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Description", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 10),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        currentDescription,
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50),

            // Tombol Mark as Complete
            Center(
              child: GestureDetector(
                onTap: () {
                  // Pindah ke Halaman Konfirmasi (Gambar 2)
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ConfirmCompleteScreen(task: widget.task))
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                  decoration: BoxDecoration(
                    color: const Color(0xFFA0C878).withOpacity(0.8),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Text(
                      "Mark as complete?",
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Dialog Edit Deskripsi
  void _showEditDialog(BuildContext context, bool isDark) {
    final TextEditingController descController = TextEditingController(text: currentDescription);
    final dialogBg = isDark ? const Color(0xFF2C3E50) : Colors.white;
    final dialogText = isDark ? Colors.white : Colors.black;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: dialogBg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text("Edit Description", style: TextStyle(fontWeight: FontWeight.bold, color: dialogText)),
          content: TextField(
            controller: descController,
            maxLines: 3,
            style: TextStyle(color: dialogText),
            decoration: InputDecoration(
              hintText: "Enter new description",
              hintStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey),
              border: const OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: isDark ? Colors.grey : Colors.black),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA0C878),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                await TaskService.updateTaskDescription(widget.task.id, descController.text);
                setState(() {
                  currentDescription = descController.text;
                });
                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text("Save", style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }
}

// ==========================================
// SCREEN 2: KONFIRMASI COMPLETE
// ==========================================
class ConfirmCompleteScreen extends StatelessWidget {
  final TaskModel task;
  const ConfirmCompleteScreen({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    // Logika Dark Mode
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF1F2937) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: BackButton(
          color: textColor,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Container(
          // Kotak Hijau Muda Besar
          width: 300,
          height: 300,
          decoration: BoxDecoration(
            color: const Color(0xFFCFF3CC).withOpacity(0.6),
            borderRadius: BorderRadius.circular(40),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // PERBAIKAN: Teks dipaksa HITAM agar terbaca di kotak hijau
              const Text(
                "Are you sure?",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: 100,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFA0C878),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 0,
                      ),
                      onPressed: () {
                        // Lanjut ke Halaman Done
                        Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => TaskCompletedScreen(task: task))
                        );
                      },
                      child: const Text("Yes", style: TextStyle(color: Colors.black)),
                    ),
                  ),
                  SizedBox(
                    width: 100,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFA0C878),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 0,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("No", style: TextStyle(color: Colors.black)),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// SCREEN 3: SUKSES / DONE
// ==========================================
class TaskCompletedScreen extends StatefulWidget {
  final TaskModel task;
  const TaskCompletedScreen({super.key, required this.task});

  @override
  State<TaskCompletedScreen> createState() => _TaskCompletedScreenState();
}

class _TaskCompletedScreenState extends State<TaskCompletedScreen> {
  @override
  Widget build(BuildContext context) {
    // Logika Dark Mode
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF1F2937) : Colors.white;
    final boxColor = const Color(0xFFCFF3CC).withOpacity(0.6);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: Container(), // Hilangkan tombol back agar user menekan Done
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Deadline: ${DateFormat('MMMM d, hh:mm a').format(widget.task.deadline)}",
              style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
            ),
            const SizedBox(height: 20),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: boxColor,
                  borderRadius: BorderRadius.circular(15)
              ),
              child: Text(
                widget.task.courseName,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
              ),
            ),
            const SizedBox(height: 20),

            Container(
              width: double.infinity,
              height: 200,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: boxColor,
                  borderRadius: BorderRadius.circular(15)
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Description", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 10),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(widget.task.description, style: const TextStyle(color: Colors.black87)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50),

            // TOMBOL DONE (DENGAN LOGIKA NOTIFIKASI DI ATAS)
            Center(
              child: GestureDetector(
                onTap: () async {
                  // 1. Update Database
                  await TaskService.updateTaskStatus(widget.task.id, widget.task.courseId, true);

                  // 2. CEK SETTING: Apakah User mengaktifkan notifikasi?
                  final prefs = await SharedPreferences.getInstance();
                  final bool showNotif = prefs.getBool('taskCompletion') ?? false;

                  // 3. Tampilkan Notifikasi jika aktif
                  if (showNotif && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: const [
                            Icon(Icons.check_circle, color: Colors.white),
                            SizedBox(width: 10),
                            Expanded(child: Text("Notification: Great Job! Task Completed.")),
                          ],
                        ),
                        backgroundColor: Colors.green,
                        duration: const Duration(seconds: 3),
                        behavior: SnackBarBehavior.floating,
                        // --- SETTING POSISI DI ATAS ---
                        margin: EdgeInsets.only(
                          bottom: MediaQuery.of(context).size.height - 150, // Dorong ke atas
                          left: 20,
                          right: 20,
                        ),
                      ),
                    );
                  }

                  // 4. Kembali ke Menu Utama
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const AllTaskScreen()),
                          (route) => route.isFirst,
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 80),
                  decoration: BoxDecoration(
                    color: const Color(0xFFA0C878).withOpacity(0.8),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Text(
                      "Done",
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 16)
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// SCREEN 4: KONFIRMASI DELETE
// ==========================================
class ConfirmDeleteScreen extends StatelessWidget {
  final TaskModel task;
  const ConfirmDeleteScreen({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF1F2937) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: BackButton(
          color: textColor,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Container(
          width: 300,
          height: 300,
          decoration: BoxDecoration(
            color: const Color(0xFFCFF3CC).withOpacity(0.6),
            borderRadius: BorderRadius.circular(40),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // PENTING: Teks dipaksa HITAM
              const Text(
                "Are you sure?",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // TOMBOL YES (DELETE)
                  SizedBox(
                    width: 100,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFA0C878),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 0,
                      ),
                      onPressed: () async {
                        // HAPUS TASK
                        await TaskService.deleteTask(task.id);

                        // Kembali ke halaman Dashboard/List (Tutup semua halaman detail)
                        if (context.mounted) {
                          Navigator.of(context).popUntil((route) => route.isFirst);
                        }
                      },
                      child: const Text("Yes", style: TextStyle(color: Colors.black)),
                    ),
                  ),
                  // TOMBOL NO
                  SizedBox(
                    width: 100,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFA0C878),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 0,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("No", style: TextStyle(color: Colors.black)),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}