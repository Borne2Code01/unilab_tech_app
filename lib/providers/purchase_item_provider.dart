import 'package:flutter/foundation.dart';
import '../models/purchase_item.dart';
import '../services/database_helper.dart';

class PurchaseItemProvider with ChangeNotifier {
  List<PurchaseItem> _purchaseItems = [];

  List<PurchaseItem> get purchaseItems => _purchaseItems;

  Future<void> fetchPurchaseItems() async {
    _purchaseItems = await DatabaseHelper().getPurchaseItems();
    notifyListeners();
  }

  Future<void> addPurchaseItem(PurchaseItem purchaseItem) async {
    await DatabaseHelper().insertPurchaseItem(purchaseItem);
    await fetchPurchaseItems();
  }

  Future<void> updatePurchaseItem(PurchaseItem purchaseItem) async {
    await DatabaseHelper().updatePurchaseItem(purchaseItem);
    await fetchPurchaseItems();
  }

  Future<void> deletePurchaseItem(String id) async {
    await DatabaseHelper().deletePurchaseItem(id);
    await fetchPurchaseItems();
  }
}
