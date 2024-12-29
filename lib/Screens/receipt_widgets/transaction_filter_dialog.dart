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
      title: const Text(
        'اختر نوع المعاملات',
        style: TextStyle(
          fontFamily: Constants.defaultFontFamily,
          color: Color(0xff4558c8),
        ),
        textAlign: TextAlign.center,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: TransactionType.values
            .map((type) => ListTile(
                  title: Text(
                    TransactionFilterHelper.getFilterName(type),
                    style: const TextStyle(
                      fontFamily: Constants.secondaryFontFamily,
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
    );
  }
}
