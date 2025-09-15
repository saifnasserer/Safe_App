import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;

class OCRService {
  static final OCRService _instance = OCRService._internal();
  factory OCRService() => _instance;
  OCRService._internal();

  // Use default text recognizer which supports multiple scripts including Arabic
  final TextRecognizer _textRecognizer = TextRecognizer();

  /// Extract text from image using Google ML Kit with improved Arabic support
  Future<String> extractTextFromImage(String imagePath) async {
    try {
      // Preprocess image for better OCR results
      final processedImagePath = await preprocessImage(imagePath);

      final inputImage = InputImage.fromFilePath(processedImagePath);
      final recognizedText = await _textRecognizer.processImage(inputImage);

      // Return text (already null-safe)
      String extractedText = recognizedText.text;
      print('Raw OCR extracted text: $extractedText');
      print('OCR text length: ${extractedText.length}');

      // Clean and improve the extracted text
      extractedText = _cleanExtractedText(extractedText);
      print('Cleaned OCR text: $extractedText');

      // Check if Arabic text was detected
      if (extractedText.contains(RegExp(r'[\u0600-\u06FF]'))) {
        print('Arabic text detected in OCR result');
      } else {
        print('No Arabic text detected - may be garbled or English only');
      }

      return extractedText;
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

  /// Get text recognition language options
  List<String> getSupportedLanguages() {
    return ['ar', 'en']; // Arabic and English
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

  /// Get OCR quality assessment
  Map<String, dynamic> assessOCRQuality(String text) {
    final hasArabic = isLikelyArabicText(text);
    final hasNumbers = text.contains(RegExp(r'\d'));
    final hasCurrency = text.contains(RegExp(r'[ج\.م|EGP|USD|\$|€]'));

    double qualityScore = 0.0;
    if (text.isNotEmpty) qualityScore += 0.3;
    if (hasNumbers) qualityScore += 0.3;
    if (hasCurrency) qualityScore += 0.2;
    if (hasArabic) qualityScore += 0.2;

    return {
      'qualityScore': qualityScore,
      'hasArabic': hasArabic,
      'hasNumbers': hasNumbers,
      'hasCurrency': hasCurrency,
      'textLength': text.length,
    };
  }

  /// Dispose resources
  void dispose() {
    _textRecognizer.close();
  }
}
