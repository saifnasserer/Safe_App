import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safe/services/share_intent_service.dart';
import 'package:safe/Screens/share_intent_loading_screen.dart';
import 'package:safe/Screens/introduction_screen.dart';
import 'package:safe/utils/storage_service.dart';
import 'package:safe/providers/profile_provider.dart';
import 'package:safe/providers/Item_Provider.dart';
import 'package:safe/providers/Goal_Provider.dart';
import 'package:safe/providers/receipt_provider.dart';
import 'package:safe/widgets/app_initializer.dart';

/// Lightweight app initializer for share intent launches
class LightweightAppInitializer extends StatefulWidget {
  final Widget child;

  const LightweightAppInitializer({super.key, required this.child});

  @override
  State<LightweightAppInitializer> createState() => _LightweightAppInitializerState();
}

class _LightweightAppInitializerState extends State<LightweightAppInitializer> {
  bool _isInitializing = true;
  bool _isShareIntentLaunch = false;
  bool _isFirstLaunch = false;
  bool _providersInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Check if this is a share intent launch
      final isShareIntent = await ShareIntentService.isShareIntentLaunch();
      
      if (isShareIntent) {
        // Skip heavy initialization for share intents
        setState(() {
          _isShareIntentLaunch = true;
          _isInitializing = false;
        });
        return;
      }

      // For normal launches, initialize providers
      await _initializeProviders();
      
      // Check if it's first launch
      final isFirstLaunch = await StorageService.isFirstLaunch();
      
      setState(() {
        _isFirstLaunch = isFirstLaunch;
        _isInitializing = false;
      });
    } catch (e) {
      print('Error in lightweight app initialization: $e');
      setState(() {
        _isInitializing = false;
      });
    }
  }

  Future<void> _initializeProviders() async {
    if (_providersInitialized) return;
    
    try {
      // Initialize ProfileProvider
      final profileProvider = ProfileProvider();
      await profileProvider.initialize();
      
      setState(() {
        _providersInitialized = true;
      });
    } catch (e) {
      print('Error initializing providers: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (_isShareIntentLaunch) {
      // Show share intent loading screen
      return const MaterialApp(
        home: ShareIntentLoadingScreen(),
      );
    }

    if (_isFirstLaunch) {
      // Show introduction screen for first launch
      return const MaterialApp(
        home: IntroductionScreen(),
      );
    }

    // Show normal app with full provider initialization
    if (_providersInitialized) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<ProfileProvider>(
            create: (context) => ProfileProvider()..initialize(),
          ),
          ChangeNotifierProxyProvider<ProfileProvider, ItemProvider>(
            create: (context) => ItemProvider(
              Provider.of<ProfileProvider>(context, listen: false),
              context,
            ),
            update: (context, profileProvider, previous) =>
                ItemProvider(profileProvider, context),
          ),
          ChangeNotifierProxyProvider<ProfileProvider, GoalProvider>(
            create: (context) => GoalProvider(
              Provider.of<ProfileProvider>(context, listen: false),
            ),
            update: (context, profileProvider, previous) =>
                GoalProvider(profileProvider),
          ),
          ChangeNotifierProvider<ReceiptProvider>(
            create: (context) => ReceiptProvider(),
          ),
        ],
        child: AppInitializer(
          child: widget.child,
        ),
      );
    }

    // Still initializing providers
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
