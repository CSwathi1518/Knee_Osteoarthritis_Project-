import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:knee/urls.dart';

class ImageDisplay extends StatefulWidget {
  @override
  _ImageDisplayState createState() => _ImageDisplayState();
}

class _ImageDisplayState extends State<ImageDisplay> {
  final ImagePicker _picker = ImagePicker();
  File? _image;
  String _className = "";
  double _confidenceScore = 0.0;
  bool _isLoading = false;
  String _patientID = ""; // Added patientID field
  bool _isDataSaved = false; // Track whether data has been saved

  // Function to handle back navigation
  void _navigateToDashboard() {
    Navigator.pushReplacementNamed(context, '/Dashboard'); // Navigate to the Dashboard screen
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _className = '';
        _confidenceScore = 0.0;
        _isDataSaved = false; // Reset the saved status when new image is picked
      });
    }
  }

  Future<void> _predictImage() async {
    if (_image == null || _patientID.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select an image and provide a patient ID.')),
      );
      return;
    }
    setState(() {
      _isLoading = true;
    });
    final uri = Uri.parse('${Urls.flaskurl}/predict');
    final request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('image', _image!.path));
    final response = await request.send();
    final responseData = await response.stream.toBytes();
    final result = json.decode(String.fromCharCodes(responseData));
    setState(() {
      _className = result['class_name'];
      _confidenceScore = result['confidence_score'];
      _isLoading = false;
    });
  }

  Future<void> _uploadImageToXAMPP() async {
    final xamppUri = Uri.parse('${Urls.url}/jointspace.php');
    final request = http.MultipartRequest('POST', xamppUri)
      ..files.add(await http.MultipartFile.fromPath('image', _image!.path))
      ..fields['class_name'] = _className
      ..fields['confidence_score'] = _confidenceScore.toString()
      ..fields['patient_id'] = _patientID; // Ensure this matches PHP

    print("Uploading image with class: $_className, confidence: $_confidenceScore, patient_id: $_patientID");
    final response = await request.send();

    // Check the response status code
    if (response.statusCode == 200) {
      final responseData = await response.stream.toBytes();
      final result = json.decode(String.fromCharCodes(responseData));
      print(result['message']);
      // Reset state variables
      setState(() {
        _image = null; // Reset image
        _className = ''; // Reset class name
        _confidenceScore = 0.0; // Reset confidence score
        _patientID = ''; // Reset patient ID
        _isDataSaved = true; // Set data saved status to true
      });
      // Show an alert dialog after saving data successfully
      _showAlertDialog('Success', 'Data saved successfully!');
      // Navigate to the Dashboard
      Navigator.pushReplacementNamed(context, '/Dashboard'); // Ensure your route is defined
    } else {
      print('Failed to upload image to XAMPP');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save data.')),
      );
    }
  }

  void _showAlertDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Upload Image',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.teal,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white, // Set the icon color to white
          ),
          onPressed: _navigateToDashboard, // Navigate back to Dashboard
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: 'Enter Patient ID',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _patientID = value;
                  });
                },
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.camera),
                icon: Icon(Icons.camera_alt, size: 28, color: Colors.white),
                label: Text(
                  'Take a Picture',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.gallery),
                icon: Icon(Icons.photo, size: 28, color: Colors.white),
                label: Text(
                  'Select from Gallery',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              SizedBox(height: 20),
              if (_image != null)
                Column(
                  children: [
                    Image.file(_image!, height: 150),
                    SizedBox(height: 16),
                  ],
                ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _predictImage,
                icon: Icon(Icons.search, size: 28, color: Colors.white),
                label: Text(
                  'Predict',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              SizedBox(height: 40),
              if (_isLoading) CircularProgressIndicator(),
              if (_className.isNotEmpty && !_isLoading)
                Column(
                  children: [
                    Text(
                      'Class Name: $_className',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Confidence: ${(_confidenceScore * 100).toStringAsFixed(2)}%',
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: !_isDataSaved ? _uploadImageToXAMPP : null, // Disable if data is already saved
                      child: Text(
                        _isDataSaved ? 'Data Saved' : 'Save Data',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ],
                ),
              SizedBox(height: 40),
              Text(
                'Pick an image to make a prediction!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
