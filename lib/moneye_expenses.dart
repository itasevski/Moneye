import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:planner/moneye_add_expense.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:core';
import 'moneye_home.dart';

typedef ExpensesAddCallback = void Function(
    String amount, String category, String currency, String date);

class Expenses extends StatefulWidget {
  final TotalExpenses callback;

  const Expenses(this.callback);

  @override
  State<StatefulWidget> createState() {
    return ExpensesState(this.callback);
  }
}

class ExpensesState extends State<Expenses> {
  List<dynamic> expenses = [];

  TotalExpenses callback;

  ExpensesState(this.callback);

  @override
  void initState() {
    super.initState();

    _getExpenses();
  }

  double convertToEuro(String amount, String currency) {
    double amountToEUR = 0;

    if (currency == "USD") {
      amountToEUR = double.parse(amount) * 0.88;
    } else if (currency == "GBP") {
      amountToEUR = double.parse(amount) * 1.179;
    } else if (currency == "MKD") {
      amountToEUR = double.parse(amount) * 0.0162;
    } else {
      amountToEUR = double.parse(amount);
    }

    return amountToEUR;
  }

  void _getExpenses() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    if (preferences.containsKey("expenses")) {
      String jsonExpenses = preferences.getString("expenses");
      var listExpenses = jsonDecode(jsonExpenses);
      setState(() {
        expenses = listExpenses;
      });
    }
  }

  void _setExpenses() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    if (preferences.containsKey("expenses")) {
      preferences.remove("expenses");
    }
    preferences.setString("expenses", jsonEncode(expenses));
  }

  void _addExpense(
      String amount, String category, String currency, String date) {
    setState(() {
      expenses.add({
        "amount": amount,
        "category": category,
        "currency": currency,
        "date": date
      });
    });

    _setExpenses();
    _setTotalExpensesByCategory(category + "(category)", amount, currency);
    _updateBalance(amount, currency);
    _updateBudget(amount, currency);
    _calculateAndSetTotalExpenses();
  }

  void _updateBalance(String amount, String currency) async {
    double amountToEUR = convertToEuro(amount, currency);

    SharedPreferences preferences = await SharedPreferences.getInstance();
    if (preferences.containsKey("currentBalance")) {
      double currentBalance = preferences.get("currentBalance");
      if (currentBalance - amountToEUR < 0) {
        currentBalance = 0;
      } else {
        currentBalance = currentBalance - amountToEUR;
      }
      preferences.setDouble("currentBalance", currentBalance);
    }
  }

  void _updateBudget(String amount, String currency) async {
    double amountToEUR = convertToEuro(amount, currency);

    SharedPreferences preferences = await SharedPreferences.getInstance();
    if (preferences.containsKey("currentBudget")) {
      double currentBudget = preferences.get("currentBudget");
      if (currentBudget - amountToEUR < 0) {
        if (preferences.containsKey("currentSavingsAmount")) {
          double currentSavings = preferences.get("currentSavingsAmount");
          currentSavings = currentSavings + (currentBudget - amountToEUR);
          if (currentSavings < 0) {
            currentSavings = 0;
          }
          preferences.setDouble("currentSavingsAmount", currentSavings);
        }
        currentBudget = 0;
      } else {
        currentBudget = currentBudget - amountToEUR;
      }
      preferences.setDouble("currentBudget", currentBudget);
    }
  }

  void _setTotalExpensesByCategory(
      String category, String amount, String currency) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    double prefsAmount = convertToEuro(amount, currency);

    if (preferences.containsKey(category)) {
      double current = preferences.get(category);
      current += prefsAmount;
      preferences.setDouble(category, current);
    } else {
      preferences.setDouble(category, prefsAmount);
    }
  }

  void _calculateAndSetTotalExpenses() async {
    double total = 0;

    for (int i = 0; i < expenses.length; i++) {
      double value =
          convertToEuro(expenses[i]["amount"], expenses[i]["currency"]);

      total += value;
    }

    SharedPreferences preferences = await SharedPreferences.getInstance();
    if (preferences.containsKey("totalExpenses")) {
      preferences.remove("totalExpenses");
    }
    preferences.setDouble("totalExpenses", total);

    callback();
  }

  void _showAddExpenseForm() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => AddExpense(_addExpense)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("List of expenses", style: TextStyle(fontSize: 25)),
          actions: [
            ElevatedButton(
                child: Text("CLEAR", style: TextStyle(fontSize: 16)),
                onPressed: () {
                  setState(() {
                    expenses = [];

                    _setExpenses();
                  });
                })
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: _showAddExpenseForm,
        ),
        body: ListView.builder(
          itemCount: expenses.length,
          itemBuilder: (context, index) {
            return Card(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                      minVerticalPadding: 15,
                      leading: Icon(Icons.access_time_filled, size: 35),
                      title: Container(
                          margin: EdgeInsets.only(bottom: 10),
                          child: Text(
                              expenses[index]["amount"].toString() +
                                  expenses[index]["currency"],
                              style: TextStyle(
                                  fontSize: 27, fontWeight: FontWeight.bold))),
                      subtitle: Text(
                          expenses[index]["category"].toString() +
                              "\n" +
                              expenses[index]["date"].toString(),
                          style: TextStyle(fontSize: 21)),
                      trailing: Container(
                          child: IconButton(
                              icon: Icon(Icons.delete,
                                  color: Colors.red, size: 35),
                              onPressed: () {
                                setState(() {
                                  expenses.removeAt(index);

                                  _setExpenses();
                                });
                              }))),
                ],
              ),
            );
          },
        ));
  }
}
