import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:safe/Constants.dart';

class CalculatorKeypad extends StatefulWidget {
  final Function(String) onButtonPressed;

  const CalculatorKeypad({
    super.key,
    required this.onButtonPressed,
  });

  @override
  State<CalculatorKeypad> createState() => _CalculatorKeypadState();
}

class _CalculatorKeypadState extends State<CalculatorKeypad>
    with TickerProviderStateMixin {
  late List<AnimationController> _animationControllers;
  late List<Animation<double>> _scaleAnimations;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationControllers = List.generate(16, (index) {
      return AnimationController(
        duration: const Duration(milliseconds: 100),
        vsync: this,
      );
    });

    _scaleAnimations = _animationControllers.map((controller) {
      return Tween<double>(
        begin: 1.0,
        end: 0.95,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ));
    }).toList();
  }

  @override
  void dispose() {
    for (var controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _handleButtonPress(String button, int index) {
    HapticFeedback.lightImpact();
    _animationControllers[index].forward().then((_) {
      _animationControllers[index].reverse();
    });
    widget.onButtonPressed(button);
  }

  Color _getButtonColor(String button) {
    if (button == '⌫') {
      return Colors.red;
    } else if (['+', '-', '*', '/'].contains(button)) {
      return Colors.orange;
    } else {
      return Colors.grey[600]!;
    }
  }

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

    return Container(
      padding: EdgeInsets.all(Constants.responsiveSpacing(context, 8)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey[100]!.withOpacity(0.8),
            Colors.grey[50]!.withOpacity(0.6),
          ],
        ),
        borderRadius:
            BorderRadius.circular(Constants.responsiveRadius(context, 16)),
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 1.2,
          crossAxisSpacing: Constants.responsiveSpacing(context, 8),
          mainAxisSpacing: Constants.responsiveSpacing(context, 8),
        ),
        itemCount: calculatorButtons.length,
        itemBuilder: (context, index) {
          final button = calculatorButtons[index];
          final buttonColor = _getButtonColor(button);

          return AnimatedBuilder(
            animation: _scaleAnimations[index],
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimations[index].value,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _handleButtonPress(button, index),
                    borderRadius: BorderRadius.circular(
                        Constants.responsiveRadius(context, 12)),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white,
                            Colors.grey[100]!,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(
                            Constants.responsiveRadius(context, 12)),
                        border: Border.all(
                          color: buttonColor.withOpacity(0.2),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: buttonColor.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: button == '⌫'
                            ? Icon(
                                Icons.backspace_outlined,
                                color: buttonColor,
                                size: Constants.responsiveFontSize(context, 20),
                              )
                            : Text(
                                button,
                                style: TextStyle(
                                  color: buttonColor,
                                  fontSize:
                                      Constants.responsiveFontSize(context, 18),
                                  fontFamily: Constants.defaultFontFamily,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
