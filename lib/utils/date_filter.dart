enum DateFilter { today, lastWeek, lastMonth, custom }

class DateFilterHelper {
  static bool isItemInRange(DateTime itemDate, DateFilter filter,
      {DateTime? customDate}) {
    final now = DateTime.now();

    switch (filter) {
      case DateFilter.today:
        return itemDate.year == now.year &&
            itemDate.month == now.month &&
            itemDate.day == now.day;

      case DateFilter.lastWeek:
        final lastWeek = now.subtract(const Duration(days: 7));
        final startOfToday = DateTime(now.year, now.month, now.day);
        return itemDate.isAfter(lastWeek) && itemDate.isBefore(startOfToday);

      case DateFilter.lastMonth:
        final lastMonth = DateTime(now.year, now.month - 1, now.day);
        final startOfToday = DateTime(now.year, now.month, now.day);
        return itemDate.isAfter(lastMonth) && itemDate.isBefore(startOfToday);

      case DateFilter.custom:
        if (customDate == null) return false;
        return itemDate.year == customDate.year &&
            itemDate.month == customDate.month &&
            itemDate.day == customDate.day;
    }
  }
}
