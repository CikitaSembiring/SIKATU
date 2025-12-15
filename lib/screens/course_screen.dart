import 'package:flutter/material.dart';
import 'package:sikatu/models/course_model.dart';
import 'package:sikatu/screens/create_course_screen.dart';
import 'package:sikatu/services/course_service.dart';
import 'package:sikatu/theme/app_colors.dart';
import 'package:sikatu/screens/main_screen.dart'; // PENTING: Tambahkan Import ini

class CourseScreen extends StatefulWidget {
  const CourseScreen({super.key});

  @override
  State<CourseScreen> createState() => _CourseScreenState();
}

class _CourseScreenState extends State<CourseScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    // --- LOGIKA DARK MODE ---
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF1F2937) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final searchBarColor = isDark ? const Color(0xFF374151) : const Color(0xFFF5F5F5);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
        // --- PERBAIKAN TOMBOL BACK ---
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              // Paksa kembali ke Home jika stuck
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const MainScreen())
              );
            }
          },
        ),
        title: Text(
          'Courses',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 24),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // --- SEARCH BAR ---
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    hintText: 'Search Courses',
                    hintStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey),
                    prefixIcon: Icon(Icons.search, color: isDark ? Colors.grey[400] : Colors.grey),
                    filled: true,
                    fillColor: searchBarColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),

              // --- LIST COURSE (REALTIME) ---
              Expanded(
                child: StreamBuilder<List<Course>>(
                  stream: CourseService.getUserCourses(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: textColor)));
                    }

                    final courses = snapshot.data ?? [];

                    final filteredCourses = courses.where((course) {
                      return course.name.toLowerCase().contains(_searchQuery);
                    }).toList();

                    if (filteredCourses.isEmpty) {
                      return Center(child: Text('Belum ada mata kuliah.', style: TextStyle(color: textColor)));
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 80),
                      itemCount: filteredCourses.length,
                      itemBuilder: (context, index) {
                        return _buildCourseCard(filteredCourses[index]);
                      },
                    );
                  },
                ),
              ),
            ],
          ),

          // Tombol + Melayang
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CreateCourseScreen()),
                );
              },
              backgroundColor: AppColors.courseGreenAccent,
              child: const Icon(Icons.add, size: 30, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseCard(Course course) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: AppColors.courseCardBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 10,
              decoration: const BoxDecoration(
                color: AppColors.courseGreenAccent,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${course.room} • ${course.credits} SKS • ${course.lecturer}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatusItem(Icons.description_outlined, '${course.totalTasks} Task'),
                        _buildStatusItem(Icons.check, '${course.finishedTasks} Finished'),
                        _buildStatusItem(Icons.hourglass_empty, '${course.activeTasks} Active'),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.black87),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black87),
        ),
      ],
    );
  }
}