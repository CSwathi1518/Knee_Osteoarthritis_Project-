import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:knee/urls.dart';
import 'dart:convert';
import 'Dashboard.dart';
import 'SignUpScreen.dart';

class loginscreen extends StatefulWidget {
  const loginscreen({super.key});

  @override
  State<loginscreen> createState() => _loginscreenState();
}

class _loginscreenState extends State<loginscreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void handleLogin() async {
    String username = _usernameController.text;
    String password = _passwordController.text;

    // Debugging output
    print('Attempting to log in with Username: $username and Password: $password');

    if (username.isEmpty || password.isEmpty) {
      showAlert('Please enter both username and password.');
      return;
    }

    // Your login API URL
    final String loginApiUrl = '${Urls.url}/project.php';
    try {
      // Send a POST request to the login API
      final response = await http.post(
        Uri.parse(loginApiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'username': username, 'password': password}),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}'); // Log the response body

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Parsed JSON: $data');

        // Check if the login was successful
        if (data['status'] == 'success') {
          showAlert('Login successful!');
          // Navigate to Dashboard
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => Dashboard(username: username),
            ),
          );
        } else {
          showAlert(data['message']); // Display server error message
        }
      } else {
        showAlert('Login failed. Please try again later.');
      }
    } catch (error) {
      print('Login Error: $error');
      showAlert('Login failed. Please try again later.');
    }
  }

  void showAlert(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Status'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView( // Wrap in SingleChildScrollView
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: size.height * 0.1),
                Image.asset(
                  'assets/knee.png', // Load image from assets
                  width: size.width * 0.6,
                  height: size.width * 0.6,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 30),
                const Text(
                  'Knee-OA',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 30),
                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Color(0xFF87C8C8),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Color(0xFF87C8C8),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: handleLogin,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    backgroundColor: const Color(0xFF148C8C),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    'LOGIN',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => SignUpScreen()),
                    );
                  },
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
