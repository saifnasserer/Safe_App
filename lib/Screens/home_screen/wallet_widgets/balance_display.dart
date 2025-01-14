import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:safe/Constants.dart';
import 'package:safe/utils/number_formatter.dart';

class BalanceDisplay extends StatefulWidget {
  final double balance;
  final double fontSize;
  final VoidCallback? onTap;

  const BalanceDisplay({
    super.key,
    required this.balance,
    required this.fontSize,
    this.onTap,
  });

  @override
  State<BalanceDisplay> createState() => _BalanceDisplayState();
}

class _BalanceDisplayState extends State<BalanceDisplay>
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
    // Calculate the base font size responsively
    double baseFontSize = Constants.responsiveFontSize(
        context,
        NumberFormatter.getAppropriateTextSize(
            widget.balance, widget.fontSize));

    return Semantics(
      value:
          'رصيد المحفظة: ${NumberFormatter.formatNumber(widget.balance)} جنيه',
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
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: Constants.responsiveSpacing(context, 8),
                  vertical: Constants.responsiveSpacing(context, 4)),
              child: Text(
                NumberFormatter.formatNumber(widget.balance),
                style: TextStyle(
                  fontSize: baseFontSize,
                  fontFamily: Constants.defaultFontFamily,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
