import 'package:flutter/material.dart';
import 'package:safe/Constants.dart';

class TransactionDateHeader extends StatelessWidget {
  final String date;
  final String Function(String) formatDate;

  const TransactionDateHeader({
    super.key,
    required this.date,
    required this.formatDate,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Constants.responsiveSpacing(context, 24),
        vertical: Constants.responsiveSpacing(context, 12),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Constants.responsiveSpacing(context, 16),
          vertical: Constants.responsiveSpacing(context, 8),
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B).withOpacity(0.04),
          borderRadius: BorderRadius.circular(Constants.responsiveRadius(context, 12)),
        ),
        child: Text(
          formatDate(date),
          style: TextStyle(
            fontSize: Constants.responsiveFontSize(context, 15),
            fontWeight: FontWeight.w600,
            fontFamily: Constants.defaultFontFamily,
            color: const Color(0xFF1E293B),
          ),
        ),
      ),
    );
  }
}
