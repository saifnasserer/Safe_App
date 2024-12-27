import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:safe/Constants.dart';
import 'package:safe/Screens/manage.dart';
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
    return Semantics(
      value: 'Balance: ${widget.balance} pounds',
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
              NumberFormatter.formatNumber(widget.balance),
              style: TextStyle(
                fontSize: NumberFormatter.getAppropriateTextSize(
                    widget.balance, widget.fontSize),
                fontFamily: Constants.defaultFontFamily,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
