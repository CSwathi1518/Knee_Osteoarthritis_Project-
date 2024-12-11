import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:knee/urls.dart';  // Ensure you have your API URL in this file
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import 'ImageDisplay.dart';
import 'ListOfPatients.dart';

class Dashboard extends StatefulWidget {
  final String username;
  const Dashboard({super.key, required this.username});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  bool _isDownloading = false;

  // Function to check and request permission
  Future<bool> checkAndRequestPermission() async {
    PermissionStatus status = await Permission.storage.request();
    return status.isGranted;
  }

  // Function to download the CSV file
  Future<void> downloadCSV(BuildContext context) async {
    setState(() {
      _isDownloading = true;
    });
    final String url = "${Urls.url}/download.php"; // Replace with your API URL
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        // Check if permission is granted
        if (await checkAndRequestPermission()) {
          // Allow the user to pick a directory
          String? directoryPath = await FilePicker.platform.getDirectoryPath();
          if (directoryPath == null) {
            Fluttertoast.showToast(
              msg: 'No Directory Selected',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
            );
            return;
          }

          // Generate a unique file name
          String fileName = 'patient_details_${DateTime.now().millisecondsSinceEpoch}.csv';
          String filePath = '$directoryPath/$fileName';
          File file = File(filePath);

          // Ensure a unique filename
          int counter = 1;
          while (await file.exists()) {
            fileName = 'patient_details_${DateTime.now().millisecondsSinceEpoch}_$counter.csv';
            filePath = '$directoryPath/$fileName';
            file = File(filePath);
            counter++;
          }

          // Write the content to the file
          await file.writeAsBytes(response.bodyBytes);
          print('CSV saved at: $filePath');

          // Notify the user
          Fluttertoast.showToast(
            msg: 'Saved Successfully',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
          );
        } else {
          Fluttertoast.showToast(
            msg: 'Permission Denied',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
          );
        }
      } else {
        Fluttertoast.showToast(
          msg: 'Error Downloading CSV',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      }
    } catch (e) {
      print('Error occurred: $e');
      Fluttertoast.showToast(
        msg: 'An error occurred: $e',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    } finally {
      setState(() {
        _isDownloading = false;
      });
    }
  }

  // Show confirmation dialog before starting the download
  void _showDownloadDialog(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('Download CSV'),
          content: Text('Do you want to download all patients\' details?'),
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                downloadCSV(context); // Start downloading
              },
              child: Text('Download'),
            ),
          ],
        );
      },
    );
  }

  // Handle navigating back
  void _handleGoBack() {
    Navigator.pushReplacementNamed(context, '/loginscreen');
  }

  // Handle upload image action
  void _handleUploadImage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ImageDisplay()),
    );
  }

  // Handle list of patients action
  void _handleListOfPatients() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ListOfPatients()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double windowHeight = MediaQuery.of(context).size.height;
    final double windowWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            size: 30,
          ),
          onPressed: _handleGoBack, // Navigate back to the login screen
        ),
        title: Text(
          'Welcome, ${widget.username}',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _showDownloadDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: windowHeight * 0.2),
          const Center(
            child: Text(
              'Knee-OA',
              style: TextStyle(
                fontSize: 37,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: windowHeight * 0.05),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.all(20),
            width: 310,
            height: 300,
            decoration: BoxDecoration(
              color: Colors.teal,
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: Colors.black),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: _handleListOfPatients,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    minimumSize: const Size(250, 80),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    side: const BorderSide(color: Colors.black),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: Image.asset(
                          'assets/patientdetails.png',
                          width: 50,
                          height: 50,
                        ),
                      ),
                      const Text(
                        'List Of Patients',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: _handleUploadImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    minimumSize: const Size(250, 80),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    side: const BorderSide(color: Colors.black),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: Image.asset(
                          'assets/folder.png',
                          width: 50,
                          height: 50,
                        ),
                      ),
                      const Text(
                        'Upload Images',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
