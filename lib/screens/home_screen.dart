import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:order_app/screens/adddishscreen.dart';
import 'package:order_app/screens/dishlistscreen.dart';
import 'package:order_app/screens/settings_screen.dart';
import 'package:order_app/screens/order_screen.dart';
import 'package:order_app/providers/dish_provider.dart';
import 'package:order_app/screens/OrderLogScreen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  bool _isDeleteMode = false;
  int _selectedIndex = 0;
  List<int> _selectedTables = [];
  late AnimationController _animationController;

  final List<Color> colorOptions = [
    Colors.grey,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple
  ]; // Inaktive Farben
  final List<Color> activeColorOptions = [
    Colors.blue,
    Colors.grey,
    Colors.green,
    Colors.orange,
    Colors.purple
  ]; // Aktive Farben

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200), // Geschwindigkeit der Animation
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _addTable() {
    final dishProvider = Provider.of<DishProvider>(context, listen: false);
    int newTableNumber = 1;

    while (dishProvider.tables.contains(newTableNumber)) {
      newTableNumber++;
    }

    dishProvider.addTable(newTableNumber);
  }

  void _toggleDeleteMode() {
    setState(() {
      _isDeleteMode = !_isDeleteMode;
      _selectedTables.clear();
      if (_isDeleteMode) {
        _animationController.repeat(reverse: true);
      } else {
        _animationController.stop();
      }
    });
  }

  void _toggleTableSelection(int tableNumber) {
    setState(() {
      if (_selectedTables.contains(tableNumber)) {
        _selectedTables.remove(tableNumber);
      } else {
        _selectedTables.add(tableNumber);
      }
    });
  }

  void _deleteSelectedTables() {
    final dishProvider = Provider.of<DishProvider>(context, listen: false);
    for (var table in _selectedTables) {
      dishProvider.deleteTable(table);
    }
    _toggleDeleteMode();
  }

  void _navigateToOrderScreen(int tableNumber) {
    if (!_isDeleteMode) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OrderScreen(tableNumber: tableNumber),
        ),
      );
    } else {
      _toggleTableSelection(tableNumber);
    }
  }

  void _editTableName() {
    final dishProvider = Provider.of<DishProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Color.fromARGB(255, 255, 248, 181),
          title: Text('Tisch wählen'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: dishProvider.tables.map((table) {
                return ListTile(
                  title: Text(dishProvider.tableNames[table] ?? 'Tisch $table'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _showEditTableNameDialog(table);
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  void _showEditTableNameDialog(int tableNumber) {
    final TextEditingController controller = TextEditingController();
    final dishProvider = Provider.of<DishProvider>(context, listen: false);
    String currentName =
        dishProvider.tableNames[tableNumber] ?? 'Tisch $tableNumber';

    // Initialisieren Sie die Farben basierend auf den gespeicherten Werten oder Standardwerten
    Color inaktivColor =
        dishProvider.inactiveTableColors[tableNumber] ?? Colors.grey;
    Color aktivColor =
        dishProvider.activeTableColors[tableNumber] ?? Colors.blue;

    controller.text = currentName;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 255, 248, 181),
          title: Text('Tischnamen und Farben ändern'),
          content: SingleChildScrollView(
            child: StatefulBuilder(
              builder: (context, StateSetter setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        hintText: 'Neuer Tischname',
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors
                                .black, // Farbe des Unterstrichs beim Fokussieren
                            width: 2.0,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    DropdownButton<Color>(
                      value: colorOptions.contains(inaktivColor)
                          ? inaktivColor
                          : null,
                      hint: Text("Inaktive Farbe"),
                      items: colorOptions.map((Color color) {
                        return DropdownMenuItem<Color>(
                          value: color,
                          child: Text(colorToString(color)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          inaktivColor = value!;
                        });
                      },
                    ),
                    DropdownButton<Color>(
                      value: activeColorOptions.contains(aktivColor)
                          ? aktivColor
                          : null,
                      hint: Text("Aktive Farbe"),
                      items: activeColorOptions.map((Color color) {
                        return DropdownMenuItem<Color>(
                          value: color,
                          child: Text(colorToString(color)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          aktivColor = value!;
                        });
                      },
                    )
                  ],
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.black, // Textfarbe
              ),
              child: Text('Abbrechen'),
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
                dishProvider.updateTableName(tableNumber, controller.text);
                dishProvider.updateTableColors(
                    tableNumber, inaktivColor, aktivColor);
                Navigator.of(context).pop();
              },
              child: Text('Speichern'),
            ),
          ],
        );
      },
    );
  }

  String colorToString(Color color) {
    switch (color) {
      case Colors.grey:
        return "Grau";
      case Colors.red:
        return "Rot";
      case Colors.green:
        return "Grün";
      case Colors.blue:
        return "Blau";
      case Colors.orange:
        return "Orange";
      case Colors.purple:
        return "Lila";
      default:
        return "Unbekannt";
    }
  }

  void _onNavigationBarTapped(int index) {
    if (!_isDeleteMode) {
      setState(() {
        _selectedIndex = index;
      });
      if (index == 0) {
        // Bleibe auf dem HomeScreen
      } else if (index == 1) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => AddDishScreen()),
          (route) => false,
        );
      } else if (index == 2) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => DishListScreen()),
          (route) => false,
        );
      } else if (index == 3) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => SettingsScreen()),
          (route) => false,
        );
      } else if (index == 4) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => OrderLogScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dishProvider = Provider.of<DishProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Bestell App'),
        actions: [
          if (_isDeleteMode)
            IconButton(
              icon: Icon(Icons.cancel),
              onPressed: _toggleDeleteMode,
              color: Colors.red,
            ),
          IconButton(
            icon: Icon(Icons.edit, color: Colors.black),
            onPressed: _editTableName,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // Anzahl der Spalten
            childAspectRatio: 1, // Verhältnis von Breite zu Höhe
            crossAxisSpacing: 8, // Abstand zwischen den Spalten
            mainAxisSpacing: 8, // Abstand zwischen den Zeilen
          ),
          itemCount: dishProvider.tables.length,
          itemBuilder: (context, index) {
            int table = dishProvider.tables[index];
            bool hasOrders = dishProvider.orders[table]?.isNotEmpty ?? false;
            Color tableColor;
            String tableName = dishProvider.tableNames[table] ?? 'Tisch $table';
            bool isSelected = _selectedTables.contains(table);

            if (_isDeleteMode && isSelected) {
              tableColor = Colors.red.shade300;
            } else if (_isDeleteMode) {
              tableColor = Colors.red;
            } else {
              tableColor = hasOrders
                  ? (dishProvider.activeTableColors[table] ?? Colors.blue)
                  : (dishProvider.inactiveTableColors[table] ?? Colors.grey);
            }

            return GestureDetector(
              onLongPress: () {
                Future.delayed(Duration(seconds: 1), () {
                  if (!_isDeleteMode) {
                    setState(() {
                      _isDeleteMode = true;
                      _animationController.repeat(reverse: true);
                    });
                  }
                  _toggleTableSelection(table);
                });
              },
              onTap: () => _navigateToOrderScreen(table),
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  double angle = _isDeleteMode
                      ? 0.04 * (_animationController.value - 0.5)
                      : 0;
                  return Transform.rotate(
                    angle: angle,
                    child: child,
                  );
                },
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: tableColor,
                    borderRadius: BorderRadius.circular(
                        30), // Hier werden die Ecken abgerundet
                  ),
                  child: Text(
                    tableName,
                    style: TextStyle(
                      color: (tableColor == Colors.blue ||
                              tableColor == Colors.red ||
                              tableColor == Colors.red.shade300)
                          ? Colors.white
                          : Colors.black,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.black),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu, color: Colors.black),
            label: 'Gerichte hinzufügen',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list, color: Colors.black),
            label: 'Gerichtsliste',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings, color: Colors.black),
            label: 'Einstellungen',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history, color: Colors.black),
            label: 'Log',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.black,
        onTap: _onNavigationBarTapped,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isDeleteMode ? _deleteSelectedTables : _addTable,
        backgroundColor: _isDeleteMode
            ? Colors.red
            : const Color.fromARGB(255, 133, 197, 135),
        tooltip:
            _isDeleteMode ? 'Ausgewählte Tische löschen' : 'Tisch hinzufügen',
        child: Icon(_isDeleteMode ? Icons.delete : Icons.add, color: Colors.black,),
      ),
    );
  }
}
