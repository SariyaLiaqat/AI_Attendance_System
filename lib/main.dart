import 'package:flutter/material.dart';
//import 'pages/student_form_page.dart';
import 'pages/dashboard_page.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Attendance System',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AttendanceDashboard(), // ✅ Start with Student Enrollment Form
    );
  }
}
