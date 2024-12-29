import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:safe/Constants.dart';
import 'package:safe/Screens/Goals.dart';

class AddGoalButton extends StatelessWidget {
  const AddGoalButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: Constants.responsiveSpacing(context, 20),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Constants.getPrimaryColor(context).withOpacity(0.1),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Constants.responsiveRadius(context, 16)),
            side: BorderSide(
              color: Constants.getPrimaryColor(context),
              width: 2,
            ),
          ),
          minimumSize: Size(
            Constants.widthPercent(context, 90),
            Constants.heightPercent(context, 13),
          ),
        ),
        onPressed: () {
          HapticFeedback.mediumImpact();
          Navigator.pushNamed(context, GoalsBlock.goalsID);
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline,
              color: Constants.getPrimaryColor(context),
              size: Constants.responsiveFontSize(context, 32),
            ),
            SizedBox(height: Constants.responsiveSpacing(context, 8)),
            Text(
              'اضف هدف جديد',
              style: TextStyle(
                color: Constants.getPrimaryColor(context),
                fontFamily: Constants.defaultFontFamily,
                fontSize: Constants.responsiveFontSize(context, 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
