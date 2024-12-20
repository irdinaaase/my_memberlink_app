// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:my_memberlink_app/views/auth/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 6), () {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const LoginScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity, // Ensures the container takes full width
        height: double.infinity, // Ensures the container takes full height
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                'assets/images/sky.jpg'), // Ensure the path is correct
            fit: BoxFit.cover, // Make the image cover the full screen
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.3), // Adjust opacity as needed
              BlendMode.darken,
            ),
          ),
        ),
        child: Stack(
          alignment: Alignment.center, // Centers everything in the stack
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset(
                  'assets/animations/quidditch.json', // Ensure this exists
                  width: 250,
                  height: 250,
                  repeat: true,
                ),
                const SizedBox(height: 20),
                Text(
                  "Welcome to Memberlink Newsletter 📩",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.08,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber[200],
                    fontFamily: 'Cinzel',
                    shadows: const [
                      Shadow(
                        offset: Offset(3, 3),
                        blurRadius: 10,
                        color: Colors.amberAccent,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Bringing You Magical Updates Daily!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.045,
                    color: Colors.grey[300],
                    fontFamily: 'Quicksand',
                  ),
                ),
                const SizedBox(height: 30),
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.amber[200]!),
                  strokeWidth: 3,
                ),
                const SizedBox(height: 20),
                Text(
                  "✍️ Owls are fetching the latest updates for you...",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.04,
                    color: Colors.grey[400],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
