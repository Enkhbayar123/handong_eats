import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class NutritionApiService {
  static const String _apiKey = "DEMO_KEY"; // USDA public demo key

  static final Map<String, String> _koreanToEnglishMap = {
    '콩나물해장국': 'Bean Sprout Soup',
    'dwaeji-gukbap': 'Pork Soup',
    'jjimdak': 'Soy Sauce Braised Chicken',
    'tteok-bokki': 'Spicy Rice Cakes',
    'tangsuyuk': 'Sweet and Sour Pork',
    'jajangmyeon': 'Black Bean Noodles',
    'jjamppong': 'Spicy Seafood Noodle Soup',
    'yukgaejang': 'Spicy Beef Soup',
    'sundubu-jjigae': 'Soft Tofu Stew',
    'kimchi-jjigae': 'Kimchi Stew',
    'kal-guksu': 'Noodle Soup',
  };

  static Future<Map<String, int>> fetchNutrients(String foodName) async {
    if (foodName.isEmpty) {
      return {};
    }

    // Translate to English query if needed
    final normalizedKey = foodName.toLowerCase();
    String queryName = foodName;
    if (_koreanToEnglishMap.containsKey(normalizedKey)) {
      queryName = _koreanToEnglishMap[normalizedKey]!;
    } else {
      // Find matching substring key
      for (var entry in _koreanToEnglishMap.entries) {
        if (normalizedKey.contains(entry.key)) {
          queryName = entry.value;
          break;
        }
      }
    }

    try {
      final query = Uri.encodeComponent(queryName);
      final url = Uri.parse(
        "https://api.nal.usda.gov/fdc/v1/foods/search?query=$query&pageSize=1&api_key=$_apiKey"
      );

      final response = await http.get(url).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data != null && data['foods'] != null && (data['foods'] as List).isNotEmpty) {
          final food = data['foods'][0];
          final nutrientsList = food['foodNutrients'] as List? ?? [];

          int calories = 0;
          int protein = 0;
          int carbs = 0;
          int fat = 0;

          for (var item in nutrientsList) {
            final name = (item['nutrientName'] as String? ?? '').toLowerCase();
            final value = (item['value'] as num? ?? 0).round();

            if (name.contains('energy') && (item['unitName'] == 'KCAL' || item['unitName'] == 'kcal')) {
              calories = value;
            } else if (name.contains('protein')) {
              protein = value;
            } else if (name.contains('carbohydrate')) {
              carbs = value;
            } else if (name.contains('total lipid') || name == 'fat') {
              fat = value;
            }
          }

          if (calories > 0 || protein > 0 || carbs > 0 || fat > 0) {
            debugPrint("Successfully fetched nutrients from USDA API for $foodName ($queryName): kcal=$calories, P=$protein, C=$carbs, F=$fat");
            return {
              'calories': calories,
              'protein': protein,
              'carbs': carbs,
              'fat': fat,
            };
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching nutrients from USDA API for $foodName ($queryName): $e");
    }

    return {};
  }
}
