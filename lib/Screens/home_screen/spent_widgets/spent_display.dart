import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:safe/Constants.dart';
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
      value:
          'المبلغ المصروف: ${NumberFormatter.formatNumber(widget.value)} جنيه',
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
            // decoration: BoxDecoration(
            //   // gradient: LinearGradient(
            //   //   begin: Alignment.topLeft,
            //   //   end: Alignment.bottomRight,
            //   //   // colors: [
            //   //   //   Colors.red.withOpacity(0.8),
            //   //   //   Colors.red.withOpacity(0.6),
            //   //   // ],
            //   // ),
            //   borderRadius: BorderRadius.circular(
            //       Constants.responsiveSpacing(context, 20)),
            //   border: Border.all(
            //     color: Colors.white.withOpacity(0.3),
            //     width: 1,
            //   ),
            //   // boxShadow: [
            //   //   BoxShadow(
            //   //     color: Colors.red.withOpacity(0.3),
            //   //     blurRadius: 10,
            //   //     offset: const Offset(0, 4),
            //   //   ),
            //   // ],
            // ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding:
                        EdgeInsets.all(Constants.responsiveSpacing(context, 6)),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(.8),
                      borderRadius: BorderRadius.circular(
                          Constants.responsiveSpacing(context, 8)),
                    ),
                    child: Icon(
                      Icons.trending_down_rounded,
                      color: Colors.white,
                      size: Constants.responsiveFontSize(context, 16),
                    ),
                  ),
                  SizedBox(width: Constants.responsiveSpacing(context, 8)),
                  Text(
                    NumberFormatter.formatNumber(widget.value),
                    style: TextStyle(
                      fontSize: Constants.responsiveFontSize(
                          context, widget.fontSize),
                      fontFamily: Constants.defaultFontFamily,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.3),
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
                      fontSize: Constants.responsiveFontSize(
                          context, widget.fontSize * 0.3),
                      fontFamily: Constants.secondaryFontFamily,
                      color: Colors.white.withOpacity(0.9),
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
