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
        backgroundColor: Colors.white.withOpacity(0.15),
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(
          horizontal: Constants.responsiveSpacing(context, 20),
          vertical: Constants.responsiveSpacing(context, 12),
        ),
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(Constants.responsiveSpacing(context, 12)),
          side: BorderSide(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        elevation: 0,
        shadowColor: Colors.transparent,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.arrow_drop_down,
            color: Colors.white,
            size: Constants.responsiveFontSize(context, 20),
          ),
          SizedBox(width: Constants.responsiveSpacing(context, 4)),
          Text(
            _getFilterText(),
            style: TextStyle(
              fontSize: Constants.responsiveFontSize(context, 14),
              color: Colors.white,
              fontFamily: Constants.secondaryFontFamily,
              fontWeight: FontWeight.w500,
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
