import 'package:flutter/material.dart';

class MarketPage extends StatelessWidget {
  const MarketPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Market Page',
        style: Theme.of(context).textTheme.headlineMedium,
      ),
    );
  }
}
