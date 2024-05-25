import 'dart:convert';
import 'package:cosmetics_project/Pages/Cart.dart';
import 'package:cosmetics_project/Pages/Comments.dart';
import 'package:cosmetics_project/Pages/FavItems.dart';
import 'package:cosmetics_project/Pages/GuestProductPage.dart';
import 'package:cosmetics_project/Pages/Login.dart';
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

class GuestHomePage extends StatefulWidget {
  GuestHomePage({Key? key, required this.title}) : super(key: key);

  final String title;
  @override
  State<GuestHomePage> createState() => GuestHomePageState();
}

class GuestHomePageState extends State<GuestHomePage> {
  List<Map<String, dynamic>> ProductsData = [];
  List<Map<String, dynamic>> allusersData = [];
  List<Map<String, dynamic>> usersData = [];
  List<String> favoriteProductIds = [];
  List<String> CartProductIds = [];
  void initState() {
    super.initState();
    fetchProducts(); // Fetch posts when the page is initialized
  }

  Future<void> fetchProducts() async {
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

        // Clear existing post data
        ProductsData.clear();

        jsonData.forEach((key, value) {
          final Map<String, dynamic> post = {
            'id': key,
            'ProductImage': value['ProductImage'],
            'ProductName': value['ProductName'],
            'ProductPrice': value['ProductPrice'],
            'ProductVendor': value['ProductVendor'],
            'ProductRating': value['ProductRating'],
            'ProductDescription': value['ProductDescription'],
            'ProductCategory': value['ProductCategory'],
          };

          ProductsData.add(post);
        });

        // var responseData = json.decode(response.body);
        // var username = responseData['name'];

        setState(() {});
      } else {
        print('Failed to fetch products: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching products: $error');
    }
  }

  //

  //

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
              'ProductDescription': value['ProductDescription'],
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

  void sortPostsByTimeStamp() {
    setState(() {
      ProductsData.sort((b, a) {
        final aTimestamp = a['timestamp'];
        print(aTimestamp);
        final bTimestamp = b['timestamp'];

        if (aTimestamp == null && bTimestamp == null) {
          print('object');
          return 0;
        } else if (aTimestamp == null) {
          print('object1');
          return 1; // Treat null as greater than non-null values
        } else if (bTimestamp == null) {
          print('object2');
          return -1; // Treat null as greater than non-null values
        }

        return aTimestamp.compareTo(bTimestamp);
      });
    });
  }

  String searchText = '';
  bool isSearchFocused = false;

  List<Map<String, dynamic>> buttonData = [
    {
      'name': 'FRAGRANCES',
      'icon': Icons.spa,
      'onPressed': () {
        print('Lip button clicked');
      },
    },
    {
      'name': 'HAIR CARE',
      'icon': Icons.spa,
      'onPressed': () {
        print('Body Splash button clicked');
      },
    },
    {
      'name': 'Skin Care',
      'icon': Icons.spa,
      'onPressed': () {
        print('Skin Care button clicked');
      },
    },
    {
      'name': 'Eye Products',
      'icon': Icons.restaurant,
      'onPressed': () {
        print('Restaurant button clicked');
      },
    },
    {
      'name': 'Perfume',
      'icon': Icons.beach_access,
      'onPressed': () {
        //  navigatetobeach();
        print('Perfume button clicked');
      },
    },
  ];
  List<Map<String, dynamic>> SortData = [
    {
      'name': 'Time(Latest)',
      'icon': Icons.access_time,
      'onPressed': () {
        print('Time button clicked');
      },
    },
    {
      'name': 'Alphabetical(A -> Z)',
      'icon': Icons.sort_by_alpha,
      'onPressed': () {
        //  navigatetobeach();
        print('Alphabet button clicked');
      },
    },
    {
      'name': 'Rating(5 -> 1)',
      'icon': Icons.star,
      'onPressed': () {
        //  navigatetobeach();
        print('Rating button clicked');
      },
    }
  ];

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
                  backgroundColor: Color(0xFFEDE8E8),
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
                      SizedBox(height: 6),
                      Expanded(
                        child: ProductsData.isEmpty
                            ? CircularProgressIndicator() // Display a loading spinner when there are no posts
                            : ListView.builder(
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(height: 16),
                                          Container(
                                            height: 270,
                                            width: double.infinity,
                                            child: Stack(
                                              children: [
                                                Image.memory(
                                                  base64Decode(
                                                      post['ProductImage']),
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
                                                    builder: (context) =>
                                                        GuestProducts(
                                                          title: 'Product Page',
                                                          postName: post['id'],
                                                          username: user
                                                              .email!, // Pass the post['name'] as an attribute
                                                        )),
                                              );
                                              print(
                                                  'view product button clicked');
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
                    // Handle FAB press
                  },
                  child: Icon(Icons.category),
                  backgroundColor: Color(0xFFEDE8E8),
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
                        icon: Icon(Icons.list),
                        onPressed: () {
                          // Handle orders icon press
                        },
                      ),
                      SizedBox(width: 40.0), // Space for the FAB

                      IconButton(
                        icon: Icon(Icons.person),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginScreen()),
                          );
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
