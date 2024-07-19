import 'package:flutter/material.dart';
import 'auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    try {
      final accessToken = await _authService.getAccessToken();
      
      if (accessToken != null) {
        final response = await _authService.testAccessToken(accessToken);
        
        if (response == 401) {
          try {
            await _authService.refreshToken();
            Navigator.of(context).pushReplacementNamed('/home');
          } catch (e) {
            print('Failed to refresh token: $e');
            await _authService.logout();
            Navigator.of(context).pushReplacementNamed('/login');
          }
        } else if (response >= 200 && response < 300) {
          Navigator.of(context).pushReplacementNamed('/home');
        } else {
          print('Unexpected response code: $response');
          Navigator.of(context).pushReplacementNamed('/login');
        }
      } else {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      print('Error checking login status: $e');
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }


  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
