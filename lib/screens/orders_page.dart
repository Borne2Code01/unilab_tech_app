import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  OrderPageState createState() => OrderPageState();
}

class OrderPageState extends State<OrderPage> {
  final List<Order> _orders = [
    Order(
        customer: 'Riza, Jose',
        deliveryDate: DateTime(2020, 4, 14),
        status: 'New',
        amountDue: 3400),
    Order(
        customer: 'Jhonson, Edward',
        deliveryDate: DateTime(2020, 4, 20),
        status: 'New',
        amountDue: 3500),
    Order(
        customer: 'Garcia, Philip',
        deliveryDate: DateTime(2020, 3, 10),
        status: 'Completed',
        amountDue: 10280),
    Order(
        customer: 'Riza, Jose',
        deliveryDate: DateTime(2021, 2, 1),
        status: 'New',
        amountDue: 1500),
    Order(
        customer: 'Riza, Jose',
        deliveryDate: DateTime(2021, 2, 1),
        status: 'New',
        amountDue: 500),
  ];

  void _showCreateModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create New Order'),
          content: CreateEditForm(
            onSave: (Order newOrder) {
              setState(() {
                _orders.add(newOrder);
              });
              Navigator.of(context).pop(); // Close the dialog
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  void _showEditModal(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Order: ${_orders[index].customer}'),
          content: CreateEditForm(
            initialOrder: _orders[index],
            onSave: (Order updatedOrder) {
              setState(() {
                _orders[index] = updatedOrder;
              });
              Navigator.of(context).pop(); // Close the dialog
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
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
      appBar: AppBar(
        title: const Text('Orders'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              ElevatedButton(
                onPressed: _showCreateModal,
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
                      DataCell(Text(order.customer)),
                      DataCell(Text(
                          DateFormat('MM/dd/yyyy').format(order.deliveryDate))),
                      DataCell(Text(order.status)),
                      DataCell(Text(order.amountDue.toString())),
                      DataCell(
                        TextButton(
                          child: const Text('Edit'),
                          onPressed: () =>
                              _showEditModal(_orders.indexOf(order)),
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
  final Order? initialOrder;
  final Function(Order) onSave;

  const CreateEditForm({super.key, this.initialOrder, required this.onSave});

  @override
  CreateEditFormState createState() => CreateEditFormState();
}

class CreateEditFormState extends State<CreateEditForm> {
  late TextEditingController _customerController;
  late TextEditingController _deliveryDateController;
  late TextEditingController _statusController;
  late TextEditingController _amountDueController;

  @override
  void initState() {
    super.initState();
    _customerController =
        TextEditingController(text: widget.initialOrder?.customer ?? '');
    _deliveryDateController = TextEditingController(
        text: widget.initialOrder != null
            ? DateFormat('MM/dd/yyyy').format(widget.initialOrder!.deliveryDate)
            : '');
    _statusController =
        TextEditingController(text: widget.initialOrder?.status ?? '');
    _amountDueController = TextEditingController(
        text: widget.initialOrder?.amountDue.toString() ?? '');
  }

  @override
  void dispose() {
    _customerController.dispose();
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
          controller: _customerController,
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
            final newOrder = Order(
              customer: _customerController.text,
              deliveryDate:
                  DateFormat('MM/dd/yyyy').parse(_deliveryDateController.text),
              status: _statusController.text,
              amountDue: double.parse(_amountDueController.text),
            );
            widget.onSave(newOrder);
          },
        ),
      ],
    );
  }
}

class Order {
  final String customer;
  final DateTime deliveryDate;
  final String status;
  final double amountDue;

  Order({
    required this.customer,
    required this.deliveryDate,
    required this.status,
    required this.amountDue,
  });
}
