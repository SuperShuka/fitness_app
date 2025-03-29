import 'package:flutter/material.dart';

class LogItem {
  final String name;
  final int calories;
  final DateTime timestamp;
  final LogItemType type;
  final List<MacroDetail>? macros;
  final double? weight; // Add weight property
  final double? baseWeight; // Add base weight for original recipe

  LogItem({
    required this.name,
    required this.calories,
    required this.timestamp,
    required this.type,
    this.macros,
    this.weight,
    this.baseWeight,
  });

  // Method to calculate adjusted macros based on weight
  LogItem adjustMacrosByWeight() {
    if (baseWeight == null || weight == null || macros == null) return this;

    // Calculate weight scaling factor
    double scaleFactor = weight! / baseWeight!;

    // Adjust macros based on weight
    List<MacroDetail> adjustedMacros = macros!.map((macro) {
      return MacroDetail(
        icon: macro.icon,
        value: (macro.value * scaleFactor).round(),
      );
    }).toList();

    // Adjust calories proportionally
    int adjustedCalories = (calories * scaleFactor).round();

    return LogItem(
      name: name,
      calories: adjustedCalories,
      timestamp: timestamp,
      type: type,
      macros: adjustedMacros,
      weight: weight,
      baseWeight: baseWeight,
    );
  }
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