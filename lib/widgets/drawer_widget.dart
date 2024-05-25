import 'package:cosmetics_project/Pages/addProduct.dart';
import 'package:flutter/material.dart';
import '../main.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.pink[100],
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            Container(
              color: const Color.fromARGB(255, 245, 150, 181),
              child: DrawerHeader(
                margin: EdgeInsets.zero,
                padding: EdgeInsets.zero,
                child: Center(
                  child: Text(
                    'Menu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home, color: Colors.pink[900]),
              title: Text('Home', style: TextStyle(color: Colors.pink[900])),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => MyApp()),
                );
              },
            ),
            ExpansionTile(
              leading: Icon(Icons.arrow_drop_down, color: Colors.pink[900]),
              title:
                  Text('Products', style: TextStyle(color: Colors.pink[900])),
              children: <Widget>[
                ListTile(
                  title: Text('Add Product',
                      style: TextStyle(color: Colors.pink[900])),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AddProductScreen()),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
