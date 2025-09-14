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
      child: Card(
        elevation: 12,
        shadowColor: Constants.getPrimaryColor(context).withOpacity(0.2),
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(Constants.responsiveRadius(context, 24)),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(Constants.responsiveRadius(context, 24)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Colors.grey[50]!,
              ],
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Constants.getPrimaryColor(context).withOpacity(0.3),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(
                  Constants.responsiveRadius(context, 24)),
            ),
            padding: EdgeInsets.all(Constants.responsiveSpacing(context, 20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Amount Input Section
                Container(
                  padding:
                      EdgeInsets.all(Constants.responsiveSpacing(context, 20)),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Constants.getPrimaryColor(context).withOpacity(0.05),
                        Constants.getPrimaryColor(context).withOpacity(0.02),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(
                        Constants.responsiveRadius(context, 16)),
                    border: Border.all(
                      color:
                          Constants.getPrimaryColor(context).withOpacity(0.2),
                      width: 1,
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
                          fontSize: Constants.responsiveFontSize(context, 32),
                          fontFamily: Constants.defaultFontFamily,
                          fontWeight: FontWeight.bold,
                          color: Constants.getPrimaryColor(context),
                        ),
                        decoration: InputDecoration(
                          hintText: '0.00',
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontFamily: Constants.secondaryFontFamily,
                            fontSize: Constants.responsiveFontSize(context, 24),
                          ),
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.only(left: 60, right: 60),
                        ),
                      ),
                      // Calculator Toggle Button
                      Positioned(
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: isCalculatorMode
                                ? Constants.getPrimaryColor(context)
                                    .withOpacity(0.1)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(
                                Constants.responsiveSpacing(context, 12)),
                          ),
                          child: IconButton(
                            icon: isCalculatorMode
                                ? Container(
                                    padding: EdgeInsets.all(
                                        Constants.responsiveSpacing(
                                            context, 4)),
                                    decoration: BoxDecoration(
                                      color: Constants.getPrimaryColor(context),
                                      borderRadius: BorderRadius.circular(
                                          Constants.responsiveSpacing(
                                              context, 8)),
                                    ),
                                    child: Text('=',
                                        style: TextStyle(
                                          fontSize:
                                              Constants.responsiveFontSize(
                                                  context, 20),
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        )),
                                  )
                                : Icon(
                                    Icons.calculate_rounded,
                                    color: Constants.getPrimaryColor(context),
                                    size: Constants.responsiveFontSize(
                                        context, 24),
                                  ),
                            onPressed: onToggleCalculator,
                          ),
                        ),
                      ),
                      // Date Select Button
                      Positioned(
                        left: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Constants.getPrimaryColor(context)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(
                                Constants.responsiveSpacing(context, 12)),
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.calendar_today_rounded,
                              color: Constants.getPrimaryColor(context),
                              size: Constants.responsiveFontSize(context, 24),
                            ),
                            onPressed: onDateSelect,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Calculator Keypad
                if (isCalculatorMode)
                  Container(
                    margin: EdgeInsets.only(
                        top: Constants.responsiveSpacing(context, 16)),
                    child: CalculatorKeypad(
                      onButtonPressed: onCalculatorButtonPressed,
                    ),
                  ),

                SizedBox(height: Constants.responsiveSpacing(context, 20)),

                // Title Input Section
                Container(
                  padding:
                      EdgeInsets.all(Constants.responsiveSpacing(context, 16)),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.grey[100]!.withOpacity(0.5),
                        Colors.grey[50]!.withOpacity(0.3),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(
                        Constants.responsiveRadius(context, 16)),
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    key: titleKey,
                    textAlign: TextAlign.center,
                    controller: titleController,
                    style: TextStyle(
                      fontSize: Constants.responsiveFontSize(context, 18),
                      fontFamily: Constants.secondaryFontFamily,
                      color: Colors.grey[800],
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: 'وصف المعاملة',
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontFamily: Constants.secondaryFontFamily,
                        fontSize: Constants.responsiveFontSize(context, 16),
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
    );
  }
}
