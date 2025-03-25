import 'package:flutter/material.dart';

class LogItem {
  final String name;
  final int calories;
  final String? image;
  final DateTime timestamp;
  final LogItemType type;
  final List<MacroDetail>? macros;

  LogItem({
    required this.name,
    required this.calories,
    this.image,
    required this.timestamp,
    required this.type,
    this.macros,
  });
}

class MacroDetail {
  final String icon;
  final int value;

  MacroDetail({
    required this.icon,
    required this.value,
  });
}

enum LogItemType {
  meal,
  training,
}