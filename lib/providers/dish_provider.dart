
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/dish.dart';
import 'dart:convert';
import 'package:flutter/material.dart'; // Dies ist notwendig, um Farben zu benutzen

class DishProvider with ChangeNotifier {
  List<Dish> _dishes = [];
  List<String> _categories = ['Hauptgericht', 'Vorspeise', 'Getränk'];
  List<int> _tables = [];
  Map<int, Map<String, List<Map<String, dynamic>>>> _orders = {};
  Map<int, String> _tableNames = {}; // Neues Map für Tisch-Namen
  List<Map<String, String>> _ordersLog = []; // Bestellprotokoll
  Map<int, Color> _inactiveTableColors = {};
  Map<int, Color> _activeTableColors = {};

  DishProvider() {
    _loadCategories();
    _loadDishes();
    _loadTables();
    _loadOrders();
    _loadTableNames(); // Tisch-Namen laden
    _loadOrdersLog(); // Bestellprotokoll laden
    _loadTableColors(); // Tisch-Farben laden
  }

  List<Dish> get dishes => _dishes;
  List<String> get categories => _categories;
  List<int> get tables => _tables;
  Map<int, Map<String, List<Map<String, dynamic>>>> get orders => _orders;
  Map<int, String> get tableNames => _tableNames; // Getter für Tisch-Namen
  List<Map<String, String>> get ordersLog => _ordersLog; // Getter für Bestellprotokoll
  Map<int, Color> get inactiveTableColors => _inactiveTableColors; // Getter für inaktive Farben
  Map<int, Color> get activeTableColors => _activeTableColors; // Getter für aktive Farben

  Future<void> _loadCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final String? categoriesString = prefs.getString('categories');
    if (categoriesString != null) {
      _categories =
          (json.decode(categoriesString) as List<dynamic>).cast<String>();
      notifyListeners();
    }
  }

  Future<void> _saveCategories() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('categories', json.encode(_categories));
  }

  Future<void> _loadDishes() async {
    final prefs = await SharedPreferences.getInstance();
    final String? dishesString = prefs.getString('dishes');
    if (dishesString != null) {
      _dishes = (json.decode(dishesString) as List<dynamic>)
          .map((item) => Dish(
              name: item['name'],
              category: item['category'],
              price: item['price']))
          .toList();
      notifyListeners();
    }
  }

  Future<void> _saveDishes() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(
        'dishes',
        json.encode(_dishes
            .map((dish) => {
                  'name': dish.name,
                  'category': dish.category,
                  'price': dish.price,
                })
            .toList()));
  }

  Future<void> _loadTables() async {
    final prefs = await SharedPreferences.getInstance();
    final String? tablesString = prefs.getString('tables');
    if (tablesString != null) {
      _tables = (json.decode(tablesString) as List<dynamic>).cast<int>();
      notifyListeners();
    }
  }

  Future<void> _saveTables() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('tables', json.encode(_tables));
  }

  Future<void> _loadOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final String? ordersString = prefs.getString('orders');
    if (ordersString != null) {
      _orders =
          (json.decode(ordersString) as Map<String, dynamic>).map((key, value) {
        return MapEntry(
            int.parse(key),
            (value as Map<String, dynamic>).map((key, value) {
              return MapEntry(
                  key,
                  (value as List<dynamic>)
                      .map((item) => item as Map<String, dynamic>)
                      .toList());
            }));
      });
      notifyListeners();
    }
  }

  Future<void> _saveOrders() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('orders', json.encode(_orders.map((key, value) {
      return MapEntry(key.toString(), value);
    })));
  }

  Future<void> _loadTableNames() async {
    final prefs = await SharedPreferences.getInstance();
    final String? tableNamesString = prefs.getString('tableNames');
    if (tableNamesString != null) {
      _tableNames = (json.decode(tableNamesString) as Map<String, dynamic>)
          .map((key, value) {
        return MapEntry(int.parse(key), value as String);
      });
      notifyListeners();
    }
  }

  Future<void> _saveTableNames() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('tableNames', json.encode(_tableNames.map((key, value) {
      return MapEntry(key.toString(), value);
    })));
  }

  Future<void> _loadOrdersLog() async {
    final prefs = await SharedPreferences.getInstance();
    final String? ordersLogString = prefs.getString('ordersLog');
    if (ordersLogString != null) {
      _ordersLog = (json.decode(ordersLogString) as List<dynamic>)
          .map((item) => {
                'date': item['date'] as String,
                'details': item['details'] as String,
              })
          .toList()
          .cast<Map<String, String>>();
      notifyListeners();
    }
  }

  Future<void> _saveOrdersLog() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('ordersLog', json.encode(_ordersLog));
  }

  Future<void> _loadTableColors() async {
    final prefs = await SharedPreferences.getInstance();
    final String? activeColorsString = prefs.getString('activeTableColors');
    final String? inactiveColorsString = prefs.getString('inactiveTableColors');

    if (activeColorsString != null && inactiveColorsString != null) {
      _activeTableColors = (json.decode(activeColorsString) as Map<String, dynamic>)
          .map((key, value) => MapEntry(int.parse(key), Color(value)));
      _inactiveTableColors = (json.decode(inactiveColorsString) as Map<String, dynamic>)
          .map((key, value) => MapEntry(int.parse(key), Color(value)));
      notifyListeners();
    }
  }

  Future<void> _saveTableColors() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('activeTableColors', json.encode(_activeTableColors.map((key, value) {
      return MapEntry(key.toString(), value.value);
    })));
    prefs.setString('inactiveTableColors', json.encode(_inactiveTableColors.map((key, value) {
      return MapEntry(key.toString(), value.value);
    })));
  }

  void addDish(String name, String category, double price) {
    _dishes.add(Dish(name: name, category: category, price: price));
    _saveDishes();
    notifyListeners();
  }

  void updateDish(
      int index, String newName, String newCategory, double newPrice) {
    _dishes[index] =
        Dish(name: newName, category: newCategory, price: newPrice);
    _saveDishes();
    notifyListeners();
  }

  void deleteDish(int index) {
    _dishes.removeAt(index);
    _saveDishes();
    notifyListeners();
  }

  void addCategory(String category) {
    _categories.add(category);
    _saveCategories();
    notifyListeners();
  }

  void deleteCategory(String category) {
    _categories.remove(category);
    _dishes.removeWhere((dish) => dish.category == category);
    _saveCategories();
    _saveDishes();
    notifyListeners();
  }

  void addTable(int tableNumber) {
    _tables.add(tableNumber);
    _saveTables();
    notifyListeners();
  }

  void deleteTable(int tableNumber) {
    _tables.remove(tableNumber);
    _orders.remove(tableNumber);
    _tableNames.remove(tableNumber); // Tischnamen auch entfernen
    _inactiveTableColors.remove(tableNumber); // Entfernen Sie die inaktive Farbe des Tisches
    _activeTableColors.remove(tableNumber); // Entfernen Sie die aktive Farbe des Tisches
    _saveTables();
    _saveOrders();
    _saveTableNames(); // Namen speichern
    _saveTableColors(); // Farben speichern
    notifyListeners();
  }

  void updateTableName(int tableNumber, String newName) {
    _tableNames[tableNumber] = newName;
    _saveTableNames();
    notifyListeners();
  }

  void updateTableColors(int tableNumber, Color inactive, Color active) {
    _inactiveTableColors[tableNumber] = inactive;
    _activeTableColors[tableNumber] = active;
    _saveTableColors();
    notifyListeners();
  }

  void addOrder(int tableNumber, String category, Map<String, dynamic> dish) {
    if (!_orders.containsKey(tableNumber)) {
      _orders[tableNumber] = {};
    }
    if (!_orders[tableNumber]!.containsKey(category)) {
      _orders[tableNumber]![category] = [];
    }
    _orders[tableNumber]![category]!.add(dish);
    _saveOrders();
    notifyListeners();
  }

  void removeOrder(int tableNumber, String category, Map<String, dynamic> dish) {
    if (orders.containsKey(tableNumber) &&
        orders[tableNumber]!.containsKey(category)) {
      _orders[tableNumber]![category]!.remove(dish);
      if (_orders[tableNumber]![category]!.isEmpty) {
        _orders[tableNumber]!.remove(category);
      }
      _saveOrders();
      notifyListeners();
    }
  }

  void addOrderLog(Map<String, dynamic> dish, int tableNumber) {
    String date = DateTime.now().toIso8601String().split('T').first;
    String details =
        "Tisch $tableNumber: ${dish['name']} für ${dish['price']}€";
    _ordersLog.add({'date': date, 'details': details});
    _saveOrdersLog();
    notifyListeners();
  }

  void clearOrdersLog() {
    _ordersLog.clear();
    _saveOrdersLog();
    notifyListeners();
  }
}