import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart'; // Added for input formatting
import 'package:knee/urls.dart';

class NewPatient extends StatefulWidget {
  const NewPatient({Key? key}) : super(key: key);

  @override
  _NewPatientState createState() => _NewPatientState();
}

class _NewPatientState extends State<NewPatient> {
  final TextEditingController patientIDController = TextEditingController();
  final TextEditingController patientNameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController contactNumberController = TextEditingController();
  String selectedGender = 'Male'; // Default gender selection

  void _handleGoBack() {
    Navigator.pushReplacementNamed(context, '/ListOfPatients');
  }

  Future<void> handleSave() async {
    if (patientIDController.text.isEmpty ||
        patientNameController.text.isEmpty ||
        ageController.text.isEmpty ||
        selectedGender.isEmpty ||
        contactNumberController.text.isEmpty ||
        contactNumberController.text.length != 10) { // Check for 10 digits
      _showDialog('Error', 'Please provide all the information with a valid 10-digit contact number.');
      return;
    }

    try {
      // Check if patient ID already exists
      final patientID = patientIDController.text;
      final response = await http.get(
          Uri.parse('${Urls.url}/checkPatientID.php?patientID=$patientID'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['exists']) {
          _showDialog('Error', 'Patient ID $patientID already exists. Please provide a new ID.');
        } else {
          // Save the patient data
          await _savePatientData();
        }
      } else {
        throw Exception('Failed to check patient ID.');
      }
    } catch (e) {
      print('Error checking patient ID: $e');
      _showDialog('Error', 'Failed to check patient ID. Please try again later.');
    }
  }

  Future<void> _savePatientData() async {
    final formData = {
      'patientID': patientIDController.text,
      'patientname': patientNameController.text,
      'Age': ageController.text,
      'Gender': selectedGender,
      'contactnumber': contactNumberController.text,
    };
    try {
      final response = await http.post(
        Uri.parse('${Urls.url}/newpatient.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(formData),
      );
      final data = json.decode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        _showDialog('Success', 'Submitted successfully', onSuccess: () {
          Navigator.pushReplacementNamed(context, '/ListOfPatients');
        });
      } else {
        _showDialog('Error', data['message'] ?? 'Failed to save patient data.');
      }
    } catch (e) {
      print('Error saving patient data: $e');
      _showDialog('Error', 'Failed to save patient data. Please try again later.');
    }
  }

  void _showDialog(String title, String content, {VoidCallback? onSuccess}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (onSuccess != null) onSuccess();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double windowHeight = MediaQuery.of(context).size.height;
    final double windowWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: windowWidth * 0.04),
            height: windowHeight * 0.20,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: _handleGoBack,
                ),
                const Spacer(),
                Text(
                  'Add New Patient',
                  style: TextStyle(
                    fontSize: windowWidth * 0.07,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(flex: 2),
              ],
            ),
          ),
          const Text(
            'Enter Patient Details',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: windowWidth * 0.1),
              child: Column(
                children: [
                  _buildTextField('Patient ID', patientIDController),
                  _buildTextField('Patient Name', patientNameController),
                  _buildTextField('Age', ageController),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: DropdownButtonFormField<String>(
                      value: selectedGender,
                      items: ['Male', 'Female', 'Other']
                          .map((gender) => DropdownMenuItem<String>(
                        value: gender,
                        child: Text(gender),
                      ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedGender = value ?? 'Male';
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Gender',
                        filled: true,
                        fillColor: const Color(0xFF87C8C8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFF148c8c)),
                        ),
                      ),
                    ),
                  ),
                  _buildTextField('Contact Number', contactNumberController),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: handleSave,
                    child: const Text(
                      'Submit',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF148c8c),
                      padding: EdgeInsets.symmetric(
                        vertical: windowHeight * 0.02,
                        horizontal: windowWidth * 0.15,
                      ),
                      textStyle: TextStyle(
                        fontSize: windowWidth * 0.058,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String hintText, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextField(
        controller: controller,
        keyboardType: hintText == 'Contact Number' ? TextInputType.phone : TextInputType.text,
        inputFormatters: hintText == 'Contact Number'
            ? [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)]
            : null,
        decoration: InputDecoration(
          hintText: hintText,
          filled: true,
          fillColor: const Color(0xFF87C8C8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF148c8c)),
          ),
        ),
      ),
    );
  }
}
