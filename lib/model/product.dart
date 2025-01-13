class ProductList {
  List<Product>? data;

  ProductList(this.data);

  ProductList.fromJson(List<dynamic> json) {
    data = json.map((productJson) => Product.fromJson(productJson)).toList();
  }
}

class Product {
  String? productId;
  String? productName;
  String? productDesc;
  String? productFilename;
  int? productQuantity;
  double? productPrice;
  String? productDate;

  Product(
      {this.productId,
      this.productName,
      this.productDesc,
      this.productFilename,
      this.productQuantity,
      this.productPrice,
      this.productDate});

  // Adjusted for the backend field names
  Product.fromJson(Map<String, dynamic> json) {
    productId = json['product_id'];
    productName = json['product_name']; // Matching backend field name
    productDesc = json['product_description']; // Matching backend field name
    productFilename = json['product_filename']; // Matching backend field name
    productQuantity = json['product_quantity'] != null
        ? int.tryParse(json['product_quantity'].toString())
        : null;
    productPrice = json['product_price'] != null
        ? double.tryParse(json['product_price'].toString())
        : null;
    productDate = json['product_date']; // Keep if your backend includes a date
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['product_id'] = productId;
    data['product_name'] = productName;
    data['product_description'] = productDesc;
    data['product_filename'] = productFilename;
    data['product_quantity'] = productQuantity?.toString();
    data['product_price'] = productPrice?.toString();
    data['product_date'] = productDate; // Keep this if needed, otherwise remove
    return data;
  }
}
