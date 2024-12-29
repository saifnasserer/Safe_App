import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:safe/Constants.dart';
import 'package:safe/providers/profile_provider.dart';
import 'package:safe/utils/storage_service.dart';
import 'package:safe/utils/date_filter.dart';
import 'package:safe/widgets/spent_widgets/spent_filter_section.dart';
import 'package:safe/widgets/spent_widgets/spent_header_section.dart';
import 'package:safe/widgets/spent_widgets/spent_navigation_bar.dart';

class SpentBlock extends StatefulWidget {
  const SpentBlock({super.key});
  static final Map<String, ValueNotifier<double>> spentByProfile = {};

  static Future<void> updateSpentValue(
      BuildContext context, double newvalue) async {
    final profileProvider = context.read<ProfileProvider>();
    if (profileProvider.currentProfile != null) {
      final profileId = profileProvider.currentProfile!.id;
      spentByProfile[profileId]?.value = newvalue;
      await StorageService.saveSpentAmount(profileId, newvalue);
    }
  }

  static Future<void> initSpent(BuildContext context) async {
    final profileProvider = context.read<ProfileProvider>();
    if (profileProvider.currentProfile != null) {
      final profileId = profileProvider.currentProfile!.id;
      if (!spentByProfile.containsKey(profileId)) {
        spentByProfile[profileId] = ValueNotifier<double>(0.0);
      }
      spentByProfile[profileId]!.value =
          await StorageService.loadSpentAmount(profileId);
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
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();

    // Initialize spent for current profile
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SpentBlock.initSpent(context);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = Constants.screenWidth(context);
    final screenHeight = Constants.screenHeight(context);
    final containerHeight = Constants.screenHeight(context);
    final profileProvider = context.watch<ProfileProvider>();
    final currentProfileId = profileProvider.currentProfile?.id;

    if (currentProfileId == null) {
      return const SizedBox.shrink();
    }

    if (!SpentBlock.spentByProfile.containsKey(currentProfileId)) {
      SpentBlock.spentByProfile[currentProfileId] = ValueNotifier<double>(0.0);
      SpentBlock.initSpent(context);
    }

    return ValueListenableBuilder<double>(
      valueListenable: SpentBlock.spentByProfile[currentProfileId]!,
      builder: (context, value, child) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: Constants.widthPercent(context, 5)),
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: Constants.getPrimaryColor(context),
                    borderRadius: BorderRadius.only(
                      topLeft:
                          Radius.circular(Constants.widthPercent(context, 15)),
                      topRight:
                          Radius.circular(Constants.widthPercent(context, 15)),
                    ),
                  ),
                ),
                Opacity(
                  opacity: 0.04,
                  child: Image.asset(
                    'assets/dots.png',
                    fit: BoxFit.cover,
                    width: screenWidth,
                    height: Constants.screenHeight(context),
                  ),
                ),
                Center(
                  child: Column(
                    children: [
                      const Spacer(flex: 2),
                      SpentHeaderSection(
                        value: value,
                        containerHeight: Constants.screenHeight(context),
                      ),
                      const Spacer(flex: 1),
                      SpentFilterSection(
                        currentFilter: _currentFilter,
                        onFilterTap: _showFilterDialog,
                      ),
                      const Spacer(flex: 1),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: SpentNavigationBar(
                          containerHeight: Constants.screenHeight(context),
                        ),
                      ),
                      const Spacer(flex: 1),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
