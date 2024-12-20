import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_memberlink_app/model/myproduct.dart';
import 'package:my_memberlink_app/myconfig.dart';
import 'package:my_memberlink_app/views/products/edit_product.dart';
import 'package:my_memberlink_app/views/products/new_product.dart';
import 'package:my_memberlink_app/views/shared/mydrawer.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  List<Product> productsList = [];
  late double screenWidth, screenHeight;
  String status = "Loading...";
  int currentPage = 1;
  int totalPage = 1;
  bool isLoadingMore = false;

  List<bool> cartStatus = []; // To track the cart status for each product

  @override
  void initState() {
    super.initState();
    loadProductsData();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Hogwarts Wares",
          style: TextStyle(
            fontFamily: "HarryPotter",
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.yellow,
          ),
        ),
        backgroundColor: Colors.brown[800],
        actions: [
          IconButton(
            onPressed: () async {
              currentPage = 1;
              productsList.clear();
              await loadProductsData();
            },
            icon: const Icon(Icons.refresh, color: Colors.amber),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/hogwarts_castle.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: productsList.isEmpty
                  ? Center(
                      child: Text(
                        status,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: "MagicSchoolOne",
                        ),
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(8.0),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.58,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                      ),
                      itemCount: productsList.length,
                      itemBuilder: (context, index) {
                        if (cartStatus.length <= index) {
                          cartStatus.add(false); // Default: not in cart
                        }
                        return buildProductCard(index);
                      },
                    ),
            ),
            if (totalPage > 1) buildPagination(),
          ],
        ),
      ),
      drawer: const MyDrawer(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NewProductScreen()),
          ).then((_) => loadProductsData());
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget buildProductCard(int index) {
    final product = productsList[index];
    return Card(
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(
          color: index % 4 == 0
              ? Colors.red
              : index % 4 == 1
                  ? Colors.green
                  : index % 4 == 2
                      ? Colors.blue
                      : Colors.yellow,
          width: 2,
        ),
      ),
      elevation: 15,
      child: Container(
        decoration: BoxDecoration(
          image: const DecorationImage(
            image: AssetImage("assets/images/paper2.jpg"),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: InkWell(
          splashColor: Colors.amber.withOpacity(0.5),
          onTap: () => showProductDetailsDialog(index),
          onLongPress: () => deleteDialog(index),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.productName ?? "Unnamed Item",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    overflow: TextOverflow.ellipsis,
                    fontFamily: 'MagicSchoolOne',
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: screenHeight / 6,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      "${MyConfig.servername}/my_memberlink_app/assets/products/${product.productFilename}",
                      width: screenWidth / 2.5,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Image.asset("assets/images/camera.png"),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Price: RM${product.productPrice}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontFamily: "MagicSchoolOne",
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Quantity: ${product.productQuantity ?? 0}",
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    setState(() {
                      cartStatus[index] = !cartStatus[index];
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          cartStatus[index]
                              ? "Successfully added to cart"
                              : "Product removed",
                        ),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: cartStatus[index]
                        ? Colors.green.shade400
                        : Colors.amber.shade400,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    foregroundColor:
                        cartStatus[index] ? Colors.white : Colors.black,
                    side: BorderSide(
                      color: cartStatus[index]
                          ? Colors.green.shade500
                          : Colors.amber.shade500,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        cartStatus[index]
                            ? Icons.check_circle
                            : Icons.add_shopping_cart,
                        color: cartStatus[index] ? Colors.white : Colors.black,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        cartStatus[index] ? "Added" : "Add to Cart",
                        style: TextStyle(
                          color:
                              cartStatus[index] ? Colors.white : Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildPagination() {
    return Container(
      color: Colors.brown[800],
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(totalPage, (index) {
          int pageIndex = index + 1;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  currentPage = pageIndex;
                  productsList.clear();
                });
                loadProductsData();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: currentPage == pageIndex
                    ? Colors.amber
                    : Colors.brown,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Text(
                "$pageIndex",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          );
        }),
      ),
    );
  }

  Future<void> loadProductsData() async {
    try {
      final response = await http.get(
        Uri.parse(
            "${MyConfig.servername}/my_memberlink_app/api/load_products.php?pageno=$currentPage"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == "success") {
          totalPage = data['numofpage'];
          final List products = data['data']['products'];
          setState(() {
            productsList.addAll(
                products.map((item) => Product.fromJson(item)).toList());
          });
        } else {
          setState(() {
            status = "No Products Available";
          });
        }
      } else {
        setState(() {
          status = "Error Loading Products";
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error Loading Products")),
        );
      }
    } catch (e) {
      setState(() {
        status = "Failed to Load Products";
      });
      log(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to Load Products: $e")),
      );
    }
  }

  void showProductDetailsDialog(int index) {
    final product = productsList[index];
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.black.withOpacity(0.8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.amber.shade600, width: 2),
          ),
          title: Center(
            child: Text(
              product.productName ?? "Unnamed Item",
              style: const TextStyle(
                fontFamily: "MagicSchoolOne", // A Hogwarts-style font
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.amber,
                shadows: [
                  Shadow(
                    color: Colors.black,
                    blurRadius: 5,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Product Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(
                    "${MyConfig.servername}/my_memberlink_app/assets/products/${product.productFilename}",
                    height: 150,
                    width: 150,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Image.asset(
                        "assets/images/hogwarts_logo.png",
                        height: 150),
                  ),
                ),
                const SizedBox(height: 10),
                // Magical Separator
                Divider(
                  color: Colors.amber.shade600,
                  thickness: 1.5,
                  indent: 40,
                  endIndent: 40,
                ),
                const SizedBox(height: 10),
                // Product Price
                Text(
                  "Price: RM${product.productPrice}",
                  style: const TextStyle(
                    fontFamily: "Cinzel",
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                ),
                const SizedBox(height: 8),
                // Product Quantity
                Text(
                  "Quantity: ${product.productQuantity}",
                  style: const TextStyle(
                    fontFamily: "Cinzel",
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 8),
                // Product Description
                Text(
                  product.productDesc ?? "No description available",
                  style: const TextStyle(
                    fontFamily: "MagicSchoolOne",
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: Colors.white54,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Colors.red.shade700,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Close",
                style: TextStyle(
                  fontFamily: "MagicSchoolOne",
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                navigateToEditProduct(index);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Colors.green.shade700,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Edit",
                style: TextStyle(
                  fontFamily: "MagicSchoolOne",
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void navigateToEditProduct(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProductScreen(myProduct: productsList[index]),
      ),
    ).then((_) => loadProductsData());
  }

  void deleteDialog(int index) {
    final product = productsList[index];
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Product"),
          content:
              Text("Are you sure you want to delete ${product.productName}?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                deleteProduct(index);
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteProduct(int index) async {
    final product = productsList[index];
    try {
      final response = await http.post(
        Uri.parse(
            "${MyConfig.servername}/my_memberlink_app/api/delete_product.php"),
        body: {"product_id": product.productId.toString()},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == "success") {
          productsList.removeAt(index);
          setState(() {});
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Product Deleted")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to Delete Product")),
          );
        }
      }
    } catch (e) {
      log(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error Deleting Product: $e")),
      );
    }
  }
}
