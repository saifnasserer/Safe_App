import 'package:flutter/material.dart';
import 'package:safe/models/receipt_data.dart';
import 'package:safe/Screens/receipt_screen/receipt_preview_screen.dart';

class NavigationService {
  static final NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;
  NavigationService._internal();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  bool _isOverlayVisible = false;

  /// Navigate to receipt preview screen
  void navigateToReceiptPreview(ReceiptData receiptData) {
    final context = navigatorKey.currentContext;
    if (context != null) {
      // Hide loading overlay first
      hideShareProcessingOverlay();

      // Then navigate
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ReceiptPreviewScreen(receiptData: receiptData),
        ),
      );
    }
  }

  /// Show loading overlay for share processing
  void showShareProcessingOverlay() {
    if (_isOverlayVisible) return; // Prevent multiple overlays

    final context = navigatorKey.currentContext;
    if (context != null) {
      _isOverlayVisible = true;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            contentPadding: EdgeInsets.zero,
            content: Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.95),
                    Colors.white.withOpacity(0.85),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      strokeWidth: 3,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'جاري معالجة الصورة...',
                    style: TextStyle(
                      fontFamily: 'CairoBold',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'يتم استخدام الذكاء الاصطناعي لتحليل الإيصال',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ).then((_) {
        _isOverlayVisible = false;
      });
    }
  }

  /// Hide loading overlay
  void hideShareProcessingOverlay() {
    final context = navigatorKey.currentContext;
    if (context != null && _isOverlayVisible) {
      Navigator.of(context).pop();
      _isOverlayVisible = false;
    }
  }

  /// Navigate to receipts screen
  void navigateToReceipts() {
    final context = navigatorKey.currentContext;
    if (context != null) {
      Navigator.of(context).pushNamed('/receipts');
    }
  }
}
