import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';
import '../models/user_model.dart';
import '../models/order_model.dart';

class ApiService {
  static const String baseUrl = 'https://astroboomin.co/api';
  
  static String? _cachedUserId;

  static Future<String?> getUserId() async {
    if (_cachedUserId != null) return _cachedUserId;
    final prefs = await SharedPreferences.getInstance();
    _cachedUserId = prefs.getString('user_id');
    return _cachedUserId;
  }

  static Future<void> saveUserId(String userId) async {
    _cachedUserId = userId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', userId);
  }

  static Future<void> logout() async {
    _cachedUserId = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
  }

  static Future<UserModel> getProfile() async {
    final userId = await getUserId();
    if (userId == null) throw Exception('Not logged in');

    final response = await http.get(
      Uri.parse('$baseUrl/profile.php?user_id=$userId'),
      headers: {
        'Content-Type': 'application/json',
      },
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return UserModel.fromJson(data['data']);
      } else {
        throw Exception(data['error'] ?? 'Failed to get profile');
      }
    } else {
      throw Exception('Server error: ${response.statusCode}');
    }
  }

  static Future<List<OrderModel>> getOrders() async {
    final userId = await getUserId();
    if (userId == null) return [];

    final response = await http.get(
      Uri.parse('$baseUrl/orders.php?user_id=$userId'),
      headers: {
        'Content-Type': 'application/json',
      },
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        final List<dynamic> ordersList = data['data'];
        return ordersList.map((json) => OrderModel.fromJson(json)).toList();
      } else {
        return [];
      }
    } else {
      throw Exception('Server error: ${response.statusCode}');
    }
  }

  static Future<bool> updateProfile({
    String? name,
    String? phone,
    XFile? avatarImage,
  }) async {
    final userId = await getUserId();
    if (userId == null) return false;

    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/update_profile.php'));
    request.fields['user_id'] = userId;
    
    if (name != null) request.fields['name'] = name;
    if (phone != null) request.fields['phone'] = phone;

    if (avatarImage != null) {
      // For web, use bytes. For mobile, use path.
      final bytes = await avatarImage.readAsBytes();
      final multipartFile = http.MultipartFile.fromBytes(
        'avatar',
        bytes,
        filename: avatarImage.name,
      );
      request.files.add(multipartFile);
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
    } catch (e) {
      print('Update profile error: $e');
    }
    return false;
  }
}
