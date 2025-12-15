import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:sikatu/models/course_model.dart';
import 'package:sikatu/models/task_model.dart';
import 'package:sikatu/services/course_service.dart';
import 'package:sikatu/services/task_service.dart';
import 'package:sikatu/theme/app_colors.dart';
import 'package:sikatu/screens/task_list_screen.dart';

class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({super.key});
  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _descriptionController = TextEditingController();
  String? _selectedCourseId;
  Course? _selectedCourseObject;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _priority = 'Low';
  bool _getAlert = false;
  bool _isLoading = false;

  void _calculatePriority(DateTime date) {
    final now = DateTime.now();
    final diff = date.difference(now).inDays;
    setState(() {
      if (diff <= 3) _priority = 'High';
      else if (diff <= 7) _priority = 'Medium';
      else _priority = 'Low';
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (context, child) => Theme(data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: AppColors.primary)), child: child!),
    );
    if (picked != null) { setState(() => _selectedDate = picked); _calculatePriority(picked); }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) => Theme(data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: AppColors.primary)), child: child!),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _handleCreateTask() async {
    if (_selectedCourseObject == null || _selectedDate == null || _selectedTime == null || _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mohon lengkapi semua data')));
      return;
    }
    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final newTask = TaskModel(
          courseId: _selectedCourseObject!.id,
          courseName: _selectedCourseObject!.name,
          description: _descriptionController.text,
          deadline: _selectedDate!,
          endTime: _selectedTime!.format(context),
          priority: _priority,
          getAlert: _getAlert,
          userId: user.uid,
        );
        await TaskService.addTask(newTask);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tugas berhasil dibuat!'), backgroundColor: Colors.green));
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const TaskListScreen()));
        }
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal membuat tugas'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    const Color solidGreenColor = Color(0xFFADF7B6);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
      appBar: AppBar(
        leading: BackButton(color: textColor),
        centerTitle: true,
        title: Text('Create new task', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Schedule", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: textColor)),
            const SizedBox(height: 10),
            StreamBuilder<List<Course>>(
              stream: CourseService.getUserCourses(),
              builder: (context, snapshot) {
                final courses = snapshot.data ?? [];
                if (_selectedCourseId != null && !courses.any((c) => c.id == _selectedCourseId)) { _selectedCourseId = null; _selectedCourseObject = null; }
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(color: solidGreenColor, borderRadius: BorderRadius.circular(12)),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      hint: const Text("Select Course", style: TextStyle(color: Colors.black54)),
                      value: _selectedCourseId,
                      isExpanded: true,
                      dropdownColor: solidGreenColor,
                      style: const TextStyle(color: Colors.black), // Teks dropdown hitam
                      items: courses.map((Course course) => DropdownMenuItem<String>(value: course.id, child: Text(course.name))).toList(),
                      onChanged: (val) { setState(() { _selectedCourseId = val; _selectedCourseObject = courses.firstWhere((c) => c.id == val); }); },
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _descriptionController,
              maxLines: 5,
              style: const TextStyle(color: Colors.black), // Input teks hitam
              decoration: InputDecoration(
                hintText: "Description",
                hintStyle: const TextStyle(color: Colors.black54),
                filled: true,
                fillColor: solidGreenColor,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.all(15),
              ),
            ),
            const SizedBox(height: 20),
            Text("Deadline", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: textColor)),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(color: solidGreenColor, borderRadius: BorderRadius.circular(12)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [const Icon(Icons.calendar_today, size: 20, color: Colors.black), const SizedBox(width: 10), Text(_selectedDate == null ? "DD/MM/YYYY" : DateFormat('dd/MM/yyyy').format(_selectedDate!), style: const TextStyle(color: Colors.black))]),
                    const Icon(Icons.keyboard_arrow_down, color: Colors.black),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text("End Time", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: textColor)),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => _selectTime(context),
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(color: solidGreenColor, borderRadius: BorderRadius.circular(12)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [const Icon(Icons.access_time, size: 20, color: Colors.black), const SizedBox(width: 10), Text(_selectedTime == null ? "HH : MM" : _selectedTime!.format(context), style: const TextStyle(color: Colors.black))]),
                    const Icon(Icons.keyboard_arrow_down, color: Colors.black),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text("Priority", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: textColor)),
            const SizedBox(height: 10),
            Row(
              children: ['High', 'Medium', 'Low'].map((p) {
                final isSelected = _priority == p;
                Color btnColor = Colors.white;
                if (isSelected) { if(p == 'High') btnColor = AppColors.taskYellow; else if (p == 'Medium') btnColor = solidGreenColor; }
                return Expanded(
                  child: GestureDetector(
                    onTap: (){ setState(() => _priority = p); },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(color: btnColor, border: Border.all(color: isSelected ? Colors.transparent : Colors.grey.shade300), borderRadius: BorderRadius.circular(10)),
                      child: Center(child: Text(p, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black))),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Get alert for this task", style: TextStyle(fontSize: 16, color: textColor)),
                Switch(value: _getAlert, activeColor: AppColors.primary, onChanged: (val) => setState(() => _getAlert = val)),
              ],
            ),
            const SizedBox(height: 30),
            GestureDetector(
              onTap: _isLoading ? null : _handleCreateTask,
              child: Container(
                width: double.infinity, height: 55,
                decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.gradientStart, AppColors.gradientEnd], begin: Alignment.topCenter, end: Alignment.bottomCenter), borderRadius: BorderRadius.circular(15)),
                child: Center(child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Create Task', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}