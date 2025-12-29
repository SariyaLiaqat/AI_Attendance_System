import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import '../services/face_embedding_service.dart';

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
    final bytes = await DefaultAssetBundle.of(context)
        .load('assets/model/mobilefacenet.tflite');
    print("Model loaded, size: ${bytes.lengthInBytes}");
  } catch (e) {
    print("Failed to load asset: $e");
  }

  // Then actually load the model into interpreter
  await _embeddingService.loadModel();
  setState(() => _isModelReady = true);
  print("Face model loaded ✅");
}


  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    final frontCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
    );

    _cameraController = CameraController(
      frontCamera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await _cameraController.initialize();
    setState(() => _isCameraReady = true);
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
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
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

    return Scaffold(
      appBar: AppBar(title: Text("Capture Face")),
      body: Stack(
        children: [
          CameraPreview(_cameraController),
          Positioned(
            bottom: 80,
            left: 50,
            child: FloatingActionButton(
              heroTag: "gallery",
              onPressed: _pickFromGallery,
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
                child: Icon(Icons.camera_alt),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
