import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class EmptyGoalsView extends StatelessWidget {
  final VoidCallback onAddGoal;
  final Color mainColor;

  const EmptyGoalsView({
    super.key,
    required this.onAddGoal,
    required this.mainColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LottieBuilder.asset(
            'assets/animation/Onion.json',
            height: 200,
          ),
          const SizedBox(height: 24),
          const Text(
            "لا يوجد اهداف حاليا",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: onAddGoal,
            icon: const Icon(Icons.add),
            label: const Text("اضف هدف جديد"),
            style: TextButton.styleFrom(
              foregroundColor: mainColor,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
