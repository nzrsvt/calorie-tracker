import 'package:flutter/material.dart';
import 'exceptions.dart';
import 'global_error_handler.dart';

abstract class BaseRepository {
  @protected
  Future<T> call<T>(BuildContext context, Future<T> Function() request) async {
    try {
      final data = await request();
      return data;
    } on TokenExpiredException catch (e) {
      GlobalErrorHandler.handleError(context, e);
      rethrow;
    } on Exception catch (e) {
      GlobalErrorHandler.handleError(context, e);
      rethrow;
    }
  }
}