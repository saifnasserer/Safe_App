import 'package:flutter/material.dart';
import 'package:safe/Constants.dart';

class item extends StatefulWidget {
  const item({
    required this.dateTime,
    super.key,
    required this.flag,
    required this.title,
    required this.price,
    this.isGoal = false,
    this.goalIndex,
  });

  final String title;
  final double price;
  final bool flag;
  final DateTime dateTime;
  final bool isGoal;
  final int? goalIndex;

  // Convert item to JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'price': price,
      'flag': flag,
      'dateTime': dateTime.toIso8601String(),
      'isGoal': isGoal,
      'goalIndex': goalIndex,
    };
  }

  // Create item from JSON
  factory item.fromJson(Map<String, dynamic> json) {
    return item(
      title: json['title'],
      price: json['price'],
      flag: json['flag'],
      dateTime: DateTime.parse(json['dateTime']),
      isGoal: json['isGoal'] ?? false,
      goalIndex: json['goalIndex'],
    );
  }

  @override
  State<item> createState() => _itemState();
}

class _itemState extends State<item> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color get _primaryColor {
    return widget.flag ? const Color(0xff399918) : const Color(0xffEE4E4E);
  }

  Color get _secondaryColor {
    return widget.flag ? const Color(0xff2E7D32) : const Color(0xffD32F2F);
  }

  IconData get _transactionIcon {
    return widget.flag
        ? Icons.trending_up_rounded
        : Icons.trending_down_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Container(
              margin: EdgeInsets.symmetric(
                horizontal: Constants.responsiveSpacing(context, 12),
                vertical: Constants.responsiveSpacing(context, 6),
              ),
              child: Card(
                elevation: 8,
                shadowColor: _primaryColor.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      Constants.responsiveSpacing(context, 16)),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                        Constants.responsiveSpacing(context, 16)),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _primaryColor,
                        _secondaryColor,
                      ],
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(
                          Constants.responsiveSpacing(context, 16)),
                      onTap: () {
                        // Add haptic feedback
                        // HapticFeedback.lightImpact();
                      },
                      child: Padding(
                        padding: EdgeInsets.all(
                            Constants.responsiveSpacing(context, 16)),
                        child: Row(
                          children: [
                            // Icon container with glassmorphism effect
                            Container(
                              width: Constants.responsiveSpacing(context, 48),
                              height: Constants.responsiveSpacing(context, 48),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(
                                    Constants.responsiveSpacing(context, 12)),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Icon(
                                _transactionIcon,
                                color: Colors.white,
                                size: Constants.responsiveFontSize(context, 24),
                              ),
                            ),
                            SizedBox(
                                width:
                                    Constants.responsiveSpacing(context, 16)),
                            // Content section
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    widget.title,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: Constants.responsiveFontSize(
                                          context, 18),
                                      fontFamily: Constants.secondaryFontFamily,
                                      fontWeight: FontWeight.w600,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black.withOpacity(0.3),
                                          offset: const Offset(0, 1),
                                          blurRadius: 2,
                                        ),
                                      ],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(
                                      height: Constants.responsiveSpacing(
                                          context, 4)),
                                  Text(
                                    _formatDate(widget.dateTime),
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: Constants.responsiveFontSize(
                                          context, 12),
                                      fontFamily: Constants.secondaryFontFamily,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Amount section
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal:
                                    Constants.responsiveSpacing(context, 12),
                                vertical:
                                    Constants.responsiveSpacing(context, 6),
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(
                                    Constants.responsiveSpacing(context, 20)),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                '${widget.price.toStringAsFixed(0)} ج.م',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize:
                                      Constants.responsiveFontSize(context, 16),
                                  fontFamily: Constants.defaultFontFamily,
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
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'اليوم';
    } else if (difference.inDays == 1) {
      return 'أمس';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} أيام';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
