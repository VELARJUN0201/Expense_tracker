import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final title = TextEditingController();
  final amount = TextEditingController();

  String category = "Food";
  String type = "Expense";

  final service = FirestoreService();

  final categories = [
    "Food",
    "Travel",
    "Shopping",
    "Bills",
    "Medical",
    "Salary",
    "Entertainment",
    "Education",
    "Others"
  ];

  Future save() async {
    if (title.text.isEmpty || amount.text.isEmpty) {
      return;
    }

    await service.addTransaction(
      title: title.text,
      amount: double.parse(amount.text),
      category: category,
      type: type,
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Transaction"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            TextField(
              controller: title,
              decoration: const InputDecoration(
                labelText: "Title",
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: amount,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Amount",
              ),
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField(
              value: category,
              items: categories.map((e) {
                return DropdownMenuItem(
                  value: e,
                  child: Text(e),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  category = value!;
                });
              },
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField(
              value: type,
              items: const [
                DropdownMenuItem(
                  value: "Income",
                  child: Text("Income"),
                ),
                DropdownMenuItem(
                  value: "Expense",
                  child: Text("Expense"),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  type = value!;
                });
              },
            ),
            const SizedBox(height: 25),
            ElevatedButton(
              onPressed: save,
              child: const Text("Save"),
            )
          ],
        ),
      ),
    );
  }
}
