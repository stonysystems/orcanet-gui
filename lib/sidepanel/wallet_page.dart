import 'package:flutter/material.dart';
import 'package:scrollable_table_view/scrollable_table_view.dart';
import '../utils.dart';
import './../api.dart'; // Import your API file

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  _WalletPageState createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  String balance = ''; // To store the fetched balance
  bool isLoadingBalance = true; // To show loading state for balance
  bool isLoadingTransactions = false; // To show loading state for transactions
  List<Map<String, dynamic>> transactions = [];
  List<Map<String, dynamic>> filteredTransactions = []; // For search results

  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchBalance();
    _loadTransactions();
    filteredTransactions = transactions; // Initialize with all transactions
  }

  // Method to filter transactions by Transaction ID
  void _filterTransactions(String query) {
    setState(() {
      filteredTransactions = transactions.where((transaction) {
        return transaction['txid'].toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  // Method to fetch the balance
  Future<void> _fetchBalance() async {
    try {
      final response = await Api.getBalance();
      print(response);
      if (response['success']) {
        setState(() {
          balance = response['data']; // Set the balance data
          isLoadingBalance = false; // Stop showing loading indicator
        });
      } else {
        setState(() {
          balance = 'Failed to fetch balance';
          isLoadingBalance = false;
        });
      }
    } catch (e) {
      print(e);
      setState(() {
        balance = 'Error occurred';
        isLoadingBalance = false;
      });
    }
  }

  // Method to fetch the transactions
  Future<void> _fetchTransactions() async {
    try {
      final response = await Api.listTransactions(1, 10);
      if (response['success']) {
        setState(() {
          transactions = List<Map<String, dynamic>>.from(response['data']);
          isLoadingTransactions = false;
        });
      } else {
        setState(() {
          transactions = [];
          isLoadingTransactions = false;
        });
      }
    } catch (e) {
      setState(() {
        transactions = [];
        isLoadingTransactions = false;
      });
    }
  }

  // Method to load the transactions asynchronously
  Future<void> _loadTransactions() async {
    setState(() {
      isLoadingTransactions = true; // Show loading spinner
    });

    try {
      transactions =
          await Api.getTransactionList();// Await the transaction list
      filteredTransactions =
          List.from(transactions); // Initialize filteredTransactions
    } catch (e) {
      print('Error fetching transactions: $e');
    } finally {
      setState(() {
        isLoadingTransactions = false; // Hide loading spinner
      });
    }
  }

  // Method to handle sending BTC
  Future<void> _sendTransaction() async {
    String address = _addressController.text;
    double amount = double.tryParse(_amountController.text) ?? 0.0;
    String? comment = _commentController.text;

    if (address.isNotEmpty && amount > 0) {
      try {
        final response = await Api.sendToAddress(
          address: address,
          amount: amount,
          comment: comment,
        );
        if (response['success']) {
          String txId = response['data']['tx_id'];

          // Update the transactions list with the new transaction
          setState(() {
            transactions.insert(0, {
              'tx_id': txId,
              'amount': amount,
              'confirmations': 0, // Pending transaction initially
            });
          });

          // Clear form fields after sending
          _addressController.clear();
          _amountController.clear();
          _commentController.clear();
        } else {
          // Handle failure case
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to send transaction')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error occurred while sending')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid address or amount')),
      );
    }
  }

  StatelessWidget getTransactionList() {
    return DataTable(
      columns: const [
        DataColumn(
          label: Text('Transaction ID'),
        ),
        DataColumn(
          label: Text('Amount (BTC)'),
        ),
        DataColumn(
          label: Text('Status'),
        ),
        DataColumn(
          label: Text('Category'),
        ),
        DataColumn(
          label: Text('Time'),
        ),
      ],
      rows: transactions.map((transaction) {
        var status =
            transaction['confirmations'] >= 3 ? 'Completed' : 'Pending';
        var statusColor = status == 'Completed' ? Colors.green : Colors.red;
        var amount = transaction['amount'] as double;
        var amountStr = (amount > 0 ? '+' : '') + amount.toStringAsFixed(8);
        var amountColor = amount > 0 ? Colors.green : Colors.red;
        var unixTimestamp = transaction['time'] as int;
        var timeStr =
            Utils.convertUtcTimestampToLocal(unixTimestamp).toString();

        return DataRow(cells: [
          DataCell(Text(transaction['txid'])),
          DataCell(Text(amountStr,
              style:
                  TextStyle(color: amountColor, fontWeight: FontWeight.bold))),
          DataCell(Text(
            status,
            style: TextStyle(color: statusColor),
          )),
          DataCell(Text(transaction['category'])),
          DataCell(Text(timeStr))
        ]);
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 60,
        title: Text(
          'Wallet Page',
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 23,
              ),
        ),
        backgroundColor: colorScheme.surface,
      ),
      // appBar: AppBar(
      //   title: const Text('Wallet Page'),
      // ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row to display Balance and Send BTC side by side
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Available Balance Box with Card and Elevation
                Expanded(
                  child: Card(
                    elevation: 5, // Adds elevation for shadow effect
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Container(
                      height: 280,
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Display either the loading state or the fetched balance
                          const SizedBox(height: 12),
                          Text(
                            isLoadingBalance
                                ? 'Loading Balance...'
                                : 'Available Balance:',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge!
                                .copyWith(color: colorScheme.onPrimary),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            isLoadingBalance
                                ? '...'
                                : balance, // Display either loading or fetched balance
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium!
                                .copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme
                                      .onPrimary, // Color of the text
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 35), // Spacing between the containers

                // Send BTC Section with Card and Elevation
                Expanded(
                  child: Card(
                    elevation: 5, // Adds elevation for shadow effect
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Container(
                      height: 280,
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Form(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Send BTC',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge!
                                  .copyWith(color: colorScheme.onPrimary),
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: _addressController,
                              decoration: InputDecoration(
                                labelText: 'Wallet Address',
                                border: const OutlineInputBorder(),
                                fillColor: colorScheme.primary,
                                filled: true,
                                labelStyle:
                                    TextStyle(color: colorScheme.onSecondary),
                                focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: colorScheme.onPrimary),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _amountController,
                              decoration: InputDecoration(
                                labelText: 'Amount (BTC)',
                                border: const OutlineInputBorder(),
                                fillColor: colorScheme.primary,
                                filled: true,
                                labelStyle:
                                    TextStyle(color: colorScheme.onSecondary),
                                focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: colorScheme.onPrimary),
                                ),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _commentController,
                              decoration: InputDecoration(
                                labelText: 'Comment',
                                border: const OutlineInputBorder(),
                                fillColor: colorScheme.primary,
                                filled: true,
                                labelStyle:
                                    TextStyle(color: colorScheme.onSecondary),
                                focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: colorScheme.onPrimary),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: ElevatedButton(
                                onPressed: _sendTransaction,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colorScheme.onPrimary,
                                  padding: const EdgeInsets.all(16.0),
                                ),
                                child: const Text('Send'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Text(
              'Transactions',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge!
                  .copyWith(color: colorScheme.onPrimary),
            ),
            const SizedBox(height: 16),
            // Transactions Table
            TextField(
              controller: _searchController,
              onChanged: _filterTransactions,
              decoration: InputDecoration(
                labelStyle: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .onSecondary, // Label text color
                ),
                labelText: 'Search by Transaction ID',
                prefixIcon: Icon(Icons.search, color: colorScheme.onPrimary),
                border: const OutlineInputBorder(),
                fillColor: colorScheme.surface,
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: colorScheme.onPrimary),
                ),
                filled: true,
              ),
              cursorColor: colorScheme.onPrimary,
            ),
            const SizedBox(height: 8),
            // Transactions Table

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1.0),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: colorScheme.onPrimary),
                  ),
                  child: isLoadingTransactions
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width - 32,
                                child: ScrollableTableView(
                                  headers: [
                                    'Transaction ID',
                                    'Amount (BTC)',
                                    'Status',
                                    'Category',
                                    'Time',
                                  ].asMap().entries.map((entry) {
                                    final label = entry.value;
                                    final widthPercentage = [
                                      0.25,
                                      0.12,
                                      0.12,
                                      0.12,
                                      0.25,
                                    ][entry.key];
                                    return TableViewHeader(
                                      label: label,
                                      width:
                                          (MediaQuery.of(context).size.width) *
                                              widthPercentage,
                                    );
                                  }).toList(),
                                  rows: filteredTransactions.map((transaction) {
                                    var status =
                                        transaction['confirmations'] >= 3
                                            ? 'Completed'
                                            : 'Pending';
                                    var statusColor = status == 'Completed'
                                        ? Colors.green
                                        : colorScheme.error;
                                    var amount =
                                        transaction['amount'] as double;
                                    var amountStr = (amount > 0 ? '+' : '') +
                                        amount.toStringAsFixed(8);
                                    var amountColor = amount > 0
                                        ? Colors.green
                                        : colorScheme.error;
                                    var unixTimestamp =
                                        transaction['time'] as int;
                                    var timeStr =
                                        DateTime.fromMillisecondsSinceEpoch(
                                                unixTimestamp * 1000)
                                            .toLocal()
                                            .toString();

                                    return TableViewRow(
                                      height: 60,
                                      cells: [
                                        TableViewCell(
                                            child: Text(transaction['txid'])),
                                        TableViewCell(
                                          child: Text(
                                            amountStr,
                                            style: TextStyle(
                                                color: amountColor,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        TableViewCell(
                                          child: Text(
                                            status,
                                            style:
                                                TextStyle(color: statusColor),
                                          ),
                                        ),
                                        TableViewCell(
                                            child:
                                                Text(transaction['category'])),
                                        TableViewCell(child: Text(timeStr)),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
