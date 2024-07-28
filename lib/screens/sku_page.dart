import 'package:flutter/material.dart';
import 'package:unilab_order_01/models/sku.dart';
import '../services/database_helper.dart';

class SkuPage extends StatefulWidget {
  const SkuPage({super.key});

  @override
  SkuPageState createState() => SkuPageState();
}

class SkuPageState extends State<SkuPage> {
  late DatabaseHelper _databaseHelper;
  List<Sku> _skus = [];

  @override
  void initState() {
    super.initState();
    _databaseHelper = DatabaseHelper();
    _loadSkus();
  }

  Future<void> _loadSkus() async {
    final List<Sku> skus = await _databaseHelper.getSKUs();
    setState(() {
      _skus = skus;
    });
  }

  void _showCreateModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create New SKU'),
          content: CreateEditForm(
            onSave: (Sku newSku) async {
              await _databaseHelper.insertSKU(newSku);
              _loadSkus();
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
          title: const Text('Edit SKU'),
          content: CreateEditForm(
            initialSku: _skus[index],
            onSave: (Sku updatedSku) async {
              await _databaseHelper.updateSKU(updatedSku);
              _loadSkus();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SKUs'),
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
                    DataColumn(label: Text('Name')),
                    DataColumn(label: Text('Code')),
                    DataColumn(label: Text('Unit Price')),
                    DataColumn(label: Text('Is Active')),
                    DataColumn(label: Text('Image')),
                    DataColumn(label: Text('Action')),
                  ],
                  rows: _skus.map((sku) {
                    return DataRow(cells: <DataCell>[
                      DataCell(Text(sku.name)),
                      DataCell(Text(sku.code)),
                      DataCell(Text(sku.unitPrice.toString())),
                      DataCell(Text(sku.isActive ? 'TRUE' : 'FALSE')),
                      DataCell(
                        IconButton(
                          icon: const Icon(Icons.image),
                          onPressed: () {
                            // Add functionality to show the image
                          },
                        ),
                      ),
                      DataCell(
                        TextButton(
                          child: const Text('Edit'),
                          onPressed: () =>
                              _showEditModal(context, _skus.indexOf(sku)),
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
  final Sku? initialSku;
  final Function(Sku) onSave;

  const CreateEditForm({super.key, this.initialSku, required this.onSave});

  @override
  CreateEditFormState createState() => CreateEditFormState();
}

class CreateEditFormState extends State<CreateEditForm> {
  late TextEditingController _nameController;
  late TextEditingController _codeController;
  late TextEditingController _unitPriceController;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialSku?.name);
    _codeController = TextEditingController(text: widget.initialSku?.code);
    _unitPriceController =
        TextEditingController(text: widget.initialSku?.unitPrice.toString());
    _isActive = widget.initialSku?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _unitPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(labelText: 'Name'),
        ),
        TextField(
          controller: _codeController,
          decoration: const InputDecoration(labelText: 'Code'),
        ),
        TextField(
          controller: _unitPriceController,
          decoration: const InputDecoration(labelText: 'Unit Price'),
          keyboardType: TextInputType.number,
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
            final newSku = Sku(
              name: _nameController.text,
              code: _codeController.text,
              unitPrice: double.parse(_unitPriceController.text),
              isActive: _isActive,
            );
            widget.onSave(newSku);
          },
        ),
      ],
    );
  }
}
