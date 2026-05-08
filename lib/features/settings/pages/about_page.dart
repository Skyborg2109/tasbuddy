import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Tentang TaskBuddy',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            const SizedBox(height: 40),
            // Logo placeholder
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.check_rounded, size: 60, color: Colors.white),
            ),
            const SizedBox(height: 24),
            const Text(
              'TaskBuddy',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Versi 1.0.0',
              style: TextStyle(color: AppColors.outline),
            ),
            const SizedBox(height: 40),
            const Text(
              'TaskBuddy adalah aplikasi manajemen tugas yang dirancang untuk membantu Anda tetap terorganisir dan produktif. Kelola pekerjaan, kehidupan pribadi, dan kesehatan Anda dalam satu tempat yang indah.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, height: 1.6),
            ),
            const SizedBox(height: 40),
            const Divider(),
            const ListTile(
              title: Text('Syarat dan Ketentuan'),
              trailing: Icon(Icons.chevron_right),
            ),
            const ListTile(
              title: Text('Kebijakan Privasi'),
              trailing: Icon(Icons.chevron_right),
            ),
            const ListTile(
              title: Text('Lisensi Open Source'),
              trailing: Icon(Icons.chevron_right),
            ),
            const SizedBox(height: 40),
            const Text(
              '© 2024 TaskBuddy Team',
              style: TextStyle(color: AppColors.outline, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
