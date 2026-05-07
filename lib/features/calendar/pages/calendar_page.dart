import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/task_service.dart';
import '../../tasks/models/task_model.dart';
import '../widgets/weekly_day_item.dart';
import '../widgets/timeline_task_card.dart';
import '../../stats/pages/stats_focus_page.dart';
import '../../tasks/pages/task_list_page.dart';
import '../../home/pages/home_page.dart';

import '../../settings/pages/settings_page.dart';
import '../../notifications/pages/notification_page.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final TaskService _taskService = TaskService();
  final User? _user = FirebaseAuth.instance.currentUser;
  late DateTime _selectedDate;
  late List<DateTime> _weekDays;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _generateWeek();
  }

  void _generateWeek() {
    // Ambil hari Senin dari minggu di mana _selectedDate berada
    final monday = _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
    _weekDays = List.generate(7, (index) => monday.add(Duration(days: index)));
  }

  String get _displayName {
    final user = _user;
    if (user == null) return 'Pengguna';
    String name = 'Pengguna';
    if (user.displayName != null && user.displayName!.trim().isNotEmpty) {
      name = user.displayName!.split(' ').first;
    } else if (user.email != null && user.email!.contains('@')) {
      final emailPart = user.email!.split('@').first;
      if (emailPart.trim().isNotEmpty) {
        name = emailPart;
      }
    }
    return name;
  }

  @override
  Widget build(BuildContext context) {
    final displayName = _displayName;
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Top Bar
              SliverAppBar(
                floating: false,
                pinned: true,
                backgroundColor: AppColors.background.withValues(alpha: 0.9),
                elevation: 0,
                leadingWidth: 200,
                leading: Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.primaryContainer,
                        backgroundImage: _user?.photoURL != null
                            ? NetworkImage(_user!.photoURL!)
                            : null,
                        child: _user?.photoURL == null
                            ? Text(
                                initial,
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Halo, $displayName!',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.notifications_none),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const NotificationPage()),
                      );
                    },
                    color: AppColors.onSurface,
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SettingsPage()),
                      );
                    },
                    color: AppColors.onSurface,
                  ),
                  const SizedBox(width: 12),
                ],
              ),

              // Monthly Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 24, left: 24, right: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('MMMM yyyy', 'id_ID').format(_selectedDate),
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.onSurface,
                            ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _selectedDate = _selectedDate.subtract(const Duration(days: 7));
                                _generateWeek();
                              });
                            },
                            icon: const Icon(Icons.chevron_left),
                            color: AppColors.onSurfaceVariant,
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.surfaceContainerLow,
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _selectedDate = _selectedDate.add(const Duration(days: 7));
                                _generateWeek();
                              });
                            },
                            icon: const Icon(Icons.chevron_right),
                            color: AppColors.onSurfaceVariant,
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.surfaceContainerLow,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Weekly Strip
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 32),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: _weekDays.map((date) {
                        final isActive = date.day == _selectedDate.day &&
                            date.month == _selectedDate.month &&
                            date.year == _selectedDate.year;
                        
                        // Map days to Indonesian
                        final dayNames = ['SEN', 'SEL', 'RAB', 'KAM', 'JUM', 'SAB', 'MIN'];
                        final dayName = dayNames[date.weekday - 1];

                        return Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: InkWell(
                            onTap: () => setState(() => _selectedDate = date),
                            child: WeeklyDayItem(
                              dayName: dayName,
                              date: date.day.toString(),
                              isActive: isActive,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),

              // Schedule Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 48, bottom: 24, left: 24, right: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "Jadwal Hari Ini",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.onSurface,
                            ),
                      ),
                    ],
                  ),
                ),
              ),

              // Real-time Tasks Timeline
              StreamBuilder<List<TaskModel>>(
                stream: _taskService.getTasksStream(),
                builder: (context, snapshot) {
                  final allTasks = snapshot.data ?? [];
                  final filteredTasks = allTasks.where((task) {
                    return task.date.day == _selectedDate.day &&
                        task.date.month == _selectedDate.month &&
                        task.date.year == _selectedDate.year;
                  }).toList();

                  if (filteredTasks.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.event_note, size: 48, color: AppColors.outline.withValues(alpha: 0.2)),
                              const SizedBox(height: 16),
                              const Text(
                                'Tidak ada jadwal untuk hari ini',
                                style: TextStyle(color: AppColors.outline),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final task = filteredTasks[index];
                          
                          Color indicatorColor;
                          switch (task.priority) {
                            case 'Tinggi':
                              indicatorColor = AppColors.tertiary;
                              break;
                            case 'Sedang':
                              indicatorColor = AppColors.primary;
                              break;
                            default:
                              indicatorColor = AppColors.secondary;
                          }

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: TimelineTaskCard(
                              title: task.title,
                              description: '${task.category} - ${task.priority}',
                              timeRange: task.time,
                              indicatorColor: indicatorColor,
                              icon: task.category == 'Pekerjaan' 
                                ? Icons.work 
                                : task.category == 'Kesehatan' 
                                  ? Icons.fitness_center 
                                  : Icons.stars,
                            ),
                          );
                        },
                        childCount: filteredTasks.length,
                      ),
                    ),
                  );
                },
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),

          // Bottom Navigation Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.only(top: 12, bottom: 32, left: 24, right: 24),
              decoration: const BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -4))
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(Icons.home_outlined, 'Beranda', false, () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => const HomePage()),
                    );
                  }),
                  _buildNavItem(Icons.assignment_turned_in_outlined, 'Tugas', false, () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => const TaskListPage()),
                    );
                  }),
                  _buildNavItem(Icons.calendar_today, 'Kalender', true, () {}),
                  _buildNavItem(Icons.query_stats_outlined, 'Statistik', false, () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => const StatsFocusPage()),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isActive ? Colors.white : AppColors.onSurfaceVariant.withValues(alpha: 0.5),
              size: 24,
            ),
          ),
          if (!isActive)
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: AppColors.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }
}
