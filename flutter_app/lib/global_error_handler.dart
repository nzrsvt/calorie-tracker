import 'package:flutter/material.dart';
import 'exceptions.dart';

class GlobalErrorHandler {
  static void handleError(BuildContext context, dynamic error) {
    if (error is TokenExpiredException) {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: ${error.toString()}')),
      );
    }
  }
}