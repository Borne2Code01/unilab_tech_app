// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:unilab_order_01/models/customer.dart';
import 'package:unilab_order_01/models/purchase_order.dart';
import 'package:unilab_order_01/models/sku.dart';
import 'package:unilab_order_01/services/database_helper.dart';
import 'package:shortid/shortid.dart';

class OrderTakingPage extends StatefulWidget {
  const OrderTakingPage({super.key});

  @override
  OrderTakingPageState createState() => OrderTakingPageState();
}

class OrderTakingPageState extends State<OrderTakingPage> {
  final List<Map<String, dynamic>> _items = [];
  late DatabaseHelper _databaseHelper;
  List<Customer> _customers = [];
  List<Sku> _skus = [];
  Customer? _selectedCustomer;
  DateTime _selectedDate = DateTime.now();
  String _status = 'New';
  TextEditingController _customerController = TextEditingController();

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
                            id: shortid.generate(),
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
                      id: shortid.generate(),
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

  Future<void> _addOrUpdateCustomer(String fullname) async {
    var existingCustomer = _customers.firstWhere(
      (customer) => customer.fullName.toLowerCase() == fullname.toLowerCase(),
      orElse: () => Customer(
        id: shortid.generate(), // default id
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
      existingCustomer = Customer(
        id: shortid.generate(), // Generate a unique ID
        mobileNumber: '',
        city: '',
        isActive: true,
        firstName: '',
        lastName: '',
        fullName: fullname,
        dateCreated: DateTime.now().toString(),
        createdBy: '',
        timestamp: DateTime.now().toString(),
        userId: '',
      );

      await _databaseHelper.insertCustomer(existingCustomer);

      setState(() {
        _customers.add(existingCustomer);
        _selectedCustomer = existingCustomer;
      });
    } else {
      setState(() {
        _selectedCustomer = existingCustomer;
      });
    }
  }

  void _saveOrder() async {
    final customerInput = _customerController.text.trim();

    if (customerInput.isNotEmpty) {
      await _addOrUpdateCustomer(customerInput);
    }

    if (_selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a customer.')),
      );
      return;
    }

    final newOrder = PurchaseOrder(
      id: shortid.generate(), // Generate a unique ID
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
      _selectedCustomer = null;
      _customerController.clear();
      _selectedDate = DateTime.now();
      _status = 'New';
      _items.clear();
    });
  }

  void _showOrderDetails(PurchaseOrder order) {
    final customer = _customers.firstWhere(
      (customer) => customer.id == order.customerId,
      orElse: () => Customer(
        id: '',
        firstName: '',
        lastName: '',
        fullName: 'Unknown',
        mobileNumber: '',
        city: '',
        isActive: false,
        dateCreated: '',
        createdBy: '',
        timestamp: '',
        userId: '',
      ),
    );

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Order Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Customer: ${customer.fullName}'),
              Text(
                  'Delivery Date: ${DateFormat.yMd().format(order.dateOfDelivery)}'),
              Text('Status: ${order.status}'),
              Text('Total Amount: ${order.amountDue.toStringAsFixed(2)}'),
              const SizedBox(height: 10),
              for (var item in _items)
                Text(
                    '${item['name']} - Quantity: ${item['quantity']} - Subtotal: ${(item['price'] * item['quantity']).toStringAsFixed(2)}'),
            ],
          ),
          actions: <Widget>[
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            children: [
              Autocomplete<Customer>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return const Iterable<Customer>.empty();
                  }
                  return _customers.where((Customer customer) => customer
                      .fullName
                      .toLowerCase()
                      .contains(textEditingValue.text.toLowerCase()));
                },
                displayStringForOption: (Customer customer) =>
                    customer.fullName,
                onSelected: (Customer selectedCustomer) {
                  _customerController.text = selectedCustomer.fullName;
                  setState(() {
                    _selectedCustomer = selectedCustomer;
                  });
                },
                fieldViewBuilder: (BuildContext context,
                    TextEditingController controller,
                    FocusNode focusNode,
                    VoidCallback onEditingComplete) {
                  _customerController = controller;
                  return TextField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: const InputDecoration(labelText: 'Customer'),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp('[a-zA-Z ]')),
                    ],
                    onChanged: (String value) {
                      if (_customers.any((customer) =>
                          customer.fullName.toLowerCase() ==
                          value.toLowerCase())) {
                        setState(() {
                          _selectedCustomer = _customers.firstWhere(
                              (customer) =>
                                  customer.fullName.toLowerCase() ==
                                  value.toLowerCase());
                        });
                      } else {
                        setState(() {
                          _selectedCustomer = null;
                        });
                      }
                    },
                    onEditingComplete: () {
                      if (!_customers.any((customer) =>
                          customer.fullName.toLowerCase() ==
                          controller.text.toLowerCase())) {
                        setState(() {
                          _selectedCustomer = null;
                        });
                      }
                      onEditingComplete();
                    },
                  );
                },
              ),
              const SizedBox(height: 16.0),
              TextField(
                decoration: const InputDecoration(labelText: 'Delivery Date'),
                controller: TextEditingController(
                    text: DateFormat('yyyy-MM-dd').format(_selectedDate)),
                readOnly: true,
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () => _openItemModal(),
                    child: const Text('Add Item'),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              ListView.builder(
                shrinkWrap: true,
                itemCount: _items.length,
                itemBuilder: (ctx, index) {
                  final item = _items[index];
                  return ListTile(
                    title: Text(item['name']),
                    subtitle: Text('Quantity: ${item['quantity']}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _openItemModal(item: item),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total: ${_totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _saveOrder,
                    child: const Text('Save Order'),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              const Text(
                'Saved Orders',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 444,
                child: ListView(
                  shrinkWrap: true,
                  children: _savedOrders.map((order) {
                    final customer = _customers.firstWhere(
                      (customer) => customer.id == order.customerId,
                      orElse: () => Customer(
                        id: '',
                        mobileNumber: '',
                        city: '',
                        isActive: false,
                        firstName: '',
                        lastName: '',
                        fullName: 'Unknown',
                        dateCreated: '',
                        createdBy: '',
                        timestamp: '',
                        userId: '',
                      ),
                    );

                    return Column(
                      children: [
                        ListTile(
                          title: Text('Order #${order.id}'),
                          subtitle: Text('Customer: ${customer.fullName}'),
                          onTap: () => _showOrderDetails(order),
                        ),
                        const Divider(color: Colors.grey),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
