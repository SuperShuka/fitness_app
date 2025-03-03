import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fitness_app/services/nutrition_service.dart';

class FitnessService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final NutritionService _nutritionService = NutritionService();
  final Health _health = Health();

  // Get current user ID
  String get _userId => _auth.currentUser!.uid;

  // Types of data we want to read from Health Platform
  final List<HealthDataType> _types = [
    HealthDataType.STEPS,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.DISTANCE_WALKING_RUNNING,
    HealthDataType.WEIGHT,
    HealthDataType.HEIGHT,
  ];

  // Request permissions for health data
  Future<bool> requestPermissions() async {
    // First request general permissions
    final status = await Permission.activityRecognition.request();
    if (status != PermissionStatus.granted) return false;

    // Then request Health permissions
    try {
      final permissions = _types.map((type) => HealthDataAccess.READ).toList();
      final requestStatus = await _health.requestAuthorization(_types, permissions: permissions);
      return requestStatus;
    } catch (e) {
      print('Error requesting health permissions: $e');
      return false;
    }
  }

  // Sync data from fitness platforms
  Future<void> syncFitnessData() async {
    try {
      final now = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day);

      // Request steps data
      final steps = await _health.getHealthDataFromTypes(
        startTime: midnight,
        endTime: now,
        types: [HealthDataType.STEPS],
      );

      // Request calories burned
      final calories = await _health.getHealthDataFromTypes(
        startTime: midnight,
        endTime: now,
        types: [HealthDataType.ACTIVE_ENERGY_BURNED],
      );

      // Calculate totals
      final totalSteps = steps.fold(0.0, (sum, data) => sum + (double.tryParse(data.value.toString()) ?? 0));
      final totalCalories = calories.fold(0.0, (sum, data) => sum + (double.tryParse(data.value.toString()) ?? 0));

      // Update daily log with fitness data
      if (totalCalories > 0) {
        await _nutritionService.updateCaloriesBurned(totalCalories);
      }

      // Update user document with latest fitness data
      await _db.collection('users').doc(_userId).update({
        'latestSyncData': {
          'steps': totalSteps,
          'caloriesBurned': totalCalories,
          'syncTime': now.toIso8601String(),
        }
      });
    } catch (e) {
      print('Error syncing fitness data: $e');
    }
  }

  // Get latest weight from fitness platforms
  Future<double?> syncLatestWeight() async {
    try {
      final now = DateTime.now();
      final lastMonth = now.subtract(Duration(days: 30));

      final weightData = await _health.getHealthDataFromTypes(
        types: [HealthDataType.WEIGHT],
        startTime: lastMonth,
        endTime:  now,
      );

      if (weightData.isNotEmpty) {
        // Sort by date, newest first
        weightData.sort((a, b) => b.dateFrom.compareTo(a.dateFrom));

        // Get latest weight
        final latestWeight = double.tryParse(weightData.first.value.toString());

        if (latestWeight != null) {
          // Update user's weight in profile
          await _db.collection('users').doc(_userId).update({
            'weight': latestWeight,
          });

          // Log weight in today's entry
          await _nutritionService.logWeight(latestWeight);

          return latestWeight;
        }
      }

      return null;
    } catch (e) {
      print('Error syncing weight data: $e');
      return null;
    }
  }
}
