import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart' as intl;
import 'dart:core';
import 'moneye_datepicker.dart';
import 'moneye_expenses.dart';
import 'moneye_add_expense_category.dart';

typedef GetExpenseCategories = Future<void> Function();

class AddExpense extends StatefulWidget {
  final ExpensesAddCallback expensesCallback;

  const AddExpense(this.expensesCallback);

  @override
  State<StatefulWidget> createState() {
    return _AddExpenseState(this.expensesCallback);
  }
}

class _AddExpenseState extends State<AddExpense> {
  ExpensesAddCallback expensesCallback;

  List<dynamic> expenseCategories = ["Food", "Clothes", "Petrol", "Gym"];
  String selectedCategory = "Food";

  final amountController = TextEditingController();

  DateTime createdOn = DateTime.now();
  String formattedDate = "";

  List<String> currencies = ["EUR", "MKD", "USD", "GBP"];
  String selectedCurrency = "EUR";

  _AddExpenseState(this.expensesCallback);

  void _addCustomExpenseCategory() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                AddExpenseCategory(_getExpenseCategories, expenseCategories)));
  }

  @override
  void initState() {
    super.initState();

    _getExpenseCategories();
  }

  void addCustomExpenseCategory(String category) {
    setState(() {
      expenseCategories.add(
        category,
      );
    });

    _setExpenseCategories();
  }

  void _onSubmit() {
    if (formattedDate == "") {
      setState(() {
        formattedDate = intl.DateFormat('dd/MM/yyyy kk:mm').format(createdOn);
      });
    }

    expensesCallback(amountController.text, selectedCategory, selectedCurrency,
        formattedDate);

    setState(() {
      amountController.text = "";
      selectedCategory = "Food";
      selectedCurrency = "EUR";
      createdOn = DateTime.now();
      formattedDate = intl.DateFormat('dd/MM/yyyy kk:mm').format(createdOn);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Expense successfully added.')),
    );
  }

  Future<void> _getExpenseCategories() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    if (preferences.containsKey("expenseCategories")) {
      String jsonExpenses = preferences.getString("expenseCategories");
      var listCategories = jsonDecode(jsonExpenses);
      setState(() {
        expenseCategories = listCategories;
      });
    }
  }

  void _setExpenseCategories() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    if (preferences.containsKey("expenseCategories")) {
      preferences.remove("expenseCategories");
    }
    preferences.setString("expenseCategories", jsonEncode(expenseCategories));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Expense'),
      ),
      body: Form(
        child: Scrollbar(
          child: Align(
            alignment: Alignment.topCenter,
            child: Card(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ...[
                        TextFormField(
                          controller: amountController,
                          decoration: const InputDecoration(
                            filled: true,
                            hintText: 'Enter amount',
                            labelText: 'Expense Amount',
                          ),
                        ),
                        DropdownButton<String>(
                          value: selectedCurrency,
                          icon: const Icon(Icons.arrow_downward),
                          elevation: 16,
                          style: const TextStyle(color: Colors.deepPurple),
                          underline: Container(
                            height: 2,
                            color: Colors.deepPurpleAccent,
                          ),
                          onChanged: (String newValue) {
                            setState(() {
                              selectedCurrency = newValue;
                            });
                          },
                          items: currencies
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                        Column(
                          children: [
                            DropdownButton<dynamic>(
                              value: selectedCategory,
                              icon: const Icon(Icons.arrow_downward),
                              elevation: 16,
                              style: const TextStyle(color: Colors.deepPurple),
                              underline: Container(
                                height: 2,
                                color: Colors.deepPurpleAccent,
                              ),
                              onChanged: (dynamic newValue) {
                                setState(() {
                                  selectedCategory = newValue;
                                });
                              },
                              items: expenseCategories
                                  .map<DropdownMenuItem<dynamic>>(
                                      (dynamic value) {
                                return DropdownMenuItem<dynamic>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            )
                          ],
                        ),
                        FormDatePicker(
                          date: createdOn,
                          onChanged: (value) {
                            setState(() {
                              setState(() {
                                createdOn = value;
                                formattedDate =
                                    intl.DateFormat('dd/MM/yyyy kk:mm')
                                        .format(createdOn);
                              });
                            });
                          },
                        ),
                      ].expand(
                        (widget) => [
                          widget,
                          const SizedBox(
                            height: 24,
                          )
                        ],
                      ),
                      ElevatedButton(
                        child: const Text('Submit'),
                        onPressed: _onSubmit,
                      ),
                      ElevatedButton(
                        child: const Text('Add custom category'),
                        onPressed: _addCustomExpenseCategory,
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
