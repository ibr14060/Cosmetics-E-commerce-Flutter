class Product {
  String id;
  String productName; // Remove final keyword here
  String productDescription;
  String productType;
  double price;
  String code;
  String vendorId;
  List<String> comments;

  Product({
    required this.id,
    required this.productName,
    required this.productDescription,
    required this.productType,
    required this.price,
    required this.code,
    required this.vendorId,
    required this.comments
  });

  factory Product.fromJson(Map<String, dynamic> json) {
  return Product(
    id: json['id'] ?? '',
    productName: json['productName'] ?? '',
    productDescription: json['productDescription'] ?? '',
    productType: json['productType'] ?? '',
    price: json['price'] != null ? json['price'].toDouble() : 0.0,
    code: json['code'] ?? '',
    vendorId: json['vendorId'] ?? '',
    comments: json['comments'] ??'',
  );
}


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productName': productName,
      'productDescription': productDescription,
      'productType': productType,
      'price': price,
      'code': code,
      'vendorId': vendorId,
      'comments':comments,
    };
  }
}
