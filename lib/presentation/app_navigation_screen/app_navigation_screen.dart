import 'package:flutter/material.dart';
import 'package:aini_s_application1/presentation/tampilan_this_month_screen/tampilan_this_month_screen.dart';
import 'package:aini_s_application1/presentation/tampilan_today_screen/tampilan_today_screen.dart';
import 'package:aini_s_application1/presentation/tampilan_weekly_screen/tampilan_weekly_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AppNavigationScreen(),
    );
  }
}

class AppNavigationScreen extends StatefulWidget {
  const AppNavigationScreen({Key? key}) : super(key: key);

  @override
  State<AppNavigationScreen> createState() => _AppNavigationScreenState();
}

class _AppNavigationScreenState extends State<AppNavigationScreen> {
  int _selectedIndex = 0;

  static List<Widget> _widgetOptions = <Widget>[
    TampilanTodayScreen(),
    TampilanWeeklyScreen(),
    TampilanThisMonthScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 3, 148, 49),
        leading: IconButton(
          icon: Icon(
            Icons.menu,
            color: Colors.white,
          ),
          onPressed: () {
            // Tambahkan aksi untuk menu di sini
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.alarm,
              color: Colors.white,
            ),
            onPressed: () {
              // Tambahkan aksi untuk alarm di sini
            },
          ),
        ],
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.today), label: 'Today'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_view_week), label: 'Weekly'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today), label: 'All Time'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromARGB(255, 11, 205, 69),
        onTap: _onItemTapped,
      ),
    );
  }
}
