import 'package:flutter/material.dart';

class Category {
  final String id;
  final String name;
  final String description;
  final Color color;

  Category({
    required this.id,
    required this.name,
    required this.description,
    required this.color,
  });

  factory Category.fromMap(Map<String, dynamic> data, String documentId) {
    return Category(
      id: documentId,
      name: data['name'],
      description: data['description'],
      color: Color(data['color']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'color': color.value,
    };
  }
}
