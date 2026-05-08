import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../features/notifications/models/notification_model.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userId => _auth.currentUser?.uid ?? '';

  CollectionReference get _notificationCollection =>
      _firestore.collection('users').doc(_userId).collection('notifications');

  Stream<List<NotificationModel>> getNotifications() {
    if (_userId.isEmpty) return Stream.value([]);
    return _notificationCollection
        .orderBy('time', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return NotificationModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  Future<void> addNotification(NotificationModel notification) async {
    await _notificationCollection.add(notification.toMap());
  }

  Future<void> markAsRead(String notificationId) async {
    await _notificationCollection.doc(notificationId).update({'isRead': true});
  }

  Future<void> markAllAsRead() async {
    final snapshot = await _notificationCollection.where('isRead', isEqualTo: false).get();
    for (var doc in snapshot.docs) {
      await doc.reference.update({'isRead': true});
    }
  }

  // Helper to send a welcome notification
  Future<void> sendWelcomeNotification() async {
    final notification = NotificationModel(
      id: '',
      userId: _userId,
      title: 'Selamat Datang di TaskBuddy! 🚀',
      desc: 'Mulai kelola tugas harianmu dengan lebih efisien mulai hari ini.',
      time: DateTime.now(),
      iconCode: 0xe14c, // celebration
      colorValue: 0xFFFF9800, // orange
    );
    await addNotification(notification);
  }
}
