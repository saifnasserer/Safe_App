import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:safe/Constants.dart';
import 'package:safe/utils/number_formatter.dart';

class TransactionItemCard extends StatelessWidget {
  final dynamic item;
  final Function(dynamic) onDelete;

  const TransactionItemCard({
    super.key,
    required this.item,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = item.flag;
    final statusColor = isIncome
        ? const Color(0xFF10B981)
        : const Color(0xFFEF4444);

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: Constants.responsiveSpacing(context, 16),
        vertical: Constants.responsiveSpacing(context, 6),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Constants.responsiveRadius(context, 16)),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(Constants.responsiveSpacing(context, 12)),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: Constants.responsiveSpacing(context, 8),
                  ),
                  child: Text(
                    NumberFormatter.formatCurrency(item.price),
                    style: TextStyle(
                      fontFamily: Constants.defaultFontFamily,
                      fontSize: Constants.responsiveFontSize(context, 17),
                      color: statusColor,
                    ),
                  ),
                ),
                SizedBox(height: Constants.responsiveSpacing(context, 6)),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.heavyImpact();
                    onDelete(item);
                  },
                  child: Icon(
                    Icons.delete_outline_rounded,
                    color: statusColor,
                    size: Constants.responsiveFontSize(context, 20),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      fontFamily: Constants.defaultFontFamily,
                      fontSize: Constants.responsiveFontSize(context, 16),
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  SizedBox(height: Constants.responsiveSpacing(context, 4)),
                  Text(
                    DateFormat('hh:mm a').format(item.dateTime),
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: Constants.responsiveFontSize(context, 13),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: Constants.responsiveSpacing(context, 16)),
            Container(
              height: Constants.heightPercent(context, 5),
              width: Constants.widthPercent(context, 10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: statusColor.withOpacity(.08),
              ),
              child: Icon(
                isIncome
                    ? Icons.arrow_upward_rounded
                    : Icons.arrow_downward_rounded,
                color: statusColor,
                size: Constants.responsiveFontSize(context, 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
