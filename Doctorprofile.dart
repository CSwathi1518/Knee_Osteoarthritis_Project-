import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:knee/urls.dart';

class Doctorprofile extends StatefulWidget {
  final String username;
  const Doctorprofile({super.key, required this.username});

  @override
  _DoctorprofileState createState() => _DoctorprofileState();
}

class _DoctorprofileState extends State<Doctorprofile> {
  bool isLoading = true;
  Map<String, dynamic>? doctorDetails;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchDoctorDetails();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Fetch doctor details whenever the screen is focused
    fetchDoctorDetails();
  }

  Future<void> fetchDoctorDetails() async {
    setState(() {
      isLoading = true; // Set loading state before fetching
    });
    final url =
        '${Urls.url}/viewprofile.php?username=${widget.username}';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          doctorDetails = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'No data found';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching data';
        isLoading = false;
      });
    }
  }

  void _handleGoBack() {
    Navigator.pushReplacementNamed(context, '/Dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF148c8c),
        centerTitle: true,
        title: const Text(
          'Doctor Profile',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: _handleGoBack,
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(child: Text(errorMessage!))
          : doctorDetails != null
          ? SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Doctor ID: ${widget.username}',
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 10),
              Text(
                'Doctor Name: ${doctorDetails!['doctorName']}',
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 10),
              Text(
                'Age: ${doctorDetails!['age']}',
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 10),
              Text(
                'Gender: ${doctorDetails!['gender']}',
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 10),
              Text(
                'Department: ${doctorDetails!['department']}',
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 10),
              Text(
                'Contact: ${doctorDetails!['contactNumber']}',
                style: const TextStyle(fontSize: 20),
              ),
            ],
          ),
        ),
      )
          : const Center(child: Text('No details available')),
    );
  }
}