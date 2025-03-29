import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner_plus/flutter_barcode_scanner_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:openfoodfacts/openfoodfacts.dart';

import '../models/log_item.dart';
import 'firestore_logs_service.dart';
import 'nutrition_api_service.dart';

// Providers
final nutritionApiServiceProvider = Provider((ref) => NutritionApiService());
final firebaseLogsServiceProvider = Provider((ref) => FirebaseLogsService());

class LogsNotifier extends StateNotifier<List<LogItem>> {
  final NutritionApiService _nutritionService;
  final FirebaseLogsService _firebaseLogsService;

  LogsNotifier(this._nutritionService, this._firebaseLogsService) : super([]);

  Future<void> addLogItemByDescription(
      BuildContext context,
      String foodDescription,
      ) async {
    try {
      final logItems = await _nutritionService.getNutritionByDescription(foodDescription);

      if (logItems != []) {
        for (var logItem in logItems) {
          await _firebaseLogsService.addLogItem(logItem);
        }
      } else {
        _showErrorDialog(context, 'Could not find nutrition information');
      }
    } catch (e) {
      Navigator.of(context).pop();
      _showErrorDialog(context, 'An error occurred: $e');
    }
  }

  Future<void> addLogItemByBarcode() async {
    try {
      OpenFoodAPIConfiguration.userAgent = UserAgent(name: 'fitness_app');

      OpenFoodAPIConfiguration.globalLanguages = <OpenFoodFactsLanguage>[OpenFoodFactsLanguage.RUSSIAN, OpenFoodFactsLanguage.ENGLISH];

      String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          "#ff6666", // Color of the scan screen
          "Cancel",  // Cancel button text
          true,      // Show flash icon
          ScanMode.BARCODE // Scan mode
      );

      if (barcodeScanRes != '-1') {
        final logItem = await _nutritionService.getNutritionByBarcode(barcodeScanRes);

        if (logItem != null) {
          await _firebaseLogsService.addLogItem(logItem);
        } else {
          print('Could not find nutrition for this barcode');
        }
      }
    } catch (e) {
      print('Barcode scanning error: $e');
    }
  }

  Future<void> addLogItemByAiScan(BuildContext context) async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.camera);

      if (pickedFile != null) {

        // Here you would integrate an AI food recognition service
        // For now, we'll use a manual description approach
        final fileName = pickedFile.path.split('/').last;

        // Close loading dialog
        Navigator.of(context).pop();

      }
    } catch (e) {
      _showErrorDialog(context, 'AI Scan error: $e');
    }
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

  Future<void> syncLogsToFirebase() async {
    try {
      await _firebaseLogsService.syncLogsToFirebase(state);
    } catch (e) {
      print('Error syncing logs to Firebase: $e');
    }
  }

  Future<void> loadLogsFromFirebase(DateTime date) async {
    try {
      final logsStream = _firebaseLogsService.getLogs(date);
      logsStream.listen((logs) {
        state = logs;
      });
    } catch (e) {
      print('Error loading logs from Firebase: $e');
    }
  }

  void addLogItem(LogItem logItem) {
    state = [...state, logItem];
    syncLogsToFirebase();
  }
}

// Provider for logs state
final logsProvider = StateNotifierProvider<LogsNotifier, List<LogItem>>((ref) {
  return LogsNotifier(
      ref.read(nutritionApiServiceProvider),
      ref.read(firebaseLogsServiceProvider)
  );
});