import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_memberlink_app/myconfig.dart';

class NewNewsScreen extends StatefulWidget {
  const NewNewsScreen({super.key});

  @override
  State<NewNewsScreen> createState() => _NewNewsScreenState();
}

class _NewNewsScreenState extends State<NewNewsScreen> {
  TextEditingController titleController = TextEditingController();
  TextEditingController detailsController = TextEditingController();

  late double screenWidth, screenHeight;

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "The Hogwarts Quill",
          style: TextStyle(
            fontFamily: 'HarryPotter',
            fontSize: 24,
            color: Colors.yellow,
          ),
        ),
        backgroundColor: Colors.brown[800],
      ),
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/hogwarts_castle.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Foreground Content
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text(
                  "Create a Magical Newsletter",
                  style: TextStyle(
                    fontFamily: 'Cinzel',
                    fontSize: 22,
                    color: Color.fromARGB(255, 243, 242, 242),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: "Enter Your Scroll Title",
                    labelStyle: const TextStyle(
                      fontFamily: 'Serif',
                      color: Colors.brown,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Colors.brown.shade700),
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: detailsController,
                  decoration: InputDecoration(
                    labelText: "Detail Your Magical Thoughts",
                    labelStyle: const TextStyle(
                      fontFamily: 'Serif',
                      color: Colors.brown,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Colors.brown.shade700),
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.8),
                  ),
                  maxLines: 15,
                ),
                const SizedBox(height: 20),
                MaterialButton(
                  elevation: 10,
                  onPressed: onInsertNewsDialog,
                  minWidth: screenWidth,
                  height: 50,
                  color: Colors.brown[800],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Text(
                    "Publish Scroll",
                    style: TextStyle(
                      fontFamily: 'HarryPotter',
                      fontSize: 18,
                      color: Colors.yellow,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void onInsertNewsDialog() {
    if (titleController.text.isEmpty || detailsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Complete the scroll before publishing!"),
        backgroundColor: Colors.red,
      ));
      return;
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
          ),
          title: const Text(
            "Publish Magical Scroll?",
            style: TextStyle(
              fontFamily: 'Serif',
              fontSize: 18,
              color: Colors.brown,
            ),
          ),
          content: const Text(
            "Do you wish to enchant this scroll for everyone?",
            style: TextStyle(fontFamily: 'Serif', fontSize: 16),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                "Yes (Wingardium Leviosa)",
                style: TextStyle(color: Colors.green),
              ),
              onPressed: () {
                insertNews();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                "No (Nox)",
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void insertNews() {
    String title = titleController.text;
    String details = detailsController.text;
    http.post(
      Uri.parse("${MyConfig.servername}/my_memberlink_app/api/insert_news.php"),
      body: {"title": title, "details": details},
    ).then((response) {
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['status'] == "success") {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Scroll Published Successfully!"),
            backgroundColor: Colors.green,
          ));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Failed to Publish the Scroll!"),
            backgroundColor: Colors.red,
          ));
        }
      }
    });
  }
}
