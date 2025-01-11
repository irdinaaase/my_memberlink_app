import 'package:flutter/material.dart';
import 'package:my_memberlink_app/model/membership.dart';
import 'package:my_memberlink_app/views/membership/purchase_membership.dart';
// import 'package:my_memberlink_app/myconfig.dart';

class MembershipDetailsScreen extends StatelessWidget {
  final Membership membership;

  const MembershipDetailsScreen({super.key, required this.membership});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(membership.membershipsName ?? "Membership Details"),
        backgroundColor: Colors.brown[800],
      ),
      body: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/hogwarts_castle.jpg"),
              fit: BoxFit.cover,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              elevation: 8,
              color: Colors.white.withOpacity(0.9),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      membership.membershipsName ?? "",
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        fontFamily: "MagicSchoolOne",
                      ),
                    ),
                    const SizedBox(height: 16),
                    buildInfoSection("Description", membership.membershipsDescription),
                    buildInfoSection("Duration", membership.membershipsDuration),
                    buildInfoSection("Benefits", membership.membershipsBenefits),
                    buildInfoSection("Terms", membership.membershipsTerms),
                    const SizedBox(height: 24),
                    Center(
                      child: Text(
                        "RM ${membership.membershipsPrice?.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => navigateToPurchase(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown[800],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "Purchase Membership",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildInfoSection(String title, String? content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.brown,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content ?? "Not available",
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  void navigateToPurchase(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PurchaseMembershipScreen(membership: membership),
      ),
    );
  }
} 