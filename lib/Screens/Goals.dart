import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:safe/Blocks/Goal.dart';
import 'package:safe/Blocks/Wallet.dart';
import 'package:safe/Constants.dart';
import 'package:provider/provider.dart';
import 'package:safe/widgets/Goal_Provider.dart';

class GoalsBlock extends StatefulWidget {
  const GoalsBlock({super.key});
  static String goalsID = 'this is goalsScreen ID';
  @override
  _GoalsBlockState createState() => _GoalsBlockState();
}

class _GoalsBlockState extends State<GoalsBlock> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController targetAmountController = TextEditingController();
  Color selectedColor = const Color(0xFF1abc9c);
  final _formKey = GlobalKey<FormState>();

  final List<Color> predefinedColors = [
    const Color(0xFF1abc9c),
    const Color(0xFF2ecc71),
    const Color(0xFF3498db),
    const Color(0xFF9b59b6),
    const Color(0xFFf1c40f),
    const Color(0xFFe67e22),
    const Color(0xFFe74c3c),
    const Color(0xFF34495e),
  ];

  Color mainColor = const Color(0xFF4459c8);

  @override
  void dispose() {
    titleController.dispose();
    targetAmountController.dispose();
    super.dispose();
  }

  void _addGoal() {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController amountController = TextEditingController();
    Color selectedColor = Colors.blue;

    showDialog(
      context: context,
      builder: (BuildContext context) {
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'إضافة هدف جديد',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextField(
                          controller: titleController,
                          textAlign: TextAlign.right,
                          decoration: InputDecoration(
                            labelText: 'اسم الهدف',
                            alignLabelWithHint: true,
                            hintText: 'مثال: سيارة جديدة  ',
                            hintTextDirection: TextDirection.rtl,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: Colors.blue, width: 2),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            suffixIcon: const Icon(Icons.edit_outlined),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: amountController,
                          textAlign: TextAlign.right,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'المبلغ المستهدف',
                            alignLabelWithHint: true,
                            // hintText: 'مثال: 10000',
                            hintTextDirection: TextDirection.rtl,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: Colors.blue, width: 2),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            suffixIcon: const Icon(Icons.attach_money_outlined),
                            prefixText: 'جنيه',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
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
                        height: 50,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          // reverse: true,
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
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                  border: selectedColor == color
                                      ? Border.all(
                                          color: Colors.white, width: 2)
                                      : null,
                                  boxShadow: selectedColor == color
                                      ? [
                                          BoxShadow(
                                            color: color.withOpacity(0.4),
                                            blurRadius: 8,
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
                          }).toList(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            HapticFeedback.mediumImpact();
                            Provider.of<GoalProvider>(context, listen: false)
                                .addGoal(
                              Goal(
                                title: titleController.text,
                                // currentAmount: 0.0,
                                targetAmount:
                                    double.parse(amountController.text),
                                color: selectedColor,
                              ),
                            );
                            Navigator.pop(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
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
                        onPressed: () {
                          Navigator.pop(context);
                        },
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
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final goals = Provider.of<GoalProvider>(context).goals;
    // final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Constants.primaryColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'اهدافك',
          style: TextStyle(
            color: Constants.primaryColor,
            fontFamily: Constants.defaultFontFamily,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: goals.isEmpty
                ? Center(
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
                          onPressed: _addGoal,
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
                  )
                : ListView.builder(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: goals.length,
                    itemBuilder: (context, index) {
                      final goal = goals[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Center(
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.9,
                            child: GestureDetector(
                              onTap: () {
                                HapticFeedback.mediumImpact();
                                final amountController =
                                    TextEditingController();
                                bool isAdding = true;

                                showDialog(
                                  context: context,
                                  builder: (context) => Dialog(
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
                                              fontFamily:
                                                  Constants.defaultFontFamily,
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: Constants.primaryColor,
                                            ),
                                          ),
                                          const SizedBox(height: 24),
                                          StatefulBuilder(
                                            builder: (context, setState) =>
                                                Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Expanded(
                                                      child: GestureDetector(
                                                        onTap: () =>
                                                            setState(() {
                                                          isAdding = true;
                                                        }),
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(12),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: isAdding
                                                                ? Constants
                                                                    .primaryColor
                                                                : Colors
                                                                    .transparent,
                                                            borderRadius:
                                                                const BorderRadius
                                                                    .horizontal(
                                                                    right: Radius
                                                                        .circular(
                                                                            12)),
                                                            border: Border.all(
                                                              color: Constants
                                                                  .primaryColor,
                                                              width: 1,
                                                            ),
                                                          ),
                                                          child: Text(
                                                            'إضافة',
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                              fontFamily: Constants
                                                                  .defaultFontFamily,
                                                              color: isAdding
                                                                  ? Colors.white
                                                                  : Constants
                                                                      .primaryColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: GestureDetector(
                                                        onTap: () =>
                                                            setState(() {
                                                          isAdding = false;
                                                        }),
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(12),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: !isAdding
                                                                ? Constants
                                                                    .primaryColor
                                                                : Colors
                                                                    .transparent,
                                                            borderRadius:
                                                                const BorderRadius
                                                                    .horizontal(
                                                                    left: Radius
                                                                        .circular(
                                                                            12)),
                                                            border: Border.all(
                                                              color: Constants
                                                                  .primaryColor,
                                                              width: 1,
                                                            ),
                                                          ),
                                                          child: Text(
                                                            'خصم',
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                              fontFamily: Constants
                                                                  .defaultFontFamily,
                                                              color: !isAdding
                                                                  ? Colors.white
                                                                  : Constants
                                                                      .primaryColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 24),
                                                TextField(
                                                  controller: amountController,
                                                  keyboardType:
                                                      const TextInputType
                                                          .numberWithOptions(
                                                    decimal: true,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                    fontFamily: Constants
                                                        .defaultFontFamily,
                                                    fontSize: 18,
                                                  ),
                                                  decoration: InputDecoration(
                                                    hintText: '0.00',
                                                    filled: true,
                                                    fillColor: Colors.grey[100],
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                      borderSide:
                                                          BorderSide.none,
                                                    ),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                      borderSide:
                                                          const BorderSide(
                                                        color: Constants
                                                            .primaryColor,
                                                        width: 2,
                                                      ),
                                                    ),
                                                    contentPadding:
                                                        const EdgeInsets
                                                            .symmetric(
                                                      horizontal: 16,
                                                      vertical: 16,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 24),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                  style: TextButton.styleFrom(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 12),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                    ),
                                                  ),
                                                  child: const Text(
                                                    'إلغاء',
                                                    style: TextStyle(
                                                      fontFamily: Constants
                                                          .defaultFontFamily,
                                                      color: Constants
                                                          .primaryColor,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              Expanded(
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    if (amountController
                                                        .text.isNotEmpty) {
                                                      double amount =
                                                          double.parse(
                                                              amountController
                                                                  .text);
                                                      if (!isAdding &&
                                                          goal.currentAmount -
                                                                  amount <
                                                              0) {
                                                        showSimpleNotification(
                                                            context: context,
                                                            duration:
                                                                const Duration(
                                                                    seconds: 2),
                                                            const Center(
                                                              child: Text(
                                                                  "المبلغ اللي عايز تخصمة اكبر من الموجود في اهدف بتاعك"),
                                                            ),
                                                            background:
                                                                Colors.red);
                                                        return;
                                                      } else if (isAdding &&
                                                          WalletBlock.wallet
                                                                      .value -
                                                                  amount <
                                                              0) {
                                                        showSimpleNotification(
                                                            context: context,
                                                            duration:
                                                                const Duration(
                                                                    seconds: 2),
                                                            const Center(
                                                                child: Text(
                                                                    "المبلغ اللي عايز تضيفة اكبر من الموجود في المحفظة")),
                                                            background:
                                                                Colors.red);
                                                        return;
                                                      } else {
                                                        showSimpleNotification(
                                                          context: context,
                                                          duration:
                                                              const Duration(
                                                                  seconds: 1),
                                                          const Center(
                                                            child: Text(
                                                                "تم التعديل بنجاح"),
                                                          ),
                                                          background:
                                                              Colors.green,
                                                        );
                                                      }
                                                      final finalAmount = isAdding
                                                          ? goal.currentAmount +
                                                              amount
                                                          : goal.currentAmount -
                                                              amount;
                                                      Provider.of<GoalProvider>(
                                                              context,
                                                              listen: false)
                                                          .updateGoalProgress(
                                                              index,
                                                              finalAmount);
                                                      HapticFeedback
                                                          .mediumImpact();
                                                      isAdding
                                                          ? WalletBlock
                                                              .updateWallet(
                                                                  WalletBlock
                                                                          .wallet
                                                                          .value -
                                                                      amount)
                                                          : WalletBlock
                                                              .updateWallet(
                                                                  WalletBlock
                                                                          .wallet
                                                                          .value +
                                                                      amount);
                                                      Navigator.pop(context);
                                                    } else {
                                                      showSimpleNotification(
                                                          context: context,
                                                          duration: Duration(
                                                              seconds: 1),
                                                          const Center(
                                                            child: Text(
                                                                "ادخل المبلغ"),
                                                          ),
                                                          background:
                                                              Colors.red);
                                                    }
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Constants.primaryColor,
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 12),
                                                    elevation: 0,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                    ),
                                                  ),
                                                  child: const Text(
                                                    'تأكيد',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontFamily: Constants
                                                          .defaultFontFamily,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                              child: GoalItem(
                                title: goal.title,
                                targetAmount: goal.targetAmount,
                                savedAmount: goal.currentAmount,
                                color: goal.color,
                                onDismissed: () {
                                  HapticFeedback.mediumImpact();
                                  Provider.of<GoalProvider>(context,
                                          listen: false)
                                      .removeGoal(index);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("تم حذف ${goal.title}"),
                                      behavior: SnackBarBehavior.floating,
                                      backgroundColor: mainColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      margin: const EdgeInsets.all(16),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: goals.isNotEmpty
          ? FloatingActionButton(
              onPressed: _addGoal,
              elevation: 2,
              backgroundColor: mainColor,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }
}

class GoalItem extends StatefulWidget {
  final String title;
  final double targetAmount;
  final double savedAmount;
  final Color color;
  final Function? onDismissed;

  const GoalItem({
    super.key,
    required this.title,
    required this.targetAmount,
    required this.savedAmount,
    required this.color,
    this.onDismissed,
  });

  @override
  State<GoalItem> createState() => _GoalItemState();
}

class _GoalItemState extends State<GoalItem> with TickerProviderStateMixin {
  late final AnimationController _controller;
  final TextEditingController _amountController = TextEditingController();

  @override
  void initState() {
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
                                  // currentAmount: widget.savedAmount,
                                  color: widget.color)),
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
            // ده شكل الكارد بتاعت كل هدف
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
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${widget.targetAmount.toStringAsFixed(0)} جنيه',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: widget.color,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: widget.color,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${(progress * 100).toStringAsFixed(0)}%',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
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
                                const SizedBox(width: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: widget.color.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '${(adjustedPotentialProgress * 100).toStringAsFixed(0)}%',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: widget.color,
                                      fontWeight: FontWeight.bold,
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
                                widget.color.withOpacity(0.3)),
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
