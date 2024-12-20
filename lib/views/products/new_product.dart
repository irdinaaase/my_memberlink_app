import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
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
  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController priceController = TextEditingController();

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Permission request failed: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
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
            onPressed: () {
              Navigator.pop(context);
            },
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
                    onTap: () {
                      showSelectionDialog();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          fit: BoxFit.contain,
                          image: _image == null
                              ? const AssetImage("assets/images/camera.png")
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
                  ),
                  const SizedBox(height: 10),
                  buildTextField(
                    priceController,
                    "Price",
                    "Enter Price",
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 10),
                  MaterialButton(
                    elevation: 10,
                    onPressed: () {
                      if (!_formKey.currentState!.validate()) {
                        return;
                      }
                      if (_image == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Please upload an image"),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                      compressImage(_image!).then((compressedImage) {
                        if (compressedImage == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Image compression failed."),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                        double filesize = getFileSize(compressedImage);
                        if (filesize > 100) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  "Image size too large after compression"),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                        _image = compressedImage;
                        insertProductDialog();
                      });
                    },
                    minWidth: screenWidth,
                    height: 50,
                    color: Colors.amber,
                    child: Text(
                      "Insert",
                      style: TextStyle(
                        color: Colors.black,
                      ),
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
  }) {
    return TextFormField(
      validator: (value) => value!.isEmpty ? validationText : null,
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        hintText: hintText,
        hintStyle: TextStyle(
          fontFamily: "MagicSchoolOne",
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
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Select from"),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size(screenWidth / 4, screenHeight / 8),
                  ),
                  child: const Text('Gallery'),
                  onPressed: () => getImage(ImageSource.gallery),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size(screenWidth / 4, screenHeight / 8),
                  ),
                  child: const Text('Camera'),
                  onPressed: () => getImage(ImageSource.camera),
                ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to show selection dialog: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future getImage(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) return;
      final imagePermanent = File(image.path);
      setState(() {
        _image = imagePermanent;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to pick image: $e"),
          backgroundColor: Colors.red,
        ),
      );
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

      if (result == null) {
        debugPrint("Compression failed: Result is null");
        return null;
      }

      debugPrint("Compression successful: ${result.path}");
      return File(result.path);
    } catch (e) {
      debugPrint("Compression exception: $e");
      return null;
    }
  }

  double getFileSize(File file) {
    try {
      int sizeInBytes = file.lengthSync();
      double sizeInKB = sizeInBytes / 1024;
      debugPrint("File size: $sizeInKB KB");
      return sizeInKB;
    } catch (e) {
      debugPrint("Failed to calculate file size: $e");
      return 0;
    }
  }

  void insertProductDialog() {
    try {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Insert Product"),
            content: const Text("Are you sure?"),
            actions: [
              TextButton(
                child: const Text("Yes"),
                onPressed: () {
                  insertProduct();
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text("No"),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to show dialog: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void insertProduct() {
    try {
      String name = nameController.text;
      String description = descriptionController.text;
      String quantity = quantityController.text;
      String price = priceController.text;
      String image = base64Encode(_image!.readAsBytesSync());

      http.post(
        Uri.parse(
            "${MyConfig.servername}/my_memberlink_app/api/insert_products.php"),
        body: {
          "product_name": name,
          "product_description": description,
          "product_quantity": quantity,
          "product_price": price,
          "product_filename": image,
        },
      ).then((response) {
        if (response.statusCode == 200) {
          var data = jsonDecode(response.body);
          if (data['status'] == "success") {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Insert Success"),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Insert Failed"),
                backgroundColor: Colors.red,
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Server error: ${response.statusCode}"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Network Error: $error"),
            backgroundColor: Colors.red,
          ),
        );
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Insert Product failed: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
