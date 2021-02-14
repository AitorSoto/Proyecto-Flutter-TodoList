import 'dart:async';

import 'package:TodosApp/Model/categories.dart';
import 'package:TodosApp/Model/todo.dart';
import 'package:TodosApp/Util/dbhelper.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';

class DataGraphic extends StatefulWidget {
  @override
  _DataGraphictState createState() => _DataGraphictState();
}

class _DataGraphictState extends State<DataGraphic> {
  List<Categories> categories;
  DbHelper helper = new DbHelper();
  @override
  void initState() {
    super.initState();
    {
      setState(() {
        categories = getData();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Charts")),
        body: SfCircularChart(
          title: ChartTitle(text: "Mucho texto"),
          legend: Legend(
              isVisible: true, overflowMode: LegendItemOverflowMode.wrap),
          series: _getLegendDefaultSeries(categories),
          tooltipBehavior: TooltipBehavior(enable: true),
        ));
  }

  List<DoughnutSeries<Categories, String>> _getLegendDefaultSeries(
      List<Categories> categoriesCharts) {
    //List<String> typesTodos = uniqueTypes();
    return <DoughnutSeries<Categories, String>>[
      DoughnutSeries<Categories, String>(
          dataSource: categoriesCharts,
          legendIconType: LegendIconType.circle,
          enableSmartLabels: true,
          xValueMapper: (Categories data, _) => data.category, //String
          yValueMapper: (Categories data, _) => data.repetitions, //Valor
          startAngle: 90,
          endAngle: 90,
          dataLabelSettings: DataLabelSettings(
              isVisible: true, labelPosition: ChartDataLabelPosition.outside)),
    ];
  }

  /*List<String> uniqueTypes() {
    List<String> typesTodos = List<String>();
    for (int i = 0; i <= categories.length; i++) typesTodos.add(categories[i].typeTodo);
    typesTodos = typesTodos.toSet().toList();
    return typesTodos;
  }*/

  List<Categories> getData() {
    final dbFuture = helper.initializeDb();
    List<Categories> categoriesList = List<Categories>();
    dbFuture.then((result) {
      final todosFuture = helper.getCategories();
      todosFuture.then((result) {
        int count = result.length;
        for (int i = 0; i < count; i++) {
          categoriesList.add(Categories.fromObject(result[i]));
        }
        setState(() {
          categories = categoriesList;
          count = count;
        });
      });
    });
    return categoriesList;
  }
}
