import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safe/Blocks/Goal.dart';
import 'package:safe/Blocks/Wallet.dart';
import 'package:safe/Constants.dart';
import 'package:safe/widgets/goals_screen_widgets/Goal_Provider.dart';

class EditGoalDialog extends StatefulWidget {
  final Goal goal;
  final int index;

  const EditGoalDialog({
    super.key,
    required this.goal,
    required this.index,
  });

  @override
  State<EditGoalDialog> createState() => _EditGoalDialogState();
}

class _EditGoalDialogState extends State<EditGoalDialog> {
  final TextEditingController amountController = TextEditingController();
  bool isAdding = true;

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'تعديل الهدف',
              style: TextStyle(
                fontFamily: Constants.defaultFontFamily,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Constants.primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            _buildToggleButtons(),
            const SizedBox(height: 24),
            _buildAmountField(),
            const SizedBox(height: 24),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleButtons() {
    return StatefulBuilder(
      builder: (context, setState) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: _buildToggleButton(
              text: 'إضافة',
              isSelected: isAdding,
              onTap: () => setState(() => isAdding = true),
            ),
          ),
          Expanded(
            child: _buildToggleButton(
              text: 'خصم',
              isSelected: !isAdding,
              onTap: () => setState(() => isAdding = false),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton({
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected ? Constants.primaryColor : Colors.transparent,
            borderRadius: const BorderRadius.all(Radius.circular(12)),
            border: Border.all(
              color: Constants.primaryColor,
              width: 1,
            ),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: Constants.defaultFontFamily,
              color: isSelected ? Colors.white : Constants.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAmountField() {
    return TextField(
      controller: amountController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontFamily: Constants.defaultFontFamily,
        fontSize: 18,
      ),
      decoration: InputDecoration(
        hintText: 'ادخل المبلغ',
        hintStyle: TextStyle(
          color: Colors.grey[400],
          fontFamily: Constants.defaultFontFamily,
        ),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: _handleEditGoal,
            style: ElevatedButton.styleFrom(
              backgroundColor: Constants.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'تأكيد',
              style: TextStyle(
                fontFamily: Constants.defaultFontFamily,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text(
              'إلغاء',
              style: TextStyle(
                fontFamily: Constants.defaultFontFamily,
                fontSize: 16,
                color: Constants.primaryColor,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _handleEditGoal() {
    if (amountController.text.isNotEmpty) {
      double amount = double.parse(amountController.text);
      if (!isAdding && widget.goal.currentAmount - amount < 0) {
        return;
      } else if (isAdding && WalletBlock.wallet.value - amount < 0) {
        return;
      }

      final finalAmount = isAdding ? amount : -amount;
      Provider.of<GoalProvider>(context, listen: false)
          .updateGoalProgress(widget.index, finalAmount);

      if (!isAdding) {
        WalletBlock.updateWallet(WalletBlock.wallet.value - amount);
      } else {
        WalletBlock.updateWallet(WalletBlock.wallet.value + amount);
      }
      Navigator.pop(context);
    }
  }
}
