import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sikatu/models/task_model.dart';
import 'package:sikatu/services/task_service.dart';
import 'package:sikatu/screens/task_detail_flow.dart';
import 'package:sikatu/screens/main_screen.dart'; // PENTING: Tambahkan Import ini

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  // Warna Statis (Pastel)
  final Color _calendarBgColor = const Color(0xFFDDEB9D);
  final Color _todayYellow = const Color(0xFFFFD95F);
  final Color _taskColor = const Color(0xFFA0C878);

  final List<String> _weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  int _getDaysInMonth(int year, int month) {
    if (month == 12) return 31;
    return DateTime(year, month + 1, 0).day;
  }

  String _getDaySuffix(int day) {
    if (day >= 11 && day <= 13) return 'th';
    switch (day % 10) {
      case 1: return 'st';
      case 2: return 'nd';
      case 3: return 'rd';
      default: return 'th';
    }
  }

  void _showYearPicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text("Select Year", style: TextStyle(color: Colors.black)),
          content: SizedBox(
            width: 300,
            height: 300,
            child: Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: Color(0xFFA0C878),
                  onPrimary: Colors.white,
                  onSurface: Colors.black,
                ),
              ),
              child: YearPicker(
                firstDate: DateTime(DateTime.now().year - 100, 1),
                lastDate: DateTime(DateTime.now().year + 100, 1),
                initialDate: _focusedDay,
                selectedDate: _focusedDay,
                onChanged: (DateTime dateTime) {
                  setState(() {
                    _focusedDay = DateTime(dateTime.year, _focusedDay.month, _focusedDay.day);
                  });
                  Navigator.pop(context);
                },
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Deteksi Dark Mode
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF1F2937) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final subTextColor = isDark ? Colors.grey[400] : Colors.grey.shade700;

    String fullDateTitle = "${DateFormat('MMMM, d').format(_selectedDay)}${_getDaySuffix(_selectedDay.day)}, ${DateFormat('EEE').format(_selectedDay)}";

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
              Navigator.pop(context); // Kembali jika bisa
            } else {
              // Jika tidak bisa pop (karena di menu utama), paksa reset ke MainScreen (Home)
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const MainScreen())
              );
            }
          },
        ),
        title: Text(
          'Calendar',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: StreamBuilder<List<TaskModel>>(
        stream: TaskService.getUserTasks(),
        builder: (context, snapshot) {
          final allTasks = snapshot.data ?? [];
          final selectedTasks = allTasks.where((task) {
            return _isSameDay(task.deadline, _selectedDay);
          }).toList();

          return Column(
            children: [
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _calendarBgColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: _buildMonthView(allTasks),
              ),

              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fullDateTitle,
                        style: TextStyle(
                          fontSize: 16,
                          color: subTextColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 15),

                      Expanded(
                        child: selectedTasks.isEmpty
                            ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.event_note, size: 50, color: Colors.grey.shade400),
                              const SizedBox(height: 10),
                              Text(
                                "No tasks due on this day",
                                style: TextStyle(color: Colors.grey.shade500),
                              ),
                            ],
                          ),
                        )
                            : ListView.builder(
                          itemCount: selectedTasks.length,
                          itemBuilder: (context, index) {
                            return _buildTaskItem(context, selectedTasks[index]);
                          },
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }

  Widget _buildMonthView(List<TaskModel> allTasks) {
    final int daysInMonth = _getDaysInMonth(_focusedDay.year, _focusedDay.month);
    final int firstWeekday = DateTime(_focusedDay.year, _focusedDay.month, 1).weekday;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left, size: 24, color: Colors.black),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    setState(() {
                      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
                    });
                  },
                ),
                const SizedBox(width: 5),
                Text(
                  DateFormat('MMMM').format(_focusedDay),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black),
                ),
                const SizedBox(width: 5),
                IconButton(
                  icon: const Icon(Icons.chevron_right, size: 24, color: Colors.black),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    setState(() {
                      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 1);
                    });
                  },
                ),
              ],
            ),
            GestureDetector(
              onTap: _showYearPicker,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    Text(
                      '${_focusedDay.year}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.chevron_right, size: 20, color: Colors.black),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: _weekDays.map((day) => Expanded(
            child: Center(
              child: Text(day, style: const TextStyle(fontSize: 13, color: Colors.black54, fontWeight: FontWeight.w500)),
            ),
          )).toList(),
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemCount: 42,
          itemBuilder: (context, index) {
            final int dayOffset = index - (firstWeekday - 1);
            final DateTime cellDate = DateTime(_focusedDay.year, _focusedDay.month, 1).add(Duration(days: dayOffset));
            final bool isCurrentMonth = cellDate.month == _focusedDay.month;

            final bool isToday = _isSameDay(cellDate, DateTime.now());
            final bool isSelected = _isSameDay(cellDate, _selectedDay);

            final bool hasTask = allTasks.any((t) => _isSameDay(t.deadline, cellDate));

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedDay = cellDate;
                  if (!isCurrentMonth) {
                    _focusedDay = DateTime(cellDate.year, cellDate.month, 1);
                  }
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isToday ? _todayYellow : Colors.white,
                  shape: BoxShape.circle,
                  border: (isSelected && !isToday)
                      ? Border.all(color: Colors.black, width: 2)
                      : null,
                  boxShadow: isToday || isSelected
                      ? [const BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))]
                      : null,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(
                      '${cellDate.day}',
                      style: TextStyle(
                        color: isCurrentMonth ? Colors.black : Colors.grey.shade400,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (hasTask && isCurrentMonth)
                      Positioned(
                        bottom: 8,
                        child: Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: isToday ? Colors.black : const Color(0xFFA0C878),
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTaskItem(BuildContext context, TaskModel task) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TaskDetailScreen(task: task)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: _taskColor,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Icon(
                task.isCompleted ? Icons.check_circle : Icons.menu_book,
                color: Colors.black54,
                size: 22
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.courseName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  if (task.description.isNotEmpty)
                    Text(
                      task.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: Colors.black.withOpacity(0.6)),
                    ),
                ],
              ),
            ),
            if (task.endTime.isNotEmpty)
              Text(
                task.endTime,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
              )
          ],
        ),
      ),
    );
  }
}