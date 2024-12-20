import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:my_memberlink_app/model/myproduct.dart';
import 'package:my_memberlink_app/myconfig.dart';

class EditProductScreen extends StatefulWidget {
  final Product myProduct;

  const EditProductScreen({super.key, required this.myProduct});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  File? _image;
  late double screenWidth, screenHeight;

  final _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    nameController.text = widget.myProduct.productName.toString();
    descriptionController.text = widget.myProduct.productDesc.toString();
    priceController.text = widget.myProduct.productPrice.toString();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Edit Product",
          style: TextStyle(
            fontFamily: "MagicSchoolOne",
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.deepPurple.shade900,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/hogwarts_castle.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
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
                            fit: BoxFit.fill,
                            image: _image == null
                                ? NetworkImage(
                                    "${MyConfig.servername}/my_memberlink_app/assets/products/${widget.myProduct.productFilename}")
                                : FileImage(_image!) as ImageProvider,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.deepPurple.shade100,
                          border: Border.all(color: Colors.deepPurple, width: 2),
                        ),
                        height: screenHeight * 0.4,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      validator: (value) =>
                          value!.isEmpty ? "Enter Product Name" : null,
                      controller: nameController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        hintText: "Product Name",
                        hintStyle: TextStyle(fontFamily: "MagicSchoolOne"),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      validator: (value) =>
                          value!.isEmpty ? "Enter Price" : null,
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        hintText: "Price",
                        hintStyle: TextStyle(fontFamily: "MagicSchoolOne"),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      validator: (value) =>
                          value!.isEmpty ? "Enter Description" : null,
                      controller: descriptionController,
                      maxLines: 10,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        hintText: "Product Description",
                        hintStyle: TextStyle(fontFamily: "MagicSchoolOne"),
                      ),
                    ),
                    const SizedBox(height: 10),
                    MaterialButton(
                      elevation: 10,
                      onPressed: () {
                        if (!_formKey.currentState!.validate()) {
                          return;
                        }
                        if (_image != null) {
                          double filesize = getFileSize(_image!);
                          if (filesize > 100) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Image size too large"),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }
                        }
                        updateProductDialog();
                      },
                      minWidth: screenWidth,
                      height: 50,
                      color: Colors.amber.shade700,
                      child: const Text(
                        "Update",
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: "MagicSchoolOne",
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void showSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Select from",
            style: TextStyle(fontFamily: "MagicSchoolOne"),
          ),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                child: const Text(
                  'Gallery',
                  style: TextStyle(fontFamily: "MagicSchoolOne"),
                ),
                onPressed: () => {
                  Navigator.of(context).pop(),
                  _selectFromGallery(),
                },
              ),
              ElevatedButton(
                child: const Text(
                  'Camera',
                  style: TextStyle(fontFamily: "MagicSchoolOne"),
                ),
                onPressed: () => {
                  Navigator.of(context).pop(),
                  _selectFromCamera(),
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _selectFromCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      maxHeight: 800,
      maxWidth: 800,
    );
    if (pickedFile != null) {
      _image = File(pickedFile.path);
      cropImage();
    }
  }

  Future<void> _selectFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxHeight: 800,
      maxWidth: 800,
    );
    if (pickedFile != null) {
      _image = File(pickedFile.path);
      cropImage();
    }
  }

  Future<void> cropImage() async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: _image!.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: Colors.deepPurple.shade900,
          toolbarWidgetColor: Colors.amber.shade700,
          lockAspectRatio: false,
        ),
      ],
    );
    if (croppedFile != null) {
      _image = File(croppedFile.path);
      setState(() {});
    }
  }

  double getFileSize(File file) {
    int sizeInBytes = file.lengthSync();
    return (sizeInBytes / (1024 * 1024)) * 1000;
  }

  void updateProductDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Update Product",
            style: TextStyle(fontFamily: "MagicSchoolOne"),
          ),
          content: const Text(
            "Are you sure?",
            style: TextStyle(fontFamily: "MagicSchoolOne"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                "Yes",
                style: TextStyle(fontFamily: "MagicSchoolOne"),
              ),
              onPressed: () {
                updateProduct();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                "No",
                style: TextStyle(fontFamily: "MagicSchoolOne"),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void updateProduct() {
    String image = _image == null
        ? "NA"
        : base64Encode(_image!.readAsBytesSync());
    String name = nameController.text;
    String description = descriptionController.text;
    String price = priceController.text;

    http.post(
      Uri.parse("${MyConfig.servername}/my_memberlink_app/api/update_product.php"),
      body: {
        "productid": widget.myProduct.productId.toString(),
        "name": name,
        "description": description,
        "price": price,
        "filename": widget.myProduct.productFilename,
        "image": image,
      },
    ).then((response) {
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['status'] == "success") {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Update Success"),
            backgroundColor: Colors.green,
          ));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Update Failed"),
            backgroundColor: Colors.red,
          ));
        }
      }
    });
  }
}
