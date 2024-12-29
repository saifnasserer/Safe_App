import 'package:flutter/material.dart';
import 'package:safe/Constants.dart';
import 'package:safe/Screens/recipt_screen/receipt_widgets/transaction_date_header.dart';
import 'package:safe/Screens/recipt_screen/receipt_widgets/transaction_item_card.dart';
import 'package:safe/utils/transaction_filter.dart';

class TransactionListView extends StatelessWidget {
  final List<dynamic> items;
  final TransactionType filterType;
  final Function(dynamic) onDeleteItem;

  const TransactionListView({
    super.key,
    required this.items,
    required this.filterType,
    required this.onDeleteItem,
  });

  Map<String, List<dynamic>> _groupItemsByDate(List<dynamic> items) {
    final Map<String, List<dynamic>> grouped = {};
    for (var item in items) {
      final dateKey = item.dateTime.toString().split(' ')[0];
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(item);
    }
    return grouped;
  }

  List<dynamic> _filterItems(List<dynamic> items) {
    if (filterType == TransactionType.all) return items;
    return items
        .where((item) =>
            filterType == TransactionType.expenses ? !item.flag : item.flag)
        .toList();
  }

  String _formatDate(String dateKey) {
    final now = DateTime.now();
    final date = DateTime.parse(dateKey);
    final difference = now.difference(date).inDays;

    if (difference == 0) return 'اليوم';
    if (difference == 1) return 'أمس';
    return dateKey;
  }

  @override
  Widget build(BuildContext context) {
    final groupedItems = _groupItemsByDate(items);
    final sortedDates = groupedItems.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      padding: EdgeInsets.symmetric(
        vertical: Constants.responsiveSpacing(context, 16),
      ),
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final dateKey = sortedDates[index];
        final itemsForDate = _filterItems(groupedItems[dateKey]!);

        if (itemsForDate.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TransactionDateHeader(
              date: dateKey,
              formatDate: _formatDate,
            ),
            ...itemsForDate.map((item) => TransactionItemCard(
                  item: item,
                  onDelete: onDeleteItem,
                )),
          ],
        );
      },
    );
  }
}
