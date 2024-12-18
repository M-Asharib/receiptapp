import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfService {
  static Future<void> generateReceipt(Map<String, dynamic> receiptData) async {
    final pdf = pw.Document();

    final tableHeaders = ["QTY", "PARTICULARS", "RATE", "AMOUNT"];
    final items = receiptData['items'] ?? [];
    double totalAmount = 0;

    // Calculate total amount
    for (var item in items) {
      totalAmount += item['amount'] ?? 0;
    }

    // Convert total to words
    String totalInWords = _numberToWords(totalAmount.toInt());

    pdf.addPage(
      pw.Page(
        margin: pw.EdgeInsets.all(20),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Header Section
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text("Date: ${receiptData['date'] ?? ''}", style: pw.TextStyle(fontSize: 12)),
                pw.Text("BILL", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                pw.Text("S. No: ${receiptData['s_no'] ?? ''}", style: pw.TextStyle(fontSize: 12)),
              ],
            ),
            pw.SizedBox(height: 5),
            pw.Text("M/s: ${receiptData['ms'] ?? ''}", style: pw.TextStyle(fontSize: 12)),

            pw.SizedBox(height: 10),

            // Table Header
            pw.Container(
              decoration: pw.BoxDecoration(
                color: PdfColors.blue100,
                border: pw.Border.all(),
              ),
              child: pw.Row(
                children: tableHeaders.map((header) {
                  return pw.Expanded(
                    child: pw.Container(
                      alignment: pw.Alignment.center,
                      padding: pw.EdgeInsets.symmetric(vertical: 4),
                      child: pw.Text(header, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                  );
                }).toList(),
              ),
            ),

            // Table Rows
            ...items.map((item) {
              return pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Container(
                      alignment: pw.Alignment.center,
                      padding: pw.EdgeInsets.symmetric(vertical: 4),
                      child: pw.Text(item['qty'].toString(), style: pw.TextStyle(fontSize: 10)),
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Container(
                      alignment: pw.Alignment.centerLeft,
                      padding: pw.EdgeInsets.symmetric(vertical: 4),
                      child: pw.Text(item['particular'].toString(), style: pw.TextStyle(fontSize: 10)),
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Container(
                      alignment: pw.Alignment.center,
                      padding: pw.EdgeInsets.symmetric(vertical: 4),
                      child: pw.Text(item['rate'].toString(), style: pw.TextStyle(fontSize: 10)),
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Container(
                      alignment: pw.Alignment.center,
                      padding: pw.EdgeInsets.symmetric(vertical: 4),
                      child: pw.Text(item['amount'].toString(), style: pw.TextStyle(fontSize: 10)),
                    ),
                  ),
                ],
              );
            }).toList(),

            // Total Row
            pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border(
                  top: pw.BorderSide(width: 1, color: PdfColors.black),
                ),
              ),
              child: pw.Row(
                children: [
                  pw.Expanded(
                    flex: 3,
                    child: pw.Container(
                      alignment: pw.Alignment.centerRight,
                      padding: pw.EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      child: pw.Text("TOTAL:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Container(
                      alignment: pw.Alignment.center,
                      padding: pw.EdgeInsets.symmetric(vertical: 4),
                      child: pw.Text(totalAmount.toString(), style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),

            // Rupees Section
            pw.SizedBox(height: 10),
            pw.Text("Rupees: ${totalInWords} Only", style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),

            // Footer Section
            pw.SizedBox(height: 20),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text("", style: pw.TextStyle(fontSize: 12)),
                pw.Text("For, SUPERSOFT COMPUTERS", style: pw.TextStyle(fontSize: 12)),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Text("Receiver's Signature", style: pw.TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  // Function to Convert Numbers to Words
  static String _numberToWords(int number) {
    final List<String> units = [
      "", "One", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine", "Ten",
      "Eleven", "Twelve", "Thirteen", "Fourteen", "Fifteen", "Sixteen", "Seventeen", "Eighteen", "Nineteen"
    ];
    final List<String> tens = ["", "", "Twenty", "Thirty", "Forty", "Fifty", "Sixty", "Seventy", "Eighty", "Ninety"];

    if (number == 0) return "Zero";
    if (number < 20) return units[number];
    if (number < 100) return "${tens[number ~/ 10]} ${units[number % 10]}".trim();
    if (number < 1000) {
      return "${units[number ~/ 100]} Hundred ${_numberToWords(number % 100)}".trim();
    }
    if (number < 100000) {
      return "${_numberToWords(number ~/ 1000)} Thousand ${_numberToWords(number % 1000)}".trim();
    }
    if (number < 10000000) {
      return "${_numberToWords(number ~/ 100000)} Lakh ${_numberToWords(number % 100000)}".trim();
    }
    return "${_numberToWords(number ~/ 10000000)} Crore ${_numberToWords(number % 10000000)}".trim();
  }
}

// import 'dart:typed_data';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:printing/printing.dart';
//
// class PdfService {
//   static Future<void> generateReceipt(Map<String, dynamic> receiptData) async {
//     final pdf = pw.Document();
//
//     final tableHeaders = ["QTY", "PARTICULARS", "RATE", "AMOUNT"];
//     final items = receiptData['items'] ?? [];
//     double totalAmount = 0;
//
//     // Calculate total amount
//     for (var item in items) {
//       totalAmount += item['amount'] ?? 0;
//     }
//
//     pdf.addPage(
//       pw.Page(
//         margin: pw.EdgeInsets.all(20),
//         build: (context) => pw.Column(
//           crossAxisAlignment: pw.CrossAxisAlignment.start,
//           children: [
//             // Header Section
//             pw.Row(
//               mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//               children: [
//                 pw.Text("Date: ${receiptData['date'] ?? ''}", style: pw.TextStyle(fontSize: 12)),
//                 pw.Text("BILL", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
//                 pw.Text("S. No: ${receiptData['s_no'] ?? ''}", style: pw.TextStyle(fontSize: 12)),
//               ],
//             ),
//             pw.SizedBox(height: 5),
//             pw.Text("M/s: ${receiptData['ms'] ?? ''}", style: pw.TextStyle(fontSize: 12)),
//
//             pw.SizedBox(height: 10),
//
//             // Table Header
//             pw.Container(
//               decoration: pw.BoxDecoration(
//                 color: PdfColors.blue100,
//                 border: pw.Border.all(),
//               ),
//               child: pw.Row(
//                 children: tableHeaders.map((header) {
//                   return pw.Expanded(
//                     child: pw.Container(
//                       alignment: pw.Alignment.center,
//                       padding: pw.EdgeInsets.symmetric(vertical: 4),
//                       child: pw.Text(header, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
//                     ),
//                   );
//                 }).toList(),
//               ),
//             ),
//
//             // Table Rows
//             ...items.map((item) {
//               return pw.Row(
//                 children: [
//                   pw.Expanded(
//                     child: pw.Container(
//                       alignment: pw.Alignment.center,
//                       padding: pw.EdgeInsets.symmetric(vertical: 4),
//                       child: pw.Text(item['qty'].toString(), style: pw.TextStyle(fontSize: 10)),
//                     ),
//                   ),
//                   pw.Expanded(
//                     child: pw.Container(
//                       alignment: pw.Alignment.centerLeft,
//                       padding: pw.EdgeInsets.symmetric(vertical: 4),
//                       child: pw.Text(item['particular'].toString(), style: pw.TextStyle(fontSize: 10)),
//                     ),
//                   ),
//                   pw.Expanded(
//                     child: pw.Container(
//                       alignment: pw.Alignment.center,
//                       padding: pw.EdgeInsets.symmetric(vertical: 4),
//                       child: pw.Text(item['rate'].toString(), style: pw.TextStyle(fontSize: 10)),
//                     ),
//                   ),
//                   pw.Expanded(
//                     child: pw.Container(
//                       alignment: pw.Alignment.center,
//                       padding: pw.EdgeInsets.symmetric(vertical: 4),
//                       child: pw.Text(item['amount'].toString(), style: pw.TextStyle(fontSize: 10)),
//                     ),
//                   ),
//                 ],
//               );
//             }).toList(),
//
//             // Total Row
//             pw.Container(
//               decoration: pw.BoxDecoration(
//                 border: pw.Border(
//                   top: pw.BorderSide(width: 1, color: PdfColors.black),
//                 ),
//               ),
//               child: pw.Row(
//                 children: [
//                   pw.Expanded(
//                     flex: 3,
//                     child: pw.Container(
//                       alignment: pw.Alignment.centerRight,
//                       padding: pw.EdgeInsets.symmetric(vertical: 4, horizontal: 8),
//                       child: pw.Text("TOTAL:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
//                     ),
//                   ),
//                   pw.Expanded(
//                     child: pw.Container(
//                       alignment: pw.Alignment.center,
//                       padding: pw.EdgeInsets.symmetric(vertical: 4),
//                       child: pw.Text(totalAmount.toString(), style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//
//             // Footer Section
//             pw.SizedBox(height: 20),
//             pw.Row(
//               mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//               children: [
//                 pw.Text("Rupees:", style: pw.TextStyle(fontSize: 12)),
//                 pw.Text("For, SUPERSOFT COMPUTERS", style: pw.TextStyle(fontSize: 12)),
//               ],
//             ),
//             pw.SizedBox(height: 20),
//             pw.Text("Receiver's Signature", style: pw.TextStyle(fontSize: 12)),
//           ],
//         ),
//       ),
//     );
//
//     await Printing.layoutPdf(
//       onLayout: (PdfPageFormat format) async => pdf.save(),
//     );
//   }
// }