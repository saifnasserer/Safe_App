import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safe/Constants.dart';
import 'package:safe/providers/profile_provider.dart';
import 'package:safe/Screens/manage.dart';
import 'package:safe/utils/storage_service.dart';
import 'package:safe/widgets/wallet_widgets/balance_display.dart';

class WalletBlock extends StatefulWidget {
  final String title;
  static final Map<String, ValueNotifier<double>> balanceByProfile = {};

  const WalletBlock({super.key, required this.title});

  static Future<void> updateWalletBalance(
      BuildContext context, double newBalance) async {
    final profileProvider = context.read<ProfileProvider>();
    if (profileProvider.currentProfile != null) {
      final profileId = profileProvider.currentProfile!.id;
      balanceByProfile[profileId]?.value = newBalance;
      await StorageService.saveWalletBalance(profileId, newBalance);
    }
  }

  static Future<void> initWallet(BuildContext context) async {
    final profileProvider = context.read<ProfileProvider>();
    if (profileProvider.currentProfile != null) {
      final profileId = profileProvider.currentProfile!.id;
      if (!balanceByProfile.containsKey(profileId)) {
        balanceByProfile[profileId] = ValueNotifier<double>(0.0);
      }
      balanceByProfile[profileId]!.value =
          await StorageService.loadWalletBalance(profileId);
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WalletBlock.initWallet(context);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    final currentProfileId = profileProvider.currentProfile?.id;

    if (currentProfileId == null) {
      return const SizedBox(); // Return empty widget if no profile
    }

    // Ensure we have a ValueNotifier for this profile
    if (!WalletBlock.balanceByProfile.containsKey(currentProfileId)) {
      WalletBlock.balanceByProfile[currentProfileId] =
          ValueNotifier<double>(0.0);
      WalletBlock.initWallet(context);
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Center(
      child: Stack(
        children: [
          Positioned(
            top: screenHeight * 0.04,
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
            top: screenHeight * 0.05,
            left: screenWidth * -0.3,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Transform.scale(
                scale: 0.2,
                child: Image.asset('assets/coins/1.png'),
              ),
            ),
          ),
          Positioned(
            top: screenHeight * -0.12,
            right: screenWidth * 0.099,
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
                SizedBox(height: screenHeight * 0.02),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: Constants.responsiveFontSize(context, 32),
                      fontWeight: FontWeight.bold,
                      fontFamily: Constants.titles,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
                    valueListenable:
                        WalletBlock.balanceByProfile[currentProfileId]!,
                    builder: (context, balance, child) {
                      return BalanceDisplay(
                        balance: balance,
                        fontSize: screenWidth * 0.2,
                        onTap: () {
                          Navigator.pushNamed(context, Manage.id);
                        },
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
