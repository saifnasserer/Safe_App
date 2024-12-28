import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:safe/Blocks/Wallet.dart';
import 'package:safe/Constants.dart';
import 'package:safe/Screens/Goals.dart' show GoalItem, GoalsBlock;
import 'package:safe/providers/profile_provider.dart';
import 'package:safe/widgets/Item_Provider.dart';
import 'package:safe/widgets/goals_screen_widgets/Goal_Provider.dart';
import 'package:safe/widgets/goals_screen_widgets/goal_item_widget.dart';
import 'package:safe/widgets/item.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:safe/utils/number_formatter.dart';

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
  final FocusNode _amountFocusNode = FocusNode();
  bool _isCalculatorMode = false;
  DateTime _selectedDate = DateTime.now();

  double getAmount() {
    try {
      // If calculator mode is active, evaluate the expression
      if (_isCalculatorMode) {
        Parser p = Parser();
        Expression exp = p.parse(amountController.text);
        ContextModel cm = ContextModel();
        return exp.evaluate(EvaluationType.REAL, cm);
      }
      // Otherwise, parse as a regular number
      return double.parse(amountController.text);
    } catch (e) {
      return 0.0;
    }
  }

  void _toggleCalculatorMode() {
    setState(() {
      _isCalculatorMode = !_isCalculatorMode;
      if (_isCalculatorMode) {
        amountController.clear();
        _amountFocusNode.unfocus(); // Remove focus in calculator mode
      } else {
        try {
          final calculatedValue = getAmount();
          amountController.text =
              NumberFormatter.formatCalculatorNumber(calculatedValue);
          _amountFocusNode
              .requestFocus(); // Focus and show keyboard when exiting calculator mode
        } catch (e) {
          amountController.clear();
        }
      }
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Constants.getPrimaryColor(context),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Constants.getPrimaryColor(context),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Widget _buildCalculatorKeypad() {
    final List<String> calculatorButtons = [
      '7',
      '8',
      '9',
      '/',
      '4',
      '5',
      '6',
      '*',
      '1',
      '2',
      '3',
      '-',
      '0',
      '.',
      '⌫',
      '+',
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1.5,
      ),
      itemCount: calculatorButtons.length,
      itemBuilder: (context, index) {
        final button = calculatorButtons[index];
        return TextButton(
          onPressed: () {
            if (button == '⌫') {
              // Handle backspace
              final currentText = amountController.text;
              if (currentText.isNotEmpty) {
                amountController.text =
                    currentText.substring(0, currentText.length - 1);
              }
            } else if (button == '=') {
              // Calculate the result
              try {
                final result = getAmount();
                amountController.text =
                    NumberFormatter.formatCalculatorNumber(result);
              } catch (e) {
                amountController.text = 'Error';
              }
            } else {
              // Append the button's value to the current text
              amountController.text += button;
            }
          },
          child: button == '⌫'
              ? Icon(
                  Icons.backspace_outlined,
                  color: Constants.getPrimaryColor(context),
                  size: 24,
                )
              : Text(
                  button,
                  style: TextStyle(
                    color: Constants.getPrimaryColor(context),
                    fontSize: 18,
                  ),
                ),
        );
      },
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    amountController.dispose();
    _amountFocusNode.dispose();
    audioPlayer.dispose();
    super.dispose();
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
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Constants.getPrimaryColor(context),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'معاملة جديدة',
          style: TextStyle(
            color: Constants.getPrimaryColor(context),
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
                    height: screenHeight * .13,
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
                            child: GoalItemWidget(
                              savedAmount: goal.currentAmount,
                              title: goal.title,
                              targetAmount: goal.targetAmount,
                              color: goal.color,
                              type: goal.type,
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
                      color: Constants.getPrimaryColor(context),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Constants.getPrimaryColor(context),
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
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            TextField(
                              controller: amountController,
                              focusNode: _amountFocusNode,
                              keyboardType: _isCalculatorMode
                                  ? TextInputType.none
                                  : const TextInputType.numberWithOptions(
                                      signed: false, decimal: true),
                              textAlign: TextAlign.center,
                              onTap: () {
                                if (_isCalculatorMode) {
                                  _amountFocusNode.unfocus();
                                } else {
                                  _amountFocusNode.requestFocus();
                                }
                              },
                              style: TextStyle(
                                fontSize: screenWidth * 0.06,
                                fontFamily: Constants.defaultFontFamily,
                                fontWeight: FontWeight.bold,
                              ),
                              decoration: const InputDecoration(
                                hintText: '0.00',
                                hintStyle: TextStyle(
                                  color: Colors.grey,
                                  fontFamily: Constants.defaultFontFamily,
                                ),
                                border: InputBorder.none,
                                contentPadding:
                                    EdgeInsets.only(left: 48, right: 48),
                              ),
                            ),
                            Positioned(
                              right: 0,
                              child: IconButton(
                                icon: Icon(
                                  _isCalculatorMode
                                      ? Icons.keyboard
                                      : Icons.calculate,
                                  color: Constants.getPrimaryColor(context),
                                ),
                                onPressed: _toggleCalculatorMode,
                              ),
                            ),
                            Positioned(
                              left: 0,
                              child: IconButton(
                                icon: Icon(
                                  Icons.calendar_today,
                                  color: Constants.getPrimaryColor(context),
                                ),
                                onPressed: () => _selectDate(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Show calculator keypad when in calculator mode
                      if (_isCalculatorMode) _buildCalculatorKeypad(),
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
                          final amount = getAmount();
                          if (amount > 0) {
                            final newItem = item(
                              title: getTitle(),
                              price: amount,
                              flag: false,
                              dateTime: _selectedDate, // Use selected date
                            );
                            HapticFeedback.mediumImpact();
                            Provider.of<ItemProvider>(context, listen: false)
                                .addItem(newItem);
                            audioPlayer.play(AssetSource('SFX/moneyAdd.mp3'));
                            amountController.clear();
                            titleController.clear();
                            final profileProvider =
                                context.read<ProfileProvider>();
                            final currentProfileId =
                                profileProvider.currentProfile?.id;
                            showSimpleNotification(
                              Text(
                                WalletBlock.balanceByProfile[currentProfileId]
                                                ?.value !=
                                            null &&
                                        WalletBlock
                                                .balanceByProfile[
                                                    currentProfileId]!
                                                .value <
                                            200
                                    ? 'خف صرف شوية بقا المحفظة فضيت'
                                    : 'تم اضافة اللي صرفتة يغالي ',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontFamily: Constants.defaultFontFamily,
                                ),
                              ),
                              background: Colors.red,
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
                    ElevatedButton(
                      onPressed: () async {
                        if (titleController.text.isNotEmpty &&
                            amountController.text.isNotEmpty) {
                          final amount = getAmount();
                          if (amount > 0) {
                            final newItem = item(
                              title: getTitle(),
                              price: amount,
                              flag: true,
                              dateTime: _selectedDate, // Use selected date
                            );
                            HapticFeedback.mediumImpact();
                            Provider.of<ItemProvider>(context, listen: false)
                                .addItem(newItem);
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
          color: Constants.getPrimaryColor(context).withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: TextButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              Navigator.of(context).pushNamed(GoalsBlock.goalsID);
            },
            child: Text(
              'إضافة هدف جديد +',
              style: TextStyle(
                color: Constants.getPrimaryColor(context),
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
