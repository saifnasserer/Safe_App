import 'package:flutter/material.dart';
import 'package:safe/Constants.dart';
import 'package:safe/utils/FirstUse.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class TutorialHelper {
  static Future<TutorialCoachMark?> createHomeTutorial({
    required BuildContext context,
    required List<GlobalKey> keys,
  }) async {
    final appTutorial = AppTutorial();
    final isFirstUse = await appTutorial.isHomeFirstUse();
    if (!isFirstUse) return null;

    List<TargetFocus> targets = [
      TargetFocus(
        identify: "wallet_key",
        keyTarget: keys[0],
        alignSkip: Alignment.bottomRight,
        shape: ShapeLightFocus.RRect,
        radius: 10,
        contents: [
          TargetContent(
            align: ContentAlign.custom,
            customPosition: CustomTargetContentPosition(
              bottom: 100,
              left: 20,
              right: 20,
            ),
            builder: (context, controller) {
              return Container(
                padding: const EdgeInsets.all(15),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "هنا هيبقا موجود كل الفلوس اللي موجوده ف محفظتك او الفلوس اللي بتضيفها ك دخل",
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: Constants.secondaryFontFamily,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => controller.next(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Constants.getPrimaryColor(context),
                      ),
                      child: const Text(
                        'التالي',
                        style: TextStyle(
                          fontFamily: Constants.secondaryFontFamily,
                          fontWeight: FontWeight.bold,
                        ),
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
        identify: "spent_key",
        keyTarget: keys[1],
        alignSkip: Alignment.bottomRight,
        shape: ShapeLightFocus.RRect,
        radius: 10,
        contents: [
          TargetContent(
            align: ContentAlign.custom,
            customPosition: CustomTargetContentPosition(
              top: 100,
              left: 20,
              right: 20,
            ),
            builder: (context, controller) {
              return Container(
                padding: const EdgeInsets.all(15),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "هنا هتلاقي كل مصاريفك اللي صرفتها سجلتها علي مدار اليوم وجرب دوس علي الزرار اللي اسمه النهارده ، هسيبك تكتشف بيعمل ايه",
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: Constants.secondaryFontFamily,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => controller.next(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Constants.getPrimaryColor(context),
                      ),
                      child: const Text(
                        'تم',
                        style: TextStyle(
                          fontFamily: Constants.secondaryFontFamily,
                          fontWeight: FontWeight.bold,
                        ),
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

    return TutorialCoachMark(
      targets: targets,
      colorShadow: Constants.getPrimaryColor(context),
      textSkip: "تخطي",
      paddingFocus: 10,
      opacityShadow: 0.8,
      onFinish: () {
        final appTutorial = AppTutorial();
        appTutorial.markHomeFirstUseComplete();
      },
      onClickTarget: (target) {
        print('Clicked target: ${target.identify}');
      },
      onSkip: () {
        final appTutorial = AppTutorial();
        appTutorial.markHomeFirstUseComplete();
        return true;
      },
    );
  }

  static Future<TutorialCoachMark?> createManageTutorial({
    required BuildContext context,
    required List<GlobalKey> keys,
  }) async {
    final appTutorial = AppTutorial();
    final isFirstUse = await appTutorial.isManageFirstUse();
    if (!isFirstUse) return null;

    List<TargetFocus> targets = [
      TargetFocus(
        identify: "transaction_section",
        keyTarget: keys[0], // _transactionSectionKey
        alignSkip: Alignment.bottomRight,
        shape: ShapeLightFocus.RRect,
        radius: 10,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            customPosition: CustomTargetContentPosition(
              bottom: 20,
              left: 20,
              right: 20,
            ),
            builder: (context, controller) {
              return Container(
                padding: const EdgeInsets.all(15),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "بعد م تضيف المبلغ والوصف لو الحاجة دي كانت دخل زي مرتب علي سبيل المثال اضغط علي دخل ، \n \n اما لو حاجة صرفتها او فلوس خرجت من محفظتك ف وقتها صرف",
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: Constants.defaultFontFamily,
                        fontSize: 20,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => controller.next(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Constants.getPrimaryColor(context),
                      ),
                      child: const Text(
                        'التالي',
                        style: TextStyle(
                          fontFamily: Constants.secondaryFontFamily,
                          fontWeight: FontWeight.bold,
                        ),
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
        identify: "add_goal",
        keyTarget: keys[1], // _addGoalKey
        alignSkip: Alignment.bottomRight,
        shape: ShapeLightFocus.RRect,
        radius: 10,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            customPosition: CustomTargetContentPosition(
              top: -120,
              left: 20,
              right: 20,
            ),
            builder: (context, controller) {
              return Container(
                padding: const EdgeInsets.all(15),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "هنا هيظهر اول هدف في قائمة اهدافك عشان يفضل قدامك دايماً وتقدر تشوفة كل م تيجي تصرف ف ضميرك يأنبك",
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: Constants.defaultFontFamily,
                        fontSize: 20,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => controller.skip(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.grey,
                      ),
                      child: const Text(
                        'تم',
                        style: TextStyle(
                          fontFamily: Constants.secondaryFontFamily,
                          fontWeight: FontWeight.bold,
                        ),
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

    return TutorialCoachMark(
      targets: targets,
      colorShadow: Constants.getPrimaryColor(context),
      textSkip: "تخطي",
      paddingFocus: 10,
      opacityShadow: 0.8,
      onFinish: () {
        final appTutorial = AppTutorial();
        appTutorial.markManageFirstUseComplete();
      },
      onClickTarget: (target) {
        print('Clicked target: ${target.identify}');
      },
      onSkip: () {
        final appTutorial = AppTutorial();
        appTutorial.markManageFirstUseComplete();
        return true;
      },
    );
  }
}
