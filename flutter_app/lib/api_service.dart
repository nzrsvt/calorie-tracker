import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import 'models.dart';

class ApiService {
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

  Future<http.Response> _get(String url) async {
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 401) {
      await _authService.refreshToken();
      final newHeaders = await _getHeaders();
      return await http.get(Uri.parse(url), headers: newHeaders);
    }
    return response;
  }

  Future<http.Response> _post(String url, Map<String, dynamic> body) async {
    final headers = await _getHeaders();
    final response = await http.post(Uri.parse(url), headers: headers, body: jsonEncode(body));

    if (response.statusCode == 401) {
      await _authService.refreshToken();
      final newHeaders = await _getHeaders();
      return await http.post(Uri.parse(url), headers: newHeaders, body: jsonEncode(body));
    }
    return response;
  }

  Future<http.Response> _put(String url, Map<String, dynamic> body) async {
    final headers = await _getHeaders();
    final response = await http.put(Uri.parse(url), headers: headers, body: jsonEncode(body));

    if (response.statusCode == 401) {
      await _authService.refreshToken();
      final newHeaders = await _getHeaders();
      return await http.put(Uri.parse(url), headers: newHeaders, body: jsonEncode(body));
    }
    return response;
  }

  Future<http.Response> _delete(String url) async {
    final headers = await _getHeaders();
    final response = await http.delete(Uri.parse(url), headers: headers);

    if (response.statusCode == 401) {
      await _authService.refreshToken();
      final newHeaders = await _getHeaders();
      return await http.delete(Uri.parse(url), headers: newHeaders);
    }
    return response;
  }

  Future<List<FoodItem>> fetchFoodItems() async {
    final response = await _get('$baseUrl/fooditems/');
    if (response.statusCode == 200) {
      List jsonResponse = jsonDecode(response.body)['results'];
      return jsonResponse.map((data) => FoodItem.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load food items');
    }
  }

  Future<List<FoodItem>> searchFoodItems(String query) async {
    final response = await _get('$baseUrl/fooditems/?search=$query');
    if (response.statusCode == 200) {
      List jsonResponse = jsonDecode(response.body)['results'];
      return jsonResponse.map((data) => FoodItem.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load search results');
    }
  }

  Future<void> addFoodItem({
    required String name,
    required String producer,
    required int calories,
    double? protein,
    double? fat,
    double? carbohydrates,
    required double portionSize,
    required String quantityUnit,
  }) async {
    final response = await _post('$baseUrl/fooditems/', {
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
  }

  Future<void> addUserMeal(int foodItemId, double quantity) async {
    final response = await _post('$baseUrl/usermeals/', {
      'food_item': foodItemId,
      'quantity': quantity,
      'datetime': DateTime.now().toIso8601String(),
    });

    if (response.statusCode != 201) {
      throw Exception('Failed to add meal');
    }
  }

  Future<List<UserMeal>> fetchUserMeals() async {
    final response = await _get('$baseUrl/usermeals/');
    if (response.statusCode == 200) {
      List jsonResponse = jsonDecode(response.body)['results'];
      return jsonResponse.map((data) => UserMeal.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load user meals');
    }
  }

  Future<List<UserMeal>> fetchTodayUserMeals() async {
    final response = await _get('$baseUrl/usermeals/today/');
    if (response.statusCode == 200) {
      List jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((data) => UserMeal.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load todays user meals');
    }
  }

  Future<void> updateUserMeal(UserMeal meal) async {
    final response = await _put('$baseUrl/usermeals/${meal.id}/', meal.toJson());
    if (response.statusCode != 200) {
      throw Exception('Failed to update meal');
    }
  }

  Future<void> deleteUserMeal(int mealId) async {
    final response = await _delete('$baseUrl/usermeals/$mealId/');
    if (response.statusCode != 204) {
      throw Exception('Failed to delete meal');
    }
  }

  Future<UserProfile> fetchUserProfile() async {
    final response = await _get('$baseUrl/userprofile/');
    if (response.statusCode == 200) {
      return UserProfile.fromJson(jsonDecode(response.body)['results'][0]);
    } else {
      throw Exception('Failed to load user profile');
    }
  }

  Future<void> updateUserProfile(UserProfile profile) async {
    final response = await _put('$baseUrl/userprofile/${profile.id}/', profile.toJson());
    if (response.statusCode != 200) {
      throw Exception('Failed to update profile');
    }
  }
}
