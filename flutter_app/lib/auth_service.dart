import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'exceptions.dart';
import 'base_repository.dart';

class AuthService extends BaseRepository {
  final String baseUrl = 'http://10.0.2.2:8000';
  final storage = const FlutterSecureStorage();

  Future<void> register(BuildContext context, String username, String email, String password, String gender, int age, int height, double weight, String activityLevel, String goal) async {
    return await call(context, () async {
      final response = await http.post(
        Uri.parse('$baseUrl/api/register/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'username': username,
          'email': email,
          'password': password,
          'gender': gender,
          'age': age,
          'height': height,
          'weight': weight,
          'activity_level': activityLevel,
          'goal': goal,
        }),
      );
      if (response.statusCode != 201) {
        throw Exception('Failed to register');
      }
    });
  }

  Future<void> login(BuildContext context, String username, String password) async {
    return await call(context, () async {
      final response = await http.post(
        Uri.parse('$baseUrl/api/token/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await storage.write(key: 'accessToken', value: data['access']);
        await storage.write(key: 'refreshToken', value: data['refresh']);
      } else {
        throw Exception('Failed to login');
      }
    });
  }

  Future<void> logout() async {
    await storage.delete(key: 'accessToken');
    await storage.delete(key: 'refreshToken');
  }

  Future<void> refreshTokenWithContext(BuildContext context) async {
    return await call(context, () async {
      await refreshToken();
    });
  }

  Future<void> refreshToken() async {
    final refreshToken = await storage.read(key: 'refreshToken');
    if (refreshToken == null) {
      throw Exception('Refresh token not found');
    }
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/token/refresh/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh': refreshToken}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await storage.write(key: 'accessToken', value: data['access']);
        await testAccessToken(data['access']);
      } else {
        await logout();
        throw TokenExpiredException('Failed to refresh token');
      }
    } catch (e) {
      await logout();
      throw TokenExpiredException('Failed to refresh token: $e');
    }
  }

  Future<String?> getAccessToken() async {
    return await storage.read(key: 'accessToken');
  }

  Future<String?> getRefreshToken() async {
    return await storage.read(key: 'refreshToken');
  }

  Future<int> testAccessToken(String accessToken) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/auth/verify/'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );
      if (response.statusCode != 200) {
        throw TokenExpiredException();
      }
      return response.statusCode;
    } catch (e) {
      throw TokenExpiredException();
    }
  }
}