import 'package:flutter/material.dart';

class WalletPage extends StatelessWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Create a ScrollController for the transactions list
    final ScrollController scrollController = ScrollController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet Page'),
        backgroundColor: Colors.lightBlue[800],
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        color: Colors.lightBlue[50], // Light blue background
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Wallet ID and Balance Info
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.lightBlue[100],
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Available Balance: 1.2345 BTC',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall!
                        .copyWith(color: Colors.blue[800]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Wallet ID: 1234567890ABCDEF',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .copyWith(color: Colors.blue[900]),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Expense: 0.5432 BTC',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .copyWith(color: Colors.blueGrey[700]),
                      ),
                      Text(
                        'Total Earnings: 1.7777 BTC',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .copyWith(color: Colors.blueGrey[700]),
                      ),
                    ],
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
                thumbVisibility: true, // Shows the scrollbar thumb
                controller: scrollController, // Attach the ScrollController
                child: ListView(
                  controller:
                      scrollController, // Attach the controller to ListView
                  padding: const EdgeInsets.all(12.0),
                  children: [
                    DataTable(
                      columns: const [
                        DataColumn(
                          label: Text('Status'),
                        ),
                        DataColumn(
                          label: Text('Transaction ID'),
                        ),
                        DataColumn(
                          label: Text('Amount (BTC)'),
                        ),
                      ],
                      rows: const [
                        DataRow(cells: [
                          DataCell(Text('Completed')),
                          DataCell(Text('TX12345')),
                          DataCell(Text('0.001')),
                        ]),
                        DataRow(cells: [
                          DataCell(Text('Pending')),
                          DataCell(Text('TX67890')),
                          DataCell(Text('0.02')),
                        ]),
                        DataRow(cells: [
                          DataCell(Text('Failed')),
                          DataCell(Text('TX54321')),
                          DataCell(Text('0.005')),
                        ]),
                      ],
                    ),
                  ],
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
                color: Colors.lightBlue[100],
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Form(
                child: Column(
                  children: [
                    TextFormField(
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
                        onPressed: () {
                          // Implement send transaction logic here
                        },
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

void main() {
  runApp(
    MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const WalletPage(),
    ),
  );
}
