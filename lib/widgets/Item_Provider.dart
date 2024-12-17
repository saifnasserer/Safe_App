import 'package:flutter/material.dart';
import 'package:safe/Blocks/Spent.dart';
import 'package:safe/Blocks/Wallet.dart';
import 'package:safe/utils/storage_service.dart';
import 'item.dart';

class ItemProvider extends ChangeNotifier {
  List<item> _items = [];

  ItemProvider() {
    _loadItems();
  }

  List<item> get items => _items;

  Future<void> _loadItems() async {
    _items = await StorageService.loadItems();
    notifyListeners();
  }

  Future<void> addItem(item newItem) async {
    if (newItem.flag == false) {
      // Expense
      final newWalletValue = WalletBlock.wallet.value - newItem.price;
      final newSpentValue = SpentBlock.spent.value + newItem.price;
      await WalletBlock.updateWallet(newWalletValue);
      await SpentBlock.updateSpentValue(newSpentValue);
    } else {
      // Income
      final newWalletValue = WalletBlock.wallet.value + newItem.price;
      await WalletBlock.updateWallet(newWalletValue);
    }
    _items.add(newItem);
    await StorageService.saveItems(_items);
    notifyListeners();
  }

  Future<void> removeItem(int index) async {
    if (_items[index].flag == false) {
      final newSpentValue = SpentBlock.spent.value - _items[index].price;
      final newWalletValue = WalletBlock.wallet.value + _items[index].price;
      await SpentBlock.updateSpentValue(newSpentValue);
      await WalletBlock.updateWallet(newWalletValue);
    } else {
      // If it was income
      final newWalletValue = WalletBlock.wallet.value - _items[index].price;
      await WalletBlock.updateWallet(newWalletValue);
    }
    _items.removeAt(index);
    await StorageService.saveItems(_items);
    notifyListeners();
  }
}
