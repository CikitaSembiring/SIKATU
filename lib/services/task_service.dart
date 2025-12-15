import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sikatu/models/task_model.dart';
import 'package:sikatu/services/course_service.dart'; // Import CourseService

class TaskService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // 1. Tambah Task & Update Course
  static Future<void> addTask(TaskModel task) async {
    // Simpan Task ke Firestore
    await _db.collection('tasks').add(task.toMap());

    // Update Jumlah Task di Course (Agar halaman Course terupdate otomatis)
    if (task.courseId.isNotEmpty) {
      await CourseService.incrementTaskCount(task.courseId);
    }
  }

  // 2. Update Status & Update Course
  static Future<void> updateTaskStatus(String taskId, String courseId, bool isCompleted) async {
    // Update Status Task
    await _db.collection('tasks').doc(taskId).update({'isCompleted': isCompleted});

    // Update Jumlah Finished di Course
    if (courseId.isNotEmpty) {
      await CourseService.updateFinishedCount(courseId, isCompleted);
    }
  }

  // --- [BARU] 3. Update Deskripsi Task (Fitur Edit) ---
  static Future<void> updateTaskDescription(String taskId, String newDescription) async {
    await _db.collection('tasks').doc(taskId).update({
      'description': newDescription,
    });
  }

  // --- [BARU] 4. Hapus Task (Fitur Delete) ---
  static Future<void> deleteTask(String taskId) async {
    // Kita ambil snapshot dulu untuk mendapatkan courseId (Opsional, untuk kerapihan data Course)
    // Jika tidak perlu update counter di Course, baris fetch & if di bawah bisa dihapus.
    try {
      final docSnapshot = await _db.collection('tasks').doc(taskId).get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        final courseId = data?['courseId'] as String?;
        final isCompleted = data?['isCompleted'] as bool? ?? false;

        // Hapus Dokumen Task
        await _db.collection('tasks').doc(taskId).delete();

        // (Opsional) Kurangi counter di CourseService jika kamu punya method decrement
        // Ini memastikan jumlah tugas di menu Course berkurang saat tugas dihapus
        if (courseId != null && courseId.isNotEmpty) {
          // Asumsi: Kamu perlu menambahkan method decrementTaskCount di CourseService nanti
          // Jika belum ada, biarkan baris ini dikomentari atau buat methodnya di CourseService
          // await CourseService.decrementTaskCount(courseId, isCompleted);
        }
      }
    } catch (e) {
      print("Error deleting task: $e");
      rethrow;
    }
  }

  // 5. Get User Tasks (Stream)
  static Stream<List<TaskModel>> getUserTasks() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _db
        .collection('tasks')
        .where('userId', isEqualTo: user.uid)
        .orderBy('deadline')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => TaskModel.fromMap(doc.id, doc.data())).toList());
  }
}