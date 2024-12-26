import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:safe/Blocks/Spent.dart';
import 'package:safe/Blocks/Wallet.dart';
import 'package:safe/Constants.dart';
import 'package:safe/Screens/EmptyReciet.dart';
import 'package:safe/Screens/Goals.dart';
import 'package:safe/Screens/HomePage.dart';
import 'package:safe/Screens/introduction_screen.dart';
import 'package:safe/Screens/manage.dart';
import 'package:safe/providers/profile_provider.dart';
import 'package:safe/widgets/goals_screen_widgets/Goal_Provider.dart';
import 'package:safe/widgets/Item_Provider.dart';
import 'package:provider/provider.dart';
import 'package:safe/widgets/app_initializer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:safe/utils/version_control.dart';
import 'package:safe/widgets/update_notes_dialog.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait mode only
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('Flutter Error: ${details.toString()}');
  };

  final profileProvider = ProfileProvider();
  await profileProvider.initialize();

  runZonedGuarded(() {
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<ProfileProvider>.value(
            value: profileProvider,
          ),
          ChangeNotifierProxyProvider<ProfileProvider, ItemProvider>(
              create: (context) => ItemProvider(
                    context.read<ProfileProvider>(),
                    context,
                  ),
              update: (context, profileProvider, previous) =>
                  ItemProvider(profileProvider, context)),
          ChangeNotifierProxyProvider<ProfileProvider, GoalProvider>(
              create: (context) =>
                  GoalProvider(context.read<ProfileProvider>()),
              update: (context, profileProvider, previous) =>
                  GoalProvider(profileProvider)),
        ],
        child: const AppInitializer(
          child: PlanetApp(),
        ),
      ),
    );
  }, (error, stack) {
    debugPrint('Caught error: $error');
    debugPrint('Stack trace: $stack');
  });
}

class PlanetApp extends StatefulWidget {
  const PlanetApp({super.key});

  @override
  State<PlanetApp> createState() => _PlanetAppState();
}

class _PlanetAppState extends State<PlanetApp> {
  bool _isFirstLaunch = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstLaunch = prefs.getBool('hasSeenIntro') ?? true;

    if (mounted) {
      setState(() {
        _isFirstLaunch = isFirstLaunch;
        _isLoading = false;
      });
    }

    if (isFirstLaunch) {
      await prefs.setBool('hasSeenIntro', false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, child) {
        final primaryColor = Constants.getPrimaryColor(context);

        return OverlaySupport.global(
          child: MaterialApp(
            title: 'Planet',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              fontFamily: Constants.defaultFontFamily,
              colorScheme: ColorScheme.fromSeed(
                seedColor: primaryColor,
                brightness: Brightness.light,
              ),
              useMaterial3: true,
              appBarTheme: AppBarTheme(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
              ),
              floatingActionButtonTheme: FloatingActionButtonThemeData(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            home: _isFirstLaunch ? const IntroductionScreen() : const Home(),
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
          ),
        );
      },
    );
  }

  void _checkForUpdates(BuildContext context) async {
    try {
      if (await VersionControl.shouldShowUpdateNotes(context)) {
        final notes = VersionControl.getUpdateNotes();
        if (notes != null && mounted) {
          showDialog(
            context: context,
            builder: (context) => UpdateNotesDialog(
              version: VersionControl.currentVersion,
              notes: notes,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error checking for updates: $e');
    }
  }
}
