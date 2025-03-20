// import 'package:aini_s_application1/service/data_service.dart';
// import 'package:flutter/material.dart';

// class TampilanThisMonthScreen extends StatefulWidget {
//   @override
//   _TampilanThisMonthScreenState createState() =>
//       _TampilanThisMonthScreenState();
// }

// class _TampilanThisMonthScreenState extends State<TampilanThisMonthScreen> {
//   bool _isLoading = false;

//   Future<void> _fetchAndShowData(int month, int year) async {
//     setState(() {
//       _isLoading = true; // Aktifkan loading overlay
//     });

//     MonthlyData? monthlyData = await DataService().getMonthlyData(month, year);

//     setState(() {
//       _isLoading = false; // Matikan loading overlay
//     });

//     _showDialog(month, monthlyData);
//   }

//   void _showDialog(int month, MonthlyData? data) {
//     List<String> monthNames = [
//       "Januari",
//       "Februari",
//       "Maret",
//       "April",
//       "Mei",
//       "Juni",
//       "Juli",
//       "Agustus",
//       "September",
//       "Oktober",
//       "November",
//       "Desember"
//     ];

//     String monthName = monthNames[month - 1];

//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text("Data Bulan $monthName"),
//           content: data != null
//               ? Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text("DO Rata-rata: ${data.doAverageFormatted}"),
//                     Text("pH Rata-rata: ${data.phAverageFormatted}"),
//                   ],
//                 )
//               : Text("Data untuk bulan $monthName belum tersedia."),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: Text("Tutup"),
//             )
//           ],
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     List<String> months = [
//       "Januari",
//       "Februari",
//       "Maret",
//       "April",
//       "Mei",
//       "Juni",
//       "Juli",
//       "Agustus",
//       "September",
//       "Oktober",
//       "November",
//       "Desember"
//     ];

//     return Scaffold(
//       body: Stack(
//         children: [
//           GridView.builder(
//             padding: EdgeInsets.all(16),
//             gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 3,
//               crossAxisSpacing: 10,
//               mainAxisSpacing: 10,
//               childAspectRatio: 2,
//             ),
//             itemCount: months.length,
//             itemBuilder: (context, index) {
//               return ElevatedButton(
//                 onPressed: () =>
//                     _fetchAndShowData(index + 1, DateTime.now().year),
//                 child: Text(months[index]),
//               );
//             },
//           ),
//           if (_isLoading) ...[
//             Opacity(
//               opacity: 0.6, // Efek gelap di belakang
//               child: ModalBarrier(dismissible: false, color: Colors.black),
//             ),
//             Center(child: CircularProgressIndicator()), // Loading di tengah
//           ],
//         ],
//       ),
//     );
//   }
// }
