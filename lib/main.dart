import 'package:flutter/material.dart';
import 'views/shares/splash_screen.dart';
import 'package:my_memberlink_app/model/user.dart';

void main() {
    WidgetsFlutterBinding.ensureInitialized();
  runApp(MainApp(userdata: User()));
}
 
class MainApp extends StatelessWidget {
  final User userdata;
  const MainApp({super.key, required this.userdata});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}