// import 'package:flutter/material.dart';
// import '../models/student_model.dart';
// import '../services/api_service.dart';
// import 'camera_capture_page.dart';
// import 'mark_attendance_page.dart';
// import 'MarkAttendancePage.dart';
// import '../pages/QRCardPage.dart';
// import '../theme/app_colors.dart';

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
//     final width = MediaQuery.of(context).size.width;
//     final isWeb = width > 800;

//     return Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: AppBar(
//         backgroundColor: AppColors.primary,
//         foregroundColor: Colors.white,
//         title: const Text('New Student'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.qr_code_scanner),
//             tooltip: 'Mark Attendance',
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => MarkAttendancePage2()),
//               );
//             },
//           ),
//           IconButton(
//             icon: const Icon(Icons.how_to_reg),
//             tooltip: 'Registration List',
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => MarkAttendancePage()),
//               );
//             },
//           ),
//         ],
//       ),

//       body: Center(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(16),
//           child: Container(
//             width: isWeb ? 600 : double.infinity,
//             padding: const EdgeInsets.all(24),
//             decoration: BoxDecoration(
//               color: AppColors.card,
//               borderRadius: BorderRadius.circular(20),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.05),
//                   blurRadius: 10,
//                   offset: const Offset(0, 5),
//                 ),
//               ],
//             ),
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   // 🔹 TITLE
//                   Text(
//                     "Student Registration",
//                     style: TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                       color: AppColors.textPrimary,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),

//                   const SizedBox(height: 24),

//                   // 🔹 NAME
//                   _buildTextField(
//                     controller: _nameController,
//                     label: "Student Name",
//                     icon: Icons.person,
//                   ),

//                   const SizedBox(height: 16),

//                   // 🔹 ROLL NO
//                   _buildTextField(
//                     controller: _rollController,
//                     label: "Roll Number",
//                     icon: Icons.confirmation_number,
//                   ),

//                   const SizedBox(height: 16),

//                   // 🔹 EMAIL
//                   _buildTextField(
//                     controller: _emailController,
//                     label: "Parent Email",
//                     icon: Icons.email,
//                   ),

//                   const SizedBox(height: 30),

//                   // 🔹 CAPTURE FACE BUTTON
//                   ElevatedButton.icon(
//                     icon: const Icon(Icons.camera_alt),
//                     label: Text(
//                       _faceEmbedding == null ? "Capture Face" : "Face Captured",
//                     ),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: _faceEmbedding == null
//                           ? AppColors.primary
//                           : AppColors.success,
//                       foregroundColor: Colors.white,
//                       minimumSize: const Size(double.infinity, 52),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(14),
//                       ),
//                     ),
//                     onPressed: () async {
//                       final embedding = await Navigator.push(
//                         context,
//                         MaterialPageRoute(builder: (_) => CameraCapturePage()),
//                       );
//                       if (embedding != null) {
//                         setState(() {
//                           _faceEmbedding = embedding;
//                         });
//                       }
//                     },
//                   ),

//                   const SizedBox(height: 30),

//                   // 🔹 SUBMIT BUTTON
//                   ElevatedButton(
//                     child: const Text("Submit Registration"),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppColors.primary,
//                       foregroundColor: Colors.white,
//                       minimumSize: const Size(double.infinity, 52),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(14),
//                       ),
//                     ),
//                     onPressed: () async {
//                       if (_formKey.currentState!.validate() &&
//                           _faceEmbedding != null) {
//                         Student student = Student(
//                           name: _nameController.text,
//                           rollNo: _rollController.text,
//                           parentEmail: _emailController.text,
//                           faceEmbedding: _faceEmbedding,
//                         );

//                         bool success = await ApiService.addStudent(student);

//                         if (success) {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (_) => QRCardPage(
//                                 studentName: _nameController.text,
//                                 rollNo: _rollController.text,
//                               ),
//                             ),
//                           );
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             const SnackBar(content: Text('Student Added')),
//                           );
//                         }
//                       } else {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(
//                             content: Text('Fill all fields and capture face'),
//                           ),
//                         );
//                       }
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String label,
//     required IconData icon,
//   }) {
//     return TextFormField(
//       controller: controller,
//       decoration: InputDecoration(
//         labelText: label,
//         prefixIcon: Icon(icon, color: AppColors.primary),
//         filled: true,
//         fillColor: AppColors.background,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(14),
//           borderSide: BorderSide.none,
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
  String? _selectedClass;
  final List<String> _classList = [
  "Play Group",
  "1-A",
  "1-B",
  "2-A",
  "2-B",
  "3-A",
  "3-B",
  "4-A",
  "4-B",
  "5-A",
  "5-B",
  "6-A",
  "6-B",
  "7-A",
  "7-B",
  "8-A",
  "8-B",
  "9-A",
  "9-B",
  "10-A",
  "10-B",
];


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

                  // 🔹 CLASS DROPDOWN
                  DropdownButtonFormField<String>(
                    value: _selectedClass,
                    items: _classList
                        .map(
                          (cls) =>
                              DropdownMenuItem(value: cls, child: Text(cls)),
                        )
                        .toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedClass = val;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: "Select Class",
                      prefixIcon: Icon(Icons.class_, color: AppColors.primary),
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (val) =>
                        val == null ? "Please select a class" : null,
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
                          studentClass:
                              _selectedClass, // ← Update here // ← ye add karna hai
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
