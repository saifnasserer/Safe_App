import 'package:flutter/material.dart';
import 'package:safe/Screens/home_screen/Spent.dart';

import 'package:safe/Constants.dart';
import 'package:safe/Screens/home_screen/Wallet.dart';
import 'package:safe/utils/greeting_service.dart';
import 'package:safe/utils/storage_service.dart';
import 'package:safe/Screens/home_screen/profile_selector.dart';
import 'package:safe/utils/TutorialHelper.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class Home extends StatefulWidget {
  static const String id = 'HomePage';

  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String? _userName;
  final GlobalKey _walletKey = GlobalKey();
  final GlobalKey _spentKey = GlobalKey();
  late TutorialCoachMark? tutorialCoachMark;

  @override
  void initState() {
    super.initState();
    _loadUserName();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initTutorial();
    });
  }

  Future<void> _initTutorial() async {
    tutorialCoachMark = await TutorialHelper.createHomeTutorial(
      context: context,
      keys: [_walletKey, _spentKey],
    );
    if (tutorialCoachMark != null) {
      tutorialCoachMark!.show(context: context);
    }
  }

  Future<void> _loadUserName() async {
    final userName = await StorageService.getUserName();
    setState(() {
      _userName = userName;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const ProfileSelector(),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Constants.getPrimaryColor(context),
        ),
      ),
      backgroundColor: const Color(0xffefefef),
      body: SafeArea(
        child: Column(
          children: [
            WalletBlock(
              key: _walletKey,
              title: GreetingService.getGreeting(_userName ?? ''),
            ),
            Expanded(
              child: SpentBlock(key: _spentKey),
            ),
          ],
        ),
      ),
    );
  }
}
