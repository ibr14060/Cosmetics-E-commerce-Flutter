import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class PostPage extends StatefulWidget {
  const PostPage({Key? key, required this.username}) : super(key: key);
  final String username;

  @override
  _PostPageState createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _productDescriptionController =
      TextEditingController();
  final TextEditingController _productTypeController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _vendorIdController = TextEditingController();

  File? _image;

  Future<void> _pickImage(ImageSource source) async {
    final pickedImage = await ImagePicker().pickImage(source: source);
    setState(() {
      if (pickedImage != null) {
        _image = File(pickedImage.path);
      }
    });
  }

  void _removeImage() {
    setState(() {
      _image = null;
    });
  }

  Future<void> postData() async {
    final String productName = _productNameController.text;
    final String productDescription = _productDescriptionController.text;
    final String productType = _productTypeController.text;
    final double price = double.tryParse(_priceController.text) ?? 0.0;
    final String code = _codeController.text;
    final String vendorId = _vendorIdController.text;

    if (productName.isEmpty ||
        productDescription.isEmpty ||
        productType.isEmpty ||
        price == 0.0 ||
        code.isEmpty ||
        vendorId.isEmpty) {
      // Validate input fields
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Please fill all fields'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    String base64Image = '';
    if (_image != null) {
      List<int> imageBytes = await _image!.readAsBytes();
      base64Image = base64Encode(imageBytes);
    }

    Map<String, dynamic> data = {
      'ProductName': productName,
      'ProductDescription': productDescription,
      'ProductCategory': productType,
      'ProductPrice': price,
      'code': code,
      'VendorName': vendorId,
      'ProductImage': base64Image,
      'ProductRating': 0,
      'ProductComments': [],
    };

    final response = await http.post(
      Uri.parse(
          'https://mobileproject12-d6fad-default-rtdb.firebaseio.com/Products.json'),
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      // Post successful
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Success'),
            content: Text('Product posted successfully'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      // Post failed
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Failed to post product'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Product'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _productNameController,
              decoration: InputDecoration(labelText: 'Product Name'),
            ),
            TextFormField(
              controller: _productDescriptionController,
              decoration: InputDecoration(labelText: 'Product Description'),
            ),
            TextFormField(
              controller: _productTypeController,
              decoration: InputDecoration(labelText: 'Product Type'),
            ),
            TextFormField(
              controller: _priceController,
              decoration: InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
            ),
            TextFormField(
              controller: _codeController,
              decoration: InputDecoration(labelText: 'Code'),
            ),
            TextFormField(
              controller: _vendorIdController,
              decoration: InputDecoration(labelText: 'Vendor ID'),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Choose Image Source'),
                      content: Text('Select the source for the image'),
                      actions: <Widget>[
                        TextButton(
                          child: Text('Camera'),
                          onPressed: () {
                            _pickImage(ImageSource.camera);
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: Text('Gallery'),
                          onPressed: () {
                            _pickImage(ImageSource.gallery);
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              child: Text('Select Image'),
            ),
            SizedBox(height: 20.0),
            if (_image != null) ...[
              Container(
                height: 200, // Fixed height for the image
                width: double.infinity, // Full width
                child: Image.file(_image!, fit: BoxFit.cover),
              ),
              SizedBox(height: 20.0),
            ],
            ElevatedButton(
              onPressed: postData,
              child: Text('Post Product'),
            ),
          ],
        ),
      ),
    );
  }
}
