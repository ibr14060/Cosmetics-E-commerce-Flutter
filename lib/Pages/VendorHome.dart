import 'package:cosmetics_project/widgets/brand_highlights.dart';
import 'package:cosmetics_project/widgets/category_widget.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import '../widgets/banner_widget.dart';
import '../widgets/drawer_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 250, 177, 215),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'shop app',
          style: TextStyle(letterSpacing: 2),
        ),
        actions: [
          IconButton(
            icon: const Icon(IconlyLight.buy),
            onPressed: () {},
          ),
        ],
      ),
      drawer: AppDrawer(), // Add the AppDrawer here
      body: ListView(
        children: [
          const SearchWidget(),
          SizedBox(
            height: 20,
            width: MediaQuery.of(context).size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  children: const [
                    Icon(
                      IconlyLight.info_square,
                      size: 12,
                      color: Colors.white,
                    ),
                    Text(
                      '4-7 days return',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
                Row(
                  children: const [
                    Icon(
                      IconlyLight.info_square,
                      size: 12,
                      color: Colors.white,
                    ),
                    Text(
                      'Trusted and Tested Brands',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
                Row(
                  children: const [
                    Icon(
                      IconlyLight.info_square,
                      size: 12,
                      color: Colors.white,
                    ),
                    Text(
                      'Shipping all over Egypt',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          BannerWidget(),
          BrandHighLights(),
          CategoryWidget(),
        ],
      ),
    );
  }
}

class SearchWidget extends StatelessWidget {
  const SearchWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 55,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: TextField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.fromLTRB(8, 8, 8, 5),
                  hintText: "Search in our shop",
                  hintStyle: TextStyle(color: Colors.grey),
                  prefixIcon: Icon(
                    Icons.search,
                    size: 30,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
