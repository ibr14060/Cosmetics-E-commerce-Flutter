import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FetchTab extends StatefulWidget {
  const FetchTab({Key? key}) : super(key: key);

  @override
  _FetchTabState createState() => _FetchTabState();
}

class _FetchTabState extends State<FetchTab> {
  late List<Map<String, dynamic>> products;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    final String databaseUrl =
        'https://mobile-project-5498f-default-rtdb.firebaseio.com/products.json';

    try {
      final response = await http.get(Uri.parse(databaseUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic>? data = json.decode(response.body);
        if (data != null) {
          List<Map<String, dynamic>> tempProducts = [];
          data.forEach((key, value) {
            tempProducts.add(value);
          });
          setState(() {
            products = tempProducts;
          });
        }
      } else {
        // Handle error
        print('Error fetching products: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching products: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return ListTile(
          title: Text(product['productName']),
          subtitle: Text(product['productDescription']),
          // Add more details or customize ListTile as needed
        );
      },
    );
  }
}
