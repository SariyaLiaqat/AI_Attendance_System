// import 'package:flutter/material.dart';
// import 'package:mobile_scanner/mobile_scanner.dart';
// import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
// import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
// import '../services/face_embedding_service.dart';
// import 'dart:math';
// import 'dart:typed_data';
// import 'package:image/image.dart' as img;


// class SmartScannerView extends StatefulWidget {
//   // 👑 Updated: We now only need the callback to send back the found roll and face status
//  final Function(String rollNumber, List<double> embedding) onDetected;


//   SmartScannerView({required this.onDetected});

//   @override
//   _SmartScannerViewState createState() => _SmartScannerViewState();
// }

// class _SmartScannerViewState extends State<SmartScannerView> with SingleTickerProviderStateMixin {
//   final TextRecognizer _textRecognizer = TextRecognizer();
//   final FaceDetector _faceDetector = FaceDetector(options: FaceDetectorOptions());
//   final FaceEmbeddingService _embeddingService = FaceEmbeddingService();

//   late AnimationController _animationController;
//   late Animation<double> _animation;
  
//   bool _isProcessing = false;
//   bool _hasFoundMatch = false;

//   MobileScannerController cameraController = MobileScannerController(
//     returnImage: true,
//     facing: CameraFacing.back, 
//   );

//   @override
//   void initState() {
//     super.initState();
//     _embeddingService.loadModel();

//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(seconds: 2),
//     )..repeat(reverse: true);
    
//     _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);
//   }

//  // 1. Add this one line right ABOVE the _processImage function
//   DateTime? _lastProcessedTime;

//   Future<void> _processImage(BarcodeCapture capture) async {
//     // 👑 CHANGE 1: THE THROTTLE
//     // Let's print a warning so we know why it's skipping!
//   if (capture.image == null) {
//     print("⚠️ Scanner Warning: capture.image is NULL. No bytes to process.");
//     return;
//   }
//     // This stops the "Lost connection" error by only scanning every 1.5 seconds.
//     final now = DateTime.now();
//     if (_lastProcessedTime != null && 
//         now.difference(_lastProcessedTime!).inMilliseconds < 1500) {
//       return; 
//     }

//     if (_isProcessing || _hasFoundMatch || capture.image == null) return;
    
//     _isProcessing = true;
//     _lastProcessedTime = now; // Record the time of this scan

//     try {
//       print("📸 Scanner: Image Captured. Processing...");

//       final inputImage = InputImage.fromBytes(
//         bytes: capture.image!,
//         metadata: InputImageMetadata(
//           size: capture.size,
//           // 👑 CHANGE 2: THE ROTATION
//           // Front cameras usually need 'rotation270deg' to read text correctly on Android
//           rotation: InputImageRotation.rotation90deg, 
//           format: InputImageFormat.nv21,
//           bytesPerRow: capture.size.width.toInt(),
//         ),
//       );

//       // 1. Detect Roll Number (QR/Barcode)
//       String? detectedRoll;
//       for (final barcode in capture.barcodes) {
//         if (barcode.rawValue != null) {
//           detectedRoll = barcode.rawValue;
//           print("🎯 QR Found: $detectedRoll");
//         }
//       }

//       // 2. OCR (Text Recognition)
//       if (detectedRoll == null) {
//         final text = await _textRecognizer.processImage(inputImage);
//         // This looks for a number with 3 or more digits
//         detectedRoll = RegExp(r'\b\d{3,}\b').stringMatch(text.text);
//         if (detectedRoll != null) print("📝 OCR Found Roll: $detectedRoll");
//       }

//       // 3. Detect Face
//       final faces = await _faceDetector.processImage(inputImage);
//       print("👤 Faces detected: ${faces.length}");

//       // 4. Logic Check
//       if (detectedRoll != null) {
//         if (faces.isNotEmpty) {
//   final Face face = faces.first;

//   // 🔥 STEP 4.1 — FACE CROP
//   final croppedFaceImage = cropFaceFromImage(
//     capture.image!,
//     face,
//     capture.size,
//   );

//   // 🔥 STEP 4.2 — EMBEDDING GENERATE
//   final List<double> liveEmbedding =
//       _embeddingService.getEmbedding(croppedFaceImage);

//   print("🧠 Face Embedding Generated (${liveEmbedding.length})");

//   _hasFoundMatch = true;
//   widget.onDetected(detectedRoll, liveEmbedding);
// }
//  else {
//           print("⚠️ Found Roll $detectedRoll but NO Face visible.");
//         }
//       } else {
//         print("🔎 Scanning... No roll number detected yet.");
//       }
//     } catch (e) {
//       print("❌ Scanner Error: $e");
//     } finally {
//       _isProcessing = false;
//     }

    
//   }

//   img.Image cropFaceFromImage(
//   Uint8List imageBytes,
//   Face face,
//   Size imageSize,
// ) {
//   final img.Image originalImage = img.decodeImage(imageBytes)!;

//   final rect = face.boundingBox;

//   int x = rect.left.toInt().clamp(0, originalImage.width);
//   int y = rect.top.toInt().clamp(0, originalImage.height);
//   int w = rect.width.toInt();
//   int h = rect.height.toInt();

//   int size = min(w, h);

//   return img.copyCrop(originalImage, x, y, size, size);
// }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     _textRecognizer.close();
//     _faceDetector.close();
//     cameraController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//        MobileScanner(
//   controller: cameraController,
//   // 👑 CHANGE: Use a simpler onDetect to see if it triggers AT ALL
//   onDetect: (BarcodeCapture capture) {
//     print("📡 ON DETECT TRIGGERED!"); // If you don't see this, the plugin is stuck
//     _processImage(capture);
//   },
// ),
        
//         // 👑 The Real Animated Laser Movement - Logic Kept
//         AnimatedBuilder(
//           animation: _animation,
//           builder: (context, child) {
//             return Positioned(
//               top: MediaQuery.of(context).size.height * 0.2 + 
//                    (MediaQuery.of(context).size.height * 0.4 * _animation.value),
//               left: 40,
//               right: 40,
//               child: Container(
//                 height: 3,
//                 decoration: BoxDecoration(
//                   color: Colors.cyanAccent,
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.cyanAccent.withOpacity(0.8),
//                       blurRadius: 15,
//                       spreadRadius: 2,
//                     )
//                   ],
//                 ),
//               ),
//             );
//           },
//         ),

//         // Visual Guide UI - 👑 Logic Kept
//         Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Container(
//                 width: 280,
//                 height: 350,
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
//                   borderRadius: BorderRadius.circular(30),
//                 ),
//                 child: const Align(
//                   alignment: Alignment.bottomCenter,
//                   child: Padding(
//                     padding: EdgeInsets.all(10),
//                     child: Text("POSITION FACE & CARD HERE", 
//                       style: TextStyle(color: Colors.white70, fontSize: 10, letterSpacing: 2)),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               // 👑 Updated: Chip now just shows that it is ready to scan
//               const Chip(
//                 backgroundColor: Colors.black54,
//                 label: Text("SCANNING FOR ID...", 
//                   style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold)),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }




import 'dart:io'; // 👑 This defines 'Platform'

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import '../services/face_embedding_service.dart';

class FaceScannerPage extends StatefulWidget {
  final Function(List<double> embedding) onResult;

  FaceScannerPage({required this.onResult});

  @override
  State<FaceScannerPage> createState() => _FaceScannerPageState();
}

class _FaceScannerPageState extends State<FaceScannerPage> {
  late CameraController _cameraController;
  bool _isCameraReady = false;
  bool _isProcessing = false;
  final FaceDetector _faceDetector =
      FaceDetector(options: FaceDetectorOptions(performanceMode: FaceDetectorMode.accurate));
  final FaceEmbeddingService _embeddingService = FaceEmbeddingService();

  @override
  void initState() {
    super.initState();
    _initCameraAndModel();
  }

  Future<void> _initCameraAndModel() async {
    await _embeddingService.loadModel();
    final cameras = await availableCameras();
    final frontCamera = cameras.firstWhere((c) => c.lensDirection == CameraLensDirection.front);

    _cameraController = CameraController(
  frontCamera,
  ResolutionPreset.low,
  enableAudio: false,
  // 👑 ADD THIS LINE:
  imageFormatGroup: Platform.isAndroid 
      ? ImageFormatGroup.nv21 // NV21 is more stable for Android ML Kit
      : ImageFormatGroup.bgra8888, 
);

    await _cameraController.initialize();
    setState(() => _isCameraReady = true);

    _cameraController.startImageStream(_processCameraImage);
  }

 Future<void> _processCameraImage(CameraImage image) async {
  if (_isProcessing) return;
  _isProcessing = true;

  try {
    // 👑 FOR ANDROID: We only need the first plane (the Y plane) for face detection
    // This avoids the 'IllegalArgument' mismatch error!
    final bytes = image.planes[0].bytes; 

   final inputImage = InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: InputImageRotation.rotation270deg, 
        format: InputImageFormat.yuv420, // 👑 USE THIS for stability
        bytesPerRow: image.planes[0].bytesPerRow,
      ),
    );

    final faces = await _faceDetector.processImage(inputImage);
    
    if (faces.isNotEmpty) {
      await _cameraController.stopImageStream();
      
      final face = faces.first;
      final cropped = _cropFace(image, face);
      final embedding = _embeddingService.getEmbedding(cropped);

      if (mounted) {
        widget.onResult(embedding);
        Navigator.pop(context);
      }
    }
  } catch (e) {
    print("👑 ML Kit Error Caught: $e");
  } finally {
    _isProcessing = false;
  }
}
  // void _stopCamera() {
  //   _cameraController.stopImageStream();
  // }

  // Uint8List _concatenatePlanes(List<Plane> planes) {
  //   final bytes = <int>[];
  //   for (var plane in planes) {
  //     bytes.addAll(plane.bytes);
  //   }
  //   return Uint8List.fromList(bytes);
  // }

  img.Image _cropFace(CameraImage cameraImage, Face face) {
  // 👑 Note: Converting YUV to RGB is heavy. 
  // For now, let's grab the Y plane correctly for a clear crop
  final bytes = cameraImage.planes[0].bytes;
  img.Image image = img.Image.fromBytes(
    cameraImage.width,
    cameraImage.height,
    bytes,
    format: img.Format.luminance, // Y plane is luminance
  );

  // 👑 Rotate image to match what the eye sees
  image = img.copyRotate(image, -90); 

  final rect = face.boundingBox;
  return img.copyCrop(
    image,
    rect.left.toInt(),
    rect.top.toInt(),
    rect.width.toInt(),
    rect.height.toInt(),
  );
}

  @override
  void dispose() {
    _cameraController.dispose();
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraReady) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text("Face Scanner")),
      body: Stack(
        children: [
          CameraPreview(_cameraController),
          Center(
            child: Container(
              width: 280,
              height: 350,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white70, width: 2),
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
