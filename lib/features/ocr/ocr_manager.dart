import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;
import 'package:safe/features/ocr/tesseract_ocr_service.dart';

/// OCR Engine enumeration
enum OcrEngine {
  tesseract,
  mlkit,
}

/// OCR Manager that handles switching between different OCR engines
class OcrManager {
  static final OcrManager _instance = OcrManager._internal();
  factory OcrManager() => _instance;
  OcrManager._internal();

  // Current OCR engine (default to Tesseract)
  OcrEngine _currentEngine = OcrEngine.tesseract;

  // Services
  final TesseractOcrService _tesseractService = TesseractOcrService();
  final TextRecognizer _mlkitRecognizer = TextRecognizer();

  /// Get current OCR engine
  OcrEngine get currentEngine => _currentEngine;

  /// Set OCR engine
  void setEngine(OcrEngine engine) {
    print('🔄 [OCR Manager] Switching engine from $_currentEngine to $engine');
    _currentEngine = engine;
  }

  /// Extract text from image using the current OCR engine
  Future<String> extractTextFromImage(
    String imagePath, {
    String language = 'ara+eng',
    bool preprocessImage = true,
  }) async {
    print(
        '🔍 [OCR Manager] Starting text extraction with engine: $_currentEngine');
    print('📁 [OCR Manager] Image path: $imagePath');
    print('🌐 [OCR Manager] Language: $language');

    // Try multiple approaches for better text extraction
    String result = '';

    // Approach 1: Try with current engine
    try {
      switch (_currentEngine) {
        case OcrEngine.tesseract:
          result =
              await _extractWithTesseract(imagePath, language, preprocessImage);
          break;
        case OcrEngine.mlkit:
          result = await _extractWithMLKit(imagePath, preprocessImage);
          break;
      }

      if (result.trim().isNotEmpty) {
        print(
            '✅ [OCR Manager] Successfully extracted text with $_currentEngine');
        return result;
      }
    } catch (e) {
      print('❌ [OCR Manager] Error with $_currentEngine engine: $e');
    }

    // Approach 2: Try with fallback engine
    final fallbackEngine = _currentEngine == OcrEngine.tesseract
        ? OcrEngine.mlkit
        : OcrEngine.tesseract;

    print('🔄 [OCR Manager] Trying fallback engine: $fallbackEngine');

    try {
      switch (fallbackEngine) {
        case OcrEngine.tesseract:
          result =
              await _extractWithTesseract(imagePath, language, preprocessImage);
          break;
        case OcrEngine.mlkit:
          result = await _extractWithMLKit(imagePath, preprocessImage);
          break;
      }

      if (result.trim().isNotEmpty) {
        print(
            '✅ [OCR Manager] Successfully extracted text with fallback engine: $fallbackEngine');
        _currentEngine = fallbackEngine; // Switch to the working engine
        return result;
      }
    } catch (fallbackError) {
      print('❌ [OCR Manager] Fallback engine also failed: $fallbackError');
    }

    // Approach 3: Try Tesseract with different language settings
    if (language == 'ara+eng') {
      print('🔄 [OCR Manager] Trying Tesseract with Arabic only...');
      try {
        result = await _tesseractService.extractTextFromImage(
          imagePath,
          language: 'ara',
          preprocessImage: preprocessImage,
        );
        if (result.trim().isNotEmpty) {
          print(
              '✅ [OCR Manager] Successfully extracted text with Arabic-only Tesseract');
          _currentEngine = OcrEngine.tesseract;
          return result;
        }
      } catch (e) {
        print('❌ [OCR Manager] Arabic-only Tesseract failed: $e');
      }

      print('🔄 [OCR Manager] Trying Tesseract with English only...');
      try {
        result = await _tesseractService.extractTextFromImage(
          imagePath,
          language: 'eng',
          preprocessImage: preprocessImage,
        );
        if (result.trim().isNotEmpty) {
          print(
              '✅ [OCR Manager] Successfully extracted text with English-only Tesseract');
          _currentEngine = OcrEngine.tesseract;
          return result;
        }
      } catch (e) {
        print('❌ [OCR Manager] English-only Tesseract failed: $e');
      }
    }

    // Approach 4: Analyze the image to understand why OCR is failing
    print('🔍 [OCR Manager] Analyzing image to understand OCR failure...');
    try {
      final imageAnalysis = await _tesseractService.analyzeImage(imagePath);
      print('📊 [OCR Manager] Image Analysis:');
      print(
          '   Dimensions: ${imageAnalysis['width']}x${imageAnalysis['height']}');
      print('   File Size: ${imageAnalysis['fileSize']} bytes');
      print(
          '   Average Brightness: ${imageAnalysis['averageBrightness']?.toStringAsFixed(2)}');
      print('   Contrast: ${imageAnalysis['contrast']?.toStringAsFixed(2)}');
      print('   Is Dark: ${imageAnalysis['isDark']}');
      print('   Is Bright: ${imageAnalysis['isBright']}');
      print('   Is Low Contrast: ${imageAnalysis['isLowContrast']}');
      print(
          '   Aspect Ratio: ${imageAnalysis['aspectRatio']?.toStringAsFixed(2)}');
      print('   Recommendations: ${imageAnalysis['recommendations']}');
    } catch (e) {
      print('❌ [OCR Manager] Failed to analyze image: $e');
    }

    print('❌ [OCR Manager] All OCR approaches failed - returning empty string');
    return '';
  }

  /// Extract text with confidence scores and detailed information
  Future<Map<String, dynamic>> extractTextWithConfidence(
    String imagePath, {
    String language = 'ara+eng',
    bool preprocessImage = true,
  }) async {
    print(
        '🔍 [OCR Manager] Starting detailed text extraction with engine: $_currentEngine');

    try {
      switch (_currentEngine) {
        case OcrEngine.tesseract:
          return await _tesseractService.extractTextWithConfidence(
            imagePath,
            language: language,
            preprocessImage: preprocessImage,
          );
        case OcrEngine.mlkit:
          return await _extractWithMLKitConfidence(imagePath, preprocessImage);
      }
    } catch (e) {
      print('❌ [OCR Manager] Error with $_currentEngine engine: $e');

      // Fallback to the other engine
      final fallbackEngine = _currentEngine == OcrEngine.tesseract
          ? OcrEngine.mlkit
          : OcrEngine.tesseract;

      print('🔄 [OCR Manager] Falling back to $fallbackEngine engine');
      _currentEngine = fallbackEngine;

      try {
        switch (fallbackEngine) {
          case OcrEngine.tesseract:
            return await _tesseractService.extractTextWithConfidence(
              imagePath,
              language: language,
              preprocessImage: preprocessImage,
            );
          case OcrEngine.mlkit:
            return await _extractWithMLKitConfidence(
                imagePath, preprocessImage);
        }
      } catch (fallbackError) {
        print('❌ [OCR Manager] Fallback engine also failed: $fallbackError');
        return {
          'text': '',
          'confidence': 0.0,
          'language': 'unknown',
          'hasArabic': false,
          'hasEnglish': false,
          'hasNumbers': false,
          'hasCurrency': false,
          'textLength': 0,
          'engine': 'unknown',
        };
      }
    }
  }

  /// Extract text using Tesseract OCR
  Future<String> _extractWithTesseract(
    String imagePath,
    String language,
    bool preprocessImage,
  ) async {
    print('🔍 [OCR Manager] Using Tesseract OCR engine');
    return await _tesseractService.extractTextFromImage(
      imagePath,
      language: language,
      preprocessImage: preprocessImage,
    );
  }

  /// Extract text using Google ML Kit
  Future<String> _extractWithMLKit(
      String imagePath, bool preprocessImage) async {
    print('🔍 [OCR Manager] Using Google ML Kit OCR engine');

    try {
      String processedImagePath = imagePath;

      // Preprocess image if requested
      if (preprocessImage) {
        processedImagePath = await _preprocessImageForMLKit(imagePath);
        print('✅ [OCR Manager] Image preprocessing completed for ML Kit');
      }

      final inputImage = InputImage.fromFilePath(processedImagePath);
      final recognizedText = await _mlkitRecognizer.processImage(inputImage);

      String extractedText = recognizedText.text;
      print(
          '📝 [OCR Manager] ML Kit extracted text length: ${extractedText.length}');
      print('📝 [OCR Manager] ML Kit extracted text: $extractedText');

      // Clean and improve the extracted text
      extractedText = _cleanExtractedText(extractedText);
      print('🧹 [OCR Manager] ML Kit cleaned text: $extractedText');

      // Check if Arabic text was detected
      if (extractedText.contains(RegExp(r'[\u0600-\u06FF]'))) {
        print('🔤 [OCR Manager] Arabic text detected in ML Kit result');
      } else {
        print('🔤 [OCR Manager] No Arabic text detected in ML Kit result');
      }

      // Clean up temporary processed image if created
      if (preprocessImage && processedImagePath != imagePath) {
        try {
          await File(processedImagePath).delete();
          print('🗑️ [OCR Manager] Cleaned up temporary processed image');
        } catch (e) {
          print('⚠️ [OCR Manager] Failed to delete temporary image: $e');
        }
      }

      return extractedText;
    } catch (e) {
      print('❌ [OCR Manager] ML Kit OCR Error: $e');
      return '';
    }
  }

  /// Extract text with confidence using Google ML Kit
  Future<Map<String, dynamic>> _extractWithMLKitConfidence(
    String imagePath,
    bool preprocessImage,
  ) async {
    try {
      String processedImagePath = imagePath;

      if (preprocessImage) {
        processedImagePath = await _preprocessImageForMLKit(imagePath);
      }

      final inputImage = InputImage.fromFilePath(processedImagePath);
      final recognizedText = await _mlkitRecognizer.processImage(inputImage);

      final text = recognizedText.text;

      // Calculate average confidence score (ML Kit doesn't provide confidence scores)
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

      // Analyze text content
      final hasArabic = RegExp(r'[\u0600-\u06FF]').hasMatch(text);
      final hasEnglish = RegExp(r'[A-Za-z]').hasMatch(text);
      final hasNumbers = RegExp(r'\d').hasMatch(text);
      final hasCurrency =
          RegExp(r'[ج\.م|EGP|USD|\$|€|د\.ع|SAR|ريال|ل\.ل|ليرة]').hasMatch(text);

      String detectedLanguage = 'unknown';
      if (hasArabic && hasEnglish) {
        detectedLanguage = 'mixed';
      } else if (hasArabic) {
        detectedLanguage = 'arabic';
      } else if (hasEnglish) {
        detectedLanguage = 'english';
      }

      return {
        'text': text,
        'confidence': averageConfidence,
        'language': detectedLanguage,
        'hasArabic': hasArabic,
        'hasEnglish': hasEnglish,
        'hasNumbers': hasNumbers,
        'hasCurrency': hasCurrency,
        'textLength': text.length,
        'engine': 'mlkit',
        'blocks': recognizedText.blocks
            .map(
              (block) => {'text': block.text, 'boundingBox': block.boundingBox},
            )
            .toList(),
      };
    } catch (e) {
      print('❌ [OCR Manager] ML Kit Confidence Error: $e');
      return {
        'text': '',
        'confidence': 0.0,
        'language': 'unknown',
        'hasArabic': false,
        'hasEnglish': false,
        'hasNumbers': false,
        'hasCurrency': false,
        'textLength': 0,
        'engine': 'mlkit',
        'blocks': <Map<String, dynamic>>[],
      };
    }
  }

  /// Preprocess image for ML Kit (similar to Tesseract preprocessing)
  Future<String> _preprocessImageForMLKit(String imagePath) async {
    try {
      print('🖼️ [OCR Manager] Starting image preprocessing for ML Kit...');

      final file = File(imagePath);
      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) {
        throw Exception('Failed to decode image');
      }

      // Resize image if too large
      img.Image resized = image;
      if (image.width > 2000 || image.height > 2000) {
        resized = img.copyResize(image, width: 2000, height: 2000);
      }

      // Convert to grayscale for better OCR
      final grayscale = img.grayscale(resized);

      // Enhance contrast for better text recognition
      final enhanced = img.contrast(grayscale, contrast: 1.3);

      // Apply sharpening filter
      final sharpened = img.convolution(
        enhanced,
        filter: [0, -1, 0, -1, 5, -1, 0, -1, 0],
      );

      // Save processed image
      final processedPath = imagePath
          .replaceAll('.jpg', '_mlkit_processed.jpg')
          .replaceAll('.png', '_mlkit_processed.png');
      final processedFile = File(processedPath);
      await processedFile.writeAsBytes(img.encodeJpg(sharpened));

      return processedPath;
    } catch (e) {
      print('❌ [OCR Manager] Image preprocessing failed for ML Kit: $e');
      return imagePath;
    }
  }

  /// Clean and improve extracted text (shared method)
  String _cleanExtractedText(String text) {
    if (text.isEmpty) return text;

    // Remove excessive whitespace
    text = text.replaceAll(RegExp(r'\s+'), ' ').trim();

    // Fix common OCR errors for Arabic text
    final arabicCorrections = {
      'l': 'ل',
      'o': 'و',
      'c': 'ج',
      'u': 'و',
      'n': 'ن',
      'h': 'ه',
      'a': 'ا',
      'e': 'ع',
      'i': 'ي',
      'r': 'ر',
      's': 'س',
      't': 'ت',
      'd': 'د',
      'g': 'ج',
      'b': 'ب',
      'p': 'ب',
      'f': 'ف',
      'k': 'ك',
      'm': 'م',
      'w': 'و',
      'y': 'ي',
      'z': 'ز',
      'x': 'خ',
      'v': 'ف',
      'q': 'ق',
    };

    // Apply corrections only to likely Arabic contexts
    String correctedText = text;
    if (text.contains(RegExp(r'[\u0600-\u06FF]'))) {
      for (final entry in arabicCorrections.entries) {
        correctedText = correctedText.replaceAll(entry.key, entry.value);
      }
    }

    // Remove common OCR artifacts
    correctedText = correctedText
        .replaceAll(
          RegExp(
              r'[^\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF\u0020-\u007E\u00A0-\u00FF]'),
          ' ',
        )
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

      // Check image dimensions
      if (image.width < 300 || image.height < 300) return false;

      // Check file size
      final fileSize = await file.length();
      if (fileSize < 10000 || fileSize > 10000000) return false; // 10KB to 10MB

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get supported languages for current engine
  List<String> getSupportedLanguages() {
    switch (_currentEngine) {
      case OcrEngine.tesseract:
        return _tesseractService.getSupportedLanguages();
      case OcrEngine.mlkit:
        return ['ar', 'en']; // Arabic and English
    }
  }

  /// Get OCR quality assessment
  Map<String, dynamic> assessOCRQuality(String text) {
    switch (_currentEngine) {
      case OcrEngine.tesseract:
        return _tesseractService.assessOCRQuality(text);
      case OcrEngine.mlkit:
        // Simple quality assessment for ML Kit
        final hasArabic = RegExp(r'[\u0600-\u06FF]').hasMatch(text);
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
          'engine': 'mlkit',
        };
    }
  }

  /// Dispose resources
  void dispose() {
    _mlkitRecognizer.close();
  }
}
