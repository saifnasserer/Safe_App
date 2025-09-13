import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:safe/Constants.dart';

class TransactionButtons extends StatefulWidget {
  final VoidCallback onExpense;
  final VoidCallback onIncome;

  const TransactionButtons({
    super.key,
    required this.onExpense,
    required this.onIncome,
  });

  @override
  State<TransactionButtons> createState() => _TransactionButtonsState();
}

class _TransactionButtonsState extends State<TransactionButtons>
    with TickerProviderStateMixin {
  late AnimationController _expenseAnimationController;
  late AnimationController _incomeAnimationController;
  late Animation<double> _expenseScaleAnimation;
  late Animation<double> _incomeScaleAnimation;

  @override
  void initState() {
    super.initState();

    _expenseAnimationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _incomeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _expenseScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _expenseAnimationController,
      curve: Curves.easeInOut,
    ));

    _incomeScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _incomeAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _expenseAnimationController.dispose();
    _incomeAnimationController.dispose();
    super.dispose();
  }

  void _handleExpenseTap() {
    HapticFeedback.mediumImpact();
    _expenseAnimationController.forward().then((_) {
      _expenseAnimationController.reverse();
    });
    widget.onExpense();
  }

  void _handleIncomeTap() {
    HapticFeedback.mediumImpact();
    _incomeAnimationController.forward().then((_) {
      _incomeAnimationController.reverse();
    });
    widget.onIncome();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Constants.responsiveSpacing(context, 20),
        vertical: Constants.responsiveSpacing(context, 16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Expense Button
          AnimatedBuilder(
            animation: _expenseScaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _expenseScaleAnimation.value,
                child: SizedBox(
                  width: Constants.widthPercent(context, 40),
                  height: Constants.heightPercent(context, 7),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _handleExpenseTap,
                      borderRadius: BorderRadius.circular(
                          Constants.responsiveRadius(context, 20)),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                              Constants.responsiveRadius(context, 20)),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.red.withOpacity(0.9),
                              Colors.red.withOpacity(0.7),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.all(
                                  Constants.responsiveSpacing(context, 6)),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(
                                    Constants.responsiveSpacing(context, 8)),
                              ),
                              child: Icon(
                                Icons.trending_down_rounded,
                                color: Colors.white,
                                size: Constants.responsiveFontSize(context, 20),
                              ),
                            ),
                            SizedBox(
                                width: Constants.responsiveSpacing(context, 8)),
                            Text(
                              'صرف',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: Constants.defaultFontFamily,
                                fontSize:
                                    Constants.responsiveFontSize(context, 16),
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.3),
                                    offset: const Offset(0, 1),
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          // Income Button
          AnimatedBuilder(
            animation: _incomeScaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _incomeScaleAnimation.value,
                child: SizedBox(
                  width: Constants.widthPercent(context, 40),
                  height: Constants.heightPercent(context, 7),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _handleIncomeTap,
                      borderRadius: BorderRadius.circular(
                          Constants.responsiveRadius(context, 20)),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                              Constants.responsiveRadius(context, 20)),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.green.withOpacity(0.9),
                              Colors.green.withOpacity(0.7),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.all(
                                  Constants.responsiveSpacing(context, 6)),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(
                                    Constants.responsiveSpacing(context, 8)),
                              ),
                              child: Icon(
                                Icons.trending_up_rounded,
                                color: Colors.white,
                                size: Constants.responsiveFontSize(context, 20),
                              ),
                            ),
                            SizedBox(
                                width: Constants.responsiveSpacing(context, 8)),
                            Text(
                              'دخل',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: Constants.defaultFontFamily,
                                fontSize:
                                    Constants.responsiveFontSize(context, 16),
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.3),
                                    offset: const Offset(0, 1),
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
