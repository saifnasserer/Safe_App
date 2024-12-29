import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:safe/Constants.dart';

class TransactionButtons extends StatelessWidget {
  final VoidCallback onExpense;
  final VoidCallback onIncome;

  const TransactionButtons({
    super.key,
    required this.onExpense,
    required this.onIncome,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Constants.responsiveSpacing(context, 20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              onExpense();
            },
            style: ElevatedButton.styleFrom(
              minimumSize: Size(
                Constants.widthPercent(context, 40),
                Constants.heightPercent(context, 6),
              ),
              backgroundColor: Colors.red.shade50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Constants.responsiveRadius(context, 16)),
              ),
            ),
            child: const Row(
              children: [
                Text(
                  'صرف',
                  style: TextStyle(
                    color: Colors.red,
                    fontFamily: Constants.defaultFontFamily,
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.remove_circle_outline, color: Colors.red),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              onIncome();
            },
            style: ElevatedButton.styleFrom(
              minimumSize: Size(
                Constants.widthPercent(context, 40),
                Constants.heightPercent(context, 6),
              ),
              backgroundColor: Colors.green.shade50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Constants.responsiveRadius(context, 16)),
              ),
            ),
            child: const Row(
              children: [
                Text(
                  'دخل',
                  style: TextStyle(
                    color: Colors.green,
                    fontFamily: Constants.defaultFontFamily,
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.add_circle_outline, color: Colors.green),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
