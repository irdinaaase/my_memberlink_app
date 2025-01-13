import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:my_memberlink_app/model/membership.dart';
import 'package:my_memberlink_app/views/newsletter/news_screen.dart';
import 'package:my_memberlink_app/model/user.dart';

class PurchaseMembershipScreen extends StatefulWidget {
  final Membership membership;
  final User userdata;

  const PurchaseMembershipScreen({
    super.key,
    required this.membership,
    required this.userdata,
  });

  @override
  State<PurchaseMembershipScreen> createState() =>
      _PurchaseMembershipScreenState();
}

class _PurchaseMembershipScreenState extends State<PurchaseMembershipScreen> {
  late WebViewController _controller;
  late double _progress;

  @override
  void initState() {
    super.initState();

    String email = widget.userdata.email ?? '';
    String phone = widget.userdata.phone ?? '';
    String name = widget.userdata.lastName ?? '';
    String userid = widget.userdata.id ?? '';
    String amount = widget.membership.membershipsPrice.toString();
    String type = widget.membership.membershipsName.toString();


    print("User email: ${widget.userdata.email}");
    print("User phone: ${widget.userdata.phone}");
    print("User last name: ${widget.userdata.lastName}");
    print("User ID: ${widget.userdata.id}");
    print("Membership amount: ${widget.membership.membershipsPrice}");

    if (email.isEmpty ||
        phone.isEmpty ||
        name.isEmpty ||
        userid.isEmpty ||
        amount.isEmpty) {
      print("Error: One or more parameters are missing!");
      return;
    }

    final Uri url = Uri.https(
      'humancc.site',
      '/irdinabalqis/memberlink/api/create_payment.php',
      {
        'users_email': email,
        'users_phone': phone,
        'users_lastname': name,
        'users_id': userid,
        'payments_amount': amount,
        'memberships_name': type,
      },
    );

    print("Constructed URL: ${url.toString()}");

    _progress = 0;
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            setState(() {
              _progress = progress / 100;
            });
          },
          onPageStarted: (String url) {
            print('Page started loading: $url');
          },
          onPageFinished: (String url) {
            print('Page finished loading: $url');
          },
          onWebResourceError: (WebResourceError error) {
            print('Error loading page: ${error.description}');
          },
        ),
      )
      ..loadRequest(url);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => MainScreen(userdata: widget.userdata)),
            );
          },
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6.0),
          child: LinearProgressIndicator(
            backgroundColor: theme.colorScheme.onPrimary,
            valueColor:
                AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
            value: _progress,
          ),
        ),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
