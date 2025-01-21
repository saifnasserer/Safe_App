import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:safe/Constants.dart';

class AppTutorial {
  static const String _firstUseKey = 'first_use_completed';
  static const String _homeFirstUseKey = 'home_first_use_completed';
  static const String _manageFirstUseKey = 'manage_first_use_completed';
  static const String _goalsFirstUseKey = 'goals_first_use_completed';
  late TutorialCoachMark tutorialCoachMark;
  List<TargetFocus> targets = [];

  // Global keys for widgets we want to highlight
  final GlobalKey walletKey = GlobalKey();
  final GlobalKey addTransactionKey = GlobalKey();
  final GlobalKey goalsKey = GlobalKey();
  final GlobalKey spentKey = GlobalKey();

  Future<bool> isFirstUse() async {
    final prefs = await SharedPreferences.getInstance();
    final isCompleted = prefs.getBool(_firstUseKey);
    return isCompleted == null || !isCompleted;
  }

  Future<bool> isHomeFirstUse() async {
    final prefs = await SharedPreferences.getInstance();
    final isCompleted = prefs.getBool(_homeFirstUseKey);
    return isCompleted == null || !isCompleted;
  }

  Future<bool> isManageFirstUse() async {
    final prefs = await SharedPreferences.getInstance();
    final isCompleted = prefs.getBool(_manageFirstUseKey);
    return isCompleted == null || !isCompleted;
  }

  Future<bool> isGoalsFirstUse() async {
    final prefs = await SharedPreferences.getInstance();
    final isCompleted = prefs.getBool(_goalsFirstUseKey);
    return isCompleted == null || !isCompleted;
  }

  Future<void> markFirstUseComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_firstUseKey, true);
  }

  Future<void> markHomeFirstUseComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_homeFirstUseKey, true);
  }

  Future<void> markManageFirstUseComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_manageFirstUseKey, true);
  }

  Future<void> markGoalsFirstUseComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_goalsFirstUseKey, true);
  }

  void showTutorial(BuildContext context) {
    initTargets();
    tutorialCoachMark = TutorialCoachMark(
      targets: targets,
      colorShadow: Constants.getPrimaryColor(context),
      textSkip: "تخطي",
      paddingFocus: 10,
      opacityShadow: 0.8,
      onFinish: () {
        markFirstUseComplete();
      },
      onSkip: () {
        markFirstUseComplete();
        return true;
      },
    );

    Future.delayed(const Duration(milliseconds: 100), () {
      tutorialCoachMark.show(context: context);
    });
  }

  void initTargets() {
    targets.add(
      TargetFocus(
        identify: "wallet_key",
        keyTarget: walletKey,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return Container(
                padding: const EdgeInsets.all(16),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "المحفظة",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 20,
                        fontFamily: Constants.defaultFontFamily,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "هنا يمكنك رؤية رصيدك الحالي",
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: Constants.defaultFontFamily,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );

    targets.add(
      TargetFocus(
        identify: "add_transaction_key",
        keyTarget: addTransactionKey,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return Container(
                padding: const EdgeInsets.all(16),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "إضافة معاملة",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 20,
                        fontFamily: Constants.defaultFontFamily,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "اضغط هنا لإضافة معاملة جديدة (مصروف أو دخل)",
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: Constants.defaultFontFamily,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );

    targets.add(
      TargetFocus(
        identify: "goals_key",
        keyTarget: goalsKey,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return Container(
                padding: const EdgeInsets.all(16),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "الأهداف",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 20,
                        fontFamily: Constants.defaultFontFamily,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "يمكنك إضافة أهداف مالية وتتبع تقدمك نحو تحقيقها",
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: Constants.defaultFontFamily,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );

    targets.add(
      TargetFocus(
        identify: "spent_key",
        keyTarget: spentKey,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return Container(
                padding: const EdgeInsets.all(16),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "المصروفات",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 20,
                        fontFamily: Constants.defaultFontFamily,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "هنا يمكنك رؤية إجمالي مصروفاتك",
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: Constants.defaultFontFamily,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
