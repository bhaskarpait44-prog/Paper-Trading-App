import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/constants.dart';

class AuthService {
  final Dio _dio = Dio(BaseOptions(baseUrl: AppConstants.baseUrl));
  final _storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        await _storage.write(key: 'accessToken', value: response.data['accessToken']);
        await _storage.write(key: 'refreshToken', value: response.data['refreshToken']);
        return response.data;
      }
    } catch (e) {
      debugPrint('Login error: $e');
    }
    return null;
  }

  Future<Map<String, dynamic>?> register(String name, String email, String password) async {
    try {
      final response = await _dio.post('/auth/register', data: {
        'name': name,
        'email': email,
        'password': password,
      });

      if (response.statusCode == 201) {
        await _storage.write(key: 'accessToken', value: response.data['accessToken']);
        await _storage.write(key: 'refreshToken', value: response.data['refreshToken']);
        return response.data;
      }
    } catch (e) {
      debugPrint('Register error: $e');
    }
    return null;
  }

  Future<void> logout() async {
    final refreshToken = await _storage.read(key: 'refreshToken');
    try {
      await _dio.post('/auth/logout', data: {'refreshToken': refreshToken});
    } catch (e) {
      debugPrint('Logout error: $e');
    }
    await _storage.delete(key: 'accessToken');
    await _storage.delete(key: 'refreshToken');
  }

  Future<String?> getToken() async => await _storage.read(key: 'accessToken');
}
