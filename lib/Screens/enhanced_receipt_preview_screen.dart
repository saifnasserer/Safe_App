import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:safe/Constants.dart';
import 'package:safe/models/receipt_data.dart';
import 'package:safe/providers/receipt_provider.dart';
import 'package:safe/providers/Item_Provider.dart';
import 'package:safe/providers/profile_provider.dart';
import 'package:safe/providers/Goal_Provider.dart';
import 'package:safe/widgets/item.dart';
import 'package:safe/Screens/home_screen/HomePage.dart';

/// Enhanced receipt preview screen with deferred provider initialization
class EnhancedReceiptPreviewScreen extends StatefulWidget {
  final ReceiptData receiptData;
  final bool isFromShareIntent;

  const EnhancedReceiptPreviewScreen({
    super.key,
    required this.receiptData,
    this.isFromShareIntent = false,
  });

  @override
  State<EnhancedReceiptPreviewScreen> createState() => _EnhancedReceiptPreviewScreenState();
}

class _EnhancedReceiptPreviewScreenState extends State<EnhancedReceiptPreviewScreen> {
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late DateTime _selectedDate;
  bool _isSaving = false;
  bool _isInitializingProviders = false;
  bool _providersInitialized = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.receiptData.title ?? '');
    _amountController = TextEditingController(
      text: widget.receiptData.amount?.toStringAsFixed(2) ?? '',
    );
    _selectedDate = widget.receiptData.date ?? DateTime.now();
    
    // Set initial provider state
    if (!widget.isFromShareIntent) {
      _providersInitialized = true;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Initialize providers if coming from share intent (after context is ready)
    if (widget.isFromShareIntent && !_providersInitialized && !_isInitializingProviders) {
      _initializeProviders();
    }
  }

  Future<void> _initializeProviders() async {
    if (_providersInitialized || _isInitializingProviders) return;
    
    setState(() {
      _isInitializingProviders = true;
    });

    try {
      // Initialize ReceiptProvider asynchronously to avoid blocking UI
      await Future.delayed(const Duration(milliseconds: 100)); // Small delay to let UI render
      
      final receiptProvider = Provider.of<ReceiptProvider>(context, listen: false);
      
      // Initialize in background
      unawaited(receiptProvider.initialize().then((_) {
        if (mounted) {
          // Add the receipt to the provider after initialization
          receiptProvider.addReceipt(widget.receiptData);
          
          setState(() {
            _providersInitialized = true;
            _isInitializingProviders = false;
          });
        }
      }));

      // Mark as initialized immediately to show UI
      if (mounted) {
        setState(() {
          _providersInitialized = true;
          _isInitializingProviders = false;
        });
      }
    } catch (e) {
      print('Error initializing providers: $e');
      if (mounted) {
        setState(() {
          _isInitializingProviders = false;
        });
        // Show error after the widget is fully built
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _showErrorSnackBar('فشل في تهيئة التطبيق: $e');
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Constants.getPrimaryColor(context),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Constants.getPrimaryColor(context),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _retryProcessing() async {
    setState(() {
      _isSaving = true;
    });

    try {
      await Provider.of<ReceiptProvider>(context, listen: false)
          .retryProcessing(widget.receiptData.id);

      if (mounted) {
        _showSuccessSnackBar('تم إعادة معالجة الإيصال');
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('فشل في إعادة معالجة الإيصال: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _saveAsTransaction() async {
    if (_titleController.text.isEmpty || _amountController.text.isEmpty) {
      _showErrorSnackBar('يرجى ملء جميع الحقول المطلوبة');
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      _showErrorSnackBar('يرجى إدخال مبلغ صحيح');
      return;
    }

    // Ensure providers are initialized
    if (!_providersInitialized) {
      await _initializeProviders();
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // Create transaction item
      final transaction = item(
        title: _titleController.text,
        price: amount,
        flag: false, // Expense
        dateTime: _selectedDate,
      );

      // Add to transaction provider
      await Provider.of<ItemProvider>(context, listen: false)
          .addItem(transaction);

      // Update receipt data
      final updatedReceipt = widget.receiptData.copyWith(
        title: _titleController.text,
        amount: amount,
        date: _selectedDate,
        isProcessed: true,
      );

      await Provider.of<ReceiptProvider>(context, listen: false)
          .updateReceipt(updatedReceipt);

      if (mounted) {
        HapticFeedback.mediumImpact();
        _showSuccessSnackBar('تم حفظ المعاملة بنجاح');
        
        // Navigate to home if from share intent, otherwise pop
        if (widget.isFromShareIntent) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const Home()),
            (route) => false,
          );
        } else {
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('فشل في حفظ المعاملة: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _navigateToHome() {
    if (widget.isFromShareIntent) {
      // Navigate to the full app with providers
      Navigator.of(context).pushAndRemoveUntil(
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
        (route) => false,
      );
    } else {
      Navigator.pop(context);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: Constants.defaultFontFamily,
          ),
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.fixed,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: Constants.defaultFontFamily,
          ),
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.fixed,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Constants.scaffoldBackgroundColor,
        appBar: AppBar(
centerTitle: true,
          title: const Text(
            'معاينة الإيصال',
            style: TextStyle(
              fontFamily: Constants.defaultFontFamily,
              color: Constants.defaultPrimaryColor,
            ),
          ),
          backgroundColor: Colors.white,
          foregroundColor: Constants.defaultPrimaryColor,
          elevation: 0,
          actions: [
            if (!widget.isFromShareIntent)
              IconButton(
                onPressed: _retryProcessing,
                icon: const Icon(Icons.refresh),
                tooltip: 'إعادة معالجة',
              ),
          ],
        ),
        body: _isInitializingProviders
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('جاري تهيئة التطبيق...'),
                  ],
                ),
              )
            : _buildContent(),
        bottomNavigationBar: _buildBottomBar(),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(Constants.responsiveSpacing(context, 20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Receipt Image
          _buildReceiptImage(),
          
          SizedBox(height: Constants.responsiveSpacing(context, 24)),
          
          // Processing Status
          _buildProcessingStatus(),
          
          SizedBox(height: Constants.responsiveSpacing(context, 24)),
          
          // Form Fields
          _buildFormFields(),
          
          SizedBox(height: Constants.responsiveSpacing(context, 24)),
          
          // Error Message (if any)
          if (widget.receiptData.errorMessage != null)
            _buildErrorMessage(),
        ],
      ),
    );
  }

  Widget _buildReceiptImage() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Constants.responsiveRadius(context, 16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Constants.responsiveRadius(context, 16)),
        child: Image.file(
          File(widget.receiptData.imagePath),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[200],
              child: const Icon(
                Icons.image_not_supported,
                size: 50,
                color: Colors.grey,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProcessingStatus() {
    return Container(
      padding: EdgeInsets.all(Constants.responsiveSpacing(context, 16)),
      decoration: BoxDecoration(
        color: widget.receiptData.sourceApp != null && widget.receiptData.sourceApp!.isNotEmpty
            ? Colors.blue.withOpacity(0.1)
            : Colors.purple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(Constants.responsiveRadius(context, 12)),
        border: Border.all(
          color: widget.receiptData.sourceApp != null && widget.receiptData.sourceApp!.isNotEmpty
              ? Colors.blue.withOpacity(0.3)
              : Colors.purple.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(Constants.responsiveSpacing(context, 12)),
            decoration: BoxDecoration(
              color: widget.receiptData.sourceApp != null && widget.receiptData.sourceApp!.isNotEmpty
                  ? Colors.blue.withOpacity(0.2)
                  : Colors.purple.withOpacity(0.2),
              borderRadius: BorderRadius.circular(Constants.responsiveRadius(context, 12)),
            ),
            child: Icon(
              widget.receiptData.sourceApp != null && widget.receiptData.sourceApp!.isNotEmpty
                  ? Icons.smart_toy // AI processing
                  : Icons.computer, // Local processing
              color: widget.receiptData.sourceApp != null && widget.receiptData.sourceApp!.isNotEmpty
                  ? Colors.blue[700]
                  : Colors.purple[700],
              size: 28,
            ),
          ),
          SizedBox(width: Constants.responsiveSpacing(context, 16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.receiptData.sourceApp != null && widget.receiptData.sourceApp!.isNotEmpty
                      ? 'معالجة بالذكاء الاصطناعي'
                      : 'معالجة محلية',
                  style: TextStyle(
                    fontSize: Constants.responsiveFontSize(context, 16),
                    fontFamily: Constants.defaultFontFamily,
                    fontWeight: FontWeight.w600,
                    color: widget.receiptData.sourceApp != null && widget.receiptData.sourceApp!.isNotEmpty
                        ? Colors.blue[700]
                        : Colors.purple[700],
                  ),
                ),
                SizedBox(height: Constants.responsiveSpacing(context, 4)),
                Text(
                  'مستوى الثقة: ${(widget.receiptData.confidenceScore * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: Constants.responsiveFontSize(context, 14),
                    fontFamily: Constants.defaultFontFamily,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title Field
        Text(
          'عنوان المعاملة',
          style: TextStyle(
            fontSize: Constants.responsiveFontSize(context, 16),
            fontFamily: Constants.defaultFontFamily,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: Constants.responsiveSpacing(context, 8)),
        TextField(
          controller: _titleController,
          decoration: InputDecoration(
            hintText: 'أدخل عنوان المعاملة',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Constants.responsiveRadius(context, 12)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Constants.responsiveRadius(context, 12)),
              borderSide: BorderSide(
                color: Constants.getPrimaryColor(context),
                width: 2,
              ),
            ),
          ),
        ),
        
        SizedBox(height: Constants.responsiveSpacing(context, 20)),
        
        // Amount Field
        Text(
          'المبلغ',
          style: TextStyle(
            fontSize: Constants.responsiveFontSize(context, 16),
            fontFamily: Constants.defaultFontFamily,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: Constants.responsiveSpacing(context, 8)),
        TextField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: '0.00',
            suffixText: widget.receiptData.currency ?? 'ج.م',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Constants.responsiveRadius(context, 12)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Constants.responsiveRadius(context, 12)),
              borderSide: BorderSide(
                color: Constants.getPrimaryColor(context),
                width: 2,
              ),
            ),
          ),
        ),
        
        SizedBox(height: Constants.responsiveSpacing(context, 20)),
        
        // Date Field
        Text(
          'التاريخ',
          style: TextStyle(
            fontSize: Constants.responsiveFontSize(context, 16),
            fontFamily: Constants.defaultFontFamily,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: Constants.responsiveSpacing(context, 8)),
        InkWell(
          onTap: () => _selectDate(context),
          child: Container(
            padding: EdgeInsets.all(Constants.responsiveSpacing(context, 16)),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(Constants.responsiveRadius(context, 12)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: Constants.getPrimaryColor(context),
                ),
                SizedBox(width: Constants.responsiveSpacing(context, 12)),
                Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  style: TextStyle(
                    fontSize: Constants.responsiveFontSize(context, 16),
                    fontFamily: Constants.defaultFontFamily,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: EdgeInsets.all(Constants.responsiveSpacing(context, 16)),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(Constants.responsiveRadius(context, 12)),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red[700],
            size: 24,
          ),
          SizedBox(width: Constants.responsiveSpacing(context, 12)),
          Expanded(
            child: Text(
              widget.receiptData.errorMessage!,
              style: TextStyle(
                fontSize: Constants.responsiveFontSize(context, 14),
                fontFamily: Constants.defaultFontFamily,
                color: Colors.red[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.all(Constants.responsiveSpacing(context, 20)),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Cancel Button
          Expanded(
            child: OutlinedButton(
              onPressed: _isSaving ? null : _navigateToHome,
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  vertical: Constants.responsiveSpacing(context, 16),
                ),
                side: BorderSide(color: Colors.grey[400]!),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Constants.responsiveRadius(context, 12)),
                ),
              ),
              child: Text(
                'إلغاء',
                style: TextStyle(
                  fontSize: Constants.responsiveFontSize(context, 16),
                  fontFamily: Constants.defaultFontFamily,
                  color: Colors.grey[700],
                ),
              ),
            ),
          ),
          
          SizedBox(width: Constants.responsiveSpacing(context, 16)),
          
          // Save Button
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _saveAsTransaction,
              style: ElevatedButton.styleFrom(
                backgroundColor: Constants.getPrimaryColor(context),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  vertical: Constants.responsiveSpacing(context, 16),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Constants.responsiveRadius(context, 12)),
                ),
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'حفظ المعاملة',
                      style: TextStyle(
                        fontSize: Constants.responsiveFontSize(context, 16),
                        fontFamily: Constants.defaultFontFamily,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
