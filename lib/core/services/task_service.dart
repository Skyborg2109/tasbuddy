import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../features/tasks/models/task_model.dart';

class TaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference get _tasksCollection => _firestore.collection('tasks');

  String? get _currentUserId => _auth.currentUser?.uid;

  // Stream of tasks for the current user
  Stream<List<TaskModel>> getTasksStream() {
    if (_currentUserId == null) return Stream.value([]);

    return _tasksCollection
        .where('userId', isEqualTo: _currentUserId)
        .snapshots()
        .map((snapshot) {
      final tasks = snapshot.docs.map((doc) {
        return TaskModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
      
      // Sort in memory to avoid needing composite indexes
      tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return tasks;
    });
  }

  // Stream of tasks for today
  Stream<List<TaskModel>> getTodayTasksStream() {
    if (_currentUserId == null) return Stream.value([]);

    return _tasksCollection
        .where('userId', isEqualTo: _currentUserId)
        .snapshots()
        .map((snapshot) {
      final now = DateTime.now();
      
      final tasks = snapshot.docs.map((doc) {
        return TaskModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).where((task) {
        // Filter tasks that are scheduled for today
        return task.date.year == now.year &&
               task.date.month == now.month &&
               task.date.day == now.day;
      }).toList();
      
      // Sort in memory
      tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return tasks;
    });
  }

  // Stream of tasks filtered by category
  Stream<List<TaskModel>> getTasksByCategoryStream(String category) {
    if (_currentUserId == null) return Stream.value([]);

    return _tasksCollection
        .where('userId', isEqualTo: _currentUserId)
        .where('category', isEqualTo: category)
        .snapshots()
        .map((snapshot) {
      final tasks = snapshot.docs.map((doc) {
        return TaskModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
      
      // Sort in memory
      tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return tasks;
    });
  }

  // Create a new task
  Future<void> addTask(TaskModel task) async {
    if (_currentUserId == null) return;
    
    final taskWithUserId = task.copyWith(userId: _currentUserId, createdAt: DateTime.now());
    await _tasksCollection.add(taskWithUserId.toMap());
  }

  // Update a task
  Future<void> updateTask(TaskModel task) async {
    await _tasksCollection.doc(task.id).update(task.toMap());
  }

  // Delete a task
  Future<void> deleteTask(String taskId) async {
    await _tasksCollection.doc(taskId).delete();
  }

  // Toggle task completion
  Future<void> toggleTaskCompletion(String taskId, bool isCompleted) async {
    await _tasksCollection.doc(taskId).update({'isCompleted': isCompleted});
  }
}
