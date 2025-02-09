import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

// Widget Chart yang mendukung 2 garis (line)
class SalesChartWidget extends StatelessWidget {
  final List<SalesData> data;
  final List<SalesData> data2; // Data kedua untuk garis kedua

  SalesChartWidget({required this.data, required this.data2});

  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      primaryXAxis: CategoryAxis(),
      title: ChartTitle(text: 'Half Yearly Sales Analysis'),
      legend: Legend(isVisible: true),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: <CartesianSeries<SalesData, String>>[
        // Garis Pertama
        LineSeries<SalesData, String>(
          dataSource: data,
          xValueMapper: (SalesData sales, _) => sales.year,
          yValueMapper: (SalesData sales, _) => sales.sales,
          name: 'Sales 1', // Nama untuk garis pertama
          color: Colors.blue, // Warna garis pertama
          dataLabelSettings: DataLabelSettings(isVisible: true),
        ),
        // Garis Kedua
        LineSeries<SalesData, String>(
          dataSource: data2,
          xValueMapper: (SalesData sales, _) => sales.year,
          yValueMapper: (SalesData sales, _) => sales.sales,
          name: 'Sales 2', // Nama untuk garis kedua
          color: Colors.red, // Warna garis kedua
          dataLabelSettings: DataLabelSettings(isVisible: true),
        ),
      ],
    );
  }
}

// Model Data untuk Chart
class SalesData {
  SalesData(this.year, this.sales);

  final String year;
  final double sales;
}
