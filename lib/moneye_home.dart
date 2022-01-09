import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:intl/intl.dart';
import 'package:planner/moneye_camera.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'moneye_balance.dart';
import 'moneye_budget.dart';
import 'moneye_expenses.dart';
import 'moneye_income.dart';
import 'moneye_map.dart';
import 'moneye_savings.dart';
import 'moneye_statistics.dart';

typedef TotalExpenses = void Function();
typedef TotalIncome = void Function();
typedef BalanceCallback = void Function(double balance);
typedef BudgetCallback = void Function(double budget);
typedef SavingsCallback = void Function(double savingsAmount);

class Moneye extends StatefulWidget {
  final List<CameraDescription> cameras;

  const Moneye(this.cameras);

  @override
  State<Moneye> createState() => _MoneyeState(this.cameras);
}

class _MoneyeState extends State<Moneye> {
  String date = DateFormat("dd/MM/yyyy kk:mm").format(DateTime.now());

  double totalExpenses = 0.000;
  double totalIncome = 0.000;

  double currentBalance = 0.000;

  double initialBudget = 0.000;
  double currentBudget = 0.000;

  double initialSavingsAmount = 0.000;
  double currentSavingsAmount = 0.000;

  double budgetPercentage = 0.000;
  double savingsPercentage = 0.000;

  final List<CameraDescription> cameras;

  LocationSettings locationSettings = AndroidSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 100,
    forceLocationManager: true,
    intervalDuration: const Duration(seconds: 10),
  );

  _MoneyeState(this.cameras);

  @override
  void initState() {
    super.initState();

    _getTotalExpenses();
    _getTotalIncome();
    _getFinancialData(
        "currentBalance", "currentBudget", "currentSavingsAmount");
  }

  void _listExpenses() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => Expenses(_getTotalExpenses)));
  }

  void _showIncomeInformation() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => Income(_getTotalIncome)));
  }

  void _showStatistics() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => Statistics()));
  }

  void _updatePercentages() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    if (preferences.containsKey("initialBudget") &&
        preferences.containsKey("currentBudget")) {
      setState(() {
        budgetPercentage = 1 -
            (((initialBudget - currentBudget) / initialBudget) * 100 * 0.01);
      });
    } else {
      setState(() {
        budgetPercentage = 0.000;
      });
    }

    if (preferences.containsKey("initialSavingsAmount") &&
        preferences.containsKey("currentSavingsAmount")) {
      setState(() {
        savingsPercentage = 1 -
            (((initialSavingsAmount - currentSavingsAmount) /
                    initialSavingsAmount) *
                100 *
                0.01);
      });
    } else {
      setState(() {
        savingsPercentage = 0.000;
      });
    }
  }

  void _getTotalExpenses() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    double totalExpensesPrefs = preferences.get("totalExpenses");
    double currentBalancePrefs = preferences.get("currentBalance");
    double currentBudgetPrefs = preferences.get("currentBudget");
    double currentSavingsAmountPrefs = preferences.get("currentSavingsAmount");
    setState(() {
      totalExpenses = totalExpensesPrefs != null ? totalExpensesPrefs : 0.000;
      currentBalance =
          currentBalancePrefs != null ? currentBalancePrefs : 0.000;
      currentBudget = currentBudgetPrefs != null ? currentBudgetPrefs : 0.000;
      currentSavingsAmount =
          currentSavingsAmountPrefs != null ? currentSavingsAmountPrefs : 0.000;
    });

    _updatePercentages();
  }

  void _getTotalIncome() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    double totalIncomePrefs = preferences.getDouble("totalIncome");
    double currentBalancePrefs = preferences.get("currentBalance");
    setState(() {
      totalIncome = totalIncomePrefs != null ? totalIncomePrefs : 0.000;
      currentBalance =
          currentBalancePrefs != null ? currentBalancePrefs : 0.000;
    });
  }

  void _getFinancialData(String currentBalanceParam, String currentBudgetParam,
      String currentSavingsAmountParam) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    if (preferences.containsKey(currentBalanceParam)) {
      setState(() {
        currentBalance = preferences.get(currentBalanceParam);
      });
    }
    if (preferences.containsKey(currentBudgetParam)) {
      setState(() {
        initialBudget = preferences.get("initialBudget");
        currentBudget = preferences.get(currentBudgetParam);
      });
    }
    if (preferences.containsKey(currentSavingsAmountParam)) {
      setState(() {
        initialSavingsAmount = preferences.get("initialSavingsAmount");
        currentSavingsAmount = preferences.get(currentSavingsAmountParam);
      });
    }

    _updatePercentages();
  }

  void _setFinancialData(String dataType, double amount) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    if (preferences.containsKey(dataType)) {
      preferences.remove(dataType);
    }
    preferences.setDouble(dataType, amount);

    _updatePercentages();
  }

  void _balanceForm() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => Balance(_setBalance)));
  }

  void _setBalance(double balance) {
    setState(() {
      currentBalance = balance;
    });

    _setFinancialData("currentBalance", balance);
  }

  void _budgetForm() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => Budget(_setBudget)));
  }

  void _setBudget(double budget) {
    setState(() {
      initialBudget = budget;
      currentBudget = budget;
    });

    _setFinancialData("initialBudget", budget);
    _setFinancialData("currentBudget", budget);
  }

  void _savingsForm() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => Savings(_setSavings)));
  }

  void _setSavings(double savingsAmount) {
    setState(() {
      initialSavingsAmount = savingsAmount;
      currentSavingsAmount = savingsAmount;
    });

    _setFinancialData("initialSavingsAmount", savingsAmount);
    _setFinancialData("currentSavingsAmount", savingsAmount);
  }

  Future<Position> _determineCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  void _viewMap() async {
    Position pos = await _determineCurrentPosition();

    double lat = pos.latitude;
    double lng = pos.longitude;

    Navigator.push(
        context, MaterialPageRoute(builder: (context) => MyMap(lat, lng)));
  }

  void _openCamera() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => CameraScreen(cameras)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Moneye", style: TextStyle(fontSize: 26)),
          actions: [
            Tooltip(
                message: "View list of expenses",
                child: IconButton(
                  icon: Icon(Icons.money),
                  onPressed: _listExpenses,
                )),
            Tooltip(
                message: "View income information",
                child: IconButton(
                  icon: Icon(Icons.monetization_on),
                  onPressed: _showIncomeInformation,
                )),
            Tooltip(
                message: "View statistics",
                child: IconButton(
                  icon: Icon(Icons.equalizer),
                  onPressed: _showStatistics,
                )),
            Tooltip(
                message: "View map",
                child: IconButton(
                  icon: Icon(Icons.location_on_outlined),
                  onPressed: _viewMap,
                )),
            Tooltip(
                message: "Open camera",
                child: IconButton(
                  icon: Icon(Icons.camera),
                  onPressed: _openCamera,
                )),
            Padding(
              padding: EdgeInsets.only(left: 15),
              child: IconButton(
                iconSize: 30,
                icon: Icon(Icons.circle_notifications),
                onPressed: null,
              ),
            )
          ],
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                    margin: EdgeInsets.only(bottom: 75),
                    child: Center(
                        child: Text(date, style: TextStyle(fontSize: 15)))),
                Container(
                    margin: EdgeInsets.only(bottom: 15),
                    child: Text(
                        "Total expenses: " +
                            totalExpenses.toStringAsFixed(1).toString() +
                            "EUR",
                        style: TextStyle(fontSize: 25))),
                Container(
                    margin: EdgeInsets.only(bottom: 105),
                    child: Text(
                        "Total income: " +
                            totalIncome.toStringAsFixed(1).toString() +
                            "EUR",
                        style: TextStyle(fontSize: 25))),
                Container(
                    margin: EdgeInsets.only(bottom: 75),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            "Balance: " +
                                currentBalance.toStringAsFixed(1) +
                                "EUR",
                            style: TextStyle(
                                fontSize: 26, fontWeight: FontWeight.bold)),
                        ElevatedButton(
                            child: Text("Set", style: TextStyle(fontSize: 16)),
                            onPressed: _balanceForm,
                            style:
                                ElevatedButton.styleFrom(primary: Colors.green))
                      ],
                    )),
                Container(
                  child: Card(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                            minVerticalPadding: 20,
                            leading: Icon(Icons.attach_money, size: 50),
                            title: Text(
                                "Budget: " +
                                    currentBudget.toStringAsFixed(1) +
                                    "EUR / " +
                                    initialBudget.toStringAsFixed(1) +
                                    "EUR",
                                style: TextStyle(fontSize: 24)),
                            subtitle: Padding(
                                padding: EdgeInsets.only(top: 15),
                                child: LinearPercentIndicator(
                                  width:
                                      MediaQuery.of(context).size.width - 200,
                                  animation: true,
                                  lineHeight: 25,
                                  animationDuration: 2000,
                                  percent: budgetPercentage,
                                  center: Text(
                                      (budgetPercentage * 100)
                                              .toStringAsFixed(1) +
                                          "%",
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)),
                                  linearStrokeCap: LinearStrokeCap.roundAll,
                                  progressColor: Colors.greenAccent,
                                ))),
                        IconButton(
                            icon: Icon(Icons.create_rounded),
                            onPressed: _budgetForm)
                      ],
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 25),
                  child: Card(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                            minVerticalPadding: 20,
                            leading: Icon(Icons.lock, size: 50),
                            title: Text(
                                "Saving amount: " +
                                    currentSavingsAmount.toStringAsFixed(1) +
                                    "EUR / " +
                                    initialSavingsAmount.toStringAsFixed(1) +
                                    "EUR",
                                style: TextStyle(fontSize: 24)),
                            subtitle: Padding(
                              padding: EdgeInsets.only(top: 15),
                              child: LinearPercentIndicator(
                                width: MediaQuery.of(context).size.width - 200,
                                animation: true,
                                lineHeight: 25,
                                animationDuration: 2000,
                                percent: savingsPercentage,
                                center: Text(
                                    (savingsPercentage * 100)
                                            .toStringAsFixed(1) +
                                        "%",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                                linearStrokeCap: LinearStrokeCap.roundAll,
                                progressColor: Colors.blue,
                              ),
                            )),
                        IconButton(
                            icon: Icon(Icons.create_rounded),
                            onPressed: _savingsForm)
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  void _clearPreferences() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.clear();
  }
}
