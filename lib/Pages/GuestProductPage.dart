import 'dart:io';
import 'package:cosmetics_project/Pages/Cart.dart';
import 'package:cosmetics_project/Pages/Login.dart';
import 'package:cosmetics_project/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'FavItems.dart';

class GuestProducts extends StatefulWidget {
  const GuestProducts({
    Key? key,
    required this.title,
    required this.postName,
    required this.username,
  }) : super(key: key);

  final String username;
  final String title;
  final String postName;

  @override
  State<GuestProducts> createState() => ProductsState();
}

class ProductsState extends State<GuestProducts> {
  List<Map<String, dynamic>> productData = [];
  String experience = '';
  File? _image;
  int rating = 1;

  @override
  void initState() {
    super.initState();
    fetchProductById(widget.postName);
  }

  Future<void> fetchProductById(String productId) async {
    try {
      final response = await http.get(Uri.parse(
          'https://mobileproject12-d6fad-default-rtdb.firebaseio.com/Products/$productId.json'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        productData.clear();

        final Map<String, dynamic> product = {
          'id': productId,
          'ProductImage': jsonData['ProductImage'],
          'ProductName': jsonData['ProductName'],
          'ProductPrice': jsonData['ProductPrice'],
          'ProductVendor': jsonData['ProductVendor'],
          'ProductRating': jsonData['ProductRating'],
          'ProductDescription': jsonData['ProductDescription'],
          'ProductCategory': jsonData['ProductCategory'],
        };

        productData.add(product);

        setState(() {});
      } else {
        print('Failed to fetch Product: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching Product: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = Auth().currentUser; // Define user here

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFEDE8E8),
        title: Text(widget.title),
      ),
      backgroundColor: Color(0xFFFFCCC1), // Set background color here
      body: productData.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: productData.length,
              itemBuilder: (context, index) {
                final product = productData[index];

                return Container(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (product['ProductImage'] != null)
                          Image.memory(
                            base64Decode(product['ProductImage']),
                            fit: BoxFit.cover,
                          ),
                        SizedBox(height: 16),
                        Text(
                          product['ProductName'] ?? '',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Price: ${product['ProductPrice']} EGP',
                          style:
                              TextStyle(fontSize: 18, color: Colors.grey[700]),
                        ),
                        SizedBox(height: 8),
                        Text(
                          product['ProductDescription'] ?? '',
                          style:
                              TextStyle(fontSize: 16, color: Colors.grey[600]),
                        ),
                        SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              color: Color.fromARGB(255, 218, 200, 46),
                              size: 22,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Rating: ${product['ProductRating']} out of 5',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Handle FAB press
        },
        child: Icon(Icons.category),
        backgroundColor: Color(0xFFEDE8E8),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 6.0,
        color: Color(0xFFEDE8E8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(Icons.list),
              onPressed: () {
                // Handle orders icon press
              },
            ),
            SizedBox(width: 40.0),
            IconButton(
              icon: Icon(Icons.person),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
                // Handle user profile icon press
              },
            ),
          ],
        ),
      ),
    );
  }
}
