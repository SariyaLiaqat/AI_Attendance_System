

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:mobile_scanner/mobile_scanner.dart';
// import 'package:image_picker/image_picker.dart';
// import '../services/api_service.dart';
// import '../models/student_model.dart';
// import '../services/face_embedding_service.dart'; // Import service
// import 'camera_capture_page.dart'; // Import face scan page
// //import '../theme/app_colors.dart';

// class MarkAttendancePage2 extends StatefulWidget {
//   @override
//   _MarkAttendancePageState createState() => _MarkAttendancePageState();
// }

// class _MarkAttendancePageState extends State<MarkAttendancePage2> {
//   final MobileScannerController scannerController = MobileScannerController();
//   final ImagePicker _picker = ImagePicker();
//   final FaceEmbeddingService _embeddingService =
//       FaceEmbeddingService(); // Initialize service

//   bool _isProcessing = false;
//   String _statusMessage = "Step 1: Scan QR or Pick Gallery Image";
//   Student? _detectedStudent;

//   @override
//   void initState() {
//     super.initState();
//     _embeddingService.loadModel(); // Load the face model
//   }

//   @override
//   void dispose() {
//     scannerController.dispose();
//     super.dispose();
//   }

//   void _resetScanner() {
//     if (!mounted) return;
//     setState(() {
//       _detectedStudent = null;
//       _isProcessing = false;
//       _statusMessage = "Step 1: Scan QR or Pick Gallery Image";
//     });
//     scannerController.start();
//   }

//   // --- THE CORE LOGIC (ENHANCED WITH FACE VERIFICATION) ---
//   void _processStudentAttendance(String rawCode) async {
//     if (_isProcessing && _detectedStudent != null) return;

//     setState(() {
//       _isProcessing = true;
//       _statusMessage = "🔍 Processing Roll: $rawCode...";
//     });

//     try {
//       String dbFormattedRoll = rawCode;
//       print("🌐 Calling API for: $dbFormattedRoll");

//       await scannerController.stop();

//       Student? student = await ApiService.getStudentByRoll(dbFormattedRoll);

//       if (!mounted) return;

//       if (student != null) {
//         setState(() {
//           _detectedStudent = student;
//           _statusMessage = "✅ Found: ${student.name}\nStep 2: Face Scan...";
//         });

//         // --- BRIDGE TO FACE VERIFICATION ---
//         final List<double>? liveEmbedding = await Navigator.push(
//           context,
//           MaterialPageRoute(builder: (_) => CameraCapturePage()),
//         );

//         if (liveEmbedding == null) {
//           _handleError("⚠️ Face scan cancelled");
//           return;
//         }

//         // Compare the face from camera with the one in DB
//         double distance = _embeddingService.compareFaces(
//           liveEmbedding,
//           student.faceEmbedding!,
//         );

//         if (distance < 0.75) {
//           // Match found!
//           bool marked = await ApiService.markPresent(student.id!);
//           if (marked) {
//             _showSuccessDialog(student.name);
//           } else {
//             _handleError("⚠️ Database update failed");
//           }
//         } else {
//           _handleError("❌ Face mismatch! Try again.");
//         }
//       } else {
//         _handleError("❌ Roll $rawCode not found");
//       }
//     } catch (e) {
//       _handleError("⚠️ Connection Error");
//     }
//   }

//   // Helper to reset state on errors
//   void _handleError(String message) {
//     if (!mounted) return;
//     setState(() {
//       _isProcessing = false;
//       _statusMessage = message;
//     });
//     Future.delayed(Duration(seconds: 2), () => _resetScanner());
//   }

//   void _onDetect(BarcodeCapture capture) {
//     final String? code = capture.barcodes.first.rawValue?.trim();
//     if (code != null && !_isProcessing) {
//       HapticFeedback.mediumImpact();
//       _processStudentAttendance(code);
//     }
//   }

//   Future<void> _pickQRFromGallery() async {
//     final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
//     if (image == null) return;

//     setState(() {
//       _isProcessing = true;
//       _statusMessage = "🎯 Analyzing Gallery Image...";
//     });

//     try {
//       final BarcodeCapture? capture = await scannerController.analyzeImage(
//         image.path,
//       );
//       if (capture != null && capture.barcodes.isNotEmpty) {
//         final String? code = capture.barcodes.first.rawValue?.trim();
//         if (code != null) _processStudentAttendance(code);
//       } else {
//         _handleError("❌ No QR code found");
//       }
//     } catch (e) {
//       _handleError("❌ Error analyzing image");
//     }
//   }

//   void _showSuccessDialog(String name) {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (ctx) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         title: Icon(Icons.check_circle, color: Colors.green, size: 80),
//         content: Text(
//           "Success!\n$name marked present",
//           textAlign: TextAlign.center,
//           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//         ),
//         actions: [
//           Center(
//             child: ElevatedButton(
//               onPressed: () {
//                 Navigator.pop(ctx);
//                 _resetScanner();
//               },
//               child: Text("Done"),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;

//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       appBar: AppBar(
//         title: Text("Smart Attendance"),
//         backgroundColor: Colors.cyan[700],
//         foregroundColor: Colors.white,
//         centerTitle: true,
//       ),
//       body: Column(
//         children: [
//           // Scanner section
//           Expanded(
//             flex: 3,
//             child: Stack(
//               children: [
//                 // Camera / QR Scanner
//                 MobileScanner(
//                   controller: scannerController,
//                   onDetect: _onDetect,
//                 ),

//                 // Overlay box with dynamic border
//                 Center(
//                   child: Container(
//                     width: size.width * 0.5,
//                     height: size.width * 0.5,
//                     decoration: BoxDecoration(
//                       border: Border.all(
//                         color: _detectedStudent == null
//                             ? Colors.white70
//                             : Colors.greenAccent,
//                         width: 4,
//                       ),
//                       borderRadius: BorderRadius.circular(24),
//                     ),
//                   ),
//                 ),

//                 // Instruction overlay
//                 Positioned(
//                   top: 20,
//                   left: 0,
//                   right: 0,
//                   child: Column(
//                     children: [
//                       Text(
//                         "📌 Align QR Code or Student ID inside the box",
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                           shadows: [
//                             Shadow(
//                               blurRadius: 4,
//                               color: Colors.black45,
//                               offset: Offset(1, 1),
//                             ),
//                           ],
//                         ),
//                       ),
//                       SizedBox(height: 8),
//                       Text(
//                         "Ensure good lighting for quick scan",
//                         textAlign: TextAlign.center,
//                         style: TextStyle(color: Colors.white70, fontSize: 14),
//                       ),
//                       SizedBox(height: 4),
//                       Text(
//                         "Step 1: Scan QR → Step 2: Face Verification",
//                         textAlign: TextAlign.center,
//                         style: TextStyle(color: Colors.white70, fontSize: 14),
//                       ),
//                     ],
//                   ),
//                 ),
//                 // Add this inside the Stack
// Positioned(
//   bottom: 10,
//   right: 20,
//   child: FloatingActionButton(
//     mini: true,
//     backgroundColor: Colors.cyan[700],
//     onPressed: () => scannerController.switchCamera(),
//     child: const Icon(Icons.flip_camera_ios, color: Colors.white),
//   ),
// ),
//               ],
//             ),
//           ),

//           // Status & controls
//           Expanded(
//             flex: 2,
//             child: Container(
//               width: double.infinity,
//               padding: EdgeInsets.all(24),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black12,
//                     blurRadius: 10,
//                     offset: Offset(0, -3),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   // Status / feedback
//                   if (_isProcessing)
//                     Column(
//                       children: [
//                         CircularProgressIndicator(
//                           valueColor: AlwaysStoppedAnimation<Color>(
//                             Colors.cyan[700]!,
//                           ),
//                         ),
//                         SizedBox(height: 12),
//                         Text(
//                           _statusMessage,
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ],
//                     )
//                   else
//                     Column(
//                       children: [
//                         Text(
//                           _statusMessage,
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                         SizedBox(height: 20),
//                         // Gallery pick button
//                         if (_detectedStudent == null)
//                           ElevatedButton.icon(
//                             onPressed: _pickQRFromGallery,
//                             icon: Icon(Icons.image),
//                             label: Text("Pick QR from Gallery"),
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.cyan[700],
//                               foregroundColor: Colors.white,
//                               minimumSize: Size(size.width * 0.6, 50),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                             ),
//                           ),
//                       ],
//                     ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }




















import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import '../models/student_model.dart';
import '../services/face_embedding_service.dart'; // Import service
import 'camera_capture_page.dart'; // Import face scan page
//import '../theme/app_colors.dart';

class MarkAttendancePage2 extends StatefulWidget {
  @override
  _MarkAttendancePageState createState() => _MarkAttendancePageState();
}

class _MarkAttendancePageState extends State<MarkAttendancePage2> {
  final MobileScannerController scannerController = MobileScannerController();
  final ImagePicker _picker = ImagePicker();
  final FaceEmbeddingService _embeddingService =
      FaceEmbeddingService(); // Initialize service

  bool _isProcessing = false;
  String _statusMessage = "Step 1: Scan QR or Pick Gallery Image";
  Student? _detectedStudent;

  @override
  void initState() {
    super.initState();
    _embeddingService.loadModel(); // Load the face model
  }

  @override
  void dispose() {
    scannerController.dispose();
    super.dispose();
  }

  void _resetScanner() {
    if (!mounted) return;
    setState(() {
      _detectedStudent = null;
      _isProcessing = false;
      _statusMessage = "Step 1: Scan QR or Pick Gallery Image";
    });
    scannerController.start();
  }

  // --- THE CORE LOGIC (ENHANCED WITH FACE VERIFICATION) ---
  void _processStudentAttendance(String rawCode) async {
    if (_isProcessing && _detectedStudent != null) return;

    setState(() {
      _isProcessing = true;
      _statusMessage = "🔍 Processing Roll: $rawCode...";
    });

    try {
      String dbFormattedRoll = rawCode;
      print("🌐 Calling API for: $dbFormattedRoll");

      await scannerController.stop();

      Student? student = await ApiService.getStudentByRoll(dbFormattedRoll);

      if (!mounted) return;

      if (student != null) {
        setState(() {
          _detectedStudent = student;
          _statusMessage = "✅ Found: ${student.name}\nStep 2: Face Scan...";
        });

        // --- BRIDGE TO FACE VERIFICATION ---
        final List<double>? liveEmbedding = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => CameraCapturePage()),
        );

        if (liveEmbedding == null) {
          _handleError("⚠️ Face scan cancelled");
          return;
        }

        // Compare the face from camera with the one in DB
        double distance = _embeddingService.compareFaces(
          liveEmbedding,
          student.faceEmbedding!,
        );

        if (distance < 0.75) {
          // Match found!
          bool marked = await ApiService.markPresent(student.id!);
          if (marked) {
            _showSuccessDialog(student.name);
          } else {
            _handleError("⚠️ Database update failed");
          }
        } else {
          _handleError("❌ Face mismatch! Try again.");
        }
      } else {
        _handleError("❌ Roll $rawCode not found");
      }
    } catch (e) {
      _handleError("⚠️ Connection Error");
    }
  }

  // Helper to reset state on errors
  void _handleError(String message) {
    if (!mounted) return;
    setState(() {
      _isProcessing = false;
      _statusMessage = message;
    });
    Future.delayed(Duration(seconds: 2), () => _resetScanner());
  }

  void _onDetect(BarcodeCapture capture) {
    final String? code = capture.barcodes.first.rawValue?.trim();
    if (code != null && !_isProcessing) {
      HapticFeedback.mediumImpact();
      _processStudentAttendance(code);
    }
  }

  Future<void> _pickQRFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    setState(() {
      _isProcessing = true;
      _statusMessage = "🎯 Analyzing Gallery Image...";
    });

    try {
      final BarcodeCapture? capture = await scannerController.analyzeImage(
        image.path,
      );
      if (capture != null && capture.barcodes.isNotEmpty) {
        final String? code = capture.barcodes.first.rawValue?.trim();
        if (code != null) _processStudentAttendance(code);
      } else {
        _handleError("❌ No QR code found");
      }
    } catch (e) {
      _handleError("❌ Error analyzing image");
    }
  }

  void _showSuccessDialog(String name) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Icon(Icons.check_circle, color: Colors.green, size: 80),
        content: Text(
          "Success!\n$name marked present",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                _resetScanner();
              },
              child: Text("Done"),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("Smart Attendance"),
        backgroundColor: Colors.cyan[700],
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Scanner section
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                // Camera / QR Scanner
                MobileScanner(
                  controller: scannerController,
                  onDetect: _onDetect,
                ),

                // Overlay box with dynamic border
                Center(
                  child: Container(
                    width: size.width * 0.5,
                    height: size.width * 0.5,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _detectedStudent == null
                            ? Colors.white70
                            : Colors.greenAccent,
                        width: 4,
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),

                // Instruction overlay
                Positioned(
                  top: 20,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      Text(
                        "📌 Align QR Code or Student ID inside the box",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              blurRadius: 4,
                              color: Colors.black45,
                              offset: Offset(1, 1),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Ensure good lighting for quick scan",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Step 1: Scan QR → Step 2: Face Verification",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                // Add this inside the Stack
Positioned(
  bottom: 10,
  right: 20,
  child: FloatingActionButton(
    mini: true,
    backgroundColor: Colors.cyan[700],
    onPressed: () => scannerController.switchCamera(),
    child: const Icon(Icons.flip_camera_ios, color: Colors.white),
  ),
),
              ],
            ),
          ),

          // Status & controls
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -3),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Status / feedback
                  if (_isProcessing)
                    Column(
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.cyan[700]!,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          _statusMessage,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        Text(
                          _statusMessage,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 20),
                        // Gallery pick button
                        if (_detectedStudent == null)
                          ElevatedButton.icon(
                            onPressed: _pickQRFromGallery,
                            icon: Icon(Icons.image),
                            label: Text("Pick QR from Gallery"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.cyan[700],
                              foregroundColor: Colors.white,
                              minimumSize: Size(size.width * 0.6, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
