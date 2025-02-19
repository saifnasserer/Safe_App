import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:safe/Screens/home_screen/Wallet.dart';
import 'package:safe/providers/Goal_Provider.dart';
import 'package:safe/providers/Item_Provider.dart';
import 'package:safe/widgets/Goal.dart';
import 'package:safe/Constants.dart';
import 'package:safe/providers/profile_provider.dart';
import 'package:safe/widgets/item.dart';

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
        borderRadius: BorderRadius.circular(
          Constants.responsiveSpacing(context, 20),
        ),
      ),
      child: Container(
        padding: EdgeInsets.all(Constants.responsiveSpacing(context, 24)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'تحديث الهدف',
              style: TextStyle(
                fontFamily: Constants.defaultFontFamily,
                fontSize: Constants.responsiveFontSize(context, 24),
                fontWeight: FontWeight.bold,
                color: Constants.getPrimaryColor(context),
              ),
            ),
            SizedBox(height: Constants.responsiveSpacing(context, 24)),
            _buildToggleButtons(),
            SizedBox(height: Constants.responsiveSpacing(context, 24)),
            _buildAmountField(),
            SizedBox(height: Constants.responsiveSpacing(context, 24)),
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
        padding: EdgeInsets.all(Constants.responsiveSpacing(context, 8)),
        child: Container(
          padding: EdgeInsets.all(Constants.responsiveSpacing(context, 12)),
          decoration: BoxDecoration(
            color: isSelected
                ? Constants.getPrimaryColor(context)
                : Colors.transparent,
            borderRadius: BorderRadius.all(
              Radius.circular(Constants.responsiveSpacing(context, 12)),
            ),
            border: Border.all(
              color: Constants.getPrimaryColor(context),
              width: Constants.responsiveSpacing(context, 1),
            ),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: Constants.defaultFontFamily,
              fontSize: Constants.responsiveFontSize(context, 16),
              color: isSelected
                  ? Colors.white
                  : Constants.getPrimaryColor(context),
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
      style: TextStyle(
        fontFamily: Constants.defaultFontFamily,
        fontSize: Constants.responsiveFontSize(context, 18),
      ),
      decoration: InputDecoration(
        hintText: 'ادخل المبلغ',
        hintStyle: TextStyle(
          color: Colors.grey[400],
          fontFamily: Constants.defaultFontFamily,
          fontSize: Constants.responsiveFontSize(context, 16),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            Constants.responsiveSpacing(context, 12),
          ),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: Constants.responsiveSpacing(context, 16),
          vertical: Constants.responsiveSpacing(context, 14),
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
            onPressed: () {
              if (amountController.text.isNotEmpty) {
                _handleEditGoal(double.parse(amountController.text), isAdding);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Constants.getPrimaryColor(context),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                vertical: Constants.responsiveSpacing(context, 12),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  Constants.responsiveSpacing(context, 12),
                ),
              ),
            ),
            child: Text(
              'تأكيد',
              style: TextStyle(
                fontFamily: Constants.defaultFontFamily,
                fontSize: Constants.responsiveFontSize(context, 16),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        SizedBox(width: Constants.responsiveSpacing(context, 12)),
        Expanded(
          child: TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(
                vertical: Constants.responsiveSpacing(context, 12),
              ),
            ),
            child: Text(
              'إلغاء',
              style: TextStyle(
                fontFamily: Constants.defaultFontFamily,
                fontSize: Constants.responsiveFontSize(context, 16),
                color: Constants.getPrimaryColor(context),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _handleEditGoal(double amount, bool isAdding) {
    if (amount <= 0 || amountController.text.isEmpty) {
      showSimpleNotification(
        const Text(
          'برجاء ادخال قيمة صحيحة',
          textAlign: TextAlign.center,
        ),
        background: Colors.red,
      );
      return;
    }

    final profileProvider = context.read<ProfileProvider>();
    final currentProfileId = profileProvider.currentProfile?.id;

    if (currentProfileId == null) return;

    final currentBalance =
        WalletBlock.balanceByProfile[currentProfileId]?.value ?? 0.0;

    if (isAdding && amount > currentBalance) {
      showSimpleNotification(
        const Text(
          'رصيدك غير كافي',
          textAlign: TextAlign.center,
        ),
        background: Colors.red,
      );
      return;
    }

    // Calculate new goal amount
    if (isAdding) {
      if (widget.goal.currentAmount + amount > widget.goal.targetAmount) {
        showSimpleNotification(
          const Text(
            'مينفعش تضيف اكتر من المبلغ المستهدف',
            textAlign: TextAlign.center,
          ),
          background: Colors.red,
        );
        return;
      } else {
        WalletBlock.updateWalletBalance(context, currentBalance - amount);
        // Send the positive delta amount
        context.read<GoalProvider>().updateGoalProgress(widget.index, amount);
        context.read<ItemProvider>().addItem(
              item(
                title: "هدف: ${widget.goal.title}",
                flag: false,
                price: amount,
                dateTime: DateTime.now(),
                isGoal: true,
                goalIndex: widget.index,
              ),
            );
      }
    } else {
      if (widget.goal.currentAmount - amount < 0) {
        showSimpleNotification(
          const Text('مينفعش تخصم اكتر من المبلغ اللي في الهدف',
              textAlign: TextAlign.center),
          background: Colors.red,
        );
        return;
      }
      WalletBlock.updateWalletBalance(context, currentBalance + amount);
      // Send the negative delta amount
      context.read<GoalProvider>().updateGoalProgress(widget.index, -amount);
      context.read<ItemProvider>().addItem(
            item(
              title: "هدف: ${widget.goal.title}",
              flag: true,
              price: amount,
              dateTime: DateTime.now(),
              isGoal: true,
              goalIndex: widget.index,
            ),
          );
    }

    Navigator.pop(context);
  }
}
