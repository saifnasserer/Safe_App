import 'package:flutter/material.dart';
import 'package:safe/Constants.dart';
import 'package:safe/utils/transaction_filter.dart';

class ReceiptAppBar extends StatelessWidget implements PreferredSizeWidget {
  final TransactionType currentFilter;
  final VoidCallback onFilterTap;

  const ReceiptAppBar({
    super.key,
    required this.currentFilter,
    required this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new,
          color: Constants.getPrimaryColor(context),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'مصاريفك',
        style: TextStyle(
          color: Constants.getPrimaryColor(context),
          fontFamily: Constants.defaultFontFamily,
          fontSize: Constants.responsiveFontSize(context, 30),
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Constants.responsiveSpacing(context, 20),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Constants.getPrimaryColor(context).withOpacity(0.1),
              borderRadius: BorderRadius.circular(
                  Constants.responsiveRadius(context, 16)),
            ),
            child: TextButton.icon(
              onPressed: onFilterTap,
              icon: Icon(
                Icons.filter_list,
                color: Constants.getPrimaryColor(context),
                size: Constants.responsiveFontSize(context, 20),
              ),
              label: Text(
                TransactionFilterHelper.getFilterName(currentFilter),
                style: TextStyle(
                  color: Constants.getPrimaryColor(context),
                  fontFamily: Constants.secondaryFontFamily,
                  fontSize: Constants.responsiveFontSize(context, 14),
                ),
              ),
            ),
          ),
        ),
      ],
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
