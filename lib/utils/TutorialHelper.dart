import 'package:flutter/material.dart';
import 'package:safe/Constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class TutorialHelper {
  static const String _keyHomePageSeen = 'homepage_tutorial_seen';
  static const String _keyManageSeen = 'manage_tutorial_seen';
  static const String _keyGoalsSeen = 'goals_tutorial_seen';
  static const String _keyReceiptSeen = 'receipt_tutorial_seen';

  static Future<bool> _hasSeenTutorial(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? false;
  }

  static Future<void> _markTutorialAsSeen(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, true);
  }

  static Future<TutorialCoachMark> createHomeTutorial({
    required BuildContext context,
    required List<GlobalKey> keys,
  }) async {
    if (await _hasSeenTutorial(_keyHomePageSeen)) {
      return TutorialCoachMark(targets: []);
    }

    List<TargetFocus> targets = [
      TargetFocus(
        identify: "wallet_key",
        keyTarget: keys[0],
        alignSkip: Alignment.bottomRight,
        shape: ShapeLightFocus.RRect,
        radius: 10,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            customPosition: CustomTargetContentPosition(
              bottom: 20,
              left: 0,
              right: 0,
            ),
            builder: (context, controller) {
              return Container(
                padding: const EdgeInsets.all(15),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "هنا هتلاقي محفظتك وفلوسك",
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: Constants.defaultFontFamily,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      // Add more targets as needed
    ];

    await _markTutorialAsSeen(_keyHomePageSeen);
    return TutorialCoachMark(
      targets: targets,
      colorShadow: Constants.primaryColor,
      textSkip: "تخطي",
      textStyleSkip: const TextStyle(
        color: Colors.white,
        fontFamily: Constants.defaultFontFamily,
        fontSize: 20,
      ),
      paddingFocus: 10,
      opacityShadow: 0.8,
    );
  }

  static Future<TutorialCoachMark> createManageTutorial({
    required BuildContext context,
    required List<GlobalKey> keys,
  }) async {
    if (await _hasSeenTutorial(_keyManageSeen)) {
      return TutorialCoachMark(targets: []);
    }

    List<TargetFocus> targets = [
      TargetFocus(
        identify: "title_input",
        keyTarget: keys[0],
        alignSkip: Alignment.bottomRight,
        shape: ShapeLightFocus.RRect,
        radius: 10,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            customPosition: CustomTargetContentPosition(
              bottom: 20,
              left: 0,
              right: 0,
            ),
            builder: (context, controller) {
              return Container(
                padding: const EdgeInsets.all(15),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "اكتب هنا وصف المصروف أو الدخل",
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: Constants.defaultFontFamily,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      TargetFocus(
        identify: "amount_input",
        keyTarget: keys[1],
        alignSkip: Alignment.bottomRight,
        shape: ShapeLightFocus.RRect,
        radius: 10,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            customPosition: CustomTargetContentPosition(
              bottom: 20,
              left: 0,
              right: 0,
            ),
            builder: (context, controller) {
              return Container(
                padding: const EdgeInsets.all(15),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "اكتب هنا المبلغ",
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: Constants.defaultFontFamily,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    ];

    await _markTutorialAsSeen(_keyManageSeen);
    return TutorialCoachMark(
      targets: targets,
      colorShadow: Constants.primaryColor,
      textSkip: "تخطي",
      textStyleSkip: const TextStyle(
        color: Colors.white,
        fontFamily: Constants.defaultFontFamily,
        fontSize: 20,
      ),
      paddingFocus: 10,
      opacityShadow: 0.8,
    );
  }

  static Future<TutorialCoachMark> createGoalsTutorial({
    required BuildContext context,
    required List<GlobalKey> keys,
  }) async {
    if (await _hasSeenTutorial(_keyGoalsSeen)) {
      return TutorialCoachMark(targets: []);
    }

    List<TargetFocus> targets = [
      TargetFocus(
        identify: "add_goal",
        keyTarget: keys[0],
        alignSkip: Alignment.bottomRight,
        shape: ShapeLightFocus.RRect,
        radius: 10,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            customPosition: CustomTargetContentPosition(
              bottom: 20,
              left: 0,
              right: 0,
            ),
            builder: (context, controller) {
              return Container(
                padding: const EdgeInsets.all(15),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "اضغط هنا لإضافة هدف جديد",
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: Constants.defaultFontFamily,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    ];

    await _markTutorialAsSeen(_keyGoalsSeen);
    return TutorialCoachMark(
      targets: targets,
      colorShadow: Constants.primaryColor,
      textSkip: "تخطي",
      textStyleSkip: const TextStyle(
        color: Colors.white,
        fontFamily: Constants.defaultFontFamily,
        fontSize: 20,
      ),
      paddingFocus: 10,
      opacityShadow: 0.8,
    );
  }

  static Future<TutorialCoachMark> createReceiptTutorial({
    required BuildContext context,
    required List<GlobalKey> keys,
  }) async {
    if (await _hasSeenTutorial(_keyReceiptSeen)) {
      return TutorialCoachMark(targets: []);
    }

    List<TargetFocus> targets = [
      TargetFocus(
        identify: "empty_state",
        keyTarget: keys[0],
        alignSkip: Alignment.bottomRight,
        shape: ShapeLightFocus.RRect,
        radius: 10,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            customPosition: CustomTargetContentPosition(
              bottom: 20,
              left: 0,
              right: 0,
            ),
            builder: (context, controller) {
              return Container(
                padding: const EdgeInsets.all(15),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "اضغط على زر + لإضافة معاملة جديدة",
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: Constants.defaultFontFamily,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    ];

    await _markTutorialAsSeen(_keyReceiptSeen);
    return TutorialCoachMark(
      targets: targets,
      colorShadow: Constants.primaryColor,
      textSkip: "تخطي",
      textStyleSkip: const TextStyle(
        color: Colors.white,
        fontFamily: Constants.defaultFontFamily,
        fontSize: 20,
      ),
      paddingFocus: 10,
      opacityShadow: 0.8,
    );
  }
}
