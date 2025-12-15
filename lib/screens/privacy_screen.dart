import 'package:flutter/material.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Deteksi Tema
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1F2937) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final subTextColor = isDark ? Colors.grey[300] : Colors.grey[800];

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text("Privacy Policy", style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        leading: BackButton(color: textColor),
        backgroundColor: bgColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Privacy Policy for SIKATU",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
            ),
            const SizedBox(height: 15),
            Text(
              "1. Data Collection\nWe collect your email and task data to provide the service. All data is stored securely on Firebase.",
              style: TextStyle(fontSize: 14, height: 1.5, color: subTextColor),
            ),
            const SizedBox(height: 10),
            Text(
              "2. Data Usage\nYour data is used solely for task management purposes. We do not share your data with third parties.",
              style: TextStyle(fontSize: 14, height: 1.5, color: subTextColor),
            ),
            const SizedBox(height: 10),
            Text(
              "3. Security\nWe implement standard security measures to protect your information.",
              style: TextStyle(fontSize: 14, height: 1.5, color: subTextColor),
            ),
          ],
        ),
      ),
    );
  }
}