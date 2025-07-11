import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:poojaheakthcare/screens/login_screen.dart';
import 'package:poojaheakthcare/screens/patient_info_screen.dart';
import 'package:poojaheakthcare/screens/splash_screen.dart';
import 'package:poojaheakthcare/utils/colors.dart';
import 'package:poojaheakthcare/website_code/web_screens/Home_Screen.dart';
import 'package:poojaheakthcare/website_code/web_screens/PatientRegistrationPage.dart';

void main() {
  //debugPaintSizeEnabled = true;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pooja Healthcare',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Plus Jakarta Sans',
        textTheme: GoogleFonts.plusJakartaSansTextTheme(
          Theme.of(context).textTheme,
        ),
        primaryTextTheme: GoogleFonts.plusJakartaSansTextTheme(),

        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100],
        useMaterial3: false,
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
      initialRoute: '/login',
      routes: {
        '/': (context) => const LoginScreen(),
        '/login': (context) => const LoginScreen(),
       // '/patientInfo': (context) => const PatientInfoScreen(),
        '/HomeScreen': (context) => const HomeScreen(),
        '/addPatient': (context) => const PatientRegistrationPage(),
      },
    );
  }
}
