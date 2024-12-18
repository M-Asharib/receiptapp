import 'package:flutter/material.dart';
// import 'package:receipt_app/services/receipt_model.dart';

import '../models/receipt_model.dart';
// import '../models/receipt_model.dart';

class HistoryScreen extends StatelessWidget {
  final List<Receipt> receipts = [
    // Dummy Data
    Receipt(
      id: '001',
      date: '2024-12-01',
      ms: 'M/S Example 1',
      items: [
        Item(qty: '2', particular: 'Item A', rate: '500', amount: '1000'),
        Item(qty: '1', particular: 'Item B', rate: '200', amount: '200'),
      ],
    ),
    Receipt(
      id: '002',
      date: '2024-12-05',
      ms: 'M/S Example 2',
      items: [
        Item(qty: '5', particular: 'Item C', rate: '300', amount: '1500'),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Receipt History'),
      ),
      body: receipts.isEmpty
          ? Center(
        child: Text(
          'No Receipts Found',
          style: TextStyle(fontSize: 18),
        ),
      )
          : ListView.builder(
        itemCount: receipts.length,
        itemBuilder: (context, index) {
          final receipt = receipts[index];
          return Card(
            margin: const EdgeInsets.all(10),
            child: ListTile(
              title: Text('Receipt ID: ${receipt.id}'),
              subtitle: Text('Date: ${receipt.date}\nM/S: ${receipt.ms}'),
              trailing: IconButton(
                icon: Icon(Icons.share),
                onPressed: () {
                  // Share PDF or data
                },
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReceiptDetailScreen(receipt: receipt),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class ReceiptDetailScreen extends StatelessWidget {
  final Receipt receipt;

  const ReceiptDetailScreen({Key? key, required this.receipt}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Receipt Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Receipt ID: ${receipt.id}', style: TextStyle(fontSize: 18)),
            Text('Date: ${receipt.date}', style: TextStyle(fontSize: 18)),
            Text('M/S: ${receipt.ms}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text(
              'Items:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: receipt.items.length,
                itemBuilder: (context, index) {
                  final item = receipt.items[index];
                  return ListTile(
                    title: Text(item.particular),
                    subtitle: Text('Qty: ${item.qty}, Rate: ${item.rate}'),
                    trailing: Text('Amount: ${item.amount}'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
