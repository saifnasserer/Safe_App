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
        radius: Constants.responsiveRadius(context, 10),
        contents: [
          TargetContent(
            align: ContentAlign.custom,
            customPosition: CustomTargetContentPosition(
              bottom: Constants.responsiveSpacing(context, 100),
              left: Constants.responsiveSpacing(context, 20),
              right: Constants.responsiveSpacing(context, 20),
            ),
            builder: (context, controller) {
              return Container(
                padding: EdgeInsets.all(Constants.responsiveSpacing(context, 15)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "هنا هيبقا موجود كل الفلوس اللي موجوده ف محفظتك او الفلوس اللي بتضيفها ك دخل",
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: Constants.secondaryFontFamily,
                        fontSize: Constants.responsiveFontSize(context, 20),
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: Constants.responsiveSpacing(context, 10)),
                    ElevatedButton(
                      onPressed: () => controller.next(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Constants.getPrimaryColor(context),
                        padding: EdgeInsets.symmetric(
                          horizontal: Constants.responsiveSpacing(context, 20),
                          vertical: Constants.responsiveSpacing(context, 10),
                        ),
                      ),
                      child: Text(
                        'التالي',
                        style: TextStyle(
                          fontFamily: Constants.secondaryFontFamily,
                          fontWeight: FontWeight.bold,
                          fontSize: Constants.responsiveFontSize(context, 16),
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
        radius: Constants.responsiveRadius(context, 10),
        contents: [
          TargetContent(
            align: ContentAlign.custom,
            customPosition: CustomTargetContentPosition(
              top: Constants.responsiveSpacing(context, 100),
              left: Constants.responsiveSpacing(context, 20),
              right: Constants.responsiveSpacing(context, 20),
            ),
            builder: (context, controller) {
              return Container(
                padding: EdgeInsets.all(Constants.responsiveSpacing(context, 15)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "هنا هتلاقي كل مصاريفك اللي صرفتها سجلتها علي مدار اليوم وجرب دوس علي الزرار اللي اسمه النهارده ، هسيبك تكتشف بيعمل ايه",
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: Constants.secondaryFontFamily,
                        fontSize: Constants.responsiveFontSize(context, 20),
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: Constants.responsiveSpacing(context, 10)),
                    ElevatedButton(
                      onPressed: () => controller.next(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Constants.getPrimaryColor(context),
                        padding: EdgeInsets.symmetric(
                          horizontal: Constants.responsiveSpacing(context, 20),
                          vertical: Constants.responsiveSpacing(context, 10),
                        ),
                      ),
                      child: Text(
                        'تم',
                        style: TextStyle(
                          fontFamily: Constants.secondaryFontFamily,
                          fontWeight: FontWeight.bold,
                          fontSize: Constants.responsiveFontSize(context, 16),
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
      paddingFocus: Constants.responsiveSpacing(context, 10),
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
        radius: Constants.responsiveRadius(context, 10),
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            customPosition: CustomTargetContentPosition(
              bottom: Constants.responsiveSpacing(context, 20),
              left: Constants.responsiveSpacing(context, 20),
              right: Constants.responsiveSpacing(context, 20),
            ),
            builder: (context, controller) {
              return Container(
                padding: EdgeInsets.all(Constants.responsiveSpacing(context, 15)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "بعد م تضيف المبلغ والوصف لو الحاجة دي كانت دخل زي مرتب علي سبيل المثال اضغط علي دخل ، \n \n اما لو حاجة صرفتها او فلوس خرجت من محفظتك ف وقتها صرف",
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: Constants.defaultFontFamily,
                        fontSize: Constants.responsiveFontSize(context, 20),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: Constants.responsiveSpacing(context, 10)),
                    ElevatedButton(
                      onPressed: () => controller.next(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Constants.getPrimaryColor(context),
                        padding: EdgeInsets.symmetric(
                          horizontal: Constants.responsiveSpacing(context, 20),
                          vertical: Constants.responsiveSpacing(context, 10),
                        ),
                      ),
                      child: Text(
                        'التالي',
                        style: TextStyle(
                          fontFamily: Constants.secondaryFontFamily,
                          fontWeight: FontWeight.bold,
                          fontSize: Constants.responsiveFontSize(context, 16),
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
        radius: Constants.responsiveRadius(context, 10),
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            customPosition: CustomTargetContentPosition(
              top: -Constants.responsiveSpacing(context, 120),
              left: Constants.responsiveSpacing(context, 20),
              right: Constants.responsiveSpacing(context, 20),
            ),
            builder: (context, controller) {
              return Container(
                padding: EdgeInsets.all(Constants.responsiveSpacing(context, 15)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "هنا هيظهر اول هدف في قائمة اهدافك عشان يفضل قدامك دايماً وتقدر تشوفة كل م تيجي تصرف ف ضميرك يأنبك",
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: Constants.defaultFontFamily,
                        fontSize: Constants.responsiveFontSize(context, 20),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: Constants.responsiveSpacing(context, 10)),
                    ElevatedButton(
                      onPressed: () => controller.skip(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.grey,
                        padding: EdgeInsets.symmetric(
                          horizontal: Constants.responsiveSpacing(context, 20),
                          vertical: Constants.responsiveSpacing(context, 10),
                        ),
                      ),
                      child: Text(
                        'تم',
                        style: TextStyle(
                          fontFamily: Constants.secondaryFontFamily,
                          fontWeight: FontWeight.bold,
                          fontSize: Constants.responsiveFontSize(context, 16),
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
      paddingFocus: Constants.responsiveSpacing(context, 10),
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
