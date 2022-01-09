import 'package:flutter/material.dart';
import 'package:planner/moneye_home.dart';

class Budget extends StatefulWidget {
  final BudgetCallback callback;

  const Budget(this.callback);

  @override
  State<StatefulWidget> createState() {
    return _BudgetState(this.callback);
  }
}

class _BudgetState extends State<Budget> {
  final budgetController = TextEditingController();

  BudgetCallback callback;

  List<String> currencies = ["EUR", "MKD", "USD", "GBP"];
  String selectedCurrency = "EUR";

  _BudgetState(this.callback);

  void _onSubmit() {
    double amount = 0;

    if (selectedCurrency == "USD") {
      amount = double.parse(budgetController.text) * 0.88;
    } else if (selectedCurrency == "GBP") {
      amount = double.parse(budgetController.text) * 1.179;
    } else if (selectedCurrency == "MKD") {
      amount = double.parse(budgetController.text) * 0.0162;
    } else {
      amount = double.parse(budgetController.text);
    }

    callback(amount);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Budget amount successfully updated.')),
    );

    setState(() {
      budgetController.text = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Set budget", style: TextStyle(fontSize: 25))),
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
                          controller: budgetController,
                          decoration: const InputDecoration(
                            filled: true,
                            hintText: 'Enter your spending budget',
                            labelText: 'Budget amount',
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
                        Container(
                            margin: EdgeInsets.only(top: 25),
                            child: ElevatedButton(
                              child: const Text('Submit'),
                              onPressed: _onSubmit,
                            ))
                      ]
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
