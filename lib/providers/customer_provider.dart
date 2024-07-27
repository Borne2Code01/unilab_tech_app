import 'package:flutter/material.dart';
import '../models/customer.dart';
import '../services/database_helper.dart';

class CustomerProvider with ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Customer> _customers = [];

  List<Customer> get customers => _customers;

  Future<void> loadCustomers() async {
    _customers = await _databaseHelper.getCustomers();
    notifyListeners();
  }

  Future<void> addCustomer(Customer customer) async {
    await _databaseHelper.insertCustomer(customer);
    await loadCustomers();
  }

  Future<void> updateCustomer(Customer customer) async {
    await _databaseHelper.updateCustomer(customer);
    await loadCustomers();
  }

  Future<void> deleteCustomer(String id) async {
    await _databaseHelper.deleteCustomer(id);
    await loadCustomers();
  }
}
