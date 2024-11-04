import 'package:flutter/material.dart';
import './../api.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<int> _fetchUploadedFileCount() async {
    final response = await Api.getProvidedFiles();
    if (response['success'] == true) {
      return (response['data'] as List).length;
    }
    return 0; // Return 0 if unsuccessful
  }

  Future<int> _fetchDownloadedFileCount() async {
    final response = await Api.getDownloadedFiles();
    if (response['success'] == true) {
      return (response['data'] as List).length;
    }
    return 0; // Return 0 if unsuccessful
  }

  Future<String> _fetchSystemStatus() async {
    final response = await Api.checkSystemStatus();
    if (response['success'] == true) {
      return response['status'];
    }
    return 'Unknown'; // Default status if unsuccessful
  }

  Future<String> _fetchWalletStatus() async {
    final response = await Api.checkWalletStatus();
    if (response['success'] == true) {
      return response['status'];
    }
    return 'Unknown'; // Default status if unsuccessful
  }

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
            const SizedBox(height: 16),
            // Stats Section Header
            Text(
              'File Statistics',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
            ),
            const SizedBox(height: 8),
            // File stats rows with FutureBuilder
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Uploaded File Count
                FutureBuilder<int>(
                  future: _fetchUploadedFileCount(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _buildStatusCard(
                          'Uploaded File Count', 'Loading...', Colors.orange);
                    } else if (snapshot.hasError) {
                      return _buildStatusCard(
                          'Uploaded File Count', 'Error', Colors.orange);
                    } else {
                      return _buildStatusCard('Uploaded File Count',
                          '${snapshot.data} files', Colors.orange);
                    }
                  },
                ),
                // Downloaded File Count
                FutureBuilder<int>(
                  future: _fetchDownloadedFileCount(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _buildStatusCard(
                          'Downloaded File Count', 'Loading...', Colors.red);
                    } else if (snapshot.hasError) {
                      return _buildStatusCard(
                          'Downloaded File Count', 'Error', Colors.red);
                    } else {
                      return _buildStatusCard('Downloaded File Count',
                          '${snapshot.data} files', Colors.red);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Status Section Header
            Text(
              'System Status',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
            ),
            const SizedBox(height: 8),
            // System Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FutureBuilder<String>(
                  future: _fetchSystemStatus(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _buildStatusCardWithIcon(
                          'System Status', 'Loading...', true);
                    } else if (snapshot.hasError) {
                      return _buildStatusCardWithIcon(
                          'System Status', 'Error', false);
                    } else {
                      return _buildStatusCardWithIcon('System Status',
                          snapshot.data!, snapshot.data! == 'Successful');
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Wallet Loaded Status
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //   children: [
            //     FutureBuilder<String>(
            //       future: _fetchWalletStatus(),
            //       builder: (context, snapshot) {
            //         if (snapshot.connectionState == ConnectionState.waiting) {
            //           return _buildStatusCardWithIcon(
            //               'Wallet Loaded Status', 'Loading...', false);
            //         } else if (snapshot.hasError) {
            //           return _buildStatusCardWithIcon(
            //               'Wallet Loaded Status', 'Error', false);
            //         } else {
            //           return _buildStatusCardWithIcon('Wallet Loaded Status',
            //               snapshot.data!, snapshot.data! == 'Successful');
            //         }
            //       },
            //     ),
            //   ],
            // ),
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

  // Helper method to create status card with icons for success or failure
  Widget _buildStatusCardWithIcon(String title, String status, bool isSuccess) {
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
                  fontWeight: FontWeight.bold,
                  color: isSuccess ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isSuccess ? Icons.check_circle : Icons.error,
                    color: isSuccess ? Colors.green : Colors.red,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    status,
                    style: TextStyle(
                      fontSize: 18,
                      color: isSuccess ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
