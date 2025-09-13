import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:safe/Constants.dart';
import 'package:safe/models/receipt_data.dart';
import 'package:safe/providers/receipt_provider.dart';
import 'package:safe/providers/Item_Provider.dart';
import 'package:safe/widgets/item.dart';

class ReceiptPreviewScreen extends StatefulWidget {
  final ReceiptData receiptData;

  const ReceiptPreviewScreen({
    super.key,
    required this.receiptData,
  });

  @override
  State<ReceiptPreviewScreen> createState() => _ReceiptPreviewScreenState();
}

class _ReceiptPreviewScreenState extends State<ReceiptPreviewScreen> {
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late DateTime _selectedDate;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.receiptData.title ?? '');
    _amountController = TextEditingController(
      text: widget.receiptData.amount?.toStringAsFixed(2) ?? '',
    );
    _selectedDate = widget.receiptData.date ?? DateTime.now();
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
        Navigator.pop(context, true);
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
        behavior: SnackBarBehavior.floating,
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
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'معاينة الإيصال',
          style: TextStyle(
            fontFamily: Constants.defaultFontFamily,
            color: Colors.white,
          ),
        ),
        backgroundColor: Constants.getPrimaryColor(context),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text(
                    'حذف الإيصال',
                    style: TextStyle(fontFamily: Constants.defaultFontFamily),
                  ),
                  content: const Text(
                    'هل أنت متأكد من حذف هذا الإيصال؟',
                    style: TextStyle(fontFamily: Constants.secondaryFontFamily),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('إلغاء'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('حذف',
                          style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                await Provider.of<ReceiptProvider>(context, listen: false)
                    .removeReceipt(widget.receiptData.id);
                if (mounted) {
                  Navigator.pop(context);
                }
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Constants.responsiveSpacing(context, 16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Receipt Image
            Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.4,
                  ),
                  child: Image.file(
                    File(widget.receiptData.imagePath),
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(
                            Icons.image_not_supported,
                            size: 64,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            SizedBox(height: Constants.responsiveSpacing(context, 20)),

            // Confidence Score
            if (widget.receiptData.confidenceScore > 0)
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding:
                      EdgeInsets.all(Constants.responsiveSpacing(context, 16)),
                  child: Row(
                    children: [
                      Icon(
                        Icons.analytics_outlined,
                        color: Constants.getPrimaryColor(context),
                        size: 24,
                      ),
                      SizedBox(width: Constants.responsiveSpacing(context, 12)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'مستوى الثقة',
                              style: TextStyle(
                                fontFamily: Constants.defaultFontFamily,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${(widget.receiptData.confidenceScore * 100).toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontFamily: Constants.secondaryFontFamily,
                                color: widget.receiptData.confidenceScore > 0.7
                                    ? Colors.green
                                    : widget.receiptData.confidenceScore > 0.4
                                        ? Colors.orange
                                        : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            SizedBox(height: Constants.responsiveSpacing(context, 20)),

            // Transaction Form
            Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding:
                    EdgeInsets.all(Constants.responsiveSpacing(context, 20)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'تفاصيل المعاملة',
                      style: TextStyle(
                        fontFamily: Constants.defaultFontFamily,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: Constants.responsiveSpacing(context, 20)),

                    // Title Field
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'وصف المعاملة',
                        labelStyle: TextStyle(
                          fontFamily: Constants.secondaryFontFamily,
                          color: Constants.getPrimaryColor(context),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Constants.getPrimaryColor(context),
                            width: 2,
                          ),
                        ),
                      ),
                      style: const TextStyle(
                        fontFamily: Constants.secondaryFontFamily,
                        fontSize: 16,
                      ),
                    ),

                    SizedBox(height: Constants.responsiveSpacing(context, 16)),

                    // Amount Field
                    TextField(
                      controller: _amountController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'المبلغ',
                        labelStyle: TextStyle(
                          fontFamily: Constants.secondaryFontFamily,
                          color: Constants.getPrimaryColor(context),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Constants.getPrimaryColor(context),
                            width: 2,
                          ),
                        ),
                        suffixText: 'ج.م',
                        suffixStyle: TextStyle(
                          fontFamily: Constants.secondaryFontFamily,
                          color: Constants.getPrimaryColor(context),
                        ),
                      ),
                      style: const TextStyle(
                        fontFamily: Constants.secondaryFontFamily,
                        fontSize: 16,
                      ),
                    ),

                    SizedBox(height: Constants.responsiveSpacing(context, 16)),

                    // Date Field
                    InkWell(
                      onTap: () => _selectDate(context),
                      child: Container(
                        padding: EdgeInsets.all(
                            Constants.responsiveSpacing(context, 16)),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color: Constants.getPrimaryColor(context),
                            ),
                            SizedBox(
                                width:
                                    Constants.responsiveSpacing(context, 12)),
                            Text(
                              '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                              style: const TextStyle(
                                fontFamily: Constants.secondaryFontFamily,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: Constants.responsiveSpacing(context, 20)),

            // Error Message Display
            if (widget.receiptData.errorMessage != null)
              Card(
                elevation: 4,
                color: Colors.red[50],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding:
                      EdgeInsets.all(Constants.responsiveSpacing(context, 16)),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red[600],
                        size: 24,
                      ),
                      SizedBox(width: Constants.responsiveSpacing(context, 12)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'خطأ في المعالجة',
                              style: TextStyle(
                                fontFamily: Constants.defaultFontFamily,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                            Text(
                              widget.receiptData.errorMessage!,
                              style: const TextStyle(
                                fontFamily: Constants.secondaryFontFamily,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            if (widget.receiptData.errorMessage != null)
              SizedBox(height: Constants.responsiveSpacing(context, 16)),

            // Retry Button (for failed receipts)
            if (widget.receiptData.errorMessage != null)
              ElevatedButton(
                onPressed: _isSaving ? null : _retryProcessing,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    vertical: Constants.responsiveSpacing(context, 16),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'إعادة المحاولة',
                        style: TextStyle(
                          fontFamily: Constants.defaultFontFamily,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),

            if (widget.receiptData.errorMessage != null)
              SizedBox(height: Constants.responsiveSpacing(context, 16)),

            // Save Button
            ElevatedButton(
              onPressed: widget.receiptData.errorMessage != null || _isSaving
                  ? null
                  : _saveAsTransaction,
              style: ElevatedButton.styleFrom(
                backgroundColor: Constants.getPrimaryColor(context),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  vertical: Constants.responsiveSpacing(context, 16),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'حفظ كمعاملة',
                      style: TextStyle(
                        fontFamily: Constants.defaultFontFamily,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
