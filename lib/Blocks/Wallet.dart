import 'package:flutter/material.dart';
import 'package:safe/Constants.dart';
import 'package:safe/utils/storage_service.dart';

class WalletBlock extends StatefulWidget {
  const WalletBlock({required this.title, super.key});
  final String title;

  // Using a ValueNotifier to track wallet changes
  static ValueNotifier<double> wallet = ValueNotifier<double>(0);

  // Method to update the wallet
  static Future<void> updateWallet(double newValue) async {
    wallet.value = newValue;
    await StorageService.saveWalletBalance(newValue);
  }

  static Future<void> initWallet() async {
    wallet.value = await StorageService.loadWalletBalance();
  }

  @override
  State<WalletBlock> createState() => _WalletBlockState();
}

class _WalletBlockState extends State<WalletBlock>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _controller.forward();
    WalletBlock.initWallet();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Center(
      child: Stack(
        children: [
          Positioned(
            top: screenHeight * 0.15,
            left: screenWidth * 0.08,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Transform.scale(
                scale: 0.1,
                child: Image.asset('assets/coins/7.png'),
              ),
            ),
          ),
          Positioned(
            top: screenHeight * 0.15,
            right: screenWidth * 0.08,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Transform.scale(
                scale: 0.2,
                child: Image.asset('assets/coins/1.png'),
              ),
            ),
          ),
          Positioned(
            top: screenHeight * -0.03,
            left: screenWidth * 0.1,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Transform.scale(
                scale: 0.07,
                child: Image.asset('assets/coins/main coin.png'),
              ),
            ),
          ),
          Positioned(
            top: screenHeight * 0.35,
            left: screenWidth * 0.35,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Transform.scale(
                scale: 0.1,
                child: Image.asset('assets/coins/4.png'),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: screenHeight * 0.1),
                Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: screenWidth * 0.12,
                    fontWeight: FontWeight.bold,
                    fontFamily: Constants.defaultFontFamily,
                  ),
                ),
                SizedBox(height: screenHeight * 0.05),
                Text(
                  "محفظتك فيها",
                  style: TextStyle(
                    fontSize: screenWidth * 0.05,
                    fontFamily: Constants.secondaryFontFamily,
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),
                Padding(
                  padding: EdgeInsets.only(
                      left: screenWidth * .1, right: screenWidth * 0.1),
                  child: ValueListenableBuilder<double>(
                    valueListenable: WalletBlock.wallet,
                    builder: (context, value, child) {
                      return Text(
                        value.toString(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: screenWidth * 0.2,
                          fontFamily: Constants.defaultFontFamily,
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),
                Text(
                  "جنية",
                  style: TextStyle(
                    fontSize: screenWidth * 0.05,
                    fontFamily: Constants.secondaryFontFamily,
                  ),
                ),
                SizedBox(height: screenHeight * 0.05),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
