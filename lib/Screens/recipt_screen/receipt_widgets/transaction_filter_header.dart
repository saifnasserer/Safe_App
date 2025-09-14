import 'package:flutter/material.dart';
import 'package:safe/Constants.dart';
import 'package:safe/utils/transaction_filter.dart';

class TransactionFilterHeader extends StatelessWidget {
  final List<dynamic> items;
  final TransactionType filterType;
  final VoidCallback? onFilterTap;

  const TransactionFilterHeader({
    super.key,
    required this.items,
    required this.filterType,
    this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onFilterTap,
      child: Padding(
        padding: EdgeInsets.all(Constants.responsiveSpacing(context, 16)),
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: Constants.responsiveSpacing(context, 12),
            horizontal: Constants.responsiveSpacing(context, 24),
          ),
          decoration: BoxDecoration(
            color: filterType == TransactionType.expenses
                ? const Color(0xFFEF4444)
                : const Color(0xFF10B981),
            borderRadius: BorderRadius.circular(Constants.responsiveRadius(context, 12)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${TransactionFilterHelper.calculateTotal(items, filterType)}',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: Constants.defaultFontFamily,
                  fontSize: Constants.responsiveFontSize(context, 18),
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.right,
              ),
              Text(
                filterType == TransactionType.expenses
                    ? ':اجمالي المصروفات '
                    : ':اجمالي الدخل ',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: Constants.secondaryFontFamily,
                  fontSize: Constants.responsiveFontSize(context, 16),
                ),
                textAlign: TextAlign.right,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
