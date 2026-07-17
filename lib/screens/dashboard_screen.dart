import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'edit_transaction_screen.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import 'add_transaction_screen.dart';
import '../widgets/chart_widget.dart';
import '../services/pdf_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String search = "";
  final List<String> categories = [
    "All",
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
  String selectedCategory = "All";

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();
    final service = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Expense Tracker"),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () async {
              final snapshot = await service.getTransactions().first;

              await PdfService().generateExpenseReport(snapshot.docs);
            },
          ),
          IconButton(
            onPressed: () async {
              await auth.logout();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddTransactionScreen(),
            ),
          );
        },
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: service.getTransactions(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error:\n${snapshot.error}",
                textAlign: TextAlign.center,
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: Text("No data"),
            );
          }

          double income = 0;
          double expense = 0;

          double food = 0;
          double travel = 0;
          double shopping = 0;
          double bills = 0;
          double medical = 0;
          double entertainment = 0;
          double education = 0;
          double others = 0;

          final docs = snapshot.data!.docs;

          for (var doc in docs) {
            final data = doc.data() as Map<String, dynamic>;

            if (data["type"] == "Income") {
              income += (data["amount"] as num).toDouble();
            } else {
              expense += (data["amount"] as num).toDouble();
            }
            switch (data["category"]) {
              case "Food":
                food += data["amount"];
                break;

              case "Travel":
                travel += data["amount"];
                break;

              case "Shopping":
                shopping += data["amount"];
                break;

              case "Bills":
                bills += data["amount"];
                break;

              case "Medical":
                medical += data["amount"];
                break;

              case "Entertainment":
                entertainment += data["amount"];
                break;

              case "Education":
                education += data["amount"];
                break;

              default:
                others += data["amount"];
            }
          }

          double balance = income - expense;

          return Column(
            children: [
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(15),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    Text(
                      "Balance",
                      style: TextStyle(
                        color: Colors.white.withOpacity(.9),
                      ),
                    ),
                    Text(
                      "₹ ${balance.toStringAsFixed(2)}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const Text(
                              "Income",
                              style: TextStyle(color: Colors.white),
                            ),
                            Text(
                              "₹${income.toStringAsFixed(2)}",
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            const Text(
                              "Expense",
                              style: TextStyle(color: Colors.white),
                            ),
                            Text(
                              "₹${expense.toStringAsFixed(2)}",
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Expense Analytics",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: TextField(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: "Search Transactions",
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      search = value.toLowerCase();
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Filter by Category",
                  ),
                  items: categories
                      .map((c) => DropdownMenuItem(
                            value: c,
                            child: Text(c),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value!;
                    });
                  },
                ),
              ),
              ChartWidget(
                food: food,
                travel: travel,
                shopping: shopping,
                bills: bills,
                medical: medical,
                entertainment: entertainment,
                education: education,
                others: others,
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final title = data["title"].toString().toLowerCase();
                    final category = data["category"];

                    if (search.isNotEmpty && !title.contains(search)) {
                      return const SizedBox.shrink();
                    }

                    if (selectedCategory != "All" &&
                        category != selectedCategory) {
                      return const SizedBox.shrink();
                    }

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: data["type"] == "Income"
                            ? Colors.green
                            : Colors.red,
                        child: const Icon(
                          Icons.currency_rupee,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(data["title"]),
                      subtitle: Text(
                        "${data["category"]} • ${data["type"]}",
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "₹${data["amount"]}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          PopupMenuButton<String>(
                            onSelected: (value) async {
                              if (value == "edit") {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => EditTransactionScreen(
                                      id: docs[index].id,
                                      title: data["title"],
                                      amount:
                                          (data["amount"] as num).toDouble(),
                                      category: data["category"],
                                      type: data["type"],
                                    ),
                                  ),
                                );
                              }

                              if (value == "delete") {
                                bool? confirm = await showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text("Delete Transaction"),
                                    content: const Text(
                                        "Are you sure you want to delete this transaction?"),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text("Cancel"),
                                      ),
                                      ElevatedButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text("Delete"),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true) {
                                  await service
                                      .deleteTransaction(docs[index].id);
                                }
                              }
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(
                                value: "edit",
                                child: Text("Edit"),
                              ),
                              PopupMenuItem(
                                value: "delete",
                                child: Text("Delete"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
