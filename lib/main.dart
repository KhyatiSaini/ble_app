import 'package:ble_app/providers/bluetooth_provider.dart';
import 'package:ble_app/providers/bluetooth_status_provider.dart';
import 'package:ble_app/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => BluetoothProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => BluetoothStatusProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'BLE App',
        theme: ThemeData(
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            elevation: 0,
          ),
          scaffoldBackgroundColor: Colors.white,
        ),
        home: const Home(),
        routes: {
          Home.routeName: (context) => const Home(),
        },
      ),
    );
  }
}
