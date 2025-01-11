import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_memberlink_app/model/membership.dart';
import 'package:my_memberlink_app/myconfig.dart';
import 'package:my_memberlink_app/views/membership/membership_details.dart';

class MembershipScreen extends StatefulWidget {
  const MembershipScreen({super.key});

  @override
  State<MembershipScreen> createState() => _MembershipScreenState();
}

class _MembershipScreenState extends State<MembershipScreen> {
  List<Membership> membershipList = [];
  late double screenHeight, screenWidth;
  String status = "Loading...";

  @override
  void initState() {
    super.initState();
    loadMemberships();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Membership Plans"),
        backgroundColor: Colors.brown[800],
      ),
      body: membershipList.isEmpty
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
              itemCount: membershipList.length,
              itemBuilder: (context, index) {
                return buildMembershipCard(membershipList[index]);
              },
            ),
    );
  }

  Widget buildMembershipCard(Membership membership) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.brown.shade800, width: 2),
      ),
      child: InkWell(
        onTap: () => navigateToDetails(membership),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                membership.membershipsName ?? "Unknown",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: "MagicSchoolOne",
                ),
              ),
              const SizedBox(height: 8),
              Text(
                membership.membershipsDescription ?? "",
                style: const TextStyle(fontSize: 16),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "RM ${membership.membershipsPrice?.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  Text(
                    membership.membershipsDuration ?? "",
                    style: const TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void navigateToDetails(Membership membership) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MembershipDetailsScreen(membership: membership),
      ),
    );
  }

  Future<void> loadMemberships() async {
    try {
      final url = Uri.parse(
        "${MyConfig.servername}/memberlink/api/load_memberships.php",
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
            membershipList = (jsonData['data']['memberships'] as List)
                .map((item) => Membership.fromJson(item))
                .toList();
            status = membershipList.isEmpty ? "No memberships available" : "";
          });
        } else {
          setState(
              () => status = jsonData['message'] ?? "No memberships available");
        }
      } else {
        setState(() => status = "Server error: ${response.statusCode}");
      }
    } catch (e) {
      setState(() => status = "Error: $e");
      debugPrint("Error loading memberships: $e");
    }
  }
}
