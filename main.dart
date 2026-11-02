import 'package:flutter/material.dart';
import 'screens/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Contact Management App',
      theme: ThemeData(
        // useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
      ),
       home: const HomePage(),
    );
   }
}