import 'package:flutter/material.dart';
import '../models/student_model.dart';
import '../services/api_service.dart';
import 'camera_capture_page.dart';
import 'mark_attendance_page.dart';
import 'MarkAttendancePage.dart';
import '../pages/QRCardPage.dart';
class StudentFormPage extends StatefulWidget {
  @override
  _StudentFormPageState createState() => _StudentFormPageState();
}

class _StudentFormPageState extends State<StudentFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _rollController = TextEditingController();
  final _emailController = TextEditingController();
  List<double>? _faceEmbedding;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: AppBar(
  title: Text('New Student'),
  actions: [
    // Icon 1: Opens Mark Attendance (the scanner)
    IconButton(
      icon: Icon(Icons.qr_code_scanner), // New icon for scanning
      tooltip: 'Mark Attendance',
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MarkAttendancePage2()),
        );
      },
    ),
    // Icon 2: Opens your registration list or other page
    IconButton(
      icon: Icon(Icons.how_to_reg), 
      tooltip: 'Registration List',
      onPressed: () {
        // This is your existing button logic
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MarkAttendancePage()),
        );
      },
    )
  ],
),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              TextFormField(controller: _nameController, decoration: InputDecoration(labelText: 'Name')),
              TextFormField(controller: _rollController, decoration: InputDecoration(labelText: 'Roll No')),
              TextFormField(controller: _emailController, decoration: InputDecoration(labelText: 'Parent Email')),
              SizedBox(height: 20),
              ElevatedButton(
                child: Text('Capture Face'),
                onPressed: () async {
                  // Navigate to Camera Capture Page → returns embedding
                  final embedding = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => CameraCapturePage()),
                  );
                  if (embedding != null) {
                    setState(() {
                      _faceEmbedding = embedding;
                    });
                  }
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                child: Text('Submit'),
                onPressed: () async {
                  if (_formKey.currentState!.validate() && _faceEmbedding != null) {
                    Student student = Student(
                      name: _nameController.text,
                      rollNo: _rollController.text,
                      parentEmail: _emailController.text,
                      faceEmbedding: _faceEmbedding,
                    );
                    
                    bool success = await ApiService.addStudent(student);
                    if (success) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => QRCardPage(
        studentName: _nameController.text,
        rollNo: _rollController.text,
      ),
    ),
  );
}
                    if (success) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Student Added')));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Fill all fields and capture face')));
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
