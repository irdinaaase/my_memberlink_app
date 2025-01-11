// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
//import 'package:my_memberlink_app/views/shares/home_screen.dart';
//import 'package:my_memberlink_app/views/products/product_screen.dart';
import 'package:my_memberlink_app/views/membership/membership_screen.dart';



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
          MaterialPageRoute(builder: (context) => const MembershipScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     
      //Sky background image
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/sky.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.3),
              BlendMode.darken,
            ),
          ),
        ),

        // Stack to overlay the quidditch animation and text
        child: Stack(
          alignment: Alignment.center, // Aligns the children to the center
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,

              //Quidditch animation
              children: [
                SizedBox(
                  height: 100,
                  child: Lottie.asset(
                    'assets/animations/quidditch.json', // Ensure this exists
                    width: 300, //how large the animation should be
                    height: 300,
                    repeat: true,
                  ),
                ),

                //Welcome to Memberlink Newsletter 📩
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0), // Adjust the padding value as needed
                  child: Column(
                    children: [
                      Text(
                        "Welcome to Memberlink Newsletter 📩",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * 0.07,
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

                      //Bringing You Magical Updates Daily!
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

                      //✍️ Owls are fetching the latest updates for you...
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
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}