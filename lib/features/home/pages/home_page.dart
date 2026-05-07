import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../widgets/daily_focus_card.dart';
import '../widgets/category_card.dart';
import '../widgets/task_card.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/task_service.dart';
import '../../tasks/models/task_model.dart';
import '../../tasks/pages/task_list_page.dart';
import '../../calendar/pages/calendar_page.dart';
import '../../stats/pages/stats_focus_page.dart';

import '../../settings/pages/settings_page.dart';
import '../../notifications/pages/notification_page.dart';
import '../../tasks/widgets/add_task_bottom_sheet.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User? _user;
  bool _localeReady = false;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    // Inisialisasi locale Indonesia secara async
    initializeDateFormatting('id_ID', null).then((_) {
      if (mounted) setState(() => _localeReady = true);
    });
  }

  // Ambil nama tampilan user: prioritaskan displayName, lalu bagian sebelum @ dari email
  String get _displayName {
    final user = _user;
    if (user == null) return 'Pengguna';
    if (user.displayName != null && user.displayName!.isNotEmpty) {
      return user.displayName!.split(' ').first; // Hanya nama pertama
    }
    return user.email?.split('@').first ?? 'Pengguna';
  }

  // Salam dinamis berdasarkan jam
  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat Pagi';
    if (hour < 15) return 'Selamat Siang';
    if (hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  // Tanggal hari ini dalam format Indonesia
  String get _todayDate {
    if (!_localeReady) return '';
    return DateFormat("EEEE, d MMMM yyyy", 'id_ID').format(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Header as pinned SliverAppBar
              SliverAppBar(
                pinned: true,
                floating: false,
                backgroundColor: AppColors.background.withValues(alpha: 0.9),
                elevation: 0,
                toolbarHeight: 80,
                leadingWidth: 0,
                automaticallyImplyLeading: false,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        // Avatar
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: AppColors.primaryContainer,
                          backgroundImage: _user?.photoURL != null
                              ? NetworkImage(_user!.photoURL!)
                              : null,
                          child: _user?.photoURL == null
                              ? Text(
                                  _displayName.isNotEmpty
                                      ? _displayName[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$_greeting, $_displayName!',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              _todayDate,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const NotificationPage()),
                            );
                          },
                          icon: const Icon(Icons.notifications_none),
                          color: AppColors.onSurface,
                          tooltip: 'Notifikasi',
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const SettingsPage()),
                            );
                          },
                          icon: const Icon(Icons.settings_outlined),
                          color: AppColors.onSurface,
                          tooltip: 'Pengaturan',
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Main Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      // Daily Focus
                      StreamBuilder<List<TaskModel>>(
                        stream: TaskService().getTodayTasksStream(),
                        builder: (context, snapshot) {
                          final tasks = snapshot.data ?? [];
                          final completedTasks = tasks.where((t) => t.isCompleted).length;
                          final totalTasks = tasks.length;
                          
                          return DailyFocusCard(
                            completedTasks: totalTasks == 0 ? 0 : completedTasks,
                            totalTasks: totalTasks == 0 ? 0 : totalTasks,
                          );
                        },
                      ),
                      const SizedBox(height: 36),

                      // Categories
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Kategori',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              'Lihat Semua',
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      StreamBuilder<List<TaskModel>>(
                        stream: TaskService().getTasksStream(),
                        builder: (context, snapshot) {
                          final tasks = snapshot.data ?? [];
                          
                          int countByCat(String cat) => tasks.where((t) => t.category == cat).length;

                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            clipBehavior: Clip.none,
                            child: Row(
                              children: [
                                CategoryCard(
                                  title: 'Pekerjaan',
                                  taskCount: '${countByCat('Pekerjaan')} Tugas',
                                  icon: Icons.work_outline,
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  iconContainerColor: Colors.white24,
                                ),
                                const SizedBox(width: 16),
                                CategoryCard(
                                  title: 'Pribadi',
                                  taskCount: '${countByCat('Pribadi')} Tugas',
                                  icon: Icons.person_outline,
                                  backgroundColor: AppColors.secondaryContainer,
                                  foregroundColor: AppColors.secondary,
                                  iconContainerColor: Colors.white.withValues(alpha: 0.5),
                                ),
                                const SizedBox(width: 16),
                                CategoryCard(
                                  title: 'Belajar',
                                  taskCount: '${countByCat('Belajar')} Tugas',
                                  icon: Icons.menu_book_outlined,
                                  backgroundColor: AppColors.surfaceContainerHigh,
                                  foregroundColor: AppColors.onSurface,
                                  iconContainerColor: Colors.white70,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 36),

                      // Priority Tasks
                      Text(
                        'Tugas Prioritas',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 16),
                      StreamBuilder<List<TaskModel>>(
                        stream: TaskService().getTasksStream(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          
                          final tasks = snapshot.data ?? [];
                          
                          if (tasks.isEmpty) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 40),
                                child: Column(
                                  children: [
                                    Icon(Icons.task_alt, size: 48, color: AppColors.outline.withValues(alpha: 0.3)),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Belum ada tugas',
                                      style: TextStyle(color: AppColors.outline),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          // Take top 3 for priority
                          final priorityTasks = tasks.take(3).toList();

                          return Column(
                            children: priorityTasks.map((task) {
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
                                child: TaskCard(
                                  title: task.title,
                                  timeRange: task.time,
                                  indicatorColor: indicatorColor,
                                  onDelete: () {
                                    TaskService().deleteTask(task.id);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Tugas berhasil dihapus')),
                                    );
                                  },
                                  onEdit: () {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      builder: (context) => AddTaskBottomSheet(task: task),
                                    );
                                  },
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      // Navbar dipindah ke sini agar selalu di bawah secara tetap
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
            _buildNavItem(Icons.home_outlined, 'Beranda', true, () {}, context),
            _buildNavItem(Icons.assignment_turned_in_outlined, 'Tugas', false, () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const TaskListPage()),
              );
            }, context),
            _buildNavItem(Icons.calendar_today_outlined, 'Kalender', false, () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const CalendarPage()),
              );
            }, context),
            _buildNavItem(Icons.query_stats_outlined, 'Statistik', false, () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const StatsFocusPage()),
              );
            }, context),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive, VoidCallback onTap, BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
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
