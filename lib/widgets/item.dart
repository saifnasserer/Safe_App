import 'package:flutter/material.dart';
import 'package:safe/Constants.dart';

class item extends StatelessWidget {
  item({
    required this.dateTime,
    super.key,
    required this.flag,
    required this.title,
    required this.price,
    this.isGoal = false,
    this.goalIndex,
  });

  final String title;
  double price;
  bool flag;
  DateTime dateTime;
  final bool isGoal;
  final int? goalIndex;

  // Convert item to JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'price': price,
      'flag': flag,
      'dateTime': dateTime.toIso8601String(),
      'isGoal': isGoal,
      'goalIndex': goalIndex,
    };
  }

  // Create item from JSON
  factory item.fromJson(Map<String, dynamic> json) {
    return item(
      title: json['title'],
      price: json['price'],
      flag: json['flag'],
      dateTime: DateTime.parse(json['dateTime']),
      isGoal: json['isGoal'] ?? false,
      goalIndex: json['goalIndex'],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Constants.responsiveSpacing(context, 15)),
      margin: EdgeInsets.only(
        left: Constants.responsiveSpacing(context, 10),
        right: Constants.responsiveSpacing(context, 10),
        top: Constants.responsiveSpacing(context, 10)
      ),
      decoration: BoxDecoration(
        color: flag ? const Color(0xff399918) : const Color(0xffEE4E4E),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: Constants.responsiveSpacing(context, 1),
            blurRadius: 0,
            offset: Offset(0, Constants.responsiveSpacing(context, 3)),
          ),
        ],
        borderRadius: BorderRadius.circular(Constants.responsiveSpacing(context, 20)),
      ),
      width: double.infinity,
      height: Constants.heightPercent(context, 8), 
      child: Row(children: [
        Text(
          price.toString(),
          style: TextStyle(
            color: Colors.white,
            fontSize: Constants.responsiveFontSize(context, 20),
            fontFamily: Constants.secondaryFontFamily
          )
        ),
        const VerticalDivider(),
        Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: Constants.responsiveFontSize(context, 20),
            fontFamily: Constants.secondaryFontFamily
          )
        ),
      ]),
    );
  }
}
