import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:safe/Blocks/Wallet.dart';
import 'package:safe/providers/profile_provider.dart';
import 'package:safe/utils/goal_types.dart';
import 'package:provider/provider.dart';

class Goal {
  final String title;
  final double targetAmount;
  double currentAmount;
  final Color color;
  final GoalType type;

  Goal({
    required this.title,
    required this.targetAmount,
    this.currentAmount = 0,
    required this.color,
    this.type = GoalType.goal,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'color': color.value,
      'type': type.index,
    };
  }

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      title: json['title'],
      targetAmount: json['targetAmount'],
      currentAmount: json['currentAmount'],
      color: Color(json['color']),
      type: GoalType.values[json['type'] ?? 0],
    );
  }

  Goal copyWith({
    String? title,
    double? targetAmount,
    double? currentAmount,
    Color? color,
    GoalType? type,
  }) {
    return Goal(
      title: title ?? this.title,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      color: color ?? this.color,
      type: type ?? this.type,
    );
  }
}

class GoalItem extends StatelessWidget {
  final Goal goal;
  final VoidCallback? onDismissed;

  const GoalItem({
    super.key,
    required this.goal,
    this.onDismissed,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(goal.title),
      direction: DismissDirection.endToStart,
      background: Container(
        decoration: BoxDecoration(
          color: Colors.red[400],
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) {
        if (onDismissed != null) {
          onDismissed!();
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: goal.color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  goal.title,
                  style: const TextStyle(
                    fontSize: 16,
                    overflow: TextOverflow.ellipsis,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ValueListenableBuilder<double>(
                  valueListenable: WalletBlock.balanceByProfile[
                          context.watch<ProfileProvider>().currentProfile?.id ??
                              ''] ??
                      ValueNotifier<double>(0.0),
                  builder: (context, savedAmount, child) {
                    double progress =
                        (savedAmount / goal.targetAmount).clamp(0.0, 1.0);

                    return Column(
                      children: [
                        Text(
                          "Saved: \$${savedAmount.toStringAsFixed(2)} / \$${goal.targetAmount.toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: progress,
                          backgroundColor: goal.color.withOpacity(0.3),
                          valueColor: AlwaysStoppedAnimation<Color>(goal.color),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
            // Lottie animation
            Positioned(
              top: 0,
              right: 0,
              left: 0,
              bottom: 0,
              child: ValueListenableBuilder<double>(
                valueListenable: WalletBlock.balanceByProfile[
                        context.watch<ProfileProvider>().currentProfile?.id ??
                            ''] ??
                    ValueNotifier<double>(0.0),
                builder: (context, savedAmount, child) {
                  double progress =
                      (savedAmount / goal.targetAmount).clamp(0.0, 1.0);

                  if (progress == 1) {
                    return Center(
                      child: Lottie.asset(
                        'assets/animation/Celebration.json',
                        animate: true,
                        repeat: true,
                        height: 100,
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
    );
  }
}
