


import 'dart:typed_data';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'dart:math';
class FaceEmbeddingService {
  late Interpreter _interpreter;
  bool _isLoaded = false;

  Future<void> loadModel() async {
    _interpreter =
        await Interpreter.fromAsset('model/mobilefacenet.tflite');
    _isLoaded = true;
  }
double compareFaces(List<double> currEmb, List<double> storedEmb) {
  double distance = 0.0;
  for (int i = 0; i < 192; i++) {
    double diff = currEmb[i] - storedEmb[i];
    distance += diff * diff;
  }
  return sqrt(distance); // Use dart:math
}
 List<double> getEmbedding(img.Image faceImage) {
  if (!_isLoaded) {
    throw Exception("Model not loaded yet");
  }

  // 1. Resize the face
  img.Image resized = img.copyResize(faceImage, width: 112, height: 112);

  // 2. Prepare the input (keep this as you have it)
  var input = Float32List(1 * 112 * 112 * 3);
  int idx = 0;
  for (int y = 0; y < 112; y++) {
    for (int x = 0; x < 112; x++) {
      final pixel = resized.getPixel(x, y);
      input[idx++] = (img.getRed(pixel) - 128) / 128.0;   // Tip: Better normalization
      input[idx++] = (img.getGreen(pixel) - 128) / 128.0; 
      input[idx++] = (img.getBlue(pixel) - 128) / 128.0;
    }
  }

  // ⭐ THE KEY CHANGE: 
  // We create a "List inside a List" to match the shape [1, 192]
  var output = List.generate(1, (index) => List.filled(192, 0.0));

  // 3. Run the interpreter with the nested output
  _interpreter.run(input.reshape([1, 112, 112, 3]), output);

  // 4. Return the first item (the actual 192 numbers)
  return List<double>.from(output[0]);
}
}
