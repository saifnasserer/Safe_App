import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Screen extends StatelessWidget {
  Screen(
      {required this.size,
      required this.buttonIcon,
      required this.screenName,
      super.key});
  Widget screenName;
  IconData buttonIcon;
  double size;
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        HapticFeedback.mediumImpact();
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (c, a1, a2) => screenName,
            transitionsBuilder: (c, anim, a2, child) =>
                FadeTransition(opacity: anim, child: child),
            transitionDuration: const Duration(milliseconds: 300),
          ),
        );
      },
      icon: Icon(
        buttonIcon,
        color: Colors.white,
        size: size,
      ),
    );
  }
}
