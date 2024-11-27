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
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController firstnameController = TextEditingController();
  TextEditingController lastnameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController otpController = TextEditingController();

  bool isOTPSent = false;
  bool passwordVisible = true;
  bool isLoading = false;
  String? selectedTitle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image with a gradient overlay
          Container(
            decoration: BoxDecoration(
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
                                offset: Offset(3, 3),
                                blurRadius: 8,
                                color: Colors.black.withOpacity(0.7),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildDropdownField(),
                        const SizedBox(height: 10),
                        _buildTextField(firstnameController, "First Name"),
                        const SizedBox(height: 10),
                        _buildTextField(lastnameController, "Last Name"),
                        const SizedBox(height: 10),
                        _buildTextField(phoneController, "Phone Number", keyboardType: TextInputType.phone),
                        const SizedBox(height: 10),
                        _buildTextField(addressController, "Address", keyboardType: TextInputType.streetAddress),
                        const SizedBox(height: 10),
                        _buildTextField(emailController, "Your Email", keyboardType: TextInputType.emailAddress),
                        const SizedBox(height: 10),
                        _buildPasswordField(),
                        if (isOTPSent) ...[
                          const SizedBox(height: 10),
                          _buildTextField(otpController, "Enter OTP", keyboardType: TextInputType.number),
                        ],
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
        prefixIcon: Icon(Icons.person, color: Colors.amber[200]),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hintText, {TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.black.withOpacity(0.5),
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey[400]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
        prefixIcon: Icon(Icons.text_fields, color: Colors.amber[200]),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      obscureText: passwordVisible,
      controller: passwordController,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.black.withOpacity(0.5),
        hintText: "Your Password",
        hintStyle: TextStyle(color: Colors.grey[400]),
        border: OutlineInputBorder(
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
      onPressed: isOTPSent ? verifyOTPAndRegister : sendOTP,
      minWidth: double.infinity,
      height: 50,
      color: Colors.deepPurple[800],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Text(
        isOTPSent ? "Verify & Register" : "Send OTP",
        style: const TextStyle(color: Colors.white, fontSize: 18),
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

  void sendOTP() async {
    String email = emailController.text;

    if (email.isEmpty || !isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Enter a valid email"),
        backgroundColor: Colors.red,
      ));
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse("${MyConfig.servername}/my_memberlink_app/api/otp_verifications.php"),
        body: {
          'action': 'send_otp',
          'email': email,
        },
      );

      setState(() {
        isLoading = false;
      });

      var data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        setState(() {
          isOTPSent = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("OTP sent to your email")));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['data'])));
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error sending OTP")));
    }
  }

  void verifyOTPAndRegister() async {
    String otp = otpController.text;
    String email = emailController.text;

    if (otp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Enter OTP"),
        backgroundColor: Colors.red,
      ));
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse("${MyConfig.servername}/my_memberlink_app/api/otp_verifications.php"),
        body: {
          'action': 'verify_otp',
          'email': email,
          'otp': otp,
        },
      );

      setState(() {
        isLoading = false;
      });

      var data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        userRegistration();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['data'])));
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error verifying OTP")));
    }
  }

  void userRegistration() async {
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
        Uri.parse("${MyConfig.servername}/my_memberlink_app/api/users.php"),
        body: {
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

      var data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['data'])));
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error registering user")));
    }
  }

  bool isValidEmail(String email) {
    return RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(email);
  }
}
