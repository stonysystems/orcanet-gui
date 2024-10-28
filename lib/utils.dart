import 'package:flutter/material.dart';

class Utils {
  static DateTime convertUtcTimestampToLocal(int timestamp) {
    // Convert timestamp to DateTime object in UTC
    final DateTime utcDateTime = DateTime.fromMillisecondsSinceEpoch(
        timestamp * 1000, // Convert seconds to milliseconds
        isUtc: true);

    // Convert UTC to local time
    final DateTime localDateTime = utcDateTime.toLocal();

    return localDateTime;
  }

  static void showSuccessSnackBar(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: Colors.green, content: Text(text)),
    );
  }

  static void showErrorSnackBar(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: Colors.red, content: Text(text)),
    );
  }
}
