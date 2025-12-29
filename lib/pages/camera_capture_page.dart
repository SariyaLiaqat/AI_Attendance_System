// import 'dart:io';
// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:camera/camera.dart';
// import 'package:google_ml_kit/google_ml_kit.dart';
// import 'package:image/image.dart' as img;
// import 'package:image_picker/image_picker.dart';
// import '../services/face_embedding_service.dart';

// class CameraCapturePage extends StatefulWidget {
//   @override
//   State<CameraCapturePage> createState() => _CameraCapturePageState();
// }

// class _CameraCapturePageState extends State<CameraCapturePage> {
//   late CameraController _cameraController;
//   bool _isCameraReady = false;
//   bool _isModelReady = false;

//   final FaceDetector _faceDetector = GoogleMlKit.vision.faceDetector(
//     FaceDetectorOptions(performanceMode: FaceDetectorMode.accurate),
//   );

//   final FaceEmbeddingService _embeddingService = FaceEmbeddingService();

//   @override
//   void initState() {
//     super.initState();
//     _initEverything();
//   }

//   Future<void> _initEverything() async {
//     await _loadModel();
//     await _initCamera();
//   }

//   Future<void> _loadModel() async {
//   try {
//     final bytes = await DefaultAssetBundle.of(context)
//         .load('assets/model/mobilefacenet.tflite');
//     print("Model loaded, size: ${bytes.lengthInBytes}");
//   } catch (e) {
//     print("Failed to load asset: $e");
//   }

//   // Then actually load the model into interpreter
//   await _embeddingService.loadModel();
//   setState(() => _isModelReady = true);
//   print("Face model loaded ✅");
// }

//   Future<void> _initCamera() async {
//     final cameras = await availableCameras();
//     final frontCamera = cameras.firstWhere(
//       (camera) => camera.lensDirection == CameraLensDirection.front,
//     );

//     _cameraController = CameraController(
//       frontCamera,
//       ResolutionPreset.medium,
//       enableAudio: false,
//     );

//     await _cameraController.initialize();
//     setState(() => _isCameraReady = true);
//   }

//   Future<void> _captureAndProcess({XFile? file}) async {
//     try {
//       // If file is not passed, capture from camera
//       file ??= await _cameraController.takePicture();
//       final inputImage = InputImage.fromFile(File(file.path));

//       final faces = await _faceDetector.processImage(inputImage);

//       if (faces.isEmpty) {
//         _showError("No face detected. Try again.");
//         return;
//       }

//       final Face face = faces.first;

//       final bytes = await File(file.path).readAsBytes();
//       img.Image original = img.decodeImage(bytes)!;

//       print("Picture path: ${file.path}");
//       print("Faces detected: ${faces.length}");
//       print("Face bounding box: ${face.boundingBox}");

//       // Crop square around face
//       final rect = face.boundingBox;
//       int x = max(rect.left.toInt(), 0);
//       int y = max(rect.top.toInt(), 0);
//       int size = min(rect.width, rect.height).toInt();
//       img.Image cropped = img.copyCrop(original, x, y, size, size);

//       // Generate embedding
//       List<double> embedding = _embeddingService.getEmbedding(cropped);
//       print("Embedding length: ${embedding.length}");
//       print("First 5 values: ${embedding.sublist(0, 5)}");

//       Navigator.pop(context, embedding);
//     } catch (e) {
//       _showError("Error: $e");
//     }
//   }

//   Future<void> _pickFromGallery() async {
//     final picker = ImagePicker();
//     final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       await _captureAndProcess(file: pickedFile);
//     }
//   }

//   void _showError(String msg) {
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
//   }

//   @override
//   void dispose() {
//     _cameraController.dispose();
//     _faceDetector.close();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (!_isCameraReady || !_isModelReady) {
//       return Scaffold(body: Center(child: CircularProgressIndicator()));
//     }

//     return Scaffold(
//       appBar: AppBar(title: Text("Capture Face")),
//       body: Stack(
//         children: [
//           CameraPreview(_cameraController),
//           Positioned(
//             bottom: 80,
//             left: 50,
//             child: FloatingActionButton(
//               heroTag: "gallery",
//               onPressed: _pickFromGallery,
//               child: Icon(Icons.photo_library),
//             ),
//           ),
//           Positioned(
//             bottom: 30,
//             left: 0,
//             right: 0,
//             child: Center(
//               child: FloatingActionButton(
//                 heroTag: "camera",
//                 onPressed: _captureAndProcess,
//                 child: Icon(Icons.camera_alt),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import '../services/face_embedding_service.dart';
import '../theme/app_colors.dart';

class CameraCapturePage extends StatefulWidget {
  @override
  State<CameraCapturePage> createState() => _CameraCapturePageState();
}

class _CameraCapturePageState extends State<CameraCapturePage> {
  late CameraController _cameraController;
  bool _isCameraReady = false;
  bool _isModelReady = false;

  final FaceDetector _faceDetector = GoogleMlKit.vision.faceDetector(
    FaceDetectorOptions(performanceMode: FaceDetectorMode.accurate),
  );

  final FaceEmbeddingService _embeddingService = FaceEmbeddingService();

  @override
  void initState() {
    super.initState();
    _initEverything();
  }

  Future<void> _initEverything() async {
    await _loadModel();
    await _initCamera();
  }

  Future<void> _loadModel() async {
    try {
      final bytes = await DefaultAssetBundle.of(
        context,
      ).load('assets/model/mobilefacenet.tflite');
      print("Model loaded, size: ${bytes.lengthInBytes}");
    } catch (e) {
      print("Failed to load asset: $e");
    }

    // Then actually load the model into interpreter
    await _embeddingService.loadModel();
    setState(() => _isModelReady = true);
    print("Face model loaded ✅");
  }

  // Change your _initCamera to this:
  Future<void> _initCamera({
    CameraLensDirection direction = CameraLensDirection.front,
  }) async {
    final cameras = await availableCameras();
    final selectedCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == direction,
      orElse: () => cameras.first,
    );

    _cameraController = CameraController(
      selectedCamera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await _cameraController.initialize();
    if (mounted) setState(() => _isCameraReady = true);
  }

  void _toggleCamera() {
    final currentDir = _cameraController.description.lensDirection;
    final newDir = (currentDir == CameraLensDirection.front)
        ? CameraLensDirection.back
        : CameraLensDirection.front;

    _cameraController.dispose();
    setState(() => _isCameraReady = false);
    _initCamera(direction: newDir);
  }

  Future<void> _captureAndProcess({XFile? file}) async {
    try {
      // If file is not passed, capture from camera
      file ??= await _cameraController.takePicture();
      final inputImage = InputImage.fromFile(File(file.path));

      final faces = await _faceDetector.processImage(inputImage);

      if (faces.isEmpty) {
        _showError("No face detected. Try again.");
        return;
      }

      final Face face = faces.first;

      final bytes = await File(file.path).readAsBytes();
      img.Image original = img.decodeImage(bytes)!;

      print("Picture path: ${file.path}");
      print("Faces detected: ${faces.length}");
      print("Face bounding box: ${face.boundingBox}");

      // Crop square around face
      final rect = face.boundingBox;
      int x = max(rect.left.toInt(), 0);
      int y = max(rect.top.toInt(), 0);
      int size = min(rect.width, rect.height).toInt();
      img.Image cropped = img.copyCrop(original, x, y, size, size);

      // Generate embedding
      List<double> embedding = _embeddingService.getEmbedding(cropped);
      print("Embedding length: ${embedding.length}");
      print("First 5 values: ${embedding.sublist(0, 5)}");

      Navigator.pop(context, embedding);
    } catch (e) {
      _showError("Error: $e");
    }
  }

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      await _captureAndProcess(file: pickedFile);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraReady || !_isModelReady) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final size = MediaQuery.of(context).size;
    final overlaySize = size.width * 0.6;

    // Calculate dynamic border color based on hypothetical alignment
    // You can later link this with ML face bounding box size/position
    Color overlayColor = Colors.red; // default
    if (_cameraController.value.isInitialized) {
      // Example logic for demo purposes
      // You can replace with actual distance/alignment check from face bounding box
      overlayColor = Colors.greenAccent.withOpacity(0.8); // best alignment
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("Capture Face"),
        backgroundColor: AppColors.primary,
      ),
      body: Stack(
        children: [
          // Camera feed
          CameraPreview(_cameraController),

          // Face guide overlay
          Center(
            child: Container(
              width: overlaySize,
              height: overlaySize,
              decoration: BoxDecoration(
                border: Border.all(
                  color: overlayColor, // dynamic color
                  width: 4,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          // Guidance text
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  "Place your face inside the box",
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
                const SizedBox(height: 8),
                Text(
                  "Maintain 1-1.5 meters distance from camera",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  "Ensure good lighting for accurate detection",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),

          // Bottom buttons
          Positioned(
            bottom: 80,
            left: 50,
            child: FloatingActionButton(
              heroTag: "gallery",
              onPressed: _pickFromGallery,
              backgroundColor: AppColors.primary,
              child: Icon(Icons.photo_library),
            ),
          ),
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: FloatingActionButton(
                heroTag: "camera",
                onPressed: _captureAndProcess,
                backgroundColor: AppColors.primary,
                child: Icon(Icons.camera_alt),
              ),
            ),
          ),
          Positioned(
            bottom: 80,
            right: 50, // Places it opposite to the gallery button
            child: FloatingActionButton(
              heroTag: "toggle",
              onPressed: _toggleCamera,
              backgroundColor: AppColors.primary,
              child: Icon(Icons.flip_camera_android),
            ),
          ),
        ],
      ),
    );
  }
}
