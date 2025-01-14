import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_memberlink_app/myconfig.dart';
import 'package:my_memberlink_app/model/membership.dart';
import 'package:my_memberlink_app/model/user.dart';
import 'package:my_memberlink_app/views/shares/mydrawer.dart';
import 'package:my_memberlink_app/views/membership/membership_history.dart';
import 'package:my_memberlink_app/views/membership/purchase_membership.dart';

class MembershipScreen extends StatefulWidget {
  final User userdata;

  const MembershipScreen({super.key, required this.userdata});

  @override
  State<MembershipScreen> createState() => _MembershipScreenState();
}

class _MembershipScreenState extends State<MembershipScreen> {
  List<Membership> membershipList = [];
  String status = "Loading...";
  Membership? selectedMembership;
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    loadMemberships();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    setState(() {
      _scrollOffset = _scrollController.offset;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70, // Adjust the height as needed
        centerTitle: true,
        flexibleSpace: Center(
          child: Padding(
            padding: const EdgeInsets.only(
                top: 20), // Adjust the top padding as needed
            child: ClipOval(
              child: Image.asset(
                'assets/icons/head.png', // Replace with your image path
                height: 60, // Set the desired height
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        backgroundColor: Colors.brown[800],
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.amber),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      MembershipHistoryScreen(userdata: widget.userdata),
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/images/hogwarts_castle.jpg",
              fit: BoxFit.cover,
            ),
          ),
          membershipList.isEmpty
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
              : Column(
                  children: [
                    Expanded(child: _buildHorizontalMembershipScroll()),
                    _buildPageIndicator(),
                  ],
                ),
        ],
      ),
      drawer: MyDrawer(userdata: widget.userdata),
    );
  }

  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildHorizontalMembershipScroll() {
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) {
        if (scrollNotification is ScrollUpdateNotification) {
          _onScroll();
        }
        return true;
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          itemCount: membershipList.length,
          itemBuilder: (context, index) {
            double scale = 1.0;
            if (_scrollController.position.haveDimensions) {
              double pageOffset = _scrollController.offset / 340;
              scale = 1 - (pageOffset - index).abs() * 0.3;
              if (scale < 0.8) scale = 0.8;
            }
            return Transform.scale(
              scale: scale,
              child: _buildMembershipCard(membershipList[index], index),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMembershipCard(Membership membership, int index) {
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                Text(
                  membership.membershipsName ?? "Unknown",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Cinzel",
                    color: Colors.amber,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                // Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    "assets/membership_images/membership_${membership.membershipsId}.jpg",
                    fit: BoxFit.cover,
                    height: 150,
                    width: double.infinity,
                  ),
                ),
                const SizedBox(height: 16),

                // Price
                Text(
                  "PRICE: RM${membership.membershipsPrice?.toStringAsFixed(2) ?? "0.00"}",
                  style: const TextStyle(
                    fontFamily: "Cinzel",
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 5),

                // Info Sections
                Text(
                  "📜 Description: \n${membership.membershipsDescription ?? "No description available."}",
                  style: const TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 5),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "\n🕛 Duration: ${membership.membershipsDuration ?? "Information not available"}",
                    style: const TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: Colors.white70,
                    ),
                  ),
                ),
                const SizedBox(height: 5),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "\n🌟 Benefits: \n${membership.membershipsBenefits ?? "Information not available"}",
                    style: const TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: Colors.white70,
                    ),
                  ),
                ),
                const SizedBox(height: 5),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "\n🗓️ Terms: \n${membership.membershipsTerms ?? "Information not available"}",
                    style: const TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: Colors.white70,
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Purchase Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => _showPurchaseDialog(membership),
                  child: const Text(
                    "Purchase Membership",
                    style: TextStyle(color: Colors.white), // Change the text color here
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPurchaseDialog(Membership membership) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            "Confirm Purchase",
            style: TextStyle(
              fontFamily: "Cinzel",
              fontWeight: FontWeight.bold,
              color: Colors.brown,
            ),
          ),
          content: const Text(
            "Are you sure you want to buy this plan?",
            style: TextStyle(
              fontFamily: "Cinzel",
              color: Colors.black87,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                "No",
                style: TextStyle(
                  fontFamily: "Cinzel",
                  color: Colors.red,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                navigateToPurchase(membership);
              },
              child: const Text(
                "Yes",
                style: TextStyle(
                  fontFamily: "Cinzel",
                  color: Colors.green,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget buildInfoSection(String title, String? content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.amber,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          content ?? "Information not available",
          style: const TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  void navigateToPurchase(Membership membership) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PurchaseMembershipScreen(
          membership: membership,
          userdata: widget.userdata,
        ),
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
    }
  }

  Widget _buildPageIndicator() {
    return Container(
      height: 4,
      margin: const EdgeInsets.only(top: 8, bottom: 16),
      alignment: Alignment.center,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        itemCount: membershipList.length,
        itemBuilder: (context, index) {
          double opacity = 1.0;
          if (_scrollController.position.haveDimensions) {
            double pageOffset = _scrollController.offset / 340;
            opacity = 1 - (pageOffset - index).abs() * 0.5;
            if (opacity < 0.3) opacity = 0.3;
          }
          return Container(
            width: 20,
            height: 4,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            color: Colors.amber.withOpacity(opacity),
          );
        },
      ),
    );
  }
}
