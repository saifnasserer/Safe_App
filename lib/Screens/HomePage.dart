import 'package:flutter/material.dart';
import 'package:safe/Blocks/Spent.dart';
import 'package:safe/Blocks/Wallet.dart';

class Home extends StatefulWidget {
  const Home({super.key});
  static const id = 'home id';
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
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
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        backgroundColor: const Color(0xffefefef),
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              SizedBox(
                height: screenHeight * .5,
                child: const WalletBlock(
                  title: "ازيك ي قمر",
                ),
              ),
              const SpentBlock()
            ],
          ),
        ));
  }
}
