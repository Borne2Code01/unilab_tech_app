import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:unilab_order_01/models/customer.dart';
import 'package:unilab_order_01/models/purchase_order.dart';
import 'package:unilab_order_01/models/sku.dart';
import 'package:unilab_order_01/services/database_helper.dart';
import 'package:uuid/uuid.dart';

class OrderDashboardPage extends StatefulWidget {
  const OrderDashboardPage({super.key});

  @override
  OrderDashboardPageState createState() => OrderDashboardPageState();
}

class OrderDashboardPageState extends State<OrderDashboardPage> {
  final List<Map<String, dynamic>> _items = [];
  late DatabaseHelper _databaseHelper;
  List<Customer> _customers = [];
  List<Sku> _skus = [];
  Customer? _selectedCustomer;
  DateTime _selectedDate = DateTime.now();
  String _status = 'New';

  @override
  void initState() {
    super.initState();
    _databaseHelper = DatabaseHelper();
    _loadCustomers();
    _loadSkus();
    _loadSavedOrders();
  }

  Future<void> _loadCustomers() async {
    final customers = await _databaseHelper.getCustomers();
    setState(() {
      _customers = customers;
    });
  }

  Future<void> _loadSkus() async {
    final skus = await _databaseHelper.getSKUs();
    setState(() {
      _skus = skus;
    });
  }

  Future<void> _loadSavedOrders() async {
    try {
      final orders = await _databaseHelper.getPurchaseOrders();
      setState(() {
        _savedOrders.clear();
        _savedOrders.addAll(orders);
      });
    } catch (e) {
      print('Error loading saved orders: $e');
    }
  }

  final List<PurchaseOrder> _savedOrders = [];

  double get _totalPrice {
    return _items.fold<double>(
      0.0,
      (sum, item) =>
          sum +
          ((item['price'] as double?) ?? 0.0) *
              ((item['quantity'] as int?) ?? 0),
    );
  }

  void _openItemModal({Map<String, dynamic>? item}) {
    final TextEditingController skuController = TextEditingController();
    final TextEditingController quantityController = TextEditingController();
    double subtotal = 0.0;

    if (item != null) {
      skuController.text = item['name'];
      quantityController.text = item['quantity'].toString();
      subtotal =
          (item['quantity'] as int?)! * (item['price'] as double? ?? 0.0);
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(item != null ? 'Edit Item' : 'Add Item'),
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Autocomplete<Sku>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    return _skus
                        .where((sku) => sku.name
                            .toLowerCase()
                            .contains(textEditingValue.text.toLowerCase()))
                        .toList();
                  },
                  displayStringForOption: (Sku sku) => sku.name,
                  onSelected: (Sku selectedSku) {
                    skuController.text = selectedSku.name;
                    setState(() {
                      subtotal = selectedSku.unitPrice *
                          (int.tryParse(quantityController.text) ?? 0);
                    });
                  },
                  fieldViewBuilder: (BuildContext context,
                      TextEditingController controller,
                      FocusNode focusNode,
                      VoidCallback onEditingComplete) {
                    return TextField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: const InputDecoration(labelText: 'SKU'),
                    );
                  },
                ),
                TextField(
                  controller: quantityController,
                  decoration: const InputDecoration(labelText: 'Quantity'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final selectedSku = _skus.firstWhere(
                        (sku) => sku.name == skuController.text,
                        orElse: () => Sku(
                            id: 001, // Add default id
                            name: '',
                            unitPrice: 0.0,
                            code: '',
                            isActive: true));
                    setState(() {
                      subtotal =
                          selectedSku.unitPrice * (int.tryParse(value) ?? 0);
                    });
                  },
                ),
                const SizedBox(height: 16),
                Text('Subtotal: ${subtotal.toStringAsFixed(2)}'),
              ],
            );
          },
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          ElevatedButton(
            child: const Text('Save'),
            onPressed: () {
              final selectedSku = _skus.firstWhere(
                  (sku) => sku.name == skuController.text,
                  orElse: () => Sku(
                      id: 001,
                      name: '',
                      unitPrice: 0.0,
                      code: '',
                      isActive: true));
              setState(() {
                if (item != null) {
                  item['name'] = skuController.text;
                  item['quantity'] = int.tryParse(quantityController.text) ?? 0;
                  item['price'] = selectedSku.unitPrice;
                } else {
                  _items.add({
                    'name': skuController.text,
                    'quantity': int.tryParse(quantityController.text) ?? 0,
                    'price': selectedSku.unitPrice,
                  });
                }
              });
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _addOrUpdateCustomer(String fullname) {
    final existingCustomer = _customers.firstWhere(
      (customer) => customer.fullName.toLowerCase() == fullname.toLowerCase(),
      orElse: () => Customer(
        id: '', // Provide default id
        mobileNumber: '',
        city: '',
        isActive: false,
        firstName: '',
        lastName: '',
        fullName: '',
        dateCreated: '',
        createdBy: '',
        timestamp: '',
        userId: '',
      ),
    );

    if (existingCustomer.fullName.isEmpty) {
      setState(() {
        _customers.add(Customer(
          id: '', // Provide default id
          mobileNumber: '',
          city: '',
          isActive: true,
          firstName: '',
          lastName: '',
          fullName: fullname,
          dateCreated: '',
          createdBy: '',
          timestamp: '',
          userId: '',
        ));
        _selectedCustomer = _customers.last;
        _status = 'New';
      });
    } else {
      setState(() {
        _selectedCustomer = existingCustomer;
        _status = existingCustomer.isActive ? 'Active' : 'Inactive';
      });
    }
  }

  void _saveOrder() async {
    if (_selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a customer.')),
      );
      return;
    }

    final newOrder = PurchaseOrder(
      id: const Uuid().v4(), // Generate a unique ID
      customerId: _selectedCustomer?.id ?? '',
      dateOfDelivery: _selectedDate,
      status: _status,
      amountDue: _totalPrice,
      dateCreated: DateTime.now(),
      createdBy: '',
      timestamp: DateTime.now(),
      userId: '',
      isActive: true,
    );

    try {
      await _databaseHelper.insertPurchaseOrder(newOrder);
      setState(() {
        _savedOrders.add(newOrder);
        _resetForm();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order saved to database')),
      );
    } catch (e) {
      print('Error saving order: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save order')),
      );
    }
  }

  void _resetForm() {
    setState(() {
      _items.clear();
      _selectedCustomer = null;
      _selectedDate = DateTime.now();
      _status = 'New';
    });
  }

  void _showOrderDetails(PurchaseOrder order) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Order #${order.id}'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                  'Customer: ${_customers.firstWhere((customer) => customer.id == order.customerId).fullName}'),
              Text(
                  'Delivery Date: ${DateFormat('yyyy-MM-dd').format(order.dateOfDelivery)}'),
              Text('Status: ${order.status}'),
              Text('Amount Due: ${order.amountDue.toStringAsFixed(2)}'),
              const SizedBox(height: 16),
              const Text('Items:'),
              ..._items
                  .map((item) => Text(
                      '${item['name']} - ${item['quantity']} x ${item['price'].toStringAsFixed(2)}'))
                  .toList(),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Autocomplete<Customer>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                final filteredText = textEditingValue.text
                    .replaceAll(RegExp(r'[^a-zA-Z\s]'), '')
                    .toLowerCase();
                if (filteredText.isEmpty) {
                  return [];
                }
                return _customers
                    .where((customer) =>
                        customer.fullName.toLowerCase().contains(filteredText))
                    .toList();
              },
              displayStringForOption: (Customer customer) => customer.fullName,
              onSelected: (Customer selectedCustomer) {
                setState(() {
                  _selectedCustomer = selectedCustomer;
                  _status = selectedCustomer.isActive ? 'Active' : 'Inactive';
                });
              },
              fieldViewBuilder: (BuildContext context,
                  TextEditingController controller,
                  FocusNode focusNode,
                  VoidCallback onEditingComplete) {
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: const InputDecoration(labelText: 'Customer'),
                  onChanged: (text) {
                    final filteredText =
                        text.replaceAll(RegExp(r'[^a-zA-Z\s]'), '');
                    if (filteredText != text) {
                      controller.value = controller.value.copyWith(
                        text: filteredText,
                        selection: TextSelection.collapsed(
                            offset: filteredText.length),
                      );
                    }
                    setState(() {
                      _addOrUpdateCustomer(filteredText);
                    });
                  },
                );
              },
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(labelText: 'Delivery Date'),
              controller: TextEditingController(
                  text: DateFormat('yyyy-MM-dd').format(_selectedDate)),
              onTap: () {
                FocusScope.of(context).requestFocus(FocusNode());
                _selectDate(context);
              },
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(labelText: 'Status'),
              controller: TextEditingController(text: _status),
              readOnly: true,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _openItemModal(),
              child: const Text('Add Item'),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              itemCount: _items.length,
              itemBuilder: (ctx, index) {
                final item = _items[index];
                return ListTile(
                  title: Text(
                      '${item['name']} - ${item['quantity']} x ${item['price']}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _openItemModal(item: item),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  'Total Amount: ${_totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _saveOrder,
                  child: const Text('Save Order'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Saved Orders:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ListView.builder(
              shrinkWrap: true,
              itemCount: _savedOrders.length,
              itemBuilder: (ctx, index) {
                final order = _savedOrders[index];
                final customer = _customers.firstWhere(
                  (customer) => customer.id == order.customerId,
                  orElse: () => Customer(
                    id: '', // Provide a default value or handle accordingly
                    firstName: '',
                    lastName: '',
                    fullName: 'Unknown', // Handle unknown or missing customer
                    mobileNumber: '',
                    city: '',
                    dateCreated: '',
                    createdBy: '',
                    timestamp: '',
                    userId: '',
                    isActive: false,
                  ),
                );
                return ListTile(
                  title: Text('Order #${order.id}'),
                  subtitle: Text(
                    'Customer: ${customer.fullName} - Amount Due: ${order.amountDue.toStringAsFixed(2)}',
                  ),
                  onTap: () => _showOrderDetails(order),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
