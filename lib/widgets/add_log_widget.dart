import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/logs_notifier.dart';

class AddLogWidget extends StatelessWidget {
  const AddLogWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF5F5DC), Color(0xFFE5E5DB)],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: EdgeInsets.symmetric(vertical: 10),
            width: 50,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              'Add Log',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),

          // Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                LogActionButton(
                  icon: Icons.search,
                  label: 'Describe Food',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/describe-food');
                  },
                ),
                LogActionButton(
                  icon: Icons.bookmark,
                  label: 'Saved',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/saved-items');
                  },
                ),
                LogActionButton(
                  icon: Icons.qr_code_scanner,
                  label: 'Scan',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/food-scanner');
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
  void _showScanOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('AI Food Recognition'),
              onTap: () {
                Navigator.pop(context);
                ref.read(logsProvider.notifier).addLogItemByAiScan(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.qr_code),
              title: Text('Barcode Scan'),
              onTap: () {
                Navigator.pop(context);
                ref.read(logsProvider.notifier).addLogItemByBarcode(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class LogActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const LogActionButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 90,  // Wider button
            height: 90,  // Added height
            decoration: BoxDecoration(
              color: Colors.grey[100],  // Light grey background
              borderRadius: BorderRadius.circular(15),
            ),
            child: Center(
              child: Icon(
                icon,
                size: 40,  // Larger icon
                color: Colors.black,
              ),
            ),
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,  // Slightly larger text
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}