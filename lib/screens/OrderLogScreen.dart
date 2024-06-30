import 'package:flutter/material.dart';
import 'package:order_app/screens/adddishscreen.dart';
import 'package:order_app/screens/dishlistscreen.dart';
import 'package:order_app/screens/home_screen.dart';
import 'package:order_app/screens/settings_screen.dart';
import 'package:provider/provider.dart';
import 'package:order_app/providers/dish_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart'; // Für die Datum-Formatierung

class OrderLogScreen extends StatefulWidget {
  @override
  _OrderLogScreenState createState() => _OrderLogScreenState();
}

class _OrderLogScreenState extends State<OrderLogScreen> {
  int _selectedIndex = 4; // Der Index für den Log-Screen

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
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => SettingsScreen()),
        (route) => false,
      );
    } else if (index == 4) {
      // Bleibe auf dem LogScreen
    }
  }

  void _deleteAllLogs() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Color.fromARGB(255, 255, 248, 181),
          title: Text("Löschen bestätigen"),
          content: Text("Möchten Sie wirklich alle Bestellungslogs löschen?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: TextButton.styleFrom(
                foregroundColor: Colors.black, // Textfarbe
              ),
              child: Text("Abbrechen"),
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
              onPressed: () => Navigator.of(context).pop(true),
              child: Text("Löschen"),
            ),
          ],
        );
      },
    );

    if (confirmed ?? false) {
      final dishProvider = Provider.of<DishProvider>(context, listen: false);
      dishProvider.ordersLog.clear();
      dishProvider.notifyListeners();
    }
  }

  void _exportLogAsPDF(String date, List<String> orders) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              children: [
                pw.Text('Bestellungslog für $date',
                    style: pw.TextStyle(fontSize: 24)),
                pw.SizedBox(height: 16),
                ...orders.map((orderDetails) {
                  return pw.Text(orderDetails,
                      style: pw.TextStyle(fontSize: 16));
                }).toList(),
              ],
            ),
          );
        },
      ),
    );

    // Save and open the PDF document using the 'printing' package.
    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save());
  }

  String _formatDate(String date) {
    // Konvertiere das Datum in TT.MM.JJJJ
    final parsedDate =
        DateTime.parse(date); // Ändere hier das Format, falls nötig
    final formattedDate = DateFormat('dd.MM.yyyy').format(parsedDate);
    return formattedDate;
  }

  @override
  Widget build(BuildContext context) {
    final dishProvider = Provider.of<DishProvider>(context);
    final ordersLog = dishProvider.ordersLog;

    Map<String, List<String>> categorizedOrders = {};

    ordersLog.forEach((order) {
      String date = order['date']!;
      String orderDetails = order['details']!;

      if (!categorizedOrders.containsKey(date)) {
        categorizedOrders[date] = [];
      }
      categorizedOrders[date]!.add(orderDetails);
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Bestellungslog'),
      ),
      body: ordersLog.isEmpty
          ? Center(child: Text('Noch keine Bestellungen vorhanden.'))
          : ListView(
              children: categorizedOrders.keys.map((date) {
                final orders = categorizedOrders[date]!;
                final formattedDate = _formatDate(date); // Formatiere das Datum
                return Container(
                  color: Colors.transparent,
                  child: ExpansionTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(formattedDate), // Zeige das formatierte Datum an
                        IconButton(
                          icon: Icon(Icons.picture_as_pdf, color: Colors.red),
                          onPressed: () => _exportLogAsPDF(date, orders),
                        ),
                      ],
                    ),
                    children: orders.map((orderDetails) {
                      return ListTile(
                        title: Text(orderDetails),
                      );
                    }).toList(),
                  ),
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
            label: 'Bestellungslog',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.black,
        onTap: _onNavigationBarTapped,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        onPressed: _deleteAllLogs,
        child: Icon(Icons.delete, color: Colors.black),
      ),
    );
  }
}
