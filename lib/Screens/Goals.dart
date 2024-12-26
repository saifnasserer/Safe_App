import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:safe/Blocks/Goal.dart';
import 'package:safe/Constants.dart';
import 'package:safe/widgets/goals_screen_widgets/Goal_Provider.dart';
import 'package:safe/widgets/goals_screen_widgets/dialogs/add_goal_dialog.dart';
import 'package:safe/widgets/goals_screen_widgets/dialogs/edit_goal_dialog.dart';
import 'package:safe/widgets/goals_screen_widgets/empty_goals_view.dart';
import 'package:safe/widgets/goals_screen_widgets/goal_item_widget.dart';

class GoalsBlock extends StatefulWidget {
  const GoalsBlock({super.key});
  static String goalsID = 'this is goalsScreen ID';
  @override
  _GoalsBlockState createState() => _GoalsBlockState();
}

class _GoalsBlockState extends State<GoalsBlock> {
  Color mainColor = const Color(0xFF4459c8);

  void _showAddGoalDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => const AddGoalDialog(),
    );
  }

  void _showEditGoalDialog(Goal goal, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) => EditGoalDialog(
        goal: goal,
        index: index,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final goals = Provider.of<GoalProvider>(context).goals;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: goals.isEmpty
                ? EmptyGoalsView(
                    onAddGoal: _showAddGoalDialog,
                    mainColor: mainColor,
                  )
                : _buildGoalsList(goals),
          ),
        ],
      ),
      floatingActionButton: goals.isNotEmpty
          ? FloatingActionButton(
              onPressed: _showAddGoalDialog,
              elevation: 2,
              backgroundColor: mainColor,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  PreferredSizeWidget _buildAppBar() {
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
        'اهدافك',
        style: TextStyle(
          color: Constants.getPrimaryColor(context),
          fontFamily: Constants.defaultFontFamily,
          fontSize: 30,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildGoalsList(List<Goal> goals) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: goals.length,
      itemBuilder: (context, index) {
        final goal = goals[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  _showEditGoalDialog(goal, index);
                },
                child: GoalItemWidget(
                  title: goal.title,
                  targetAmount: goal.targetAmount,
                  savedAmount: goal.currentAmount,
                  color: goal.color,
                  type: goal.type,
                  onDismissed: () {
                    Provider.of<GoalProvider>(context, listen: false)
                        .removeGoal(index);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Center(child: Text("تم حذف ${goal.title}")),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: mainColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        margin: const EdgeInsets.all(16),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
