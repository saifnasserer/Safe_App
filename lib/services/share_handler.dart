import 'dart:async';
import 'dart:io';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:safe/models/receipt_data.dart';
import 'package:safe/services/ocr_service.dart';
import 'package:safe/services/receipt_parser.dart';
import 'package:safe/services/navigation_service.dart';
import 'package:safe/providers/receipt_provider.dart';

class ShareHandler {
  static final ShareHandler _instance = ShareHandler._internal();
  factory ShareHandler() => _instance;
  ShareHandler._internal();

  final OCRService _ocrService = OCRService();
  StreamSubscription? _intentDataStreamSubscription;
  StreamSubscription? _intentDataStreamSubscription2;

  // ReceiptProvider instance for processing
  ReceiptProvider? _receiptProvider;

  /// Set ReceiptProvider for processing shared images
  void setReceiptProvider(ReceiptProvider receiptProvider) {
    _receiptProvider = receiptProvider;
  }

  /// Initialize share intent handling
  void initialize() {
    // Handle sharing coming from outside the app while the app is already started
    _intentDataStreamSubscription2 =
        ReceiveSharingIntent.instance.getMediaStream().listen(
      (List<SharedMediaFile> sharedMedia) {
        if (sharedMedia.isNotEmpty) {
          _handleSharedMedia(sharedMedia);
        }
      },
      onError: (err) {
        print('Error receiving shared media: $err');
      },
    );

    // Handle sharing coming from outside the app while the app was closed
    // DISABLED: Automatic processing on app startup for production
    // ReceiveSharingIntent.instance
    //     .getInitialMedia()
    //     .then((List<SharedMediaFile> sharedMedia) {
    //   if (sharedMedia.isNotEmpty && _onReceiptProcessed != null) {
    //     _handleSharedMedia(sharedMedia);
    //   }
    // });
  }

  /// Handle shared media (images and text)
  Future<void> _handleSharedMedia(List<SharedMediaFile> sharedMedia) async {
    for (final mediaFile in sharedMedia) {
      if (mediaFile.type == SharedMediaType.image) {
        // Try to detect source app from file path or metadata
        final sourceApp = _detectSourceApp(mediaFile);
        await _processSharedImage(mediaFile.path, sourceApp: sourceApp);
      } else if (mediaFile.type == SharedMediaType.text) {
        print('Received shared text: ${mediaFile.path}');
        // Handle shared text if needed
      }
    }
  }

  /// Detect source app from media file metadata
  String? _detectSourceApp(SharedMediaFile mediaFile) {
    // This is a simplified detection - in a real implementation,
    // you would need native code to get the actual source app
    final path = mediaFile.path.toLowerCase();

    // Common patterns that might indicate source apps
    if (path.contains('instagram')) return 'com.instagram.android';
    if (path.contains('whatsapp')) return 'com.whatsapp';
    if (path.contains('facebook')) return 'com.facebook.katana';
    if (path.contains('messenger')) return 'com.facebook.orca';
    if (path.contains('twitter')) return 'com.twitter.android';
    if (path.contains('snapchat')) return 'com.snapchat.android';
    if (path.contains('camera')) return 'com.android.camera2';
    if (path.contains('gallery')) return 'com.android.gallery3d';
    if (path.contains('photos')) return 'com.google.android.apps.photos';

    return null; // Unknown source
  }

  /// Process a shared image using ReceiptProvider
  Future<ReceiptData?> _processSharedImage(String imagePath,
      {String? sourceApp}) async {
    try {
      print('🔍 [ShareHandler] Processing shared image: $imagePath');

      if (_receiptProvider == null) {
        print('❌ [ShareHandler] ReceiptProvider not set');
        return null;
      }

      // Use the same processing function as Manage screen
      final receiptData =
          await _receiptProvider!.processImage(imagePath, sourceApp: sourceApp);

      if (receiptData != null) {
        print('✅ [ShareHandler] Successfully processed shared image');
        // Navigate to receipts screen
        NavigationService().navigateToReceipts();
      } else {
        print('❌ [ShareHandler] Failed to process shared image');
      }

      return receiptData;
    } catch (e) {
      print('❌ [ShareHandler] Error processing shared image: $e');
      return null;
    }
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
      return originalPath; // Return original path if saving fails
    }
  }

  /// Process image from camera or gallery
  Future<ReceiptData?> processImageFromPicker(String imagePath,
      {String? sourceApp}) async {
    return await _processSharedImage(imagePath, sourceApp: sourceApp);
  }

  /// Get all saved receipts
  Future<List<String>> getSavedReceiptImages() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final receiptsDir = Directory(path.join(appDir.path, 'receipts'));

      if (!await receiptsDir.exists()) {
        return [];
      }

      final files = await receiptsDir.list().toList();
      return files
          .where((file) => file is File && _isImageFile(file.path))
          .map((file) => file.path)
          .toList();
    } catch (e) {
      print('Error getting saved receipts: $e');
      return [];
    }
  }

  /// Check if file is an image
  bool _isImageFile(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    return ['.jpg', '.jpeg', '.png', '.bmp', '.gif'].contains(extension);
  }

  /// Delete receipt image
  Future<bool> deleteReceiptImage(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting receipt image: $e');
      return false;
    }
  }

  /// Get receipt image file size
  Future<int> getReceiptImageSize(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        return await file.length();
      }
      return 0;
    } catch (e) {
      print('Error getting image size: $e');
      return 0;
    }
  }

  /// Dispose resources
  void dispose() {
    _intentDataStreamSubscription?.cancel();
    _intentDataStreamSubscription2?.cancel();
    _ocrService.dispose();
  }
}
