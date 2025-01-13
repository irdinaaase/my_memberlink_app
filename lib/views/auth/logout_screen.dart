import 'package:flutter/material.dart';
import 'package:my_memberlink_app/model/user.dart';
import 'package:my_memberlink_app/views/auth/login_screen.dart';

class LogoutScreen extends StatefulWidget {
  final User userdata;
  const LogoutScreen({super.key, required this.userdata});

  @override
  State<LogoutScreen> createState() => _LogoutScreenState();
}

class _LogoutScreenState extends State<LogoutScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Logout'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            bool? confirmed = await showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text("Are you sure you want to log out?"),
                  content: Text(
                    "Bye  ${widget.userdata.title} ${widget.userdata.lastName}, See you again!",
                    style: TextStyle(fontSize: 18, color: Colors.brown),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context, true); // User confirmed logout
                      },
                      child: Text("Yes"),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context, false); // User canceled logout
                      },
                      child: Text("No"),
                    ),
                  ],
                );
              },
            );
            if (confirmed ?? false) {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()));
            }
          },
          child: Text('Logout'),
        ),
      ),
    );
  }
}
