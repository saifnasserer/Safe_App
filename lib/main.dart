import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:safe/Constants.dart';
import 'package:safe/Screens/notes/notes_scree.dart';
import 'package:safe/Screens/recipt_screen/recipt.dart';
import 'package:safe/Screens/goals_screen/Goals.dart';
import 'package:safe/Screens/home_screen/HomePage.dart';
import 'package:safe/Screens/introduction_screen.dart';
import 'package:safe/Screens/manage_screen/manage.dart';
import 'package:safe/providers/Goal_Provider.dart';
import 'package:safe/providers/Item_Provider.dart';
import 'package:safe/providers/profile_provider.dart';
import 'package:safe/providers/receipt_provider.dart';
import 'package:safe/utils/storage_service.dart';
import 'package:provider/provider.dart';
import 'package:safe/widgets/app_initializer.dart';
import 'package:safe/services/navigation_service.dart';
import 'package:safe/services/share_intent_handler.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:safe/widgets/share_loading_screen.dart';

// Deferred imports for better performance
import 'package:safe/Screens/notes/notes_scree.dart' deferred as notes_deferred;
import 'package:safe/Screens/recipt_screen/recipt.dart'
    deferred as receipt_deferred;
import 'package:safe/Screens/receipt_screen/receipt_list_screen.dart'
    deferred as receipt_list_deferred;
import 'package:safe/Screens/goals_screen/Goals.dart'
    deferred as goals_deferred;
import 'package:safe/Screens/manage_screen/manage.dart'
    deferred as manage_deferred;

/// Check if app was launched via share intent
Future<bool> _checkForInitialShareIntent() async {
  try {
    final initialMedia = await ReceiveSharingIntent.instance.getInitialMedia();
    print('🔍 [Main] Initial media check: ${initialMedia.length} items');
    if (initialMedia.isNotEmpty) {
      print(
          '📱 [Main] Found initial shared media: ${initialMedia.map((m) => m.path).join(', ')}');
      return true;
    }
    return false;
  } catch (e) {
    print('❌ [Main] Error checking initial share intent: $e');
    return false;
  }
}

void main() async {
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

    // Preload deferred libraries for better performance
    await _preloadDeferredLibraries();

    // Initialize core providers
    final profileProvider = ProfileProvider();
    await profileProvider.initialize();

    // Initialize ShareIntentHandler for all share intents
    final shareIntentHandler = ShareIntentHandler();
    shareIntentHandler.initialize(processInitialMedia: true);

    print('📱 [Main] App initialized with share intent support');

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
          ChangeNotifierProvider<ReceiptProvider>(
            create: (context) => ReceiptProvider(),
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

/// Preload deferred libraries for better performance
Future<void> _preloadDeferredLibraries() async {
  try {
    print('🚀 [Main] Preloading deferred libraries...');
    await Future.wait([
      notes_deferred.loadLibrary(),
      receipt_deferred.loadLibrary(),
      receipt_list_deferred.loadLibrary(),
      goals_deferred.loadLibrary(),
      manage_deferred.loadLibrary(),
    ]);
    print('✅ [Main] Deferred libraries preloaded successfully');
  } catch (e) {
    print('⚠️ [Main] Error preloading deferred libraries: $e');
  }
}

class SafeApp extends StatefulWidget {
  const SafeApp({super.key});

  @override
  State<SafeApp> createState() => _SafeAppState();
}

class _SafeAppState extends State<SafeApp> {
  bool _isFirstLaunch = false;
  bool _isLoading = true;
  bool _hasInitialShareIntent = false;

  @override
  void initState() {
    super.initState();
    _checkAppState();
  }

  Future<void> _checkAppState() async {
    // Check for initial share intent first
    final hasInitialMedia = await _checkForInitialShareIntent();

    // Check if it's first launch
    final isFirstLaunch = await StorageService.isFirstLaunch();

    if (mounted) {
      setState(() {
        _hasInitialShareIntent = hasInitialMedia;
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

        // Determine the initial screen based on app state
        Widget initialScreen;
        if (_hasInitialShareIntent) {
          print('📱 [SafeApp] Showing loading screen for share intent');
          initialScreen = const ShareLoadingScreen();
        } else if (_isFirstLaunch) {
          print('📱 [SafeApp] Showing introduction screen for first launch');
          initialScreen = const IntroductionScreen();
        } else {
          print('📱 [SafeApp] Showing home screen for normal launch');
          initialScreen = const Home();
        }

        return OverlaySupport.global(
          child: MaterialApp(
            title: 'Safe',
            debugShowCheckedModeBanner: false,
            navigatorKey: NavigationService().navigatorKey,
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
            home: initialScreen,
            routes: {
              Home.id: (context) => const Home(),
              GoalsBlock.goalsID: (context) => goals_deferred.GoalsBlock(),
              Reciept.id: (context) => receipt_deferred.Reciept(),
              Manage.id: (context) => manage_deferred.Manage(),
              notes.id: (context) => notes_deferred.notes(),
              '/receipts': (context) =>
                  receipt_list_deferred.ReceiptListScreen(),
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
