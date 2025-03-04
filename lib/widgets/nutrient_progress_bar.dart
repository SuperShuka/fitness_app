import 'package:flutter/material.dart';

class NutrientProgressBar extends StatelessWidget {
  final String label;
  final double value;
  final double target;
  final Color color;

  const NutrientProgressBar({
    Key? key,
    required this.label,
    required this.value,
    required this.target,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double percentage = (target > 0) ? (value / target).clamp(0.0, 1.0) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${value.toInt()}/${target.toInt()} g',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Stack(
          children: [
            Container(
              height: 10,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            // Progress indicator
            Container(
              height: 10,
              width: MediaQuery.of(context).size.width * percentage * 0.8,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ],
        ),
      ],
    );
  }
}