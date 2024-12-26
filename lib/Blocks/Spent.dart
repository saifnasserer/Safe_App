import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:safe/Constants.dart';
import 'package:safe/providers/profile_provider.dart';
import 'package:safe/Screens/EmptyReciet.dart';
import 'package:safe/Screens/Goals.dart';
import 'package:safe/Screens/manage.dart';
import 'package:safe/utils/storage_service.dart';
import 'package:safe/utils/date_filter.dart';
import 'package:safe/widgets/navigation.dart';

class SpentBlock extends StatefulWidget {
  const SpentBlock({super.key});
  static ValueNotifier<double> spent = ValueNotifier<double>(0.0);

  static Future<void> updateSpentValue(
      BuildContext context, double newvalue) async {
    final profileProvider = context.read<ProfileProvider>();
    if (profileProvider.currentProfile != null) {
      spent.value = newvalue;
      await StorageService.saveSpentAmount(
          profileProvider.currentProfile!.id, newvalue);
    }
  }

  static Future<void> initSpent(BuildContext context) async {
    final profileProvider = context.read<ProfileProvider>();
    if (profileProvider.currentProfile != null) {
      spent.value = await StorageService.loadSpentAmount(
          profileProvider.currentProfile!.id);
    }
  }

  @override
  State<SpentBlock> createState() => _SpentBlockState();
}

class _SpentBlockState extends State<SpentBlock>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  DateFilter _currentFilter = DateFilter.today;
  DateTime? _customDate;

  void _showDatePicker() async {
    final earliestDate = await _getEarliestExpenseDate();
    final picked = await showDatePicker(
      context: context,
      initialDate: _customDate ?? DateTime.now(),
      firstDate: earliestDate,
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _customDate = picked;
        _currentFilter = DateFilter.custom;
      });
      _updateSpentValue();
    }
  }

  Future<DateTime> _getEarliestExpenseDate() async {
    final profileProvider = context.read<ProfileProvider>();

    if (profileProvider.currentProfile != null) {
      final items =
          await StorageService.loadItems(profileProvider.currentProfile!.id);
      if (items.isEmpty) {
        return DateTime.now();
      }

      return items
          .where((item) => !item.flag) // Only consider expenses
          .map((item) => item.dateTime)
          .reduce((a, b) => a.isBefore(b) ? a : b);
    }
    return DateTime.now();
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'اختر الفترة',
            style: TextStyle(
              fontFamily: Constants.defaultFontFamily,
              color: Color(0xff4558c8),
            ),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text(
                  'النهاردة',
                  style: TextStyle(
                    fontFamily: Constants.secondaryFontFamily,
                  ),
                  textAlign: TextAlign.center,
                ),
                onTap: () {
                  setState(() {
                    _currentFilter = DateFilter.today;
                    _customDate = null;
                  });
                  _updateSpentValue();
                  HapticFeedback.mediumImpact();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text(
                  'الاسبوع اللي فات',
                  style: TextStyle(
                    fontFamily: Constants.secondaryFontFamily,
                  ),
                  textAlign: TextAlign.center,
                ),
                onTap: () {
                  setState(() {
                    _currentFilter = DateFilter.lastWeek;
                    _customDate = null;
                  });
                  _updateSpentValue();
                  HapticFeedback.mediumImpact();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text(
                  'الشهر اللي فات',
                  style: TextStyle(
                    fontFamily: Constants.secondaryFontFamily,
                  ),
                  textAlign: TextAlign.center,
                ),
                onTap: () {
                  setState(() {
                    _currentFilter = DateFilter.lastMonth;
                    _customDate = null;
                  });
                  _updateSpentValue();
                  HapticFeedback.mediumImpact();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text(
                  'تاريخ معين',
                  style: TextStyle(
                    fontFamily: Constants.secondaryFontFamily,
                  ),
                  textAlign: TextAlign.center,
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showDatePicker();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _updateSpentValue() async {
    final profileProvider = context.read<ProfileProvider>();

    if (profileProvider.currentProfile != null) {
      final items =
          await StorageService.loadItems(profileProvider.currentProfile!.id);
      double total = 0;

      for (var item in items) {
        if (DateFilterHelper.isItemInRange(item.dateTime, _currentFilter,
            customDate: _customDate)) {
          if (!item.flag) {
            // Only count expenses (when flag is false)
            total += item.price;
          }
        }
      }

      await SpentBlock.updateSpentValue(context, total);
    }
  }

  @override
  void initState() {
    super.initState();
    SpentBlock.initSpent(context);
    _updateSpentValue(); // Initial update based on today's filter
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return ValueListenableBuilder<double>(
      valueListenable: SpentBlock.spent,
      builder: (context, value, child) {
        return Expanded(
          child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
            double containerHeight = constraints.maxHeight;

            return SlideTransition(
              position: _slideAnimation,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        color: Constants.getPrimaryColor(context),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(screenWidth * 0.15),
                          topRight: Radius.circular(screenWidth * 0.15),
                        ),
                      ),
                    ),
                    Opacity(
                      opacity: 0.04,
                      child: Image.asset(
                        'assets/dots.png',
                        fit: BoxFit.cover,
                        width: screenWidth,
                        height: screenHeight * .5,
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Spacer(),
                          Text(
                            "مصاريفك",
                            style: TextStyle(
                              fontSize: containerHeight * 0.09,
                              color: Colors.white,
                              fontFamily: Constants.defaultFontFamily,
                            ),
                          ),
                          SizedBox(height: containerHeight * 0.02),
                          Text(
                            "انت صرفت",
                            style: TextStyle(
                              fontSize: containerHeight * 0.05,
                              color: Colors.white,
                              fontFamily: Constants.secondaryFontFamily,
                            ),
                          ),
                          Text(
                            value.toStringAsFixed(2),
                            maxLines: 1,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: containerHeight * 0.18,
                              color: Colors.white,
                              fontFamily: Constants.defaultFontFamily,
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              _showFilterDialog();
                              HapticFeedback.mediumImpact();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _currentFilter == DateFilter.today
                                      ? 'النهاردة'
                                      : _currentFilter == DateFilter.lastWeek
                                          ? 'الاسبوع اللي فات'
                                          : _currentFilter ==
                                                  DateFilter.lastMonth
                                              ? 'الشهر اللي فات'
                                              : 'تاريخ معين',
                                  style: const TextStyle(
                                    color: Color(0xff4558c8),
                                    fontFamily: Constants.secondaryFontFamily,
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_drop_down,
                                  color: Color(0xff4558c8),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(
                                bottom: containerHeight * 0.05,
                                top: containerHeight * 0.1),
                            decoration: const BoxDecoration(
                                color: Color(0xff1c1c1c),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(40))),
                            height: containerHeight * 0.12,
                            width: containerHeight * 0.5,
                            child: Row(children: [
                              const Spacer(flex: 1),
                              Screen(
                                buttonIcon: Icons.add,
                                screenName: const Manage(),
                                size: containerHeight * 0.08,
                              ),
                              const Spacer(flex: 1),
                              Screen(
                                  buttonIcon: Icons.task_alt_rounded,
                                  screenName: const GoalsBlock(),
                                  size: containerHeight * 0.08),
                              const Spacer(flex: 1),
                              Screen(
                                  size: containerHeight * 0.08,
                                  buttonIcon: Icons.receipt_long_rounded,
                                  screenName: const Reciept()),
                              const Spacer(flex: 1),
                            ]),
                          )
                          // SizedBox(
                          //   height: containerHeight * 0.25,
                          //   child: const MyNavigator(),
                          // ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
