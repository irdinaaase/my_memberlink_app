import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_memberlink_app/myconfig.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController firstnameController = TextEditingController();
  TextEditingController lastnameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  bool passwordVisible = true;
  bool isLoading = false;
  String? selectedTitle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image with gradient overlay
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/portal.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.6),
                  Colors.transparent,
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Card(
                  color: Colors.black.withOpacity(0.7),
                  elevation: 15,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Create New Account',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber[200],
                              fontFamily: 'Cinzel',
                              shadows: [
                                Shadow(
                                  offset: const Offset(3, 3),
                                  blurRadius: 8,
                                  color: Colors.black.withOpacity(0.7),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildDropdownField(),
                          const SizedBox(height: 10),
                          _buildTextField(
                              firstnameController, "First Name", false),
                          const SizedBox(height: 10),
                          _buildTextField(
                              lastnameController, "Last Name", false),
                          const SizedBox(height: 10),
                          _buildTextField(
                              phoneController, "Phone Number", false,
                              keyboardType: TextInputType.phone),
                          const SizedBox(height: 10),
                          _buildTextField(addressController, "Address", false,
                              keyboardType: TextInputType.streetAddress),
                          const SizedBox(height: 10),
                          _buildTextField(emailController, "Your Email", true,
                              keyboardType: TextInputType.emailAddress),
                          const SizedBox(height: 10),
                          _buildPasswordField(),
                          const SizedBox(height: 20),
                          isLoading
                              ? const CircularProgressIndicator()
                              : _buildActionButton(),
                          const SizedBox(height: 20),
                          _buildLoginRedirectText(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField() {
    return DropdownButtonFormField<String>(
      value: selectedTitle,
      items: ["Ms.", "Mr.", "Mrs."]
          .map((title) => DropdownMenuItem(value: title, child: Text(title)))
          .toList(),
      onChanged: (value) {
        setState(() {
          selectedTitle = value!;
        });
      },
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.black.withOpacity(0.5),
        hintText: "Choose Your Title",
        hintStyle: TextStyle(color: Colors.grey[400]),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
        prefixIcon: Icon(Icons.person, color: Colors.amber[200]),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String hintText, bool isEmail,
      {TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "$hintText is required";
        }
        if (isEmail) {
          const emailRegex = r'^[^@\s]+@[^@\s]+\.[^@\s]+$';
          if (!RegExp(emailRegex).hasMatch(value)) {
            return 'Enter a valid email address';
          }
        }
        return null;
      },
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.black.withOpacity(0.5),
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey[400]),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
        prefixIcon: Icon(
          isEmail ? Icons.email : Icons.text_fields,
          color: Colors.amber[200],
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      obscureText: passwordVisible,
      controller: passwordController,
      style: const TextStyle(color: Colors.white),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Password is required";
        }
        if (value.length < 6) {
          return "Password must be at least 6 characters long";
        }
        return null;
      },
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.black.withOpacity(0.5),
        hintText: "Your Password",
        hintStyle: TextStyle(color: Colors.grey[400]),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
        prefixIcon: Icon(Icons.lock, color: Colors.amber[200]),
        suffixIcon: IconButton(
          icon: Icon(
            passwordVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.white,
          ),
          onPressed: () {
            setState(() {
              passwordVisible = !passwordVisible;
            });
          },
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    return MaterialButton(
      elevation: 10,
      onPressed: userRegistration,
      minWidth: double.infinity,
      height: 50,
      color: Colors.deepPurple[800],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: const Text(
        "Register",
        style: TextStyle(color: Colors.white, fontSize: 18),
      ),
    );
  }

  Widget _buildLoginRedirectText() {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: const Text(
        "Already registered? Login",
        style: TextStyle(
          color: Colors.white,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  void userRegistration() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    String title = selectedTitle ?? "";
    String firstName = firstnameController.text;
    String lastName = lastnameController.text;
    String phone = phoneController.text;
    String address = addressController.text;
    String email = emailController.text;
    String password = passwordController.text;

    try {
      final response = await http.post(
        Uri.parse("${MyConfig.servername}/memberlink/api/register_user.php"),
        body: {
          'action': 'register_user',
          'title': title,
          'first_name': firstName,
          'last_name': lastName,
          'phone': phone,
          'address': address,
          'email': email,
          'password': password,
        },
      );

      setState(() {
        isLoading = false;
      });

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(data['message'])));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Server error: ${response.statusCode}")),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error registering user")));
    }
  }
}
