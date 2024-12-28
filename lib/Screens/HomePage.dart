import 'package:flutter/material.dart';
import 'package:safe/Blocks/Spent.dart';
import 'package:safe/Blocks/Wallet.dart';
import 'package:safe/Constants.dart';
import 'package:safe/utils/greeting_service.dart';
import 'package:safe/utils/storage_service.dart';
import 'package:safe/widgets/profile_selector.dart';

class Home extends StatefulWidget {
  static const String id = 'HomePage';

  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user_name = StorageService.getUserName();
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
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            WalletBlock(title: GreetingService.getGreeting('sd')),
            SpentBlock(),
          ],
        ),
      ),
    );
  }
}
