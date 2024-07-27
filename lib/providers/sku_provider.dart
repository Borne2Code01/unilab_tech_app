import 'package:flutter/material.dart';
import '../models/sku.dart';
import '../services/database_helper.dart';

class SKUProvider with ChangeNotifier {
  List<Sku> _skus = [];
  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<Sku> get skus => _skus;

  Future<void> fetchSKUs() async {
    _skus = await _dbHelper.getSKUs();
    notifyListeners();
  }

  Future<void> addSKU(Sku sku) async {
    await _dbHelper.insertSKU(sku);
    await fetchSKUs();
  }

  Future<void> updateSKU(Sku sku) async {
    await _dbHelper.updateSKU(sku);
    await fetchSKUs();
  }

  Future<void> deleteSKU(int id) async {
    await _dbHelper.deleteSKU(id.toString());
    await fetchSKUs();
  }
}
