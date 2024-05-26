import 'dart:convert';
import 'package:cosmetics_project/Pages/Category.dart';
import 'package:cosmetics_project/Pages/Comments.dart';
import 'package:cosmetics_project/Pages/ProductPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cosmetics_project/auth.dart';
import 'package:http/http.dart' as http;
import 'package:cupertino_icons/cupertino_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:line_icons/line_icons.dart';

class Vendor extends StatefulWidget {
  Vendor({Key? key, required this.title, required this.username})
      : super(key: key);

  final String title;
  final String username;
  @override
  State<Vendor> createState() => HomePageState();
}

class HomePageState extends State<Vendor> {
  List<Map<String, dynamic>> ProductsData = [];
  List<Map<String, dynamic>> allusersData = [];
  List<Map<String, dynamic>> usersData = [];
  final User? currentUser = FirebaseAuth.instance.currentUser;

  void initState() {
    super.initState();

    fetchProductsByCurrentUserVendor();
  }

  Future<void> fetchProductsByCurrentUserVendor() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        // Handle the case where the user is not authenticated
        return;
      }

      final userData = await fetchUserData();
      if (userData != null) {
        String? userVendorName;
        userData.forEach((key, value) {
          if (value['email'] == currentUser.email) {
            userVendorName = value['vendorname'];
          }
        });

        if (userVendorName != null) {
          await fetchProducts(userVendorName!);
        } else {
          print('User data not found or vendor name missing');
        }
      } else {
        print('User data not found');
      }
    } catch (error) {
      print('Error fetching products by current user vendor: $error');
    }
  }

  Future<Map<String, dynamic>?> fetchUserData() async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://mobileproject12-d6fad-default-rtdb.firebaseio.com/Users.json'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> userData = json.decode(response.body);
        print(userData);
        return userData;
      } else {
        print('Failed to fetch user data: ${response.statusCode}');
        return null;
      }
    } catch (error) {
      print('Error fetching user data: $error');
      return null;
    }
  }

  Future<void> fetchProducts(String vendorName) async {
    try {
      final User? user = Auth().currentUser;
      if (user == null) {
        // Handle the case where the user is not authenticated
        return;
      }

      final token = await user.getIdToken();
      print("token" + token!);
      final response = await http.get(Uri.parse(
          'https://mobileproject12-d6fad-default-rtdb.firebaseio.com/Products.json'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        // Clear existing product data
        ProductsData.clear();

        jsonData.forEach((key, value) {
          if (value['ProductVendor'] == vendorName) {
            // Check if the product vendor matches the current user's vendor name
            final Map<String, dynamic> post = {
              'id': key,
              'ProductImage': value['ProductImage'],
              'ProductName': value['ProductName'],
              'ProductPrice': value['ProductPrice'],
              'ProductVendor': value['ProductVendor'],
              'ProductRating': value['ProductRating'],
            };

            ProductsData.add(post);
            print(ProductsData);
          }
        });

        // Update the UI after fetching filtered products
        setState(() {});
      } else {
        print('Failed to fetch products: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching products: $error');
    }
  }

  Future<void> fetchPostsofsearch(String name) async {
    try {
      final User? user = Auth().currentUser;
      if (user == null) {
        return;
      }

      final token = await user.getIdToken();
      print("fffffff" + token!);
      final response = await http.get(
        Uri.parse(
            'https://mobileproject12-d6fad-default-rtdb.firebaseio.com/Products.json'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        ProductsData.clear();

        jsonData.forEach((key, value) {
          final String name_to_search_with = value['name'];
          if (name == name_to_search_with) {
            final Map<String, dynamic> post = {
              'id': key,
              'ProductImage': value['ProductImage'],
              'ProductName': value['ProductName'],
              'ProductPrice': value['ProductPrice'],
              'ProductVendor': value['ProductVendor'],
              'ProductRating': value['ProductRating'],
              'ProductCategory': value['ProductCategory'],
            };

            ProductsData.add(post);
            print("ProductsData" + ProductsData.toString());
          }
        });

        setState(() {});
      } else {
        print('Failed to fetch posts: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching posts: $error');
    }
  }

  bool isLiked = false;
  void toggleLike(String productId, String userEmail) async {
    try {
      final response = await http.get(Uri.parse(
          'https://mobileproject12-d6fad-default-rtdb.firebaseio.com/FavItems.json'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> favData = json.decode(response.body);

        String userKey = '';
        Map<String, dynamic>? userFavItems;

        favData.forEach((key, value) {
          if (value['email'] == userEmail) {
            userKey = key;
            userFavItems = value['Products'];
          }
        });

        if (userKey.isNotEmpty) {
          if (userFavItems != null && userFavItems!.containsKey(productId)) {
            userFavItems!.remove(productId);
          } else {
            userFavItems ??= {};
            userFavItems![productId] = {'id': productId};
          }
          final updateResponse = await http.patch(
            Uri.parse(
                'https://mobileproject12-d6fad-default-rtdb.firebaseio.com/FavItems/$userKey.json'),
            body: json.encode({
              'Products': userFavItems,
            }),
          );

          if (updateResponse.statusCode == 200) {
            print('Favorite items updated successfully');
          } else {
            print(
                'Failed to update favorite items: ${updateResponse.statusCode}');
          }
        } else {
          print('User not found');
        }
      } else {
        print('Failed to fetch favorite items: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching favorite items: $error');
    }

    setState(() {
      isLiked = !isLiked;
    });
  }

  void sortPostsByName() {
    setState(() {
      ProductsData.sort((a, b) => a['name'].compareTo(b['name']));
    });
  }

  void sortPostsByRating() {
    setState(() {
      ProductsData.sort((b, a) => a['rating'].compareTo(b['rating']));
    });
  }

  String searchText = '';
  bool isSearchFocused = false;
  List<Map<String, dynamic>> buttonData = [
    {
      'name': 'FRAGRANCES',
      'icon': Icons.spa,
      'category': 'FRAGRANCES',
    },
    {
      'name': 'HAIR CARE',
      'icon': Icons.spa,
      'category': 'HAIR CARE',
    },
    {
      'name': 'Skin Care',
      'icon': Icons.spa,
      'category': 'Skin Care',
    },
    {
      'name': 'Makeup',
      'icon': Icons.restaurant,
      'category': 'Makeup',
    },
  ];

  void navigateToCategoryPage(String category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryPage(
          title: category,
          username: widget.username,
          category: category,
        ),
      ),
    );
  }

  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: Future<User?>.value(Auth().currentUser),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Loading...'),
            ),
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else {
          if (snapshot.hasError || snapshot.data == null) {
            return Scaffold(
              appBar: AppBar(
                title: Text('Error'),
              ),
              body: Center(
                child: Text('Error: User not found'),
              ),
            );
          } else {
            final User user = snapshot.data!;
            return Scaffold(
                appBar: AppBar(
                  actions: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          isSearchFocused = true;
                        });
                      },
                      icon: const Icon(Icons.search),
                    ),
                  ],
                  backgroundColor: Colors.blue,
                  title: isSearchFocused
                      ? TextField(
                          onChanged: (value) {
                            setState(() {
                              searchText = value;
                            });
                          },
                          onSubmitted: (value) {
                            fetchPostsofsearch(value);
                          },
                          decoration: InputDecoration(
                            hintText: 'Search',
                            border: InputBorder.none,
                          ),
                        )
                      : Text(widget.title),
                ),
                body: Container(
                  color: Color(0xFFFFCCC1),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 120,
                        child: Column(
                          children: [
                            Container(
                              color: Colors.grey[200], // Background color
                              padding: EdgeInsets.all(16.0),
                              child: Center(
                                child: Text(
                                  'Glam & Beauty', // Your title text
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                color: Colors.grey[200], // Background color
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: buttonData.length,
                                  itemBuilder: (context, index) {
                                    final button = buttonData[index];
                                    final isLastButton =
                                        index == buttonData.length - 1;
                                    return Container(
                                      margin: EdgeInsets.only(
                                          top: 8.0,
                                          bottom: 8.0,
                                          left: 8.0,
                                          right: isLastButton ? 8.0 : 0.0),
                                      color: isLastButton
                                          ? Colors.grey[200]
                                          : null, // Space between buttons
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          button['onPressed']();
                                        },
                                        icon: Icon(button['icon']),
                                        label: Text(button['name']),
                                        style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(11.0),
                                          ),
                                          backgroundColor: Colors.grey[200],
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 8.0,
                                              vertical:
                                                  4.0), // Adjust the padding // Button background color
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        ' ',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 6),
                      Expanded(
                        child: ListView.builder(
                          itemCount: ProductsData.length,
                          itemBuilder: (context, index) {
                            final post = ProductsData[index];
                            //     final useer = usersData[ProductsData.length];

                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                side: BorderSide(
                                  color: Color(
                                      0xFFEDE8E8), // Setting background color
                                  width: 1.0,
                                ),
                              ),
                              elevation: 2,
                              margin: EdgeInsets.only(
                                  top: 8.0,
                                  left: 16.0,
                                  right: 16.0,
                                  bottom: 40.0), // Adjusted margin
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 16),
                                    Container(
                                      height: 270,
                                      width: double.infinity,
                                      child: Stack(
                                        children: [
                                          Image.memory(
                                            base64Decode(post['ProductImage']),
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: double.infinity,
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                    const SizedBox(width: 8.0),
                                    Center(
                                      // Wrapping product name in Center widget
                                      child: Text(
                                        post['ProductVendor'],
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                    Center(
                                      // Wrapping product name in Center widget
                                      child: Text(
                                        post['ProductName'],
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Center(
                                      child: Text(
                                        '${post['ProductPrice']} LE',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Center(
                                      child: Text(
                                        '${post['ProductCategory']}',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                    ),
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        print(post['id']);

                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => Products(
                                                    title: 'Product Page',
                                                    postName: post['id'],
                                                    username: user
                                                        .email!, // Pass the post['name'] as an attribute
                                                  )),
                                        );
                                        print('view product button clicked');
                                      },
                                      icon: Icon(Icons.navigate_next),
                                      label: Text('View Product'),
                                      style: ElevatedButton.styleFrom(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 8.0,
                                        ),
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
                ),
                floatingActionButton: FloatingActionButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/postpage');
                  },
                  child: Icon(Icons.add),
                ),
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.centerDocked,
                bottomNavigationBar: BottomAppBar(
                  shape: CircularNotchedRectangle(),
                  notchMargin: 6.0,
                  color: Color(0xFFEDE8E8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          // Handle cart icon press
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.list),
                        onPressed: () {
                          // Handle orders icon press
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
                ));
          }
        }
      },
    );
  }
}
