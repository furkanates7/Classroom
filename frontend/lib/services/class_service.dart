import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/class.dart';
import '../models/assignment.dart';
import 'auth_service.dart';

class ClassService {
  static const String baseUrl = AuthService.baseUrl;

  static Future<List<Class>> getMyClasses(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/classes'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Class.fromJson(json)).toList();
      } else {
        throw Exception('Sınıflar yüklenemedi');
      }
    } catch (e) {
      throw Exception('Bağlantı hatası: $e');
    }
  }

  static Future<Class> createClass(String token, String name, String description, String subject) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/classes'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'name': name,
          'description': description,
          'subject': subject,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Class.fromJson(data);
      } else {
        throw Exception('Sınıf oluşturulamadı');
      }
    } catch (e) {
      throw Exception('Bağlantı hatası: $e');
    }
  }

  static Future<bool> joinClass(String token, String classCode) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/classes/$classCode/join'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Sınıfa katılım hatası: $e');
    }
  }

  static Future<List<Assignment>> getClassAssignments(String token, int classId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/classes/$classId/assignments'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Assignment.fromJson(json)).toList();
      } else {
        throw Exception('Ödevler yüklenemedi');
      }
    } catch (e) {
      throw Exception('Bağlantı hatası: $e');
    }
  }

  static Future<Assignment> createAssignment(
    String token,
    int classId,
    String title,
    String description,
    DateTime dueDate,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/classes/$classId/assignments'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'title': title,
          'description': description,
          'due_date': dueDate.toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Assignment.fromJson(data);
      } else {
        throw Exception('Ödev oluşturulamadı');
      }
    } catch (e) {
      throw Exception('Bağlantı hatası: $e');
    }
  }
} 