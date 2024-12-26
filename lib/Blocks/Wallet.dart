import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:safe/Constants.dart';
import 'package:safe/providers/profile_provider.dart';
import 'package:safe/Screens/manage.dart';
import 'package:safe/utils/storage_service.dart';

class WalletBlock extends StatefulWidget {
  const WalletBlock({required this.title, super.key});
  final String title;

  static ValueNotifier<double> wallet = ValueNotifier<double>(0.0);

  static Future<void> updateWallet(
      BuildContext context, double newValue) async {
    final profileProvider = context.read<ProfileProvider>();
    if (profileProvider.currentProfile != null) {
      wallet.value = newValue;
      await StorageService.saveWalletBalance(
          profileProvider.currentProfile!.id, newValue);
    }
  }

  static Future<void> initWallet(BuildContext context) async {
    final profileProvider = context.read<ProfileProvider>();
    if (profileProvider.currentProfile != null) {
      wallet.value = await StorageService.loadWalletBalance(
          profileProvider.currentProfile!.id);
    }
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
    WalletBlock.initWallet(context);
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
            top: screenHeight * 0.158,
            left: screenWidth * 0.3,
            child: Lottie.asset(
              'assets/animation/Underline.json',
              animate: true,
              repeat: false,
            ),
          ),
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
                Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: screenWidth * 0.12,
                    fontWeight: FontWeight.bold,
                    fontFamily: Constants.titles,
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
                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          Navigator.pushNamed(context, Manage.id);
                        },
                        child: Text(
                          value.toStringAsFixed(2),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: screenWidth * 0.2,
                            fontFamily: Constants.defaultFontFamily,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: screenHeight * 0.008),
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
