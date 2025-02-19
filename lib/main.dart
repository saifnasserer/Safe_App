import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:safe/Constants.dart';
import 'package:safe/Screens/recipt_screen/recipt.dart';
import 'package:safe/Screens/goals_screen/Goals.dart';
import 'package:safe/Screens/home_screen/HomePage.dart';
import 'package:safe/Screens/introduction_screen.dart';
import 'package:safe/Screens/manage_screen/manage.dart';
import 'package:safe/providers/Goal_Provider.dart';
import 'package:safe/providers/Item_Provider.dart';
import 'package:safe/providers/profile_provider.dart';
import 'package:safe/utils/storage_service.dart';
import 'package:provider/provider.dart';
import 'package:safe/widgets/app_initializer.dart';

void main() async {
  await Future.delayed(const Duration(seconds: 2));
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Lock orientation to portrait mode only
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      debugPrint('Flutter Error: ${details.toString()}');
    };

    final profileProvider = ProfileProvider();
    await profileProvider.initialize();

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<ProfileProvider>.value(
            value: profileProvider,
          ),
          ChangeNotifierProxyProvider<ProfileProvider, ItemProvider>(
            create: (context) => ItemProvider(
              profileProvider,
              context,
            ),
            update: (context, profileProvider, previous) =>
                ItemProvider(profileProvider, context),
          ),
          ChangeNotifierProxyProvider<ProfileProvider, GoalProvider>(
            create: (context) => GoalProvider(profileProvider),
            update: (context, profileProvider, previous) =>
                GoalProvider(profileProvider),
          ),
        ],
        child: const AppInitializer(
          child: SafeApp(),
        ),
      ),
    );
  }, (error, stack) {
    debugPrint('Error caught by runZonedGuarded: $error');
    debugPrint('Stack trace: $stack');
  });
}

class SafeApp extends StatefulWidget {
  const SafeApp({super.key});

  @override
  State<SafeApp> createState() => _SafeAppState();
}

class _SafeAppState extends State<SafeApp> {
  bool _isFirstLaunch = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    final isFirstLaunch = await StorageService.isFirstLaunch();

    if (mounted) {
      setState(() {
        _isFirstLaunch = isFirstLaunch;
        _isLoading = false;
      });
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
            title: 'Safe',
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
                systemOverlayStyle: const SystemUiOverlayStyle(
                  statusBarColor: Colors.transparent,
                  statusBarIconBrightness: Brightness.dark,
                  statusBarBrightness: Brightness.light,
                ),
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
}
