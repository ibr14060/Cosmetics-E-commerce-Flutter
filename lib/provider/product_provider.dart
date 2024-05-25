import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class Product_provider with ChangeNotifier{
  Map<String,dynamic> ?productData;


getFormData(String? productName,int? regularPrice,int? salesPrice,String? taxStatus,String ? taxType){
  if(productName != null){
productData!['ProductName'] = productName;
  }

   if(regularPrice != null){
productData!['regularPrice'] = regularPrice;
  }

   if(salesPrice != null){
productData!['salesPrice'] = salesPrice;
  }

   if(taxStatus != null){
productData!['taxStatus'] = taxStatus;
  }

   if(taxType != null){
productData!['taxType'] = taxType;
  }
notifyListeners();

}



}