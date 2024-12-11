import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:knee/urls.dart';

class ViewHistory extends StatefulWidget {
  final String patientID;
  const ViewHistory({super.key, required this.patientID});

  @override
  State<ViewHistory> createState() => _ViewHistoryState();
}

class _ViewHistoryState extends State<ViewHistory> {
  List<dynamic> records = [];
  String message = '';

  @override
  void initState() {
    super.initState();
    fetchXRayImages(widget.patientID);
  }

  Future<void> fetchXRayImages(String patientID) async {
    try {
      final response = await http.get(
        Uri.parse('${Urls.url}/fetchdetails.php?patientID=$patientID'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'no_data') {
          setState(() {
            message = data['message'];
          });
        } else if (data['status'] == 'success') {
          setState(() {
            records = data['data'];
          });
        } else {
          setState(() {
            message = 'Error fetching data: ${data['message'] ?? 'No data found'}';
          });
        }
      } else {
        setState(() {
          message = 'Error fetching data: ${response.reasonPhrase}';
        });
      }
    } catch (error) {
      setState(() {
        message = 'Error fetching data: $error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View History'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                'Details for Patient ID: ${widget.patientID}',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              message.isNotEmpty
                  ? Column(
                children: [
                  Text(
                    message,
                    style: TextStyle(color: Colors.red, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                ],
              )
                  : Column(
                children: records.map((record) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Patient ID: ${record['patient_id']}'), // updated key
                          SizedBox(height: 10),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FullScreenImage(
                                    imageUrl: '${Urls.url}/${record['image_path']}',
                                  ),
                                ),
                              );
                            },
                            child: Image.network(
                              '${Urls.url}/${record['image_path']}',
                              height: 200, // Thumbnail size
                              width: double.infinity,
                              fit: BoxFit.contain,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text('Prediction: ${record['prediction']}'), // added prediction field
                          Text('Confidence: ${record['confidence_score']}%'), // added confidence score field
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  side: BorderSide(color: Colors.teal), // Set the border color to teal
                ),
                child: Text(
                  'Go Back',
                  style: TextStyle(color: Colors.teal), // Set text color to teal
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FullScreenImage extends StatelessWidget {
  final String imageUrl;

  const FullScreenImage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: InteractiveViewer(
          child: Image.network(imageUrl),
        ),
      ),
    );
  }
}
