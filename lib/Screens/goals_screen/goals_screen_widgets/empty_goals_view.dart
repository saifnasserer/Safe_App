import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:safe/Constants.dart';

class EmptyGoalsView extends StatelessWidget {
  final VoidCallback onAddGoal;
  final Color mainColor;

  const EmptyGoalsView({
    super.key,
    required this.onAddGoal,
    required this.mainColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LottieBuilder.asset(
            'assets/animation/Onion.json',
            height:
                Constants.heightPercent(context, 25), // 25% of screen height
          ),
          SizedBox(height: Constants.responsiveSpacing(context, 24)),
          Text(
            "معندكش اهدف",
            style: TextStyle(
              fontSize: Constants.responsiveFontSize(context, 20),
              fontWeight: FontWeight.w500,
              color: Colors.black87,
              fontFamily: Constants.secondaryFontFamily,
            ),
          ),
          SizedBox(height: Constants.responsiveSpacing(context, 16)),
          TextButton.icon(
            onPressed: onAddGoal,
            icon: Icon(
              Icons.add,
              size: Constants.responsiveSpacing(context, 24),
            ),
            label: Text(
              "ضيف هدف جديد",
              style: TextStyle(
                fontSize: Constants.responsiveFontSize(context, 16),
              ),
            ),
            style: TextButton.styleFrom(
              backgroundColor: mainColor.withOpacity(0.1),
              foregroundColor: mainColor,
              padding: EdgeInsets.symmetric(
                horizontal: Constants.responsiveSpacing(context, 20),
                vertical: Constants.responsiveSpacing(context, 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
