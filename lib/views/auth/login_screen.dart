// ignore_for_file: use_build_context_synchronously, prefer_const_constructors

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:my_memberlink_app/myconfig.dart';
import 'package:my_memberlink_app/views/auth/register_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_memberlink_app/views/newsletter/news_screen.dart';

import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailcontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();
  bool rememberme = false;
  bool passwordVisible = true; // Password visibility state

  @override
  void initState() {
    super.initState();
    loadPref();
  }

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
                          'Portal to Entry',
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
                        // Email input field
                        TextField(
                          controller: emailcontroller,
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.black.withOpacity(0.5),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                            ),
                            hintText: "Your Email",
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            prefixIcon:
                                Icon(Icons.email, color: Colors.amber[200]),
                          ),
                        ),
                        const SizedBox(height: 15),
                        // Password input field
                        TextField(
                          obscureText: passwordVisible,
                          controller: passwordcontroller,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.black.withOpacity(0.5),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                            ),
                            hintText: "Your Password",
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            prefixIcon:
                                Icon(Icons.lock, color: Colors.amber[200]),
                            suffixIcon: IconButton(
                              icon: Icon(
                                passwordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                setState(() {
                                  passwordVisible = !passwordVisible;
                                });
                              },
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            const Text(
                              "Remember me",
                              style: TextStyle(color: Colors.white),
                            ),
                            Checkbox(
                              value: rememberme,
                              onChanged: (bool? value) {
                                setState(() {
                                  handleRememberMe(value!);
                                });
                              },
                              activeColor: Colors.amber,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Login button with a magical glow
                        MaterialButton(
                          elevation: 10,
                          onPressed: onLogin,
                          minWidth: double.infinity,
                          height: 50,
                          color: Colors.deepPurple[800],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Text(
                            "Login",
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ),
                        const SizedBox(height: 20),
                        GestureDetector(
                          child: const Text(
                            "Forgot Password?",
                            style: TextStyle(
                                color: Colors.white,
                                decoration: TextDecoration.underline),
                          ),
                        ),
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (content) => const RegisterScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            "Create new account?",
                            style: TextStyle(
                                color: Colors.white,
                                decoration: TextDecoration.underline),
                          ),
                        ),
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

  void onLogin() {
    String email = emailcontroller.text;
    String password = passwordcontroller.text;
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Please enter email and password"),
      ));
      return;
    }
    http.post(
  Uri.parse("${MyConfig.servername}/my_memberlink_app/api/login_user.php"),
  body: {"email": email, "password": password},
).then((response) {
  print("Response Body: ${response.body}"); // Debugging line
  print("Response Status Code: ${response.statusCode}");
  if (response.statusCode == 200) {
    try {
      var data = jsonDecode(response.body); // Fails if response isn't JSON
      if (data['status'] == "success") {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Entry Success"),
          backgroundColor: Colors.green,
        ));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (content) => const MainScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Entry Failed"),
          backgroundColor: Colors.red,
        ));
      }
    } catch (e) {
      print("JSON Decode Error: $e"); // Log the exception
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Invalid server response"),
        backgroundColor: Colors.red,
      ));
    }
  }
});

  }

  Future<void> handleRememberMe(bool value) async {
    String email = emailcontroller.text;
    String pass = passwordcontroller.text;
    if (value) {
      if (email.isNotEmpty && pass.isNotEmpty) {
        await storeSharedPrefs(value, email, pass);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please enter your credentials"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    } else {
      await storeSharedPrefs(false, "", "");
    }
    rememberme = value;
  }

  Future<void> storeSharedPrefs(bool value, String email, String pass) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (value) {
      prefs.setString("email", email);
      prefs.setString("password", pass);
      prefs.setBool("rememberme", value);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Preferences Stored"),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 1),
      ));
    } else {
      prefs.remove("email");
      prefs.remove("password");
      prefs.setBool("rememberme", value);
      emailcontroller.clear();
      passwordcontroller.clear();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Preferences Removed"),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 1),
      ));
    }
    setState(() {});
  }

  Future<void> loadPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    emailcontroller.text = prefs.getString("email") ?? "";
    passwordcontroller.text = prefs.getString("password") ?? "";
    rememberme = prefs.getBool("rememberme") ?? false;
    setState(() {});
  }
}
