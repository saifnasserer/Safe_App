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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
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
                      style:
                          TextStyle(fontFamily: Constants.secondaryFontFamily),
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
              Container(
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
                      color:
                          Constants.getPrimaryColor(context).withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                      Constants.responsiveRadius(context, 20)),
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
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.grey[200]!,
                                Colors.grey[100]!,
                              ],
                            ),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.image_not_supported,
                                  size: 64,
                                  color: Constants.getPrimaryColor(context)
                                      .withOpacity(0.5),
                                ),
                                SizedBox(
                                    height: Constants.responsiveSpacing(
                                        context, 8)),
                                Text(
                                  'خطأ في تحميل الصورة',
                                  style: TextStyle(
                                    fontFamily: Constants.secondaryFontFamily,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              SizedBox(height: Constants.responsiveSpacing(context, 20)),

              // Processing Method Info
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                      Constants.responsiveRadius(context, 16)),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: widget.receiptData.sourceApp != null &&
                            widget.receiptData.sourceApp!.isNotEmpty
                        ? [
                            Colors.blue.withOpacity(0.1),
                            Colors.blue.withOpacity(0.05),
                          ]
                        : [
                            Colors.purple.withOpacity(0.1),
                            Colors.purple.withOpacity(0.05),
                          ],
                  ),
                  border: Border.all(
                    color: widget.receiptData.sourceApp != null &&
                            widget.receiptData.sourceApp!.isNotEmpty
                        ? Colors.blue.withOpacity(0.2)
                        : Colors.purple.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding:
                      EdgeInsets.all(Constants.responsiveSpacing(context, 20)),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(
                            Constants.responsiveSpacing(context, 12)),
                        decoration: BoxDecoration(
                          color: widget.receiptData.sourceApp != null &&
                                  widget.receiptData.sourceApp!.isNotEmpty
                              ? Colors.blue.withOpacity(0.2)
                              : Colors.purple.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(
                              Constants.responsiveRadius(context, 12)),
                        ),
                        child: Icon(
                          widget.receiptData.sourceApp != null &&
                                  widget.receiptData.sourceApp!.isNotEmpty
                              ? Icons.smart_toy // AI processing
                              : Icons.computer, // Local processing
                          color: widget.receiptData.sourceApp != null &&
                                  widget.receiptData.sourceApp!.isNotEmpty
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
                              widget.receiptData.sourceApp != null &&
                                      widget.receiptData.sourceApp!.isNotEmpty
                                  ? 'معالجة ذكية'
                                  : 'معالجة محلية',
                              style: TextStyle(
                                fontFamily: Constants.defaultFontFamily,
                                fontWeight: FontWeight.bold,
                                fontSize:
                                    Constants.responsiveFontSize(context, 16),
                                color: widget.receiptData.sourceApp != null &&
                                        widget.receiptData.sourceApp!.isNotEmpty
                                    ? Colors.blue[700]
                                    : Colors.purple[700],
                              ),
                            ),
                            SizedBox(
                                height:
                                    Constants.responsiveSpacing(context, 4)),
                            Text(
                              widget.receiptData.sourceApp != null &&
                                      widget.receiptData.sourceApp!.isNotEmpty
                                  ? 'تمت المعالجة باستخدام الذكاء الاصطناعي'
                                  : 'تمت المعالجة محلياً باستخدام القواعد المبرمجة',
                              style: TextStyle(
                                fontFamily: Constants.secondaryFontFamily,
                                color: Colors.grey[600],
                                fontSize:
                                    Constants.responsiveFontSize(context, 12),
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
              Container(
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
                      color:
                          Constants.getPrimaryColor(context).withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding:
                      EdgeInsets.all(Constants.responsiveSpacing(context, 24)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(
                                Constants.responsiveSpacing(context, 8)),
                            decoration: BoxDecoration(
                              color: Constants.getPrimaryColor(context)
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(
                                  Constants.responsiveRadius(context, 8)),
                            ),
                            child: Icon(
                              Icons.edit_note,
                              color: Constants.getPrimaryColor(context),
                              size: 24,
                            ),
                          ),
                          SizedBox(
                              width: Constants.responsiveSpacing(context, 12)),
                          Text(
                            'تفاصيل المعاملة',
                            style: TextStyle(
                              fontFamily: Constants.defaultFontFamily,
                              fontSize:
                                  Constants.responsiveFontSize(context, 20),
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                          height: Constants.responsiveSpacing(context, 20)),

                      // Title Field
                      TextField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: 'وصف المعاملة',
                          labelStyle: TextStyle(
                            fontFamily: Constants.secondaryFontFamily,
                            color: Constants.getPrimaryColor(context),
                            fontSize: Constants.responsiveFontSize(context, 14),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                Constants.responsiveRadius(context, 12)),
                            borderSide: BorderSide(
                              color: Colors.grey.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                Constants.responsiveRadius(context, 12)),
                            borderSide: BorderSide(
                              color: Colors.grey.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                Constants.responsiveRadius(context, 12)),
                            borderSide: BorderSide(
                              color: Constants.getPrimaryColor(context),
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.grey.withOpacity(0.05),
                          contentPadding: EdgeInsets.all(
                              Constants.responsiveSpacing(context, 16)),
                        ),
                        style: TextStyle(
                          fontFamily: Constants.secondaryFontFamily,
                          fontSize: Constants.responsiveFontSize(context, 16),
                          color: Colors.grey[800],
                        ),
                      ),

                      SizedBox(
                          height: Constants.responsiveSpacing(context, 16)),

                      // Amount Field
                      TextField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: InputDecoration(
                          labelText: 'المبلغ',
                          labelStyle: TextStyle(
                            fontFamily: Constants.secondaryFontFamily,
                            color: Constants.getPrimaryColor(context),
                            fontSize: Constants.responsiveFontSize(context, 14),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                Constants.responsiveRadius(context, 12)),
                            borderSide: BorderSide(
                              color: Colors.grey.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                Constants.responsiveRadius(context, 12)),
                            borderSide: BorderSide(
                              color: Colors.grey.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                Constants.responsiveRadius(context, 12)),
                            borderSide: BorderSide(
                              color: Constants.getPrimaryColor(context),
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.grey.withOpacity(0.05),
                          contentPadding: EdgeInsets.all(
                              Constants.responsiveSpacing(context, 16)),
                          suffixText: 'ج.م',
                          suffixStyle: TextStyle(
                            fontFamily: Constants.secondaryFontFamily,
                            color: Constants.getPrimaryColor(context),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: TextStyle(
                          fontFamily: Constants.secondaryFontFamily,
                          fontSize: Constants.responsiveFontSize(context, 16),
                          color: Colors.grey[800],
                        ),
                      ),

                      SizedBox(
                          height: Constants.responsiveSpacing(context, 16)),

                      // Date Field
                      InkWell(
                        onTap: () => _selectDate(context),
                        borderRadius: BorderRadius.circular(
                            Constants.responsiveRadius(context, 12)),
                        child: Container(
                          padding: EdgeInsets.all(
                              Constants.responsiveSpacing(context, 16)),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey.withOpacity(0.3),
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(
                                Constants.responsiveRadius(context, 12)),
                            color: Colors.grey.withOpacity(0.05),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(
                                    Constants.responsiveSpacing(context, 8)),
                                decoration: BoxDecoration(
                                  color: Constants.getPrimaryColor(context)
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(
                                      Constants.responsiveRadius(context, 8)),
                                ),
                                child: Icon(
                                  Icons.calendar_today,
                                  color: Constants.getPrimaryColor(context),
                                  size: 20,
                                ),
                              ),
                              SizedBox(
                                  width:
                                      Constants.responsiveSpacing(context, 12)),
                              Text(
                                '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                                style: TextStyle(
                                  fontFamily: Constants.secondaryFontFamily,
                                  fontSize:
                                      Constants.responsiveFontSize(context, 16),
                                  color: Colors.grey[800],
                                ),
                              ),
                              const Spacer(),
                              Icon(
                                Icons.arrow_drop_down,
                                color: Constants.getPrimaryColor(context),
                                size: 24,
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
                    padding: EdgeInsets.all(
                        Constants.responsiveSpacing(context, 16)),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.red[600],
                          size: 24,
                        ),
                        SizedBox(
                            width: Constants.responsiveSpacing(context, 12)),
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
                Container(
                  width: double.infinity,
                  height: Constants.heightPercent(context, 7),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                        Constants.responsiveRadius(context, 16)),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.orange.withOpacity(0.9),
                        Colors.orange.withOpacity(0.7),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _isSaving ? null : _retryProcessing,
                      borderRadius: BorderRadius.circular(
                          Constants.responsiveRadius(context, 16)),
                      child: _isSaving
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'جاري المعالجة...',
                                  style: TextStyle(
                                    fontFamily: Constants.defaultFontFamily,
                                    fontSize: Constants.responsiveFontSize(
                                        context, 16),
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.refresh,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'إعادة المحاولة',
                                  style: TextStyle(
                                    fontFamily: Constants.defaultFontFamily,
                                    fontSize: Constants.responsiveFontSize(
                                        context, 16),
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),

              if (widget.receiptData.errorMessage != null)
                SizedBox(height: Constants.responsiveSpacing(context, 16)),

              // Save Button
              Container(
                width: double.infinity,
                height: Constants.heightPercent(context, 7),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                      Constants.responsiveRadius(context, 16)),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: widget.receiptData.errorMessage != null || _isSaving
                        ? [
                            Colors.grey.withOpacity(0.5),
                            Colors.grey.withOpacity(0.3),
                          ]
                        : [
                            Constants.getPrimaryColor(context).withOpacity(0.9),
                            Constants.getPrimaryColor(context).withOpacity(0.7),
                          ],
                  ),
                  boxShadow:
                      widget.receiptData.errorMessage != null || _isSaving
                          ? []
                          : [
                              BoxShadow(
                                color: Constants.getPrimaryColor(context)
                                    .withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: widget.receiptData.errorMessage != null || _isSaving
                        ? null
                        : _saveAsTransaction,
                    borderRadius: BorderRadius.circular(
                        Constants.responsiveRadius(context, 16)),
                    child: _isSaving
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'جاري الحفظ...',
                                style: TextStyle(
                                  fontFamily: Constants.defaultFontFamily,
                                  fontSize:
                                      Constants.responsiveFontSize(context, 16),
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.save,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'حفظ كمعاملة',
                                style: TextStyle(
                                  fontFamily: Constants.defaultFontFamily,
                                  fontSize:
                                      Constants.responsiveFontSize(context, 16),
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
