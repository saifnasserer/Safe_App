import 'package:safe/features/ocr/ocr_manager.dart';
import 'package:safe/services/ocr_service.dart';

/// Example usage of the new OCR system with Tesseract and ML Kit engines
class OcrExampleUsage {
  final OcrManager _ocrManager = OcrManager();
  final OCRService _ocrService = OCRService();

  /// Example 1: Basic text extraction with Tesseract (default)
  Future<void> basicTextExtraction(String imagePath) async {
    print('=== Example 1: Basic Text Extraction ===');

    // Extract text using the default Tesseract engine
    final extractedText = await _ocrManager.extractTextFromImage(imagePath);

    print('📝 Extracted Text: $extractedText');
    print('📊 Text Length: ${extractedText.length}');
  }

  /// Example 2: Text extraction with specific language
  Future<void> languageSpecificExtraction(String imagePath) async {
    print('=== Example 2: Language Specific Extraction ===');

    // Extract Arabic text only
    final arabicText = await _ocrManager.extractTextFromImage(
      imagePath,
      language: 'ara',
    );
    print('🔤 Arabic Text: $arabicText');

    // Extract English text only
    final englishText = await _ocrManager.extractTextFromImage(
      imagePath,
      language: 'eng',
    );
    print('🔤 English Text: $englishText');

    // Extract both Arabic and English
    final mixedText = await _ocrManager.extractTextFromImage(
      imagePath,
      language: 'ara+eng',
    );
    print('🔤 Mixed Text: $mixedText');
  }

  /// Example 3: Detailed extraction with confidence scores
  Future<void> detailedExtractionWithConfidence(String imagePath) async {
    print('=== Example 3: Detailed Extraction with Confidence ===');

    final result = await _ocrManager.extractTextWithConfidence(imagePath);

    print('📝 Text: ${result['text']}');
    print('📊 Confidence: ${result['confidence']}');
    print('🌐 Language: ${result['language']}');
    print('🔤 Has Arabic: ${result['hasArabic']}');
    print('🔤 Has English: ${result['hasEnglish']}');
    print('🔢 Has Numbers: ${result['hasNumbers']}');
    print('💰 Has Currency: ${result['hasCurrency']}');
    print('⚙️ Engine Used: ${result['engine']}');
  }

  /// Example 4: Engine switching
  Future<void> engineSwitching(String imagePath) async {
    print('=== Example 4: Engine Switching ===');

    // Use Tesseract engine
    _ocrManager.setEngine(OcrEngine.tesseract);
    print('🔄 Switched to Tesseract engine');

    final tesseractResult = await _ocrManager.extractTextFromImage(imagePath);
    print('📝 Tesseract Result: $tesseractResult');

    // Switch to ML Kit engine
    _ocrManager.setEngine(OcrEngine.mlkit);
    print('🔄 Switched to ML Kit engine');

    final mlkitResult = await _ocrManager.extractTextFromImage(imagePath);
    print('📝 ML Kit Result: $mlkitResult');
  }

  /// Example 5: Using the integrated OCR Service
  Future<void> integratedOcrService(String imagePath) async {
    print('=== Example 5: Integrated OCR Service ===');

    // The OCR Service now uses the new OCR Manager internally
    final extractedText = await _ocrService.extractTextFromImage(imagePath);
    print('📝 OCR Service Result: $extractedText');

    // Get detailed information
    final detailedResult =
        await _ocrService.extractTextWithConfidence(imagePath);
    print('📊 OCR Service Confidence: ${detailedResult['confidence']}');
    print('⚙️ OCR Service Engine: ${detailedResult['engine']}');

    // Switch engine through the service
    _ocrService.setOcrEngine(OcrEngine.mlkit);
    print('🔄 Switched OCR Service engine to ML Kit');

    final mlkitResult = await _ocrService.extractTextFromImage(imagePath);
    print('📝 OCR Service ML Kit Result: $mlkitResult');
  }

  /// Example 6: Image suitability check
  Future<void> imageSuitabilityCheck(String imagePath) async {
    print('=== Example 6: Image Suitability Check ===');

    final isSuitable = await _ocrManager.isImageSuitableForOCR(imagePath);
    print('✅ Image suitable for OCR: $isSuitable');

    if (!isSuitable) {
      print('⚠️ Image may not produce good OCR results');
      print('💡 Consider:');
      print('   - Image should be at least 300x300 pixels');
      print('   - File size should be between 10KB and 10MB');
      print('   - Image should be clear and well-lit');
    }
  }

  /// Example 7: OCR quality assessment
  Future<void> ocrQualityAssessment(String imagePath) async {
    print('=== Example 7: OCR Quality Assessment ===');

    final extractedText = await _ocrManager.extractTextFromImage(imagePath);
    final qualityAssessment = _ocrManager.assessOCRQuality(extractedText);

    print('📝 Extracted Text: $extractedText');
    print('📊 Quality Score: ${qualityAssessment['qualityScore']}');
    print('🔤 Has Arabic: ${qualityAssessment['hasArabic']}');
    print('🔤 Has English: ${qualityAssessment['hasEnglish']}');
    print('🔢 Has Numbers: ${qualityAssessment['hasNumbers']}');
    print('💰 Has Currency: ${qualityAssessment['hasCurrency']}');
    print('📏 Text Length: ${qualityAssessment['textLength']}');
    print('⚙️ Engine: ${qualityAssessment['engine']}');
  }

  /// Example 8: Receipt processing workflow
  Future<void> receiptProcessingWorkflow(String imagePath) async {
    print('=== Example 8: Receipt Processing Workflow ===');

    // Step 1: Check image suitability
    final isSuitable = await _ocrManager.isImageSuitableForOCR(imagePath);
    if (!isSuitable) {
      print('❌ Image not suitable for OCR processing');
      return;
    }

    // Step 2: Extract text with Tesseract (better for Arabic)
    print('🔍 Extracting text with Tesseract...');
    final tesseractResult = await _ocrManager.extractTextWithConfidence(
      imagePath,
      language: 'ara+eng',
    );

    print('📝 Tesseract extracted text: ${tesseractResult['text']}');
    print('📊 Tesseract confidence: ${tesseractResult['confidence']}');

    // Step 3: If confidence is low, try ML Kit as comparison
    if (tesseractResult['confidence'] < 0.7) {
      print('⚠️ Low confidence with Tesseract, trying ML Kit...');

      _ocrManager.setEngine(OcrEngine.mlkit);
      final mlkitResult =
          await _ocrManager.extractTextWithConfidence(imagePath);

      print('📝 ML Kit extracted text: ${mlkitResult['text']}');
      print('📊 ML Kit confidence: ${mlkitResult['confidence']}');

      // Choose the result with higher confidence
      if (mlkitResult['confidence'] > tesseractResult['confidence']) {
        print('✅ Using ML Kit result (higher confidence)');
        _ocrManager.setEngine(OcrEngine.mlkit);
      } else {
        print('✅ Using Tesseract result (higher confidence)');
        _ocrManager.setEngine(OcrEngine.tesseract);
      }
    }

    // Step 4: Assess final quality
    final finalText = await _ocrManager.extractTextFromImage(imagePath);
    final qualityAssessment = _ocrManager.assessOCRQuality(finalText);

    print('🎯 Final Result:');
    print('   Text: $finalText');
    print('   Quality Score: ${qualityAssessment['qualityScore']}');
    print('   Engine: ${_ocrManager.currentEngine}');
  }

  /// Example 9: Batch processing multiple images
  Future<void> batchProcessing(List<String> imagePaths) async {
    print('=== Example 9: Batch Processing ===');

    for (int i = 0; i < imagePaths.length; i++) {
      print('📸 Processing image ${i + 1}/${imagePaths.length}');

      try {
        final result =
            await _ocrManager.extractTextWithConfidence(imagePaths[i]);
        print(
            '   ✅ Success: ${result['text'].substring(0, result['text'].length > 50 ? 50 : result['text'].length)}...');
        print('   📊 Confidence: ${result['confidence']}');
        print('   ⚙️ Engine: ${result['engine']}');
      } catch (e) {
        print('   ❌ Failed: $e');
      }

      print(''); // Empty line for readability
    }
  }

  /// Example 10: Performance comparison between engines
  Future<void> performanceComparison(String imagePath) async {
    print('=== Example 10: Performance Comparison ===');

    // Test Tesseract performance
    print('🔍 Testing Tesseract performance...');
    final tesseractStart = DateTime.now();
    _ocrManager.setEngine(OcrEngine.tesseract);
    final tesseractResult = await _ocrManager.extractTextFromImage(imagePath);
    final tesseractDuration = DateTime.now().difference(tesseractStart);

    print(
        '📝 Tesseract Result: ${tesseractResult.substring(0, tesseractResult.length > 50 ? 50 : tesseractResult.length)}...');
    print('⏱️ Tesseract Duration: ${tesseractDuration.inMilliseconds}ms');

    // Test ML Kit performance
    print('🔍 Testing ML Kit performance...');
    final mlkitStart = DateTime.now();
    _ocrManager.setEngine(OcrEngine.mlkit);
    final mlkitResult = await _ocrManager.extractTextFromImage(imagePath);
    final mlkitDuration = DateTime.now().difference(mlkitStart);

    print(
        '📝 ML Kit Result: ${mlkitResult.substring(0, mlkitResult.length > 50 ? 50 : mlkitResult.length)}...');
    print('⏱️ ML Kit Duration: ${mlkitDuration.inMilliseconds}ms');

    // Compare results
    print('📊 Performance Summary:');
    print('   Tesseract: ${tesseractDuration.inMilliseconds}ms');
    print('   ML Kit: ${mlkitDuration.inMilliseconds}ms');
    print(
        '   Winner: ${tesseractDuration < mlkitDuration ? 'Tesseract' : 'ML Kit'}');
  }
}

/// Console output examples for debugging
void printOcrDebugOutput() {
  print('''
🔍 [Tesseract OCR] Starting text extraction...
📁 [Tesseract OCR] Image path: /path/to/image.jpg
🌐 [Tesseract OCR] Language: ara+eng
🖼️ [Tesseract OCR] Preprocessing enabled: true
🖼️ [Tesseract OCR] Starting image preprocessing...
📐 [Tesseract OCR] Original image size: 1920x1080
📐 [Tesseract OCR] Resized image to: 1920x1080
🎨 [Tesseract OCR] Converted to grayscale
✨ [Tesseract OCR] Enhanced contrast
🔍 [Tesseract OCR] Applied sharpening filter
💾 [Tesseract OCR] Saved processed image to: /tmp/tesseract_processed_1234567890.png
✅ [Tesseract OCR] Image preprocessing completed
📝 [Tesseract OCR] Raw extracted text length: 156
📝 [Tesseract OCR] Raw extracted text: متجر الأمل - فاتورة رقم 12345 - المجموع: 150.50 ج.م
🧹 [Tesseract OCR] Cleaning extracted text...
🔤 [Tesseract OCR] Applying Arabic character corrections...
✅ [Tesseract OCR] Text cleaning completed
🧹 [Tesseract OCR] Cleaned text: متجر الأمل - فاتورة رقم 12345 - المجموع: 150.50 ج.م
🔤 [Tesseract OCR] Arabic text detected in OCR result
🗑️ [Tesseract OCR] Cleaned up temporary processed image
✅ [Tesseract OCR] Text extraction completed successfully
''');
}
