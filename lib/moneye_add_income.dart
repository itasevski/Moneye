import 'package:flutter/material.dart';
import 'dart:core';
import 'moneye_income.dart';

class AddIncome extends StatefulWidget {
  final IncomeAddCallback incomeCallback;

  const AddIncome(this.incomeCallback);

  @override
  State<StatefulWidget> createState() {
    return _AddIncomeState(this.incomeCallback);
  }
}

class _AddIncomeState extends State<AddIncome> {
  IncomeAddCallback incomeCallback;

  _AddIncomeState(this.incomeCallback);

  final amountController = TextEditingController();
  final dayOfIncomeController = TextEditingController();
  final workplaceController = TextEditingController();
  final positionController = TextEditingController();

  List<String> currencies = ["EUR", "MKD", "USD", "GBP"];
  String selectedCurrency = "EUR";

  void _onSubmit() {
    incomeCallback(
        amountController.text,
        selectedCurrency,
        workplaceController.text,
        dayOfIncomeController.text,
        positionController.text);

    setState(() {
      amountController.text = "";
      selectedCurrency = "EUR";

      dayOfIncomeController.text = "";
      workplaceController.text = "";
      positionController.text = "";
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Income successfully added.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Income Information'),
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
                            labelText: 'Income Amount',
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
                        TextFormField(
                          controller: workplaceController,
                          decoration: const InputDecoration(
                            filled: true,
                            hintText: 'Enter workplace',
                            labelText: 'Workplace',
                          ),
                        ),
                        TextFormField(
                          controller: dayOfIncomeController,
                          decoration: const InputDecoration(
                            filled: true,
                            hintText:
                                'Enter the day of income receival (day of month)',
                            labelText: 'Day of income',
                          ),
                        ),
                        TextFormField(
                          controller: positionController,
                          decoration: const InputDecoration(
                            filled: true,
                            hintText: 'Enter work position',
                            labelText: 'Work Position',
                          ),
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
