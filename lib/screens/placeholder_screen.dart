import 'package:flutter/material.dart';

// Ini adalah layar sementara untuk tab yang belum dibuat
class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.grey[300],
      ),
      body: Center(
        child: Text(
          'Halaman untuk $title',
          style: TextStyle(fontSize: 24, color: Colors.grey),
        ),
      ),
    );
  }
}
