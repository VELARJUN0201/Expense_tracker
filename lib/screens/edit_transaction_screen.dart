import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class EditTransactionScreen extends StatefulWidget {
  final String id;
  final String title;
  final double amount;
  final String category;
  final String type;

  const EditTransactionScreen({
    super.key,
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.type,
  });

  @override
  State<EditTransactionScreen> createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  late TextEditingController title;
  late TextEditingController amount;

  late String category;
  late String type;

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

  @override
  void initState() {
    super.initState();

    title = TextEditingController(text: widget.title);
    amount = TextEditingController(text: widget.amount.toString());

    category = widget.category;
    type = widget.type;
  }

  Future save() async {
    await service.updateTransaction(
      id: widget.id,
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
      appBar: AppBar(title: const Text("Edit Transaction")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            TextField(
              controller: title,
              decoration: const InputDecoration(labelText: "Title"),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: amount,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Amount"),
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField(
              value: category,
              items: categories
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (value) {
                setState(() => category = value!);
              },
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField(
              value: type,
              items: const [
                DropdownMenuItem(value: "Income", child: Text("Income")),
                DropdownMenuItem(value: "Expense", child: Text("Expense")),
              ],
              onChanged: (value) {
                setState(() => type = value!);
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: save,
              child: const Text("Update"),
            ),
          ],
        ),
      ),
    );
  }
}
