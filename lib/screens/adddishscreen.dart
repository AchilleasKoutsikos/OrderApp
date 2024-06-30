import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:order_app/screens/dishlistscreen.dart';
import 'package:order_app/providers/dish_provider.dart';
import 'package:order_app/screens/home_screen.dart';
import 'package:order_app/screens/settings_screen.dart';
import 'package:order_app/screens/OrderLogScreen.dart';

class AddDishScreen extends StatefulWidget {
  @override
  _AddDishScreenState createState() => _AddDishScreenState();
}

class _AddDishScreenState extends State<AddDishScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedCategory = '';
  String _dishName = '';
  double _price = 0.0;
  int _selectedIndex =
      1; // index 1 because this screen is "Gerichte hinzufügen"

  void _onNavigationBarTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
        (route) => false,
      );
    } else if (index == 1) {
      // Bleibe auf dem AddDishScreen
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

  @override
  Widget build(BuildContext context) {
    final dishProvider = Provider.of<DishProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Gericht hinzufügen'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedCategory.isNotEmpty
                      ? _selectedCategory
                      : dishProvider.categories[0],
                  decoration: InputDecoration(
                    labelText: 'Kategorie',
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors
                            .black, // Farbe des Unterstrichs beim Fokussieren
                        width: 1.0,
                      ),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors
                            .black, // Farbe des Unterstrichs im normalen Zustand
                        width: 2.0,
                      ),
                    ),
                  ),
                  items: dishProvider.categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value!;
                    });
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Gericht Name',
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.black, // Farbe des Unterstrichs beim Fokussieren
                        width: 1.0,
                      ),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors
                            .black, // Farbe des Unterstrichs im normalen Zustand
                        width: 2.0,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Bitte Name eingeben';
                    }
                    _dishName = value;
                    return null;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Preis',
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors
                            .black, // Farbe des Unterstrichs beim Fokussieren
                        width: 1.0,
                      ),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors
                            .black, // Farbe des Unterstrichs im normalen Zustand
                        width: 2.0,
                      ),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Bitte Preis eingeben';
                    }
                    try {
                      _price = double.parse(value);
                    } catch (e) {
                      return 'Bitte gültigen Preis eingeben';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 40),
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
                    if (_formKey.currentState!.validate()) {
                      if (_selectedCategory.isEmpty) {
                        _selectedCategory = dishProvider.categories[0];
                      }
                      dishProvider.addDish(
                          _dishName, _selectedCategory, _price);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Gericht hinzugefügt!')),
                      );
                    }
                  },
                  child: Text('Hinzufügen'),
                ),
              ],
            ),
          ),
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
    );
  }
}
