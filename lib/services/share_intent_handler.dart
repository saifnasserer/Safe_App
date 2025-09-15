import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:safe/models/receipt_data.dart';
import 'package:safe/services/ocr_service.dart';
import 'package:safe/services/receipt_parser.dart';
import 'package:safe/services/navigation_service.dart';
import 'package:safe/Screens/receipt_screen/receipt_preview_screen.dart';
import 'package:safe/Constants.dart';
import 'package:provider/provider.dart';
import 'package:safe/providers/receipt_provider.dart';

/// Optimized share intent handler that bypasses heavy app initialization
class ShareIntentHandler {
  static final ShareIntentHandler _instance = ShareIntentHandler._internal();
  factory ShareIntentHandler() => _instance;
  ShareIntentHandler._internal();

  final OCRService _ocrService = OCRService();
  StreamSubscription? _intentDataStreamSubscription;
  StreamSubscription? _intentDataStreamSubscription2;

  bool _isProcessing = false;
  int _retryCount = 0;
  static const int _maxRetries = 3;

  /// Initialize share intent handling with immediate processing
  void initialize() {
    // Handle sharing coming from outside the app while the app is already started
    _intentDataStreamSubscription2 =
        ReceiveSharingIntent.instance.getMediaStream().listen(
      (List<SharedMediaFile> sharedMedia) {
        if (sharedMedia.isNotEmpty && !_isProcessing) {
          _handleSharedMedia(sharedMedia);
        }
      },
      onError: (err) {
        print('Error receiving shared media: $err');
        _showErrorAndNavigateHome('خطأ في استقبال الصورة: $err');
      },
    );

    // Handle sharing coming from outside the app while the app was closed
    ReceiveSharingIntent.instance
        .getInitialMedia()
        .then((List<SharedMediaFile> sharedMedia) {
      if (sharedMedia.isNotEmpty && !_isProcessing) {
        _handleSharedMedia(sharedMedia);
      }
    });
  }

  /// Handle shared media (images and text)
  Future<void> _handleSharedMedia(List<SharedMediaFile> sharedMedia) async {
    if (_isProcessing) return;

    _isProcessing = true;
    _retryCount = 0;

    try {
      for (final mediaFile in sharedMedia) {
        if (mediaFile.type == SharedMediaType.image) {
          // Show immediate loading screen
          _showProcessingScreen();

          // Try to detect source app from file path or metadata
          final sourceApp = _detectSourceApp(mediaFile);
          await _processSharedImage(mediaFile.path, sourceApp: sourceApp);
        } else if (mediaFile.type == SharedMediaType.text) {
          print('Received shared text: ${mediaFile.path}');
          // Handle shared text if needed
        }
      }
    } catch (e) {
      print('Error processing shared media: $e');
      _showErrorAndNavigateHome('خطأ في معالجة الصورة: $e');
    } finally {
      _isProcessing = false;
    }
  }

  /// Show processing screen immediately
  void _showProcessingScreen() {
    final context = NavigationService().navigatorKey.currentContext;
    if (context != null) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => _ProcessingScreen(),
      );
    }
  }

  /// Hide processing screen
  void _hideProcessingScreen() {
    final context = NavigationService().navigatorKey.currentContext;
    if (context != null) {
      Navigator.of(context).pop();
    }
  }

  /// Process a shared image with retry logic
  Future<void> _processSharedImage(String imagePath,
      {String? sourceApp}) async {
    try {
      // Extract text using OCR with timeout
      final extractedText = await _ocrService
          .extractTextFromImage(imagePath)
          .timeout(const Duration(seconds: 30));

      if (extractedText.isEmpty) {
        print('No text extracted from image');

        // Create a receipt with error message for user feedback
        final errorReceipt = ReceiptData(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          imagePath: imagePath,
          extractedText: '',
          title: 'لم يتم استخراج نص',
          amount: null,
          date: DateTime.now(),
          currency: 'ج.م',
          merchant: null,
          confidenceScore: 0.0,
          processedAt: DateTime.now(),
          isProcessed: false,
          errorMessage: 'لم يتم العثور على نص في الصورة',
          sourceApp: sourceApp,
        );

        // Save image and add to provider
        final savedImagePath = await _saveImageToAppDirectory(imagePath);
        final updatedErrorReceipt =
            errorReceipt.copyWith(imagePath: savedImagePath);

        // Add receipt to provider and navigate to preview
        _addReceiptAndNavigate(updatedErrorReceipt);
        return;
      }

      // Clean the extracted text
      final cleanedText = ReceiptParser.cleanText(extractedText);
      print('Extracted text for processing: $cleanedText');

      // Assess OCR quality
      final qualityAssessment = _ocrService.assessOCRQuality(cleanedText);
      print('OCR Quality Assessment: $qualityAssessment');

      if (qualityAssessment['hasArabic'] == true) {
        print(
            'Arabic text detected in receipt - may need cloud OCR for better results');
      }

      // Parse the receipt text using Gemini API with fallback
      final receiptData = await ReceiptParser.parseReceiptText(
          cleanedText, imagePath,
          sourceApp: sourceApp);

      // Save the processed image to app directory
      final savedImagePath = await _saveImageToAppDirectory(imagePath);
      final updatedReceiptData =
          receiptData.copyWith(imagePath: savedImagePath);

      // Add receipt to provider and navigate to preview
      _addReceiptAndNavigate(updatedReceiptData);
    } catch (e) {
      print('Error processing shared image: $e');

      // Retry logic
      if (_retryCount < _maxRetries) {
        _retryCount++;
        print('Retrying processing (attempt $_retryCount/$_maxRetries)');
        await Future.delayed(
            Duration(seconds: _retryCount * 2)); // Exponential backoff
        await _processSharedImage(imagePath, sourceApp: sourceApp);
      } else {
        // Max retries reached, show error
        _hideProcessingScreen();
        _showErrorAndNavigateHome(
            'فشل في معالجة الصورة بعد $_maxRetries محاولات: $e');
      }
    }
  }

  /// Add receipt to provider and navigate to preview screen
  void _addReceiptAndNavigate(ReceiptData receiptData) async {
    final context = NavigationService().navigatorKey.currentContext;
    if (context != null) {
      try {
        // Add receipt to provider
        final receiptProvider =
            Provider.of<ReceiptProvider>(context, listen: false);
        await receiptProvider.addReceipt(receiptData);

        // Hide processing screen and navigate to preview
        _hideProcessingScreen();

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) =>
                ReceiptPreviewScreen(receiptData: receiptData),
          ),
        );
      } catch (e) {
        print('Error adding receipt to provider: $e');
        _hideProcessingScreen();
        _showErrorAndNavigateHome('فشل في حفظ الإيصال: $e');
      }
    }
  }

  /// Show error and navigate to home
  void _showErrorAndNavigateHome(String errorMessage) {
    final context = NavigationService().navigatorKey.currentContext;
    if (context != null) {
      _hideProcessingScreen();

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text(
            'خطأ في المعالجة',
            style: TextStyle(fontFamily: Constants.defaultFontFamily),
          ),
          content: Text(
            errorMessage,
            style: const TextStyle(fontFamily: Constants.secondaryFontFamily),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacementNamed('/');
              },
              child: const Text('العودة للرئيسية'),
            ),
          ],
        ),
      );
    }
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

  /// Save image to app directory
  Future<String> _saveImageToAppDirectory(String originalPath) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final receiptsDir = Directory(path.join(appDir.path, 'receipts'));

      if (!await receiptsDir.exists()) {
        await receiptsDir.create(recursive: true);
      }

      final fileName = 'receipt_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final newPath = path.join(receiptsDir.path, fileName);

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
    _intentDataStreamSubscription?.cancel();
    _intentDataStreamSubscription2?.cancel();
    _ocrService.dispose();
  }
}

/// Processing screen widget
class _ProcessingScreen extends StatefulWidget {
  @override
  _ProcessingScreenState createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<_ProcessingScreen> {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        contentPadding: EdgeInsets.zero,
        content: Container(
          padding: EdgeInsets.all(32),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Simple circular progress indicator
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Constants.getPrimaryColor(context),
                ),
                strokeWidth: 3,
              ),
              SizedBox(height: 24),
              // Simple processing text
              Text(
                'جاري معالجة الصورة...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[800],
                  fontFamily: Constants.defaultFontFamily,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
