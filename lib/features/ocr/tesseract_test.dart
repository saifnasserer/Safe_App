import 'dart:io';
import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';

/// Simple test to verify Tesseract is working
class TesseractTest {
  static Future<void> testBasicOcr() async {
    print('🧪 [Tesseract Test] Starting basic OCR test...');

    try {
      // Test with English only first
      print('🧪 [Tesseract Test] Testing English OCR...');
      final englishResult = await FlutterTesseractOcr.extractText(
        'test_image_path', // This will fail but we want to see the error
        language: 'eng',
        args: {
          "tessedit_pageseg_mode": "1",
          "tessedit_ocr_engine_mode": "1",
        },
      );
      print('🧪 [Tesseract Test] English result: "$englishResult"');
    } catch (e) {
      print('🧪 [Tesseract Test] English test error: $e');
    }

    try {
      // Test with Arabic only
      print('🧪 [Tesseract Test] Testing Arabic OCR...');
      final arabicResult = await FlutterTesseractOcr.extractText(
        'test_image_path', // This will fail but we want to see the error
        language: 'ara',
        args: {
          "tessedit_pageseg_mode": "1",
          "tessedit_ocr_engine_mode": "1",
        },
      );
      print('🧪 [Tesseract Test] Arabic result: "$arabicResult"');
    } catch (e) {
      print('🧪 [Tesseract Test] Arabic test error: $e');
    }

    try {
      // Test with combined languages
      print('🧪 [Tesseract Test] Testing combined languages...');
      final combinedResult = await FlutterTesseractOcr.extractText(
        'test_image_path', // This will fail but we want to see the error
        language: 'ara+eng',
        args: {
          "tessedit_pageseg_mode": "1",
          "tessedit_ocr_engine_mode": "1",
        },
      );
      print('🧪 [Tesseract Test] Combined result: "$combinedResult"');
    } catch (e) {
      print('🧪 [Tesseract Test] Combined test error: $e');
    }
  }
}
