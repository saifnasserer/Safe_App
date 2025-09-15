import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;
import 'package:safe/features/ocr/ocr_manager.dart';

class OCRService {
  static final OCRService _instance = OCRService._internal();
  factory OCRService() => _instance;
  OCRService._internal();

  // Use the new OCR Manager for engine switching
  final OcrManager _ocrManager = OcrManager();

  // Keep the old ML Kit recognizer for backward compatibility
  final TextRecognizer _textRecognizer = TextRecognizer();

  /// Extract text from image using the new OCR Manager (Tesseract by default)
  Future<String> extractTextFromImage(String imagePath) async {
    try {
      print('🔍 [OCR Service] Using new OCR Manager for text extraction');

      // Use the new OCR Manager which defaults to Tesseract
      final extractedText = await _ocrManager.extractTextFromImage(
        imagePath,
        language: 'ara+eng', // Support both Arabic and English
        preprocessImage: true,
      );

      print('📝 [OCR Service] Extracted text length: ${extractedText.length}');
      print('📝 [OCR Service] Extracted text: $extractedText');

      return extractedText;
    } catch (e) {
      print(
          '❌ [OCR Service] Error with new OCR Manager, falling back to ML Kit: $e');

      // Fallback to the old ML Kit implementation
      try {
        final processedImagePath = await preprocessImage(imagePath);
        final inputImage = InputImage.fromFilePath(processedImagePath);
        final recognizedText = await _textRecognizer.processImage(inputImage);

        String extractedText = recognizedText.text;
        print(
            '📝 [OCR Service] ML Kit fallback extracted text: $extractedText');

        extractedText = _cleanExtractedText(extractedText);
        print('🧹 [OCR Service] ML Kit fallback cleaned text: $extractedText');

        return extractedText;
      } catch (fallbackError) {
        print('❌ [OCR Service] ML Kit fallback also failed: $fallbackError');
        return '';
      }
    }
  }

  /// Extract text with confidence scores using the new OCR Manager
  Future<Map<String, dynamic>> extractTextWithConfidence(
    String imagePath,
  ) async {
    try {
      print(
          '🔍 [OCR Service] Using new OCR Manager for detailed text extraction');

      // Use the new OCR Manager which provides better confidence scores
      final result = await _ocrManager.extractTextWithConfidence(
        imagePath,
        language: 'ara+eng',
        preprocessImage: true,
      );

      print(
          '📊 [OCR Service] OCR result: ${result['engine']} engine, confidence: ${result['confidence']}');
      return result;
    } catch (e) {
      print(
          '❌ [OCR Service] Error with new OCR Manager, falling back to ML Kit: $e');

      // Fallback to the old ML Kit implementation
      try {
        final inputImage = InputImage.fromFilePath(imagePath);
        final recognizedText = await _textRecognizer.processImage(inputImage);

        final text = recognizedText.text;

        // Calculate average confidence score (ML Kit doesn't provide confidence scores)
        double averageConfidence = 0.0;
        if (text.isNotEmpty) {
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
          'engine': 'mlkit',
          'blocks': recognizedText.blocks
              .map(
                (block) =>
                    {'text': block.text, 'boundingBox': block.boundingBox},
              )
              .toList(),
        };
      } catch (fallbackError) {
        print('❌ [OCR Service] ML Kit fallback also failed: $fallbackError');
        return {
          'text': '',
          'confidence': 0.0,
          'engine': 'unknown',
          'blocks': <Map<String, dynamic>>[],
        };
      }
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

      // Resize image if too large (OCR works better with reasonable sizes)
      img.Image resized = image;
      if (image.width > 2000 || image.height > 2000) {
        resized = img.copyResize(image, width: 2000, height: 2000);
      }

      // Convert to grayscale for better OCR
      final grayscale = img.grayscale(resized);

      // Enhance contrast for better text recognition
      final enhanced = img.contrast(grayscale, contrast: 1.3);

      // Apply sharpening filter
      final sharpened =
          img.convolution(enhanced, filter: [0, -1, 0, -1, 5, -1, 0, -1, 0]);

      // Save processed image
      final processedPath = imagePath
          .replaceAll('.jpg', '_processed.jpg')
          .replaceAll('.png', '_processed.png');
      final processedFile = File(processedPath);
      await processedFile.writeAsBytes(img.encodeJpg(sharpened));

      return processedPath;
    } catch (e) {
      print('Image preprocessing failed: $e');
      // If preprocessing fails, return original path
      return imagePath;
    }
  }

  /// Clean and improve extracted text
  String _cleanExtractedText(String text) {
    if (text.isEmpty) return text;

    // Remove excessive whitespace
    text = text.replaceAll(RegExp(r'\s+'), ' ').trim();

    // Fix common OCR errors for Arabic text
    // These are common misrecognitions of Arabic characters
    final arabicCorrections = {
      'l': 'ل', // Common misrecognition
      'o': 'و', // Common misrecognition
      'c': 'ج', // Common misrecognition
      'u': 'و', // Common misrecognition
      'n': 'ن', // Common misrecognition
      'h': 'ه', // Common misrecognition
      'a': 'ا', // Common misrecognition
      'e': 'ع', // Common misrecognition
      'i': 'ي', // Common misrecognition
      'r': 'ر', // Common misrecognition
      's': 'س', // Common misrecognition
      't': 'ت', // Common misrecognition
      'd': 'د', // Common misrecognition
      'g': 'ج', // Common misrecognition
      'b': 'ب', // Common misrecognition
      'p': 'ب', // Common misrecognition
      'f': 'ف', // Common misrecognition
      'k': 'ك', // Common misrecognition
      'm': 'م', // Common misrecognition
      'w': 'و', // Common misrecognition
      'y': 'ي', // Common misrecognition
      'z': 'ز', // Common misrecognition
      'x': 'خ', // Common misrecognition
      'v': 'ف', // Common misrecognition
      'q': 'ق', // Common misrecognition
    };

    // Apply corrections only to likely Arabic contexts
    String correctedText = text;
    for (final entry in arabicCorrections.entries) {
      // Only apply corrections if the character appears in a context that suggests Arabic
      if (text.contains(RegExp(r'[\u0600-\u06FF]'))) {
        correctedText = correctedText.replaceAll(entry.key, entry.value);
      }
    }

    // Remove common OCR artifacts
    correctedText = correctedText
        .replaceAll(
            RegExp(
                r'[^\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF\u0020-\u007E\u00A0-\u00FF]'),
            ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    return correctedText;
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

  /// Detect if extracted text likely contains Arabic content
  bool isLikelyArabicText(String text) {
    if (text.isEmpty) return false;

    // Count Arabic characters
    final arabicChars = RegExp(r'[\u0600-\u06FF]').allMatches(text).length;
    final totalChars = text.replaceAll(RegExp(r'\s'), '').length;

    if (totalChars == 0) return false;

    // If more than 30% of characters are Arabic, consider it Arabic text
    final arabicRatio = arabicChars / totalChars;
    return arabicRatio > 0.3;
  }

  /// Switch OCR engine
  void setOcrEngine(OcrEngine engine) {
    print('🔄 [OCR Service] Switching OCR engine to: $engine');
    _ocrManager.setEngine(engine);
  }

  /// Get current OCR engine
  OcrEngine getCurrentOcrEngine() {
    return _ocrManager.currentEngine;
  }

  /// Get supported languages for current engine
  List<String> getSupportedLanguages() {
    return _ocrManager.getSupportedLanguages();
  }

  /// Check if image is suitable for OCR
  // Future<bool> isImageSuitableForOCR(String imagePath) async {
  //   return await _ocrManager.isImageSuitableForOCR(imagePath);
  // }

  /// Get OCR quality assessment
  Map<String, dynamic> assessOCRQuality(String text) {
    return _ocrManager.assessOCRQuality(text);
  }

  /// Dispose resources
  void dispose() {
    _textRecognizer.close();
    _ocrManager.dispose();
  }
}
