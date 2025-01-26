import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:safe/Constants.dart';
import 'package:safe/utils/transaction_filter.dart';

class TransactionFilterDialog extends StatelessWidget {
  final TransactionType currentFilter;
  final Function(TransactionType) onFilterSelected;

  const TransactionFilterDialog({
    super.key,
    required this.currentFilter,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'اختر نوع المعاملات',
        style: TextStyle(
          fontFamily: Constants.defaultFontFamily,
          fontSize: Constants.responsiveFontSize(context, 18),
          color: const Color(0xff4558c8),
        ),
        textAlign: TextAlign.center,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: TransactionType.values
            .map((type) => ListTile(
                  title: Text(
                    TransactionFilterHelper.getFilterName(type),
                    style: TextStyle(
                      fontFamily: Constants.secondaryFontFamily,
                      fontSize: Constants.responsiveFontSize(context, 16),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    onFilterSelected(type);
                  },
                ))
            .toList(),
      ),
      contentPadding: EdgeInsets.all(Constants.responsiveSpacing(context, 16)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Constants.responsiveRadius(context, 12)),
      ),
    );
  }
}
