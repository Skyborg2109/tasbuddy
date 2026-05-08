import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/task_service.dart';
import '../../../core/services/category_service.dart';
import '../../../core/services/notification_service.dart';
import '../models/task_model.dart';
import '../../notifications/models/notification_model.dart';

class AddTaskBottomSheet extends StatefulWidget {
  final TaskModel? task;
  const AddTaskBottomSheet({super.key, this.task});

  @override
  State<AddTaskBottomSheet> createState() => _AddTaskBottomSheetState();
}

class _AddTaskBottomSheetState extends State<AddTaskBottomSheet> {
  late String _selectedCategory;
  late String _selectedPriority;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late TextEditingController _taskController;
  
  final TaskService _taskService = TaskService();
  final CategoryService _categoryService = CategoryService();
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.task?.category ?? 'Pekerjaan';
    _selectedPriority = widget.task?.priority ?? 'Rendah';
    _selectedDate = widget.task?.date ?? DateTime.now();
    _taskController = TextEditingController(text: widget.task?.title ?? '');
    
    // Parse time string if editing
    if (widget.task != null) {
      final parts = widget.task!.time.split(':');
      if (parts.length == 2) {
        final hour = int.tryParse(parts[0]) ?? TimeOfDay.now().hour;
        final minute = int.tryParse(parts[1]) ?? TimeOfDay.now().minute;
        _selectedTime = TimeOfDay(hour: hour, minute: minute);
      } else {
        _selectedTime = TimeOfDay.now();
      }
    } else {
      _selectedTime = TimeOfDay.now();
    }
  }

  final List<Map<String, dynamic>> _categories = [
    {
      'label': 'Pekerjaan',
      'icon': Icons.work,
      'color': AppColors.primary,
      'container': AppColors.primaryContainer,
      'onContainer': AppColors.onPrimaryContainer,
    },
    {
      'label': 'Pribadi',
      'icon': Icons.favorite,
      'color': AppColors.secondary,
      'container': AppColors.secondaryContainer,
      'onContainer': AppColors.onSecondaryContainer,
    },
    {
      'label': 'Kesehatan',
      'icon': Icons.fitness_center,
      'color': AppColors.tertiary,
      'container': AppColors.tertiaryContainer,
      'onContainer': AppColors.onTertiaryContainer,
    },
  ];

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() => _selectedTime = picked);
    }
  }

  void _handleCreateTask() async {
    final title = _taskController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Judul tugas tidak boleh kosong')),
      );
      return;
    }

    try {
      // Gabungkan tanggal dan waktu
      final taskDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      if (widget.task != null) {
        // Update existing task
        final updatedTask = widget.task!.copyWith(
          title: title,
          category: _selectedCategory,
          priority: _selectedPriority,
          date: taskDateTime,
          time: _selectedTime.format(context),
        );
        await _taskService.updateTask(updatedTask);
      } else {
        // Create new task
        final newTask = TaskModel(
          id: '', // Diisi oleh Firestore
          userId: '', // Diisi oleh TaskService
          title: title,
          category: _selectedCategory,
          priority: _selectedPriority,
          date: taskDateTime,
          time: _selectedTime.format(context),
          isCompleted: false,
          createdAt: DateTime.now(),
        );
        await _taskService.addTask(newTask);
        
        // Kirim notifikasi tugas baru
        await _notificationService.addNotification(NotificationModel(
          id: '',
          userId: '', // Handle by service
          title: 'Tugas Baru Dibuat 📝',
          desc: 'Tugas "${newTask.title}" telah ditambahkan ke kategori ${newTask.category}.',
          time: DateTime.now(),
          iconCode: Icons.add_task.codePoint,
          colorValue: AppColors.primary.toARGB32(),
        ));
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.task != null ? 'Tugas berhasil diperbarui' : 'Tugas berhasil dibuat')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan tugas: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 32,
        left: 32,
        right: 32,
        bottom: 32 + MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tugas Baru',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.onSurface,
                          ),
                    ),
                    const Text(
                      'Buat momen fokus',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.surfaceContainerHigh,
                    padding: const EdgeInsets.all(12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Task Name
            _buildLabel('NAMA TUGAS'),
            TextField(
              controller: _taskController,
              autofocus: true,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                hintText: 'Apa yang perlu diselesaikan?',
                hintStyle: const TextStyle(color: AppColors.outline),
                filled: true,
                fillColor: AppColors.surfaceContainerHigh,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(20),
              ),
            ),
            const SizedBox(height: 32),

            // Category Selection
            _buildLabel('KATEGORI'),
            StreamBuilder<List<dynamic>>( // Use dynamic to handle the hardcoded initial if empty
              stream: _categoryService.getCategories(),
              builder: (context, snapshot) {
                final categories = (snapshot.hasData && snapshot.data!.isNotEmpty)
                    ? snapshot.data!
                    : _categories; // Fallback to hardcoded if Firestore empty

                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: categories.map((cat) {
                    final isSelected = _selectedCategory == cat['label'];
                    final Color catColor = cat is Map ? cat['color'] : cat.color;
                    final IconData catIcon = cat is Map ? cat['icon'] : cat.icon;

                    return InkWell(
                      onTap: () => setState(() => _selectedCategory = cat['label']),
                      borderRadius: BorderRadius.circular(32),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? catColor.withValues(alpha: 0.3)
                              : AppColors.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(32),
                          border: isSelected
                              ? Border.all(color: catColor.withValues(alpha: 0.2), width: 2)
                              : null,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: catColor,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(14),
                                  topRight: Radius.circular(18),
                                  bottomLeft: Radius.circular(22),
                                  bottomRight: Radius.circular(10),
                                ),
                              ),
                              child: Icon(catIcon, color: Colors.white, size: 16),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              cat['label'],
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: isSelected ? AppColors.primary : AppColors.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 32),

            // Date & Time Grid
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('TANGGAL'),
                      InkWell(
                        onTap: _selectDate,
                        borderRadius: BorderRadius.circular(20),
                        child: _buildDateTimeContainer(
                          Icons.calendar_today,
                          DateFormat('dd MMM yyyy').format(_selectedDate),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('WAKTU'),
                      InkWell(
                        onTap: _selectTime,
                        borderRadius: BorderRadius.circular(20),
                        child: _buildDateTimeContainer(
                          Icons.schedule,
                          _selectedTime.format(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Priority Selection
            _buildLabel('PRIORITAS'),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: ['Rendah', 'Sedang', 'Tinggi'].map((p) {
                  final isSelected = _selectedPriority == p;
                  return Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _selectedPriority = p),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.surfaceContainerLowest : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  )
                                ]
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            p,
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                              color: isSelected ? AppColors.onSurface : AppColors.outline,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 40),

            // Create Button
            SizedBox(
              width: double.infinity,
              height: 64,
              child: ElevatedButton(
                onPressed: _handleCreateTask,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                  elevation: 8,
                  shadowColor: AppColors.primary.withValues(alpha: 0.4),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_task),
                    const SizedBox(width: 12),
                    const Text(
                      'Buat Tugas',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.5,
          color: AppColors.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildDateTimeContainer(IconData icon, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
