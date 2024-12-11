import 'package:flutter/material.dart';
import 'package:knee/loginscreen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  WelcomeScreenState createState() => WelcomeScreenState();
}

class WelcomeScreenState extends State<WelcomeScreen> {
  void handleGo() {
    Navigator.pushNamed(context, '/loginscreen'); // Navigate to LoginScreen
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF148c8c),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo.png', // Load image from assets
              width: width * 0.7,
              height: width * 0.7,
              fit: BoxFit.cover,
            ),
            SizedBox(height: height * 0.03),
            Text(
              '“Unlocking the Hidden Threat”',
              style: TextStyle(
                fontSize: width * 0.07,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: height * 0.02),
            Text(
              'Delving into\nKnee\nOsteoarthritis',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: width * 0.08,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: height * 0.07),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => loginscreen()),
                );
              }, // Handle navigation to login screen
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  vertical: height * 0.02,
                  horizontal: width * 0.1,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(width * 0.04),
                ),
                elevation: 5,
              ),
              child: Text(
                'GO',
                style: TextStyle(
                  color: const Color(0xFF148c8c),
                  fontSize: width * 0.06,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
