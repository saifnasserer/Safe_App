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
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: Constants.responsiveSpacing(context, 16),
              vertical: Constants.responsiveSpacing(context, 8),
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.9),
                  Colors.white.withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(
                  Constants.responsiveSpacing(context, 20)),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Container(
                  //   padding:
                  //       EdgeInsets.all(Constants.responsiveSpacing(context, 6)),
                  //   decoration: BoxDecoration(
                  //     color:
                  //         Constants.getPrimaryColor(context).withOpacity(0.1),
                  //     borderRadius: BorderRadius.circular(
                  //         Constants.responsiveSpacing(context, 8)),
                  //   ),
                  //   child: Icon(
                  //     Icons.account_balance_wallet_rounded,
                  //     color: Constants.getPrimaryColor(context),
                  //     size: Constants.responsiveFontSize(context, 16),
                  //   ),
                  // ),
                  // SizedBox(width: Constants.responsiveSpacing(context, 8)),
                  Text(
                    NumberFormatter.formatNumber(widget.balance),
                    style: TextStyle(
                      fontSize: baseFontSize,
                      fontFamily: Constants.defaultFontFamily,
                      color: Colors.grey[800],
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.1),
                          offset: const Offset(0, 1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: Constants.responsiveSpacing(context, 4)),
                  Text(
                    'ج.م',
                    style: TextStyle(
                      fontSize: baseFontSize * 0.3,
                      fontFamily: Constants.secondaryFontFamily,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
