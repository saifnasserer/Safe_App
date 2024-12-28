import 'package:flutter/material.dart';
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
        bottom: containerHeight * 0.05,
        top: containerHeight * 0.1,
      ),
      decoration: const BoxDecoration(
        color: Color(0xff1c1c1c),
        borderRadius: BorderRadius.all(Radius.circular(40)),
      ),
      height: containerHeight * 0.12,
      width: containerHeight * 0.5,
      child: Row(
        children: [
          const Spacer(flex: 1),
          Screen(
            buttonIcon: Icons.add_circle_outline_rounded,
            screenName: const Manage(),
            size: containerHeight * 0.08,
          ),
          const Spacer(flex: 1),
          Screen(
            buttonIcon: Icons.task_alt_rounded,
            screenName: const GoalsBlock(),
            size: containerHeight * 0.08,
          ),
          const Spacer(flex: 1),
          Screen(
            buttonIcon: Icons.receipt_long_rounded,
            screenName: const Reciept(),
            size: containerHeight * 0.08,
          ),
          const Spacer(flex: 1),
        ],
      ),
    );
  }
}
