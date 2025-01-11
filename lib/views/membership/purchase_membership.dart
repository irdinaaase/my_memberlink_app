import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:my_memberlink_app/model/membership.dart';
import 'package:my_memberlink_app/myconfig.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PurchaseMembershipScreen extends StatefulWidget {
  final Membership membership;

  const PurchaseMembershipScreen({super.key, required this.membership});

  @override
  State<PurchaseMembershipScreen> createState() =>
      _PurchaseMembershipScreenState();
}

class _PurchaseMembershipScreenState extends State<PurchaseMembershipScreen> {
  bool isProcessing = false;
  String? userId;
  late double screenHeight, screenWidth;

  @override
  void initState() {
    super.initState();
    loadUserId();
  }

  Future<void> loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('user_id');
    });
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Purchase Membership"),
        backgroundColor: Colors.brown[800],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/hogwarts_castle.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Card(
            elevation: 8,
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.membership.membershipsName ?? "Membership",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: "MagicSchoolOne",
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Price: RM ${widget.membership.membershipsPrice?.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isProcessing ? null : processPayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown[800],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: isProcessing
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "Proceed to Payment",
                              style: TextStyle(fontSize: 18),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> processPayment() async {
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please login to purchase membership")),
      );
      return;
    }

    setState(() => isProcessing = true);

    try {
      final url =
          Uri.parse("${MyConfig.servername}/memberlink/api/create_bill.php");

      // Prepare the request body
      final response = await http
          .post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId.toString(),
          'memberships_id': widget.membership.membershipsId.toString(),
          'payments_amount': widget.membership.membershipsPrice.toString(),
          'description': widget.membership.membershipsName.toString(),
        }),
      )
          .timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException("Connection timeout. Please try again.");
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success' && data['billplz_url'] != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentWebView(
                url: data['billplz_url'],
                membership: widget.membership,
              ),
            ),
          );
        } else {
          showErrorSnackbar(data['message'] ?? "Failed to create payment");
        }
      } else {
        showErrorSnackbar("Server error: ${response.statusCode}");
      }
    } on TimeoutException {
      showErrorSnackbar("Connection timeout. Please try again.");
    } catch (e) {
      showErrorSnackbar("Error: $e");
    } finally {
      setState(() => isProcessing = false);
    }
  }

  void showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class PaymentWebView extends StatelessWidget {
  final String url;
  final Membership membership;

  const PaymentWebView({
    super.key,
    required this.url,
    required this.membership,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment"),
        backgroundColor: Colors.brown[800],
      ),
      body: WebViewWidget(
        controller: WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..loadRequest(Uri.parse(url))
          ..setNavigationDelegate(
            NavigationDelegate(
              onNavigationRequest: (NavigationRequest request) {
                if (request.url.contains('payment_callback.php')) {
                  handlePaymentCallback(context, request.url);
                  return NavigationDecision.prevent;
                }
                return NavigationDecision.navigate;
              },
            ),
          ),
      ),
    );
  }

  Future<void> handlePaymentCallback(BuildContext context, String url) async {
    // Extract payment status from URL
    Uri uri = Uri.parse(url);
    String? billplzPaid = uri.queryParameters['billplz[paid]'];

    if (billplzPaid == 'true') {
      // Payment successful
      Navigator.of(context).popUntil((route) => route.isFirst);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Payment successful!"),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      // Payment failed
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Payment failed. Please try again."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
