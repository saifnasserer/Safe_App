import 'package:flutter/material.dart';
import 'package:safe/Constants.dart';

class UpdateNoteItem extends StatelessWidget {
  final String note;
  final IconData icon;

  const UpdateNoteItem({
    super.key,
    required this.note,
    this.icon = Icons.check_circle_outline,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        bottom: Constants.responsiveSpacing(context, 12),
      ),
      padding: EdgeInsets.all(Constants.responsiveSpacing(context, 12)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          Constants.responsiveSpacing(context, 12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: Constants.responsiveSpacing(context, 8),
            offset: Offset(0, Constants.responsiveSpacing(context, 2)),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Theme.of(context).primaryColor,
            size: Constants.responsiveSpacing(context, 20),
          ),
          SizedBox(width: Constants.responsiveSpacing(context, 12)),
          Expanded(
            child: Text(
              note,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                    fontSize: Constants.responsiveFontSize(context, 14),
                  ),
              textDirection: TextDirection.rtl,
            ),
          ),
        ],
      ),
    );
  }
}
