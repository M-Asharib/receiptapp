import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:number_to_words_english/number_to_words_english.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:receipt_app/screen/receipt_view.dart';
import '../services/pdf_service.dart';



class ReceiptScreen extends StatefulWidget {
  @override
  _ReceiptScreenState createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends State<ReceiptScreen> {
  final TextEditingController dateController = TextEditingController();
  final TextEditingController msController = TextEditingController();
  List<Map<String, dynamic>> items = [];

  @override
  void initState() {
    super.initState();
    items.add({'particular': '', 'rate': '', 'qty': '', 'amount': 0});
  }

  void addItem() {
    setState(() {
      items.add({'particular': '', 'rate': '', 'qty': '', 'amount': 0});
    });
  }

  Future<void> pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        dateController.text = DateFormat('dd-MM-yyyy').format(pickedDate);
      });
    }
  }

  void calculateAmount(int index) {
    double rate = double.tryParse(items[index]['rate']) ?? 0;
    double qty = double.tryParse(items[index]['qty']) ?? 0;
    setState(() {
      items[index]['amount'] = rate * qty;
    });
  }

  void generatePDF() async {
    // Create a new document reference for Firestore
    CollectionReference receipts = FirebaseFirestore.instance.collection('receipts');

    // Data to be added to Firestore
    Map<String, dynamic> receiptData = {
      'date': dateController.text,
      'ms': msController.text,
      'items': items,
    };

    // Add data to Firestore
    await receipts.add(receiptData)
        .then((value) => print("Receipt Added"))
        .catchError((error) => print("Failed to add receipt: $error"));

    // Generate PDF after adding data to Firestore
    await PdfService.generateReceipt(receiptData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Generate Receipt'),
        actions: [
          // Adding View Icon to the AppBar
          IconButton(
            icon: Icon(Icons.visibility),
            onPressed: () {
              // Navigate to FetchReceiptDataScreen when the icon is clicked
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FetchReceiptDataScreen()),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addItem,
        child: Icon(Icons.add),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: pickDate,
              child: AbsorbPointer(
                child: TextField(
                  controller: dateController,
                  decoration: InputDecoration(
                    labelText: 'Date',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: msController,
              decoration: InputDecoration(
                labelText: 'M/S',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (context, index) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 8),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Particular',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) => items[index]['particular'] = value,
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              labelText: 'Rate',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              items[index]['rate'] = value;
                              calculateAmount(index);
                            },
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              labelText: 'Qty',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              items[index]['qty'] = value;
                              calculateAmount(index);
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Amount: ${items[index]['amount'].toStringAsFixed(2)}',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'In Words: ${NumberToWordsEnglish.convert(items[index]['amount'].toInt())}',
                      style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                    ),
                  ],
                );
              },
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: generatePDF,
              icon: Icon(Icons.picture_as_pdf),
              label: Text('Generate PDF'),
              style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
            ),
          ],
        ),
      ),
    );
  }
}




// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// // import 'package:number_to_words/number_to_words.dart';
// import 'package:number_to_words_english/number_to_words_english.dart';
// // For converting numbers to words
// import '../services/pdf_service.dart';
//
// class ReceiptScreen extends StatefulWidget {
//   @override
//   _ReceiptScreenState createState() => _ReceiptScreenState();
// }
//
// class _ReceiptScreenState extends State<ReceiptScreen> {
//   final TextEditingController dateController = TextEditingController();
//   final TextEditingController msController = TextEditingController();
//   List<Map<String, dynamic>> items = [];
//
//   @override
//   void initState() {
//     super.initState();
//     items.add({'particular': '', 'rate': '', 'qty': '', 'amount': 0});
//   }
//
//   void addItem() {
//     setState(() {
//       items.add({'particular': '', 'rate': '', 'qty': '', 'amount': 0});
//     });
//   }
//
//   Future<void> pickDate() async {
//     DateTime? pickedDate = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2101),
//     );
//
//     if (pickedDate != null) {
//       setState(() {
//         dateController.text = DateFormat('dd-MM-yyyy').format(pickedDate);
//       });
//     }
//   }
//
//   void calculateAmount(int index) {
//     double rate = double.tryParse(items[index]['rate']) ?? 0;
//     double qty = double.tryParse(items[index]['qty']) ?? 0;
//     setState(() {
//       items[index]['amount'] = rate * qty;
//     });
//   }
//
//   void generatePDF() async {
//     await PdfService.generateReceipt({
//       'date': dateController.text,
//       'ms': msController.text,
//       'items': items,
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Generate Receipt')),
//       floatingActionButton: FloatingActionButton(
//         onPressed: addItem,
//         child: Icon(Icons.add),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             GestureDetector(
//               onTap: pickDate,
//               child: AbsorbPointer(
//                 child: TextField(
//                   controller: dateController,
//                   decoration: InputDecoration(
//                     labelText: 'Date',
//                     border: OutlineInputBorder(),
//                     suffixIcon: Icon(Icons.calendar_today),
//                   ),
//                 ),
//               ),
//             ),
//             SizedBox(height: 16),
//             TextField(
//               controller: msController,
//               decoration: InputDecoration(
//                 labelText: 'M/S',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             SizedBox(height: 20),
//             ListView.builder(
//               shrinkWrap: true,
//               physics: NeverScrollableScrollPhysics(),
//               itemCount: items.length,
//               itemBuilder: (context, index) {
//                 return Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     SizedBox(height: 8),
//                     TextField(
//                       decoration: InputDecoration(
//                         labelText: 'Particular',
//                         border: OutlineInputBorder(),
//                       ),
//                       onChanged: (value) => items[index]['particular'] = value,
//                     ),
//                     SizedBox(height: 8),
//                     Row(
//                       children: [
//                         Expanded(
//                           child: TextField(
//                             decoration: InputDecoration(
//                               labelText: 'Rate',
//                               border: OutlineInputBorder(),
//                             ),
//                             keyboardType: TextInputType.number,
//                             onChanged: (value) {
//                               items[index]['rate'] = value;
//                               calculateAmount(index);
//                             },
//                           ),
//                         ),
//                         SizedBox(width: 8),
//                         Expanded(
//                           child: TextField(
//                             decoration: InputDecoration(
//                               labelText: 'Qty',
//                               border: OutlineInputBorder(),
//                             ),
//                             keyboardType: TextInputType.number,
//                             onChanged: (value) {
//                               items[index]['qty'] = value;
//                               calculateAmount(index);
//                             },
//                           ),
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: 8),
//                     Row(
//                       children: [
//                         Expanded(
//                           child: Container(
//                             padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//                             decoration: BoxDecoration(
//                               border: Border.all(color: Colors.grey),
//                               borderRadius: BorderRadius.circular(4),
//                             ),
//                             child: Text(
//                               'Amount: ${items[index]['amount'].toStringAsFixed(2)}',
//                               style: TextStyle(fontSize: 16),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: 8),
//                     Text(
//                       'In Words: ${NumberToWordsEnglish.convert(items[index]['amount'].toInt())}',
//                       style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
//                     ),
//
//                     // Text(
//                     //   'In Words: ${NumberToWords.convertDouble(items[index]['amount'], precision: 2)}',
//                     //   style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
//                     // ),
//                   ],
//                 );
//               },
//             ),
//             SizedBox(height: 20),
//             ElevatedButton.icon(
//               onPressed: generatePDF,
//               icon: Icon(Icons.picture_as_pdf),
//               label: Text('Generate PDF'),
//               style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
