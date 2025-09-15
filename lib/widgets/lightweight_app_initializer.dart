import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safe/services/share_intent_handler.dart';
import 'package:safe/providers/receipt_provider.dart';
import 'package:safe/Constants.dart';

/// Lightweight app initializer for share intent flow
/// Only initializes essential services, defers heavy initialization
class LightweightAppInitializer extends StatefulWidget {
  final Widget child;

  const LightweightAppInitializer({super.key, required this.child});

  @override
  State<LightweightAppInitializer> createState() =>
      _LightweightAppInitializerState();
}

class _LightweightAppInitializerState extends State<LightweightAppInitializer> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _checkForShareIntent();
  }

  Future<void> _checkForShareIntent() async {
    // Initialize receipt provider for share intent flow
    final receiptProvider =
        Provider.of<ReceiptProvider>(context, listen: false);
    await receiptProvider.initializeForShareIntent();

    // Initialize share intent handling immediately
    final shareIntentHandler = ShareIntentHandler();
    shareIntentHandler.initialize();

    // Mark as initialized for share intent flow
    if (mounted) {
      setState(() {
        _initialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return _buildLoadingScreen();
    }

    // If this is a share intent, show the child immediately
    // The share intent handler will take over navigation
    return widget.child;
  }

  Widget _buildLoadingScreen() {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Constants.scaffoldBackgroundColor,
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: Center(
            child: Container(
              padding: EdgeInsets.all(Constants.responsiveSpacing(context, 40)),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                    Constants.responsiveRadius(context, 20)),
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
                    color: Constants.getPrimaryColor(context).withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(
                        Constants.responsiveSpacing(context, 20)),
                    decoration: BoxDecoration(
                      color:
                          Constants.getPrimaryColor(context).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(
                          Constants.responsiveRadius(context, 50)),
                    ),
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Constants.getPrimaryColor(context)),
                      strokeWidth: 3,
                    ),
                  ),
                  SizedBox(height: Constants.responsiveSpacing(context, 20)),
                  Text(
                    'جاري تحضير التطبيق...',
                    style: TextStyle(
                      fontFamily: Constants.defaultFontFamily,
                      fontSize: Constants.responsiveFontSize(context, 18),
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: Constants.responsiveSpacing(context, 8)),
                  Text(
                    'يتم تهيئة خدمات التطبيق',
                    style: TextStyle(
                      fontFamily: Constants.secondaryFontFamily,
                      fontSize: Constants.responsiveFontSize(context, 14),
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
