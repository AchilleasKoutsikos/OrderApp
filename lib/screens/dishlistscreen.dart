import 'package:flutter/material.dart';
import 'package:order_app/providers/dish_provider.dart';
import 'package:provider/provider.dart';
import 'package:order_app/screens/home_screen.dart';
import 'package:order_app/screens/adddishscreen.dart';
import 'package:order_app/screens/settings_screen.dart';
import 'package:order_app/screens/OrderLogScreen.dart';

class DishListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final dishProvider = Provider.of<DishProvider>(context);
    int _selectedIndex = 2; // index 2 because this screen is "Gerichtsliste"

    void _onNavigationBarTapped(int index) {
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
        // Bleibe auf dem DishListScreen
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

    void _editDishDialog(int index) {
      final _nameController =
          TextEditingController(text: dishProvider.dishes[index].name);
      final _priceController = TextEditingController(
          text: dishProvider.dishes[index].price.toString());
      String _selectedCategory = dishProvider.dishes[index].category;

      showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                backgroundColor: const Color.fromARGB(255, 255, 248, 181),
                title: Text('Gericht bearbeiten'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors
                                .black, // Farbe des Unterstrichs beim Fokussieren
                            width: 2.0,
                          ),
                        ),
                      ),
                    ),
                    TextField(
                      controller: _priceController,
                      decoration: InputDecoration(
                        labelText: 'Preis',
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors
                                .black, // Farbe des Unterstrichs beim Fokussieren
                            width: 2.0,
                          ),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    DropdownButton<String>(
                      value: _selectedCategory,
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
                  ],
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
                      dishProvider.updateDish(
                        index,
                        _nameController.text,
                        _selectedCategory,
                        double.parse(_priceController.text),
                      );
                      Navigator.of(context).pop();
                    },
                    child: Text('Speichern'),
                  ),
                ],
              );
            },
          );
        },
      );
    }

    // Gerichte nach Kategorie und alphabetisch sortieren
    final categories = dishProvider.categories;
    final categoryToDishes = {for (var category in categories) category: []};
    for (var dish in dishProvider.dishes) {
      categoryToDishes[dish.category]?.add(dish);
    }
    for (var category in categoryToDishes.keys) {
      categoryToDishes[category]?.sort((a, b) => a.name.compareTo(b.name));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Gerichte Liste'),
      ),
      body: ListView(
        children: categories.map((category) {
          final dishes = categoryToDishes[category] ?? [];
          return ExpansionTile(
            title: Text(category),
            children: dishes.map((dish) {
              int index = dishProvider.dishes.indexOf(dish);
              return ListTile(
                title: Text(dish.name),
                subtitle: Text('${dish.price.toStringAsFixed(2)} €'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        _editDishDialog(index);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        dishProvider.deleteDish(index);
                      },
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        }).toList(),
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
