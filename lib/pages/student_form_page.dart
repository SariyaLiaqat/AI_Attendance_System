// import 'package:flutter/material.dart';
// import '../models/student_model.dart';
// import '../services/api_service.dart';
// import 'camera_capture_page.dart';
// import 'mark_attendance_page.dart';
// import 'MarkAttendancePage.dart';
// import '../pages/QRCardPage.dart';
// class StudentFormPage extends StatefulWidget {
//   @override
//   _StudentFormPageState createState() => _StudentFormPageState();
// }

// class _StudentFormPageState extends State<StudentFormPage> {
//   final _formKey = GlobalKey<FormState>();
//   final _nameController = TextEditingController();
//   final _rollController = TextEditingController();
//   final _emailController = TextEditingController();
//   List<double>? _faceEmbedding;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//      appBar: AppBar(
//   title: Text('New Student'),
//   actions: [
//     // Icon 1: Opens Mark Attendance (the scanner)
//     IconButton(
//       icon: Icon(Icons.qr_code_scanner), // New icon for scanning
//       tooltip: 'Mark Attendance',
//       onPressed: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => MarkAttendancePage2()),
//         );
//       },
//     ),
//     // Icon 2: Opens your registration list or other page
//     IconButton(
//       icon: Icon(Icons.how_to_reg),
//       tooltip: 'Registration List',
//       onPressed: () {
//         // This is your existing button logic
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => MarkAttendancePage()),
//         );
//       },
//     )
//   ],
// ),
//       body: Form(
//         key: _formKey,
//         child: Padding(
//           padding: EdgeInsets.all(16),
//           child: Column(
//             children: [
//               TextFormField(controller: _nameController, decoration: InputDecoration(labelText: 'Name')),
//               TextFormField(controller: _rollController, decoration: InputDecoration(labelText: 'Roll No')),
//               TextFormField(controller: _emailController, decoration: InputDecoration(labelText: 'Parent Email')),
//               SizedBox(height: 20),
//               ElevatedButton(
//                 child: Text('Capture Face'),
//                 onPressed: () async {
//                   // Navigate to Camera Capture Page → returns embedding
//                   final embedding = await Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (_) => CameraCapturePage()),
//                   );
//                   if (embedding != null) {
//                     setState(() {
//                       _faceEmbedding = embedding;
//                     });
//                   }
//                 },
//               ),
//               SizedBox(height: 20),
//               ElevatedButton(
//                 child: Text('Submit'),
//                 onPressed: () async {
//                   if (_formKey.currentState!.validate() && _faceEmbedding != null) {
//                     Student student = Student(
//                       name: _nameController.text,
//                       rollNo: _rollController.text,
//                       parentEmail: _emailController.text,
//                       faceEmbedding: _faceEmbedding,
//                     );

//                     bool success = await ApiService.addStudent(student);
//                     if (success) {
//   Navigator.push(
//     context,
//     MaterialPageRoute(
//       builder: (_) => QRCardPage(
//         studentName: _nameController.text,
//         rollNo: _rollController.text,
//       ),
//     ),
//   );
// }
//                     if (success) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Student Added')));
//                   } else {
//                     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Fill all fields and capture face')));
//                   }
//                 },
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import '../models/student_model.dart';
import '../services/api_service.dart';
import 'camera_capture_page.dart';
import 'mark_attendance_page.dart';
import 'MarkAttendancePage.dart';
import '../pages/QRCardPage.dart';
import '../theme/app_colors.dart';

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
    final width = MediaQuery.of(context).size.width;
    final isWeb = width > 800;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('New Student'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: 'Mark Attendance',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MarkAttendancePage2()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.how_to_reg),
            tooltip: 'Registration List',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MarkAttendancePage()),
              );
            },
          ),
        ],
      ),

      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Container(
            width: isWeb ? 600 : double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 🔹 TITLE
                  Text(
                    "Student Registration",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 24),

                  // 🔹 NAME
                  _buildTextField(
                    controller: _nameController,
                    label: "Student Name",
                    icon: Icons.person,
                  ),

                  const SizedBox(height: 16),

                  // 🔹 ROLL NO
                  _buildTextField(
                    controller: _rollController,
                    label: "Roll Number",
                    icon: Icons.confirmation_number,
                  ),

                  const SizedBox(height: 16),

                  // 🔹 EMAIL
                  _buildTextField(
                    controller: _emailController,
                    label: "Parent Email",
                    icon: Icons.email,
                  ),

                  const SizedBox(height: 30),

                  // 🔹 CAPTURE FACE BUTTON
                  ElevatedButton.icon(
                    icon: const Icon(Icons.camera_alt),
                    label: Text(
                      _faceEmbedding == null ? "Capture Face" : "Face Captured",
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _faceEmbedding == null
                          ? AppColors.primary
                          : AppColors.success,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () async {
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

                  const SizedBox(height: 30),

                  // 🔹 SUBMIT BUTTON
                  ElevatedButton(
                    child: const Text("Submit Registration"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate() &&
                          _faceEmbedding != null) {
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
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Student Added')),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Fill all fields and capture face'),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
