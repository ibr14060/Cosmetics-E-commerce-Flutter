import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

class CategoryWidget extends StatefulWidget {
  @override
  _CategoryWidgetState createState() => _CategoryWidgetState();
}

class _CategoryWidgetState extends State<CategoryWidget> {
  final List<String> _categoryLabel = <String>[
    '*Picked for you',
    'SkinCare',
    'Makeup',
    'Perfumes and body mists',
    'HairCare',
    'Beauty Tools',
  ];
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      
      child: Column(
        children: [
          Text(
            'Stores for you',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
              fontSize: 20,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              height: 40,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _categoryLabel.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(8,0,8,8),
                            child: ActionChip(
                              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              backgroundColor: _index == index
                                  ? Color.fromARGB(255, 235, 75, 152)
                                  : Colors.grey,
                              label: Text(
                                _categoryLabel[index],
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _index == index ? Colors.white : Colors.black,
                                ),
                              ),
                              onPressed: () {
                                setState(() {
                                  _index = index;
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        // Action for the arrow down button
                      },
                      icon: Icon(IconlyLight.arrow_down),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
