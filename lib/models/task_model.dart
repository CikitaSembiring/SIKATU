import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  final String id;
  final String courseId; // ID Mata Kuliah (PENTING)
  final String courseName;
  final String description;
  final DateTime deadline;
  final String endTime;
  final String priority;
  final bool getAlert;
  final bool isCompleted;
  final String userId;

  TaskModel({
    this.id = '',
    required this.courseId,
    required this.courseName,
    required this.description,
    required this.deadline,
    required this.endTime,
    required this.priority,
    required this.getAlert,
    this.isCompleted = false,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'courseId': courseId,
      'courseName': courseName,
      'description': description,
      'deadline': Timestamp.fromDate(deadline),
      'endTime': endTime,
      'priority': priority,
      'getAlert': getAlert,
      'isCompleted': isCompleted,
      'userId': userId,
    };
  }

  factory TaskModel.fromMap(String id, Map<String, dynamic> map) {
    return TaskModel(
      id: id,
      courseId: map['courseId'] ?? '',
      courseName: map['courseName'] ?? '',
      description: map['description'] ?? '',
      deadline: (map['deadline'] as Timestamp).toDate(),
      endTime: map['endTime'] ?? '',
      priority: map['priority'] ?? 'Low',
      getAlert: map['getAlert'] ?? false,
      isCompleted: map['isCompleted'] ?? false,
      userId: map['userId'] ?? '',
    );
  }
}