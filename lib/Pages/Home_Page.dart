import 'dart:convert';
import 'package:cosmetics_project/Pages/Comments.dart';
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

  final String title;
  final String username;
  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> ProductsData = [];
  List<Map<String, dynamic>> allusersData = [];
  List<Map<String, dynamic>> usersData = [];

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
        // Handle the case where the user is not authenticated
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

        // Clear existing post data
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

        // Find the user by email
        favData.forEach((key, value) {
          if (value['email'] == userEmail) {
            userKey = key;
            userFavItems = value['Products'];
          }
        });

        if (userKey.isNotEmpty) {
          // Check if the product is already in the favorites
          if (userFavItems != null && userFavItems!.containsKey(productId)) {
            // Remove the product from favorites
            userFavItems!.remove(productId);
          } else {
            // Add the product to favorites
            userFavItems ??= {};
            userFavItems![productId] = {
              'id': productId
            }; // You can add additional data if needed
          }

          // Update the user's favorite items in the database
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
                      Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Text(
                              'Sort by ',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          // SizedBox(height: 16),
                        ],
                      ),
                      SizedBox(
                        height: 54,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: SortData.length,
                          itemBuilder: (context, index) {
                            final button = SortData[index];

                            return Container(
                              margin: EdgeInsets.symmetric(horizontal: 8.0),
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  //button['onPressed']
                                  if (button['name'] ==
                                      "Alphabetical(A -> Z)") {
                                    sortPostsByName();
                                  } else if (button['name'] == "Time(Latest)") {
                                    sortPostsByTimeStamp();
                                  } else {
                                    sortPostsByRating();
                                  }
                                },
                                icon: Icon(button['icon']),
                                label: Text(button['name']),
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16.0),
                                  ),
                                  padding: EdgeInsets.all(12.0),
                                ),
                              ),
                            );
                          },
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
                                    const SizedBox(width: 8.0),
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            'UserName',
                                            style: TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                        ),

                                        Text(
                                          ' :',
                                          style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),

                                        // const SizedBox(width: 8.0),
                                        Flexible(
                                          child: Text(
                                            post['ProductName'],
                                            style: TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 19.0),
                                        Text(
                                          ' ',
                                          style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                        IconButton(
                                            icon: Icon(
                                              isLiked
                                                  ? Icons.favorite
                                                  : Icons.favorite_border,
                                              color: Colors.red,
                                            ),
                                            onPressed: () {
                                              toggleLike(
                                                  post['id'], user.email!);
                                            }),
                                      ],
                                    ),
                                    Row(children: [
                                      // SizedBox(width: 16.0),
                                      Text(
                                        post['ProductName'],
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
/*
                          SizedBox(width: 16.0),
                          IconButton(
                            icon: Icon(
                              isLiked ? Icons.favorite : Icons.favorite_border,
                              color: Colors.red,
                              size: 50.0,
                            ),
                            onPressed: toggleLike,
                          ),
                          */
                                    ]),
                                    SizedBox(height: 8),
                                    Text(
                                      'Price: ${post['ProductPrice']}',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(Icons.location_on, size: 16),
                                        SizedBox(width: 4),
                                        Flexible(
                                          child: Text(
                                            'Vendor: ${post['ProductVendor']}',
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Rating: ${post['ProductRating']}',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    SizedBox(height: 16),
                                    Container(
                                      height: 200,
                                      width: double.infinity,
                                      child: Image.memory(
                                        base64Decode(post['ProductImage']),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        RatingBar.builder(
                                          initialRating:
                                              post['ProductRating'].toDouble(),
                                          minRating: 1,
                                          direction: Axis.horizontal,
                                          allowHalfRating: true,
                                          itemCount: 5,
                                          itemSize: 35,
                                          itemPadding: EdgeInsets.symmetric(
                                              horizontal: 2.0),
                                          itemBuilder: (context, _) => Icon(
                                            Icons.star,
                                            color: Colors.amber,
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
                                                        title: 'Comment Page',
                                                        postName: post['id'],
                                                        username: user
                                                            .email!, // Pass the post['name'] as an attribute
                                                      )),
                                            );

                                            // Handle the comment button click
                                            print('Comment button clicked');
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
                        icon: Icon(Icons.shopping_cart),
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
                ));
          }
        }
      },
    );
  }
}
