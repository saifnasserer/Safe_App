import 'dart:async';
import 'dart:io';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:path_provider/path_provider.dart';
import 'package:safe/models/receipt_data.dart';
import 'package:safe/services/ocr_service.dart';
import 'package:safe/services/receipt_parser.dart';
import 'package:safe/services/gemini_service.dart';

/// Lightweight service for handling share intents without full app initialization
class ShareIntentService {
  static final ShareIntentService _instance = ShareIntentService._internal();
  factory ShareIntentService() => _instance;
  ShareIntentService._internal();

  final OCRService _ocrService = OCRService();
  final GeminiService _geminiService = GeminiService();

  /// Check if app was launched via share intent
  static Future<bool> isShareIntentLaunch() async {
    try {
      final sharedMedia = await ReceiveSharingIntent.instance.getInitialMedia();
      return sharedMedia.isNotEmpty;
    } catch (e) {
      print('Error checking share intent: $e');
      return false;
    }
  }

  /// Get shared media from intent
  static Future<List<SharedMediaFile>> getSharedMedia() async {
    try {
      return await ReceiveSharingIntent.instance.getInitialMedia();
    } catch (e) {
      print('Error getting shared media: $e');
      return [];
    }
  }

  /// Process shared image with minimal dependencies
  Future<ReceiptData?> processSharedImage(SharedMediaFile imageFile) async {
    try {
      // Save image to app directory
      final savedImagePath = await _saveImageToAppDirectory(imageFile.path);
      
      // Extract text using OCR
      final extractedText = await _ocrService.extractTextFromImage(savedImagePath);
      
      if (extractedText.isEmpty) {
        return _createErrorReceipt(
          savedImagePath,
          'لم يتم العثور على نص في الصورة',
          'لم يتم استخراج نص',
        );
      }

      // Clean the extracted text
      final cleanedText = ReceiptParser.cleanText(extractedText);

      // Validate if it looks like a receipt
      if (!ReceiptParser.isValidReceipt(cleanedText)) {
        return _createErrorReceipt(
          savedImagePath,
          'لا يبدو هذا النص كإيصال صالح',
          'إيصال غير صالح',
          extractedText: cleanedText,
        );
      }

      // Detect source app
      final sourceApp = _detectSourceApp(imageFile);

      // Process with AI (with fallback)
      return await _processReceiptWithAI(cleanedText, savedImagePath, sourceApp);

    } catch (e) {
      print('Error processing shared image: $e');
      return _createErrorReceipt(
        imageFile.path,
        'حدث خطأ أثناء معالجة الصورة: $e',
        'خطأ في المعالجة',
      );
    }
  }

  /// Process receipt with AI and fallback
  Future<ReceiptData?> _processReceiptWithAI(String text, String imagePath, String? sourceApp) async {
    try {
      // Try Gemini API first
      final geminiResult = await _geminiService.analyzeReceiptTextWithCache(text);
      
      if (geminiResult.isSuccess && 
          geminiResult.analysis != null && 
          geminiResult.analysis!.confidence > 0.6) {
        
        // Create receipt from Gemini analysis
        final analysis = geminiResult.analysis!;
        String title = analysis.title ?? _generateTitle(analysis.merchant, analysis.totalAmount);
        
        return ReceiptData(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          imagePath: imagePath,
          extractedText: text,
          title: title,
          amount: analysis.totalAmount,
          date: analysis.date != null ? DateTime.tryParse(analysis.date!) : DateTime.now(),
          currency: analysis.currency,
          merchant: analysis.merchant,
          confidenceScore: analysis.confidence,
          processedAt: DateTime.now(),
          isProcessed: true,
          sourceApp: 'AI_PROCESSED', // Mark as AI processed
        );
      } else {
        // Fall back to regex parsing
        return await ReceiptParser.parseReceiptText(text, imagePath, sourceApp: sourceApp);
      }
    } catch (e) {
      print('Error in AI processing: $e');
      // Fall back to regex parsing
      return await ReceiptParser.parseReceiptText(text, imagePath, sourceApp: sourceApp);
    }
  }

  /// Create error receipt for user feedback
  ReceiptData _createErrorReceipt(String imagePath, String errorMessage, String title, {String? extractedText}) {
    return ReceiptData(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      imagePath: imagePath,
      extractedText: extractedText ?? '',
      title: title,
      amount: null,
      date: DateTime.now(),
      currency: 'ج.م',
      merchant: null,
      confidenceScore: 0.0,
      processedAt: DateTime.now(),
      isProcessed: false,
      errorMessage: errorMessage,
      sourceApp: null, // No source app for error receipts
    );
  }

  /// Detect source app from media file metadata
  String? _detectSourceApp(SharedMediaFile mediaFile) {
    final path = mediaFile.path.toLowerCase();
    
    if (path.contains('instagram')) return 'com.instagram.android';
    if (path.contains('whatsapp')) return 'com.whatsapp';
    if (path.contains('facebook')) return 'com.facebook.katana';
    if (path.contains('messenger')) return 'com.facebook.orca';
    if (path.contains('twitter')) return 'com.twitter.android';
    if (path.contains('snapchat')) return 'com.snapchat.android';
    if (path.contains('camera')) return 'com.android.camera2';
    if (path.contains('gallery')) return 'com.android.gallery3d';
    if (path.contains('photos')) return 'com.google.android.apps.photos';
    
    return null;
  }

  /// Generate title from merchant and amount
  String _generateTitle(String? merchant, double? amount) {
    if (merchant != null && merchant.isNotEmpty) {
      return merchant;
    } else if (amount != null) {
      return 'مصروف ${amount.toStringAsFixed(0)} ج.م';
    } else {
      return 'مصروف جديد';
    }
  }

  /// Save image to app directory
  Future<String> _saveImageToAppDirectory(String originalPath) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final receiptsDir = Directory('${appDir.path}/receipts');

      if (!await receiptsDir.exists()) {
        await receiptsDir.create(recursive: true);
      }

      final fileName = 'receipt_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final newPath = '${receiptsDir.path}/$fileName';

      final originalFile = File(originalPath);
      await originalFile.copy(newPath);

      return newPath;
    } catch (e) {
      print('Error saving image: $e');
      return originalPath;
    }
  }

  /// Dispose resources
  void dispose() {
    _ocrService.dispose();
  }
}
