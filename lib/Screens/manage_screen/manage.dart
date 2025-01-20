import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:safe/Constants.dart';
import 'package:safe/Screens/home_screen/Wallet.dart';
import 'package:safe/Screens/manage_screen/manage_widgets/add_goal_button.dart';
import 'package:safe/Screens/manage_screen/manage_widgets/goals_list_view.dart';
import 'package:safe/Screens/manage_screen/manage_widgets/manage_app_bar.dart';
import 'package:safe/Screens/manage_screen/manage_widgets/transaction_buttons.dart';
import 'package:safe/Screens/manage_screen/manage_widgets/transaction_input_form.dart';
import 'package:safe/providers/Goal_Provider.dart';
import 'package:safe/providers/Item_Provider.dart';
import 'package:safe/providers/profile_provider.dart';
import 'package:safe/utils/number_formatter.dart';
import 'package:safe/widgets/item.dart';

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
      if (_isCalculatorMode) {
        Parser p = Parser();
        Expression exp = p.parse(amountController.text);
        ContextModel cm = ContextModel();
        return exp.evaluate(EvaluationType.REAL, cm);
      }
      return double.parse(amountController.text);
    } catch (e) {
      return 0.0;
    }
  }

  void _toggleCalculatorMode() {
    setState(() {
      if (!_isCalculatorMode) {
        // Switching TO calculator mode
        _amountFocusNode.unfocus();
      } else {
        // Switching FROM calculator mode
        try {
          final calculatedValue = getAmount();
          if (calculatedValue != 0.0) {
            amountController.text = NumberFormatter.formatCalculatorNumber(calculatedValue);
          }
          _amountFocusNode.requestFocus();
        } catch (e) {
          // Keep the existing value even if there's an error
        }
      }
      _isCalculatorMode = !_isCalculatorMode;
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

  void _handleCalculatorButton(String button) {
    if (button == '⌫') {
      final currentText = amountController.text;
      if (currentText.isNotEmpty) {
        amountController.text =
            currentText.substring(0, currentText.length - 1);
      }
    } else {
      amountController.text += button;
    }
  }

  void _handleTransaction(bool isIncome) async {
    if (titleController.text.isNotEmpty && amountController.text.isNotEmpty) {
      final amount = getAmount();

      // Check for order-related words if it's an expense

      if (amount > 0) {
        final title = titleController.text.toLowerCase();
        final newItem = item(
          title: titleController.text,
          price: amount,
          flag: isIncome,
          dateTime: _selectedDate,
        );
        Provider.of<ItemProvider>(context, listen: false).addItem(newItem);
        audioPlayer.play(AssetSource('SFX/moneyAdd.mp3'));
        amountController.clear();
        titleController.clear();

        if (!isIncome) {
          final profileProvider = context.read<ProfileProvider>();
          final currentProfileId = profileProvider.currentProfile?.id;
          if (title.contains('order') ||
              title.contains('اوردر') ||
              title.contains('أوردر')) {
            showSimpleNotification(
              const Text(
                'كفااااية اوردرات',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: Constants.defaultFontFamily,
                  fontSize: 16,
                ),
              ),
              background: Colors.red,
              duration: const Duration(seconds: 2),
            );
            return;
          } else {
            showSimpleNotification(
              Text(
                WalletBlock.balanceByProfile[currentProfileId]?.value != null &&
                        WalletBlock.balanceByProfile[currentProfileId]!.value <
                            200
                    ? 'خف صرف شوية بقا المحفظة فضيت'
                    : 'تم اضافة اللي صرفتة يغالي ',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: Constants.defaultFontFamily,
                ),
              ),
              background: Colors.red,
              duration: const Duration(seconds: 2),
            );
          }
        } else {
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
        }
      } else {
        _showErrorNotification();
      }
    } else {
      _showErrorNotification();
    }
  }

  void _showErrorNotification() {
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

  @override
  void dispose() {
    titleController.dispose();
    amountController.dispose();
    _amountFocusNode.dispose();
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.scaffoldBackgroundColor,
      appBar: const ManageAppBar(),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: SizedBox(
                height: Constants.responsiveSpacing(context, 16),
              ),
            ),
            SliverToBoxAdapter(
              child: Consumer<GoalProvider>(
                builder: (context, goalProvider, _) {
                  final goals = goalProvider.goals;
                  if (goals.isEmpty) {
                    return const AddGoalButton();
                  }
                  return GoalsListView(
                    goals: goals,
                    onGoalRemoved: (index) {
                      goalProvider.removeGoal(index);
                      if (goalProvider.goals.isEmpty) {
                        setState(() {});
                      }
                    },
                  );
                },
              ),
            ),
            SliverToBoxAdapter(
              child: TransactionInputForm(
                titleController: titleController,
                amountController: amountController,
                amountFocusNode: _amountFocusNode,
                isCalculatorMode: _isCalculatorMode,
                onToggleCalculator: _toggleCalculatorMode,
                onDateSelect: () => _selectDate(context),
                onCalculatorButtonPressed: _handleCalculatorButton,
              ),
            ),
            SliverToBoxAdapter(
              child: TransactionButtons(
                onExpense: () => _handleTransaction(false),
                onIncome: () => _handleTransaction(true),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
