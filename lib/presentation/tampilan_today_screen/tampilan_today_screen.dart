import 'package:aini_s_application1/presentation/tampilan_today_screen/widgets/currentValue.dart';
import 'package:aini_s_application1/presentation/tampilan_today_screen/widgets/lineChart.dart';
import 'package:flutter/material.dart';
import '../../core/app_export.dart';

// ignore_for_file: must_be_immutable
class TampilanTodayScreen extends StatefulWidget {
  TampilanTodayScreen({Key? key}) : super(key: key);

  @override
  State<TampilanTodayScreen> createState() => _TampilanTodayScreenState();
}

class _TampilanTodayScreenState extends State<TampilanTodayScreen> {
  TextEditingController vectornineteenController = TextEditingController();
  TextEditingController vectorController = TextEditingController();
  TextEditingController vector1Controller = TextEditingController();

  // 🔹 Fungsi untuk refresh data
  Future<void> _refreshData() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: RefreshIndicator(
        onRefresh: _refreshData, // 🔹 Tambahkan fungsi refresh
        child: SingleChildScrollView(
          physics:
              AlwaysScrollableScrollPhysics(), // 🔹 Supaya bisa ditarik meski tidak bisa scroll
          child: Column(
            children: [
              SizedBox(height: 14.v),
              // _buildViewHierarchyList(context),
              LatestSensorData(),
              SizedBox(height: 20),
              SalesChartWidget(), // 🔹 Akan reload saat refresh
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Text('Time'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
