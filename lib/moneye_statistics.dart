import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Statistics extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _StatisticsState();
  }
}

class _StatisticsState extends State<Statistics> {
  Map<String, double> expensesMap = {};

  Map<String, double> incomeMap = {};

  List<Color> expensesColorList = [
    Colors.red,
    Colors.blue,
    Colors.yellow,
    Colors.green,
    Colors.cyan,
    Colors.purple,
    Colors.pink,
    Colors.blueAccent,
    Colors.deepPurple,
    Colors.brown,
    Colors.deepOrangeAccent,
    Colors.orange,
    Colors.lightGreenAccent,
    Colors.teal
  ];

  List<Color> incomeColorList = [
    Colors.green,
    Colors.greenAccent,
    Colors.teal,
    Colors.tealAccent,
    Colors.lightGreen,
    Colors.lightGreenAccent,
    Colors.lime
  ];

  @override
  void initState() {
    super.initState();

    _updateExpensesMap();
    _updateIncomeMap();
  }

  void _updateExpensesMap() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    Set<String> categories =
        preferences.getKeys().where((e) => e.endsWith("(category)")).toSet();

    if (categories.length == 0) {
      setState(() {
        expensesMap.putIfAbsent("Food", () => 0);
        expensesMap.putIfAbsent("Clothes", () => 0);
        expensesMap.putIfAbsent("Petrol", () => 0);
        expensesMap.putIfAbsent("Gym", () => 0);
      });
    }

    double prefsValue = 0.000;
    String key = "";

    for (int i = 0; i < categories.length; i++) {
      key = categories.elementAt(i).split("(")[0];
      if (expensesMap.containsKey(key)) {
        prefsValue = preferences.get(categories.elementAt(i));
        setState(() {
          expensesMap.update(key, (value) => prefsValue);
        });
      } else {
        prefsValue = preferences.get(categories.elementAt(i));
        setState(() {
          expensesMap.putIfAbsent(key, () => prefsValue);
        });
      }
    }
  }

  void _updateIncomeMap() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    Set<String> workplaces =
        preferences.getKeys().where((e) => e.endsWith("(workplace)")).toSet();

    if (workplaces.length == 0) {
      setState(() {
        incomeMap.putIfAbsent("No income yet.", () => 0);
      });
    }

    double prefsValue = 0.000;
    String key = "";

    for (int i = 0; i < workplaces.length; i++) {
      key = workplaces.elementAt(i).split("(")[0];
      if (incomeMap.containsKey(key)) {
        prefsValue = preferences.get(workplaces.elementAt(i));
        setState(() {
          incomeMap.update(key, (value) => prefsValue);
        });
      } else {
        prefsValue = preferences.get(workplaces.elementAt(i));
        setState(() {
          incomeMap.putIfAbsent(key, () => prefsValue);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar:
            AppBar(title: Text("Statistics", style: TextStyle(fontSize: 27))),
        body: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                  margin: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height / 11.5),
                  padding: EdgeInsets.only(bottom: 10, left: 15),
                  child: Align(
                      alignment: Alignment.topLeft,
                      child: Text("Expenses",
                          style: TextStyle(
                              fontSize: 25, fontWeight: FontWeight.bold)))),
              Container(
                margin: EdgeInsets.only(top: 45, left: 20),
                child: PieChart(
                    dataMap: expensesMap,
                    animationDuration: Duration(milliseconds: 1300),
                    chartLegendSpacing: 32,
                    chartRadius: MediaQuery.of(context).size.width / 1.9,
                    colorList: expensesColorList,
                    initialAngleInDegree: 0,
                    chartType: ChartType.ring,
                    ringStrokeWidth: 30,
                    legendOptions: LegendOptions(
                      showLegendsInRow: false,
                      legendPosition: LegendPosition.right,
                      showLegends: true,
                      legendShape: BoxShape.circle,
                      legendTextStyle: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    chartValuesOptions: ChartValuesOptions(
                        showChartValueBackground: true,
                        showChartValues: true,
                        showChartValuesInPercentage: true,
                        showChartValuesOutside: false,
                        decimalPlaces: 2,
                        chartValueStyle: TextStyle(
                            color: Colors.black,
                            backgroundColor: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                        chartValueBackgroundColor: Colors.white)),
              ),
              Container(
                  margin: EdgeInsets.only(top: 75),
                  padding: EdgeInsets.only(bottom: 10, left: 15),
                  child: Align(
                      alignment: Alignment.topLeft,
                      child: Text("Income",
                          style: TextStyle(
                              fontSize: 25, fontWeight: FontWeight.bold)))),
              Container(
                margin: EdgeInsets.only(top: 45, left: 20),
                child: PieChart(
                    dataMap: incomeMap,
                    animationDuration: Duration(milliseconds: 1300),
                    chartLegendSpacing: 32,
                    chartRadius: MediaQuery.of(context).size.width / 1.9,
                    colorList: incomeColorList,
                    initialAngleInDegree: 0,
                    chartType: ChartType.ring,
                    ringStrokeWidth: 30,
                    legendOptions: LegendOptions(
                      showLegendsInRow: false,
                      legendPosition: LegendPosition.right,
                      showLegends: true,
                      legendShape: BoxShape.circle,
                      legendTextStyle: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    chartValuesOptions: ChartValuesOptions(
                        showChartValueBackground: true,
                        showChartValues: true,
                        showChartValuesInPercentage: true,
                        showChartValuesOutside: false,
                        decimalPlaces: 2,
                        chartValueStyle: TextStyle(
                            color: Colors.black,
                            backgroundColor: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                        chartValueBackgroundColor: Colors.white)),
              )
            ],
          ),
        ));
  }
}
