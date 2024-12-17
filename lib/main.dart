import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:safe/Blocks/Spent.dart';
import 'package:safe/Blocks/Wallet.dart';
import 'package:safe/Constants.dart';
import 'package:safe/Screens/EmptyReciet.dart';
import 'package:safe/Screens/Goals.dart';
import 'package:safe/Screens/HomePage.dart';
import 'package:safe/Screens/introduction_screen.dart';
import 'package:safe/Screens/manage.dart';
import 'package:safe/widgets/Goal_Provider.dart';
import 'package:safe/widgets/Item_Provider.dart';
import 'package:provider/provider.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize wallet and spent values
  await WalletBlock.initWallet();
  await SpentBlock.initSpent();

  // Lock orientation to portrait mode only
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('Flutter Error: ${details.toString()}');
  };

  runZonedGuarded(() {
    runApp(
      OverlaySupport.global(
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider<ItemProvider>(create: (_) => ItemProvider()),
            ChangeNotifierProvider<GoalProvider>(create: (_) => GoalProvider()),
          ],
          child: const PlanetApp(),
        ),
      ),
    );
  }, (error, stack) {
    debugPrint('Caught error: $error');
    debugPrint('Stack trace: $stack');
  });
}

class PlanetApp extends StatelessWidget {
  const PlanetApp({super.key});

  Future<bool> _isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenIntro = prefs.getBool('hasSeenIntro') ?? false;
    return !hasSeenIntro;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Planet',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: Constants.defaultFontFamily,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xff4558c8),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: FutureBuilder<bool>(
        future: _isFirstLaunch(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          return snapshot.data == true
              ? const IntroductionScreen()
              : const Home();
        },
      ),
      routes: {
        Home.id: (context) => const Home(),
        GoalsBlock.goalsID: (context) => const GoalsBlock(),
        Reciept.id: (context) => const Reciept(),
        Manage.id: (context) => const Manage(),
      },
      builder: (context, child) {
        return ScrollConfiguration(
          behavior: const ScrollBehavior().copyWith(
            physics: const BouncingScrollPhysics(),
          ),
          child: child!,
        );
      },
    );
  }
}
