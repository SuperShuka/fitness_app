import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/log_item.dart';
import '../utils/debug_print.dart';

class NutritionApiService {
  static const String appId = 'abf1ae27';
  static const String apiKey = '2c8f12ecd62f5367303ecccd3df5e55f';
  static const String baseUrl = 'https://trackapi.nutritionix.com/v2/natural/nutrients';

  Future<LogItem?> getNutritionByDescription(String foodDescription) async {
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
        dPrint(data);
        dPrint(data['foods'].length);
        if (data['foods'] != null && data['foods'].isNotEmpty) {
          final food = data['foods'][0];

          return LogItem(
            name: food['food_name'] ?? foodDescription,
            calories: food['nf_calories']?.toInt() ?? 0.0,
            timestamp: DateTime.now(),
            type: LogItemType.meal,
            macros: [
              MacroDetail(
                  icon: '🍗',
                  value: food['nf_protein']?.toInt() ?? 0.0
              ),
              MacroDetail(
                  icon: '🍞',
                  value: food['nf_total_carbohydrate']?.toInt() ?? 0.0
              ),
              MacroDetail(
                  icon: '🧀',
                  value: food['nf_total_fat']?.toInt() ?? 0.0
              ),
            ],
          );
        }
      }
    } catch (e) {
      print('Nutrition API Error: $e');
    }
    return null;
  }

  // Barcode nutrition lookup
  Future<LogItem?> getNutritionByBarcode(String barcode) async {
    try {
      final response = await http.get(
        Uri.parse('https://trackapi.nutritionix.com/v2/search/item?upc=$barcode'),
        headers: {
          'x-app-id': appId,
          'x-app-key': apiKey,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['foods'] != null && data['foods'].isNotEmpty) {
          final food = data['foods'][0];

          return LogItem(
            name: food['food_name'] ?? 'Scanned Item',
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
          );
        }
      }
    } catch (e) {
      print('Barcode Lookup Error: $e');
    }
    return null;
  }
}