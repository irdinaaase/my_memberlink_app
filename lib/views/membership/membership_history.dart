import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_memberlink_app/model/user.dart';
import 'package:my_memberlink_app/myconfig.dart';

class MembershipHistoryScreen extends StatefulWidget {
  final User userdata;

  const MembershipHistoryScreen({super.key, required this.userdata});

  @override
  State<MembershipHistoryScreen> createState() => _MembershipHistoryScreenState();
}

class _MembershipHistoryScreenState extends State<MembershipHistoryScreen> {
  List<dynamic> historyList = [];
  String status = "Loading...";

  @override
  void initState() {
    super.initState();
    loadMembershipHistory();
  }

  Future<void> loadMembershipHistory() async {
    try {
      final url = Uri.parse(
        "${MyConfig.servername}/memberlink/api/load_memberships.php?users_id=${widget.userdata.id}",
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
        if (jsonData['status'] == 'success') {
          setState(() {
            historyList = jsonData['data']['history'] ?? [];
            status = historyList.isEmpty ? "No membership history available" : "";
          });
        } else {
          setState(() => status = jsonData['message'] ?? "No membership history available");
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Membership History"),
        backgroundColor: Colors.brown[800],
      ),
      body: historyList.isEmpty
          ? Center(
              child: Text(
                status,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
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
    );
  }

  Widget buildHistoryCard(dynamic history) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.brown.shade800, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Payment ID: ${history['payments_id']}",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Amount: RM ${history['payments_amount']}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              "Status: ${history['payments_status']}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              "Date: ${history['payments_date']}",
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
