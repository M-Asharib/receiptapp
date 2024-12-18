import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';

class FetchReceiptDataScreen extends StatefulWidget {
  @override
  _FetchReceiptDataScreenState createState() => _FetchReceiptDataScreenState();
}

class _FetchReceiptDataScreenState extends State<FetchReceiptDataScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> receiptData = [];
  List<Map<String, dynamic>> filteredData = [];

  // Controllers for the filters
  TextEditingController searchController = TextEditingController();

  // Controllers for date filters
  TextEditingController fromDateController = TextEditingController();
  TextEditingController toDateController = TextEditingController();

  DateTime? fromDate;
  DateTime? toDate;

  @override
  void initState() {
    super.initState();
    fetchReceipts();
  }

  // Function to fetch receipts from Firestore
  Future<void> fetchReceipts() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('receipts').get();

      setState(() {
        receiptData = snapshot.docs
            .map((doc) => {
          'id': doc.id,
          'date': doc['date'],
          'ms': doc['ms'],
          'items': List<Map<String, dynamic>>.from(doc['items']),
        })
            .toList();
        filteredData = List.from(receiptData);
      });
    } catch (e) {
      print('Error fetching receipts: $e');
    }
  }

  // Function to filter the receipts based on the search fields
  void filterReceipts() {
    setState(() {
      filteredData = receiptData.where((receipt) {
        // Check for text filters (Particular + M/S combined)
        bool matchSearch = searchController.text.isEmpty ||
            receipt['items'].any((item) =>
            item['particular']
                .toString()
                .toLowerCase()
                .contains(searchController.text.toLowerCase()) ||
                receipt['ms']
                    .toString()
                    .toLowerCase()
                    .contains(searchController.text.toLowerCase()));

        return matchSearch;
      }).toList();
    });
  }

  // Function to generate the PDF from the receipt data
  Future<String> generatePdf(List<Map<String, dynamic>> filteredData) async {
    final pdf = pw.Document();

    for (var receipt in filteredData) {
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              children: [
                pw.Text('Date: ${receipt['date']}'),
                pw.Text('M/S: ${receipt['ms']}'),
                pw.ListView.builder(
                  itemCount: receipt['items'].length,
                  itemBuilder: (context, index) {
                    var item = receipt['items'][index];
                    return pw.Text(
                      'Particular: ${item['particular']}, Rate: ${item['rate']}, Qty: ${item['qty']}, Amount: ${item['amount']}',
                    );
                  },
                ),
              ],
            );
          },
        ),
      );
    }

    // Save the PDF to a file
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/receipts.pdf';
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    return filePath;
  }

  // Function to share the PDF
  Future<void> sharePdf(List<Map<String, dynamic>> filteredData) async {
    String filePath = await generatePdf(filteredData);

    // Convert the file path to XFile
    final XFile xFile = XFile(filePath);

    // Share the file
    await Share.shareXFiles([xFile], text: 'Here are the receipts');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Receipts Data'),
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () => sharePdf(filteredData), // Trigger share function
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16),

            // Combined Particular & M/S Filter
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Filter by Particular or M/S',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.search),
              ),
              onChanged: (_) => filterReceipts(),
            ),
            SizedBox(height: 20),

            // Display filtered receipts
            filteredData.isEmpty
                ? Center(child: CircularProgressIndicator())
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: filteredData.map((receipt) {
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Date: ${receipt['date']}'),
                        SizedBox(height: 8),
                        Text('M/S: ${receipt['ms']}'),
                        SizedBox(height: 8),
                        Column(
                          children: List.generate(receipt['items'].length, (index) {
                            var item = receipt['items'][index];
                            return ListTile(
                              title: Text('Particular: ${item['particular']}'),
                              subtitle: Text(
                                'Rate: ${item['rate']} | Qty: ${item['qty']} | Amount: ${item['amount']}',
                              ),
                            );
                          }),
                        ),
                        SizedBox(height: 8),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
