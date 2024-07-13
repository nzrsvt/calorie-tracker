import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';

class ApiService {
  final String baseUrl = 'http://10.0.2.2:8000';

  Future<void> register(String username, String password, String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/register/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': username,
        'password': password,
        'email': email,
      }),
    );

    if (response.statusCode == 201) {
      // Registration successful
    } else {
      throw Exception('Failed to register');
    }
  }

  Future<void> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/token/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('access', data['access']);
      await prefs.setString('refresh', data['refresh']);
    } else {
      throw Exception('Failed to login');
    }
  }

  Future<List<FoodItem>> fetchFoodItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access') ?? '';

    final response = await http.get(
      Uri.parse('$baseUrl/fooditems/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List jsonResponse = jsonDecode(response.body)['results'];
      return jsonResponse.map((data) => FoodItem.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load food items');
    }
  }

  Future<List<FoodItem>> searchFoodItems(String query) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access') ?? '';

    final response = await http.get(
      Uri.parse('$baseUrl/fooditems/?search=$query'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List jsonResponse = jsonDecode(response.body)['results'];
      return jsonResponse.map((data) => FoodItem.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load search results');
    }
  }

  Future<void> addUserMeal(int foodItemId, double quantity) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access') ?? '';

    final response = await http.post(
      Uri.parse('$baseUrl/usermeals/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, dynamic>{
        'food_item': foodItemId,
        'quantity': quantity,
        'datetime': DateTime.now().toIso8601String(),
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add meal');
    }
  }

  Future<List<UserMeal>> fetchUserMeals() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access') ?? '';

    final response = await http.get(
      Uri.parse('$baseUrl/usermeals/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List jsonResponse = jsonDecode(response.body)['results'];
      return jsonResponse.map((data) => UserMeal.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load user meals');
    }
  }
}
