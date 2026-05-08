import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../features/tasks/models/category_model.dart';

class CategoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userId => _auth.currentUser?.uid ?? '';

  CollectionReference get _categoryCollection =>
      _firestore.collection('users').doc(_userId).collection('categories');

  Stream<List<CategoryModel>> getCategories() {
    if (_userId.isEmpty) return Stream.value([]);
    return _categoryCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return CategoryModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  Future<void> addCategory(CategoryModel category) async {
    await _categoryCollection.add(category.toMap());
  }

  Future<void> updateCategory(CategoryModel category) async {
    await _categoryCollection.doc(category.id).update(category.toMap());
  }

  Future<void> deleteCategory(String categoryId) async {
    await _categoryCollection.doc(categoryId).delete();
  }

  // Initial categories if empty
  Future<void> seedInitialCategories() async {
    final snapshot = await _categoryCollection.get();
    if (snapshot.docs.isEmpty) {
      final initial = [
        {'label': 'Pekerjaan', 'icon': 0xe10e, 'color': 0xFF0066FF}, // Icons.work, Blue
        {'label': 'Pribadi', 'icon': 0xe25b, 'color': 0xFFFF4081}, // Icons.favorite, Pink
        {'label': 'Kesehatan', 'icon': 0xe28f, 'color': 0xFF4CAF50}, // Icons.fitness_center, Green
      ];
      for (var cat in initial) {
        await _categoryCollection.add({
          'userId': _userId,
          'label': cat['label'],
          'iconCode': cat['icon'],
          'colorValue': cat['color'],
        });
      }
    }
  }
}
