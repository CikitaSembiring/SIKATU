import 'package:flutter/material.dart';

class TaskListItem extends StatelessWidget {
  final String title;
  final Color color;

  const TaskListItem({
    super.key, // Gunakan super.key
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade300, width: 1), // Border tipis
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.grey.shade800, // Warna teks lebih gelap
        ),
      ),
    );
  }
}

