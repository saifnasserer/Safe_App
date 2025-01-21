import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:safe/providers/Goal_Provider.dart';
import 'package:safe/utils/FirstUse.dart';
import 'package:safe/widgets/Goal.dart';
import 'package:safe/Constants.dart';
import 'package:safe/Screens/goals_screen/goals_screen_widgets/dialogs/add_goal_dialog.dart';
import 'package:safe/Screens/goals_screen/goals_screen_widgets/dialogs/edit_goal_dialog.dart';
import 'package:safe/Screens/goals_screen/goals_screen_widgets/empty_goals_view.dart';
import 'package:safe/Screens/goals_screen/goals_screen_widgets/goal_item_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GoalsBlock extends StatefulWidget {
  const GoalsBlock({super.key});
  static String goalsID = 'this is goalsScreen ID';
  @override
  _GoalsBlockState createState() => _GoalsBlockState();
}

class _GoalsBlockState extends State<GoalsBlock> {
  final _appTutorial = AppTutorial();

  @override
  void initState() {
    super.initState();
    _checkFirstUse();
  }

  Future<void> _checkFirstUse() async {
    final isFirstUse = await _appTutorial.isGoalsFirstUse();
    final goals = Provider.of<GoalProvider>(context, listen: false).goals;

    if (mounted && goals.isNotEmpty && isFirstUse) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showNote(
            "عشان تحذف الهدف شدة ناحية الشمال وانت ضاغط علية \n عشان تحدثه اضغط علي الهدف",
            duration: 5);
      });
      await _appTutorial.markGoalsFirstUseComplete();
    }
  }

  void _showNote(String message, {int duration = 5}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: Constants.defaultFontFamily,
              fontSize: 16,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        backgroundColor: Constants.getPrimaryColor(context),
        duration: Duration(seconds: duration),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(10),
      ),
    );
  }

  void _showAddGoalDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => const AddGoalDialog(),
    ).then((_) async {
      final goals = Provider.of<GoalProvider>(context, listen: false).goals;
      final isFirstUse = await _appTutorial.isGoalsFirstUse();
      if (goals.isNotEmpty && isFirstUse) {
        _showNote(
            "عشان تحذف الهدف شدة ناحية الشمال وانت ضاغط علية \n عشان تحدثه اضغط علي الهدف",
            duration: 5);
        await _appTutorial.markGoalsFirstUseComplete();
      }
    });
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
    return Consumer<GoalProvider>(
      builder: (context, goalProvider, _) {
        final goals = goalProvider.goals;

        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: _buildAppBar(),
          body: Column(
            children: [
              Expanded(
                child: goals.isEmpty
                    ? EmptyGoalsView(
                        onAddGoal: _showAddGoalDialog,
                        mainColor: Constants.getPrimaryColor(context),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: Constants.defaultFontSize,
                            vertical: Constants.defaultFontSize / 2),
                        itemCount: goals.length,
                        itemBuilder: (context, index) {
                          final goal = goals[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: Constants.defaultFontSize / 2),
                            child: Center(
                              child: SizedBox(
                                width: Constants.widthPercent(context, 90),
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
                                    onDismissed: () {
                                      Provider.of<GoalProvider>(context,
                                              listen: false)
                                          .removeGoal(index);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Center(
                                              child:
                                                  Text("تم حذف ${goal.title}")),
                                          behavior: SnackBarBehavior.floating,
                                          backgroundColor:
                                              Constants.getPrimaryColor(
                                                  context),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                Constants.defaultFontSize *
                                                    0.625),
                                          ),
                                          margin: const EdgeInsets.all(
                                              Constants.defaultFontSize),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
          floatingActionButton: goals.isNotEmpty
              ? FloatingActionButton(
                  onPressed: _showAddGoalDialog,
                  elevation: 2,
                  backgroundColor: Constants.getPrimaryColor(context),
                  child: const Icon(Icons.add, color: Colors.white),
                )
              : null,
        );
      },
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
          fontSize: Constants.defaultFontSize * 1.875,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
    );
  }
}
