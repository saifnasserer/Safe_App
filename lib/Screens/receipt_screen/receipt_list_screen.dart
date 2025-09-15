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
    // Removed automatic initialization to prevent unwanted receipt processing
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
            'الإيصالات',
            style: TextStyle(
              fontFamily: Constants.defaultFontFamily,
              color: Constants.defaultPrimaryColor,
            ),
          ),
          backgroundColor: Colors.white,
          foregroundColor: Constants.defaultPrimaryColor,
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
              return Center(
                child: Container(
                  padding:
                      EdgeInsets.all(Constants.responsiveSpacing(context, 30)),
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
                        'جاري معالجة الإيصالات...',
                        style: TextStyle(
                          fontFamily: Constants.defaultFontFamily,
                          fontSize: Constants.responsiveFontSize(context, 18),
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: Constants.responsiveSpacing(context, 8)),
                      Text(
                        'يتم استخدام الذكاء الاصطناعي لتحليل الإيصالات',
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
      ),
    );
  }

  Widget _buildReceiptCard(BuildContext context, ReceiptData receipt) {
    return Container(
      margin: EdgeInsets.only(bottom: Constants.responsiveSpacing(context, 16)),
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(Constants.responsiveRadius(context, 20)),
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
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            final result = await Navigator.push<bool>(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ReceiptPreviewScreen(receiptData: receipt),
              ),
            );

            if (result == true) {
              // Refresh the list if a transaction was saved
              setState(() {});
            }
          },
          borderRadius:
              BorderRadius.circular(Constants.responsiveRadius(context, 20)),
          child: Padding(
            padding: EdgeInsets.all(Constants.responsiveSpacing(context, 20)),
            child: Row(
              children: [
                // Receipt Image Thumbnail (on the right for RTL)
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                        Constants.responsiveRadius(context, 16)),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Constants.getPrimaryColor(context).withOpacity(0.1),
                        Constants.getPrimaryColor(context).withOpacity(0.05),
                      ],
                    ),
                    border: Border.all(
                      color:
                          Constants.getPrimaryColor(context).withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                        Constants.responsiveRadius(context, 14)),
                    child: Image.file(
                      File(receipt.imagePath),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
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
                          child: Icon(
                            Icons.image_not_supported,
                            color: Constants.getPrimaryColor(context)
                                .withOpacity(0.5),
                            size: 30,
                          ),
                        );
                      },
                    ),
                  ),
                ),

                SizedBox(width: Constants.responsiveSpacing(context, 20)),

                // Receipt Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        receipt.title ?? 'إيصال غير محدد',
                        style: TextStyle(
                          fontFamily: Constants.defaultFontFamily,
                          fontSize: Constants.responsiveFontSize(context, 16),
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      SizedBox(height: Constants.responsiveSpacing(context, 8)),

                      // Amount
                      if (receipt.amount != null)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: Constants.responsiveSpacing(context, 8),
                            vertical: Constants.responsiveSpacing(context, 4),
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.green.withOpacity(0.1),
                                Colors.green.withOpacity(0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(
                                Constants.responsiveRadius(context, 8)),
                          ),
                          child: Text(
                            receipt.formattedAmount,
                            style: TextStyle(
                              fontFamily: Constants.defaultFontFamily,
                              fontSize:
                                  Constants.responsiveFontSize(context, 14),
                              color: Colors.green[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                      SizedBox(height: Constants.responsiveSpacing(context, 8)),

                      // Date
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: Colors.grey[500],
                          ),
                          SizedBox(
                              width: Constants.responsiveSpacing(context, 4)),
                          Text(
                            receipt.formattedDate,
                            style: TextStyle(
                              fontFamily: Constants.secondaryFontFamily,
                              fontSize:
                                  Constants.responsiveFontSize(context, 12),
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: Constants.responsiveSpacing(context, 8)),

                      // Status and Processing Method
                      Row(
                        children: [
                          // Status indicator
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal:
                                  Constants.responsiveSpacing(context, 10),
                              vertical: Constants.responsiveSpacing(context, 4),
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: receipt.errorMessage != null
                                    ? [
                                        Colors.red.withOpacity(0.1),
                                        Colors.red.withOpacity(0.05)
                                      ]
                                    : receipt.isValidForTransaction
                                        ? [
                                            Colors.green.withOpacity(0.1),
                                            Colors.green.withOpacity(0.05)
                                          ]
                                        : receipt.isProcessed
                                            ? [
                                                Colors.orange.withOpacity(0.1),
                                                Colors.orange.withOpacity(0.05)
                                              ]
                                            : [
                                                Colors.red.withOpacity(0.1),
                                                Colors.red.withOpacity(0.05)
                                              ],
                              ),
                              borderRadius: BorderRadius.circular(
                                  Constants.responsiveRadius(context, 12)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  receipt.errorMessage != null
                                      ? Icons.error_outline
                                      : receipt.isValidForTransaction
                                          ? Icons.check_circle_outline
                                          : receipt.isProcessed
                                              ? Icons.hourglass_empty
                                              : Icons.pending,
                                  size: 12,
                                  color: receipt.errorMessage != null
                                      ? Colors.red[700]
                                      : receipt.isValidForTransaction
                                          ? Colors.green[700]
                                          : receipt.isProcessed
                                              ? Colors.orange[700]
                                              : Colors.red[700],
                                ),
                                SizedBox(
                                    width: Constants.responsiveSpacing(
                                        context, 4)),
                                Text(
                                  receipt.errorMessage != null
                                      ? 'خطأ'
                                      : receipt.isValidForTransaction
                                          ? 'جاهز للحفظ'
                                          : receipt.isProcessed
                                              ? 'معالج'
                                              : 'غير معالج',
                                  style: TextStyle(
                                    fontFamily: Constants.secondaryFontFamily,
                                    fontSize: Constants.responsiveFontSize(
                                        context, 10),
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
                              ],
                            ),
                          ),

                          SizedBox(
                              width: Constants.responsiveSpacing(context, 8)),

                          // Processing method indicator
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal:
                                  Constants.responsiveSpacing(context, 8),
                              vertical: Constants.responsiveSpacing(context, 4),
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: receipt.sourceApp != null &&
                                        receipt.sourceApp!.isNotEmpty
                                    ? [
                                        Colors.blue.withOpacity(0.1),
                                        Colors.blue.withOpacity(0.05)
                                      ]
                                    : [
                                        Colors.purple.withOpacity(0.1),
                                        Colors.purple.withOpacity(0.05)
                                      ],
                              ),
                              borderRadius: BorderRadius.circular(
                                  Constants.responsiveRadius(context, 10)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  receipt.sourceApp != null &&
                                          receipt.sourceApp!.isNotEmpty
                                      ? Icons.smart_toy // AI processing
                                      : Icons.computer, // Local processing
                                  size: 12,
                                  color: receipt.sourceApp != null &&
                                          receipt.sourceApp!.isNotEmpty
                                      ? Colors.blue[700]
                                      : Colors.purple[700],
                                ),
                                SizedBox(
                                    width: Constants.responsiveSpacing(
                                        context, 4)),
                                Text(
                                  receipt.sourceApp != null &&
                                          receipt.sourceApp!.isNotEmpty
                                      ? 'ذكي'
                                      : 'محلي',
                                  style: TextStyle(
                                    fontFamily: Constants.secondaryFontFamily,
                                    fontSize: Constants.responsiveFontSize(
                                        context, 9),
                                    color: receipt.sourceApp != null &&
                                            receipt.sourceApp!.isNotEmpty
                                        ? Colors.blue[700]
                                        : Colors.purple[700],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Arrow icon
                Container(
                  padding:
                      EdgeInsets.all(Constants.responsiveSpacing(context, 8)),
                  decoration: BoxDecoration(
                    color: Constants.getPrimaryColor(context).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(
                        Constants.responsiveRadius(context, 8)),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Constants.getPrimaryColor(context),
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
