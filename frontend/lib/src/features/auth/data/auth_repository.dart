import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../domain/app_user.dart';
import 'token_storage.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.read(dioProvider), ref.read(tokenStorageProvider));
});

class AuthRepository {
  AuthRepository(this._dio, this._tokenStorage);

  final Dio _dio;
  final TokenStorage _tokenStorage;

  Future<AppUser?> restoreSession() async {
    final token = await _tokenStorage.readToken();
    if (token == null || token.isEmpty) return null;
    return me();
  }

  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    final token = response.data?['access_token'] as String?;
    if (token == null || token.isEmpty) {
      throw StateError('Login response did not include an access token.');
    }
    await _tokenStorage.saveToken(token);
    return me();
  }

  Future<AppUser> me() async {
    final response = await _dio.get<Map<String, dynamic>>('/auth/me');
    return AppUser.fromJson(response.data ?? <String, dynamic>{});
  }

  Future<void> logout() => _tokenStorage.clear();
}
