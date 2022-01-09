import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:planner/moneye_add_expense.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:core';
import 'moneye_add_expense.dart';

class AddExpenseCategory extends StatefulWidget {
  final GetExpenseCategories getCallback;
  final List<dynamic> expenseCategories;

  const AddExpenseCategory(this.getCallback, this.expenseCategories);

  @override
  State<StatefulWidget> createState() {
    return _AddExpenseCategoryState(this.getCallback, this.expenseCategories);
  }
}

class _AddExpenseCategoryState extends State<AddExpenseCategory> {
  final expenseCategoryController = TextEditingController();

  GetExpenseCategories getCallback;
  List<dynamic> expenseCategories;

  _AddExpenseCategoryState(this.getCallback, this.expenseCategories);

  void _submitExpenseCategory() {
    setState(() {
      expenseCategories.add(expenseCategoryController.text);
      expenseCategoryController.text = "";
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Category successfully added.')),
    );

    _setExpenseCategories();
    getCallback();
  }

  void _setExpenseCategories() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    if (preferences.containsKey("expenseCategories")) {
      preferences.remove("expenseCategories");
    }
    preferences.setString("expenseCategories", jsonEncode(expenseCategories));
  }

  Widget _listExpenseCategories() {
    return ListView.builder(
      itemCount: expenseCategories.length,
      itemBuilder: (context, index) {
        return Card(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                  leading: Icon(Icons.access_time_filled),
                  title: Text(expenseCategories[index],
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  trailing: Container(
                      child: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              expenseCategories.removeAt(index);
                            });

                            _setExpenseCategories();
                            getCallback();
                          }))),
            ],
          ),
        );
      },
    );
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Add Category'),
        ),
        body: Column(mainAxisSize: MainAxisSize.min, children: [
          SizedBox(
            child: Form(
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
                                controller: expenseCategoryController,
                                decoration: const InputDecoration(
                                  filled: true,
                                  hintText: 'Enter category',
                                  labelText: 'Expense Category',
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
                                onPressed: _submitExpenseCategory),
                            // Card(
                            //   child:_listCategories;
                            // )
                            // _listExpenseCategories()
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 25),
          SizedBox(
            height: MediaQuery.of(context).size.height / 4,
            child: _listExpenseCategories(),
          )
        ]));
  }
}
