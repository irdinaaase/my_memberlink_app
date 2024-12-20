import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:my_memberlink_app/myconfig.dart';

class NewProductScreen extends StatefulWidget {
  const NewProductScreen({super.key});

  @override
  State<NewProductScreen> createState() => _NewProductScreenState();
}

class _NewProductScreenState extends State<NewProductScreen> {
  late double screenWidth, screenHeight;
  File? _image;

  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final quantityController = TextEditingController();
  final priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    requestPermissions();
  }

  Future<void> requestPermissions() async {
    try {
      var statuses = await [
        Permission.camera,
        Permission.storage,
      ].request();

      if (!mounted) return;

      if (statuses[Permission.camera]!.isDenied ||
          statuses[Permission.storage]!.isDenied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Camera and Storage permissions are required."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      showErrorSnackbar("Permission request failed: $e");
    }
  }

  void showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text("New Product"),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: showSelectionDialog,
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          fit: BoxFit.contain,
                          image: _image == null
                              ? const AssetImage("assets/images/placeholder.png")
                              : FileImage(_image!) as ImageProvider,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey.shade200,
                        border: Border.all(color: Colors.grey),
                      ),
                      height: screenHeight * 0.4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  buildTextField(
                    nameController,
                    "Product Name",
                    "Enter Product Name",
                  ),
                  const SizedBox(height: 10),
                  buildTextField(
                    descriptionController,
                    "Product Description",
                    "Enter Product Description",
                    maxLines: 5,
                  ),
                  const SizedBox(height: 10),
                  buildTextField(
                    quantityController,
                    "Quantity",
                    "Enter Quantity",
                    keyboardType: TextInputType.number,
                    numericValidation: true,
                  ),
                  const SizedBox(height: 10),
                  buildTextField(
                    priceController,
                    "Price",
                    "Enter Price",
                    keyboardType: TextInputType.number,
                    numericValidation: true,
                  ),
                  const SizedBox(height: 10),
                  MaterialButton(
                    elevation: 10,
                    onPressed: handleInsert,
                    minWidth: screenWidth,
                    height: 50,
                    color: Colors.amber,
                    child: const Text(
                      "Insert",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextField(
    TextEditingController controller,
    String hintText,
    String validationText, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    bool numericValidation = false,
  }) {
    return TextFormField(
      validator: (value) {
        if (value == null || value.isEmpty) {
          return validationText;
        }
        if (numericValidation && (double.tryParse(value) == null || double.parse(value) <= 0)) {
          return "$hintText must be a positive number";
        }
        return null;
      },
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        hintText: hintText,
        hintStyle: TextStyle(
          fontSize: 16,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }

  Future<void> showSelectionDialog() async {
    try {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Select from"),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  child: const Text('Gallery'),
                  onPressed: () => getImage(ImageSource.gallery),
                ),
                ElevatedButton(
                  child: const Text('Camera'),
                  onPressed: () => getImage(ImageSource.camera),
                ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      showErrorSnackbar("Failed to show selection dialog: $e");
    }
  }

  Future getImage(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) return;
      setState(() {
        _image = File(image.path);
      });
    } catch (e) {
      showErrorSnackbar("Failed to pick image: $e");
    }
  }

  Future<File?> compressImage(File file) async {
    try {
      final directory = await getTemporaryDirectory();
      final targetPath =
          p.join(directory.path, "compressed_${p.basename(file.path)}");

      var result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: 30,
        minWidth: 1024,
        minHeight: 1024,
      );

      return result == null ? null : File(result.path);
    } catch (e) {
      debugPrint("Compression exception: $e");
      return null;
    }
  }

  Future<String> encodePlaceholderImage() async {
    final bytes = await rootBundle.load('assets/images/placeholder.png');
    return base64Encode(bytes.buffer.asUint8List());
  }

  Future<void> handleInsert() async {
    if (!_formKey.currentState!.validate()) return;

    String imageBase64;
    if (_image == null) {
      imageBase64 = await encodePlaceholderImage();
    } else {
      final compressedImage = await compressImage(_image!);
      if (compressedImage == null) {
        showErrorSnackbar("Image compression failed.");
        return;
      }
      imageBase64 = base64Encode(compressedImage.readAsBytesSync());
    }

    insertProduct(imageBase64);
  }

  void insertProduct(String imageBase64) {
    final body = {
      "product_name": nameController.text,
      "product_description": descriptionController.text,
      "product_quantity": quantityController.text,
      "product_price": priceController.text,
      "product_filename": imageBase64,
    };

    http.post(
      Uri.parse("${MyConfig.servername}/my_memberlink_app/api/insert_products.php"),
      body: body,
    ).then((response) {
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == "success") {
          Navigator.pop(context);
          showSuccessSnackbar("Insert Success");
        } else {
          showErrorSnackbar("Insert Failed");
        }
      } else {
        showErrorSnackbar("Server error: ${response.statusCode}");
      }
    }).catchError((error) {
      showErrorSnackbar("Network Error: $error");
    });
  }
}
