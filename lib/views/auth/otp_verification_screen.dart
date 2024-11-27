// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:email_otp/email_otp.dart'; // Import the email_otp package

class OTPScreen extends StatefulWidget {
  final String email; // Add an email parameter

  const OTPScreen({super.key, required this.email}); // Add it to the constructor

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final TextEditingController otpController = TextEditingController();
  bool otpSent = false; // Track OTP send status
  bool otpVerified = false; // Track OTP verification status

  // Function to send OTP to the provided email
  void sendOTP() async {
    String email = widget.email; // Use the passed email
    if (email.isNotEmpty) {
      bool result = await EmailOTP.sendOTP(email: email);
      if (result) {
        setState(() {
          otpSent = true;
        });
        print('OTP sent to $email');
      } else {
        print('Failed to send OTP');
      }
    } else {
      print('Invalid email address');
    }
  }

  // Function to verify the OTP entered by the user
  void verifyOTP() {
    String otp = otpController.text;
    bool isValid = EmailOTP.verifyOTP(otp: otp);
    if (isValid) {
      setState(() {
        otpVerified = true;
      });
      print('OTP is valid');
    } else {
      setState(() {
        otpVerified = false;
      });
      print('Invalid OTP');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('OTP Screen')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('OTP will be sent to: ${widget.email}', // Display the email
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: sendOTP, // Send OTP when button is pressed
              child: const Text('Send OTP'),
            ),
            if (otpSent) const Text('OTP has been sent to your email.'),
            
            // OTP TextField for user to enter OTP
            if (otpSent) ...[
              const SizedBox(height: 20),
              TextField(
                controller: otpController,
                decoration: const InputDecoration(
                  labelText: 'Enter OTP',
                ),
                keyboardType: TextInputType.number,
              ),
              ElevatedButton(
                onPressed: verifyOTP, // Verify OTP when button is pressed
                child: const Text('Verify OTP'),
              ),
            ],
            if (otpVerified) const Text('OTP is valid!'),
            if (!otpVerified && otpController.text.isNotEmpty)
              const Text('Invalid OTP. Please try again.'),
          ],
        ),
      ),
    );
  }
}
