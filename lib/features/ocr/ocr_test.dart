import 'package:safe/features/ocr/ocr_manager.dart';
import 'package:safe/services/ocr_service.dart';

/// Simple test class to verify OCR functionality
class OcrTest {
  static Future<void> testOcrFunctionality() async {
    print('🧪 [OCR Test] Starting OCR functionality test...');

    try {
      // Test 1: Check if OCR Manager can be instantiated
      final ocrManager = OcrManager();
      print('✅ [OCR Test] OCR Manager instantiated successfully');

      // Test 2: Check if OCR Service can be instantiated
      final ocrService = OCRService();
      print('✅ [OCR Test] OCR Service instantiated successfully');

      // Test OCR Service methods
      final ocrServiceLanguages = ocrService.getSupportedLanguages();
      print(
          '✅ [OCR Test] OCR Service supported languages: $ocrServiceLanguages');

      // Test 3: Check supported languages
      final supportedLanguages = ocrManager.getSupportedLanguages();
      print('✅ [OCR Test] Supported languages: $supportedLanguages');

      // Test 4: Check current engine
      final currentEngine = ocrManager.currentEngine;
      print('✅ [OCR Test] Current engine: $currentEngine');

      // Test 5: Test engine switching
      ocrManager.setEngine(OcrEngine.mlkit);
      print('✅ [OCR Test] Switched to ML Kit engine');

      ocrManager.setEngine(OcrEngine.tesseract);
      print('✅ [OCR Test] Switched back to Tesseract engine');

      print('🎉 [OCR Test] All basic tests passed!');
    } catch (e) {
      print('❌ [OCR Test] Test failed: $e');
    }
  }

  /// Test OCR with a sample image (if available)
  static Future<void> testOcrWithImage(String imagePath) async {
    print('🧪 [OCR Test] Testing OCR with image: $imagePath');

    try {
      final ocrService = OCRService();

      // Test image suitability
      final isSuitable = await ocrService.isImageSuitableForOCR(imagePath);
      print('📸 [OCR Test] Image suitable for OCR: $isSuitable');

      if (isSuitable) {
        // Test text extraction
        final extractedText = await ocrService.extractTextFromImage(imagePath);
        print('📝 [OCR Test] Extracted text: $extractedText');

        // Test detailed extraction
        final detailedResult =
            await ocrService.extractTextWithConfidence(imagePath);
        print('📊 [OCR Test] Detailed result: $detailedResult');

        if (extractedText.isNotEmpty) {
          print('✅ [OCR Test] OCR test with image successful!');
        } else {
          print('⚠️ [OCR Test] No text extracted from image');
        }
      } else {
        print('⚠️ [OCR Test] Image not suitable for OCR');
      }
    } catch (e) {
      print('❌ [OCR Test] OCR test with image failed: $e');
    }
  }
}
