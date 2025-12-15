import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sikatu/models/course_model.dart';

class CourseService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<void> addCourse(Course course) async {
    await _db.collection('courses').add(course.toMap());
  }

  // --- UPDATE JUMLAH TUGAS ---
  static Future<void> incrementTaskCount(String courseId) async {
    await _db.collection('courses').doc(courseId).update({
      'totalTasks': FieldValue.increment(1),
    });
  }

  // --- UPDATE JUMLAH SELESAI ---
  static Future<void> updateFinishedCount(String courseId, bool isCompleted) async {
    // Jika isCompleted = true -> Tambah 1, jika false -> Kurang 1
    await _db.collection('courses').doc(courseId).update({
      'finishedTasks': FieldValue.increment(isCompleted ? 1 : -1),
    });
  }

  static Stream<List<Course>> getUserCourses() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _db
        .collection('courses')
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Course.fromMap(doc.id, doc.data())).toList());
  }
}