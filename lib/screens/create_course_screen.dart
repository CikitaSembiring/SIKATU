import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sikatu/models/course_model.dart';
import 'package:sikatu/services/course_service.dart';
import 'package:sikatu/theme/app_colors.dart';

class CreateCourseScreen extends StatefulWidget {
  const CreateCourseScreen({super.key});
  @override
  State<CreateCourseScreen> createState() => _CreateCourseScreenState();
}

class _CreateCourseScreenState extends State<CreateCourseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _courseNameController = TextEditingController();
  final _lecturerNameController = TextEditingController();
  final _roomController = TextEditingController();
  final _creditsController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _courseNameController.dispose();
    _lecturerNameController.dispose();
    _roomController.dispose();
    _creditsController.dispose();
    super.dispose();
  }

  Future<void> _handleCreateCourse() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final newCourse = Course(
            name: _courseNameController.text,
            lecturer: _lecturerNameController.text,
            room: _roomController.text,
            credits: int.tryParse(_creditsController.text) ?? 0,
            userId: user.uid,
          );
          await CourseService.addCourse(newCourse);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mata kuliah berhasil ditambahkan!'), backgroundColor: Colors.green));
            Navigator.pop(context);
          }
        }
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menambahkan: $e'), backgroundColor: Colors.red));
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
      appBar: AppBar(
        leading: BackButton(color: textColor),
        centerTitle: true,
        title: Text('Create new courses', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 20)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildGreenTextField(controller: _courseNameController, hint: 'Course Name'),
              const SizedBox(height: 20),
              _buildGreenTextField(controller: _lecturerNameController, hint: 'Lecturer Name'),
              const SizedBox(height: 20),
              _buildGreenTextField(controller: _roomController, hint: 'Room'),
              const SizedBox(height: 20),
              _buildGreenTextField(controller: _creditsController, hint: 'Credits (SKS)', isNumber: true),
              const Spacer(),
              _isLoading ? const Center(child: CircularProgressIndicator()) : Container(
                width: double.infinity, height: 55,
                decoration: BoxDecoration(gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [AppColors.gradientStart, AppColors.gradientEnd]), borderRadius: BorderRadius.circular(15)),
                child: ElevatedButton(onPressed: _handleCreateCourse, style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))), child: const Text('Create Courses', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white))),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGreenTextField({required TextEditingController controller, required String hint, bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.black), // Teks user hitam
      validator: (value) => value == null || value.isEmpty ? '$hint tidak boleh kosong' : null,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.black.withOpacity(0.6)), // Hint agak transparan hitam
        filled: true,
        fillColor: AppColors.createCourseInputBg, // Warna #ADF7B6
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      ),
    );
  }
}