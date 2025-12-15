import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile'),
        backgroundColor: Color(0xFFA9CF80), // Warna hijau
      ),
      body: Center(
        child: Text(
          'Halaman Profil Pengguna',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
