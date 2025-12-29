


import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/student_model.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.1.193:5000';

  static Future<bool> addStudent(Student student) async {
    final url = Uri.parse('$baseUrl/addStudent');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(student.toJson()),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Error: ${response.body}');
      return false;
    }
  }
 static Future<Student?> getStudentByRoll(String rollNo) async {
  try {
    print("🌐 Flutter is attempting to reach: $baseUrl/getStudent/$rollNo");
    final url = Uri.parse('$baseUrl/getStudent/$rollNo');
    final response = await http.get(url).timeout(Duration(seconds: 5)); // Add a timeout!

    if (response.statusCode == 200) {
      return Student.fromJson(jsonDecode(response.body));
    }
    return null;
  } catch (e) {
    print("❌ NETWORK ERROR: $e"); // THIS WILL TELL US WHY IT FAILED
    return null;
  }
}

static Future<bool> markPresent(int studentId) async {
  final url = Uri.parse('$baseUrl/markAttendance');
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'student_id': studentId, 'status': 'Present'}),
  );
  return response.statusCode == 200;
}

static Future<List<Student>> getAllStudents() async {
  try {
    final url = Uri.parse('$baseUrl/getAllStudents');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Student.fromJson(e)).toList();
    } else {
      return [];
    }
  } catch (e) {
    print("Error fetching all students: $e");
    return [];
  }
}

}







