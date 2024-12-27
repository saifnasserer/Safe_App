import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:safe/Constants.dart';
import 'package:safe/Screens/EmptyReciet.dart';
import 'package:safe/utils/number_formatter.dart';

class SpentDisplay extends StatefulWidget {
  final double value;
  final double fontSize;
  final VoidCallback? onTap;

  const SpentDisplay({
    super.key,
    required this.value,
    required this.fontSize,
    this.onTap,
  });

  @override
  State<SpentDisplay> createState() => _SpentDisplayState();
}

class _SpentDisplayState extends State<SpentDisplay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      value: 'Spent amount: ${widget.value} pounds',
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          _animationController
              .forward()
              .then((_) => _animationController.reverse());
          widget.onTap?.call();
        },
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              NumberFormatter.formatNumber(widget.value),
              style: TextStyle(
                fontSize: NumberFormatter.getAppropriateTextSize(
                    widget.value, widget.fontSize),
                fontFamily: Constants.defaultFontFamily,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
