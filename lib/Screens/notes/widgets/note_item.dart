import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class note_item extends StatelessWidget {
  const note_item({super.key, required this.note_title, required this.date});
  final String note_title;
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat.yMMMEd().add_jm().format(date);
    return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        height: 65,
        width: double.infinity,
        decoration: BoxDecoration(
            color: Colors.purple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            const Spacer(flex: 1),
            Column(children: [
              Text(
                note_title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                formattedDate,
                style: TextStyle(color: Colors.grey.shade600),
                textAlign: TextAlign.start,
              )
            ]),
            const Spacer(flex: 3),
            IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert))
          ],
        ));
  }
}
