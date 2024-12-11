import 'package:calculator/screens/perbelanjaan.dart';
import 'package:calculator/screens/peruntukan.dart';
import 'package:calculator/screens/senarai.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:month_year_picker/month_year_picker.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        GlobalWidgetsLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        MonthYearPickerLocalizations.delegate,
      ],
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // primarySwatch: Colors.black, // Your primary color
        inputDecorationTheme: const InputDecorationTheme(
          focusColor: Colors.black,
          floatingLabelStyle: TextStyle(color: Colors.black),
          enabledBorder: UnderlineInputBorder(
            borderSide:
                BorderSide(color: Colors.black), // Color when not focused
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.black), // Color when focused
          ),
        ),
      ),
      home: FinanceHome(),
    );
  }
}

class FinanceHome extends StatefulWidget {
  @override
  _FinanceHomeState createState() => _FinanceHomeState();
}

class _FinanceHomeState extends State<FinanceHome>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              Icons.calculate,
              color: Colors.white,
              size: 30,
            ),
            const Text(
              'I&E Calculator',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.black,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white, // Text color for selected tab
          indicatorColor: Colors.white,
          unselectedLabelColor:
              Colors.white70, // Text color for unselected tabs
          tabs: const [
            Tab(
              icon: Icon(Icons.add),
              child: Text(
                'PERUNTUKAN',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Tab(
              icon: Icon(Icons.remove),
              child: Text(
                'PERBELANJAAN',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Tab(
              icon: Icon(Icons.list),
              child: Text(
                'REPORT',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          MoneyInForm(),
          MoneyOutForm(),
          SenaraiPage(),
        ],
      ),
    );
  }
}
