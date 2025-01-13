import 'package:flutter/material.dart';
import 'package:my_memberlink_app/model/user.dart';
import 'package:my_memberlink_app/views/products/product_screen.dart';
import 'package:my_memberlink_app/views/events/event_screen.dart';
import 'package:my_memberlink_app/views/newsletter/news_screen.dart';
import 'package:my_memberlink_app/views/auth/logout_screen.dart';

class MyDrawer extends StatelessWidget {
  final User userdata; // Accept userdata as a parameter

  // Constructor to accept userdata
  const MyDrawer({super.key, required this.userdata});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/paper.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: ListView(
          children: [
            _buildUserHeader(),
            _createDrawerItem(
              context: context,
              text: "Newsletter",
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  _customPageRoute(MainScreen(userdata: userdata)),
                );
              },
            ),
            _createDrawerItem(
              context: context,
              text: "Events",
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  _customPageRoute(EventScreen(userdata: userdata)),
                );
              },
            ),
            _createDrawerItem(
              context: context,
              text: "Members",
              onTap: () {},
            ),
            _createDrawerItem(
              context: context,
              text: "Payments",
              onTap: () {},
            ),
            _createDrawerItem(
              context: context,
              text: "Products",
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  _customPageRoute(ProductScreen(userdata: userdata)),
                );
              },
            ),
            _createDrawerItem(
              context: context,
              text: "Vetting",
              onTap: () {},
            ),
            _createDrawerItem(
              context: context,
              text: "Settings",
              onTap: () {},
            ),
            _createDrawerItem(
              context: context,
              text: "Logout",
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  _customPageRoute(LogoutScreen(userdata: userdata)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserHeader() {
    return UserAccountsDrawerHeader(
      accountName: Text(
        "${userdata.title} ${userdata.lastName}", // Use userdata values
        style: const TextStyle(
          fontFamily: "MagicSchoolOne",
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      accountEmail: Text(
        userdata.email ??
            "", // Use userdata.email, with a fallback if it's null
        style: const TextStyle(
          fontFamily: "MagicSchoolOne",
          fontSize: 16,
          color: Colors.white,
        ),
      ),
      currentAccountPicture: CircleAvatar(
        backgroundImage: AssetImage(userdata.profileImage ??
            "assets/images/avatar.png"), // Fallback image if not set
      ),
      decoration: const BoxDecoration(
        color: Colors.brown,
        borderRadius: BorderRadius.vertical(top: Radius.circular(0.0)),
      ),
    );
  }

  PageRouteBuilder _customPageRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(position: offsetAnimation, child: child);
      },
    );
  }

  Widget _createDrawerItem(
      {required BuildContext context,
      required String text,
      required GestureTapCallback onTap}) {
    return ListTile(
      title: Text(
        text,
        style: const TextStyle(
          fontFamily: "MagicSchoolOne",
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.brown,
        ),
      ),
      onTap: onTap,
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.brown),
    );
  }
}
