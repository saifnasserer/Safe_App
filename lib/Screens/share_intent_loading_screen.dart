import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:path_provider/path_provider.dart';
import 'package:safe/Constants.dart';
import 'package:safe/models/receipt_data.dart';
import 'package:safe/services/ocr_service.dart';
import 'package:safe/services/receipt_parser.dart';
import 'package:safe/services/gemini_service.dart';
import 'package:safe/providers/profile_provider.dart';
import 'package:safe/providers/Item_Provider.dart';
import 'package:safe/providers/Goal_Provider.dart';
import 'package:safe/providers/receipt_provider.dart';
import 'package:safe/Screens/enhanced_receipt_preview_screen.dart';
import 'package:safe/Screens/home_screen/HomePage.dart';

/// Optimized loading screen for share intent processing
class ShareIntentLoadingScreen extends StatefulWidget {
  const ShareIntentLoadingScreen({super.key});

  @override
  State<ShareIntentLoadingScreen> createState() => _ShareIntentLoadingScreenState();
}

class _ShareIntentLoadingScreenState extends State<ShareIntentLoadingScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  final OCRService _ocrService = OCRService();
  final GeminiService _geminiService = GeminiService();

  String _currentStatus = 'جاري تحضير التطبيق...';
  double _progress = 0.0;
  bool _hasError = false;
  String? _errorMessage;
  int _retryCount = 0;
  static const int _maxRetries = 3;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _processShareIntent();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _animationController.forward();
  }

  Future<void> _processShareIntent() async {
    try {
      // Step 1: Get shared media
      _updateStatus('جاري استلام الصورة...', 0.1);
      await Future.delayed(const Duration(milliseconds: 500));

      final sharedMedia = await ReceiveSharingIntent.instance.getInitialMedia();
      
      if (sharedMedia.isEmpty) {
        _handleError('لم يتم العثور على صورة مشتركة');
        return;
      }

      final imageFile = sharedMedia.first;
      if (imageFile.type != SharedMediaType.image) {
        _handleError('نوع الملف غير مدعوم');
        return;
      }

      // Step 2: Save image to app directory
      _updateStatus('جاري حفظ الصورة...', 0.2);
      final savedImagePath = await _saveImageToAppDirectory(imageFile.path);
      await Future.delayed(const Duration(milliseconds: 300));

      // Step 3: Extract text using OCR
      _updateStatus('جاري استخراج النص من الصورة...', 0.3);
      final extractedText = await _ocrService.extractTextFromImage(savedImagePath);
      
      if (extractedText.isEmpty) {
        _handleError('لم يتم العثور على نص في الصورة');
        return;
      }

      // Step 4: Clean and validate text
      _updateStatus('جاري تحليل النص...', 0.5);
      final cleanedText = ReceiptParser.cleanText(extractedText);
      
      if (!ReceiptParser.isValidReceipt(cleanedText)) {
        _handleError('لا يبدو هذا النص كإيصال صالح');
        return;
      }

      // Step 5: Process with AI (with fallback)
      _updateStatus('جاري معالجة الإيصال بالذكاء الاصطناعي...', 0.7);
      final receiptData = await _processReceiptWithAI(cleanedText, savedImagePath, imageFile);
      
      if (receiptData == null) {
        _handleError('فشل في معالجة الإيصال');
        return;
      }

      // Step 6: Complete processing
      _updateStatus('تمت المعالجة بنجاح!', 1.0);
      await Future.delayed(const Duration(milliseconds: 800));

      // Navigate to preview screen
      _navigateToPreview(receiptData);

    } catch (e) {
      _handleError('حدث خطأ غير متوقع: $e');
    }
  }

  Future<ReceiptData?> _processReceiptWithAI(String text, String imagePath, SharedMediaFile imageFile) async {
    try {
      // Detect source app
      final sourceApp = _detectSourceApp(imageFile);
      
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
        _updateStatus('جاري المعالجة المحلية...', 0.8);
        return await ReceiptParser.parseReceiptText(text, imagePath, sourceApp: sourceApp);
      }
    } catch (e) {
      print('Error in AI processing: $e');
      // Fall back to regex parsing
      _updateStatus('جاري المعالجة المحلية...', 0.8);
      return await ReceiptParser.parseReceiptText(text, imagePath);
    }
  }

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

  String _generateTitle(String? merchant, double? amount) {
    if (merchant != null && merchant.isNotEmpty) {
      return merchant;
    } else if (amount != null) {
      return 'مصروف ${amount.toStringAsFixed(0)} ج.م';
    } else {
      return 'مصروف جديد';
    }
  }

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

  void _updateStatus(String status, double progress) {
    if (mounted) {
      setState(() {
        _currentStatus = status;
        _progress = progress;
      });
    }
  }

  void _handleError(String error) {
    if (mounted) {
      setState(() {
        _hasError = true;
        _errorMessage = error;
        _progress = 0.0;
      });
    }
  }

  void _navigateToPreview(ReceiptData receiptData) {
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => MultiProvider(
            providers: [
              ChangeNotifierProvider<ProfileProvider>(
                create: (context) {
                  final provider = ProfileProvider();
                  // Initialize asynchronously to avoid blocking UI
                  Future.microtask(() => provider.initialize());
                  return provider;
                },
              ),
              ChangeNotifierProxyProvider<ProfileProvider, ItemProvider>(
                create: (context) => ItemProvider(
                  Provider.of<ProfileProvider>(context, listen: false),
                  context,
                ),
                update: (context, profileProvider, previous) =>
                    ItemProvider(profileProvider, context),
              ),
              ChangeNotifierProxyProvider<ProfileProvider, GoalProvider>(
                create: (context) => GoalProvider(
                  Provider.of<ProfileProvider>(context, listen: false),
                ),
                update: (context, profileProvider, previous) =>
                    GoalProvider(profileProvider),
              ),
              ChangeNotifierProvider<ReceiptProvider>(
                create: (context) => ReceiptProvider(),
              ),
            ],
            child: EnhancedReceiptPreviewScreen(
              receiptData: receiptData,
              isFromShareIntent: true,
            ),
          ),
        ),
      );
    }
  }

  void _navigateToHome() {
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => MultiProvider(
            providers: [
              ChangeNotifierProvider<ProfileProvider>(
                create: (context) {
                  final provider = ProfileProvider();
                  // Initialize asynchronously to avoid blocking UI
                  Future.microtask(() => provider.initialize());
                  return provider;
                },
              ),
              ChangeNotifierProxyProvider<ProfileProvider, ItemProvider>(
                create: (context) => ItemProvider(
                  Provider.of<ProfileProvider>(context, listen: false),
                  context,
                ),
                update: (context, profileProvider, previous) =>
                    ItemProvider(profileProvider, context),
              ),
              ChangeNotifierProxyProvider<ProfileProvider, GoalProvider>(
                create: (context) => GoalProvider(
                  Provider.of<ProfileProvider>(context, listen: false),
                ),
                update: (context, profileProvider, previous) =>
                    GoalProvider(profileProvider),
              ),
              ChangeNotifierProvider<ReceiptProvider>(
                create: (context) => ReceiptProvider(),
              ),
            ],
            child: const Home(),
          ),
        ),
      );
    }
  }

  Future<void> _retryProcessing() async {
    if (_retryCount >= _maxRetries) {
      _handleError('تم تجاوز عدد المحاولات المسموح');
      return;
    }

    _retryCount++;
    setState(() {
      _hasError = false;
      _errorMessage = null;
      _progress = 0.0;
    });

    await _processShareIntent();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _ocrService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Constants.scaffoldBackgroundColor,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(Constants.responsiveSpacing(context, 24)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Logo/Icon
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Constants.getPrimaryColor(context),
                            Constants.getPrimaryColor(context).withOpacity(0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Constants.getPrimaryColor(context).withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.receipt_long,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: Constants.responsiveSpacing(context, 40)),

                // Status Text
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    _currentStatus,
                    style: TextStyle(
                      fontSize: Constants.responsiveFontSize(context, 18),
                      fontFamily: Constants.defaultFontFamily,
                      color: _hasError ? Colors.red[700] : Colors.grey[800],
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                SizedBox(height: Constants.responsiveSpacing(context, 30)),

                // Progress Indicator
                if (!_hasError) ...[
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        // Progress Bar
                        Container(
                          width: double.infinity,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: _progress,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Constants.getPrimaryColor(context),
                                    Constants.getPrimaryColor(context).withOpacity(0.7),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: Constants.responsiveSpacing(context, 16)),

                        // Progress Percentage
                        Text(
                          '${(_progress * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: Constants.responsiveFontSize(context, 14),
                            fontFamily: Constants.defaultFontFamily,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Error Message
                if (_hasError) ...[
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 60,
                          color: Colors.red[400],
                        ),
                        SizedBox(height: Constants.responsiveSpacing(context, 16)),
                        Text(
                          _errorMessage ?? 'حدث خطأ غير متوقع',
                          style: TextStyle(
                            fontSize: Constants.responsiveFontSize(context, 16),
                            fontFamily: Constants.defaultFontFamily,
                            color: Colors.red[700],
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: Constants.responsiveSpacing(context, 30)),
                        
                        // Action Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Retry Button
                            if (_retryCount < _maxRetries)
                              ElevatedButton.icon(
                                onPressed: _retryProcessing,
                                icon: const Icon(Icons.refresh),
                                label: const Text('إعادة المحاولة'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Constants.getPrimaryColor(context),
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: Constants.responsiveSpacing(context, 20),
                                    vertical: Constants.responsiveSpacing(context, 12),
                                  ),
                                ),
                              ),
                            
                            // Home Button
                            ElevatedButton.icon(
                              onPressed: _navigateToHome,
                              icon: const Icon(Icons.home),
                              label: const Text('الرئيسية'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[600],
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  horizontal: Constants.responsiveSpacing(context, 20),
                                  vertical: Constants.responsiveSpacing(context, 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],

                SizedBox(height: Constants.responsiveSpacing(context, 40)),

                // Processing Animation
                if (!_hasError)
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Constants.getPrimaryColor(context),
                        ),
                        strokeWidth: 3,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
