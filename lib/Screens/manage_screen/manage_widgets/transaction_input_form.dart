import 'package:flutter/material.dart';
import 'package:safe/Constants.dart';
import 'package:safe/Screens/manage_screen/manage_widgets/calculator_keypad.dart';

class TransactionInputForm extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController amountController;
  final FocusNode amountFocusNode;
  final bool isCalculatorMode;
  final VoidCallback onToggleCalculator;
  final VoidCallback onDateSelect;
  final Function(String) onCalculatorButtonPressed;
  final GlobalKey? titleKey;
  final GlobalKey? amountKey;

  const TransactionInputForm({
    super.key,
    required this.titleController,
    required this.amountController,
    required this.amountFocusNode,
    required this.isCalculatorMode,
    required this.onToggleCalculator,
    required this.onDateSelect,
    required this.onCalculatorButtonPressed,
    this.titleKey,
    this.amountKey,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(Constants.responsiveSpacing(context, 16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(Constants.responsiveRadius(context, 24)),
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
          borderRadius:
              BorderRadius.circular(Constants.responsiveRadius(context, 24)),
        ),
        padding: EdgeInsets.all(Constants.responsiveSpacing(context, 16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(Constants.responsiveSpacing(context, 16)),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Constants.getPrimaryColor(context),
                    width: 1,
                  ),
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  TextField(
                    key: amountKey,
                    controller: amountController,
                    focusNode: amountFocusNode,
                    keyboardType: isCalculatorMode
                        ? TextInputType.none
                        : const TextInputType.numberWithOptions(
                            signed: false, decimal: true),
                    textAlign: TextAlign.center,
                    onTap: () {
                      if (isCalculatorMode) {
                        amountFocusNode.unfocus();
                      } else {
                        amountFocusNode.requestFocus();
                      }
                    },
                    style: TextStyle(
                      fontSize: Constants.responsiveFontSize(context, 30),
                      fontFamily: Constants.secondaryFontFamily,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: const InputDecoration(
                      hintText: '0.00',
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontFamily: Constants.secondaryFontFamily,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.only(left: 48, right: 48),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    child: IconButton(
                      icon: Icon(
                        isCalculatorMode ? Icons.keyboard : Icons.calculate,
                        color: Constants.getPrimaryColor(context),
                      ),
                      onPressed: onToggleCalculator,
                    ),
                  ),
                  Positioned(
                    left: 0,
                    child: IconButton(
                      icon: Icon(
                        Icons.calendar_today,
                        color: Constants.getPrimaryColor(context),
                      ),
                      onPressed: onDateSelect,
                    ),
                  ),
                ],
              ),
            ),
            if (isCalculatorMode)
              CalculatorKeypad(
                onButtonPressed: onCalculatorButtonPressed,
              ),
            const SizedBox(height: 16),
            TextField(
              key: titleKey,
              textAlign: TextAlign.center,
              controller: titleController,
              style: TextStyle(
                fontSize: Constants.responsiveFontSize(context, 30),
                fontFamily: Constants.secondaryFontFamily,
              ),
              decoration: const InputDecoration(
                hintText: 'وصف المعاملة',
                hintStyle: TextStyle(
                  color: Colors.grey,
                  fontFamily: Constants.secondaryFontFamily,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
