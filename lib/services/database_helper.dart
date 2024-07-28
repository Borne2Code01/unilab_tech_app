import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/sku.dart';
import '../models/customer.dart';
import '../models/purchase_order.dart';
import '../models/purchase_item.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'crud_system.db');
    return openDatabase(
      path,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE SKUs (
            id TEXT PRIMARY KEY,
            name TEXT,
            code TEXT,
            unitPrice REAL,
            dateCreated TEXT,
            createdBy TEXT,
            timestamp TEXT,
            userId TEXT,
            isActive INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE Customers (
            id TEXT PRIMARY KEY,
            firstName TEXT,
            lastName TEXT,
            fullName TEXT,
            mobileNumber TEXT,
            city TEXT,
            dateCreated TEXT,
            createdBy TEXT,
            timestamp TEXT,
            userId TEXT,
            isActive INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE PurchaseOrders (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            customerId TEXT,
            dateOfDelivery TEXT,
            status TEXT,
            amountDue REAL,
            dateCreated TEXT,
            createdBy TEXT,
            timestamp TEXT,
            userId TEXT,
            isActive INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE PurchaseItems (
            id TEXT PRIMARY KEY,
            purchaseOrderId TEXT,
            skuId TEXT,
            quantity INTEGER,
            price REAL,
            timestamp TEXT,
            userId TEXT
          )
        ''');
      },
      version: 2,
    );
  }

  // SKU methods
  Future<int> insertSKU(Sku sku) async {
    final db = await database;
    return await db.insert('SKUs', sku.toMap());
  }

  Future<List<Sku>> getSKUs() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('SKUs');
    return List.generate(maps.length, (i) {
      return Sku.fromMap(maps[i]);
    });
  }

  Future<int> updateSKU(Sku sku) async {
    final db = await database;
    return await db.update(
      'SKUs',
      sku.toMap(),
      where: 'id = ?',
      whereArgs: [sku.id],
    );
  }

  Future<int> deleteSKU(String id) async {
    final db = await database;
    return await db.delete(
      'SKUs',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Customer methods
  Future<int> insertCustomer(Customer customer) async {
    final db = await database;
    return await db.insert('Customers', customer.toJson());
  }

  Future<List<Customer>> getCustomers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('Customers');
    return List.generate(maps.length, (i) {
      return Customer.fromJson(maps[i]);
    });
  }

  Future<int> updateCustomer(Customer customer) async {
    final db = await database;
    return await db.update(
      'Customers',
      customer.toJson(),
      where: 'id = ?',
      whereArgs: [customer.id],
    );
  }

  Future<int> deleteCustomer(String id) async {
    final db = await database;
    return await db.delete(
      'Customers',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // PurchaseOrder methods
  Future<int> insertPurchaseOrder(PurchaseOrder purchaseOrder) async {
    final db = await database;
    return await db.insert(
      'PurchaseOrders',
      {
        'customerId': purchaseOrder.customerId,
        'dateOfDelivery': purchaseOrder.dateOfDelivery.toIso8601String(),
        'status': purchaseOrder.status,
        'amountDue': purchaseOrder.amountDue,
        'dateCreated': purchaseOrder.dateCreated.toIso8601String(),
        'createdBy': purchaseOrder.createdBy,
        'timestamp': purchaseOrder.timestamp.toIso8601String(),
        'userId': purchaseOrder.userId,
        'isActive': purchaseOrder.isActive ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<PurchaseOrder>> getPurchaseOrders() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('PurchaseOrders');
    return List.generate(maps.length, (i) {
      return PurchaseOrder.fromMap(maps[i]);
    });
  }

  Future<int> updatePurchaseOrder(PurchaseOrder purchaseOrder) async {
    final db = await database;
    return await db.update(
      'PurchaseOrders',
      {
        'customerId': purchaseOrder.customerId,
        'dateOfDelivery': purchaseOrder.dateOfDelivery.toIso8601String(),
        'status': purchaseOrder.status,
        'amountDue': purchaseOrder.amountDue,
        'dateCreated': purchaseOrder.dateCreated.toIso8601String(),
        'createdBy': purchaseOrder.createdBy,
        'timestamp': purchaseOrder.timestamp.toIso8601String(),
        'userId': purchaseOrder.userId,
        'isActive': purchaseOrder.isActive ? 1 : 0,
      },
      where: 'id = ?',
      whereArgs: [purchaseOrder.id],
    );
  }

  Future<int> deletePurchaseOrder(String id) async {
    final db = await database;
    return await db.delete(
      'PurchaseOrders',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // PurchaseItem methods
  Future<int> insertPurchaseItem(PurchaseItem purchaseItem) async {
    final db = await database;
    return await db.insert('PurchaseItems', purchaseItem.toJson());
  }

  Future<List<PurchaseItem>> getPurchaseItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('PurchaseItems');
    return List.generate(maps.length, (i) {
      return PurchaseItem.fromJson(maps[i]);
    });
  }

  Future<int> updatePurchaseItem(PurchaseItem purchaseItem) async {
    final db = await database;
    return await db.update(
      'PurchaseItems',
      purchaseItem.toJson(),
      where: 'id = ?',
      whereArgs: [purchaseItem.id],
    );
  }

  Future<int> deletePurchaseItem(String id) async {
    final db = await database;
    return await db.delete(
      'PurchaseItems',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Method to get database path
  Future<String> getDatabasePath() async {
    return join(await getDatabasesPath(), 'crud_system.db');
  }
}
