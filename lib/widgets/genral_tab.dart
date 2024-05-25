import 'package:flutter/material.dart';

class GeneralTab extends StatefulWidget {
  final Function({
    required String productName,
    required String productDescription,
    required String productType,
    required double price,
    required String code,
    required String vendorId,
    required List<Map<String, String>> comments,
  }) onDataSaved;

  const GeneralTab({Key? key, required this.onDataSaved}) : super(key: key);

  @override
  _GeneralTabState createState() => _GeneralTabState();
}

class _GeneralTabState extends State<GeneralTab> {
  String productName = '';
  String productDescription = '';
  String productType = '';
  double price = 0.0;
  String code = '';
  String vendorId = '';
  late String selectedCommentId;
  List<Map<String, String>> comments = [{'comment': '', 'userId': ''}];

  @override
  void initState() {
    super.initState();
    selectedCommentId = comments.isNotEmpty ? comments.first['userId'] ?? '' : '';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: ListView(
        children: [
          _formField(
            label: 'Product Name',
            inputType: TextInputType.name,
            onChanged: (value) {
              setState(() {
                productName = value;
              });
            },
          ),
          _formField(
            label: 'Product Description',
            inputType: TextInputType.multiline,
            onChanged: (value) {
              setState(() {
                productDescription = value;
              });
            },
          ),
          _formField(
            label: 'Product Type',
            inputType: TextInputType.text,
            onChanged: (value) {
              setState(() {
                productType = value;
              });
            },
          ),
          _formField(
            label: 'Price',
            inputType: TextInputType.number,
            onChanged: (value) {
              setState(() {
                price = double.parse(value);
              });
            },
          ),
          _formField(
            label: 'Code',
            inputType: TextInputType.text,
            onChanged: (value) {
              setState(() {
                code = value;
              });
            },
          ),
          _formField(
            label: 'Vendor ID',
            inputType: TextInputType.text,
            onChanged: (value) {
              setState(() {
                vendorId = value;
              });
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
                selectedCommentId = newValue ?? '';
              });
            },
            decoration: InputDecoration(labelText: 'Comments'),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              widget.onDataSaved(
                productName: productName,
                productDescription: productDescription,
                productType: productType,
                price: price,
                code: code,
                vendorId: vendorId,
                comments: comments,
              );
            },
            child: Text('Save Product'),
          ),
        ],
      ),
    );
  }

  Widget _formField({
    required String label,
    required TextInputType inputType,
    required void Function(String) onChanged,
  }) {
    return TextFormField(
      keyboardType: inputType,
      decoration: InputDecoration(
        labelText: label,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$label cannot be empty';
        }
        return null;
      },
      onChanged: onChanged,
    );
  }
}
