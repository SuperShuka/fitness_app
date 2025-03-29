import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:openfoodfacts/openfoodfacts.dart';
import 'dart:convert';
import '../models/log_item.dart';
import '../utils/debug_print.dart';

class NutritionApiService {
  static const String appId = 'abf1ae27';
  static const String apiKey = '2c8f12ecd62f5367303ecccd3df5e55f';
  static const String baseUrl = 'https://trackapi.nutritionix.com/v2/natural/nutrients';

  Future<List<LogItem>> getNutritionByDescription(String foodDescription) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'x-app-id': appId,
          'x-app-key': apiKey,
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'query': foodDescription,
        }),
      );


      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<LogItem> logItems = [];

        for (var food in data['foods']) {
          logItems.add(LogItem(
            name: food['food_name'] ?? foodDescription,
            calories: food['nf_calories']?.toDouble() ?? 0.0,
            timestamp: DateTime.now(),
            type: LogItemType.meal,
            macros: [
              MacroDetail(
                  icon: '🍗',
                  value: food['nf_protein']?.toDouble() ?? 0.0
              ),
              MacroDetail(
                  icon: '🍞',
                  value: food['nf_total_carbohydrate']?.toDouble() ?? 0.0
              ),
              MacroDetail(
                  icon: '🧀',
                  value: food['nf_total_fat']?.toDouble() ?? 0.0
              ),
            ],
            weight: food['serving_weight_grams']?.toInt() ?? 0,
          ));
        }

        return logItems;
      }
    } catch (e) {
      print('Nutrition API Error: $e');
    }
    return [];
  }

  Future<LogItem?> getNutritionByBarcode(String barcode) async {
    try {

      OpenFoodAPIConfiguration.userAgent = UserAgent(name: 'fitness_app');

      OpenFoodAPIConfiguration.globalLanguages = <OpenFoodFactsLanguage>[OpenFoodFactsLanguage.RUSSIAN, OpenFoodFactsLanguage.ENGLISH];
      ProductResultV3 result = await OpenFoodAPIClient.getProductV3(ProductQueryConfiguration(
        barcode,
        language: OpenFoodFactsLanguage.RUSSIAN, version: ProductQueryVersion.v3,
      ));

      if (result.product != null) {
        final product = result.product!;

        return LogItem(
          name: product.productName ?? 'Scanned Item',
          calories: product.nutriments?.getValue(Nutrient.energyKCal, PerSize.oneHundredGrams)?.toDouble() ?? 0.0,
          timestamp: DateTime.now(),
          type: LogItemType.meal,
          macros: [
            MacroDetail(
              icon: '🍗',
              value: product.nutriments?.getValue(Nutrient.proteins, PerSize.oneHundredGrams)?.toDouble() ?? 0.0,
            ),
            MacroDetail(
              icon: '🍞',
              value: product.nutriments?.getValue(Nutrient.carbohydrates, PerSize.oneHundredGrams)?.toDouble() ?? 0.0,
            ),
            MacroDetail(
              icon: '🧀',
              value: product.nutriments?.getValue(Nutrient.fat, PerSize.oneHundredGrams)?.toDouble() ?? 0.0,
            ),
          ],
          weight: 100,
        );
      }
    } catch (e) {
      print('OpenFoodFacts Barcode Lookup Error: $e');
    }
    return null;
  }
}