import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AuthResponse {
  final bool success;
  final String message;
  final String? accessToken;
  final String? refreshToken;
  final Map<String, dynamic>? user;

  AuthResponse({
    required this.success,
    required this.message,
    this.accessToken,
    this.refreshToken,
    this.user,
  });
}

class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();

  /// Returns the base URL according to platform.
  /// 10.0.2.2 is used for Android emulator to reach host localhost.
  String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000/api/auth';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000/api/auth';
    } else {
      return 'http://localhost:3000/api/auth';
    }
  }

  /// Register user on Node.js backend
  Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/register');
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'name': name.trim(),
              'email': email.trim().toLowerCase(),
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 8));

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final success = body['success'] == true;
      String message = body['message'] as String? ?? (success ? 'Registration successful' : 'Registration failed');
      if (body['errors'] != null && (body['errors'] as List).isNotEmpty) {
        final errList = (body['errors'] as List)
            .map((e) => (e is Map ? e['message']?.toString() : e.toString()) ?? '')
            .where((s) => s.isNotEmpty)
            .join('\n');
        if (errList.isNotEmpty) {
          message = errList;
        }
      }

      if (success && body['data'] != null) {
        final data = body['data'] as Map<String, dynamic>;
        return AuthResponse(
          success: true,
          message: message,
          accessToken: data['accessToken'] as String?,
          refreshToken: data['refreshToken'] as String?,
          user: data['user'] as Map<String, dynamic>?,
        );
      } else {
        return AuthResponse(success: false, message: message);
      }
    } catch (e) {
      return AuthResponse(
        success: false,
        message: 'Could not connect to Node.js server ($e).',
      );
    }
  }

  /// Login user on Node.js backend
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/login');
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email.trim().toLowerCase(),
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 8));

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final success = body['success'] == true;
      String message = body['message'] as String? ?? (success ? 'Login successful' : 'Login failed');
      if (body['errors'] != null && (body['errors'] as List).isNotEmpty) {
        final errList = (body['errors'] as List)
            .map((e) => (e is Map ? e['message']?.toString() : e.toString()) ?? '')
            .where((s) => s.isNotEmpty)
            .join('\n');
        if (errList.isNotEmpty) {
          message = errList;
        }
      }

      if (success && body['data'] != null) {
        final data = body['data'] as Map<String, dynamic>;
        return AuthResponse(
          success: true,
          message: message,
          accessToken: data['accessToken'] as String?,
          refreshToken: data['refreshToken'] as String?,
          user: data['user'] as Map<String, dynamic>?,
        );
      } else {
        return AuthResponse(success: false, message: message);
      }
    } catch (e) {
      return AuthResponse(
        success: false,
        message: 'Could not connect to Node.js server ($e).',
      );
    }
  }

  /// Fetch profile from Node.js backend using JWT access token
  Future<AuthResponse> getProfile(String accessToken) async {
    try {
      final url = Uri.parse('$baseUrl/profile');
      final response = await http
          .get(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $accessToken',
            },
          )
          .timeout(const Duration(seconds: 8));

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final success = body['success'] == true;
      final message = body['message'] as String? ?? '';

      if (success && body['data'] != null) {
        final data = body['data'] as Map<String, dynamic>;
        return AuthResponse(
          success: true,
          message: message,
          user: data['user'] as Map<String, dynamic>?,
        );
      } else {
        return AuthResponse(success: false, message: message);
      }
    } catch (e) {
      return AuthResponse(
        success: false,
        message: 'Could not connect to backend server ($e).',
      );
    }
  }

  /// Logout from Node.js backend
  Future<void> logout(String? refreshToken) async {
    if (refreshToken == null || refreshToken.isEmpty) return;
    try {
      final url = Uri.parse('$baseUrl/logout');
      await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      ).timeout(const Duration(seconds: 5));
    } catch (_) {
      // Ignore network errors on logout
    }
  }
}
