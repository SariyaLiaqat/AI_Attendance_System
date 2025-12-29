// import 'package:flutter/material.dart';
// import 'package:qr_flutter/qr_flutter.dart';

// class QRCardPage extends StatelessWidget {
//   final String studentName;
//   final String rollNo;

//   QRCardPage({required this.studentName, required this.rollNo});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Student Card')),
//       body: Center(
//         child: Container(
//           width: 300,
//           height: 220,
//           padding: EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             border: Border.all(color: Colors.black),
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: <Widget>[
//               Text(studentName,
//                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//               Text('Roll No: $rollNo'),
//               SizedBox(height: 16),
//              QrImageView(
//   data: rollNo, 
//   version: QrVersions.auto,
//   size: 100.0,
// ),
//             ],
//           ),
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
    return Scaffold(
      appBar: AppBar(title: Text('Student Card')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Screenshot(
              controller: screenshotController,
              child: Container(
                width: 300,
                height: 220,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white, 
                  border: Border.all(color: Colors.black, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(widget.studentName,
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
                    Text('Roll No: ${widget.rollNo}', style: TextStyle(color: Colors.black)),
                    SizedBox(height: 16),
                    QrImageView(
                      data: widget.rollNo,
                      version: QrVersions.auto,
                      size: 100.0,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton.icon(
              icon: Icon(Icons.save_alt),
              label: Text("Save to Gallery"),
              onPressed: () async {
                // 1. Capture the widget
                final image = await screenshotController.capture();
                
                if (image != null) {
                  // 2. Save to temporary directory first
                  final directory = await getTemporaryDirectory();
                  final filePath = '${directory.path}/${widget.rollNo}.png';
                  final file = File(filePath);
                  await file.writeAsBytes(image);

                  // 3. Move to Gallery
                  try {
                    await Gal.putImage(filePath); // This makes it visible in Photos/Gallery
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Saved to Gallery! 👑')),
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
    );
  }
}