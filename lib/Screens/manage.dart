import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:safe/Constants.dart';
import 'package:safe/Screens/Goals.dart' show GoalItem, GoalsBlock;
import 'package:safe/widgets/Goal_Provider.dart';
import 'package:safe/widgets/Item_Provider.dart';
import 'package:safe/widgets/item.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

class Manage extends StatefulWidget {
  const Manage({super.key});
  static const String id = 'manageID';
  @override
  State<Manage> createState() => _ManageState();
}

class _ManageState extends State<Manage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final AudioPlayer audioPlayer = AudioPlayer();

  double getAmount() {
    if (amountController.text.isNotEmpty) {
      return double.parse(amountController.text);
    } else {
      return 0;
    }
  }

  String getTitle() {
    if (titleController.text.isNotEmpty) {
      return titleController.text;
    } else {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    // final GoalsList = Provider.of<GoalProvider>(context).getGoals;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Constants.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Constants.primaryColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'إضافة معاملة جديدة',
          style: TextStyle(
            color: Constants.primaryColor,
            fontFamily: Constants.titles,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: GestureDetector(
        onTap: () {
          // Dismiss keyboard when tapping outside
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Goals Section at the top
              Container(
                height: 160,
                margin: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Center(
                        child: Text(
                          textAlign: TextAlign.center,
                          'أهدافك',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: Constants.defaultFontFamily,
                            color: Constants.primaryColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: Consumer<GoalProvider>(
                        builder: (context, goalProvider, _) {
                          final goals = goalProvider.goals;
                          if (goals.isEmpty) {
                            return _buildAddNewGoalButton(context);
                          }
                          return ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            itemCount: goals.length,
                            itemBuilder: (context, index) {
                              final goal = goals[index];
                              return Container(
                                width: MediaQuery.of(context).size.width - 48,
                                margin: const EdgeInsets.only(right: 16),
                                child: GestureDetector(
                                  onTap: () {
                                    HapticFeedback.mediumImpact();
                                    Navigator.pushNamed(
                                        context, GoalsBlock.goalsID);
                                  },
                                  child: GoalItem(
                                    savedAmount: goal.currentAmount,
                                    title: goal.title,
                                    targetAmount: goal.targetAmount,
                                    color: goal.color,
                                    onDismissed: () {
                                      HapticFeedback.heavyImpact();
                                      goalProvider.removeGoal(index);
                                      if (goalProvider.goals.isEmpty) {
                                        setState(() {
                                          _buildAddNewGoalButton(context);
                                        });
                                      }
                                    },
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Main Content
              Container(
                margin: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Constants.primaryColor,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Description TextField
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Constants.primaryColor,
                              width: 1,
                            ),
                          ),
                        ),
                        child: TextField(
                          textAlign: TextAlign.center,
                          controller: titleController,
                          style: const TextStyle(
                            fontSize: 30,
                            fontFamily: Constants.defaultFontFamily,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'وصف المعاملة',
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontFamily: Constants.defaultFontFamily,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      // Amount TextField
                      Container(
                        padding: EdgeInsets.all(screenWidth * 0.04),
                        child: TextField(
                          controller: amountController,
                          keyboardType: const TextInputType.numberWithOptions(
                              signed: false, decimal: true),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: screenWidth * 0.06,
                            fontFamily: Constants.defaultFontFamily,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            hintText: '0.00',
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: screenWidth * 0.08,
                              fontFamily: Constants.defaultFontFamily,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Action Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: MaterialButton(
                        onPressed: () async {
                          if (titleController.text.isNotEmpty &&
                              amountController.text.isNotEmpty) {
                            HapticFeedback.mediumImpact();
                            Provider.of<ItemProvider>(context, listen: false)
                                .addItem(
                              item(
                                title: titleController.text,
                                price: getAmount(),
                                flag: false,
                                dateTime: DateTime.now(),
                              ),
                            );
                            audioPlayer.play(AssetSource('SFX/moneyAdd.mp3'));
                            amountController.clear();
                            titleController.clear();
                            showSimpleNotification(
                              const Text(
                                'تم إضافة المصروف بنجاح',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: Constants.defaultFontFamily,
                                ),
                              ),
                              background: Colors.green,
                              duration: const Duration(seconds: 1),
                            );
                          } else {
                            HapticFeedback.heavyImpact();
                            showSimpleNotification(
                              const Center(
                                child: Text(
                                  'ضيف البيانات الناقصة',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: Constants.defaultFontFamily,
                                  ),
                                ),
                              ),
                              background: Colors.red,
                              duration: const Duration(seconds: 1),
                            );
                          }
                        },
                        height: 56,
                        color: Colors.red.shade50,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.remove_circle_outline,
                              color: Colors.red.shade400,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'صرف',
                              style: TextStyle(
                                color: Colors.red.shade400,
                                fontFamily: Constants.defaultFontFamily,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: MaterialButton(
                        onPressed: () async {
                          if (titleController.text.isNotEmpty &&
                              amountController.text.isNotEmpty) {
                            HapticFeedback.mediumImpact();
                            Provider.of<ItemProvider>(context, listen: false)
                                .addItem(
                              item(
                                title: titleController.text,
                                price: getAmount(),
                                flag: true,
                                dateTime: DateTime.now(),
                              ),
                            );
                            audioPlayer.play(AssetSource('SFX/moneyAdd.mp3'));
                            amountController.clear();
                            titleController.clear();
                            showSimpleNotification(
                              const Text(
                                'تم إضافة الدخل بنجاح',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: Constants.defaultFontFamily,
                                ),
                              ),
                              background: Colors.green,
                              duration: const Duration(seconds: 1),
                            );
                          } else {
                            HapticFeedback.heavyImpact();
                            showSimpleNotification(
                              const Center(
                                child: Text(
                                  'ضيف البيانات الناقصة',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: Constants.defaultFontFamily,
                                  ),
                                ),
                              ),
                              background: Colors.red,
                              duration: const Duration(seconds: 1),
                            );
                          }
                        },
                        height: 56,
                        color: Colors.green.shade50,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_circle_outline,
                              color: Colors.green.shade400,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'إضافة',
                              style: TextStyle(
                                color: Colors.green.shade400,
                                fontFamily: Constants.defaultFontFamily,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddNewGoalButton(BuildContext context) {
    return InkWell(
      onTap: () {
        HapticFeedback.mediumImpact();
        Navigator.of(context).pushNamed(GoalsBlock.goalsID);
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: Constants.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: TextButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              Navigator.of(context).pushNamed(GoalsBlock.goalsID);
            },
            child: const Text(
              'إضافة هدف جديد +',
              style: TextStyle(
                color: Constants.primaryColor,
                fontFamily: Constants.secondaryFontFamily,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
