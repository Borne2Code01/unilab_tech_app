// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unilab_order_01/screens/cutomer_list_page.dart';
import 'package:unilab_order_01/services/database_helper.dart';
import 'providers/customer_provider.dart';
import 'providers/purchase_order_provider.dart';
import 'providers/purchase_item_provider.dart';
import 'providers/sku_provider.dart';
import 'screens/order_taking_page.dart';
import 'screens/orders_list_page.dart';
import 'screens/sku_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize DatabaseHelper and print the database path
  final dbHelper = DatabaseHelper();
  String dbPath = await dbHelper.getDatabasePath();
  print('Database path: $dbPath');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CustomerProvider()),
        ChangeNotifierProvider(create: (_) => PurchaseOrderProvider()),
        ChangeNotifierProvider(create: (_) => PurchaseItemProvider()),
        ChangeNotifierProvider(create: (_) => SKUProvider()),
      ],
      child: MaterialApp(
        title: 'Unilab CRUD',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const HomePage(),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Taking'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CustomerPage(),
                        ),
                      );
                    },
                    child: const Text('Customers'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SkuPage(),
                        ),
                      );
                    },
                    child: const Text('SKU'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const OrderPage(),
                        ),
                      );
                    },
                    child: const Text('Orders'),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: const OrderTakingPage(),
            )
          ],
        ),
      ),
    );
  }
}
