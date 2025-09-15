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

        // NEW CONDITION: If Tesseract result is less than 10 characters, rescan with ML Kit
        if (_currentEngine == OcrEngine.tesseract &&
            result.trim().length < 10) {
          print(
              '🔄 [OCR Manager] Tesseract result is less than 10 characters (${result.trim().length}), rescanning with ML Kit...');

          try {
            final mlkitResult =
                await _extractWithMLKit(imagePath, preprocessImage);
            if (mlkitResult.trim().isNotEmpty &&
                mlkitResult.trim().length > result.trim().length) {
              print(
                  '✅ [OCR Manager] ML Kit provided better result (${mlkitResult.trim().length} chars vs ${result.trim().length} chars)');
              return mlkitResult;
            } else {
              print(
                  'ℹ️ [OCR Manager] ML Kit result not better, keeping Tesseract result');
            }
          } catch (mlkitError) {
            print(
                '❌ [OCR Manager] ML Kit rescan failed: $mlkitError, keeping Tesseract result');
          }
        }

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
      Map<String, dynamic> result;
      switch (_currentEngine) {
        case OcrEngine.tesseract:
          result = await _tesseractService.extractTextWithConfidence(
            imagePath,
            language: language,
            preprocessImage: preprocessImage,
          );
          break;
        case OcrEngine.mlkit:
          result =
              await _extractWithMLKitConfidence(imagePath, preprocessImage);
          break;
      }

      // NEW CONDITION: If Tesseract result is less than 10 characters, rescan with ML Kit
      if (_currentEngine == OcrEngine.tesseract &&
          result['text'] != null &&
          result['text'].toString().trim().length < 10) {
        print(
            '🔄 [OCR Manager] Tesseract result is less than 10 characters (${result['text'].toString().trim().length}), rescanning with ML Kit...');

        try {
          final mlkitResult =
              await _extractWithMLKitConfidence(imagePath, preprocessImage);
          if (mlkitResult['text'] != null &&
              mlkitResult['text'].toString().trim().isNotEmpty &&
              mlkitResult['text'].toString().trim().length >
                  result['text'].toString().trim().length) {
            print(
                '✅ [OCR Manager] ML Kit provided better result (${mlkitResult['text'].toString().trim().length} chars vs ${result['text'].toString().trim().length} chars)');
            return mlkitResult;
          } else {
            print(
                'ℹ️ [OCR Manager] ML Kit result not better, keeping Tesseract result');
          }
        } catch (mlkitError) {
          print(
              '❌ [OCR Manager] ML Kit rescan failed: $mlkitError, keeping Tesseract result');
        }
      }

      return result;
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

      // If ML Kit returns empty text, try with different preprocessing
      if (extractedText.trim().isEmpty) {
        print(
            '🔄 [OCR Manager] ML Kit returned empty text, trying alternative preprocessing...');

        // Try with original image without preprocessing
        if (preprocessImage) {
          try {
            final originalInputImage = InputImage.fromFilePath(imagePath);
            final originalRecognizedText =
                await _mlkitRecognizer.processImage(originalInputImage);
            final originalText = originalRecognizedText.text;

            if (originalText.trim().isNotEmpty) {
              print(
                  '✅ [OCR Manager] ML Kit succeeded with original image: $originalText');
              extractedText = originalText;
            }
          } catch (e) {
            print('❌ [OCR Manager] ML Kit failed with original image: $e');
          }
        }

        // Try with enhanced preprocessing for Arabic text
        if (extractedText.trim().isEmpty) {
          try {
            final enhancedImagePath =
                await _preprocessImageForArabicMLKit(imagePath);
            final enhancedInputImage =
                InputImage.fromFilePath(enhancedImagePath);
            final enhancedRecognizedText =
                await _mlkitRecognizer.processImage(enhancedInputImage);
            final enhancedText = enhancedRecognizedText.text;

            if (enhancedText.trim().isNotEmpty) {
              print(
                  '✅ [OCR Manager] ML Kit succeeded with enhanced Arabic preprocessing: $enhancedText');
              extractedText = enhancedText;
            }

            // Clean up enhanced image
            try {
              await File(enhancedImagePath).delete();
            } catch (e) {
              print('⚠️ [OCR Manager] Failed to delete enhanced image: $e');
            }
          } catch (e) {
            print(
                '❌ [OCR Manager] ML Kit failed with enhanced preprocessing: $e');
          }
        }
      }

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
      String text = '';

      if (preprocessImage) {
        processedImagePath = await _preprocessImageForMLKit(imagePath);
      }

      final inputImage = InputImage.fromFilePath(processedImagePath);
      var recognizedText = await _mlkitRecognizer.processImage(inputImage);

      text = recognizedText.text;

      // If ML Kit returns empty text, try with different preprocessing
      if (text.trim().isEmpty) {
        print(
            '🔄 [OCR Manager] ML Kit confidence returned empty text, trying alternative preprocessing...');

        // Try with original image without preprocessing
        if (preprocessImage) {
          try {
            final originalInputImage = InputImage.fromFilePath(imagePath);
            final originalRecognizedText =
                await _mlkitRecognizer.processImage(originalInputImage);
            final originalText = originalRecognizedText.text;

            if (originalText.trim().isNotEmpty) {
              print(
                  '✅ [OCR Manager] ML Kit confidence succeeded with original image');
              text = originalText;
              recognizedText = originalRecognizedText;
            }
          } catch (e) {
            print(
                '❌ [OCR Manager] ML Kit confidence failed with original image: $e');
          }
        }

        // Try with enhanced preprocessing for Arabic text
        if (text.trim().isEmpty) {
          try {
            final enhancedImagePath =
                await _preprocessImageForArabicMLKit(imagePath);
            final enhancedInputImage =
                InputImage.fromFilePath(enhancedImagePath);
            final enhancedRecognizedText =
                await _mlkitRecognizer.processImage(enhancedInputImage);
            final enhancedText = enhancedRecognizedText.text;

            if (enhancedText.trim().isNotEmpty) {
              print(
                  '✅ [OCR Manager] ML Kit confidence succeeded with enhanced Arabic preprocessing');
              text = enhancedText;
              recognizedText = enhancedRecognizedText;
            }

            // Clean up enhanced image
            try {
              await File(enhancedImagePath).delete();
            } catch (e) {
              print('⚠️ [OCR Manager] Failed to delete enhanced image: $e');
            }
          } catch (e) {
            print(
                '❌ [OCR Manager] ML Kit confidence failed with enhanced preprocessing: $e');
          }
        }
      }

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

  /// Enhanced preprocessing specifically for Arabic text with ML Kit
  Future<String> _preprocessImageForArabicMLKit(String imagePath) async {
    try {
      print(
          '🖼️ [OCR Manager] Starting enhanced Arabic preprocessing for ML Kit...');

      final file = File(imagePath);
      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) {
        throw Exception('Failed to decode image');
      }

      // Upscale small images for better Arabic text recognition
      img.Image resized = image;
      if (image.width < 800 || image.height < 800) {
        final scaleFactor =
            800 / (image.width < image.height ? image.width : image.height);
        resized = img.copyResize(
          image,
          width: (image.width * scaleFactor).round(),
          height: (image.height * scaleFactor).round(),
        );
        print('📐 [OCR Manager] Upscaled image for Arabic text recognition');
      }

      // Convert to grayscale
      final grayscale = img.grayscale(resized);

      // Apply aggressive contrast enhancement for Arabic text
      final enhanced = img.contrast(grayscale, contrast: 1.5);

      // Apply brightness adjustment
      final brightnessAdjusted = img.adjustColor(enhanced, brightness: 0.1);

      // Apply sharpening specifically for Arabic characters
      final sharpened = img.convolution(
        brightnessAdjusted,
        filter: [0, -1, 0, -1, 6, -1, 0, -1, 0], // Stronger sharpening
      );

      // Apply noise reduction
      final denoised = img.gaussianBlur(sharpened, radius: 1);

      // Save processed image
      final processedPath = imagePath
          .replaceAll('.jpg', '_mlkit_arabic_processed.jpg')
          .replaceAll('.png', '_mlkit_arabic_processed.png');
      final processedFile = File(processedPath);
      await processedFile.writeAsBytes(img.encodeJpg(denoised));

      print('✅ [OCR Manager] Enhanced Arabic preprocessing completed');
      return processedPath;
    } catch (e) {
      print('❌ [OCR Manager] Enhanced Arabic preprocessing failed: $e');
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
