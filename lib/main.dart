import 'package:flutter/material.dart';
import 'package:poojaheakthcare/screens/login_screen.dart';
import 'package:poojaheakthcare/screens/patient_form_screen.dart';
import 'package:poojaheakthcare/screens/patient_info_screen.dart';
import 'package:poojaheakthcare/screens/splash_screen.dart';
import 'package:poojaheakthcare/utils/colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Proper Digin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.primary,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.button,
            textStyle: const TextStyle(fontSize: 18),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/patientInfo': (context) => const PatientInfoScreen(),
        // '/patientForm': (context) =>
        //     const PatientFormScreen(), // You'll need to implement this
      },
    );
  }
}
