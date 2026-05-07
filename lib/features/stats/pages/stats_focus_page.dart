import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/task_service.dart';
import '../../tasks/models/task_model.dart';
import '../widgets/productivity_gauge.dart';
import '../widgets/activity_chart.dart';
import '../widgets/streak_card.dart';
import '../../tasks/pages/task_list_page.dart';
import '../../calendar/pages/calendar_page.dart';
import '../../home/pages/home_page.dart';
import '../../settings/pages/settings_page.dart';
import '../../notifications/pages/notification_page.dart';

class StatsFocusPage extends StatefulWidget {
  const StatsFocusPage({super.key});

  @override
  State<StatsFocusPage> createState() => _StatsFocusPageState();
}

class _StatsFocusPageState extends State<StatsFocusPage> {
  final TaskService _taskService = TaskService();
  final User? _user = FirebaseAuth.instance.currentUser;

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
      body: StreamBuilder<List<TaskModel>>(
        stream: _taskService.getTasksStream(),
        builder: (context, snapshot) {
          final allTasks = snapshot.data ?? [];
          
          // Hitung tugas hari ini
          final now = DateTime.now();
          final todayTasks = allTasks.where((t) => 
            t.createdAt.day == now.day && 
            t.createdAt.month == now.month && 
            t.createdAt.year == now.year).toList();
          
          final completedToday = todayTasks.where((t) => t.isCompleted).length;
          final totalToday = todayTasks.length;

          // Hitung aktivitas 7 hari terakhir
          List<int> activityData = [];
          List<String> activityDays = [];
          for (int i = 6; i >= 0; i--) {
            final date = now.subtract(Duration(days: i));
            final count = allTasks.where((t) => 
              t.isCompleted &&
              t.date.day == date.day && 
              t.date.month == date.month && 
              t.date.year == date.year).length;
            activityData.add(count);
            
            // Nama hari singkat
            final dayNames = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
            activityDays.add(dayNames[date.weekday % 7]);
          }

          return Stack(
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

                  // Productivity Gauge
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 32, bottom: 40),
                      child: ProductivityGauge(
                        completed: completedToday, 
                        total: totalToday == 0 ? 1 : totalToday, // Hindari pembagian nol
                      ),
                    ),
                  ),

                  // Summary Cards
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildRecordCard(context, completedToday),
                          const SizedBox(height: 24),
                          StreakCard(
                            streakDays: completedToday > 0 ? 1 : 0, // Sederhana untuk sekarang
                            title: 'FOKUS PENUH KESADARAN',
                            subtitle: completedToday == totalToday && totalToday > 0
                                ? 'Luar biasa! Target hari ini tercapai.'
                                : 'Siap untuk fokus hari ini, $_displayName?',
                            reminder: "Jangan putus rantainya!",
                          ),
                          const SizedBox(height: 32),
                          ActivityChart(
                            data: activityData,
                            days: activityDays,
                          ),
                          const SizedBox(height: 32),
                          _buildSectionTitle(context, 'Pencapaian'),
                          const SizedBox(height: 16),
                          _buildAchievementsSection(),
                          const SizedBox(height: 120), // Bottom space
                        ],
                      ),
                    ),
                  ),
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
                      _buildNavItem(Icons.calendar_today_outlined, 'Kalender', false, () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => const CalendarPage()),
                        );
                      }),
                      _buildNavItem(Icons.query_stats, 'Statistik', true, () {}),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRecordCard(BuildContext context, int completed) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.secondaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: AppColors.secondaryContainer,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.workspace_premium, color: AppColors.onSecondaryContainer),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  completed > 0 ? 'Kemajuan Bagus!' : 'Ayo Mulai!',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.onSecondaryContainer,
                      ),
                ),
                Text(
                  '$completed tugas selesai hari ini',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppColors.onSecondaryContainer.withValues(alpha: 0.8),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.onSurface,
          ),
    );
  }

  Widget _buildAchievementsSection() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildAchievementBadge(Icons.bolt, 'Cepat Belajar'),
          const SizedBox(width: 16),
          _buildAchievementBadge(Icons.calendar_month, 'Konsisten'),
          const SizedBox(width: 16),
          _buildAchievementBadge(Icons.star, 'Performa Bintang'),
          const SizedBox(width: 16),
          _buildAchievementBadge(Icons.favorite, 'Fokus Harian'),
        ],
      ),
    );
  }

  Widget _buildAchievementBadge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 32),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
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
