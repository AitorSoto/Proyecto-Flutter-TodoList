import 'dart:async';

import 'package:TodosApp/Model/todo.dart';
import 'package:TodosApp/Util/dbhelper.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';

class DataGraphic extends StatefulWidget {
  final DbHelper dbHelper;
  DataGraphic(this.dbHelper);

  @override
  _DataGraphictState createState() => _DataGraphictState(this.dbHelper);
}

class _DataGraphictState extends State<DataGraphic> {
  List<Todo> todos = List();
  DbHelper helper;
  _DataGraphictState(this.helper);
  @override
  void initState() {
    super.initState();
    {
      setState(() {
        todos = getData(helper);
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
          series: _getLegendDefaultSeries(todos),
          tooltipBehavior: TooltipBehavior(enable: true),
        ));
  }

  List<DoughnutSeries<Todo, String>> _getLegendDefaultSeries(
      List<Todo> todoCharts) {
    return <DoughnutSeries<Todo, String>>[
      DoughnutSeries<Todo, String>(
          dataSource: todoCharts,
          legendIconType: LegendIconType.circle,
          enableSmartLabels: true,
          xValueMapper: (Todo data, _) => data.date, //String
          yValueMapper: (Todo data, _) => 2, //Valor
          startAngle: 90,
          endAngle: 90,
          dataLabelSettings: DataLabelSettings(
              isVisible: true, labelPosition: ChartDataLabelPosition.outside)),
    ];
  }
}

List<Todo> getData(DbHelper helper) {
  List<Todo> todoList = List<Todo>();

  final todosFuture = helper.getTodos();
  todosFuture.then((result) {
    int count = result.length;
    for (int i = 0; i < count; i++) {
      todoList.add(Todo.fromObject(result[i]));
    }
  });

  return todoList;
}
