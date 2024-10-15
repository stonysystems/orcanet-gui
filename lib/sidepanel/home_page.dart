import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: const Color.fromARGB(255, 209, 241, 255),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 36),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Total Uploads
                _buildStatusCard('Total Upload', '51 files', Colors.blue),
                // Incoming Traffic
                _buildStatusCard('Incoming Traffic', '100 kB/s', Colors.green),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Total Downloads
                _buildStatusCard('Total Download', '10 files', Colors.orange),
                // Outgoing Traffic
                _buildStatusCard('Outgoing Traffic', '10 kB/s', Colors.red),
              ],
            ),
            const SizedBox(height: 16),
            // Add charts or additional info here
            Expanded(
              child: Center(
                child: Text(
                  'Bandwidth Overtime and Activity Graphs',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to create each status card
  Widget _buildStatusCard(String title, String value, Color color) {
    return Expanded(
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(fontSize: 24),
              )
            ],
          ),
        ),
      ),
    );
  }
}
