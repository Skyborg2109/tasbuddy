import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class HelpCenterPage extends StatelessWidget {
  const HelpCenterPage({super.key});

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
          'Pusat Bantuan',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildHelpItem(Icons.question_answer_outlined, 'FAQ', 'Pertanyaan yang sering diajukan'),
          _buildHelpItem(Icons.email_outlined, 'Hubungi Kami', 'support@taskbuddy.com'),
          _buildHelpItem(Icons.description_outlined, 'Panduan Pengguna', 'Pelajari cara menggunakan TaskBuddy'),
          const SizedBox(height: 32),
          const Text(
            'Populer',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildFAQItem('Bagaimana cara membuat tugas baru?'),
          _buildFAQItem('Apakah saya bisa menggunakan TaskBuddy offline?'),
          _buildFAQItem('Bagaimana cara sinkronisasi data?'),
        ],
      ),
    );
  }

  Widget _buildHelpItem(IconData icon, String title, String subtitle) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }

  Widget _buildFAQItem(String question) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(question, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        children: const [
          Padding(
            padding: EdgeInsets.all(16),
            child: Text('Anda dapat mengetuk tombol "+" di halaman utama untuk membuat tugas baru dengan kategori, prioritas, dan tenggat waktu.'),
          )
        ],
      ),
    );
  }
}
