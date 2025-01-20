// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:safe/Screens/manage_screen/manage_widgets/calculator_keypad.dart';
import 'package:safe/Screens/manage_screen/manage_widgets/transaction_input_form.dart';
import 'package:safe/providers/Goal_Provider.dart';
import 'package:safe/providers/Item_Provider.dart';
import 'package:safe/providers/profile_provider.dart';
import 'package:safe/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:safe/Screens/home_screen/HomePage.dart';
import 'package:safe/Screens/introduction_screen.dart';

void main() {
  group('PlanetApp Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('shows loading indicator initially',
        (WidgetTester tester) async {
      final profileProvider = ProfileProvider();
      await profileProvider.initialize();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<ProfileProvider>.value(
              value: profileProvider,
            ),
            ChangeNotifierProxyProvider<ProfileProvider, ItemProvider>(
              create: (context) => ItemProvider(profileProvider, context),
              update: (context, profileProvider, previous) =>
                  ItemProvider(profileProvider, context),
            ),
            ChangeNotifierProxyProvider<ProfileProvider, GoalProvider>(
              create: (context) => GoalProvider(profileProvider),
              update: (context, profileProvider, previous) =>
                  GoalProvider(profileProvider),
            ),
          ],
          child: const SafeApp(),
        ),
      );

      // Initially should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('navigates to Home after loading when not first launch',
        (WidgetTester tester) async {
      // Set up SharedPreferences to indicate not first launch
      SharedPreferences.setMockInitialValues(
          {'isFirstLaunch': false, 'userName': 'Test User'});

      final profileProvider = ProfileProvider();
      await profileProvider.initialize();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<ProfileProvider>.value(
              value: profileProvider,
            ),
            ChangeNotifierProxyProvider<ProfileProvider, ItemProvider>(
              create: (context) => ItemProvider(profileProvider, context),
              update: (context, profileProvider, previous) =>
                  ItemProvider(profileProvider, context),
            ),
            ChangeNotifierProxyProvider<ProfileProvider, GoalProvider>(
              create: (context) => GoalProvider(profileProvider),
              update: (context, profileProvider, previous) =>
                  GoalProvider(profileProvider),
            ),
          ],
          child: const SafeApp(),
        ),
      );

      // Wait for loading to complete
      await tester.pumpAndSettle();

      // Should show Home screen
      expect(find.byType(Home), findsOneWidget);
    });
  });

  group('Introduction Screen Tests', () {
    late ProfileProvider profileProvider;

    setUp(() async {
      SharedPreferences.setMockInitialValues({'isFirstLaunch': true});
      profileProvider = ProfileProvider();
      await profileProvider.initialize();
    });

    Widget buildTestableWidget(Widget child) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<ProfileProvider>.value(
            value: profileProvider,
          ),
          ChangeNotifierProxyProvider<ProfileProvider, ItemProvider>(
            create: (context) => ItemProvider(profileProvider, context),
            update: (context, profileProvider, previous) =>
                ItemProvider(profileProvider, context),
          ),
          ChangeNotifierProxyProvider<ProfileProvider, GoalProvider>(
            create: (context) => GoalProvider(profileProvider),
            update: (context, profileProvider, previous) =>
                GoalProvider(profileProvider),
          ),
        ],
        child: MaterialApp(home: child),
      );
    }

    testWidgets('shows welcome message and name input',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const IntroductionScreen()));

      // Verify welcome message is shown
      expect(find.text('اهلاً بيك يغالي'), findsOneWidget);

      // Verify name input field exists
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('validates empty name input', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const IntroductionScreen()));

      // Navigate to the last page
      await tester.tap(find.text('تخطي'));
      await tester.pumpAndSettle();

      // Try to complete introduction without entering name
      await tester.enterText(find.byType(TextField), '');
      await tester.pump();

      // Verify error message is shown
      expect(find.text('من فضلك اكتب اسمك الأول'), findsOneWidget);
    });

    testWidgets('saves name and proceeds to home', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const IntroductionScreen()));

      // Navigate to the last page
      await tester.tap(find.text('تخطي'));
      await tester.pumpAndSettle();

      // Enter name
      await tester.enterText(find.byType(TextField), 'Test User');
      await tester.pump();

      // Complete introduction
      await tester.tap(find.text('تخطي'));
      await tester.pumpAndSettle();

      // Verify navigation to home screen
      expect(find.byType(IntroductionScreen), findsNothing);
      expect(find.byType(Home), findsOneWidget);
    });
  });

  group('Calculator Keypad Tests', () {
    testWidgets('renders calculator buttons correctly',
        (WidgetTester tester) async {
      String pressedButton = '';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalculatorKeypad(
              onButtonPressed: (value) {
                pressedButton = value;
              },
            ),
          ),
        ),
      );

      // Verify numeric buttons are present
      for (int i = 0; i <= 9; i++) {
        expect(find.text('$i'), findsOneWidget);
      }

      // Verify operator buttons
      expect(find.text('+'), findsOneWidget);
      expect(find.text('-'), findsOneWidget);
      expect(find.text('*'), findsOneWidget);
      expect(find.text('/'), findsOneWidget);
      expect(find.text('.'), findsOneWidget);
    });

    testWidgets('handles button press correctly', (WidgetTester tester) async {
      String pressedButton = '';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalculatorKeypad(
              onButtonPressed: (value) {
                pressedButton = value;
              },
            ),
          ),
        ),
      );

      // Test pressing a number
      await tester.tap(find.text('5'));
      expect(pressedButton, '5');

      // Test pressing an operator
      await tester.tap(find.text('+'));
      expect(pressedButton, '+');
    });
  });

  group('Transaction Input Form Tests', () {
    testWidgets('renders form fields correctly', (WidgetTester tester) async {
      final titleController = TextEditingController();
      final amountController = TextEditingController();
      final amountFocusNode = FocusNode();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TransactionInputForm(
              titleController: titleController,
              amountController: amountController,
              amountFocusNode: amountFocusNode,
              isCalculatorMode: false,
              onToggleCalculator: () {},
              onDateSelect: () {},
              onCalculatorButtonPressed: (_) {},
            ),
          ),
        ),
      );

      // Verify title input exists
      expect(find.byType(TextField),
          findsNWidgets(2)); // Two text fields: title and amount
      expect(find.text('وصف المعاملة'), findsOneWidget);

      // Verify calculator toggle button exists
      expect(find.byIcon(Icons.calculate), findsOneWidget);

      // Verify date picker button exists
      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
    });

    testWidgets('toggles calculator mode', (WidgetTester tester) async {
      bool calculatorMode = false;
      final titleController = TextEditingController();
      final amountController = TextEditingController();
      final amountFocusNode = FocusNode();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TransactionInputForm(
              titleController: titleController,
              amountController: amountController,
              amountFocusNode: amountFocusNode,
              isCalculatorMode: calculatorMode,
              onToggleCalculator: () {
                calculatorMode = !calculatorMode;
              },
              onDateSelect: () {},
              onCalculatorButtonPressed: (_) {},
            ),
          ),
        ),
      );

      // Toggle calculator mode
      await tester.tap(find.byIcon(Icons.calculate));
      await tester.pump();

      expect(calculatorMode, true);
    });
  });
}
