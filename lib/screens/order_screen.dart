import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:order_app/providers/dish_provider.dart';

class OrderScreen extends StatefulWidget {
  final int tableNumber;
  OrderScreen({required this.tableNumber});

  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  bool _isDeleteMode = false;
  Set<Map<String, dynamic>> _selectedDishes = {};

  void _showPaymentDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 255, 248, 181),
          title: Text('Bezahlung'),
          content: Text('Möchten Sie getrennt oder zusammen zahlen?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showSplitPaymentDialog();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.black, // Textfarbe
              ),
              child: Text('Getrennt'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.black,
                shadowColor: Colors.black, // Schattenfarbe
                elevation: 10, // Erhebung
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(15.0), // Abgerundete Ecken
                ),
                padding: EdgeInsets.symmetric(
                    horizontal: 30, vertical: 15), // Innenabstand
              ),
              onPressed: () {
                _payTogether();
                Navigator.of(context).pop();
              },
              child: Text('Zusammen'),
            ),
          ],
        );
      },
    );
  }

  void _payTogether() {
    final dishProvider = Provider.of<DishProvider>(context, listen: false);
    int tableNumber = widget.tableNumber;
    final tableOrders = dishProvider.orders[tableNumber] ?? {};

    tableOrders.forEach((category, dishes) {
      dishes.forEach((dish) {
        dishProvider.addOrderLog(dish, tableNumber);
      });
    });

    dishProvider.orders.remove(widget.tableNumber);
    dishProvider.notifyListeners();

    Navigator.of(context).pop();
  }

  void _showSplitPaymentDialog() {
    final dishProvider = Provider.of<DishProvider>(context, listen: false);
    final tableOrders = dishProvider.orders[widget.tableNumber] ?? {};
    Set<Map<String, dynamic>> _selectedDishes = {};

    showDialog(
      context: context,
      builder: (context) {
        double popupHeight = MediaQuery.of(context).size.height * 0.7;
        double popupWidth = MediaQuery.of(context).size.width * 0.9;
        return StatefulBuilder(
          builder: (context, setState) {
            double _calculateTotal() {
              return _selectedDishes.fold(
                  0.0, (sum, dish) => sum + dish['price']);
            }

            void _toggleDishSelection(
                String category, Map<String, dynamic> dish) {
              setState(() {
                if (_selectedDishes.contains(dish)) {
                  _selectedDishes.remove(dish);
                } else {
                  dish['category'] = category; // Ensure category is assigned
                  _selectedDishes.add(dish);
                }
              });
            }

            void _removeSelectedDishesFromOrders() {
              _selectedDishes.forEach((dish) {
                dishProvider.removeOrder(
                    widget.tableNumber, dish['category'], dish);
                dishProvider.addOrderLog(dish, widget.tableNumber);
              });
              _selectedDishes.clear();
              dishProvider.notifyListeners();
            }

            bool _areAllDishesPaid() {
              return tableOrders.values
                  .every((categoryDishes) => categoryDishes.isEmpty);
            }

            return AlertDialog(
              backgroundColor: const Color.fromARGB(255, 255, 248, 181),
              title: Text('Gerichte auswählen zum Bezahlen'),
              content: Container(
                width: popupWidth,
                height: popupHeight,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: ListView(
                        children: tableOrders.keys.expand((category) {
                          return tableOrders[category]!
                              .map((dish) => ListTile(
                                    title: Text(dish['name']),
                                    trailing: Text(
                                        '${dish['price'].toStringAsFixed(2)}€'),
                                    onTap: () =>
                                        _toggleDishSelection(category, dish),
                                    selected: _selectedDishes.contains(dish),
                                    selectedTileColor: Colors.red[100],
                                  ))
                              .toList();
                        }).toList(),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                              'Gesamt: ${_calculateTotal().toStringAsFixed(2)}€'),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.black,
                              shadowColor: Colors.black, // Schattenfarbe
                              elevation: 10, // Erhebung
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    15.0), // Abgerundete Ecken
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 15), // Innenabstand
                            ),
                            onPressed: () {
                              setState(() {
                                _removeSelectedDishesFromOrders();
                              });
                              if (_areAllDishesPaid()) {
                                dishProvider.orders.remove(widget.tableNumber);
                                dishProvider.notifyListeners();
                                Navigator.of(context).pop();
                              }
                            },
                            child: Text('Bezahlt'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.black, // Textfarbe
                  ),
                  child: Text('Abbrechen'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final dishProvider = Provider.of<DishProvider>(context);
    final orders = dishProvider.orders[widget.tableNumber] ?? {};

    double _calculateTotal() {
      double total = 0.0;
      orders.forEach((category, dishes) {
        for (var dish in dishes) {
          total += dish['price'];
        }
      });
      return total;
    }

    void _toggleDeleteMode([String? category, Map<String, dynamic>? dish]) {
      setState(() {
        _isDeleteMode = !_isDeleteMode;
        if (!_isDeleteMode) {
          _selectedDishes.clear();
        }
        if (_isDeleteMode && category != null && dish != null) {
          dish['category'] = category; // Ensure category is assigned
          _selectedDishes.add(dish);
        }
      });
    }

    void _toggleDishSelection(String category, Map<String, dynamic> dish) {
      setState(() {
        if (_selectedDishes.contains(dish)) {
          _selectedDishes.remove(dish);
        } else {
          dish['category'] = category; // Ensure category is assigned
          _selectedDishes.add(dish);
        }
      });
    }

    void _removeSelectedDishes() {
      final dishProvider = Provider.of<DishProvider>(context, listen: false);
      _selectedDishes.forEach((dish) {
        dishProvider.removeOrder(widget.tableNumber, dish['category'], dish);
      });
      _selectedDishes.clear();
      dishProvider.notifyListeners();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Bestellungen Tisch ${widget.tableNumber}'),
        leading: IconButton(
          icon: Icon(Icons.home),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_isDeleteMode)
            IconButton(
              icon: Icon(Icons.cancel),
              onPressed: _toggleDeleteMode,
              color: Colors.red,
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: orders.keys.expand((category) {
            return orders[category]!.map((dish) {
              return ListTile(
                title: Text(dish['name']),
                trailing: Text('${dish['price'].toStringAsFixed(2)}€'),
                onTap: _isDeleteMode
                    ? () => _toggleDishSelection(category, dish)
                    : null,
                onLongPress: !_isDeleteMode
                    ? () => _toggleDeleteMode(category, dish)
                    : null,
                selected: _selectedDishes.contains(dish),
                selectedTileColor: Colors.red[100],
              );
            }).toList();
          }).toList(),
        ),
      ),
      floatingActionButton: _isDeleteMode
          ? FloatingActionButton(
              onPressed: () {
                _removeSelectedDishes();
                _toggleDeleteMode();
              },
              child: Icon(Icons.delete),
              backgroundColor: Colors.red,
            )
          : FloatingActionButton(
              onPressed: _showAddDishDialog,
              child: Icon(Icons.add),
              backgroundColor: const Color.fromARGB(255, 133, 197, 135),
            ),
      bottomNavigationBar: BottomAppBar(
        color: const Color.fromARGB(255, 255, 248, 181),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Gesamt: ${_calculateTotal().toStringAsFixed(2)}€'),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.black,
                  shadowColor: Colors.black, // Schattenfarbe
                  elevation: 10, // Erhebung
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(15.0), // Abgerundete Ecken
                  ),
                  padding: EdgeInsets.symmetric(
                      horizontal: 30, vertical: 15), // Innenabstand
                ),
                onPressed: _showPaymentDialog,
                child: Text('Bezahlen'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddDishDialog() {
    final dishProvider = Provider.of<DishProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) {
        String selectedCategory = dishProvider.categories[0];
        Set<int> _highlightedDishes = {};

        return StatefulBuilder(
          builder: (context, setState) {
            Future<void> _highlightDish(int dishIndex) async {
              setState(() {
                _highlightedDishes.add(dishIndex);
              });
              await Future.delayed(Duration(milliseconds: 300));
              setState(() {
                _highlightedDishes.remove(dishIndex);
              });
            }

            return AlertDialog(
              backgroundColor: const Color.fromARGB(255, 255, 248, 181),
              title: Text('Gericht hinzufügen'),
              content: Container(
                width: double.maxFinite,
                height: MediaQuery.of(context).size.height * 0.7,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButton<String>(
                      value: selectedCategory,
                      items: dishProvider.categories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCategory = value!;
                        });
                      },
                    ),
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: 3,
                        children: dishProvider.dishes
                            .where((dish) => dish.category == selectedCategory)
                            .toList()
                            .asMap()
                            .entries
                            .map((entry) {
                          int index = entry.key;
                          var dish = entry.value;
                          return GestureDetector(
                            onTap: () {
                              dishProvider.addOrder(
                                  widget.tableNumber,
                                  selectedCategory,
                                  {'name': dish.name, 'price': dish.price});
                              _highlightDish(index);
                            },
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 400),
                              color: _highlightedDishes.contains(index)
                                  ? const Color.fromARGB(255, 133, 197, 135)
                                  : Colors.transparent,
                              child: Card(
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(dish.name,
                                          textAlign: TextAlign.center),
                                      Text('${dish.price.toStringAsFixed(2)}€',
                                          textAlign: TextAlign.center),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.black,
                    shadowColor: Colors.black, // Schattenfarbe
                    elevation: 10, // Erhebung
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(15.0), // Abgerundete Ecken
                    ),
                    padding: EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15), // Innenabstand
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Schließen'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
