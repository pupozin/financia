import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CategoryHelper {
  static IconData getIcon(String category) {
    switch (category.toLowerCase()) {
      case 'home':
        return FontAwesomeIcons.house;
      case 'health':
        return FontAwesomeIcons.heartPulse;
      case 'travel':
        return FontAwesomeIcons.plane;
      case 'food':
        return FontAwesomeIcons.burger;
      case 'study':
        return FontAwesomeIcons.book;
      case 'entertainment':
        return FontAwesomeIcons.tv;
      default:
        return FontAwesomeIcons.circle; // categoria genérica
    }
  }

  static Color getColor(String category) {
    switch (category.toLowerCase()) {
      case 'home':
        return Colors.purple;
      case 'health':
        return const Color(0xFFB94B65);
      case 'travel':
        return Colors.grey;
      case 'food':
        return const Color(0xFFCE9144);
      case 'study':
        return const Color(0xFF774545);
      case 'entertainment':
        return Colors.deepPurpleAccent;
      default:
        return Colors.white;
    }
  }
}
