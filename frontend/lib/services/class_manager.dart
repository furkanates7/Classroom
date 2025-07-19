import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/class.dart';

class ClassManager {
  static const String _storageKey = 'classes';
  
  // Sınıf oluştur
  static Future<ClassModel> createClass({
    required String name,
    required String subject,
    required String description,
    required String teacherId,
  }) async {
    final classes = await getAllClasses();
    
    final newClass = ClassModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      subject: subject,
      description: description,
      teacherId: teacherId,
      createdAt: DateTime.now(),
    );
    
    classes.add(newClass);
    await _saveClasses(classes);
    
    return newClass;
  }
  
  // Tüm sınıfları getir
  static Future<List<ClassModel>> getAllClasses() async {
    final prefs = await SharedPreferences.getInstance();
    final classesJson = prefs.getStringList(_storageKey) ?? [];
    
    return classesJson
        .map((json) => ClassModel.fromJson(jsonDecode(json)))
        .toList();
  }
  
  // Öğretmen sınıflarını getir
  static Future<List<ClassModel>> getTeacherClasses(String teacherId) async {
    final allClasses = await getAllClasses();
    return allClasses.where((c) => c.teacherId == teacherId).toList();
  }
  
  // Öğrenci sınıflarını getir (şimdilik tüm sınıfları göster)
  static Future<List<ClassModel>> getStudentClasses() async {
    return await getAllClasses();
  }
  
  // Sınıfı sil
  static Future<void> deleteClass(String classId) async {
    final classes = await getAllClasses();
    classes.removeWhere((c) => c.id == classId);
    await _saveClasses(classes);
  }
  
  // Sınıfları kaydet
  static Future<void> _saveClasses(List<ClassModel> classes) async {
    final prefs = await SharedPreferences.getInstance();
    final classesJson = classes
        .map((c) => jsonEncode(c.toJson()))
        .toList();
    await prefs.setStringList(_storageKey, classesJson);
  }
} 