import 'package:flutter/material.dart';

class MiningPage extends StatelessWidget {
  const MiningPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Mining Page',
        style: Theme.of(context).textTheme.headlineMedium,
      ),
    );
  }
}
