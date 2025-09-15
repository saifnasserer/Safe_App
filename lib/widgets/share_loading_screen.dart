import 'package:flutter/material.dart';
import 'package:safe/Constants.dart';

class ShareLoadingScreen extends StatelessWidget {
  const ShareLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Simple loading indicator
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Constants.getPrimaryColor(context),
                ),
                strokeWidth: 3,
              ),

              SizedBox(height: Constants.responsiveSpacing(context, 24)),

              // Simple text
              Text(
                'جاري معالجة الإيصال...',
                style: TextStyle(
                  fontFamily: Constants.defaultFontFamily,
                  fontSize: Constants.responsiveFontSize(context, 18),
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
