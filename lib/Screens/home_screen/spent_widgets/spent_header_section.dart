import 'package:flutter/material.dart';
import 'package:safe/Constants.dart';
import 'package:safe/Screens/recipt_screen/recipt.dart';
import 'package:safe/Screens/home_screen/spent_widgets/spent_display.dart';

class SpentHeaderSection extends StatelessWidget {
  final double value;
  final double containerHeight;

  const SpentHeaderSection({
    super.key,
    required this.value,
    required this.containerHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: Constants.responsiveSpacing(context, 8)),
        Text(
          "مصاريفك",
          style: TextStyle(
            fontSize: Constants.responsiveFontSize(context, 40),
            color: Colors.white,
            fontFamily: Constants.defaultFontFamily,
          ),
        ),
        SizedBox(height: Constants.responsiveSpacing(context, 8)),
        Text(
          "انت صرفت",
          style: TextStyle(
            fontSize: Constants.responsiveFontSize(context, 20),
            color: Colors.white,
            fontFamily: Constants.secondaryFontFamily,
          ),
        ),
        SpentDisplay(
          value: value,
          fontSize: MediaQuery.of(context).size.height * 0.07,
          onTap: () {
            Navigator.pushNamed(context, Reciept.id);
          },
        ),
      ],
    );
  }
}
