import 'package:flutter/material.dart';
import 'package:hive_expenses_tracker/boxes.dart';
import 'package:hive_expenses_tracker/models/transaction.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

class TransactionPage extends StatefulWidget {
  const TransactionPage({Key? key}) : super(key: key);

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  @override
  void dispose() {
    Hive.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Hive Expense Tracker'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => showDialog(
              context: context,
              builder: (context) => buildDeleteDialog(),
            ),
            icon: const Icon(Icons.delete),
          ),
        ],
      ),
      body: ValueListenableBuilder<Box<Transaction>>(
        valueListenable: Boxes.getTranscations().listenable(),
        builder: (context, box, _) {
          final transactions = box.values.toList().cast<Transaction>();
          return buildContent(transactions);
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(
          context: context,
          builder: (context) => buildAddDialog(context),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget buildContent(List<Transaction> list) {
    double netCredit = 0;
    for (var element in list) {
      if (element.isExpense == true) {
        netCredit -= element.amount;
      } else {
        netCredit += element.amount;
      }
    }
    if (list.isEmpty) {
      return const Center(
        child: Text(
          'No Expenses Yet!',
          style: TextStyle(fontSize: 20.0),
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: Column(
          children: [
            Text(
              'Net Credit: £E $netCredit',
              style: const TextStyle(
                fontSize: 20.0,
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10.0),
            Expanded(
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(10.0),
                itemBuilder: (context, index) => buildExpenseCard(list[index]),
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 10.0),
                itemCount: list.length,
              ),
            ),
          ],
        ),
      );
    }
  }

  Future deleteAllTransactions() async {
    final box = Boxes.getTranscations();
    box.clear();
  }

  Future addTransaction(String title, double amount, bool isExpense) async {
    final transaction = Transaction()
      ..title = title
      ..amount = amount
      ..createdDate = DateTime.now()
      ..isExpense = isExpense;
    //setState(() => _transactions.add(transaction));
    final box = Boxes.getTranscations();
    box.add(transaction);
  }

  Future editTransaction(
    Transaction transaction,
    String title,
    double amount,
    bool isExpense,
  ) async {
    setState(() {
      transaction.title = title;
      transaction.amount = amount;
      transaction.isExpense = isExpense;
    });
  }

  Future deleteTransaction(Transaction transaction) async {
    transaction.delete();
  }

  Widget buildDeleteDialog() {
    return AlertDialog(
      title: const Text('Are you sure ?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => deleteAllTransactions().then((value) {
            Navigator.pop(context);
          }),
          child: const Text('Delete'),
        ),
      ],
    );
  }

  Widget buildAddDialog(context) {
    bool selectedValue = true;
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    return AlertDialog(
      title: const Text('Add Transaction'),
      content: StatefulBuilder(
        builder: ((context, setState) {
          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    hintText: 'Enter Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10.0),
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(
                    hintText: 'Enter Amount',
                    border: OutlineInputBorder(),
                  ),
                ),
                Row(
                  children: [
                    Row(
                      children: [
                        Radio(
                          value: true,
                          groupValue: selectedValue,
                          onChanged: (bool? value) {
                            setState(() {
                              selectedValue = value!;
                            });
                          },
                        ),
                        const Text('Expense'),
                      ],
                    ),
                    Row(
                      children: [
                        Radio(
                          value: false,
                          groupValue: selectedValue,
                          onChanged: (bool? value) {
                            setState(() {
                              selectedValue = value!;
                            });
                          },
                        ),
                        const Text('Income'),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => addTransaction(
            titleController.text,
            double.parse(amountController.text),
            selectedValue,
          ).then((value) {
            Navigator.pop(context);
          }),
          child: const Text('Add'),
        ),
      ],
    );
  }

  Widget buildEditDialog(context, Transaction transaction) {
    bool selectedValue = transaction.isExpense;
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    titleController.text = transaction.title;
    amountController.text = transaction.amount.toString();
    return AlertDialog(
      title: const Text('Edit Transaction'),
      content: StatefulBuilder(
        builder: ((context, setState) {
          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    hintText: transaction.title,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10.0),
                TextField(
                  controller: amountController,
                  decoration: InputDecoration(
                    hintText: transaction.amount.toString(),
                    border: const OutlineInputBorder(),
                  ),
                ),
                Row(
                  children: [
                    Row(
                      children: [
                        Radio(
                          value: true,
                          groupValue: selectedValue,
                          onChanged: (bool? value) {
                            setState(() {
                              selectedValue = value!;
                            });
                          },
                        ),
                        const Text('Expense'),
                      ],
                    ),
                    Row(
                      children: [
                        Radio(
                          value: false,
                          groupValue: selectedValue,
                          onChanged: (bool? value) {
                            setState(() {
                              selectedValue = value!;
                            });
                          },
                        ),
                        const Text('Income'),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => editTransaction(
            transaction,
            titleController.text,
            double.parse(amountController.text),
            selectedValue,
          ).then((value) {
            Navigator.pop(context);
          }),
          child: const Text('Save'),
        ),
      ],
    );
  }

  Widget buildExpenseCard(Transaction transaction) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: const [
            BoxShadow(
              offset: Offset(1, 2),
              blurRadius: 5,
              color: Colors.black45,
            ),
          ],
        ),
        child: Theme(
          data: ThemeData(
            colorScheme: const ColorScheme.light(
              secondary: Colors.black,
              primary: Colors.black,
            ),
            dividerColor: Colors.transparent,
          ),
          child: ExpansionTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      transaction.title,
                      style: const TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5.0),
                    Text(
                      DateFormat('yMMMd').format(transaction.createdDate),
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 12.0,
                      ),
                    ),
                  ],
                ),
                Text(
                  '£E ${transaction.amount.toString()}',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: transaction.isExpense ? Colors.red : Colors.green,
                  ),
                ),
              ],
            ),
            children: [
              SizedBox(
                height: 30.0,
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit'),
                        onPressed: () => showDialog(
                            context: context,
                            builder: (context) {
                              return buildEditDialog(context, transaction);
                            }),
                      ),
                    ),
                    Expanded(
                      child: TextButton.icon(
                        icon: const Icon(Icons.close),
                        label: const Text('Delete'),
                        onPressed: () => deleteTransaction(transaction),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      );
}
