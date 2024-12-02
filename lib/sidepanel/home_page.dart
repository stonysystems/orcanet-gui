import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
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

  // Dummy data generators for upload and download speed
  // Future<List<FlSpot>> _fetchUploadSpeedData() async {
  //   // Replace with actual API logic
  //   return List.generate(10, (index) => FlSpot(index.toDouble(), (index * 2).toDouble()));
  // }

  // Future<List<FlSpot>> _fetchDownloadSpeedData() async {
  //   // Replace with actual API logic
  //   return List.generate(10, (index) => FlSpot(index.toDouble(), (index * 1.5).toDouble()));
  // }
  Future<List<FlSpot>> _fetchUploadSpeedData() async {
  const double baseUploadSpeed = 5.0; // Average upload speed in Mbps
  const double fluctuationRange = 2.0; // +/- range for fluctuations
  final random = Random();

  return List.generate(
    10,
    (index) {
      double fluctuation = (random.nextDouble() * fluctuationRange * 2) - fluctuationRange;
      double speed = (baseUploadSpeed + fluctuation).clamp(0, double.infinity); // Avoid negative speeds
      return FlSpot(index.toDouble(), speed);
    },
  );
}

Future<List<FlSpot>> _fetchDownloadSpeedData() async {
  const double baseDownloadSpeed = 10.0; // Average download speed in Mbps
  const double fluctuationRange = 3.0; // +/- range for fluctuations
  final random = Random();

  return List.generate(
    10,
    (index) {
      double fluctuation = (random.nextDouble() * fluctuationRange * 2) - fluctuationRange;
      double speed = (baseDownloadSpeed + fluctuation).clamp(0, double.infinity); // Avoid negative speeds
      return FlSpot(index.toDouble(), speed);
    },
  );
}

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dashboard',
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 23,
              ),
        ),
        backgroundColor: colorScheme.surface,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [ 
              const SizedBox(height: 10),
              Text(
                'File Statistics',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: colorScheme.onPrimary,
                    ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FutureBuilder<int>(
                    future: _fetchUploadedFileCount(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return _buildStatusCard('Uploaded File Count',
                            'Loading...', colorScheme, true);
                      } else if (snapshot.hasError) {
                        return _buildStatusCard(
                            'Uploaded File Count', 'Error', colorScheme, false);
                      } else {
                        return _buildStatusCard('Uploaded File Count',
                            '${snapshot.data} files', colorScheme, true);
                      }
                    },
                  ),
                  FutureBuilder<int>(
                    future: _fetchDownloadedFileCount(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return _buildStatusCard('Downloaded File Count',
                            'Loading...', colorScheme, true);
                      } else if (snapshot.hasError) {
                        return _buildStatusCard(
                            'Downloaded File Count', 'Error', colorScheme, false);
                      } else {
                        return _buildStatusCard('Downloaded File Count',
                            '${snapshot.data} files', colorScheme, true);
                      }
                    },
                  ),
                  FutureBuilder<int>(
                    future: _fetchUploadedFileCount(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return _buildStatusCard('Proxy Usage Percentage',
                            'Loading...', colorScheme, true);
                      } else if (snapshot.hasError) {
                        return _buildStatusCard(
                            'Proxy Usage Percentage', 'Error', colorScheme, false);
                      } else {
                        return _buildStatusCard('Proxy Usage Percentage',
                            '${snapshot.data} files', colorScheme, true);
                      }
                    },
                  ),
                  FutureBuilder<int>(
                    future: _fetchDownloadedFileCount(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return _buildStatusCard('Mining Rewards',
                            'Loading...', colorScheme, true);
                      } else if (snapshot.hasError) {
                        return _buildStatusCard(
                            'Mining Rewards', 'Error', colorScheme, false);
                      } else {
                        return _buildStatusCard('Mining Rewards',
                            '${snapshot.data} files', colorScheme, true);
                      }
                    },
                  ),
       
                ],
              ),
              const SizedBox(height: 32),
              Text(
                'System Status',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: colorScheme.onPrimary,
                    ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FutureBuilder<String>(
                    future: _fetchSystemStatus(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return _buildStatusCardWithIcon(
                            'System Status', 'Loading...', true, colorScheme);
                      } else if (snapshot.hasError) {
                        return _buildStatusCardWithIcon(
                            'System Status', 'Error', false, colorScheme);
                      } else {
                        return _buildStatusCardWithIcon(
                            'System Status',
                            snapshot.data!,
                            snapshot.data! == 'Successful',
                            colorScheme);
                      }
                    },
                  ),
                  FutureBuilder<String>(
                    future: _fetchWalletStatus(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return _buildStatusCardWithIcon('Wallet Loaded Status',
                            'Loading...', false, colorScheme);
                      } else if (snapshot.hasError) {
                        return _buildStatusCardWithIcon(
                            'Wallet Loaded Status', 'Error', false, colorScheme);
                      } else {
                        return _buildStatusCardWithIcon(
                            'Wallet Loaded Status',
                            snapshot.data!,
                            snapshot.data! == 'Successful',
                            colorScheme);
                      }
                    },
                  ),
                
                ],
              ),
              const SizedBox(height: 32),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //   children: [
              //     FutureBuilder<String>(
              //       future: _fetchWalletStatus(),
              //       builder: (context, snapshot) {
              //         if (snapshot.connectionState == ConnectionState.waiting) {
              //           return _buildStatusCardWithIcon('Wallet Loaded Status',
              //               'Loading...', false, colorScheme);
              //         } else if (snapshot.hasError) {
              //           return _buildStatusCardWithIcon(
              //               'Wallet Loaded Status', 'Error', false, colorScheme);
              //         } else {
              //           return _buildStatusCardWithIcon(
              //               'Wallet Loaded Status',
              //               snapshot.data!,
              //               snapshot.data! == 'Successful',
              //               colorScheme);
              //         }
              //       },
              //     ),
              //   ],
              // ),
              // const SizedBox(height: 32),

              Card(
                color: colorScheme.primary,
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
               // margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Network Speed',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: colorScheme.onPrimary,
                            ),
                      ),
                      const SizedBox(height: 16),
                      FutureBuilder<List<List<FlSpot>>>(
                        future: Future.wait([
                          _fetchUploadSpeedData(),
                          _fetchDownloadSpeedData(),
                        ]),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return const Center(child: Text('Error loading graph data.'));
                          } else {
                            final uploadData = snapshot.data![0];
                            final downloadData = snapshot.data![1];
                            return SizedBox(
                              height: 350,
                              child: LineChart(
                                LineChartData(
                                  gridData: const FlGridData(show: true),
                                  titlesData: const FlTitlesData(
                                    leftTitles: AxisTitles(
                                      axisNameWidget: Text(
                                        'Speed (Mbps)',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                      axisNameSize: 16,
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 44,
                                      ),
                                    ),
                                    bottomTitles: AxisTitles(
                                      axisNameWidget: Text(
                                        'Time (s)',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                      axisNameSize: 16,
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 44,
                                      ),
                                    ),
                                  ),
                                  borderData: FlBorderData(
                                    show: true,
                                    border: const Border(
                                      left: BorderSide(width: 1),
                                      bottom: BorderSide(width: 1),
                                    ),
                                  ),
                                  lineBarsData: [
                                    LineChartBarData(
                                      spots: uploadData,
                                      isCurved: false,
                                      color: Colors.blue,
                                      barWidth: 3,
                                      belowBarData: BarAreaData(show: false),
                                    ),
                                    LineChartBarData(
                                      spots: downloadData,
                                      isCurved: false,
                                      color: Colors.green,
                                      barWidth: 3,
                                      belowBarData: BarAreaData(show: false),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),

            
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard(
      String title, String value, ColorScheme colorScheme, bool isSuccess) {
    return Expanded(
      child: Card(
        color: colorScheme.primary,
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  color: colorScheme.onPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  color: isSuccess ? Colors.green : colorScheme.error,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCardWithIcon(
      String title, String status, bool isSuccess, ColorScheme colorScheme) {
    return Expanded(
      child: Card(
        color: colorScheme.primary,
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 18, color: colorScheme.onPrimary),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isSuccess ? Icons.check_circle : Icons.error,
                    color: isSuccess ? Colors.green : colorScheme.error,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    status,
                    style: TextStyle(
                      fontSize: 16,
                      color: isSuccess ? Colors.green : colorScheme.error,
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
