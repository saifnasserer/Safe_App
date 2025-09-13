import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safe/Constants.dart';
import 'package:safe/models/receipt_data.dart';
import 'package:safe/providers/receipt_provider.dart';
import 'package:safe/Screens/receipt_screen/receipt_preview_screen.dart';

class ReceiptListScreen extends StatefulWidget {
  const ReceiptListScreen({super.key});

  @override
  State<ReceiptListScreen> createState() => _ReceiptListScreenState();
}

class _ReceiptListScreenState extends State<ReceiptListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ReceiptProvider>(context, listen: false).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'الإيصالات الممسوحة',
          style: TextStyle(
            fontFamily: Constants.defaultFontFamily,
            color: Colors.white,
          ),
        ),
        backgroundColor: Constants.getPrimaryColor(context),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Consumer<ReceiptProvider>(
            builder: (context, receiptProvider, child) {
              if (receiptProvider.receipts.isNotEmpty) {
                return PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) async {
                    if (value == 'clear_all') {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text(
                            'حذف جميع الإيصالات',
                            style: TextStyle(
                                fontFamily: Constants.defaultFontFamily),
                          ),
                          content: const Text(
                            'هل أنت متأكد من حذف جميع الإيصالات؟ لا يمكن التراجع عن هذا الإجراء.',
                            style: TextStyle(
                                fontFamily: Constants.secondaryFontFamily),
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
                        await receiptProvider.clearAllReceipts();
                      }
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'clear_all',
                      child: Text(
                        'حذف جميع الإيصالات',
                        style: TextStyle(
                            fontFamily: Constants.secondaryFontFamily),
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<ReceiptProvider>(
        builder: (context, receiptProvider, child) {
          if (receiptProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (receiptProvider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[300],
                  ),
                  SizedBox(height: Constants.responsiveSpacing(context, 16)),
                  const Text(
                    'حدث خطأ',
                    style: TextStyle(
                      fontFamily: Constants.defaultFontFamily,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: Constants.responsiveSpacing(context, 8)),
                  Text(
                    receiptProvider.errorMessage!,
                    style: TextStyle(
                      fontFamily: Constants.secondaryFontFamily,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: Constants.responsiveSpacing(context, 16)),
                  ElevatedButton(
                    onPressed: () {
                      receiptProvider.initialize();
                    },
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          if (receiptProvider.receipts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: Constants.responsiveSpacing(context, 16)),
                  Text(
                    'لا توجد إيصالات',
                    style: TextStyle(
                      fontFamily: Constants.defaultFontFamily,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: Constants.responsiveSpacing(context, 8)),
                  Text(
                    'شارك صورة إيصال مع التطبيق لبدء المسح',
                    style: TextStyle(
                      fontFamily: Constants.secondaryFontFamily,
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(Constants.responsiveSpacing(context, 16)),
            itemCount: receiptProvider.receipts.length,
            itemBuilder: (context, index) {
              final receipt = receiptProvider.receipts[index];
              return _buildReceiptCard(context, receipt);
            },
          );
        },
      ),
    );
  }

  Widget _buildReceiptCard(BuildContext context, ReceiptData receipt) {
    return Card(
      elevation: 6,
      margin: EdgeInsets.only(bottom: Constants.responsiveSpacing(context, 12)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (context) => ReceiptPreviewScreen(receiptData: receipt),
            ),
          );

          if (result == true) {
            // Refresh the list if a transaction was saved
            setState(() {});
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(Constants.responsiveSpacing(context, 16)),
          child: Row(
            children: [
              // Receipt Image Thumbnail
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(receipt.imagePath),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.image_not_supported,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                ),
              ),

              SizedBox(width: Constants.responsiveSpacing(context, 16)),

              // Receipt Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      receipt.title ?? 'إيصال غير محدد',
                      style: const TextStyle(
                        fontFamily: Constants.defaultFontFamily,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: Constants.responsiveSpacing(context, 4)),

                    // Amount
                    if (receipt.amount != null)
                      Text(
                        receipt.formattedAmount,
                        style: TextStyle(
                          fontFamily: Constants.secondaryFontFamily,
                          fontSize: 14,
                          color: Colors.green[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                    SizedBox(height: Constants.responsiveSpacing(context, 4)),

                    // Date
                    Text(
                      receipt.formattedDate,
                      style: TextStyle(
                        fontFamily: Constants.secondaryFontFamily,
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),

                    SizedBox(height: Constants.responsiveSpacing(context, 4)),

                    // Status and Confidence
                    Row(
                      children: [
                        // Status indicator
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: Constants.responsiveSpacing(context, 8),
                            vertical: Constants.responsiveSpacing(context, 2),
                          ),
                          decoration: BoxDecoration(
                            color: receipt.errorMessage != null
                                ? Colors.red[100]
                                : receipt.isValidForTransaction
                                    ? Colors.green[100]
                                    : receipt.isProcessed
                                        ? Colors.orange[100]
                                        : Colors.red[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            receipt.errorMessage != null
                                ? 'خطأ'
                                : receipt.isValidForTransaction
                                    ? 'جاهز للحفظ'
                                    : receipt.isProcessed
                                        ? 'معالج'
                                        : 'غير معالج',
                            style: TextStyle(
                              fontFamily: Constants.secondaryFontFamily,
                              fontSize: 10,
                              color: receipt.errorMessage != null
                                  ? Colors.red[700]
                                  : receipt.isValidForTransaction
                                      ? Colors.green[700]
                                      : receipt.isProcessed
                                          ? Colors.orange[700]
                                          : Colors.red[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        SizedBox(
                            width: Constants.responsiveSpacing(context, 8)),

                        // Confidence score
                        if (receipt.confidenceScore > 0)
                          Row(
                            children: [
                              Icon(
                                Icons.analytics_outlined,
                                size: 12,
                                color: receipt.confidenceScore > 0.7
                                    ? Colors.green
                                    : receipt.confidenceScore > 0.4
                                        ? Colors.orange
                                        : Colors.red,
                              ),
                              SizedBox(
                                  width:
                                      Constants.responsiveSpacing(context, 2)),
                              Text(
                                '${(receipt.confidenceScore * 100).toStringAsFixed(0)}%',
                                style: TextStyle(
                                  fontFamily: Constants.secondaryFontFamily,
                                  fontSize: 10,
                                  color: receipt.confidenceScore > 0.7
                                      ? Colors.green
                                      : receipt.confidenceScore > 0.4
                                          ? Colors.orange
                                          : Colors.red,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Arrow icon
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
