import 'package:flutter/material.dart';
import 'package:unilab_order_01/models/customer.dart';
import '../services/database_helper.dart';

class CustomerPage extends StatefulWidget {
  const CustomerPage({super.key});

  @override
  CustomerPageState createState() => CustomerPageState();
}

class CustomerPageState extends State<CustomerPage> {
  late DatabaseHelper _databaseHelper;
  List<Customer> _customers = [];

  @override
  void initState() {
    super.initState();
    _databaseHelper = DatabaseHelper();
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    final customers = await _databaseHelper.getCustomers();
    setState(() {
      _customers = customers;
    });
  }

  List<Customer> get customers => _customers;

  void _showCreateModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create New Customer'),
          content: CreateEditForm(
            onSave: (Customer newCustomer) async {
              await _databaseHelper.insertCustomer(newCustomer);
              _loadCustomers();
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

  void _showEditModal(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Customer: ${_customers[index].fullName}'),
          content: CreateEditForm(
            initialCustomer: _customers[index],
            onSave: (Customer updatedCustomer) async {
              await _databaseHelper.updateCustomer(updatedCustomer);
              _loadCustomers();
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

  void _deleteCustomer(int index) async {
    await _databaseHelper.deleteCustomer(_customers[index].id);
    _loadCustomers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              ElevatedButton(
                onPressed: () => _showCreateModal(context),
                child: const Text('Create New'),
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const <DataColumn>[
                    DataColumn(label: Text('Fullname')),
                    DataColumn(label: Text('Mobile Number')),
                    DataColumn(label: Text('City')),
                    DataColumn(label: Text('Is Active')),
                    DataColumn(label: Text('Action')),
                  ],
                  rows: _customers.map((customer) {
                    return DataRow(cells: <DataCell>[
                      DataCell(Text(customer.fullName)),
                      DataCell(Text(customer.mobileNumber)),
                      DataCell(Text(customer.city)),
                      DataCell(Text(customer.isActive ? 'TRUE' : 'FALSE')),
                      DataCell(
                        Row(
                          children: [
                            TextButton(
                              child: const Text('Edit'),
                              onPressed: () => _showEditModal(
                                  context, _customers.indexOf(customer)),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () =>
                                  _deleteCustomer(_customers.indexOf(customer)),
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
  final Customer? initialCustomer;
  final Function(Customer) onSave;

  const CreateEditForm({super.key, this.initialCustomer, required this.onSave});

  @override
  CreateEditFormState createState() => CreateEditFormState();
}

class CreateEditFormState extends State<CreateEditForm> {
  late TextEditingController _fullnameController;
  late TextEditingController _mobileNumberController;
  late TextEditingController _cityController;
  bool _isActive = true;
  late String _id;

  @override
  void initState() {
    super.initState();
    if (widget.initialCustomer != null) {
      _fullnameController =
          TextEditingController(text: widget.initialCustomer!.fullName);
      _mobileNumberController =
          TextEditingController(text: widget.initialCustomer!.mobileNumber);
      _cityController =
          TextEditingController(text: widget.initialCustomer!.city);
      _isActive = widget.initialCustomer!.isActive;
      _id = widget.initialCustomer!.id;
    } else {
      _fullnameController = TextEditingController();
      _mobileNumberController = TextEditingController();
      _cityController = TextEditingController();
      _isActive = true;
      _id = ''; // Default for new customers
    }
  }

  @override
  void dispose() {
    _fullnameController.dispose();
    _mobileNumberController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        TextField(
          controller: _fullnameController,
          decoration: const InputDecoration(labelText: 'Fullname'),
        ),
        TextField(
          controller: _mobileNumberController,
          decoration: const InputDecoration(labelText: 'Mobile Number'),
        ),
        TextField(
          controller: _cityController,
          decoration: const InputDecoration(labelText: 'City'),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            const Text('Is Active'),
            Switch(
              value: _isActive,
              onChanged: (bool value) {
                setState(() {
                  _isActive = value;
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          child: const Text('Save'),
          onPressed: () {
            final newCustomer = Customer(
              id: _id.isEmpty ? DateTime.now().toString() : _id,
              fullName: _fullnameController.text,
              mobileNumber: _mobileNumberController.text,
              city: _cityController.text,
              dateCreated: '',
              createdBy: 'current_user',
              timestamp: '',
              userId: 'user_id',
              isActive: _isActive,
              firstName: '',
              lastName: '',
            );
            widget.onSave(newCustomer);
          },
        ),
      ],
    );
  }
}
