import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:my_memberlink_app/model/news.dart';
import 'package:http/http.dart' as http;
import 'package:my_memberlink_app/myconfig.dart';

class EditNewsScreen extends StatefulWidget {
  final News news;
  const EditNewsScreen({super.key, required this.news});

  @override
  State<EditNewsScreen> createState() => _EditNewsState();
}

class _EditNewsState extends State<EditNewsScreen> {
  TextEditingController titleController = TextEditingController();
  TextEditingController detailsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    titleController.text = widget.news.newsTitle.toString();
    detailsController.text = widget.news.newsDetails.toString();
  }

  late double screenWidth, screenHeight;

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Edit Scroll",
          style: TextStyle(
            fontFamily: 'HarryPotter',
            fontSize: 22,
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
          // Content on top of the image
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text(
                    "Modify Your Scroll",
                    style: TextStyle(
                      fontFamily: 'HarryPotter',
                      fontSize: 20,
                      color: Colors.yellow,
                      shadows: [
                        Shadow(
                          offset: Offset(2, 2),
                          blurRadius: 4,
                          color: Colors.black,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: "Modify Your Scroll Title",
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
                  const SizedBox(height: 20),
                  TextField(
                    controller: detailsController,
                    decoration: InputDecoration(
                      labelText: "Refine Your Magical Thoughts",
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
                    maxLines: screenHeight ~/ 35,
                  ),
                  const SizedBox(height: 20),
                  MaterialButton(
                    elevation: 10,
                    onPressed: onUpdateNewsDialog,
                    minWidth: screenWidth,
                    height: 50,
                    color: Colors.brown[800],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Text(
                      "Update Enchantment",
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
          ),
        ],
      ),
    );
  }

  void onUpdateNewsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "Charm Your Scroll?",
            style: TextStyle(
              fontFamily: 'Serif',
              fontSize: 18,
              color: Colors.brown,
            ),
          ),
          content: const Text(
            "Do you wish to enchant this scroll for all?",
            style: TextStyle(fontFamily: 'Serif', fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                updateNews();
                Navigator.pop(context);
              },
              child: const Text(
                "Yes (Alohomora)",
                style: TextStyle(color: Colors.green),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                "No (Nox)",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void updateNews() {
    String title = titleController.text.toString();
    String details = detailsController.text.toString();

    http.post(
      Uri.parse("${MyConfig.servername}/my_memberlink_app/api/update_news.php"),
      body: {
        "newsid": widget.news.newsId.toString(),
        "title": title,
        "details": details,
      },
    ).then((response) {
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['status'] == "success") {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Scroll Updated Successfully!"),
            backgroundColor: Colors.green,
          ));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Failed to Update the Scroll!"),
            backgroundColor: Colors.red,
          ));
        }
      }
    });
  }
}
