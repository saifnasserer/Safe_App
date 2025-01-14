import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safe/Constants.dart';
import 'package:safe/Screens/manage_screen/manage.dart';
import 'package:safe/providers/Item_Provider.dart';
import 'package:safe/providers/Goal_Provider.dart';
import 'package:safe/utils/FirstUse.dart';
import 'package:safe/utils/transaction_filter.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:safe/Screens/recipt_screen/receipt_widgets/empty_state_widget.dart';
import 'package:safe/Screens/recipt_screen/receipt_widgets/receipt_app_bar.dart';
import 'package:safe/Screens/recipt_screen/receipt_widgets/transaction_filter_header.dart';
import 'package:safe/Screens/recipt_screen/receipt_widgets/transaction_list_view.dart';
import 'package:safe/Screens/recipt_screen/receipt_widgets/transaction_filter_dialog.dart';

class Reciept extends StatefulWidget {
  const Reciept({super.key});
  static String id = 'this is receipt Page id';

  @override
  State<Reciept> createState() => _RecieptState();
}

class _RecieptState extends State<Reciept> {
  TransactionType _currentFilter = TransactionType.all;
  final _appTutorial = AppTutorial();

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => TransactionFilterDialog(
        currentFilter: _currentFilter,
        onFilterSelected: (filter) {
          setState(() => _currentFilter = filter);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _handleDeleteItem(dynamic item) {
    final itemIndex =
        Provider.of<ItemProvider>(context, listen: false).items.indexOf(item);
    if (itemIndex >= 0) {
      // If this is a goal transaction, update the goal progress
      if (item.isGoal && item.goalIndex != null) {
        // If flag is true, it was adding to wallet (removing from goal)
        // If flag is false, it was removing from wallet (adding to goal)
        // So we need to do the opposite when deleting
        final amount = item.flag ? item.price : -item.price;
        context.read<GoalProvider>().updateGoalProgress(item.goalIndex!, amount);
      }

      Provider.of<ItemProvider>(context, listen: false).removeItem(itemIndex);
      showSimpleNotification(
        const Center(child: Text('تم الحذف')),
        background: Colors.green,
        context: context,
        duration: const Duration(seconds: 1),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkFirstUse();
    });
  }

  Future<void> _checkFirstUse() async {
    if (await _appTutorial.isFirstUse()) {
      if (mounted) {
        _appTutorial.showTutorial(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = Provider.of<ItemProvider>(context).items;

    return Scaffold(
      backgroundColor: Constants.scaffoldBackgroundColor,
      appBar: ReceiptAppBar(
        currentFilter: _currentFilter,
        onFilterTap: _showFilterDialog,
      ),
      body: items.isEmpty
          ? EmptyStateWidget(
              onAddTransaction: () => Navigator.pushNamed(context, Manage.id),
              tutorialKey: _appTutorial.goalsKey,
            )
          : Column(
              children: [
                if (_currentFilter != TransactionType.all)
                  TransactionFilterHeader(
                    items: items,
                    filterType: _currentFilter,
                  ),
                Expanded(
                  child: TransactionListView(
                    items: items,
                    filterType: _currentFilter,
                    onDeleteItem: _handleDeleteItem,
                  ),
                ),
              ],
            ),
      floatingActionButton: items.isEmpty
          ? null
          : FloatingActionButton(
              key: _appTutorial.addTransactionKey,
              onPressed: () {
                Navigator.pushNamed(context, Manage.id);
              },
              backgroundColor: Constants.getPrimaryColor(context),
              child: Icon(
                Icons.add,
                color: Colors.white,
                size: Constants.responsiveFontSize(context, 24),
              ),
            ),
    );
  }
}
