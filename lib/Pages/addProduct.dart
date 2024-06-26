import 'dart:io';

import 'package:cosmetics_project/widgets/genral_tab.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:cosmetics_project/widgets/genral_tab.dart';

class AddProductScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    throw UnimplementedError();
  }

  final String databaseUrl =
      'https://mobileproject12-d6fad-default-rtdb.firebaseio.com/Products';

  void showDialogMessage(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  void addProductToDatabase({
    required BuildContext context,
    required String productName,
    required String productDescription,
    required String productType,
    required double price,
    required String code,
    required String vendorId,
    required List<Map<String, dynamic>> comments,
    File? imageFile, // Add imageFile parameter
  }) async {
    try {
      final productId = Uuid().v4();

      final response = await http.post(
        Uri.parse('$databaseUrl.json'),
        body: json.encode({
          'ProductId': productId,
          'ProductName': productName,
          'ProductDescription': productDescription,
          'ProductCategory': productType,
          'ProductPrice': price,
          'code': code,
          'VendorName': vendorId,
          'ProductComments': comments,
        }),
      );

      if (response.statusCode == 200) {
        showDialogMessage(
            context, 'Success', 'The product has been added successfully.');
      } else {
        showDialogMessage(context, 'Error',
            'Error adding product Please Try again: ${response.statusCode}');
      }
    } catch (error) {
      showDialogMessage(
          context, 'Error', 'Error adding product Please Try again: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: 0,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: Text('Add Product'),
          bottom: const TabBar(
            isScrollable: true,
            indicator: UnderlineTabIndicator(
              borderSide: BorderSide(
                width: 4,
                color: Colors.pink,
              ),
            ),
            tabs: [
              Tab(
                child: Text('Add Product'),
              ),
              Tab(
                child: Text('Update Product'),
              ),
            ],
          ),
        ),
        body: Center(
          child: TabBarView(
            children: [
              GeneralTab(
                onDataSaved: ({
                  required String productName,
                  required String productDescription,
                  required String productType,
                  required double price,
                  required String code,
                  required String vendorId,
                  required List<Map<String, dynamic>> comments,
                }) {
                  addProductToDatabase(
                    context: context,
                    productName: productName,
                    productDescription: productDescription,
                    productType: productType,
                    price: price,
                    code: code,
                    vendorId: vendorId,
                    comments: comments,
                  );
                },
              ),
              UpdateProductTab(databaseUrl: '$databaseUrl.json'),
            ],
          ),
        ),
      ),
    );
  }
}

class UpdateProductTab extends StatefulWidget {
  final String databaseUrl;

  const UpdateProductTab({Key? key, required this.databaseUrl})
      : super(key: key);

  @override
  _UpdateProductTabState createState() => _UpdateProductTabState();
}

class _UpdateProductTabState extends State<UpdateProductTab> {
  List<Map<String, dynamic>> products = [];

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
            products = data.entries
                .map((e) => {
                      ...e.value as Map<String, dynamic>,
                      'id': e.key,
                    })
                .toList();
          });
        }
      } else {
        print('Failed to fetch products: ${response.statusCode}');
      }
    } catch (error) {
      print('Failed to fetch products: $error');
    }
  }

  Future<void> updateProduct({
    required BuildContext context,
    required String id,
    required String productName,
    required String productDescription,
    required String productType,
    required double price,
    required String code,
    required String vendorId,
    required List<Map<String, dynamic>> comments,
  }) async {
    try {
      final Map<String, dynamic> productData = {
        'productName': productName,
        'productDescription': productDescription,
        'productType': productType,
        'price': price,
        'code': code,
        'vendorId': vendorId,
        'comments': comments,
      };

      final String baseUrl =
          'https://mobileproject12-d6fad-default-rtdb.firebaseio.com/Products/$id.json';
      final Uri url = Uri.parse(baseUrl);

      final response = await http.put(
        url,
        body: json.encode(productData),
      );

      if (response.statusCode == 200) {
        showDialogMessage(
            context, 'Success', 'Product has been saved successfully ');
        fetchProducts();
      } else {
        showDialogMessage(context, 'Error',
            'Error updating product , Please Try again: ${response.statusCode}');
      }
    } catch (error) {
      showDialogMessage(context, 'Error',
          'Error updating product , Please Try again: $error');
    }
  }

  Future<void> deleteProduct(BuildContext context, String id) async {
    bool confirmDelete = await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('Confirm Delete'),
            content: Text('Are you sure you want to delete this product?'),
            actions: [
              TextButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(ctx).pop(false);
                },
              ),
              TextButton(
                child: Text('Delete'),
                onPressed: () {
                  Navigator.of(ctx).pop(true);
                },
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmDelete) return;

    try {
      final String baseUrl =
          'https://mobileproject12-d6fad-default-rtdb.firebaseio.com/Products/$id.json';
      final Uri url = Uri.parse(baseUrl);

      final response = await http.delete(url);

      if (response.statusCode == 200) {
        showDialogMessage(
            context, 'Success', 'Product has been deleted successfully');
        fetchProducts();
      } else {
        showDialogMessage(context, 'Error',
            'Error deleting product , Please Try again: ${response.statusCode}');
      }
    } catch (error) {
      showDialogMessage(context, 'Error',
          'Error deleting product , Please Try again: $error');
    }
  }

  void showDialogMessage(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return ProductEditForm(
          product: product,
          onSave: (id, productName, productDescription, productType, price,
              code, vendorId, comments) {
            updateProduct(
              context: context,
              id: id,
              productName: productName,
              productDescription: productDescription,
              productType: productType,
              price: price,
              code: code,
              vendorId: vendorId,
              comments: comments,
            );
          },
          onDelete: (id) {
            deleteProduct(context, id);
          },
        );
      },
    );
  }
}

class ProductEditForm extends StatefulWidget {
  final Map<String, dynamic> product;
  final Function(
    String id,
    String productName,
    String productDescription,
    String productType,
    double price,
    String code,
    String vendorId,
    List<Map<String, dynamic>> comments,
  ) onSave;
  final Function(String id) onDelete;

  const ProductEditForm({
    Key? key,
    required this.product,
    required this.onSave,
    required this.onDelete,
  }) : super(key: key);

  @override
  _ProductEditFormState createState() => _ProductEditFormState();
}

class _ProductEditFormState extends State<ProductEditForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _productNameController;
  late TextEditingController _productDescriptionController;
  late TextEditingController _productTypeController;
  late TextEditingController _priceController;
  late TextEditingController _codeController;
  late TextEditingController _vendorIdController;
  late TextEditingController _commentController;
  List<Map<String, dynamic>> comments = [];
  String? selectedCommentId;

  @override
  void initState() {
    super.initState();
    _productNameController =
        TextEditingController(text: widget.product['productName']);
    _productDescriptionController =
        TextEditingController(text: widget.product['productDescription']);
    _productTypeController =
        TextEditingController(text: widget.product['productType']);
    _priceController =
        TextEditingController(text: widget.product['price'].toString());
    _codeController = TextEditingController(text: widget.product['code']);
    _vendorIdController =
        TextEditingController(text: widget.product['vendorId']);
    _commentController = TextEditingController();

    comments = (widget.product['comments'] != null &&
            widget.product['comments'] is List)
        ? List<Map<String, dynamic>>.from(
            (widget.product['comments'] as List).map(
              (comment) => {
                'comment': comment['comment'] != null
                    ? comment['comment'].toString()
                    : '',
                'userId': comment['userId'] != null
                    ? comment['userId'].toString()
                    : '',
              },
            ),
          )
        : [
            {'comment': '', 'userId': ''}
          ];
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _productDescriptionController.dispose();
    _productTypeController.dispose();
    _priceController.dispose();
    _codeController.dispose();
    _vendorIdController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _productNameController,
                decoration: InputDecoration(labelText: 'Product Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a product name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _productDescriptionController,
                decoration: InputDecoration(labelText: 'Product Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a product description';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _productTypeController,
                decoration: InputDecoration(labelText: 'Product Type'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a product type';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _codeController,
                decoration: InputDecoration(labelText: 'Code'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a code';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _vendorIdController,
                decoration: InputDecoration(labelText: 'Vendor ID'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a vendor ID';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: selectedCommentId,
                items: comments.map((comment) {
                  return DropdownMenuItem<String>(
                    value: comment['userId'],
                    child: Text('${comment['userId']}: ${comment['comment']}'),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    selectedCommentId = newValue;
                  });
                },
                decoration: InputDecoration(labelText: 'Comments'),
              ),
              SizedBox(height: 8.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        widget.onSave(
                          widget.product['id'],
                          _productNameController.text,
                          _productDescriptionController.text,
                          _productTypeController.text,
                          double.parse(_priceController.text),
                          _codeController.text,
                          _vendorIdController.text,
                          comments,
                        );
                      }
                    },
                    child: Text('Save Changes'),
                  ),
                  IconButton(
                    onPressed: () {
                      widget.onDelete(widget.product['id']);
                    },
                    icon: Icon(Icons.delete),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
