import 'package:flutter/material.dart';
import 'package:safe/Constants.dart';

class CalculatorKeypad extends StatelessWidget {
  final Function(String) onButtonPressed;

  const CalculatorKeypad({
    super.key,
    required this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
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
          onPressed: () => onButtonPressed(button),
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
                    fontSize: Constants.responsiveFontSize(context, 18),
                  ),
                ),
        );
      },
    );
  }
}
