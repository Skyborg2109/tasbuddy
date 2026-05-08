import 'package:flutter/material.dart';

class CategoryModel {
  final String id;
  final String userId;
  final String label;
  final int iconCode;
  final int colorValue;

  CategoryModel({
    required this.id,
    required this.userId,
    required this.label,
    required this.iconCode,
    required this.colorValue,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'label': label,
      'iconCode': iconCode,
      'colorValue': colorValue,
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map, String id) {
    return CategoryModel(
      id: id,
      userId: map['userId'] ?? '',
      label: map['label'] ?? '',
      iconCode: map['iconCode'] ?? Icons.folder.codePoint,
      colorValue: map['colorValue'] ?? Colors.blue.toARGB32(),
    );
  }

  IconData get icon => IconData(iconCode, fontFamily: 'MaterialIcons');
  Color get color => Color(colorValue);
}
