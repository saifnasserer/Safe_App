import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safe/Screens/home_screen/Spent.dart';
import 'package:safe/Screens/home_screen/Wallet.dart';
import 'package:safe/providers/receipt_provider.dart';
import 'package:safe/services/share_intent_handler.dart';
import 'package:safe/Constants.dart';

class AppInitializer extends StatefulWidget {
  final Widget child;

  const AppInitializer({super.key, required this.child});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    if (!mounted) return;
    await WalletBlock.initWallet(context);
    await SpentBlock.initSpent(context);

    // Initialize ReceiptProvider to handle share intents
    final receiptProvider =
        Provider.of<ReceiptProvider>(context, listen: false);
    await receiptProvider.initialize();

    // Initialize the optimized share intent handler
    final shareIntentHandler = ShareIntentHandler();
    shareIntentHandler.initialize();

    if (mounted) {
      setState(() {
        _initialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _initialized
        ? widget.child
        : MaterialApp(
            home: Scaffold(
              backgroundColor: Constants.scaffoldBackgroundColor,
              body: Directionality(
                textDirection: TextDirection.rtl,
                child: Center(
                  child: Container(
                    padding: EdgeInsets.all(
                        Constants.responsiveSpacing(context, 40)),
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
                          color: Constants.getPrimaryColor(context)
                              .withOpacity(0.1),
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
                            color: Constants.getPrimaryColor(context)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(
                                Constants.responsiveRadius(context, 50)),
                          ),
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Constants.getPrimaryColor(context)),
                            strokeWidth: 3,
                          ),
                        ),
                        SizedBox(
                            height: Constants.responsiveSpacing(context, 20)),
                        Text(
                          'جاري تحضير التطبيق...',
                          style: TextStyle(
                            fontFamily: Constants.defaultFontFamily,
                            fontSize: Constants.responsiveFontSize(context, 18),
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        SizedBox(
                            height: Constants.responsiveSpacing(context, 8)),
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
