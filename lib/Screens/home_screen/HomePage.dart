import 'package:flutter/material.dart';
import 'package:safe/Screens/home_screen/Spent.dart';

import 'package:safe/Constants.dart';
import 'package:safe/Screens/home_screen/Wallet.dart';
import 'package:safe/utils/greeting_service.dart';
import 'package:safe/utils/storage_service.dart';
import 'package:safe/Screens/home_screen/profile_selector.dart';

class Home extends StatefulWidget {
  static const String id = 'HomePage';

  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String? _userName;

  @override
  void initState() {
    super.initState();
    _loadUserName();
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
            WalletBlock(title: GreetingService.getGreeting(_userName ?? '')),
            const Expanded(
              child: SpentBlock(),
            ),
          ],
        ),
      ),
    );
  }
}
