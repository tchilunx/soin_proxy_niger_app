import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheToken(String token);
  Future<String?> getToken();
  Future<void> cacheUser(UserModel user);
  Future<UserModel?> getUser();
  Future<void> cacheUserRole(String role);
  Future<String?> getUserRole();
  Future<void> clearCache();
  Future<bool> isLoggedIn();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage _storage;

  AuthLocalDataSourceImpl({required FlutterSecureStorage storage})
      : _storage = storage;

  @override
  Future<void> cacheToken(String token) async {
    try {
      await _storage.write(key: AppConstants.tokenKey, value: token);
    } catch (e) {
      throw CacheException(message: 'Erreur lors de la sauvegarde du token');
    }
  }

  @override
  Future<String?> getToken() async {
    try {
      return await _storage.read(key: AppConstants.tokenKey);
    } catch (e) {
      throw CacheException(message: 'Erreur lors de la lecture du token');
    }
  }

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      final userJson = jsonEncode(user.toJson());
      await _storage.write(key: AppConstants.userKey, value: userJson);
    } catch (e) {
      throw CacheException(message: 'Erreur lors de la sauvegarde de l\'utilisateur');
    }
  }

  @override
  Future<UserModel?> getUser() async {
    try {
      final userJson = await _storage.read(key: AppConstants.userKey);
      if (userJson == null) return null;
      return UserModel.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
    } catch (e) {
      throw CacheException(message: 'Erreur lors de la lecture de l\'utilisateur');
    }
  }

  @override
  Future<void> cacheUserRole(String role) async {
    try {
      await _storage.write(key: AppConstants.userRoleKey, value: role);
    } catch (e) {
      throw CacheException(message: 'Erreur lors de la sauvegarde du rôle');
    }
  }

  @override
  Future<String?> getUserRole() async {
    try {
      return await _storage.read(key: AppConstants.userRoleKey);
    } catch (e) {
      throw CacheException(message: 'Erreur lors de la lecture du rôle');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await _storage.delete(key: AppConstants.tokenKey);
      await _storage.delete(key: AppConstants.userKey);
      await _storage.delete(key: AppConstants.userRoleKey);
    } catch (e) {
      throw CacheException(message: 'Erreur lors de la suppression du cache');
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    try {
      final token = await _storage.read(key: AppConstants.tokenKey);
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}

