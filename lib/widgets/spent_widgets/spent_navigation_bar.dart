import 'package:flutter/material.dart';
import 'package:safe/Constants.dart';
import 'package:safe/Screens/EmptyReciet.dart';
import 'package:safe/Screens/Goals.dart';
import 'package:safe/screens/Manage.dart';
import 'package:safe/widgets/navigation.dart';

class SpentNavigationBar extends StatelessWidget {
  final double containerHeight;

  const SpentNavigationBar({
    super.key,
    required this.containerHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        bottom: Constants.responsiveSpacing(context, 10),
        top: Constants.responsiveSpacing(context, 10),
      ),
      decoration: BoxDecoration(
        color: const Color(0xff1c1c1c),
        borderRadius: BorderRadius.all(
            Radius.circular(Constants.responsiveRadius(context, 40))),
      ),
      height: Constants.heightPercent(context, 7),
      width: Constants.screenWidth(context) * 0.5,
      child: Row(
        children: [
          const Spacer(flex: 1),
          Screen(
            buttonIcon: Icons.add_circle_outline_rounded,
            screenName: const Manage(),
            size: Constants.responsiveSpacing(context, 32),
          ),
          const Spacer(flex: 1),
          Screen(
            buttonIcon: Icons.task_alt_rounded,
            screenName: const GoalsBlock(),
            size: Constants.responsiveSpacing(context, 32),
          ),
          const Spacer(flex: 1),
          Screen(
            buttonIcon: Icons.receipt_long_rounded,
            screenName: const Reciept(),
            size: Constants.responsiveSpacing(context, 32),
          ),
          const Spacer(flex: 1),
        ],
      ),
    );
  }
}
