import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;

class OCRService {
  static final OCRService _instance = OCRService._internal();
  factory OCRService() => _instance;
  OCRService._internal();

  final TextRecognizer _textRecognizer = TextRecognizer();

  /// Extract text from image using Google ML Kit
  Future<String> extractTextFromImage(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final recognizedText = await _textRecognizer.processImage(inputImage);

      // Return text (already null-safe)
      return recognizedText.text;
    } catch (e) {
      print('OCR Error: $e');
      return ''; // Return empty string instead of throwing exception
    }
  }

  /// Extract text with confidence scores
  Future<Map<String, dynamic>> extractTextWithConfidence(
    String imagePath,
  ) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final recognizedText = await _textRecognizer.processImage(inputImage);

      final text = recognizedText.text;

      // Calculate average confidence score (ML Kit doesn't provide confidence scores)
      // We'll use a simple heuristic based on text length and structure
      double averageConfidence = 0.0;
      if (text.isNotEmpty) {
        // Base confidence on text length and structure
        averageConfidence = 0.7; // Default confidence
        if (text.length > 50) averageConfidence += 0.1;
        if (text.contains(RegExp(r'\d'))) {
          averageConfidence += 0.1;
        }
        if (text.contains(RegExp(r'[A-Za-z\u0600-\u06FF]'))) {
          averageConfidence += 0.1;
        }
      }

      return {
        'text': text,
        'confidence': averageConfidence,
        'blocks': recognizedText.blocks
            .map(
              (block) => {'text': block.text, 'boundingBox': block.boundingBox},
            )
            .toList(),
      };
    } catch (e) {
      print('OCR Confidence Error: $e');
      return {
        'text': '',
        'confidence': 0.0,
        'blocks': <Map<String, dynamic>>[],
      };
    }
  }

  /// Preprocess image for better OCR results
  Future<String> preprocessImage(String imagePath) async {
    try {
      final file = File(imagePath);
      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) {
        throw Exception('Failed to decode image');
      }

      // Convert to grayscale for better OCR
      final grayscale = img.grayscale(image);

      // Enhance contrast
      final enhanced = img.contrast(grayscale, contrast: 1.2);

      // Save processed image
      final processedPath = imagePath
          .replaceAll('.jpg', '_processed.jpg')
          .replaceAll('.png', '_processed.png');
      final processedFile = File(processedPath);
      await processedFile.writeAsBytes(img.encodeJpg(enhanced));

      return processedPath;
    } catch (e) {
      // If preprocessing fails, return original path
      return imagePath;
    }
  }

  /// Check if image is suitable for OCR
  Future<bool> isImageSuitableForOCR(String imagePath) async {
    try {
      final file = File(imagePath);
      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) return false;

      // Check image dimensions (should be at least 300x300 for good OCR)
      if (image.width < 300 || image.height < 300) return false;

      // Check file size (should be reasonable)
      final fileSize = await file.length();
      if (fileSize < 10000 || fileSize > 10000000) return false; // 10KB to 10MB

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get text recognition language options
  List<String> getSupportedLanguages() {
    return ['ar', 'en']; // Arabic and English
  }

  /// Dispose resources
  void dispose() {
    _textRecognizer.close();
  }
}
