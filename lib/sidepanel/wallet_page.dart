import 'package:flutter/material.dart';

class WalletPage extends StatelessWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Wallet Page',
        style: Theme.of(context).textTheme.headlineMedium,
      ),
    );
  }
}
