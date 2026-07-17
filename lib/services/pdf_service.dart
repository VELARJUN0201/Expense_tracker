import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfService {
  Future<void> generateExpenseReport(
    List<QueryDocumentSnapshot> docs,
  ) async {
    final pdf = pw.Document();

    double income = 0;
    double expense = 0;

    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;

      if (data["type"] == "Income") {
        income += (data["amount"] as num).toDouble();
      } else {
        expense += (data["amount"] as num).toDouble();
      }
    }

    final balance = income - expense;

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              "Expense Tracker Report",
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Table.fromTextArray(
            headers: ["Title", "Category", "Type", "Amount"],
            data: docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;

              return [
                data["title"],
                data["category"],
                data["type"],
                "₹${data["amount"]}",
              ];
            }).toList(),
          ),
          pw.SizedBox(height: 20),
          pw.Text("Income : ₹${income.toStringAsFixed(2)}"),
          pw.Text("Expense : ₹${expense.toStringAsFixed(2)}"),
          pw.Text("Balance : ₹${balance.toStringAsFixed(2)}"),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }
}
