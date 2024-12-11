import 'package:flutter/material.dart';
import 'package:knee/ListOfPatients.dart';
import 'package:knee/NewPatient.dart';
import 'package:knee/ViewHistory.dart';
import 'package:knee/loginscreen.dart';
import 'package:knee/welcomescreen.dart';
import 'Dashboard.dart';
import 'ImageDisplay.dart';
import 'SignUpScreen.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ),
        useMaterial3: true,
      ),
      // Define your routes here
      routes: {
        '/loginscreen': (context) => const loginscreen(), // Ensure loginscreen is defined properly
        '/SignUpScreen': (context) => const SignUpScreen(),
        '/Dashboard': (context) => const Dashboard(username: '', ),
        '/ListOfPatients': (context) => ListOfPatients(),
        '/ImageDisplay': (context) => ImageDisplay(), // Corrected typo here
        '/NewPatient': (context) => const NewPatient(),
        '/ViewHistory': (context) => const ViewHistory(patientID: '',),
      },
      home: const WelcomeScreen(),
    );
  }
}

