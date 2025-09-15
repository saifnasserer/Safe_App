import 'dart:io';
import 'dart:math' as math;
import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

/// Tesseract OCR Service for Arabic and English text recognition
class TesseractOcrService {
  static final TesseractOcrService _instance = TesseractOcrService._internal();
  factory TesseractOcrService() => _instance;
  TesseractOcrService._internal();

  /// Extract text from image using Tesseract OCR with multiple preprocessing approaches
  /// Supports both Arabic and English text recognition
  Future<String> extractTextFromImage(
    String imagePath, {
    String language = 'ara+eng', // Default to Arabic + English
    bool preprocessImage = true,
  }) async {
    try {
      print('🔍 [Tesseract OCR] Starting text extraction...');
      print('📁 [Tesseract OCR] Image path: $imagePath');
      print('🌐 [Tesseract OCR] Language: $language');
      print('🖼️ [Tesseract OCR] Preprocessing enabled: $preprocessImage');

      String processedImagePath = imagePath;

      // Preprocess image if requested
      if (preprocessImage) {
        processedImagePath = await _preprocessImage(imagePath);
        print('✅ [Tesseract OCR] Image preprocessing completed');
      }

      // Test Arabic language specifically
      print('🧪 [Tesseract OCR] Testing Arabic OCR specifically...');
      print('🧪 [Tesseract OCR] Using fresh Arabic trained data file...');
      try {
        final arabicResult = await FlutterTesseractOcr.extractText(
          imagePath,
          language: 'ara', // Test Arabic only
          args: {
            "tessedit_pageseg_mode": "1",
            "tessedit_ocr_engine_mode": "1",
          },
        );
        print(
            '🧪 [Tesseract OCR] Arabic test result: "$arabicResult" (length: ${arabicResult.length})');

        if (arabicResult.trim().isNotEmpty) {
          print('✅ [Tesseract OCR] Arabic OCR test succeeded!');
          return arabicResult;
        } else {
          print(
              '⚠️ [Tesseract OCR] Arabic OCR returned empty result - Arabic trained data might not be working');
        }
      } catch (e) {
        print('❌ [Tesseract OCR] Arabic OCR test failed: $e');
      }

      // Test English language specifically
      print('🧪 [Tesseract OCR] Testing English OCR specifically...');
      try {
        final englishResult = await FlutterTesseractOcr.extractText(
          imagePath,
          language: 'eng', // Test English only
          args: {
            "tessedit_pageseg_mode": "1",
            "tessedit_ocr_engine_mode": "1",
          },
        );
        print(
            '🧪 [Tesseract OCR] English test result: "$englishResult" (length: ${englishResult.length})');

        if (englishResult.trim().isNotEmpty) {
          print('✅ [Tesseract OCR] English OCR test succeeded!');
          return englishResult;
        }
      } catch (e) {
        print('❌ [Tesseract OCR] English OCR test failed: $e');
      }

      // Test combined languages
      print('🧪 [Tesseract OCR] Testing combined languages (ara+eng)...');
      try {
        final combinedResult = await FlutterTesseractOcr.extractText(
          imagePath,
          language: 'ara+eng', // Test combined languages
          args: {
            "tessedit_pageseg_mode": "1",
            "tessedit_ocr_engine_mode": "1",
          },
        );
        print(
            '🧪 [Tesseract OCR] Combined test result: "$combinedResult" (length: ${combinedResult.length})');

        if (combinedResult.trim().isNotEmpty) {
          print('✅ [Tesseract OCR] Combined OCR test succeeded!');
          return combinedResult;
        }
      } catch (e) {
        print('❌ [Tesseract OCR] Combined OCR test failed: $e');
      }

      // Perform OCR using Tesseract with improved parameters
      print(
          '🔧 [Tesseract OCR] About to call FlutterTesseractOcr.extractText...');
      print('🔧 [Tesseract OCR] Image path: $processedImagePath');
      print('🔧 [Tesseract OCR] Language: $language');

      // Try with minimal parameters first to isolate the issue
      final extractedText = await FlutterTesseractOcr.extractText(
        processedImagePath,
        language: language,
        args: {
          "tessedit_pageseg_mode": "1",
          "tessedit_ocr_engine_mode": "1",
        },
      );

      print('🔧 [Tesseract OCR] FlutterTesseractOcr.extractText completed');
      print('🔧 [Tesseract OCR] Raw result type: ${extractedText.runtimeType}');
      print('🔧 [Tesseract OCR] Raw result length: ${extractedText.length}');
      print('🔧 [Tesseract OCR] Raw result content: "$extractedText"');

      print(
          '📝 [Tesseract OCR] Raw extracted text length: ${extractedText.length}');
      print('📝 [Tesseract OCR] Raw extracted text: $extractedText');

      // Check if no text was extracted
      if (extractedText.trim().isEmpty) {
        print(
            '⚠️ [Tesseract OCR] No text extracted - trying alternative preprocessing...');

        // Try alternative preprocessing approaches
        final alternativeResult =
            await _tryAlternativePreprocessing(imagePath, language);
        if (alternativeResult.isNotEmpty) {
          print('✅ [Tesseract OCR] Alternative preprocessing succeeded');
          return alternativeResult;
        }

        print(
            '💡 [Tesseract OCR] All preprocessing approaches failed - consider ML Kit fallback');
      }

      // Clean and improve the extracted text
      final cleanedText = _cleanExtractedText(extractedText);
      print('🧹 [Tesseract OCR] Cleaned text: $cleanedText');

      // Detect language content
      _analyzeTextContent(cleanedText);

      // Clean up temporary processed image if created
      if (preprocessImage && processedImagePath != imagePath) {
        try {
          await File(processedImagePath).delete();
          print('🗑️ [Tesseract OCR] Cleaned up temporary processed image');
        } catch (e) {
          print('⚠️ [Tesseract OCR] Failed to delete temporary image: $e');
        }
      }

      return cleanedText;
    } catch (e) {
      print('❌ [Tesseract OCR] Error during text extraction: $e');
      return '';
    }
  }

  /// Extract text with confidence scores and detailed information
  Future<Map<String, dynamic>> extractTextWithConfidence(
    String imagePath, {
    String language = 'ara+eng',
    bool preprocessImage = true,
  }) async {
    try {
      print('🔍 [Tesseract OCR] Starting detailed text extraction...');

      final extractedText = await extractTextFromImage(
        imagePath,
        language: language,
        preprocessImage: preprocessImage,
      );

      // Calculate confidence based on text quality indicators
      final confidence = _calculateConfidence(extractedText);

      // Analyze text content
      final analysis = _analyzeTextContent(extractedText);

      return {
        'text': extractedText,
        'confidence': confidence,
        'language': analysis['detectedLanguage'],
        'hasArabic': analysis['hasArabic'],
        'hasEnglish': analysis['hasEnglish'],
        'hasNumbers': analysis['hasNumbers'],
        'hasCurrency': analysis['hasCurrency'],
        'textLength': extractedText.length,
        'engine': 'tesseract',
      };
    } catch (e) {
      print('❌ [Tesseract OCR] Error during detailed extraction: $e');
      return {
        'text': '',
        'confidence': 0.0,
        'language': 'unknown',
        'hasArabic': false,
        'hasEnglish': false,
        'hasNumbers': false,
        'hasCurrency': false,
        'textLength': 0,
        'engine': 'tesseract',
      };
    }
  }

  /// Preprocess image for better OCR results
  Future<String> _preprocessImage(String imagePath) async {
    try {
      print('🖼️ [Tesseract OCR] Starting image preprocessing...');

      final file = File(imagePath);
      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) {
        throw Exception('Failed to decode image');
      }

      print(
          '📐 [Tesseract OCR] Original image size: ${image.width}x${image.height}');

      // Resize image for optimal OCR performance
      img.Image resized = image;

      // Check if image is too small (common cause of OCR failure)
      if (image.width < 500 || image.height < 500) {
        // Upscale small images significantly for better OCR
        final scaleFactor = 500 / math.min(image.width, image.height);
        final newWidth = (image.width * scaleFactor).round();
        final newHeight = (image.height * scaleFactor).round();
        resized = img.copyResize(image, width: newWidth, height: newHeight);
        print(
            '📐 [Tesseract OCR] Upscaled small image from ${image.width}x${image.height} to ${resized.width}x${resized.height}');
      } else if (image.width > 2000 || image.height > 2000) {
        // Downscale very large images
        resized = img.copyResize(image, width: 2000, height: 2000);
        print(
            '📐 [Tesseract OCR] Downscaled large image to: ${resized.width}x${resized.height}');
      }

      // Convert to grayscale for better OCR
      final grayscale = img.grayscale(resized);
      print('🎨 [Tesseract OCR] Converted to grayscale');

      // Enhance contrast more aggressively for better text recognition
      final enhanced = img.contrast(grayscale, contrast: 1.5);
      print('✨ [Tesseract OCR] Enhanced contrast');

      // Apply brightness adjustment based on image analysis
      // For very bright images, reduce brightness significantly
      final brightnessAdjustment = _calculateOptimalBrightness(enhanced);
      final brightened =
          img.adjustColor(enhanced, brightness: brightnessAdjustment);
      print('💡 [Tesseract OCR] Adjusted brightness by: $brightnessAdjustment');

      // Apply sharpening filter for better text clarity
      final sharpened = img.convolution(
        brightened,
        filter: [0, -1, 0, -1, 5, -1, 0, -1, 0],
      );
      print('🔍 [Tesseract OCR] Applied sharpening filter');

      // Apply additional noise reduction
      final denoised = img.gaussianBlur(sharpened, radius: 1);
      print('🧹 [Tesseract OCR] Applied noise reduction');

      // Save processed image to temporary directory
      final tempDir = await getTemporaryDirectory();
      final processedPath =
          '${tempDir.path}/tesseract_processed_${DateTime.now().millisecondsSinceEpoch}.png';
      final processedFile = File(processedPath);
      await processedFile.writeAsBytes(img.encodePng(denoised));

      print('💾 [Tesseract OCR] Saved processed image to: $processedPath');

      return processedPath;
    } catch (e) {
      print('❌ [Tesseract OCR] Image preprocessing failed: $e');
      // If preprocessing fails, return original path
      return imagePath;
    }
  }

  /// Clean and improve extracted text
  String _cleanExtractedText(String text) {
    if (text.isEmpty) return text;

    print('🧹 [Tesseract OCR] Cleaning extracted text...');

    // Remove excessive whitespace
    text = text.replaceAll(RegExp(r'\s+'), ' ').trim();

    // Fix common OCR errors for Arabic text
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
    if (text.contains(RegExp(r'[\u0600-\u06FF]'))) {
      print('🔤 [Tesseract OCR] Applying Arabic character corrections...');
      for (final entry in arabicCorrections.entries) {
        correctedText = correctedText.replaceAll(entry.key, entry.value);
      }
    }

    // Remove common OCR artifacts and normalize characters
    correctedText = correctedText
        .replaceAll(
          RegExp(
              r'[^\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF\u0020-\u007E\u00A0-\u00FF]'),
          ' ',
        )
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    print('✅ [Tesseract OCR] Text cleaning completed');
    return correctedText;
  }

  /// Analyze text content to detect language and content type
  Map<String, dynamic> _analyzeTextContent(String text) {
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
      'hasArabic': hasArabic,
      'hasEnglish': hasEnglish,
      'hasNumbers': hasNumbers,
      'hasCurrency': hasCurrency,
      'detectedLanguage': detectedLanguage,
    };
  }

  /// Calculate confidence score based on text quality
  double _calculateConfidence(String text) {
    if (text.isEmpty) return 0.0;

    double confidence = 0.0;

    // Base confidence from text length
    if (text.length > 10) confidence += 0.2;
    if (text.length > 50) confidence += 0.2;
    if (text.length > 100) confidence += 0.1;

    // Content analysis
    final analysis = _analyzeTextContent(text);
    if (analysis['hasNumbers']) confidence += 0.2;
    if (analysis['hasCurrency']) confidence += 0.1;
    if (analysis['hasArabic'] || analysis['hasEnglish']) confidence += 0.2;

    // Check for reasonable character distribution
    final totalChars = text.replaceAll(RegExp(r'\s'), '').length;
    if (totalChars > 0) {
      final alphaNumericChars =
          RegExp(r'[\u0600-\u06FF\u0020-\u007E]').allMatches(text).length;
      final alphaNumericRatio = alphaNumericChars / totalChars;
      if (alphaNumericRatio > 0.7) confidence += 0.1;
    }

    return confidence.clamp(0.0, 1.0);
  }

  /// Check if image is suitable for OCR
  Future<bool> isImageSuitableForOCR(String imagePath) async {
    try {
      final file = File(imagePath);
      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) {
        print('❌ [Tesseract OCR] Failed to decode image');
        return false;
      }

      // Check image dimensions (should be at least 300x300 for good OCR)
      if (image.width < 300 || image.height < 300) {
        print(
            '❌ [Tesseract OCR] Image too small: ${image.width}x${image.height}');
        return false;
      }

      // Check file size (should be reasonable)
      final fileSize = await file.length();
      if (fileSize < 10000 || fileSize > 10000000) {
        print('❌ [Tesseract OCR] File size unsuitable: ${fileSize} bytes');
        return false; // 10KB to 10MB
      }

      print('✅ [Tesseract OCR] Image is suitable for OCR');
      return true;
    } catch (e) {
      print('❌ [Tesseract OCR] Error checking image suitability: $e');
      return false;
    }
  }

  /// Analyze image characteristics for debugging
  Future<Map<String, dynamic>> analyzeImage(String imagePath) async {
    try {
      final file = File(imagePath);
      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) {
        return {'error': 'Failed to decode image'};
      }

      // Calculate image statistics
      double totalBrightness = 0;
      int pixelCount = 0;
      for (int y = 0; y < image.height; y++) {
        for (int x = 0; x < image.width; x++) {
          final pixel = image.getPixel(x, y);
          final r = pixel.r;
          final g = pixel.g;
          final b = pixel.b;
          final brightness = (r + g + b) / 3.0;
          totalBrightness += brightness;
          pixelCount++;
        }
      }
      final averageBrightness = totalBrightness / pixelCount;

      // Calculate contrast (standard deviation of brightness)
      double variance = 0;
      for (int y = 0; y < image.height; y++) {
        for (int x = 0; x < image.width; x++) {
          final pixel = image.getPixel(x, y);
          final r = pixel.r;
          final g = pixel.g;
          final b = pixel.b;
          final brightness = (r + g + b) / 3.0;
          variance += (brightness - averageBrightness) *
              (brightness - averageBrightness);
        }
      }
      final contrast = variance / pixelCount;

      return {
        'width': image.width,
        'height': image.height,
        'fileSize': await file.length(),
        'averageBrightness': averageBrightness,
        'contrast': contrast,
        'isDark': averageBrightness < 100,
        'isBright': averageBrightness > 200,
        'isLowContrast': contrast < 1000,
        'isHighContrast': contrast > 10000,
        'aspectRatio': image.width / image.height,
        'totalPixels': pixelCount,
        'recommendations': _getImageRecommendations(
            averageBrightness, contrast, image.width, image.height),
      };
    } catch (e) {
      return {'error': 'Failed to analyze image: $e'};
    }
  }

  /// Get recommendations based on image analysis
  List<String> _getImageRecommendations(
      double brightness, double contrast, int width, int height) {
    List<String> recommendations = [];

    if (brightness < 100) {
      recommendations.add('Image is too dark - increase brightness');
    } else if (brightness > 200) {
      recommendations.add('Image is too bright - decrease brightness');
    }

    if (contrast < 1000) {
      recommendations.add('Image has low contrast - increase contrast');
    }

    if (width < 500 || height < 500) {
      recommendations.add('Image resolution is low - try higher resolution');
    }

    if (width / height < 0.5 || width / height > 2.0) {
      recommendations
          .add('Image aspect ratio is unusual - ensure text is horizontal');
    }

    if (recommendations.isEmpty) {
      recommendations.add('Image quality appears good for OCR');
    }

    return recommendations;
  }

  /// Calculate optimal brightness adjustment based on image characteristics
  double _calculateOptimalBrightness(img.Image image) {
    // Calculate average brightness
    double totalBrightness = 0;
    int pixelCount = 0;

    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        final r = pixel.r;
        final g = pixel.g;
        final b = pixel.b;
        final brightness = (r + g + b) / 3.0;
        totalBrightness += brightness;
        pixelCount++;
      }
    }

    final averageBrightness = totalBrightness / pixelCount;

    // Calculate brightness adjustment
    // Target brightness is around 128 (middle gray)
    if (averageBrightness > 200) {
      // Very bright image - reduce brightness significantly
      return -0.3;
    } else if (averageBrightness > 150) {
      // Bright image - reduce brightness moderately
      return -0.2;
    } else if (averageBrightness < 80) {
      // Dark image - increase brightness
      return 0.2;
    } else if (averageBrightness < 120) {
      // Slightly dark image - increase brightness slightly
      return 0.1;
    } else {
      // Good brightness - minimal adjustment
      return 0.0;
    }
  }

  /// Try alternative preprocessing approaches when standard preprocessing fails
  Future<String> _tryAlternativePreprocessing(
      String imagePath, String language) async {
    try {
      print(
          '🔄 [Tesseract OCR] Trying alternative preprocessing approaches...');

      final file = File(imagePath);
      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) {
        return '';
      }

      // Approach 1: Upscale and aggressive preprocessing for small images
      print(
          '🔄 [Tesseract OCR] Trying upscaling with aggressive preprocessing...');
      img.Image processedImage = image;

      // Upscale if image is small
      if (image.width < 500 || image.height < 500) {
        final scaleFactor = 1000 / math.min(image.width, image.height);
        final newWidth = (image.width * scaleFactor).round();
        final newHeight = (image.height * scaleFactor).round();
        processedImage =
            img.copyResize(image, width: newWidth, height: newHeight);
        print(
            '📐 [Tesseract OCR] Upscaled to ${processedImage.width}x${processedImage.height}');
      }

      final aggressiveContrast = img.contrast(processedImage, contrast: 2.5);
      final aggressiveBrightness = img.adjustColor(aggressiveContrast,
          brightness: -0.3); // Reduce brightness for bright images
      final aggressiveGrayscale = img.grayscale(aggressiveBrightness);

      final aggressiveResult =
          await _performOcrOnProcessedImage(aggressiveGrayscale, language);
      if (aggressiveResult.isNotEmpty) {
        print('✅ [Tesseract OCR] Aggressive preprocessing succeeded');
        return aggressiveResult;
      }

      // Approach 2: Invert colors (for dark text on light background)
      print('🔄 [Tesseract OCR] Trying color inversion...');
      final inverted = img.invert(image);
      final invertedGrayscale = img.grayscale(inverted);

      final invertedResult =
          await _performOcrOnProcessedImage(invertedGrayscale, language);
      if (invertedResult.isNotEmpty) {
        print('✅ [Tesseract OCR] Color inversion succeeded');
        return invertedResult;
      }

      // Approach 3: Edge detection approach
      print('🔄 [Tesseract OCR] Trying edge detection approach...');
      final grayscale = img.grayscale(image);
      final edges = img
          .convolution(grayscale, filter: [-1, -1, -1, -1, 8, -1, -1, -1, -1]);

      final edgeResult = await _performOcrOnProcessedImage(edges, language);
      if (edgeResult.isNotEmpty) {
        print('✅ [Tesseract OCR] Edge detection succeeded');
        return edgeResult;
      }

      // Approach 4: Simple grayscale without additional processing
      print('🔄 [Tesseract OCR] Trying simple grayscale...');
      final simpleGrayscale = img.grayscale(image);

      final simpleResult =
          await _performOcrOnProcessedImage(simpleGrayscale, language);
      if (simpleResult.isNotEmpty) {
        print('✅ [Tesseract OCR] Simple grayscale succeeded');
        return simpleResult;
      }

      // Approach 5: Try OCR on original image without any preprocessing
      print(
          '🔄 [Tesseract OCR] Trying original image without preprocessing...');
      final originalResult = await _performOcrOnProcessedImage(image, language);
      if (originalResult.isNotEmpty) {
        print('✅ [Tesseract OCR] Original image OCR succeeded');
        return originalResult;
      }

      print(
          '❌ [Tesseract OCR] All alternative preprocessing approaches failed');
      return '';
    } catch (e) {
      print('❌ [Tesseract OCR] Alternative preprocessing failed: $e');
      return '';
    }
  }

  /// Perform OCR on a processed image
  Future<String> _performOcrOnProcessedImage(
      img.Image processedImage, String language) async {
    try {
      // Save processed image temporarily
      final tempDir = await getTemporaryDirectory();
      final tempPath =
          '${tempDir.path}/alt_processed_${DateTime.now().millisecondsSinceEpoch}.png';
      final tempFile = File(tempPath);
      await tempFile.writeAsBytes(img.encodePng(processedImage));

      // Perform OCR with different page segmentation modes
      String result = '';

      // Try different page segmentation modes
      final pageSegModes = ['1', '3', '6', '8', '13'];

      for (final mode in pageSegModes) {
        try {
          print('🔧 [Tesseract OCR] Trying page segmentation mode: $mode');
          result = await FlutterTesseractOcr.extractText(
            tempPath,
            language: language,
            args: {
              "preserve_interword_spaces": "1",
              "tessedit_pageseg_mode": mode,
              "tessedit_ocr_engine_mode": "1",
            },
          );

          print(
              '🔧 [Tesseract OCR] Mode $mode result: "$result" (length: ${result.length})');

          if (result.trim().isNotEmpty) {
            print('✅ [Tesseract OCR] Page segmentation mode $mode succeeded');
            break;
          }
        } catch (e) {
          print('⚠️ [Tesseract OCR] Page segmentation mode $mode failed: $e');
        }
      }

      // Clean up
      try {
        await tempFile.delete();
      } catch (e) {
        // Ignore cleanup errors
      }

      return result.trim();
    } catch (e) {
      print('❌ [Tesseract OCR] OCR on processed image failed: $e');
      return '';
    }
  }

  /// Get supported languages
  List<String> getSupportedLanguages() {
    return ['ara', 'eng', 'ara+eng'];
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
    final analysis = _analyzeTextContent(text);
    final confidence = _calculateConfidence(text);

    return {
      'qualityScore': confidence,
      'hasArabic': analysis['hasArabic'],
      'hasEnglish': analysis['hasEnglish'],
      'hasNumbers': analysis['hasNumbers'],
      'hasCurrency': analysis['hasCurrency'],
      'detectedLanguage': analysis['detectedLanguage'],
      'textLength': text.length,
      'engine': 'tesseract',
    };
  }
}
