import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:planner/moneye_home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'moneye_add_income.dart';
import 'package:intl/intl.dart' as intl;

typedef IncomeAddCallback = void Function(String amount, String currency,
    String workplace, String dayOfIncome, String position);

class Income extends StatefulWidget {
  final TotalIncome callback;

  const Income(this.callback);

  @override
  State<StatefulWidget> createState() {
    return _IncomeState(this.callback);
  }
}

class _IncomeState extends State<Income> {
  List<dynamic> incomeSources = [];
  List<dynamic> incomeList = [];

  TotalIncome callback;

  _IncomeState(this.callback);

  @override
  void initState() {
    super.initState();

    _getIncomeSources();
    _getIncomeList();
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

  void _addIncome(String amount, String currency, String workplace,
      String dayOfIncome, String position) {
    setState(() {
      incomeSources.add({
        "amount": amount,
        "currency": currency,
        "workplace": workplace,
        "dayOfIncome": dayOfIncome,
        "position": position
      });
    });

    _setIncomeSources();
    _logIncome();
  }

  void _updateBalance(String amount, String currency) async {
    double amountToEUR = convertToEuro(amount, currency);

    SharedPreferences preferences = await SharedPreferences.getInstance();
    if (preferences.containsKey("currentBalance")) {
      double currentBalance = preferences.get("currentBalance");
      currentBalance = currentBalance + amountToEUR;
      preferences.setDouble("currentBalance", currentBalance);
    } else {
      preferences.setDouble("currentBalance", amountToEUR);
    }
  }

  void _setTotalIncomeByWorkplace(
      String workplace, String amount, String currency) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    double prefsAmount = convertToEuro(amount, currency);

    if (preferences.containsKey(workplace)) {
      double current = preferences.get(workplace);
      current += prefsAmount;
      preferences.setDouble(workplace, current);
    } else {
      preferences.setDouble(workplace, prefsAmount);
    }
  }

  void _calculateAndSetTotalIncome() async {
    double total = 0;

    for (int i = 0; i < incomeList.length; i++) {
      double value =
          convertToEuro(incomeList[i]["amount"], incomeList[i]["currency"]);

      total += value;
    }

    SharedPreferences preferences = await SharedPreferences.getInstance();
    if (preferences.containsKey("totalIncome")) {
      preferences.remove("totalIncome");
    }
    preferences.setDouble("totalIncome", total);

    callback();
  }

  void _logIncome() {
    DateTime now = DateTime.now();
    bool flag = false;

    for (int i = 0; i < incomeSources.length; i++) {
      flag = false;
      for (int j = 0; j < incomeList.length; j++) {
        if (incomeSources[i]["workplace"] == incomeList[j]["workplace"] &&
            now.month == incomeList[j]["month"]) {
          flag = true;
        }
      }
      if (now.day == int.parse(incomeSources[i]["dayOfIncome"]) &&
          flag == false) {
        setState(() {
          incomeList.add({
            "amount": incomeSources[i]["amount"],
            "currency": incomeSources[i]["currency"],
            "workplace": incomeSources[i]["workplace"],
            "date": intl.DateFormat("dd/MM/yyyy kk:mm").format(now),
            "month": now.month
          });
        });

        _setIncomeList();
        _updateBalance(
            incomeSources[i]["amount"], incomeSources[i]["currency"]);
        _setTotalIncomeByWorkplace(
            incomeSources[i]["workplace"] + "(workplace)",
            incomeSources[i]["amount"],
            incomeSources[i]["currency"]);
      }
    }

    _calculateAndSetTotalIncome();
  }

  void _showAddIncomeForm() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => AddIncome(_addIncome)));
  }

  void _getIncomeSources() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    if (preferences.containsKey("incomeSources")) {
      String jsonIncomeSources = preferences.getString("incomeSources");
      var listIncomeSources = jsonDecode(jsonIncomeSources);
      setState(() {
        incomeSources = listIncomeSources;
      });
    }
  }

  void _setIncomeSources() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    if (preferences.containsKey("incomeSources")) {
      preferences.remove("incomeSources");
    }
    preferences.setString("incomeSources", jsonEncode(incomeSources));
  }

  void _getIncomeList() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    if (preferences.containsKey("incomeList")) {
      String jsonIncomeList = preferences.getString("incomeList");
      var decodedIncomeList = jsonDecode(jsonIncomeList);
      setState(() {
        incomeList = decodedIncomeList;
      });
    }

    _logIncome();
  }

  void _setIncomeList() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    if (preferences.containsKey("incomeList")) {
      preferences.remove("incomeList");
    }
    preferences.setString("incomeList", jsonEncode(incomeList));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text("Income information", style: TextStyle(fontSize: 27))),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: _showAddIncomeForm,
        ),
        body: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
                margin: EdgeInsets.only(top: 25),
                padding: EdgeInsets.only(bottom: 10, left: 15),
                child: Align(
                    alignment: Alignment.topLeft,
                    child: Text("Income sources",
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)))),
            SizedBox(
                height: MediaQuery.of(context).size.height / 4,
                child: ListView.builder(
                    itemCount: incomeSources.length,
                    itemBuilder: (context, index) {
                      return Card(
                          child: Column(children: [
                        ListTile(
                            leading: Icon(Icons.access_time_filled, size: 35),
                            title: Container(
                                child: Text(
                                    incomeSources[index]["amount"].toString() +
                                        incomeSources[index]["currency"]
                                            .toString(),
                                    style: TextStyle(
                                        fontSize: 27,
                                        fontWeight: FontWeight.bold))),
                            subtitle: Text(
                                incomeSources[index]["workplace"].toString() +
                                    "\n" +
                                    incomeSources[index]["position"].toString(),
                                style: TextStyle(fontSize: 21)),
                            trailing: Container(
                                child: IconButton(
                                    icon: Icon(Icons.delete,
                                        color: Colors.red, size: 35),
                                    onPressed: () {
                                      setState(() {
                                        incomeSources.removeAt(index);
                                      });
                                      _setIncomeSources();
                                    })))
                      ]));
                    })),
            Container(
                margin: EdgeInsets.only(top: 50),
                padding: EdgeInsets.only(bottom: 10, left: 15, right: 20),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Income logs",
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold)),
                        ElevatedButton(
                            child:
                                Text("CLEAR", style: TextStyle(fontSize: 16)),
                            onPressed: () {
                              setState(() {
                                incomeList = [];
                              });
                              _setIncomeList();
                            },
                            style:
                                ElevatedButton.styleFrom(primary: Colors.green))
                      ]),
                )),
            SizedBox(
                height: MediaQuery.of(context).size.height / 2,
                child: ListView.builder(
                    itemCount: incomeList.length,
                    itemBuilder: (context, index) {
                      return Card(
                          child: Column(children: [
                        ListTile(
                            leading: Icon(Icons.access_time_filled, size: 35),
                            title: Container(
                                child: Text(
                                    incomeList[index]["amount"].toString() +
                                        incomeList[index]["currency"],
                                    style: TextStyle(
                                        fontSize: 27,
                                        fontWeight: FontWeight.bold))),
                            subtitle: Text(
                                incomeList[index]["workplace"].toString() +
                                    "\n" +
                                    incomeList[index]["date"].toString(),
                                style: TextStyle(fontSize: 21)),
                            trailing: Container(
                                child: IconButton(
                                    icon: Icon(Icons.delete,
                                        color: Colors.red, size: 35),
                                    onPressed: () {
                                      setState(() {
                                        incomeList.removeAt(index);
                                      });
                                      _setIncomeList();
                                    })))
                      ]));
                    }))
          ]),
        ));
  }
}
