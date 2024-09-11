import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import 'models.dart';
import 'base_repository.dart';

class ApiService extends BaseRepository {
  final String baseUrl = 'http://10.0.2.2:8000';
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _getHeaders() async {
    String? token = await _authService.getAccessToken();
    if (token == null) {
      throw Exception('Access token not found');
    }
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };
  }

  Future<http.Response> _get(BuildContext context, String url) async {
    return await call(context, () async {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 401) {
        await _authService.refreshTokenWithContext(context);
        final newHeaders = await _getHeaders();
        return await http.get(Uri.parse(url), headers: newHeaders);
      }
      return response;
    });
  }

  Future<http.Response> _post(BuildContext context, String url, Map<String, dynamic> body) async {
    return await call(context, () async {
      final headers = await _getHeaders();
      final response = await http.post(Uri.parse(url), headers: headers, body: jsonEncode(body));
      if (response.statusCode == 401) {
        await _authService.refreshTokenWithContext(context);
        final newHeaders = await _getHeaders();
        return await http.post(Uri.parse(url), headers: newHeaders, body: jsonEncode(body));
      }
      return response;
    });
  }

  Future<http.Response> _put(BuildContext context, String url, Map<String, dynamic> body) async {
    return await call(context, () async {
      final headers = await _getHeaders();
      final response = await http.put(Uri.parse(url), headers: headers, body: jsonEncode(body));
      if (response.statusCode == 401) {
        await _authService.refreshTokenWithContext(context);
        final newHeaders = await _getHeaders();
        return await http.put(Uri.parse(url), headers: newHeaders, body: jsonEncode(body));
      }
      return response;
    });
  }

  Future<http.Response> _delete(BuildContext context, String url) async {
    return await call(context, () async {
      final headers = await _getHeaders();
      final response = await http.delete(Uri.parse(url), headers: headers);
      if (response.statusCode == 401) {
        await _authService.refreshTokenWithContext(context);
        final newHeaders = await _getHeaders();
        return await http.delete(Uri.parse(url), headers: newHeaders);
      }
      return response;
    });
  }

  Future<List<FoodItem>> fetchFoodItems(BuildContext context) async {
    return await call(context, () async {
      final response = await _get(context, '$baseUrl/fooditems/');
      if (response.statusCode == 200) {
        List jsonResponse = jsonDecode(utf8.decode(response.bodyBytes))['results'];
        return jsonResponse.map((data) => FoodItem.fromJson(data)).toList();
      } else {
        throw Exception('Failed to load food items');
      }
    });
  }

  Future<List<FoodItem>> searchFoodItems(BuildContext context, String query) async {
    return await call(context, () async {
      final response = await _get(context, '$baseUrl/fooditems/?search=$query');
      if (response.statusCode == 200) {
        List jsonResponse = jsonDecode(utf8.decode(response.bodyBytes))['results'];
        return jsonResponse.map((data) => FoodItem.fromJson(data)).toList();
      } else {
        throw Exception('Failed to load search results');
      }
    });
  }

  Future<void> addFoodItem(BuildContext context, {
    required String name,
    required String producer,
    required int calories,
    double? protein,
    double? fat,
    double? carbohydrates,
    required double portionSize,
    required String quantityUnit,
  }) async {
    return await call(context, () async {
      final response = await _post(context, '$baseUrl/fooditems/', {
        'name': name,
        'producer': producer,
        'calories': calories,
        'protein': protein ?? 0,
        'fat': fat ?? 0,
        'carbohydrates': carbohydrates ?? 0,
        'portion_size': portionSize,
        'quantity_unit': quantityUnit,
      });

      if (response.statusCode != 201) {
        throw Exception('Failed to add food item');
      }
    });
  }

  Future<void> addUserMeal(BuildContext context, int foodItemId, double quantity, String mealType) async {
    return await call(context, () async {
      final response = await _post(context, '$baseUrl/usermeals/', {
        'food_item': foodItemId,
        'quantity': quantity,
        'meal_type': mealType,
        'datetime': DateTime.now().toIso8601String(),
      });

      if (response.statusCode != 201) {
        throw Exception('Failed to add meal');
      }
    });
  }

  Future<List<UserMeal>> fetchUserMeals(BuildContext context) async {
    return await call(context, () async {
      final response = await _get(context, '$baseUrl/usermeals/');
      if (response.statusCode == 200) {
        List jsonResponse = jsonDecode(utf8.decode(response.bodyBytes))['results'];
        return jsonResponse.map((data) => UserMeal.fromJson(data)).toList();
      } else {
        throw Exception('Failed to load user meals');
      }
    });
  }

  Future<List<UserMeal>> fetchTodayUserMeals(BuildContext context) async {
    return await call(context, () async {
      final response = await _get(context, '$baseUrl/usermeals/today/');
      if (response.statusCode == 200) {
        List jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        return jsonResponse.map((data) => UserMeal.fromJson(data)).toList();
      } else {
        throw Exception('Failed to load todays user meals');
      }
    });
  }

  Future<void> updateUserMeal(BuildContext context, UserMeal meal) async {
    return await call(context, () async {
      final response = await _put(context, '$baseUrl/usermeals/${meal.id}/', meal.toJson());
      if (response.statusCode != 200) {
        throw Exception('Failed to update meal');
      }
    });
  }

  Future<void> deleteUserMeal(BuildContext context, int mealId) async {
    return await call(context, () async {
      final response = await _delete(context, '$baseUrl/usermeals/$mealId/');
      if (response.statusCode != 204) {
        throw Exception('Failed to delete meal');
      }
    });
  }

  Future<UserProfile> fetchUserProfile(BuildContext context) async {
    return await call(context, () async {
      final response = await _get(context, '$baseUrl/userprofile/');
      if (response.statusCode == 200) {
        return UserProfile.fromJson(jsonDecode(response.body)['results'][0]);
      } else {
        throw Exception('Failed to load user profile');
      }
    });
  }

  Future<void> updateUserProfile(BuildContext context, UserProfile profile) async {
    return await call(context, () async {
      final response = await _put(context, '$baseUrl/userprofile/${profile.id}/', profile.toJson());
      if (response.statusCode != 200) {
        throw Exception('Failed to update profile');
      }
    });
  }

  Future<Map<String, dynamic>> calculateNutritionalValue(BuildContext context, String description) async {
    return await call(context, () async {
      final response = await _post(context, '$baseUrl/fooditems/calculate_nutritional_value/', {'description': description});
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to calculate nutritional value');
      }
    });
  }

  Future<String> getAiAdvice(BuildContext context, String mealType) async {
    return await call(context, () async {
      final response = await _post(
        context, 
        '$baseUrl/usermeals/ai_advice/', 
        {'meal_type': mealType}
      );
      
      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw Exception('Failed to get AI advice');
      }
    });
  }

  
}