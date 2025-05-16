import 'package:flutter/material.dart';
import 'pantalla_principal.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mi Aplicación',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Color(0xFF121212),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          elevation: 0,
          centerTitle: true,
        ),
        colorScheme: ThemeData.dark().colorScheme.copyWith(
          secondary: Color(0xFFB8860B),
          background: Color(0xFF121212),
        ),
      ),
      home: SafeArea(child: SplashScreen()),
      routes: {'/principal': (_) => SafeArea(child: PantallaPrincipal())},
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 5), () {
      Navigator.pushReplacementNamed(context, '/principal');
    });
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Center(
              child: Image.asset(
                'assets/images/logo.png',
                width: mq.size.width * 0.5,
                height: mq.size.width * 0.5,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 50.0),
            child: Text(
              '© 2025 FutureCoders 35. All rights reserved.',
              style: TextStyle(
                color: Color(0xFFB8860B),
                fontSize: mq.textScaleFactor * 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
