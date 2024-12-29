import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:safe/Constants.dart';
import 'package:safe/utils/date_filter.dart';

class SpentFilterSection extends StatelessWidget {
  final DateFilter currentFilter;
  final Function() onFilterTap;

  const SpentFilterSection({
    super.key,
    required this.currentFilter,
    required this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        onFilterTap();
        HapticFeedback.mediumImpact();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        padding: EdgeInsets.symmetric(
          horizontal: Constants.responsiveSpacing(context, 16),
          vertical: Constants.responsiveSpacing(context, 8),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.arrow_drop_down,
            color: Color(0xff4558c8),
          ),
          Text(
            _getFilterText(),
            style: TextStyle(
              fontSize: Constants.responsiveFontSize(context, 14),
              color: Constants.getPrimaryColor(context),
              fontFamily: Constants.secondaryFontFamily,
            ),
          ),
        ],
      ),
    );
  }

  String _getFilterText() {
    switch (currentFilter) {
      case DateFilter.today:
        return 'النهاردة';
      case DateFilter.lastWeek:
        return 'الاسبوع اللي فات';
      case DateFilter.lastMonth:
        return 'الشهر اللي فات';
      case DateFilter.custom:
        return 'تاريخ معين';
    }
  }
}
