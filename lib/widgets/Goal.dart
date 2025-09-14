import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:safe/Screens/home_screen/Wallet.dart';
import 'package:safe/providers/profile_provider.dart';
import 'package:provider/provider.dart';

class Goal {
  final String title;
  final double targetAmount;
  double currentAmount;
  final Color color;

  Goal({
    required this.title,
    required this.targetAmount,
    this.currentAmount = 0,
    required this.color,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'color': color.value,
    };
  }

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      title: json['title'],
      targetAmount: json['targetAmount'],
      currentAmount: json['currentAmount'],
      color: Color(json['color']),
    );
  }

  Goal copyWith({
    String? title,
    double? targetAmount,
    double? currentAmount,
    Color? color,
  }) {
    return Goal(
      title: title ?? this.title,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      color: color ?? this.color,
    );
  }
}

class GoalItem extends StatefulWidget {
  final Goal goal;
  final VoidCallback? onDismissed;

  const GoalItem({
    super.key,
    required this.goal,
    this.onDismissed,
  });

  @override
  State<GoalItem> createState() => _GoalItemState();
}

class _GoalItemState extends State<GoalItem> with TickerProviderStateMixin {
  late AnimationController _progressAnimationController;
  late AnimationController _pulseAnimationController;
  late Animation<double> _progressAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressAnimationController,
      curve: Curves.easeInOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseAnimationController,
      curve: Curves.easeInOut,
    ));

    _progressAnimationController.forward();
    _pulseAnimationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _progressAnimationController.dispose();
    _pulseAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(widget.goal.title),
      direction: DismissDirection.endToStart,
      background: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.red[400]!, Colors.red[600]!],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(
          Icons.delete_outline,
          color: Colors.white,
          size: 28,
        ),
      ),
      onDismissed: (_) {
        if (widget.onDismissed != null) {
          widget.onDismissed!();
        }
      },
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Card(
                elevation: 12,
                shadowColor: widget.goal.color.withOpacity(0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        widget.goal.color.withOpacity(0.1),
                        widget.goal.color.withOpacity(0.05),
                      ],
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        // Add haptic feedback
                        // HapticFeedback.lightImpact();
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Stack(
                          children: [
                            // Main content
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Goal title with icon
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color:
                                            widget.goal.color.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: widget.goal.color
                                              .withOpacity(0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.flag_rounded,
                                        color: widget.goal.color,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        widget.goal.title,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey[800],
                                          shadows: [
                                            Shadow(
                                              color:
                                                  Colors.black.withOpacity(0.1),
                                              offset: const Offset(0, 1),
                                              blurRadius: 2,
                                            ),
                                          ],
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                // Progress section
                                ValueListenableBuilder<double>(
                                  valueListenable: WalletBlock.balanceByProfile[
                                          context
                                                  .watch<ProfileProvider>()
                                                  .currentProfile
                                                  ?.id ??
                                              ''] ??
                                      ValueNotifier<double>(0.0),
                                  builder: (context, savedAmount, child) {
                                    double progress =
                                        (savedAmount / widget.goal.targetAmount)
                                            .clamp(0.0, 1.0);

                                    return Column(
                                      children: [
                                        // Progress bar with animation
                                        AnimatedBuilder(
                                          animation: _progressAnimation,
                                          builder: (context, child) {
                                            return Container(
                                              height: 12,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                color: widget.goal.color
                                                    .withOpacity(0.2),
                                              ),
                                              child: Stack(
                                                children: [
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              6),
                                                      gradient: LinearGradient(
                                                        colors: [
                                                          widget.goal.color
                                                              .withOpacity(0.3),
                                                          widget.goal.color
                                                              .withOpacity(0.1),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  FractionallySizedBox(
                                                    widthFactor: progress *
                                                        _progressAnimation
                                                            .value,
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(6),
                                                        gradient:
                                                            LinearGradient(
                                                          colors: [
                                                            widget.goal.color,
                                                            widget.goal.color
                                                                .withOpacity(
                                                                    0.8),
                                                          ],
                                                        ),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: widget
                                                                .goal.color
                                                                .withOpacity(
                                                                    0.4),
                                                            blurRadius: 4,
                                                            offset:
                                                                const Offset(
                                                                    0, 2),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                        const SizedBox(height: 12),

                                        // Amount display
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "محفوظ: ${savedAmount.toStringAsFixed(0)} ج.م",
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[600],
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            Text(
                                              "الهدف: ${widget.goal.targetAmount.toStringAsFixed(0)} ج.م",
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[600],
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 8),

                                        // Percentage
                                        Text(
                                          "${(progress * 100).toStringAsFixed(1)}%",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: widget.goal.color,
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),

                            // Celebration animation
                            Positioned(
                              top: 0,
                              right: 0,
                              left: 0,
                              bottom: 0,
                              child: ValueListenableBuilder<double>(
                                valueListenable: WalletBlock.balanceByProfile[
                                        context
                                                .watch<ProfileProvider>()
                                                .currentProfile
                                                ?.id ??
                                            ''] ??
                                    ValueNotifier<double>(0.0),
                                builder: (context, savedAmount, child) {
                                  double progress =
                                      (savedAmount / widget.goal.targetAmount)
                                          .clamp(0.0, 1.0);

                                  if (progress >= 1.0) {
                                    return Center(
                                      child: Lottie.asset(
                                        'assets/animation/Celebration.json',
                                        animate: true,
                                        repeat: true,
                                        height: 120,
                                        fit: BoxFit.contain,
                                      ),
                                    );
                                  } else {
                                    return const SizedBox();
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
