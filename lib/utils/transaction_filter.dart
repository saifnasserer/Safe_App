enum TransactionType {
  all,
  expenses,
  income
}

class TransactionFilterHelper {
  static String getFilterName(TransactionType type) {
    switch (type) {
      case TransactionType.all:
        return 'الكل';
      case TransactionType.expenses:
        return 'المصروفات';
      case TransactionType.income:
        return 'الدخل';
    }
  }

  static double calculateTotal(List<dynamic> items, TransactionType filter) {
    double total = 0;
    for (var item in items) {
      if (filter == TransactionType.all ||
          (filter == TransactionType.expenses && !item.flag) ||
          (filter == TransactionType.income && item.flag)) {
        total += item.price;
      }
    }
    return total;
  }
}
