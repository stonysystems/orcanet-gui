import 'package:flutter/material.dart';
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
  bool isLoadingTransactions = true; // To show loading state for transactions
  List<Map<String, dynamic>> transactions = []; // To store fetched transactions

  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchBalance();
    _fetchTransactions();
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
        // String status =
        //     transaction['confirmations'] >= 6
        //         ? 'Completed'
        //         : transaction['confirmations'] > 0
        //             ? 'Pending'
        //             : 'Failed';
        var status =
            transaction['confirmations'] >= 3 ? 'Completed' : 'Pending';
        var statusColor = status == 'Completed' ? Colors.green : Colors.red;
        var amount = transaction['amount'] as double;
        var amountStr = (amount > 0 ? '+' : '') + amount.toStringAsFixed(2);
        var amountColor = amount > 0 ? Colors.green : Colors.red;
        var unixTimestamp = transaction['time'] as int;
        var timeStr =
            Utils.convertUtcTimestampToLocal(unixTimestamp).toString();

        return DataRow(cells: [
          DataCell(Text(transaction['txid'])),
          DataCell(Text(amountStr, style: TextStyle(color: amountColor, fontWeight: FontWeight.bold))),
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet Page'),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Wallet ID and Balance Info
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 209, 241, 255),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Display either the loading state or the fetched balance
                  Text(
                    isLoadingBalance
                        ? 'Loading Balance...' // Show loading text
                        : 'Available Balance: $balance', // Show fetched balance
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall!
                        .copyWith(color: Colors.blue[800]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Wallet ID: 1234567890ABCDEF', // Hardcoded for now
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .copyWith(color: Colors.blue[900]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Transactions Table
            Text(
              'Transactions',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge!
                  .copyWith(color: Colors.blue[800]),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Scrollbar(
                thumbVisibility: true,
                controller: scrollController,
                child: isLoadingTransactions
                    ? const Center(
                        child:
                            CircularProgressIndicator()) // Show loading indicator
                    : transactions.isEmpty
                        ? const Text(
                            'No transactions available') // Show empty state
                        : ListView(
                            controller: scrollController,
                            padding: const EdgeInsets.all(12.0),
                            children: [getTransactionList()],
                          ),
              ),
            ),
            const SizedBox(height: 16),

            // Transaction Form
            Text(
              'Send BTC',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge!
                  .copyWith(color: Colors.blue[800]),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Form(
                child: Column(
                  children: [
                    TextFormField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        labelText: 'Wallet Address',
                        border: const OutlineInputBorder(),
                        fillColor: Colors.lightBlue[50],
                        filled: true,
                        labelStyle: TextStyle(color: Colors.blue[900]),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue[600]!),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _amountController,
                      decoration: InputDecoration(
                        labelText: 'Amount (BTC)',
                        border: const OutlineInputBorder(),
                        fillColor: Colors.lightBlue[50],
                        filled: true,
                        labelStyle: TextStyle(color: Colors.blue[900]),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue[600]!),
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
                        fillColor: Colors.lightBlue[50],
                        filled: true,
                        labelStyle: TextStyle(color: Colors.blue[900]),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue[600]!),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _sendTransaction,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightBlue[700],
                          padding: const EdgeInsets.all(16.0),
                        ),
                        child: const Text('Send'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
