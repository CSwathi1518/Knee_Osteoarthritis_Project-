import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:knee/urls.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form fields
  String username = '';
  String doctorName = '';
  String age = '';
  String gender = 'Select Gender'; // Default value for gender dropdown
  String department = '';
  String contactNumber = '';
  String password = '';
  bool _isPasswordVisible = false; // Password visibility toggle

  void _navigateBack(BuildContext context) {
    Navigator.pushReplacementNamed(context, '/loginscreen');
  }

  Future<void> _handleSignup() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Create the filtered form data map
      final Map<String, String> formData = {
        'username': username,
        'doctorName': doctorName,
        'age': age,
        'gender': gender,
        'department': department,
        'contactNumber': contactNumber,
        'password': password,
      };

      try {
        // Send HTTP POST request to the PHP backend
        final response = await http.post(
          Uri.parse('${Urls.url}/signup.php'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(formData),
        );

        // Check if the response is successful
        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          if (responseData['success'] == false) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(responseData['message'])),
            );
          } else {
            // Show alert dialog for successful registration
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Registration Successful'),
                  content: const Text('You have successfully registered.'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                        // Navigate back to the login screen
                        _navigateBack(context);
                      },
                      child: const Text('OK'),
                    ),
                  ],
                );
              },
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Server error. Please try again later.')),
          );
        }
      } catch (error) {
        print('Error: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to register. Please check your connection.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide all the information.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double windowHeight = MediaQuery.of(context).size.height;
    final double windowWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white, // Set background color to white
      appBar: AppBar(
        backgroundColor: Colors.white, // Set AppBar background color to white
        foregroundColor: Colors.black,
        leading: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 8.0), // Adjust padding
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              size: 30, // Adjust icon size
            ),
            onPressed: () => _navigateBack(context), // Back arrow to login screen
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: windowWidth * 0.08),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: windowHeight * 0.05),
                Image.asset(
                  'assets/knee1.png', // Replace with the asset image
                  width: 130,
                  height: 130,
                ),
                SizedBox(height: windowHeight * 0.02),
                Text(
                  'Knee-OA',
                  style: TextStyle(
                    fontSize: windowWidth * 0.08,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: windowHeight * 0.05),
                _buildTextInput(
                  label: 'Doctor ID',
                  onSaved: (value) => username = value!,
                ),
                _buildTextInput(
                  label: 'Doctor Name',
                  onSaved: (value) => doctorName = value!,
                ),
                _buildTextInput(
                  label: 'Age',
                  onSaved: (value) => age = value!,
                ),
                _buildGenderDropdown(),
                _buildTextInput(
                  label: 'Department',
                  onSaved: (value) => department = value!,
                ),
                _buildContactInput(),
                _buildPasswordInput(),
                SizedBox(height: windowHeight * 0.05),
                ElevatedButton(
                  onPressed: _handleSignup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: EdgeInsets.symmetric(
                      horizontal: windowWidth * 0.3,
                      vertical: windowHeight * 0.02,
                    ),
                  ),
                  child: Text(
                    'Signup',
                    style: TextStyle(
                      fontSize: windowWidth * 0.04,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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

  Widget _buildTextInput({
    required String label,
    bool obscureText = false,
    required FormFieldSetter<String> onSaved,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.teal[100],
        ),
        obscureText: obscureText,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
        onSaved: onSaved,
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: DropdownButtonFormField<String>(
        value: gender,
        items: [
          'Select Gender',
          'Male',
          'Female',
          'Other',
        ].map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            gender = value!;
          });
        },
        decoration: InputDecoration(
          labelText: 'Gender',
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.teal[100],
        ),
        validator: (value) {
          if (value == null || value == 'Select Gender') {
            return 'Please select your gender';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildContactInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: 'Contact Number',
          prefixText: '+91 ', // Prefix for contact number
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.teal[100],
        ),
        keyboardType: TextInputType.phone,
        maxLength: 10, // Allowing only 10 digits
        validator: (value) {
          if (value == null || value.isEmpty || value.length != 10) {
            return 'Please enter a valid contact number';
          }
          return null;
        },
        onSaved: (value) => contactNumber = value!,
      ),
    );
  }

  Widget _buildPasswordInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: 'Password',
          suffixIcon: IconButton(
            icon: Icon(
              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            ),
            onPressed: () {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible;
              });
            },
          ),
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.teal[100],
        ),
        obscureText: !_isPasswordVisible,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a password';
          }
          return null;
        },
        onSaved: (value) => password = value!,
      ),
    );
  }
}
