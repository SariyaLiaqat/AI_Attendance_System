// import 'package:flutter/material.dart';
// import '../models/student_model.dart';
// import '../services/api_service.dart';

// import 'camera_capture_page.dart';
// import 'dart:math';

// class MarkAttendancePage extends StatefulWidget {
//   @override
//   _MarkAttendancePageState createState() => _MarkAttendancePageState();
// }

// class _MarkAttendancePageState extends State<MarkAttendancePage> {
//   final _rollController = TextEditingController();
//   Student? _foundStudent;
//   bool _isLoading = false;

//   // Function to calculate if faces match
//   bool _compareEmbeddings(List<double> current, List<double> stored) {
//     double distance = 0;
//     for (int i = 0; i < 192; i++) {
//       double diff = current[i] - stored[i];
//       distance += diff * diff;
//     }
//     distance = sqrt(distance);
//     print("Face Distance: $distance");
//     return distance < 1.0; // 1.0 is a standard threshold for MobileFaceNet
//   }

//   void _searchStudent() async {
//     setState(() => _isLoading = true);
//     final student = await ApiService.getStudentByRoll(_rollController.text);
//     setState(() {
//       _foundStudent = student;
//       _isLoading = false;
//     });
//     if (student == null) {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Student not found!")));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Mark Attendance")),
//       body: Padding(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           children: [
//             TextField(
//               controller: _rollController,
//               decoration: InputDecoration(
//                 labelText: "Enter Roll Number",
//                 suffixIcon: IconButton(icon: Icon(Icons.search), onPressed: _searchStudent),
//               ),
//             ),
//             if (_isLoading) CircularProgressIndicator(),
//             if (_foundStudent != null) ...[
//               SizedBox(height: 30),
//               Card(
//                 child: ListTile(
//                   title: Text("Name: ${_foundStudent!.name}"),
//                   subtitle: Text("Email: ${_foundStudent!.parentEmail}"),
//                 ),
//               ),
//               ElevatedButton.icon(
//                 icon: Icon(Icons.face),
//                 label: Text("Verify & Mark Present"),
//                 onPressed: () async {
//                   // 1. Open Camera to get live face embedding
//                   final List<double>? liveEmbedding = await Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (_) => CameraCapturePage()),
//                   );

//                   if (liveEmbedding != null) {
//                     // 2. Compare live face with stored face
//                     bool match = _compareEmbeddings(liveEmbedding, _foundStudent!.faceEmbedding!);

//                     if (match) {
//                       bool success = await ApiService.markPresent(_foundStudent!.id!);
//                       if (success) {
//                         ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Colors.green, content: Text("Attendance Marked!")));
//                       }
//                     } else {
//                       ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Colors.red, content: Text("Face mismatch! Access Denied.")));
//                     }
//                   }
//                 },
//               )
//             ]
//           ],
//         ),
//       ),
//     );
//   }
// }







import 'package:flutter/material.dart';
import '../models/student_model.dart';
import '../services/api_service.dart';
import '../widgets/smart_scanner_view.dart'; // 👈 Import your new widget
import 'camera_capture_page.dart';
import 'dart:math';
import '../services/face_embedding_service.dart';
class MarkAttendancePage extends StatefulWidget {
  @override
  _MarkAttendancePageState createState() => _MarkAttendancePageState();
}

class _MarkAttendancePageState extends State<MarkAttendancePage> {
  final _rollController = TextEditingController();
  Student? _foundStudent;
  bool _isLoading = false;
  final FaceEmbeddingService _embeddingService = FaceEmbeddingService();




  // Comparison logic
  bool _compareEmbeddings(List<double> current, List<double> stored) {
    double distance = 0;
    for (int i = 0; i < 192; i++) {
      double diff = current[i] - stored[i];
      distance += diff * diff;
    }
    distance = sqrt(distance);
    return distance < 1.0;
  }

  // Search logic
  void _searchStudent(String roll) async {
    setState(() => _isLoading = true);
    _rollController.text = roll; // Fill the text field
    final student = await ApiService.getStudentByRoll(roll);
    setState(() {
      _foundStudent = student;
     
      _isLoading = false;
    });
    if (student == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Student not found!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Mark Attendance")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          // Added to prevent overflow
          child: Column(
            children: [
              // 👈 NEW: Card Scanner Button
       ElevatedButton.icon(
  icon: Icon(Icons.qr_code_scanner),
  label: Text("Scan Student"),
  style: ElevatedButton.styleFrom(
    minimumSize: Size(double.infinity, 50),
    backgroundColor: Colors.cyan.shade700,
    foregroundColor: Colors.white,
  ),
  onPressed: () async {
    setState(() => _isLoading = true);

    final liveEmbedding = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FaceScannerPage(
          onResult: (embedding) {
            Navigator.pop(context, embedding);
          },
        ),
      ),
    );

    if (liveEmbedding == null) {
      setState(() => _isLoading = false);
      return; // user canceled
    }

    // ✅ Fetch all students from DB
    final students = await ApiService.getAllStudents();
    bool matched = false;

    for (var student in students) {
      if (student.faceEmbedding != null) {
        double distance = _embeddingService.compareFaces(liveEmbedding, student.faceEmbedding!);
        if (distance < 1.0) {
          bool success = await ApiService.markPresent(student.id!);
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.green,
                content: Text("✅ ${student.name} marked present!"),
              ),
            );
          }
          matched = true;
          break;
        }
      }
    }

    if (!matched) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text("❌ Face not recognized!"),
        ),
      );
    }

    setState(() => _isLoading = false);
  },
),

              SizedBox(height: 20),
              Text("OR", style: TextStyle(color: Colors.grey)),
              SizedBox(height: 20),

              TextField(
                controller: _rollController,
                decoration: InputDecoration(
                  labelText: "Manual Roll Number",
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () => _searchStudent(_rollController.text),
                  ),
                ),
              ),

              if (_isLoading)
                Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),

              if (_foundStudent != null) ...[
                SizedBox(height: 30),
                Card(
                  color: Colors.cyan.shade50,
                  child: ListTile(
                    leading: Icon(Icons.person, size: 40, color: Colors.cyan),
                    title: Text(
                      _foundStudent!.name,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text("ID: ${_foundStudent!.rollNo}"),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: Icon(Icons.face),
                  label: Text("Verify Face & Mark Present"),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                  ),
                  onPressed: () async {
                    final List<double>? liveEmbedding = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => CameraCapturePage()),
                    );

                    if (liveEmbedding != null) {
                      bool match = _compareEmbeddings(
                        liveEmbedding,
                        _foundStudent!.faceEmbedding!,
                      );
                      if (match) {
                        bool success = await ApiService.markPresent(
                          _foundStudent!.id!,
                        );
                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.green,
                              content: Text("Attendance Marked!"),
                            ),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.red,
                            content: Text("Face mismatch!"),
                          ),
                        );
                      }
                    }
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
