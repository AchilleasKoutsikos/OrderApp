import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:order_app/providers/dish_provider.dart';
import 'package:order_app/screens/home_screen.dart';
import 'package:order_app/screens/adddishscreen.dart';
import 'package:order_app/screens/dishlistscreen.dart';
import 'package:order_app/screens/OrderLogScreen.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  String _newCategory = '';
  int _selectedIndex = 3; // index 3 because this screen is "Einstellungen"

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
      // Bleibe auf dem SettingsScreen
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
        title: Text('Einstellungen'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Neue Kategorie',
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors
                            .black, // Farbe des Unterstrichs beim Fokussieren
                        width: 1.0,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Bitte Kategorie eingeben';
                    }
                    _newCategory = value;
                    return null;
                  },
                ),
                SizedBox(height: 30),
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
                      dishProvider.addCategory(_newCategory);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Kategorie hinzugefügt!')),
                      );
                      _newCategory = '';
                      _formKey.currentState!.reset();
                    }
                  },
                  child: Text('Hinzufügen'),
                ),
                SizedBox(height: 20),
                Text(
                  'Verfügbare Kategorien:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                ...dishProvider.categories.map((category) => ListTile(
                      title: Text(category),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.black),
                        onPressed: () {
                          // Dialog zur Bestätigung des Löschens anzeigen
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                backgroundColor:
                                    Color.fromARGB(255, 255, 248, 181),
                                title: Text('Kategorie löschen'),
                                content: Text(
                                    'Möchten Sie die Kategorie "$category" wirklich löschen?'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    style: TextButton.styleFrom(
                                      foregroundColor:
                                          Colors.black, // Textfarbe
                                    ),
                                    child: Text('Abbrechen'),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      backgroundColor: Colors.black,
                                      shadowColor:
                                          Colors.black, // Schattenfarbe
                                      elevation: 10, // Erhebung
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            15.0), // Abgerundete Ecken
                                      ),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 30,
                                          vertical: 15), // Innenabstand
                                    ),
                                    onPressed: () {
                                      dishProvider.deleteCategory(category);
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('Löschen'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    )),
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
