import 'package:flutter/material.dart';
import 'package:scrollable_table_view/scrollable_table_view.dart';
import './../api.dart'; // Import your API file

class ProxyPage extends StatefulWidget {
  const ProxyPage({super.key});

  @override
  _ProxyPageState createState() => _ProxyPageState();
}

class _ProxyPageState extends State<ProxyPage> {
  bool isBeAProxyEnabled = false;
  int? selectedProxyIndex;
  String proxyStatus = 'Ready';
  String connectedPeers = '0';
  String dataTransfer = '0 MB';
  String coinsEarned = '0';
  bool isLoadingProxyList = true;
  List<Map<String, dynamic>> proxyList = [];

  @override
  void initState() {
    super.initState();
    _fetchProxyList();
  }

  Future<void> _fetchProxyList() async {
    try {
      String txId = '12345';
      Map<String, dynamic> response = await Api.getProxyList(txId);
      setState(() {
        proxyList = List<Map<String, dynamic>>.from(response['proxyList']);
        isLoadingProxyList = false;
      });
    } catch (e) {
      print('Error fetching proxy list: $e');
      isLoadingProxyList = false;
    }
  }

  Future<void> _showConfirmationDialog(
      String title, VoidCallback onConfirm) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSecondary, // Title color
            ),
          ),
          content: Text(
            'Are you sure you want to proceed?',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSecondary, // Content color
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .onSecondary, // Button text color
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
              child: Text(
                'Confirm',
                style: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .onSecondary, // Button text color
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _toggleBeAProxy() {
    _showConfirmationDialog('Enable Be a Proxy?', () {
      setState(() {
        isBeAProxyEnabled = !isBeAProxyEnabled;
        selectedProxyIndex = null;
        proxyStatus = isBeAProxyEnabled ? 'Serving as Proxy' : 'Ready';
        connectedPeers = isBeAProxyEnabled ? '5' : '0';
        dataTransfer = isBeAProxyEnabled ? '200 MB' : '0 MB';
        coinsEarned = isBeAProxyEnabled ? '50 Coins' : '0';
      });
    });
  }

  void _toggleConnectToProxy(int index) {
    _showConfirmationDialog('Connect to Proxy Server?', () {
      setState(() {
        selectedProxyIndex = selectedProxyIndex == index ? null : index;
        isBeAProxyEnabled = false;
        if (selectedProxyIndex != null) {
          proxyStatus =
              'Connected to Proxy: ${proxyList[selectedProxyIndex!]['ip']}';
          connectedPeers = '2';
          dataTransfer = '50 MB';
          coinsEarned = '10 Coins';
        } else {
          proxyStatus = 'Ready';
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onPrimary,
        title: const Text('Proxy Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Proxy Status Section
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: colorScheme.primary
                    .withOpacity(0.5), // Semi-transparent primary
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.network_check, color: colorScheme.onPrimary),
                      const SizedBox(width: 8),
                      Text(
                        proxyStatus,
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                              color: colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  if (selectedProxyIndex != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'IP: ${proxyList[selectedProxyIndex!]['ip']}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      'Location: ${proxyList[selectedProxyIndex!]['location']}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      'Bandwidth: ${proxyList[selectedProxyIndex!]['bandwidth']}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                  if (isBeAProxyEnabled) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Connected Peers: $connectedPeers',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      'Data Transfer: $dataTransfer',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      'Coins Earned: $coinsEarned',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ]
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Be a Proxy Section
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: colorScheme.primary
                    .withOpacity(0.5), // Semi-transparent primary
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Be a Proxy',
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Switch(
                    value: isBeAProxyEnabled,
                    onChanged: (value) {
                      _toggleBeAProxy();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Connect to Proxy Section
            Text(
              'Connect to Proxy',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge!
                  .copyWith(color: colorScheme.onPrimary),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: isLoadingProxyList
                    ? const Center(child: CircularProgressIndicator())
                    : ScrollableTableView(
                        headers: [
                          "S.No",
                          "Server IP",
                          "Location",
                          "Availability",
                          "Bandwidth",
                          "Connect"
                        ].asMap().entries.map((entry) {
                          final index = entry.key;
                          final label = entry.value;

                          // Define custom widths for each column (adjust as needed)
                          const columnWidths = [
                            0.1, // S.No (10% of the container width)
                            0.2, // Server IP (20%)
                            0.2, // Location (20%)
                            0.1, // Availability (10%)
                            0.2, // Bandwidth (20%)
                            0.1, // Connect (10%)
                          ];

                          return TableViewHeader(
                            label: label, // Set the header label
                            width: MediaQuery.of(context).size.width *
                                columnWidths[index],
                            alignment:
                                Alignment.center, // Center-align the label
                            textStyle: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSecondary, // Text color
                              fontWeight: FontWeight.bold,
                            ),
                            padding: const EdgeInsets.all(
                                8.0), // Optional: Adjust padding
                          );
                        }).toList(),
                        rows: proxyList.map((proxy) {
                          int index = proxyList.indexOf(proxy);
                          return TableViewRow(
                            height: 60,
                            cells: [
                              TableViewCell(
                                child: Text(
                                  proxy['sno'].toString(),
                                  style: TextStyle(
                                    color: colorScheme.onSecondary,
                                  ),
                                ),
                              ),
                              TableViewCell(
                                child: Text(
                                  proxy['ip'],
                                  style: TextStyle(
                                    color: colorScheme.onSecondary,
                                  ),
                                ),
                              ),
                              TableViewCell(
                                child: Text(
                                  proxy['location'],
                                  style: TextStyle(
                                    color: colorScheme.onSecondary,
                                  ),
                                ),
                              ),
                              TableViewCell(
                                child: Text(
                                  proxy['status'],
                                  style: TextStyle(
                                    color: proxy['status'] == 'Available'
                                        ? Colors.green
                                        : colorScheme.error,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              TableViewCell(
                                child: Text(
                                  proxy['bandwidth'],
                                  style: TextStyle(
                                    color: colorScheme.onSecondary,
                                  ),
                                ),
                              ),
                              TableViewCell(
                                child: Switch(
                                  value: selectedProxyIndex == index,
                                  onChanged: (value) {
                                    _toggleConnectToProxy(index);
                                  },
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
