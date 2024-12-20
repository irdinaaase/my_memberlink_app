// ignore_for_file: prefer_typing_uninitialized_variables, avoid_print, use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_memberlink_app/model/news.dart';
import 'package:my_memberlink_app/myconfig.dart';
import 'package:my_memberlink_app/views/newsletter/edit_news.dart';
import 'package:my_memberlink_app/views/shared/mydrawer.dart';
import 'package:my_memberlink_app/views/newsletter/new_news.dart';
import 'package:http/http.dart' as http;

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<News> newsList = [];
  final df = DateFormat('dd/MM/yyyy hh:mm a');
  int numofpage = 1;
  int curpage = 1;
  int numofresult = 0;
  late double screenWidth, screenHeight;
  var color;

  @override
  void initState() {
    super.initState();
    loadNewsData();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "The Daily Prophet",
          style: TextStyle(
            fontFamily: 'HarryPotter', // Custom Harry Potter font
            fontSize: 24,
            color: Colors.yellow,
          ),
        ),
        backgroundColor: Colors.brown[800], // House Gryffindor theme
        actions: [
          IconButton(
              onPressed: () {
                loadNewsData();
              },
              icon: const Icon(Icons.refresh, color: Colors.yellow))
        ],
      ),
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    "assets/images/hogwarts_castle.jpg"), // Background image
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Foreground Content
          newsList.isEmpty
              ? Center(
                  child: Text(
                    "Awaiting magical scrolls...",
                    style: TextStyle(
                      fontFamily: 'HarryPotter',
                      fontSize: 18,
                      color: Colors.brown[800],
                    ),
                  ),
                )
              : Column(
                  children: [
                    Container(
                      alignment: Alignment.center,
                      margin: const EdgeInsets.all(8),
                      child: Text(
                        "Page: $curpage | Total Articles: $numofresult",
                        style: const TextStyle(
                          fontFamily: 'Serif',
                          fontSize: 16,
                          color: Color.fromARGB(137, 240, 234, 234),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: newsList.length,
                        itemBuilder: (context, index) {
                          return Card(
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                  color: Colors.brown.shade700, width: 2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            color: (Colors.yellow[50] ?? Colors.yellow)
                                .withOpacity(0.9),
                            elevation: 5,
                            child: ListTile(
                              onLongPress: () {
                                deleteDialog(index);
                              },
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    truncateString(
                                        newsList[index].newsTitle.toString(),
                                        30),
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.brown),
                                  ),
                                  Text(
                                    df.format(DateTime.parse(
                                        newsList[index].newsDate.toString())),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Text(
                                truncateString(
                                    newsList[index].newsDetails.toString(),
                                    100),
                                textAlign: TextAlign.justify,
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.forward_to_inbox,
                                  color: Colors.brown,
                                ),
                                onPressed: () {
                                  showNewsDetailsDialog(index);
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    // Pagination Buttons
                    SizedBox(
                      height: screenHeight * 0.05,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: numofpage,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          if ((curpage - 1) == index) {
                            color = Colors.yellow[700];
                          } else {
                            color = Colors.brown[400];
                          }
                          return TextButton(
                            onPressed: () {
                              curpage = index + 1;
                              loadNewsData();
                            },
                            child: Text(
                              (index + 1).toString(),
                              style: TextStyle(
                                fontFamily: 'HarryPotter',
                                color: color,
                                fontSize: 18,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
        ],
      ),
      drawer: const MyDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(context,
              MaterialPageRoute(builder: (content) => const NewNewsScreen()));
          loadNewsData();
        },
        backgroundColor: Colors.brown,
        child: const Icon(Icons.add, color: Colors.yellow),
      ),
    );
  }

  String truncateString(String str, int length) {
    if (str.length > length) {
      str = str.substring(0, length);
      return "$str...";
    } else {
      return str;
    }
  }

  void loadNewsData() {
    http
        .get(Uri.parse(
            "${MyConfig.servername}/my_memberlink_app/api/load_news.php?pageno=$curpage"))
        .then((response) {
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['status'] == "success") {
          var result = data['data']['news'];
          newsList.clear();
          for (var item in result) {
            News news = News.fromJson(item);
            newsList.add(news);
          }
          numofpage = int.parse(data['numofpage'].toString());
          numofresult = int.parse(data['numberofresult'].toString());
          setState(() {});
        }
      } else {
        print("Error - The magic failed to load.");
      }
    });
  }

  void showNewsDetailsDialog(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(newsList[index].newsTitle.toString()),
          content: Text(
            newsList[index].newsDetails.toString(),
            textAlign: TextAlign.justify,
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                News news = newsList[index];
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (content) => EditNewsScreen(news: news)));
                loadNewsData();
              },
              child: const Text("Edit"),
            ),
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Close"))
          ],
        );
      },
    );
  }

  void deleteDialog(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "Delete \"${truncateString(newsList[index].newsTitle.toString(), 20)}\"?",
            style: const TextStyle(fontSize: 18, color: Colors.red),
          ),
          content: const Text(
              "Are you sure you want to erase this news from history?"),
          actions: [
            TextButton(
              onPressed: () {
                deleteNews(index);
                Navigator.pop(context);
              },
              child: const Text("Yes (Expelliarmus)"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("No (Protego)"),
            )
          ],
        );
      },
    );
  }

  void deleteNews(int index) {
    http.post(
        Uri.parse(
            "${MyConfig.servername}/my_memberlink_app/api/delete_news.php"),
        body: {"newsid": newsList[index].newsId.toString()}).then((response) {
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['status'] == "success") {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("News erased from history."),
            backgroundColor: Colors.green,
          ));
          loadNewsData();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Failed to cast the spell."),
            backgroundColor: Colors.red,
          ));
        }
      }
    });
  }
}
