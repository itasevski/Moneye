import 'package:flutter/material.dart';
import 'package:planner/moneye_home.dart';

class Savings extends StatefulWidget {
  final SavingsCallback callback;

  const Savings(this.callback);

  @override
  State<StatefulWidget> createState() {
    return _SavingsState(this.callback);
  }
}

class _SavingsState extends State<Savings> {
  final savingsController = TextEditingController();

  SavingsCallback callback;

  List<String> currencies = ["EUR", "MKD", "USD", "GBP"];
  String selectedCurrency = "EUR";

  _SavingsState(this.callback);

  void _onSubmit() {
    double amount = 0;

    if (selectedCurrency == "USD") {
      amount = double.parse(savingsController.text) * 0.88;
    } else if (selectedCurrency == "GBP") {
      amount = double.parse(savingsController.text) * 1.179;
    } else if (selectedCurrency == "MKD") {
      amount = double.parse(savingsController.text) * 0.0162;
    } else {
      amount = double.parse(savingsController.text);
    }

    callback(amount);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Savings amount successfully updated.')),
    );

    setState(() {
      savingsController.text = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text("Set savings", style: TextStyle(fontSize: 25))),
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
                          controller: savingsController,
                          decoration: const InputDecoration(
                            filled: true,
                            hintText: 'Enter your saving amount',
                            labelText: 'Saving amount',
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
