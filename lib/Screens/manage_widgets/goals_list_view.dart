import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:safe/Constants.dart';
import 'package:safe/Screens/Goals.dart';
import 'package:safe/widgets/goals_screen_widgets/goal_item_widget.dart';
import 'package:safe/Blocks/Goal.dart';

class GoalsListView extends StatelessWidget {
  final List<Goal> goals;
  final Function(int) onGoalRemoved;

  const GoalsListView({
    super.key,
    required this.goals,
    required this.onGoalRemoved,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Constants.heightPercent(context, 13),
      child: ListView.builder(
        padding: EdgeInsets.symmetric(
          horizontal: Constants.responsiveSpacing(context, 20),
        ),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: goals.length,
        itemBuilder: (context, index) {
          final goal = goals[index];
          return Container(
            width: Constants.widthPercent(context, 90),
            margin: EdgeInsets.only(
              right: Constants.responsiveSpacing(context, 20),
            ),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                Navigator.pushNamed(context, GoalsBlock.goalsID);
              },
              child: GoalItemWidget(
                savedAmount: goal.currentAmount,
                title: goal.title,
                targetAmount: goal.targetAmount,
                color: goal.color,
                type: goal.type,
                onDismissed: () {
                  HapticFeedback.heavyImpact();
                  onGoalRemoved(index);
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
