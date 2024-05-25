import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UpdateProductTab extends StatefulWidget {
  final String databaseUrl;

  const UpdateProductTab({Key? key, required this.databaseUrl}) : super(key: key);

  @override
  _UpdateProductTabState createState() => _UpdateProductTabState();
}

class _UpdateProductTabState extends State<UpdateProductTab> {
  List<dynamic> products = [];

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      final response = await http.get(Uri.parse(widget.databaseUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        if (data != null) {
          setState(() {
            products = data.values.toList();
          });
        }
      } else {
        print('Failed to fetch products: ${response.statusCode}');
      }
    } catch (error) {
      print('Failed to fetch products: $error');
    }
  }

  Future<void> updateProduct(int index, Map<String, dynamic> newData) async {
    try {
      final productToUpdate = products[index];

      // Replace the data with the new data provided
      productToUpdate['productName'] = newData['productName'];
      productToUpdate['productDescription'] = newData['productDescription'];
      productToUpdate['productType'] = newData['productType'];
      productToUpdate['price'] = newData['price'];
      productToUpdate['code'] = newData['code'];
      productToUpdate['vendorId'] = newData['vendorId'];

      final response = await http.put(
        Uri.parse('${widget.databaseUrl}/${productToUpdate['id']}.json'), // Assuming each product has an 'id'
        body: json.encode(productToUpdate),
      );

      if (response.statusCode == 200) {
        print('Product updated successfully');
        fetchProducts(); // Fetch products again to reflect the changes
      } else {
        print('Failed to update product: ${response.statusCode}');
      }
    } catch (error) {
      print('Error updating product: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Card(
          margin: EdgeInsets.all(8.0),
          child: Container(
            width: double.infinity,
            alignment: Alignment.center,
            padding: EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  title: Text(product['productName']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Description: ${product['productDescription']}'),
                      Text('Type: ${product['productType']}'),
                      Text('Price: ${product['price']}'),
                      Text('Code: ${product['code']}'),
                      Text('Vendor ID: ${product['vendorId']}'),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        // Example of updating the product with new data
                        updateProduct(index, {
                          'productName': 'New Product Name',
                          'productDescription': 'New Product Description',
                          'productType': 'New Product Type',
                          'price': 99.99,
                          'code': 'New Code',
                          'vendorId': 'New Vendor ID',
                        });
                      },
                      child: Text('Update'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      body: UpdateProductTab(databaseUrl: 'Your_Firebase_Database_URL'),
    ),
  ));
}
