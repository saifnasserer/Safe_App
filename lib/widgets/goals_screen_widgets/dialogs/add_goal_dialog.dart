import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:safe/Blocks/Goal.dart';
import 'package:safe/Constants.dart';
import 'package:safe/utils/goal_types.dart';
import 'package:safe/widgets/goals_screen_widgets/Goal_Provider.dart';

class AddGoalDialog extends StatefulWidget {
  const AddGoalDialog({super.key});

  @override
  State<AddGoalDialog> createState() => _AddGoalDialogState();
}

class _AddGoalDialogState extends State<AddGoalDialog> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  Color selectedColor = Colors.blue;
  final GoalType _selectedType = GoalType.goal;
  int? _selectedCommitmentDay;

  @override
  void dispose() {
    titleController.dispose();
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'إضافة هدف جديد',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Constants.primaryColor,
                      fontSize: 20,
                      fontFamily: Constants.defaultFontFamily),
                ),
                const SizedBox(height: 5),
                _buildForm(),
                const SizedBox(height: 16),
                _buildColorPicker(),
                const SizedBox(height: 24),
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          const SizedBox(height: 16),
          _buildTitleField(),
          const SizedBox(height: 16),
          _buildAmountField(),
        ],
      ),
    );
  }

  Widget _buildTitleField() {
    return TextField(
      controller: titleController,
      textAlign: TextAlign.right,
      decoration: InputDecoration(
        labelText: 'اسم الهدف',
        alignLabelWithHint: true,
        hintText: 'مثال: سيارة جديدة  ',
        hintStyle: const TextStyle(fontFamily: Constants.secondaryFontFamily),
        hintTextDirection: TextDirection.rtl,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }

  Widget _buildAmountField() {
    return TextField(
      controller: amountController,
      textAlign: TextAlign.right,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: 'المبلغ المستهدف',
        alignLabelWithHint: true,
        hintTextDirection: TextDirection.rtl,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        prefixText: 'جنية: ',
        prefixStyle: const TextStyle(fontFamily: Constants.secondaryFontFamily),
      ),
    );
  }

  Widget _buildColorPicker() {
    return Column(
      children: [
        const Text(
          'لون الهدف',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        StatefulBuilder(
          builder: (context, setState) {
            return Container(
              height: 55,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  Colors.blue,
                  Colors.green,
                  Colors.red,
                  Colors.purple,
                  Colors.orange,
                  Colors.teal,
                  Colors.pink,
                  Colors.indigo,
                ].map((color) {
                  return _buildColorOption(color, setState);
                }).toList(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildColorOption(Color color, StateSetter setState) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        setState(() {
          selectedColor = color;
        });
      },
      child: Container(
        width: 40,
        height: 40,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: selectedColor == color
              ? Border.all(color: Colors.white, width: 2)
              : null,
          boxShadow: selectedColor == color
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 1,
                    spreadRadius: 2,
                  )
                ]
              : null,
        ),
        child: selectedColor == color
            ? const Icon(
                Icons.check,
                color: Colors.white,
                size: 20,
              )
            : null,
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        ElevatedButton(
          onPressed: _handleAddGoal,
          style: ElevatedButton.styleFrom(
            backgroundColor: Constants.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: const Text(
            'إضافة',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 8),
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 12,
            ),
          ),
          child: Text(
            'إلغاء',
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  void _handleAddGoal() {
    if (_formKey.currentState!.validate()) {
      HapticFeedback.mediumImpact();
      Provider.of<GoalProvider>(context, listen: false).addGoal(
        Goal(
          title: titleController.text,
          targetAmount: double.parse(amountController.text),
          color: selectedColor,
          type: _selectedType,
        ),
      );
      Navigator.pop(context);
    }
  }
}
