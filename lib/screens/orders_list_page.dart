import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:unilab_order_01/main.dart';
import '../services/database_helper.dart';
import '../models/purchase_order.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  OrderPageState createState() => OrderPageState();
}

class OrderPageState extends State<OrderPage> {
  late DatabaseHelper _databaseHelper;
  List<PurchaseOrder> _orders = [];

  @override
  void initState() {
    super.initState();
    _databaseHelper = DatabaseHelper();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    final orders = await _databaseHelper.getPurchaseOrders();
    setState(() {
      _orders = orders;
    });
  }

  void _showEditModal(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Order: ${_orders[index].customerId}'),
          content: CreateEditForm(
            initialOrder: _orders[index],
            onSave: (PurchaseOrder updatedOrder) async {
              await _databaseHelper.updatePurchaseOrder(updatedOrder);
              _loadOrders();
              Navigator.of(context).pop();
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteOrder(int index) async {
    await _databaseHelper.deletePurchaseOrder(_orders[index].id.toString());
    _loadOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HomePage()),
                  );
                },
                child: const Text('Create New'),
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const <DataColumn>[
                    DataColumn(label: Text('Customer')),
                    DataColumn(label: Text('Delivery Date')),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Amount Due')),
                    DataColumn(label: Text('Action')),
                  ],
                  rows: _orders.map((order) {
                    return DataRow(cells: <DataCell>[
                      DataCell(Text(order.customerId.toString())),
                      DataCell(Text(DateFormat('MM/dd/yyyy')
                          .format(order.dateOfDelivery))),
                      DataCell(Text(order.status)),
                      DataCell(Text(order.amountDue.toString())),
                      DataCell(
                        Row(
                          children: [
                            TextButton(
                              child: const Text('Edit'),
                              onPressed: () =>
                                  _showEditModal(_orders.indexOf(order)),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () =>
                                  _deleteOrder(_orders.indexOf(order)),
                            ),
                          ],
                        ),
                      ),
                    ]);
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

class CreateEditForm extends StatefulWidget {
  final PurchaseOrder? initialOrder;
  final Function(PurchaseOrder) onSave;

  const CreateEditForm({super.key, this.initialOrder, required this.onSave});

  @override
  CreateEditFormState createState() => CreateEditFormState();
}

class CreateEditFormState extends State<CreateEditForm> {
  late TextEditingController _customerIdController;
  late TextEditingController _deliveryDateController;
  late TextEditingController _statusController;
  late TextEditingController _amountDueController;

  @override
  void initState() {
    super.initState();
    _customerIdController = TextEditingController(
        text: widget.initialOrder?.customerId.toString() ?? '');
    _deliveryDateController = TextEditingController(
        text: widget.initialOrder != null
            ? DateFormat('MM/dd/yyyy')
                .format(widget.initialOrder!.dateOfDelivery)
            : '');
    _statusController =
        TextEditingController(text: widget.initialOrder?.status ?? '');
    _amountDueController = TextEditingController(
        text: widget.initialOrder?.amountDue.toString() ?? '');
  }

  @override
  void dispose() {
    _customerIdController.dispose();
    _deliveryDateController.dispose();
    _statusController.dispose();
    _amountDueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        TextField(
          controller: _customerIdController,
          decoration: const InputDecoration(labelText: 'Customer'),
        ),
        TextField(
          controller: _deliveryDateController,
          decoration: const InputDecoration(labelText: 'Delivery Date'),
          onTap: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2101),
            );
            if (pickedDate != null) {
              setState(() {
                _deliveryDateController.text =
                    DateFormat('MM/dd/yyyy').format(pickedDate);
              });
            }
          },
        ),
        TextField(
          controller: _statusController,
          decoration: const InputDecoration(labelText: 'Status'),
        ),
        TextField(
          controller: _amountDueController,
          decoration: const InputDecoration(labelText: 'Amount Due'),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          child: const Text('Save'),
          onPressed: () {
            final newOrder = PurchaseOrder(
              id: '',
              customerId: '',
              dateOfDelivery:
                  DateFormat('MM/dd/yyyy').parse(_deliveryDateController.text),
              status: _statusController.text,
              amountDue: double.parse(_amountDueController.text),
              dateCreated: DateTime.now(),
              createdBy: widget.initialOrder?.createdBy ?? 'current_user',
              timestamp: DateTime.now(),
              userId: widget.initialOrder?.userId ?? 'user_id',
              isActive: widget.initialOrder?.isActive ?? true,
            );
            widget.onSave(newOrder);
          },
        ),
      ],
    );
  }
}
