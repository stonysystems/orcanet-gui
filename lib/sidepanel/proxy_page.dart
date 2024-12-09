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
  String? selectedProxyId;
  String proxyStatus = 'Ready';
  String connectedPeers = '0';
  String dataTransfer = '0 MB';
  String coinsEarned = '0';
  bool isLoadingProxyList = true;
  Map<String, Map<String, dynamic>> proxyList = {};

  @override
  void initState() {
    super.initState();
    _fetchProxyList();
  }

  Future<void> _fetchProxyList() async {
    try {
      var r = await Api.getProxyStatus();
      print(r);

      var response = await Api.getProxyProviders();
      var data = List<Map<String, dynamic>>.from(response['data']);
      print(response);
      Map<String, Map<String, dynamic>> proxies = Map();

      for (var row in data) {
        var metadata = Map<String, dynamic>.from(row['proxy_metadata']);
        metadata['ip'] = metadata['proxy_address']!.split(':')[0];
        metadata['location'] = await Api.getIPLocation(metadata['ip']!);
        proxies[row['peer_id']] = metadata;
      }

      print(proxies);

      setState(() {
        proxyList = proxies;
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
    _showConfirmationDialog('Enable Be a Proxy?', () async {
      bool success = false;

      if (!isBeAProxyEnabled) {
        Map<String, dynamic> response = await Api.startProviding();
        success = response['success'];
      } else {
        Map<String, dynamic> response = await Api.stopProxy();
        success = response['success'];
      }

      if (!success) {
        return;
      }

      setState(() {
        isBeAProxyEnabled = !isBeAProxyEnabled;
        selectedProxyId = null;
        proxyStatus = isBeAProxyEnabled ? 'Serving as Proxy' : 'Ready';
        connectedPeers = isBeAProxyEnabled ? '5' : '0';
        dataTransfer = isBeAProxyEnabled ? '200 MB' : '0 MB';
        coinsEarned = isBeAProxyEnabled ? '50 Coins' : '0';
      });
    });
  }

  void _toggleConnectToProxy(String proxyId) {
    _showConfirmationDialog('Connect to Proxy Server?', () async {
      var response = await Api.connectToProxy(proxyId);
      print(response);
      if(!response['success']) {
        return;
      }

      setState(() {
        selectedProxyId = selectedProxyId == proxyId ? null : selectedProxyId;
        isBeAProxyEnabled = false;
        if (selectedProxyId != null) {
          proxyStatus =
              'Connected to Proxy: ${proxyList[selectedProxyId!]?['ip']}';
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
        toolbarHeight: 60,
        title: Text(
          'Proxy',
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 23,
              ),
        ),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onPrimary,
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
                color: colorScheme.primary,
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
                  if (selectedProxyId != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'IP: ${proxyList[selectedProxyId!]?['ip']}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      'Location: ${proxyList[selectedProxyId!]?['location']}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      'Bandwidth: ${proxyList[selectedProxyId!]?['bandwidth']}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Be a Proxy Section
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: colorScheme.primary,
                //.withOpacity(0.5), // Semi-transparent primary
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
                    activeColor: Colors.black,
                    inactiveThumbColor: Colors.black,
                    activeTrackColor: Colors.black.withOpacity(0.3),
                    inactiveTrackColor: Colors.black.withOpacity(0.1),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Connect to Proxy Section
            Text(
              'Available Proxies',
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
                          "Fee rate per kb",
                          "Connect"
                        ].asMap().entries.map((entry) {
                          final index = entry.key;
                          final label = entry.value;

                          // Define custom widths for each column (adjust as needed)
                          const columnWidths = [
                            0.10, // S.No (10% of the container width)
                            0.10, // Server IP (20%)
                            0.20, // Location (20%)
                            0.10,
                            0.20, // Connect (10%)
                          ];

                          return TableViewHeader(
                            label: label,
                            // Set the header label
                            width: MediaQuery.of(context).size.width *
                                columnWidths[index],
                            alignment: Alignment.center,
                            // Center-align the label
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
                        rows: proxyList.entries.indexed.map((item) {
                          final (index, entry) = item;
                          String proxyId = entry.key;
                          var metadata = entry.value;

                          var data = [
                            (index + 1).toString(), // SNo
                            metadata['ip']!,
                            metadata['location']!,
                            metadata['fee_rate_per_kb']!.toString()
                          ];

                          return TableViewRow(
                            height: 60,
                            cells: [
                              ...data.map((value) => TableViewCell(
                                    child: Text(
                                      value,
                                      style: TextStyle(
                                        color: colorScheme.onSecondary,
                                      ),
                                    ),
                                  )),
                              TableViewCell(
                                child: Switch(
                                  value: selectedProxyId == proxyId,
                                  onChanged: (value) {
                                    _toggleConnectToProxy(proxyId);
                                  },
                                  activeColor: Colors.black,
                                  inactiveThumbColor: Colors.black,
                                  activeTrackColor:
                                      Colors.black.withOpacity(0.3),
                                  inactiveTrackColor:
                                      Colors.black.withOpacity(0.1),
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
