import 'dart:convert';
import 'package:cosmetics_project/Pages/Cart.dart';
import 'package:cosmetics_project/Pages/Category.dart';
import 'package:cosmetics_project/Pages/Comments.dart';
import 'package:cosmetics_project/Pages/FavItems.dart';
import 'package:cosmetics_project/Pages/ProductPage.dart';
import 'package:cosmetics_project/Pages/order.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cosmetics_project/auth.dart';
import 'package:http/http.dart' as http;
import 'package:cupertino_icons/cupertino_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:line_icons/line_icons.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key, required this.title, required this.username})
      : super(key: key);
  final User? user = Auth().currentUser;

  final String title;
  final String username;
  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> ProductsData = [];
  List<Map<String, dynamic>> allusersData = [];
  List<Map<String, dynamic>> usersData = [];
  List<String> favoriteProductIds = [];
  List<String> CartProductIds = [];
  final User? currentUser = FirebaseAuth.instance.currentUser;
  void initState() {
    super.initState();
    fetchProducts(); // Fetch posts when the page is initialized
  }

  void updateProductRating(String productId, double newRating) async {
    try {
      final response = await http.get(Uri.parse(
          'https://mobileproject12-d6fad-default-rtdb.firebaseio.com/Products/$productId.json'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> productData = json.decode(response.body);

        // Extract previous ratings
        double previousRatings = productData['ProductRating'];
        double totalRating = 0.0;

        totalRating += previousRatings.toDouble();

        totalRating += newRating;

        // Calculate new average rating
        double averageRating = totalRating / 2;

        // Update product rating in the database with the new average
        final updateResponse = await http.patch(
          Uri.parse(
              'https://mobileproject12-d6fad-default-rtdb.firebaseio.com/Products/$productId.json'),
          body: json.encode({
            'ProductRating': averageRating,
          }),
        );

        if (updateResponse.statusCode == 200) {
          print('Product rating updated successfully');
        } else {
          print(
              'Failed to update product rating: ${updateResponse.statusCode}');
        }
      } else {
        print('Failed to fetch product data: ${response.statusCode}');
      }
    } catch (error) {
      print('Error updating product rating: $error');
    }
  }

  Future<void> fetchFavoriteItems() async {
    try {
      final User? user = Auth().currentUser;
      if (user == null) {
        // Handle the case where the user is not authenticated
        return;
      }

      final response = await http.get(Uri.parse(
          'https://mobileproject12-d6fad-default-rtdb.firebaseio.com/FavItems.json'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> favData = json.decode(response.body);

        favData.forEach((key, value) {
          if (value['email'] == user.email) {
            final userFavItems = value['Products'];
            if (userFavItems != null) {
              setState(() {
                favoriteProductIds = userFavItems.keys.cast<String>().toList();
              });
              print(favoriteProductIds);
            }
          }
        });
      } else {
        print('Failed to fetch favorite items: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching favorite items: $error');
    }
  }

  Future<void> fetchCartItems() async {
    try {
      final User? user = Auth().currentUser;
      if (user == null) {
        // Handle the case where the user is not authenticated
        return;
      }

      final response = await http.get(Uri.parse(
          'https://mobileproject12-d6fad-default-rtdb.firebaseio.com/Cart.json'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> CartData = json.decode(response.body);

        CartData.forEach((key, value) {
          if (value['email'] == user.email) {
            final userCartItems = value['Products'];
            if (userCartItems != null) {
              setState(() {
                CartProductIds = userCartItems.keys.cast<String>().toList();
              });
              print(CartProductIds);
            }
          }
        });
      } else {
        print('Failed to fetch cart items: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching cart items: $error');
    }
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
      await fetchFavoriteItems(); // Fetch favorite items first
      await fetchCartItems(); // Fetch cart items first
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
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        ProductsData.clear();

        jsonData.forEach((key, value) {
          final String name_to_search_with = value['ProductName'];
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
            fetchFavoriteItems();
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
  }

  bool isinCart = false;
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
            userCartItems![productId] = {'id': productId, 'quantity': 1};
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
  void handleSearch(String query) {
    fetchPostsofsearch(query);
  }

  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: Future<User?>.value(Auth().currentUser),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
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
                      onSubmitted:
                          handleSearch, // Call handleSearch when submitted
                      decoration: InputDecoration(
                        hintText: 'Search',
                        border: InputBorder.none,
                      ),
                    )
                  : Text(widget.title),
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
                                          navigateToCategoryPage(
                                              button['category']);
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
                                  final productId = post['id'];
                                  final isLiked =
                                      favoriteProductIds.contains(productId);

                                  final isinCart =
                                      CartProductIds.contains(productId);

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
                                                Positioned(
                                                  top: 8.0,
                                                  right: 8.0,
                                                  child: IconButton(
                                                    icon: Icon(
                                                      isLiked
                                                          ? Icons.favorite
                                                          : Icons
                                                              .favorite_border,
                                                      color: isLiked
                                                          ? Colors.red
                                                          : null,
                                                    ),
                                                    onPressed: () {
                                                      toggleLike(post['id'],
                                                          user.email!);
                                                    },
                                                  ),
                                                ),
                                                Positioned(
                                                  top: 8.0,
                                                  left: 8.0,
                                                  child: IconButton(
                                                    icon: Icon(
                                                      isinCart
                                                          ? Icons.shopping_cart
                                                          : Icons
                                                              .shopping_cart_checkout_outlined,
                                                      color: isinCart
                                                          ? Colors.teal
                                                          : null,
                                                    ),
                                                    onPressed: () {
                                                      toggleCart(post['id'],
                                                          user.email!);
                                                    },
                                                  ),
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
                                            children: [
                                              RatingBar.builder(
                                                initialRating:
                                                    post['ProductRating']
                                                        .toDouble(),
                                                minRating: 1,
                                                direction: Axis.horizontal,
                                                allowHalfRating: true,
                                                itemCount: 5,
                                                itemSize: 35,
                                                itemPadding:
                                                    EdgeInsets.symmetric(
                                                        horizontal: 2.0),
                                                itemBuilder: (context, _) =>
                                                    Icon(
                                                  Icons.star,
                                                  color: Color(0xFFFFCCC1),
                                                ),
                                                onRatingUpdate: (newRating) {
                                                  updateProductRating(
                                                      post['id'], newRating);
                                                },
                                              ),
                                              SizedBox(width: 8),
                                              ElevatedButton.icon(
                                                onPressed: () {
                                                  print(post['id']);

                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            Comments(
                                                              title:
                                                                  'Comment Page',
                                                              postName:
                                                                  post['id'],
                                                              username: user
                                                                  .email!, // Pass the post['name'] as an attribute
                                                            )),
                                                  );

                                                  // Handle the comment button click
                                                  print(
                                                      'Comment button clicked');
                                                },
                                                icon: Icon(Icons.comment),
                                                label: Text('Comment'),
                                                style: ElevatedButton.styleFrom(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 8.0,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          ElevatedButton.icon(
                                            onPressed: () {
                                              print(post['id']);

                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        Products(
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
                        icon: Icon(Icons.shopping_cart),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Cart(
                                      title: 'Your Cart ',
                                      username: user
                                          .email!, // Pass the post['name'] as an attribute
                                    )),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.book),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Order(
                                      title: 'Your Orders ',
                                      username: user
                                          .email!, // Pass the post['name'] as an attribute
                                    )),
                          );
                        },
                      ),
                      SizedBox(width: 40.0), // Space for the FAB
                      IconButton(
                        icon: Icon(Icons.favorite),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => FavItems(
                                      title: 'Your Wishlist ',
                                      username: user
                                          .email!, // Pass the post['name'] as an attribute
                                    )),
                          );
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
                ));
          }
        }
      },
    );
  }
}
