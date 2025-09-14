import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:safe/Constants.dart';

class Screen extends StatefulWidget {
  const Screen({
    required this.size,
    required this.buttonIcon,
    required this.screenName,
    required this.labelText,
    super.key,
  });

  final Widget screenName;
  final IconData buttonIcon;
  final double size;
  final String labelText;

  @override
  State<Screen> createState() => _ScreenState();
}

class _ScreenState extends State<Screen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap() {
    HapticFeedback.mediumImpact();
    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (c, a1, a2) => widget.screenName,
        transitionsBuilder: (c, anim, a2, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: anim,
            curve: Curves.easeInOut,
          )),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: Container(
              margin: EdgeInsets.symmetric(
                horizontal: Constants.responsiveSpacingNew(context, 8),
                vertical: Constants.responsiveSpacingNew(context, 4),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _handleTap,
                  borderRadius: BorderRadius.circular(
                      Constants.responsiveSpacingNew(context, 16)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        widget.buttonIcon,
                        color: Colors.white,
                        size: Constants.responsiveSpacingNew(
                            context, widget.size),
                      ),
                      SizedBox(
                          height: Constants.responsiveSpacingNew(context, 6)),
                      Text(
                        widget.labelText,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: Constants.responsiveSpacingNew(context, 11),
                          fontFamily: Constants.secondaryFontFamily,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
