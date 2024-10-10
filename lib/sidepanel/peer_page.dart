import 'package:flutter/material.dart';

class PeerPage extends StatelessWidget {
  const PeerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Peer Page',
        style: Theme.of(context).textTheme.headlineMedium,
      ),
    );
  }
}
