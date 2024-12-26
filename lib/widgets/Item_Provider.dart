import 'package:flutter/material.dart';
import 'package:safe/widgets/item.dart';
import 'package:safe/utils/storage_service.dart';
import 'package:safe/providers/profile_provider.dart';
import 'package:safe/Blocks/Spent.dart';
import 'package:safe/Blocks/Wallet.dart';

class ItemProvider extends ChangeNotifier {
  final ProfileProvider _profileProvider;
  final BuildContext context;
  List<item> _items = [];

  ItemProvider(this._profileProvider, this.context) {
    _loadItems();
  }

  List<item> get items => List.unmodifiable(_items);

  Future<void> _loadItems() async {
    final currentProfile = _profileProvider.currentProfile;
    if (currentProfile != null) {
      _items = await StorageService.loadItems(currentProfile.id);
      notifyListeners();
    }
  }

  Future<void> addItem(item newItem) async {
    final currentProfile = _profileProvider.currentProfile;
    if (currentProfile != null) {
      if (newItem.flag == false) {
        // Expense
        final newWalletValue = WalletBlock.wallet.value - newItem.price;
        final newSpentValue = SpentBlock.spent.value + newItem.price;
        await WalletBlock.updateWallet(context, newWalletValue);
        await SpentBlock.updateSpentValue(context, newSpentValue);
      } else {
        // Income
        final newWalletValue = WalletBlock.wallet.value + newItem.price;
        await WalletBlock.updateWallet(context, newWalletValue);
      }
      _items.add(newItem);
      await StorageService.saveItems(currentProfile.id, _items);
      notifyListeners();
    }
  }

  Future<void> removeItem(int index) async {
    final currentProfile = _profileProvider.currentProfile;
    if (currentProfile != null) {
      if (_items[index].flag == false) {
        final newSpentValue = SpentBlock.spent.value - _items[index].price;
        final newWalletValue = WalletBlock.wallet.value + _items[index].price;
        await SpentBlock.updateSpentValue(context, newSpentValue);
        await WalletBlock.updateWallet(context, newWalletValue);
      } else {
        // If it was income
        final newWalletValue = WalletBlock.wallet.value - _items[index].price;
        await WalletBlock.updateWallet(context, newWalletValue);
      }
      _items.removeAt(index);
      await StorageService.saveItems(currentProfile.id, _items);
      notifyListeners();
    }
  }
}
