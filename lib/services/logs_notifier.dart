import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../models/log_item.dart';
import 'nutrition_api_service.dart';

// Providers
final nutritionApiServiceProvider = Provider((ref) => NutritionApiService());

class LogsNotifier extends StateNotifier<List<LogItem>> {
  final NutritionApiService _nutritionService;

  LogsNotifier(this._nutritionService) : super([]);

  Future<void> addLogItemByDescription(
      BuildContext context,
      String foodDescription,
      ) async {
    // Show loading dialog
    _showLoadingDialog(context);

    try {
      final logItem = await _nutritionService.getNutritionByDescription(foodDescription);

      // Close loading dialog
      Navigator.of(context).pop();

      if (logItem != null) {
        await _showFoodDetailsDialog(context, logItem);
      } else {
        _showErrorDialog(context, 'Could not find nutrition information');
      }
    } catch (e) {
      // Close loading dialog
      Navigator.of(context).pop();
      _showErrorDialog(context, 'An error occurred: $e');
    }
  }

  Future<void> addLogItemByBarcode(BuildContext context) async {
    try {
      // Scan barcode
      String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          "#ff6666",
          "Cancel",
          true,
          ScanMode.BARCODE
      );

      if (barcodeScanRes != '-1') {
        // Show loading
        _showLoadingDialog(context);

        final logItem = await _nutritionService.getNutritionByBarcode(barcodeScanRes);

        // Close loading dialog
        Navigator.of(context).pop();

        if (logItem != null) {
          await _showFoodDetailsDialog(context, logItem);
        } else {
          _showErrorDialog(context, 'Could not find nutrition for this barcode');
        }
      }
    } catch (e) {
      _showErrorDialog(context, 'Barcode scanning error: $e');
    }
  }

  Future<void> addLogItemByAiScan(BuildContext context) async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.camera);

      if (pickedFile != null) {
        // Show loading
        _showLoadingDialog(context);

        // Here you would integrate an AI food recognition service
        // For now, we'll use a manual description approach
        final fileName = pickedFile.path.split('/').last;

        // Close loading dialog
        Navigator.of(context).pop();

        // Prompt user to describe the food
        await _showAiScanDescriptionDialog(context, fileName);
      }
    } catch (e) {
      _showErrorDialog(context, 'AI Scan error: $e');
    }
  }

  Future<void> _showFoodDetailsDialog(BuildContext context, LogItem logItem) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Food Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${logItem.name}', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Calories: ${logItem.calories.toStringAsFixed(2)}'),
            SizedBox(height: 10),
            Text('Macros:'),
            ...logItem.macros.map((macro) =>
                Text('${macro.icon}: ${macro.value.toStringAsFixed(2)}')
            ).toList(),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Add the log item to the state
              state = [...state, logItem];
              Navigator.of(context).pop();
            },
            child: Text('Add to Logs'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAiScanDescriptionDialog(BuildContext context, String fileName) async {
    final TextEditingController controller = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Describe the Food'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
              hintText: 'Enter food description based on the image'
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await addLogItemByDescription(context, controller.text);
            },
            child: Text('Look Up Nutrition'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Processing Food...'),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}

// Provider for logs state
final logsProvider = StateNotifierProvider<LogsNotifier, List<LogItem>>((ref) {
  return LogsNotifier(ref.read(nutritionApiServiceProvider));
});