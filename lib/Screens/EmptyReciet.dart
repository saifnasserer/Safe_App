import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:safe/Constants.dart';
import 'package:safe/Screens/manage.dart';
import 'package:safe/utils/FirstUse.dart';
import 'package:safe/widgets/Item_Provider.dart';
import 'package:provider/provider.dart';

class Reciept extends StatefulWidget {
  const Reciept({super.key});
  static String id = 'this is receipt Page id';

  @override
  State<Reciept> createState() => _RecieptState();
}

class _RecieptState extends State<Reciept> {
  final AppTutorial _appTutorial = AppTutorial();
  final GlobalKey _walletKey = GlobalKey();
  final GlobalKey _spentKey = GlobalKey();
  final GlobalKey _goalsKey = GlobalKey();
  final GlobalKey _addTransactionKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkFirstUse();
    });
  }

  Future<void> _checkFirstUse() async {
    if (await _appTutorial.isFirstUse()) {
      if (mounted) {
        _appTutorial.showTutorial(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = Provider.of<ItemProvider>(context).items;
    final Map<String, List<dynamic>> groupedItems = {};

    for (var item in items) {
      final dateKey = _formatDate(item.dateTime);
      if (groupedItems.containsKey(dateKey)) {
        groupedItems[dateKey]!.add(item);
      } else {
        groupedItems[dateKey] = [item];
      }
    }

    return Scaffold(
      backgroundColor: Constants.scaffoldBackgroundColor,
      // appBar: AppBar(
      //   iconTheme: const IconThemeData(color: Colors.white),
      //   elevation: 0,
      //   backgroundColor: Constants.primaryColor,
      //   centerTitle: true,
      //   title: const Text(
      //     "مصاريفك",
      //     style: TextStyle(
      //       fontFamily: Constants.defaultFontFamily,
      //       fontSize: 24,
      //       fontWeight: FontWeight.bold,
      //       color: Colors.white,
      //     ),
      //   ),
      // ),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Constants.primaryColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'مصاريفك',
          style: TextStyle(
            color: Constants.primaryColor,
            fontFamily: Constants.defaultFontFamily,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: items.isEmpty
          ? Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Constants.primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.receipt_long_rounded,
                        size: 60,
                        color: Constants.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'لا يوجد معاملات',
                      style: TextStyle(
                        color: Constants.primaryColor,
                        fontSize: 24,
                        fontFamily: Constants.secondaryFontFamily,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'اضغط على الزر في الأسفل لإضافة معاملة جديدة',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: Constants.defaultFontSize,
                        fontFamily: Constants.secondaryFontFamily,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    Container(
                      key: _appTutorial.goalsKey,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Constants.primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pushNamed(context, Manage.id);
                          },
                          child: const Text(
                            'اضافة معاملة',
                            style: TextStyle(
                                fontFamily: Constants.secondaryFontFamily,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          )),
                    ),
                  ]),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              itemCount: groupedItems.keys.length,
              itemBuilder: (context, index) {
                final dateKey =
                    groupedItems.keys.toList().reversed.toList()[index];
                final itemsForDate = groupedItems[dateKey]!.reversed.toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 12.0,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B).withOpacity(0.04),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          dateKey,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            fontFamily: Constants.defaultFontFamily,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ),
                    ),
                    ...itemsForDate.map((item) {
                      final isIncome = item.flag;
                      final statusColor = isIncome
                          ? const Color(0xFF10B981)
                          : const Color(0xFFEF4444);

                      return Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFE2E8F0),
                            width: 1,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                height: 44,
                                width: 44,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: statusColor.withOpacity(.08),
                                ),
                                child: Icon(
                                  isIncome
                                      ? Icons.arrow_upward_rounded
                                      : Icons.arrow_downward_rounded,
                                  color: statusColor,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.title,
                                      style: const TextStyle(
                                        fontFamily: Constants.defaultFontFamily,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF1E293B),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      DateFormat('hh:mm a')
                                          .format(item.dateTime),
                                      style: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${item.price} جنيه',
                                    style: TextStyle(
                                      fontFamily: Constants.defaultFontFamily,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                      color: statusColor,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  GestureDetector(
                                    onTap: () {
                                      HapticFeedback.heavyImpact();
                                      final itemIndex = items.indexOf(item);
                                      if (itemIndex >= 0) {
                                        Provider.of<ItemProvider>(context,
                                                listen: false)
                                            .removeItem(itemIndex);
                                        showSimpleNotification(
                                            context: context,
                                            const Center(
                                                child: Text('تم الحذف')),
                                            background: Colors.green);
                                      }
                                    },
                                    child: Icon(
                                      Icons.delete_outline_rounded,
                                      color: statusColor,
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                );
              },
            ),
      floatingActionButton: items.isEmpty
          ? null
          : FloatingActionButton(
              key: _appTutorial.addTransactionKey,
              onPressed: () {
                HapticFeedback.mediumImpact();
                Navigator.pushNamed(context, Manage.id);
              },
              backgroundColor: Constants.primaryColor,
              child: const Icon(Icons.add, color: Colors.white),
            ),
    );
  }

  String _formatDate(DateTime date) {
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));

    if (DateFormat('yyyy-MM-dd').format(date) ==
        DateFormat('yyyy-MM-dd').format(today)) {
      return 'اليوم';
    } else if (DateFormat('yyyy-MM-dd').format(date) ==
        DateFormat('yyyy-MM-dd').format(yesterday)) {
      return 'أمس';
    } else {
      return DateFormat('yyyy-MM-dd').format(date);
    }
  }
}
