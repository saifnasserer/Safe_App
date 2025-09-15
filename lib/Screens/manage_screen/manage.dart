import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:safe/Constants.dart';
import 'package:safe/Screens/home_screen/Wallet.dart';
import 'package:safe/Screens/manage_screen/manage_widgets/add_goal_button.dart';
import 'package:safe/Screens/manage_screen/manage_widgets/goals_list_view.dart';
import 'package:safe/Screens/manage_screen/manage_widgets/manage_app_bar.dart';
import 'package:safe/Screens/manage_screen/manage_widgets/transaction_buttons.dart';
import 'package:safe/Screens/manage_screen/manage_widgets/transaction_input_form.dart';
import 'package:safe/providers/Goal_Provider.dart';
import 'package:safe/providers/Item_Provider.dart';
import 'package:safe/providers/profile_provider.dart';
import 'package:safe/providers/receipt_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:safe/utils/number_formatter.dart';
import 'package:safe/widgets/item.dart';
import 'package:safe/utils/TutorialHelper.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class Manage extends StatefulWidget {
  const Manage({super.key});
  static const String id = 'manageID';
  @override
  State<Manage> createState() => _ManageState();
}

class _ManageState extends State<Manage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final AudioPlayer audioPlayer = AudioPlayer();
  final FocusNode _amountFocusNode = FocusNode();
  final GlobalKey _titleKey = GlobalKey();
  final GlobalKey _amountKey = GlobalKey();
  final GlobalKey _addGoalKey = GlobalKey();
  final GlobalKey _transactionSectionKey = GlobalKey();
  late TutorialCoachMark? tutorialCoachMark;
  bool _isCalculatorMode = false;
  DateTime _selectedDate = DateTime.now();
  final ImagePicker _imagePicker = ImagePicker();
  bool _isProcessingImage = false;

  double getAmount() {
    try {
      if (_isCalculatorMode) {
        Parser p = Parser();
        Expression exp = p.parse(amountController.text);
        ContextModel cm = ContextModel();
        return exp.evaluate(EvaluationType.REAL, cm);
      }
      return double.parse(amountController.text);
    } catch (e) {
      return 0.0;
    }
  }

  void _toggleCalculatorMode() {
    setState(() {
      if (!_isCalculatorMode) {
        // Switching TO calculator mode
        _amountFocusNode.unfocus();
      } else {
        // Switching FROM calculator mode
        try {
          final calculatedValue = getAmount();
          if (calculatedValue != 0.0) {
            amountController.text =
                NumberFormatter.formatCalculatorNumber(calculatedValue);
          }
          _amountFocusNode.requestFocus();
        } catch (e) {
          // Keep the existing value even if there's an error
        }
      }
      _isCalculatorMode = !_isCalculatorMode;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Constants.getPrimaryColor(context),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Constants.getPrimaryColor(context),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _handleCalculatorButton(String button) {
    if (button == '⌫') {
      final currentText = amountController.text;
      if (currentText.isNotEmpty) {
        amountController.text =
            currentText.substring(0, currentText.length - 1);
      }
    } else {
      amountController.text += button;
    }
  }

  void _handleTransaction(bool isIncome) async {
    if (titleController.text.isNotEmpty && amountController.text.isNotEmpty) {
      final amount = getAmount();

      // Check for order-related words if it's an expense

      if (amount > 0) {
        final title = titleController.text.toLowerCase();
        final newItem = item(
          title: titleController.text,
          price: amount,
          flag: isIncome,
          dateTime: _selectedDate,
        );
        Provider.of<ItemProvider>(context, listen: false).addItem(newItem);
        audioPlayer.play(AssetSource('SFX/moneyAdd.mp3'));
        amountController.clear();
        titleController.clear();

        if (!isIncome) {
          final profileProvider = context.read<ProfileProvider>();
          final currentProfileId = profileProvider.currentProfile?.id;
          if (title.contains('order') ||
              title.contains('اوردر') ||
              title.contains('أوردر')) {
            showSimpleNotification(
              const Text(
                'كفااااية اوردرات',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: Constants.defaultFontFamily,
                  fontSize: 16,
                ),
              ),
              background: Colors.red,
              duration: const Duration(seconds: 2),
            );
            return;
          } else {
            showSimpleNotification(
              Text(
                WalletBlock.balanceByProfile[currentProfileId]?.value != null &&
                        WalletBlock.balanceByProfile[currentProfileId]!.value <
                            200
                    ? 'خف صرف شوية بقا المحفظة فضيت'
                    : 'تم اضافة اللي صرفتة يغالي ',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: Constants.defaultFontFamily,
                ),
              ),
              background: Colors.red,
              duration: const Duration(seconds: 2),
            );
          }
        } else {
          showSimpleNotification(
            const Text(
              'تم إضافة الدخل بنجاح',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: Constants.defaultFontFamily,
              ),
            ),
            background: Colors.green,
            duration: const Duration(seconds: 1),
          );
        }
      } else {
        _showErrorNotification();
      }
    } else {
      _showErrorNotification();
    }
  }

  void _showErrorNotification() {
    HapticFeedback.heavyImpact();
    showSimpleNotification(
      const Center(
        child: Text(
          'ضيف البيانات الناقصة',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: Constants.defaultFontFamily,
          ),
        ),
      ),
      background: Colors.red,
      duration: const Duration(seconds: 1),
    );
  }

  /// Show loading overlay for image processing
  void _showImageProcessingOverlay() {
    if (_isProcessingImage) return; // Prevent multiple overlays

    _isProcessingImage = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          contentPadding: EdgeInsets.zero,
          content: Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.95),
                  Colors.white.withOpacity(0.85),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Constants.getPrimaryColor(context).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Constants.getPrimaryColor(context)),
                    strokeWidth: 3,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'جاري معالجة الصورة...',
                  style: TextStyle(
                    fontFamily: Constants.defaultFontFamily,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'يتم استخدام الذكاء الاصطناعي لتحليل الإيصال',
                  style: TextStyle(
                    fontFamily: Constants.secondaryFontFamily,
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    ).then((_) {
      _isProcessingImage = false;
    });
  }

  /// Hide loading overlay
  void _hideImageProcessingOverlay() {
    if (_isProcessingImage) {
      Navigator.of(context).pop();
      _isProcessingImage = false;
    }
  }

  Future<void> _scanReceipt() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (image != null) {
        // Show loading overlay
        _showImageProcessingOverlay();

        try {
          final receiptProvider =
              Provider.of<ReceiptProvider>(context, listen: false);
          final receiptData = await receiptProvider.processImage(image.path,
              sourceApp: 'Camera');

          // Hide loading overlay
          _hideImageProcessingOverlay();

          if (receiptData != null && mounted) {
            // Navigate to receipt preview screen
            Navigator.pushNamed(
              context,
              '/receipts',
            );
          } else if (mounted) {
            showSimpleNotification(
              const Center(
                child: Text(
                  'فشل في معالجة الإيصال',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: Constants.defaultFontFamily,
                  ),
                ),
              ),
              background: Colors.red,
              duration: const Duration(seconds: 2),
            );
          }
        } catch (processingError) {
          // Hide loading overlay on error
          _hideImageProcessingOverlay();

          if (mounted) {
            showSimpleNotification(
              Center(
                child: Text(
                  'خطأ في معالجة الإيصال: $processingError',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: Constants.defaultFontFamily,
                  ),
                ),
              ),
              background: Colors.red,
              duration: const Duration(seconds: 2),
            );
          }
        }
      }
    } catch (e) {
      // Hide loading overlay on error
      _hideImageProcessingOverlay();

      if (mounted) {
        showSimpleNotification(
          Center(
            child: Text(
              'خطأ في مسح الإيصال: $e',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: Constants.defaultFontFamily,
              ),
            ),
          ),
          background: Colors.red,
          duration: const Duration(seconds: 2),
        );
      }
    }
  }

  Future<void> _pickReceiptFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        // Show loading overlay
        _showImageProcessingOverlay();

        try {
          final receiptProvider =
              Provider.of<ReceiptProvider>(context, listen: false);
          final receiptData = await receiptProvider.processImage(image.path,
              sourceApp: 'Gallery');

          // Hide loading overlay
          _hideImageProcessingOverlay();

          if (receiptData != null && mounted) {
            // Navigate to receipt preview screen
            Navigator.pushNamed(
              context,
              '/receipts',
            );
          } else if (mounted) {
            showSimpleNotification(
              const Center(
                child: Text(
                  'فشل في معالجة الإيصال',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: Constants.defaultFontFamily,
                  ),
                ),
              ),
              background: Colors.red,
              duration: const Duration(seconds: 2),
            );
          }
        } catch (processingError) {
          // Hide loading overlay on error
          _hideImageProcessingOverlay();

          if (mounted) {
            showSimpleNotification(
              Center(
                child: Text(
                  'خطأ في معالجة الإيصال: $processingError',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: Constants.defaultFontFamily,
                  ),
                ),
              ),
              background: Colors.red,
              duration: const Duration(seconds: 2),
            );
          }
        }
      }
    } catch (e) {
      // Hide loading overlay on error
      _hideImageProcessingOverlay();

      if (mounted) {
        showSimpleNotification(
          Center(
            child: Text(
              'خطأ في اختيار الإيصال: $e',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: Constants.defaultFontFamily,
              ),
            ),
          ),
          background: Colors.red,
          duration: const Duration(seconds: 2),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initTutorial();
    });
  }

  Future<void> _initTutorial() async {
    tutorialCoachMark = await TutorialHelper.createManageTutorial(
      context: context,
      keys: [_transactionSectionKey, _addGoalKey],
    );
    if (tutorialCoachMark != null) {
      tutorialCoachMark!.show(context: context);
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    amountController.dispose();
    _amountFocusNode.dispose();
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Constants.scaffoldBackgroundColor,
        appBar: const ManageAppBar(),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: SizedBox(
                  height: Constants.responsiveSpacing(context, 16),
                ),
              ),
              SliverToBoxAdapter(
                child: Consumer<GoalProvider>(
                  builder: (context, goalProvider, _) {
                    final goals = goalProvider.goals;
                    if (goals.isEmpty) {
                      return AddGoalButton(key: _addGoalKey);
                    }
                    return GoalsListView(
                      key: _addGoalKey,
                      goals: goals,
                      onGoalRemoved: (index) {
                        goalProvider.removeGoal(index);
                        if (goalProvider.goals.isEmpty) {
                          setState(() {});
                        }
                      },
                    );
                  },
                ),
              ),
              SliverToBoxAdapter(
                child: Column(
                  key: _transactionSectionKey,
                  children: [
                    TransactionInputForm(
                      titleController: titleController,
                      amountController: amountController,
                      amountFocusNode: _amountFocusNode,
                      isCalculatorMode: _isCalculatorMode,
                      onToggleCalculator: _toggleCalculatorMode,
                      onDateSelect: () => _selectDate(context),
                      onCalculatorButtonPressed: _handleCalculatorButton,
                      titleKey: _titleKey,
                      amountKey: _amountKey,
                    ),
                    TransactionButtons(
                      onExpense: () => _handleTransaction(false),
                      onIncome: () => _handleTransaction(true),
                    ),

                    // Receipt Scanning Section
                    Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: Constants.responsiveSpacing(context, 20),
                        vertical: Constants.responsiveSpacing(context, 16),
                      ),
                      child: Card(
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(
                              Constants.responsiveSpacing(context, 16)),
                          child: Column(
                            // crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                // mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Icon(
                                    Icons.receipt_long,
                                    color: Constants.getPrimaryColor(context),
                                    size: 24,
                                  ),
                                  SizedBox(
                                      width: Constants.responsiveSpacing(
                                          context, 8)),
                                  Text(
                                    'الإيصالات',
                                    style: TextStyle(
                                      fontFamily: Constants.defaultFontFamily,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Constants.getPrimaryColor(context),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                  height:
                                      Constants.responsiveSpacing(context, 12)),
                              Text(
                                'امسح إيصال أو فاتورة لاستخراج البيانات تلقائياً',
                                style: TextStyle(
                                  fontFamily: Constants.secondaryFontFamily,
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(
                                  height:
                                      Constants.responsiveSpacing(context, 16)),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: _scanReceipt,
                                      icon: const Icon(Icons.camera_alt),
                                      label: const Text(
                                        'مسح',
                                        style: TextStyle(
                                          fontFamily:
                                              Constants.defaultFontFamily,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            Constants.getPrimaryColor(context),
                                        foregroundColor: Colors.white,
                                        padding: EdgeInsets.symmetric(
                                          vertical: Constants.responsiveSpacing(
                                              context, 12),
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                      width: Constants.responsiveSpacing(
                                          context, 12)),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: _pickReceiptFromGallery,
                                      icon: const Icon(Icons.photo_library),
                                      label: const Text(
                                        'معرض',
                                        style: TextStyle(
                                          fontFamily:
                                              Constants.defaultFontFamily,
                                        ),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor:
                                            Constants.getPrimaryColor(context),
                                        side: BorderSide(
                                          color: Constants.getPrimaryColor(
                                              context),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                          vertical: Constants.responsiveSpacing(
                                              context, 12),
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                  height:
                                      Constants.responsiveSpacing(context, 8)),
                              Center(
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.pushNamed(context, '/receipts');
                                  },
                                  child: Text(
                                    'عرض الإيصالات الممسوحة',
                                    style: TextStyle(
                                      fontFamily: Constants.secondaryFontFamily,
                                      color: Constants.getPrimaryColor(context),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
