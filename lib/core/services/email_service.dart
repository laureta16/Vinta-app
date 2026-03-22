import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EmailService {
  static Future<void> sendWelcomeEmail(String email, String username) async {
    // REAL EMAIL BRIDGE: Opening the user's email client with a pre-filled Welcome message.
    // This provides a 'Real' functioning experience without requiring a backend API key initially.
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: email,
      query: encodeQueryParameters(<String, String>{
        'subject': 'Welcome to Vinta, $username!',
        'body': 'Hi $username,\n\nWelcome to Vinta, your premium secondary fashion destination. Your account has been created successfully.\n\nHappy shopping!\nThe Vinta Team',
      }),
    );

    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      debugPrint('Could not launch email client for $email');
    }
  }

  static Future<void> sendPasswordResetEmail(String identifier) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: identifier,
      query: encodeQueryParameters(<String, String>{
        'subject': 'Reset your Vinta Password',
        'body': 'Hi,\n\nPlease follow the instructions in your app to reset your password.\n\nRegards,\nVinta Security',
      }),
    );

    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    }
  }

  static String? encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((MapEntry<String, String> e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }
}
