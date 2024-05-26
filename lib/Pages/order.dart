import 'dart:io';
import 'package:cosmetics_project/Pages/Checkout.dart';
import 'package:cosmetics_project/Pages/FavItems.dart';
import 'package:cosmetics_project/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Order extends StatefulWidget {
  const Order({
    Key? key,
    required this.title,
    required this.username,
  });
  final String username;
  final String title;
  @override
  State<Order> createState() => CartState();
}

class CartState extends State<Order> {
  List<Map<String, dynamic>> CartData = [];
  List<String> CartProductIds = [];
  List<Map<String, dynamic>> productData = [];

  String experience = '';
  int rating = 1;

  void initState() {
    super.initState();
    fetchCartItems(); // Fetch posts when the page is initialized
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
        print(productData);

        setState(() {});
      } else {
        print('Failed to fetch Product: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching Product: $error');
    }
  }

  Future<void> fetchCartItems() async {
    try {
      final User? user = Auth().currentUser;
      if (user == null) {
        // Handle the case where the user is not authenticated
        return;
      }

      final response = await http.get(
        Uri.parse(
          'https://mobileproject12-d6fad-default-rtdb.firebaseio.com/Orders.json',
        ),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic>? ordersData = json.decode(response.body);

        if (ordersData != null) {
          for (String orderId in ordersData.keys) {
            final orderInfo = ordersData[orderId];

            if (orderInfo['email'] == user.email) {
              // Extract order details
              final address = orderInfo['address'];
              final paymentMethod = orderInfo['paymentMethod'];
              print(address);
              // Fetch products associated with this order
              final Map<String, dynamic>? products = orderInfo['Products'];
              if (products != null) {
                for (String productId in products.keys) {
                  final productResponse = await http.get(Uri.parse(
                    'https://mobileproject12-d6fad-default-rtdb.firebaseio.com/Products/$productId.json',
                  ));

                  if (productResponse.statusCode == 200) {
                    final Map<String, dynamic>? productJson =
                        json.decode(productResponse.body);

                    if (productJson != null) {
                      final Map<String, dynamic> product = {
                        'id': productId,
                        'ProductImage': productJson['ProductImage'],
                        'ProductName': productJson['ProductName'],
                        'ProductPrice': productJson['ProductPrice'],
                        'ProductVendor': productJson['ProductVendor'],
                        'ProductRating': productJson['ProductRating'],
                        'ProductDescription': productJson['ProductDescription'],
                        'ProductCategory': productJson['ProductCategory'],
                        'quantity': products[productId]['quantity'],
                        'address': address,
                        'paymentMethod': paymentMethod,
                      };

                      setState(() {
                        CartData.add(product);
                        print(CartData);
                      });
                    }
                  } else {
                    print(
                      'Failed to fetch product with ID $productId: ${productResponse.statusCode}',
                    );
                  }
                }
              }
            }
          }
        } else {
          print('No orders found for the user.');
        }
      } else {
        print('Failed to fetch cart data: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching cart data: $error');
    }
  }

  void toggleCart(String productId, String userEmail) async {
    try {
      final response = await http.get(Uri.parse(
          'https://mobileproject12-d6fad-default-rtdb.firebaseio.com/Cart.json'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> CartData = json.decode(response.body);

        String userKey = '';
        Map<String, dynamic>? userCartItems;

        CartData.forEach((key, value) {
          if (value['email'] == userEmail) {
            userKey = key;
            userCartItems = value['Products'];
          }
        });

        if (userKey.isNotEmpty) {
          if (userCartItems != null && userCartItems!.containsKey(productId)) {
            userCartItems!.remove(productId);
          } else {
            userCartItems ??= {};
            userCartItems![productId] = {'id': productId};
          }
          final updateResponse = await http.patch(
            Uri.parse(
                'https://mobileproject12-d6fad-default-rtdb.firebaseio.com/Cart/$userKey.json'),
            body: json.encode({
              'Products': userCartItems,
            }),
          );

          if (updateResponse.statusCode == 200) {
            print('Cart items updated successfully');
            fetchCartItems();
          } else {
            print(
                'Failed to update favorite items: ${updateResponse.statusCode}');
          }
        } else {
          print('User not found');
        }
      } else {
        print('Failed to fetch cart items: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching cart items: $error');
    }
  }

  double calculateTotalPrice() {
    double totalPrice = 0;
    for (var product in CartData) {
      totalPrice += (product['ProductPrice'] * product['quantity']).toInt();
    }
    return totalPrice;
  }

  void checkout() async {
    try {
      final User? user = Auth().currentUser;
      if (user == null) {
        // Handle the case where the user is not authenticated
        return;
      }

      // Collect product IDs and quantities
      final List<Map<String, dynamic>> checkoutData = [];
      for (var product in CartData) {
        final productId = product['id']; // Use 'id' instead of 'productId'
        final quantity = product['quantity'];
        final Map<String, dynamic> item = {
          'id': productId,
          'quantity': quantity,
        };
        checkoutData.add(item);
      }

      // Send checkout data to the endpoint
      final response = await http.post(
        Uri.parse(
            'https://mobileproject12-d6fad-default-rtdb.firebaseio.com/Checkout.json'),
        body: json.encode({
          'email': user.email,
          'products': checkoutData,
        }),
      );

      if (response.statusCode == 200) {
        print('Checkout successful.');
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Checkout(
                    title: 'Chekout Page',
                    username:
                        user.email!, // Pass the post['name'] as an attribute
                  )),
        );
        // You can add additional logic here if needed, such as navigation to a confirmation screen.
      } else {
        print('Failed to checkout: ${response.statusCode}');
      }
    } catch (error) {
      print('Error during checkout: $error');
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: CartData.length,
              itemBuilder: (context, index) {
                final productId = CartData[index]; // Get the product ID
                final product =
                    CartData[index]; // Find the product data for the current ID

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    side: BorderSide(
                      color: Color(0xFFEDE8E8),
                      width: 1,
                    ),
                  ),
                  elevation: 2,
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Padding(
                    padding: EdgeInsets.all(11),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (product['ProductImage'] != null &&
                            product['ProductImage'] != '')
                          Container(
                            height: 100,
                            child: Image.memory(
                              base64Decode(product['ProductImage']),
                              fit: BoxFit.contain,
                            ),
                          ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${product['ProductName']}',
                                style: TextStyle(fontSize: 14),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Price: ${product['ProductPrice']} EGP',
                                style: TextStyle(fontSize: 14),
                              ),
                              SizedBox(height: 9),
                              Text(
                                'Quantity: ${product['quantity']} ',
                                style: TextStyle(fontSize: 14),
                              ),
                              SizedBox(height: 9),
                              Text(
                                'Address: ${product['address']} ',
                                style: TextStyle(fontSize: 14),
                              ),
                              SizedBox(height: 9),
                              Text(
                                'Payment Method: ${product['paymentMethod']} ',
                                style: TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'TOTAL : ${calculateTotalPrice()} EGP',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton(onPressed: checkout, child: Text('Checkout')),
          SizedBox(height: 16),
        ],
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
              icon: Icon(Icons.shopping_cart),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Order(
                      title: 'Your Cart ',
                      username: user!.email!,
                    ),
                  ),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.list),
              onPressed: () {
                // Handle orders icon press
              },
            ),
            SizedBox(width: 40.0),
            IconButton(
              icon: Icon(Icons.favorite),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FavItems(
                      title: 'Your Wishlist ',
                      username: user!.email!,
                    ),
                  ),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.person),
              onPressed: () {
                // Handle user profile icon press
              },
            ),
          ],
        ),
      ),
    );
  }
}
