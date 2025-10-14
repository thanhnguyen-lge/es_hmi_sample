import 'package:flutter/material.dart';
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';
import 'providers/chart_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: <SingleChildWidget>[
        ChangeNotifierProvider<ChartProvider>(
          create: (BuildContext context) => ChartProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Chart Sample',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 2,
          ),
        ),
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
