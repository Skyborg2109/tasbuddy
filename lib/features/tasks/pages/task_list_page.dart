import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/task_service.dart';
import '../../stats/pages/stats_focus_page.dart';
import '../../calendar/pages/calendar_page.dart';
import '../../home/pages/home_page.dart';
import '../widgets/add_task_bottom_sheet.dart';
import '../widgets/task_list_item.dart';
import '../models/task_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../settings/pages/settings_page.dart';
import '../../notifications/pages/notification_page.dart';

class TaskListPage extends StatefulWidget {
  const TaskListPage({super.key});

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  int _selectedFilterIndex = 0;
  final List<String> _filters = ['Semua', 'Berlangsung', 'Selesai'];
  final TaskService _taskService = TaskService();
  final User? _user = FirebaseAuth.instance.currentUser;

  String _getRelativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(date.year, date.month, date.day);
    final difference = taskDate.difference(today).inDays;

    if (difference == 0) return 'Hari Ini';
    if (difference == 1) return 'Besok';
    if (difference == -1) return 'Kemarin';
    
    return DateFormat("d MMMM", 'id_ID').format(date);
  }

  void _showAddTask() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddTaskBottomSheet(),
    );
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
          // Main Scrollable Content
          StreamBuilder<List<TaskModel>>(
            stream: _taskService.getTasksStream(),
            builder: (context, snapshot) {
              final allTasks = snapshot.data ?? [];
              
              // Apply filter
              List<TaskModel> filteredTasks;
              if (_selectedFilterIndex == 1) { // Berlangsung
                filteredTasks = allTasks.where((t) => !t.isCompleted).toList();
              } else if (_selectedFilterIndex == 2) { // Selesai
                filteredTasks = allTasks.where((t) => t.isCompleted).toList();
              } else {
                filteredTasks = allTasks;
              }

              return CustomScrollView(
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

                  // Filter Chips
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 24, left: 24, right: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_filters.length, (index) {
                          final isActive = _selectedFilterIndex == index;
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: InkWell(
                              onTap: () => setState(() => _selectedFilterIndex = index),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isActive ? AppColors.primary : AppColors.surfaceContainer,
                                  borderRadius: BorderRadius.circular(32),
                                ),
                                child: Text(
                                  _filters[index],
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                                    color: isActive ? Colors.white : AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),

                  // Tasks List
                  if (filteredTasks.isEmpty)
                    SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.assignment_outlined, size: 64, color: AppColors.outline.withValues(alpha: 0.3)),
                            const SizedBox(height: 16),
                            Text(
                              'Tidak ada tugas ditemukan',
                              style: TextStyle(color: AppColors.outline),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 40),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final task = filteredTasks[index];
                            
                            Color catColor;
                            Color catTextColor;
                            switch (task.category) {
                              case 'Pekerjaan':
                                catColor = AppColors.tertiaryContainer;
                                catTextColor = AppColors.onTertiaryContainer;
                                break;
                              case 'Pribadi':
                                catColor = AppColors.primaryContainer;
                                catTextColor = AppColors.onPrimaryContainer;
                                break;
                              case 'Kesehatan':
                                catColor = AppColors.secondaryContainer;
                                catTextColor = AppColors.onSecondaryContainer;
                                break;
                              default:
                                catColor = AppColors.surfaceContainer;
                                catTextColor = AppColors.onSurfaceVariant;
                            }

                            final dateInfo = _getRelativeDate(task.date);

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Dismissible(
                                key: Key(task.id),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 24),
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                ),
                                onDismissed: (direction) {
                                  _taskService.deleteTask(task.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Tugas dihapus')),
                                  );
                                },
                                child: TaskListItem(
                                  title: task.title,
                                  subtitle: '$dateInfo, ${task.time} • ${task.category}',
                                  category: task.category,
                                  categoryColor: catColor,
                                  categoryTextColor: catTextColor,
                                  isCompleted: task.isCompleted,
                                  onToggle: () async {
                                    final now = DateTime.now();
                                    
                                    // Parse jam dan menit dari string task.time (format HH:mm)
                                    final timeParts = task.time.split(':');
                                    bool isFuture = false;
                                    
                                    if (timeParts.length == 2) {
                                      final hour = int.tryParse(timeParts[0]) ?? 0;
                                      final minute = int.tryParse(timeParts[1]) ?? 0;
                                      
                                      final taskDateTime = DateTime(
                                        task.date.year,
                                        task.date.month,
                                        task.date.day,
                                        hour,
                                        minute,
                                      );
                                      
                                      isFuture = taskDateTime.isAfter(now);
                                    }

                                    // Jika ingin mencentang tugas yang belum waktunya
                                    if (!task.isCompleted && isFuture) {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                          title: const Text('Selesaikan Lebih Awal?'),
                                          content: Text('Jadwal tugas ini (${_getRelativeDate(task.date)}, ${task.time}) belum tiba. Apakah Anda yakin ingin menyelesaikannya sekarang?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(ctx, false),
                                              child: const Text('Batal'),
                                            ),
                                            TextButton(
                                              onPressed: () => Navigator.pop(ctx, true),
                                              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                                              child: const Text('Ya, Selesai'),
                                            ),
                                          ],
                                        ),
                                      );
                                      
                                      if (confirm != true) return;
                                    }

                                    _taskService.toggleTaskCompletion(task.id, !task.isCompleted);
                                  },
                                ),
                              ),
                            );
                          },
                          childCount: filteredTasks.length,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),

          // Floating Action Button
          Positioned(
            bottom: 20,
            right: 24,
            child: FloatingActionButton(
              onPressed: _showAddTask,
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.add, size: 32),
            ),
          ),
        ],
      ),
      // Bottom Navigation Bar dipindah ke sini agar tetap di bawah
      bottomNavigationBar: Container(
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
            _buildNavItem(Icons.assignment_turned_in, 'Tugas', true, () {}),
            _buildNavItem(Icons.calendar_today_outlined, 'Kalender', false, () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const CalendarPage()),
              );
            }),
            _buildNavItem(Icons.query_stats_outlined, 'Statistik', false, () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const StatsFocusPage()),
              );
            }),
          ],
        ),
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
