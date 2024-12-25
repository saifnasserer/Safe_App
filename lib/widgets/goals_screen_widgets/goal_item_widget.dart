import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:safe/Blocks/Goal.dart';
import 'package:safe/Blocks/Wallet.dart';
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
        title: const Text(
          'إضافة مبلغ للهدف',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: Constants.defaultFontFamily,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextField(
          controller: _amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textAlign: TextAlign.center,
          decoration: const InputDecoration(
            hintText: 'ادخل المبلغ',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'إلغاء',
              style: TextStyle(
                fontFamily: Constants.defaultFontFamily,
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
            child: const Text(
              'إضافة',
              style: TextStyle(
                fontFamily: Constants.defaultFontFamily,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final walletValue = WalletBlock.wallet.value;
    final screenHight = MediaQuery.of(context).size.height;
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
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: const Icon(Icons.delete_outline, color: Colors.white),
          ),
          onDismissed: (direction) {
            HapticFeedback.mediumImpact();
            widget.onDismissed?.call();
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: widget.color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
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
                            style: const TextStyle(
                              fontSize: 16,
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
                              style: const TextStyle(
                                fontFamily: Constants.secondaryFontFamily,
                                color: Colors.grey,
                              ),
                            ),
                          SizedBox(height: screenHight * .01),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${widget.savedAmount.toStringAsFixed(0)} جنيه',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: widget.color,
                                  fontFamily: Constants.secondaryFontFamily,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: widget.color,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${(progress * 100).toStringAsFixed(0)}%',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                    fontFamily: Constants.secondaryFontFamily,
                                  ),
                                ),
                              ),
                              if (walletValue > 0) ...[
                                const SizedBox(width: 4),
                                Text(
                                  '→',
                                  style: TextStyle(
                                    color: widget.color,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${widget.targetAmount.toStringAsFixed(0)} جنية',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: widget.color,
                                    fontFamily: Constants.secondaryFontFamily,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: widget.color.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '${(adjustedPotentialProgress * 100).toStringAsFixed(0)}%',
                                    style: TextStyle(
                                      fontSize: 12,
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
                const SizedBox(height: 12),
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(widget.color),
                        minHeight: 8,
                      ),
                    ),
                    if (walletValue > 0)
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: adjustedPotentialProgress,
                            backgroundColor: Colors.transparent,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              widget.color.withOpacity(0.3),
                            ),
                            minHeight: 8,
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
                height: 150,
              ),
            ),
          ),
      ],
    );
  }
}
