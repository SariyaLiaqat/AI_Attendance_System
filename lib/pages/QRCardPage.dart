// import 'package:flutter/material.dart';
// import 'package:qr_flutter/qr_flutter.dart';
// import 'package:screenshot/screenshot.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:gal/gal.dart'; // Add this import
// import 'dart:io';

// class QRCardPage extends StatefulWidget {
//   final String studentName;
//   final String rollNo;

//   QRCardPage({required this.studentName, required this.rollNo});

//   @override
//   _QRCardPageState createState() => _QRCardPageState();
// }

// class _QRCardPageState extends State<QRCardPage> {
//   ScreenshotController screenshotController = ScreenshotController();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Student Card')),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Screenshot(
//               controller: screenshotController,
//               child: Container(
//                 width: 300,
//                 height: 220,
//                 padding: EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   border: Border.all(color: Colors.black, width: 2),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: <Widget>[
//                     Text(widget.studentName,
//                         style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
//                     Text('Roll No: ${widget.rollNo}', style: TextStyle(color: Colors.black)),
//                     SizedBox(height: 16),
//                     QrImageView(
//                       data: widget.rollNo,
//                       version: QrVersions.auto,
//                       size: 100.0,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             SizedBox(height: 30),
//             ElevatedButton.icon(
//               icon: Icon(Icons.save_alt),
//               label: Text("Save to Gallery"),
//               onPressed: () async {
//                 // 1. Capture the widget
//                 final image = await screenshotController.capture();

//                 if (image != null) {
//                   // 2. Save to temporary directory first
//                   final directory = await getTemporaryDirectory();
//                   final filePath = '${directory.path}/${widget.rollNo}.png';
//                   final file = File(filePath);
//                   await file.writeAsBytes(image);

//                   // 3. Move to Gallery
//                   try {
//                     await Gal.putImage(filePath); // This makes it visible in Photos/Gallery
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(content: Text('Saved to Gallery! 👑')),
//                     );
//                   } catch (e) {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(content: Text('Failed to save: $e')),
//                     );
//                   }
//                 }
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }




import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gal/gal.dart'; // Add this import
import '../theme/app_colors.dart';

import 'dart:io';

class QRCardPage extends StatefulWidget {
  final String studentName;
  final String rollNo;

  QRCardPage({required this.studentName, required this.rollNo});

  @override
  _QRCardPageState createState() => _QRCardPageState();
}

class _QRCardPageState extends State<QRCardPage> {
  ScreenshotController screenshotController = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWeb = width > 800;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Student ID Card'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /// 🪪 STUDENT CARD
              Screenshot(
                controller: screenshotController,
                child: Container(
                  width: isWeb ? 420 : 320,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      /// 🎓 HEADER
                      Text(
                        "AI Attendance ID",
                        style: TextStyle(
                          fontSize: 14,
                          letterSpacing: 1,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),

                      const SizedBox(height: 12),

                      /// 👤 NAME
                      Text(
                        widget.studentName,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),

                      const SizedBox(height: 6),

                      /// 🔢 ROLL NO
                      Text(
                        "Roll No: ${widget.rollNo}",
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// 🔲 QR CODE
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.4),
                          ),
                        ),
                        child: QrImageView(
                          data: widget.rollNo,
                          version: QrVersions.auto,
                          size: 120,
                        ),
                      ),

                      const SizedBox(height: 16),

                      /// 🧠 FOOTER
                      Text(
                        "Scan for Attendance Verification",
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),

              /// 💾 SAVE BUTTON
              ElevatedButton.icon(
                icon: const Icon(Icons.save_alt),
                label: const Text("Save to Gallery"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(260, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () async {
                  // 🔒 LOGIC UNTOUCHED
                  final image = await screenshotController.capture();

                  if (image != null) {
                    final directory = await getTemporaryDirectory();
                    final filePath = '${directory.path}/${widget.rollNo}.png';
                    final file = File(filePath);
                    await file.writeAsBytes(image);

                    try {
                      await Gal.putImage(filePath);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Saved to Gallery 👑')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to save: $e')),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
