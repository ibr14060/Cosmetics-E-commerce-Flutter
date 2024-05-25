import 'dart:io';
import 'package:cosmetics_project/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Checkout extends StatefulWidget {
  const Checkout({
    Key? key,
    required this.title,
    required this.username,
  });
  final String username;
  final String title;
  @override
  State<Checkout> createState() => FavItemsState();
}

class FavItemsState extends State<Checkout> {
  List<Map<String, dynamic>> CheckoutData = [];
  List<String> CheckoutProductIds = [];
  List<Map<String, dynamic>> productData = [];

  String experience = '';
  int rating = 1;

  void initState() {
    super.initState();
    fetchCheckoutItems(); // Fetch posts when the page is initialized
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
        setState(() {
          CheckoutData.add(product);
          productData.add(product);
        });
        print(productData);
      } else {
        print('Failed to fetch Product: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching Product: $error');
    }
  }

  Future<void> fetchCheckoutItems() async {
    try {
      final User? user = Auth().currentUser;
      if (user == null) {
        // Handle the case where the user is not authenticated
        return;
      }

      final response = await http.get(
        Uri.parse(
          'https://mobileproject12-d6fad-default-rtdb.firebaseio.com/Checkout.json',
        ),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> cartData = json.decode(response.body);

        List<Map<String, dynamic>> checkoutItems = [];

        cartData.forEach((key, value) async {
          if (value['email'] == user.email) {
            final userCartItems = value['products'];
            if (userCartItems != null) {
              for (var cartItem in userCartItems) {
                final String productId = cartItem['id'];
                final int quantity = cartItem['quantity'];
                CheckoutProductIds.add(
                    productId); // Add the product ID to the list (if needed
                final productResponse = await http.get(Uri.parse(
                  'https://mobileproject12-d6fad-default-rtdb.firebaseio.com/Products/$productId.json',
                ));

                if (productResponse.statusCode == 200) {
                  final Map<String, dynamic> productJson =
                      json.decode(productResponse.body);

                  final Map<String, dynamic> product = {
                    'id': productId,
                    'ProductImage': productJson['ProductImage'],
                    'ProductName': productJson['ProductName'],
                    'ProductPrice': productJson['ProductPrice'],
                    'ProductVendor': productJson['ProductVendor'],
                    'ProductRating': productJson['ProductRating'],
                    'ProductDescription': productJson['ProductDescription'],
                    'ProductCategory': productJson['ProductCategory'],
                    'quantity': quantity,
                  };
                  setState(() {
                    // Update state with fetched checkout items
                    CheckoutData.add(product);
                    print(CheckoutData);
                  });
                  checkoutItems.add(product);
                } else {
                  print(
                    'Failed to fetch product with ID $productId: ${productResponse.statusCode}',
                  );
                }
              }
            }
          }
        });
      } else {
        print('Failed to fetch cart data: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching cart data: $error');
    }
  }

  //
  Future<void> sendNotificationToUser() async {
    try {
      final response = await http.get(
          Uri.parse('https://your-firebase-project.firebaseio.com/users.json'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        jsonData.forEach((key, value) async {
          // Replace `postOwnerId` with the ID of the user who posted the FavItemsed post
          if (key == 'postOwnerId') {
            final String fcmToken = value['fcmToken'];

            final message = {
              'notification': {
                'title': 'New FavItems',
                'body': 'Someone FavItemsed on your post.',
              },
              'token': fcmToken,
            };

            final response = await http.post(
              Uri.parse('https://fcm.googleapis.com/fcm/send'),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'key=YOUR_SERVER_KEY',
              },
              body: json.encode(message),
            );

            if (response.statusCode == 200) {
              print('Notification sent successfully.');
            } else {
              print('Failed to send notification: ${response.statusCode}');
            }
          }
        });
      } else {
        print('Failed to fetch users: ${response.statusCode}');
      }
    } catch (error) {
      print('Error sending notification: $error');
    }
  }

  void toggleCheckout(String productId, String userEmail) async {
    try {
      final response = await http.get(Uri.parse(
          'https://mobileproject12-d6fad-default-rtdb.firebaseio.com/Checkout.json'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> FavItemsData = json.decode(response.body);

        String userKey = '';
        Map<String, dynamic>? userFavItemsItems;

        FavItemsData.forEach((key, value) {
          if (value['email'] == userEmail) {
            userKey = key;
            userFavItemsItems = value['Products'];
          }
        });

        if (userKey.isNotEmpty) {
          if (userFavItemsItems != null &&
              userFavItemsItems!.containsKey(productId)) {
            userFavItemsItems!.remove(productId);
          } else {
            userFavItemsItems ??= {};
            userFavItemsItems![productId] = {'id': productId};
          }
          final updateResponse = await http.patch(
            Uri.parse(
                'https://mobileproject12-d6fad-default-rtdb.firebaseio.com/FavItems/$userKey.json'),
            body: json.encode({
              'Products': userFavItemsItems,
            }),
          );

          if (updateResponse.statusCode == 200) {
            print('FavItems items updated successfully');
            fetchCheckoutItems();
          } else {
            print(
                'Failed to update favorite items: ${updateResponse.statusCode}');
          }
        } else {
          print('User not found');
        }
      } else {
        print('Failed to fetch FavItems items: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching FavItems items: $error');
    }
  }

  void toggleFavItems(String productId, String userEmail) async {
    try {
      final response = await http.get(Uri.parse(
          'https://mobileproject12-d6fad-default-rtdb.firebaseio.com/FavItems.json'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> FavItemsData = json.decode(response.body);

        String userKey = '';
        Map<String, dynamic>? userFavItemsItems;

        FavItemsData.forEach((key, value) {
          if (value['email'] == userEmail) {
            userKey = key;
            userFavItemsItems = value['Products'];
          }
        });

        if (userKey.isNotEmpty) {
          if (userFavItemsItems != null &&
              userFavItemsItems!.containsKey(productId)) {
            userFavItemsItems!.remove(productId);
          } else {
            userFavItemsItems ??= {};
            userFavItemsItems![productId] = {'id': productId};
          }
          final updateResponse = await http.patch(
            Uri.parse(
                'https://mobileproject12-d6fad-default-rtdb.firebaseio.com/FavItems/$userKey.json'),
            body: json.encode({
              'Products': userFavItemsItems,
            }),
          );

          if (updateResponse.statusCode == 200) {
            print('FavItems items updated successfully');
            fetchCheckoutItems();
          } else {
            print(
                'Failed to update favorite items: ${updateResponse.statusCode}');
          }
        } else {
          print('User not found');
        }
      } else {
        print('Failed to fetch FavItems items: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching FavItems items: $error');
    }
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
      for (var product in CheckoutData) {
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      backgroundColor: Color(0xFFFFCCC1), // Set background color here
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: CheckoutData.length,
              itemBuilder: (context, index) {
                final productId =
                    CheckoutProductIds[index]; // Get the product ID
                final product = CheckoutData[
                    index]; // Find the product data for the current ID

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
                                'Quantity: ${product['quantity']} EGP',
                                style: TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            toggleFavItems(productId, widget.username);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                          ),
                          child: Icon(
                            Icons.delete,
                            color: Color.fromARGB(255, 134, 5,
                                5), // Adjust the color of the icon as needed
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
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
                // Handle FavItems icon press
              },
            ),
            IconButton(
              icon: Icon(Icons.list),
              onPressed: () {
                // Handle orders icon press
              },
            ),
            SizedBox(width: 40.0), // Space for the FAB
            IconButton(
              icon: Icon(Icons.favorite),
              onPressed: () {
                // Handle favorite icon press
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
