import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:safe/Constants.dart';

class Screen extends StatelessWidget {
  Screen({
    required this.size,
    required this.buttonIcon,
    required this.screenName,
    required this.labelText,
    super.key,
  });
  Widget screenName;
  IconData buttonIcon;
  double size;
  String labelText;

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
            transitionDuration: const Duration(milliseconds: 150),
          ),
        );
      },
      icon: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            buttonIcon,
            color: Colors.white,
            size: Constants.responsiveSpacing(context, size),
          ),
          SizedBox(height: Constants.responsiveSpacing(context, 2)),
          Text(
            labelText,
            style: TextStyle(
              color: Colors.white,
              fontSize: Constants.responsiveFontSize(context, 10),
            ),
          ),
        ],
      ),
    );
  }
}
