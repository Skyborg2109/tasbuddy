import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/category_service.dart';
import '../../tasks/models/category_model.dart';

class CategoryManagementPage extends StatefulWidget {
  const CategoryManagementPage({super.key});

  @override
  State<CategoryManagementPage> createState() => _CategoryManagementPageState();
}

class _CategoryManagementPageState extends State<CategoryManagementPage> {
  final CategoryService _categoryService = CategoryService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.onSurface, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Text(
          'Kategori',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.onSurface,
            letterSpacing: -0.5,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCategoryDialog(),
        label: const Text(
          'Kategori Baru',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        icon: const Icon(Icons.add_rounded),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      body: StreamBuilder<List<CategoryModel>>(
        stream: _categoryService.getCategories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }

          final categories = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.outline.withValues(alpha: 0.2)),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: cat.color.withValues(alpha: 0.1),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(22),
                        bottomLeft: Radius.circular(26),
                        bottomRight: Radius.circular(14),
                      ),
                    ),
                    child: Icon(cat.icon, color: cat.color, size: 24),
                  ),
                  title: Text(
                    cat.label,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 0.3,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildActionButton(
                        Icons.edit_outlined,
                        AppColors.primary,
                        () => _showCategoryDialog(category: cat),
                      ),
                      const SizedBox(width: 8),
                      _buildActionButton(
                        Icons.delete_outline_rounded,
                        Colors.redAccent,
                        () => _showDeleteConfirm(cat),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildActionButton(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.category_outlined, size: 80, color: AppColors.outline.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          const Text('Belum ada kategori kustom', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Tambahkan kategori untuk mengelompokkan tugas Anda.'),
        ],
      ),
    );
  }

  void _showCategoryDialog({CategoryModel? category}) {
    final labelController = TextEditingController(text: category?.label ?? '');
    int selectedIconCode = category?.iconCode ?? Icons.folder.codePoint;
    Color selectedColor = category?.color ?? AppColors.primary;

    final List<IconData> availableIcons = [
      Icons.work_rounded,
      Icons.person_rounded,
      Icons.favorite_rounded,
      Icons.shopping_cart_rounded,
      Icons.school_rounded,
      Icons.home_rounded,
      Icons.fitness_center_rounded,
      Icons.flight_rounded,
      Icons.payments_rounded,
      Icons.palette_rounded,
      Icons.restaurant_rounded,
      Icons.sports_esports_rounded,
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          backgroundColor: AppColors.surface,
          title: Text(
            category == null ? 'Kategori Baru' : 'Edit Kategori',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: labelController,
                  decoration: InputDecoration(
                    labelText: 'Nama Kategori',
                    filled: true,
                    fillColor: AppColors.surfaceContainerLow,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Pilih Ikon', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: availableIcons.map((icon) {
                    final isSelected = selectedIconCode == icon.codePoint;
                    return InkWell(
                      onTap: () => setDialogState(() => selectedIconCode = icon.codePoint),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: isSelected ? selectedColor.withValues(alpha: 0.2) : AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(16),
                          border: isSelected ? Border.all(color: selectedColor, width: 2) : null,
                        ),
                        child: Icon(
                          icon, 
                          color: isSelected ? selectedColor : AppColors.outline,
                          size: 28,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                const Text('Pilih Warna', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    AppColors.primary,
                    Colors.redAccent,
                    Colors.blueAccent,
                    Colors.greenAccent,
                    Colors.orangeAccent,
                    Colors.purpleAccent,
                    Colors.pinkAccent,
                    Colors.tealAccent,
                  ].map((color) {
                    final isSelected = selectedColor.toARGB32() == color.toARGB32();
                    return GestureDetector(
                      onTap: () => setDialogState(() => selectedColor = color),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: isSelected ? Border.all(color: AppColors.onSurface, width: 2) : null,
                          boxShadow: [
                            if (isSelected)
                              BoxShadow(
                                color: color.withValues(alpha: 0.4),
                                blurRadius: 8,
                                spreadRadius: 2,
                              )
                          ],
                        ),
                        child: isSelected ? const Icon(Icons.check, size: 20, color: Colors.white) : null,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal', style: TextStyle(color: AppColors.outline)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (labelController.text.isEmpty) return;
                
                final newCat = CategoryModel(
                  id: category?.id ?? '',
                  userId: '', 
                  label: labelController.text,
                  iconCode: selectedIconCode,
                  colorValue: selectedColor.toARGB32(),
                );

                final navigator = Navigator.of(context);
                if (category == null) {
                  await _categoryService.addCategory(newCat);
                } else {
                  await _categoryService.updateCategory(newCat);
                }
                if (mounted) navigator.pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirm(CategoryModel category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Kategori'),
        content: Text('Apakah Anda yakin ingin menghapus kategori "${category.label}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              await _categoryService.deleteCategory(category.id);
              if (mounted) navigator.pop();
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
