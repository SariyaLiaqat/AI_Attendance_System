


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

static Future<List<Student>> getAllStudents({String? studentClass}) async {
  try {
    String url = '$baseUrl/getAllStudents';
    if (studentClass != null) {
      url += '?class=$studentClass'; // Pass class filter
    }
    final response = await http.get(Uri.parse(url));

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




static Future<Map<String, dynamic>> getDailyStats() async {
  try {
    final response = await http.get(Uri.parse('$baseUrl/getDailyStats'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    return {"presentPercent": 0, "absentPercent": 0, "total": 0};
  } catch (e) {
    return {"presentPercent": 0, "absentPercent": 0, "total": 0};
  }
}

static Future<List<dynamic>> getRecentActivity() async {
  try {
    final response = await http.get(Uri.parse('$baseUrl/getRecentActivity'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    return [];
  } catch (e) {
    return [];
  }
}

static Future<List<dynamic>> getWeeklyAttendance() async {
  try {
    final response = await http.get(Uri.parse('$baseUrl/getWeeklyAttendance'));
    if (response.statusCode == 200) return json.decode(response.body);
    return [];
  } catch (e) {
    return [];
  }
}

// Weekly stats for a single student
static Future<List<dynamic>> getStudentWeekly(int studentId) async {
  try {
    final response = await http.get(Uri.parse('$baseUrl/getStudentWeekly/$studentId'));
    if (response.statusCode == 200) return json.decode(response.body);
    return [];
  } catch (e) {
    print("Error fetching weekly attendance: $e");
    return [];
  }
}

// Monthly stats for a single student
static Future<List<dynamic>> getStudentMonthly(int studentId) async {
  try {
    final response = await http.get(Uri.parse('$baseUrl/getStudentMonthly/$studentId'));
    if (response.statusCode == 200) return json.decode(response.body);
    return [];
  } catch (e) {
    print("Error fetching monthly attendance: $e");
    return [];
  }
}

}







