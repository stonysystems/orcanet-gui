import 'package:flutter/material.dart';

class StatusPage extends StatelessWidget {
  const StatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Status Page',
        style: Theme.of(context).textTheme.headlineMedium,
      ),
    );
  }
}
