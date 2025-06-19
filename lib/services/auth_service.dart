import 'dart:convert';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'graphql_service.dart';
import 'restaurant_owner_service.dart';
import 'driver_profile_service.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  // Login mutation
  static const String loginMutation = '''
    mutation LoginUser(\$email: String!, \$password: String!) {
      loginUser(email: \$email, password: \$password) {
        token
        user {
          penggunaId
          email
          namaPengguna
          role
          telepon
          alamat
        }
      }
    }
  ''';

  // Register mutation
  static const String registerMutation = '''
    mutation RegisterUser(
      \$email: String!
      \$namaPengguna: String
      \$password: String!
      \$role: Role!
      \$telepon: String
      \$alamat: String
    ) {
      registerUser(
        email: \$email
        namaPengguna: \$namaPengguna
        password: \$password
        role: \$role
        telepon: \$telepon
        alamat: \$alamat
      ) {
        token
        user {
          penggunaId
          email
          namaPengguna
          role
          telepon
          alamat
        }
      }
    }
  ''';

  static Future<Map<String, dynamic>?> login(
    String email,
    String password,
  ) async {
    try {
      final client = await GraphQLService.getClient();
      final result = await client.mutate(
        MutationOptions(
          document: gql(loginMutation),
          variables: {'email': email, 'password': password},
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      final data = result.data!['loginUser'];
      await saveAuthData(data['token'], data['user']);
      return data;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  static Future<Map<String, dynamic>?> register({
    required String email,
    required String password,
    required String role,
    String? namaPengguna,
    String? telepon,
    String? alamat,
  }) async {
    try {
      final client = await GraphQLService.getClient();
      final result = await client.mutate(
        MutationOptions(
          document: gql(registerMutation),
          variables: {
            'email': email,
            'password': password,
            'role': role,
            'namaPengguna': namaPengguna,
            'telepon': telepon,
            'alamat': alamat,
          },
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      final data = result.data!['registerUser'];
      await saveAuthData(data['token'], data['user']);
      return data;
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  static Future<void> saveAuthData(
    String token,
    Map<String, dynamic> user,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userKey, jsonEncode(user));
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);

    if (token == null) return false;

    try {
      return !JwtDecoder.isExpired(token);
    } catch (e) {
      return false;
    }
  }

  static Future<Map<String, dynamic>?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString(_userKey);

    if (userString == null) return null;

    return jsonDecode(userString);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    GraphQLService.resetClient();
  }

  // Check if restaurant owner has already created their restaurant
  static Future<bool> hasRestaurant() async {
    try {
      final user = await getCurrentUser();
      if (user == null || user['role'] != 'Restaurant') {
        return false;
      }

      final restaurant = await RestaurantOwnerService.getMyRestaurant();
      return restaurant != null;
    } catch (e) {
      // If there's an error checking, assume no restaurant
      return false;
    }
  }

  // Check if driver has already created their profile
  static Future<bool> hasDriverProfile() async {
    try {
      final user = await getCurrentUser();
      if (user == null || user['role'] != 'Driver') {
        return false;
      }

      final driverProfile = await DriverProfileService.getMyDriverProfile();
      return driverProfile != null;
    } catch (e) {
      // If there's an error checking, assume no driver profile
      return false;
    }
  }
}
