import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_memberlink_app/model/user.dart';
import 'package:my_memberlink_app/myconfig.dart';
import 'package:my_memberlink_app/views/membership/membership_screen.dart';

class MembershipHistoryScreen extends StatefulWidget {
  final User userdata;

  const MembershipHistoryScreen({super.key, required this.userdata});

  @override
  State<MembershipHistoryScreen> createState() =>
      _MembershipHistoryScreenState();
}

class _MembershipHistoryScreenState extends State<MembershipHistoryScreen> {
  List<dynamic> historyList = [];
  String status = "Loading...";
  late double screenWidth, screenHeight;
  var color;

  @override
  void initState() {
    super.initState();
    loadMembershipHistory();
  }

  Future<void> loadMembershipHistory() async {
    try {
      final url = Uri.parse(
        "${MyConfig.servername}/memberlink/api/load_memberships_history.php?users_id=${widget.userdata.id}",
      );

      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
      );

      debugPrint("Response status: ${response.statusCode}");
      debugPrint("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        debugPrint("Parsed JSON: $jsonData");
        if (jsonData['status'] == 'success') {
          setState(() {
            historyList = jsonData['data']['history'];
            status =
                historyList.isEmpty ? "No subscription history available" : "";
          });
        } else {
          setState(() {
            historyList = [];
            status = jsonData['message'] ?? "No subscription history available";
          });
        }
      } else if (response.statusCode == 404) {
        setState(() => status = "Error 404: Resource not found");
      } else {
        setState(() => status = "Server error: ${response.statusCode}");
      }
    } catch (e) {
      setState(() => status = "Error: $e");
      debugPrint("Error loading membership history: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      MembershipScreen(userdata: widget.userdata)),
            );
          },
        ),
        toolbarHeight: 70,
        centerTitle: true,
        flexibleSpace: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: ClipOval(
              child: Image.asset(
                'assets/icons/head.png',
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        backgroundColor: Colors.brown[800],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/images/hogwarts_castle.jpg",
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              Expanded(
                child: historyList.isEmpty
                    ? Center(
                        child: Text(
                          status,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: "MagicSchoolOne",
                            color: Colors.amber,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: historyList.length,
                        itemBuilder: (context, index) {
                          return buildHistoryCard(historyList[index]);
                        },
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildHistoryCard(dynamic history) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
      width: 350,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.amber, width: 2),
        ),
        elevation: 8,
        color: Colors.black.withOpacity(0.8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Membership Name: ${history['memberships_name']}",
                style: const TextStyle(
                  fontFamily: 'Cinzel',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Payment ID: ${history['payments_billplz_id']}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Amount: RM ${history['payments_amount']}",
                style: const TextStyle(fontSize: 16, color: Colors.white70),
              ),
              const SizedBox(height: 8),
              Text(
                "Status: ${history['payments_status']}",
                style: TextStyle(
                  fontSize: 16,
                  color: history['payments_status'].toString().toLowerCase() == 'success' ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Date: ${history['payments_date']}",
                style: const TextStyle(fontSize: 16, color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
