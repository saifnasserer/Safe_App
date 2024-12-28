import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:safe/Blocks/Goal.dart';
import 'package:safe/Blocks/Wallet.dart';
import 'package:safe/providers/profile_provider.dart';
import 'package:safe/Constants.dart';
import 'package:safe/widgets/goals_screen_widgets/Goal_Provider.dart';
import 'package:safe/utils/goal_types.dart';

class GoalItemWidget extends StatefulWidget {
  final String title;
  final double targetAmount;
  final double savedAmount;
  final Color color;
  final GoalType type;
  final int? commitmentDay;
  final Function? onDismissed;

  const GoalItemWidget({
    super.key,
    required this.title,
    required this.targetAmount,
    required this.savedAmount,
    required this.color,
    required this.type,
    this.commitmentDay,
    this.onDismissed,
  });

  @override
  State<GoalItemWidget> createState() => _GoalItemWidgetState();
}

class _GoalItemWidgetState extends State<GoalItemWidget>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  final TextEditingController _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    if (widget.savedAmount / widget.targetAmount >= 1.0) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _showAddValueDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'إضافة مبلغ للهدف',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: Constants.defaultFontFamily,
            fontSize: Constants.responsiveFontSize(context, 24),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextField(
          controller: _amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: Constants.responsiveFontSize(context, 16),
          ),
          decoration: InputDecoration(
            hintText: 'ادخل المبلغ',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                Constants.responsiveSpacing(context, 8),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'إلغاء',
              style: TextStyle(
                fontFamily: Constants.defaultFontFamily,
                fontSize: Constants.responsiveFontSize(context, 14),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              if (_amountController.text.isNotEmpty) {
                final amount = double.parse(_amountController.text);
                if (amount > 0) {
                  Provider.of<GoalProvider>(context, listen: false)
                      .updateGoalProgress(
                          Provider.of<GoalProvider>(context, listen: false)
                              .goals
                              .indexOf(Goal(
                                title: widget.title,
                                targetAmount: widget.targetAmount,
                                color: widget.color,
                                type: widget.type,
                              )),
                          amount);
                  HapticFeedback.mediumImpact();
                  _amountController.clear();
                  Navigator.pop(context);
                }
              }
            },
            child: Text(
              'إضافة',
              style: TextStyle(
                fontFamily: Constants.defaultFontFamily,
                fontSize: Constants.responsiveFontSize(context, 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    final currentProfileId = profileProvider.currentProfile?.id;
    final walletValue = currentProfileId != null 
        ? WalletBlock.balanceByProfile[currentProfileId]?.value ?? 0.0
        : 0.0;
    final progress = widget.savedAmount / widget.targetAmount;
    final potentialProgress =
        (widget.savedAmount + walletValue) / widget.targetAmount;
    final adjustedPotentialProgress =
        potentialProgress > 1.0 ? 1.0 : potentialProgress;

    if (progress >= 1.0 && !_controller.isAnimating) {
      _controller.repeat();
      HapticFeedback.lightImpact();
    }

    return Stack(
      children: [
        Dismissible(
          key: Key(widget.title),
          direction: DismissDirection.endToStart,
          background: Container(
            decoration: BoxDecoration(
              color: Colors.red[400],
              borderRadius: BorderRadius.circular(
                Constants.responsiveSpacing(context, 16),
              ),
            ),
            alignment: Alignment.centerRight,
            padding: EdgeInsets.symmetric(
              horizontal: Constants.responsiveSpacing(context, 20),
            ),
            child: Icon(
              Icons.delete_outline,
              color: Colors.white,
              size: Constants.responsiveSpacing(context, 24),
            ),
          ),
          onDismissed: (direction) {
            HapticFeedback.mediumImpact();
            widget.onDismissed?.call();
          },
          child: Container(
            padding: EdgeInsets.all(Constants.responsiveSpacing(context, 16)),
            decoration: BoxDecoration(
              color: widget.color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(
                Constants.responsiveSpacing(context, 16),
              ),
              border: Border.all(
                color: widget.color.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            widget.title,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: Constants.responsiveFontSize(context, 16),
                              color: Colors.black87,
                              fontFamily: Constants.defaultFontFamily,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (widget.type == GoalType.monthlyCommitment &&
                              widget.commitmentDay != null)
                            Text(
                              'يوم الالتزام: ${widget.commitmentDay}',
                              style: TextStyle(
                                fontFamily: Constants.secondaryFontFamily,
                                fontSize: Constants.responsiveFontSize(context, 14),
                                color: Colors.grey,
                              ),
                            ),
                          SizedBox(height: Constants.responsiveSpacing(context, 8)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${widget.savedAmount.toStringAsFixed(0)} جنيه',
                                style: TextStyle(
                                  fontSize: Constants.responsiveFontSize(context, 14),
                                  color: widget.color,
                                  fontFamily: Constants.secondaryFontFamily,
                                ),
                              ),
                              SizedBox(width: Constants.responsiveSpacing(context, 8)),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: Constants.responsiveSpacing(context, 6),
                                  vertical: Constants.responsiveSpacing(context, 2),
                                ),
                                decoration: BoxDecoration(
                                  color: widget.color,
                                  borderRadius: BorderRadius.circular(
                                    Constants.responsiveSpacing(context, 4),
                                  ),
                                ),
                                child: Text(
                                  '${(progress * 100).toStringAsFixed(0)}%',
                                  style: TextStyle(
                                    fontSize: Constants.responsiveFontSize(context, 12),
                                    color: Colors.white,
                                    fontFamily: Constants.secondaryFontFamily,
                                  ),
                                ),
                              ),
                              if (walletValue > 0) ...[
                                SizedBox(width: Constants.responsiveSpacing(context, 4)),
                                Text(
                                  '→',
                                  style: TextStyle(
                                    color: widget.color,
                                    fontWeight: FontWeight.bold,
                                    fontSize: Constants.responsiveFontSize(context, 14),
                                  ),
                                ),
                                SizedBox(width: Constants.responsiveSpacing(context, 8)),
                                Text(
                                  '${widget.targetAmount.toStringAsFixed(0)} جنية',
                                  style: TextStyle(
                                    fontSize: Constants.responsiveFontSize(context, 14),
                                    color: widget.color,
                                    fontFamily: Constants.secondaryFontFamily,
                                  ),
                                ),
                                SizedBox(width: Constants.responsiveSpacing(context, 4)),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: Constants.responsiveSpacing(context, 6),
                                    vertical: Constants.responsiveSpacing(context, 2),
                                  ),
                                  decoration: BoxDecoration(
                                    color: widget.color.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(
                                      Constants.responsiveSpacing(context, 4),
                                    ),
                                  ),
                                  child: Text(
                                    '${(adjustedPotentialProgress * 100).toStringAsFixed(0)}%',
                                    style: TextStyle(
                                      fontSize: Constants.responsiveFontSize(context, 12),
                                      color: widget.color,
                                      fontFamily: Constants.secondaryFontFamily,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: Constants.responsiveSpacing(context, 12)),
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(
                        Constants.responsiveSpacing(context, 8),
                      ),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(widget.color),
                        minHeight: Constants.responsiveSpacing(context, 8),
                      ),
                    ),
                    if (walletValue > 0)
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                            Constants.responsiveSpacing(context, 8),
                          ),
                          child: LinearProgressIndicator(
                            value: adjustedPotentialProgress,
                            backgroundColor: Colors.transparent,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              widget.color.withOpacity(0.3),
                            ),
                            minHeight: Constants.responsiveSpacing(context, 8),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (progress >= 1.0)
          Positioned.fill(
            child: Center(
              child: Lottie.asset(
                'assets/animation/Celebration.json',
                repeat: true,
                animate: true,
                controller: _controller,
                onLoaded: (composition) {
                  _controller.duration = composition.duration;
                  if (progress >= 1.0) {
                    _controller.repeat();
                  }
                },
                height: Constants.heightPercent(context, 20),
              ),
            ),
          ),
      ],
    );
  }
}
