import 'package:flutter/foundation.dart';
import '../models/purchase_order.dart';
import '../services/database_helper.dart';

class PurchaseOrderProvider with ChangeNotifier {
  List<PurchaseOrder> _purchaseOrders = [];

  List<PurchaseOrder> get purchaseOrders => _purchaseOrders;

  Future<void> fetchPurchaseOrders() async {
    _purchaseOrders = await DatabaseHelper().getPurchaseOrders();
    notifyListeners();
  }

  Future<void> addPurchaseOrder(PurchaseOrder purchaseOrder) async {
    await DatabaseHelper().insertPurchaseOrder(purchaseOrder);
    await fetchPurchaseOrders();
  }

  Future<void> updatePurchaseOrder(PurchaseOrder purchaseOrder) async {
    await DatabaseHelper().updatePurchaseOrder(purchaseOrder);
    await fetchPurchaseOrders();
  }

  Future<void> deletePurchaseOrder(String id) async {
    int intId = int.parse(id);
    await DatabaseHelper().deletePurchaseOrder(intId.toString());
    await fetchPurchaseOrders();
  }
}
