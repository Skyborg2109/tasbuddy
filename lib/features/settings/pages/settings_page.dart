import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/auth_service.dart';
import '../../notifications/pages/notification_page.dart';
import 'edit_profile_page.dart';
import 'security_page.dart';
import 'help_center_page.dart';
import 'about_page.dart';
import 'category_management_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    // Ambil nama dengan pengamanan ekstra
    final rawName = user?.displayName ?? user?.email?.split('@').first ?? 'Pengguna';
    final displayName = rawName.trim();
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.background.withValues(alpha: 0.9),
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.onSurface, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Pengaturan',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
            ),
            centerTitle: false,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Section
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: AppColors.primaryContainer,
                          backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
                          child: user?.photoURL == null 
                            ? Text(
                                initial, 
                                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primary)
                              )
                            : null,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          displayName,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          user?.email ?? '',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

            _buildSectionTitle(context, 'Akun'),
            _buildSettingItem(Icons.person_outline, 'Edit Profil', () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfilePage()));
            }),
            _buildSettingItem(Icons.notifications_outlined, 'Notifikasi', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationPage()),
              );
            }),
            _buildSettingItem(Icons.security, 'Keamanan', () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SecurityPage()));
            }),
            _buildSettingItem(Icons.category_outlined, 'Manajemen Kategori', () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const CategoryManagementPage()));
            }),
            
            const SizedBox(height: 32),
            _buildSectionTitle(context, 'Lainnya'),
            _buildSettingItem(Icons.help_outline, 'Pusat Bantuan', () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const HelpCenterPage()));
            }),
            _buildSettingItem(Icons.info_outline, 'Tentang TaskBuddy', () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutPage()));
            }),
            
            const SizedBox(height: 48),
            // Logout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showLogoutDialog(context),
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Keluar dari Akun'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent.withValues(alpha: 0.1),
                  foregroundColor: Colors.redAccent,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildSettingItem(IconData icon, String title, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: AppColors.onSurfaceVariant),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.chevron_right, size: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        tileColor: AppColors.surfaceContainerLow.withValues(alpha: 0.5),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx); // Tutup dialog
              await AuthService().signOut();
              if (context.mounted) {
                // Gunakan pushNamedAndRemoveUntil ke '/' atau hapus semua stack
                // karena AuthWrapper di main.dart akan menangani perubahan state
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            },
            child: const Text('Keluar', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
