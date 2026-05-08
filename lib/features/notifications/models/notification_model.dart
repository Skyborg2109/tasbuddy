import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String desc;
  final DateTime time;
  final bool isRead;
  final int iconCode;
  final int colorValue;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.desc,
    required this.time,
    this.isRead = false,
    required this.iconCode,
    required this.colorValue,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'desc': desc,
      'time': Timestamp.fromDate(time),
      'isRead': isRead,
      'iconCode': iconCode,
      'colorValue': colorValue,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map, String id) {
    return NotificationModel(
      id: id,
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      desc: map['desc'] ?? '',
      time: (map['time'] as Timestamp).toDate(),
      isRead: map['isRead'] ?? false,
      iconCode: map['iconCode'] ?? Icons.notifications.codePoint,
      colorValue: map['colorValue'] ?? Colors.blue.toARGB32(),
    );
  }

  IconData get icon => IconData(iconCode, fontFamily: 'MaterialIcons');
  Color get color => Color(colorValue);
}
