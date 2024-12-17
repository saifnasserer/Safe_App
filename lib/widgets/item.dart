import 'package:flutter/material.dart';
import 'package:safe/Constants.dart';

class item extends StatelessWidget {
  item({
    required this.dateTime,
    super.key,
    required this.flag,
    required this.title,
    required this.price,
  });

  final String title;
  double price;
  bool flag;
  DateTime dateTime;

  // Convert item to JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'price': price,
      'flag': flag,
      'dateTime': dateTime.toIso8601String(),
    };
  }

  // Create item from JSON
  factory item.fromJson(Map<String, dynamic> json) {
    return item(
      title: json['title'],
      price: json['price'],
      flag: json['flag'],
      dateTime: DateTime.parse(json['dateTime']),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.only(left: 10, right: 10, top: 10),
      decoration: BoxDecoration(
        color: flag ? const Color(0xff399918) : const Color(0xffEE4E4E),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 0,
            offset: const Offset(0, 3), // changes position of shadow
          ),
        ],
        borderRadius: BorderRadius.circular(20),
      ),
      width: double.infinity,
      height: 60,
      child: Row(children: [
        Text(price.toString(),
            style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontFamily: Constants.secondaryFontFamily)),
        const VerticalDivider(),
        Text(title,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontFamily: Constants.secondaryFontFamily)),
      ]),
    );
  }
}
