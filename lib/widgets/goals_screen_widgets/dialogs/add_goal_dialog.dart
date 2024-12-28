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
          borderRadius: BorderRadius.circular(
            Constants.responsiveSpacing(context, 20),
          ),
        ),
        child: Container(
          padding: EdgeInsets.all(Constants.responsiveSpacing(context, 24)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(
              Constants.responsiveSpacing(context, 20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: Constants.responsiveSpacing(context, 10),
                offset: Offset(0, Constants.responsiveSpacing(context, 4)),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'إضافة هدف جديد',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Constants.getPrimaryColor(context),
                    fontSize: Constants.responsiveFontSize(context, 20),
                    fontFamily: Constants.defaultFontFamily,
                  ),
                ),
                SizedBox(height: Constants.responsiveSpacing(context, 5)),
                _buildForm(),
                SizedBox(height: Constants.responsiveSpacing(context, 16)),
                _buildColorPicker(),
                SizedBox(height: Constants.responsiveSpacing(context, 24)),
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
          SizedBox(height: Constants.responsiveSpacing(context, 16)),
          _buildTitleField(),
          SizedBox(height: Constants.responsiveSpacing(context, 16)),
          _buildAmountField(),
        ],
      ),
    );
  }

  Widget _buildTitleField() {
    return TextField(
      controller: titleController,
      textAlign: TextAlign.right,
      style: TextStyle(fontSize: Constants.responsiveFontSize(context, 16)),
      decoration: InputDecoration(
        labelText: 'اسم الهدف',
        alignLabelWithHint: true,
        hintText: 'مثال: سيارة جديدة  ',
        hintStyle: TextStyle(
          fontFamily: Constants.secondaryFontFamily,
          fontSize: Constants.responsiveFontSize(context, 14),
        ),
        labelStyle: TextStyle(
          fontSize: Constants.responsiveFontSize(context, 16),
        ),
        hintTextDirection: TextDirection.rtl,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            Constants.responsiveSpacing(context, 12),
          ),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            Constants.responsiveSpacing(context, 12),
          ),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            Constants.responsiveSpacing(context, 12),
          ),
          borderSide: BorderSide(
            color: Colors.blue,
            width: Constants.responsiveSpacing(context, 2),
          ),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: EdgeInsets.symmetric(
          horizontal: Constants.responsiveSpacing(context, 12),
          vertical: Constants.responsiveSpacing(context, 16),
        ),
      ),
    );
  }

  Widget _buildAmountField() {
    return TextField(
      controller: amountController,
      textAlign: TextAlign.right,
      keyboardType: TextInputType.number,
      style: TextStyle(fontSize: Constants.responsiveFontSize(context, 16)),
      decoration: InputDecoration(
        labelText: 'المبلغ المستهدف',
        alignLabelWithHint: true,
        labelStyle: TextStyle(
          fontSize: Constants.responsiveFontSize(context, 16),
        ),
        hintTextDirection: TextDirection.rtl,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            Constants.responsiveSpacing(context, 12),
          ),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            Constants.responsiveSpacing(context, 12),
          ),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            Constants.responsiveSpacing(context, 12),
          ),
          borderSide: BorderSide(
            color: Colors.blue,
            width: Constants.responsiveSpacing(context, 2),
          ),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        prefixText: 'جنية: ',
        prefixStyle: TextStyle(
          fontFamily: Constants.secondaryFontFamily,
          fontSize: Constants.responsiveFontSize(context, 14),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: Constants.responsiveSpacing(context, 12),
          vertical: Constants.responsiveSpacing(context, 16),
        ),
      ),
    );
  }

  Widget _buildColorPicker() {
    return Column(
      children: [
        Text(
          'لون الهدف',
          style: TextStyle(
            fontSize: Constants.responsiveFontSize(context, 16),
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: Constants.responsiveSpacing(context, 8)),
        StatefulBuilder(
          builder: (context, setState) {
            return Container(
              height: Constants.responsiveSpacing(context, 55),
              padding: EdgeInsets.all(Constants.responsiveSpacing(context, 4)),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(
                  Constants.responsiveSpacing(context, 12),
                ),
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
        width: Constants.responsiveSpacing(context, 40),
        height: Constants.responsiveSpacing(context, 40),
        margin: EdgeInsets.symmetric(
          horizontal: Constants.responsiveSpacing(context, 4),
        ),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: selectedColor == color
              ? Border.all(
                  color: Colors.white,
                  width: Constants.responsiveSpacing(context, 2),
                )
              : null,
          boxShadow: selectedColor == color
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: Constants.responsiveSpacing(context, 1),
                    spreadRadius: Constants.responsiveSpacing(context, 2),
                  )
                ]
              : null,
        ),
        child: selectedColor == color
            ? Icon(
                Icons.check,
                color: Colors.white,
                size: Constants.responsiveSpacing(context, 20),
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
            backgroundColor: Constants.getPrimaryColor(context),
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(
              horizontal: Constants.responsiveSpacing(context, 24),
              vertical: Constants.responsiveSpacing(context, 12),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                Constants.responsiveSpacing(context, 12),
              ),
            ),
            elevation: 0,
          ),
          child: Text(
            'إضافة',
            style: TextStyle(
              fontSize: Constants.responsiveFontSize(context, 16),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(width: Constants.responsiveSpacing(context, 8)),
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(
              horizontal: Constants.responsiveSpacing(context, 20),
              vertical: Constants.responsiveSpacing(context, 12),
            ),
          ),
          child: Text(
            'إلغاء',
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: Constants.responsiveFontSize(context, 16),
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
