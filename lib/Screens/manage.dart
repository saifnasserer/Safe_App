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

  @override
  void dispose() {
    titleController.dispose();
    amountController.dispose();
    audioPlayer.dispose();
    super.dispose();
  }

  double getAmount() {
    try {
      return double.parse(amountController.text);
    } catch (e) {
      return 0.0;
    }
  }

  String getTitle() {
    return titleController.text.isNotEmpty ? titleController.text : '';
  }

  @override
  Widget build(BuildContext context) {
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
        title: Text(
          'معاملة جديدة',
          style: TextStyle(
            color: Constants.primaryColor,
            fontFamily: Constants.defaultFontFamily,
            fontSize: screenWidth * 0.06,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: SizedBox(
                height: screenHeight * 0.02,
              ),
            ),
            SliverToBoxAdapter(
              child: Consumer<GoalProvider>(
                builder: (context, goalProvider, _) {
                  final screenWidth = MediaQuery.of(context).size.width;
                  final goals = goalProvider.goals ?? [];
                  if (goals.isEmpty) {
                    return _buildAddNewGoalButton(context);
                  }
                  return SizedBox(
                    height: screenHeight * .12,
                    child: ListView.builder(
                      padding:
                          EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: goals.length,
                      itemBuilder: (context, index) {
                        final goal = goals[index];
                        return Container(
                          width: screenWidth - 48,
                          margin: EdgeInsets.only(right: screenWidth * 0.05),
                          child: GestureDetector(
                            onTap: () {
                              HapticFeedback.mediumImpact();
                              Navigator.pushNamed(context, GoalsBlock.goalsID);
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
                    ),
                  );
                },
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                margin: EdgeInsets.all(screenHeight * 0.02),
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
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
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
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(screenWidth * .4, screenHeight * .06),
                        backgroundColor: Colors.red.shade50,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Text(
                            'صرف',
                            style: TextStyle(
                                color: Colors.red,
                                fontFamily: Constants.defaultFontFamily),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.remove_circle_outline, color: Colors.red),
                        ],
                      ),
                    ),

                    // _buildActionButton(
                    //   text: 'إضافة',
                    //   color: Colors.green.shade400,
                    //   icon: Icons.add_circle_outline,

                    // ),
                    ElevatedButton(
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
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(screenWidth * .4, screenHeight * .06),
                        backgroundColor: Colors.green.shade50,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Text(
                            'اضافة',
                            style: TextStyle(
                                color: Colors.green,
                                fontFamily: Constants.defaultFontFamily),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.add_circle_outline, color: Colors.green),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
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
