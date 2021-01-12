import 'dart:async';

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
  List<Todo> todos;
  DbHelper helper = new DbHelper();
  @override
  void initState() {
    super.initState();
    {
      setState(() {
        todos = getData();
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
          yValueMapper: (Todo data, _) =>
              todos.where((e) => e.typeTodo == data.typeTodo).length, //Valor
          startAngle: 90,
          endAngle: 90,
          dataLabelSettings: DataLabelSettings(
              isVisible: true, labelPosition: ChartDataLabelPosition.outside)),
    ];
  }

  List<Todo> getData() {
    final dbFuture = helper.initializeDb();
    List<Todo> todoList = List<Todo>();
    dbFuture.then((result) {
      final todosFuture = helper.getTodos();
      todosFuture.then((result) {
        int count = result.length;
        for (int i = 0; i < count; i++) {
          todoList.add(Todo.fromObject(result[i]));
        }
        setState(() {
          todos = todoList;
          count = count;
        });
      });
    });
    return todoList;
  }
}
