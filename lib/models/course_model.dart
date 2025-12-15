class Course {
  final String id;
  final String name;
  final String room;
  final int credits;
  final String lecturer;
  final int totalTasks;
  final int finishedTasks;
  final String userId; // Agar data tidak tertukar antar user

  Course({
    this.id = '',
    required this.name,
    required this.room,
    required this.credits,
    required this.lecturer,
    required this.userId,
    this.totalTasks = 0,
    this.finishedTasks = 0,
  });

  int get activeTasks => totalTasks - finishedTasks;

  // Mengubah data ke format Map untuk disimpan ke Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'room': room,
      'credits': credits,
      'lecturer': lecturer,
      'totalTasks': totalTasks,
      'finishedTasks': finishedTasks,
      'userId': userId,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    };
  }

  // Mengubah data dari Firestore ke object Course
  factory Course.fromMap(String id, Map<String, dynamic> map) {
    return Course(
      id: id,
      name: map['name'] ?? '',
      room: map['room'] ?? '',
      credits: map['credits']?.toInt() ?? 0,
      lecturer: map['lecturer'] ?? '',
      totalTasks: map['totalTasks']?.toInt() ?? 0,
      finishedTasks: map['finishedTasks']?.toInt() ?? 0,
      userId: map['userId'] ?? '',
    );
  }
}