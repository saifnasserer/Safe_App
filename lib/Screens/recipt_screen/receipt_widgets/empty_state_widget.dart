import 'package:flutter/material.dart';
import 'package:safe/Constants.dart';

class EmptyStateWidget extends StatelessWidget {
  final VoidCallback onAddTransaction;
  final GlobalKey? tutorialKey;

  const EmptyStateWidget({
    super.key,
    required this.onAddTransaction,
    this.tutorialKey,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: Constants.widthPercent(context, 30),
            height: Constants.widthPercent(context, 30),
            decoration: BoxDecoration(
              color: Constants.getPrimaryColor(context).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.receipt_long_rounded,
              size: Constants.responsiveFontSize(context, 60),
              color: Constants.getPrimaryColor(context),
            ),
          ),
          SizedBox(height: Constants.responsiveSpacing(context, 24)),
          Text(
            'لا يوجد معاملات',
            style: TextStyle(
              color: Constants.getPrimaryColor(context),
              fontSize: Constants.responsiveFontSize(context, 24),
              fontFamily: Constants.secondaryFontFamily,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: Constants.responsiveSpacing(context, 12)),
          Text(
            'اضغط على الزار ده عشان تضيف معاملة جديدة',
            style: TextStyle(
              color: Colors.grey,
              fontSize: Constants.responsiveFontSize(context, 16),
              fontFamily: Constants.secondaryFontFamily,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: Constants.responsiveSpacing(context, 24)),
          Container(
            key: tutorialKey,
            margin: EdgeInsets.symmetric(
              horizontal: Constants.responsiveSpacing(context, 16),
            ),
            child: ElevatedButton(
              onPressed: onAddTransaction,
              style: ElevatedButton.styleFrom(
                backgroundColor: Constants.getPrimaryColor(context),
                padding: EdgeInsets.symmetric(
                  horizontal: Constants.responsiveSpacing(context, 24),
                  vertical: Constants.responsiveSpacing(context, 12),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Constants.responsiveRadius(context, 12)),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.add,
                    color: Colors.white,
                    size: Constants.responsiveFontSize(context, 24),
                  ),
                  SizedBox(width: Constants.responsiveSpacing(context, 8)),
                  Text(
                    'اضافة معاملة',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: Constants.responsiveFontSize(context, 16),
                      fontFamily: Constants.secondaryFontFamily,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
