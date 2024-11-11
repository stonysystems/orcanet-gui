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
          title: Text(title),
          content: const Text('Are you sure you want to proceed?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
              child: const Text('Confirm'),
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
    return Scaffold(
      appBar: AppBar(
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
                color: Colors.lightBlue[50],
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.network_check, color: Colors.blue[800]),
                      const SizedBox(width: 8),
                      Text(
                        proxyStatus,
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                              color: Colors.blue[800],
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
                color: Colors.lightBlue[50],
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Be a Proxy',
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: Colors.blue[800],
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
                  .copyWith(color: Colors.blue[800]),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                width: MediaQuery.of(context).size.width *
                    0.45, // Set container to 50% width
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: Colors.blue[800]!),
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
                        ]
                            .map((label) => TableViewHeader(label: label))
                            .toList(),
                        rows: proxyList.map((proxy) {
                          int index = proxyList.indexOf(proxy);
                          return TableViewRow(
                            height: 60,
                            cells: [
                              TableViewCell(
                                  child: Text(proxy['sno'].toString())),
                              TableViewCell(child: Text(proxy['ip'])),
                              TableViewCell(child: Text(proxy['location'])),
                              TableViewCell(child: Text(proxy['status'])),
                              TableViewCell(child: Text(proxy['bandwidth'])),
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
