import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:knee/NewPatient.dart';
import 'package:knee/ViewHistory.dart';
import 'package:knee/urls.dart'; // Import your new screen

class ListOfPatients extends StatefulWidget {
  const ListOfPatients({Key? key}) : super(key: key);

  @override
  _ListOfPatientsState createState() => _ListOfPatientsState();
}

class _ListOfPatientsState extends State<ListOfPatients> {
  List<Map<String, dynamic>> patients = [];
  bool loading = true;
  String error = '';
  String searchQuery = '';
  bool refreshing = false;
  Map<String, bool> showOptions = {};
  Map<String, dynamic> editPatient = {};

  @override
  void initState() {
    super.initState();
    fetchPatientList();
  }

  Future<void> fetchPatientList() async {
    try {
      final response = await http.get(Uri.parse('${Urls.url}/patientlist.php'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          setState(() {
            patients = List<Map<String, dynamic>>.from(data);
            loading = false;
            error = '';
          });
        } else {
          setState(() {
            error = data['message'] ?? 'No data found';
            loading = false;
          });
        }
      } else {
        setState(() {
          error = 'Failed to load patients: ${response.statusCode}';
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error fetching data: $e';
        loading = false;
      });
    }
  }

  void handleEllipsePress(String patientID) {
    setState(() {
      showOptions[patientID] = !(showOptions[patientID] ?? false);
    });
  }

  void handleEdit(Map<String, dynamic> patient) {
    setState(() {
      editPatient = patient;
    });
  }

  void handleDelete(String patientID) async {
    try {
      final response = await http.delete(Uri.parse('${Urls.url}/deletePatient.php?patientID=$patientID'));
      if (response.statusCode == 200) {
        setState(() {
          patients.removeWhere((patient) => patient['patientID'] == patientID);
          showOptions[patientID] = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Patient deleted successfully.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete patient.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting patient: $e')),
      );
    }
  }

  void handleSaveEdit() async {
    if (editPatient.isNotEmpty) {
      try {
        final response = await http.post(
          Uri.parse('${Urls.url}/editPatient.php'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(editPatient),
        );
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['status'] == 'success') {
            setState(() {
              patients = patients.map((patient) {
                return patient['patientID'] == editPatient['patientID'] ? editPatient : patient;
              }).toList();
              editPatient = {};
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Patient details updated successfully.')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(data['message'] ?? 'Failed to update patient details.')),
            );
          }
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating patient: $e')),
        );
      }
    }
  }

  void handleInputChange(String name, String value) {
    setState(() {
      editPatient[name] = value;
    });
  }

  Future<void> onRefresh() async {
    setState(() {
      refreshing = true;
    });
    await fetchPatientList();
    setState(() {
      refreshing = false;
    });
  }

  List<Map<String, dynamic>> get filteredPatients {
    return patients.where((patient) => patient['patientname']!.toLowerCase().contains(searchQuery.toLowerCase())).toList();
  }

  void handleLogoPress() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const NewPatient()),
    );
  }

  void _handleGoBack() {
    Navigator.pushReplacementNamed(context, '/Dashboard');
  }

  void handleShowXRay(String patientID) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewHistory(patientID: patientID),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 15.0),
            Text('List Of Patients'),
          ],
        ),
        leading: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0), // Reduced padding
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              size: 30,
            ),
            onPressed: _handleGoBack, // Navigation back
        ),
      ),
      ),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : error.isNotEmpty
          ? Center(child: Text(error))
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search, color: Colors.black),
                hintText: 'Search',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              onChanged: (text) {
                setState(() {
                  searchQuery = text;
                });
              },
            ),
          ),
          SizedBox(height: 10.0),
          Expanded(
            child: RefreshIndicator(
              onRefresh: onRefresh,
              child: ListView.builder(
                itemCount: filteredPatients.length,
                itemBuilder: (context, index) {
                  final patient = filteredPatients[index];
                  final patientID = patient['patientID']!;
                  final isEditing = editPatient['patientID'] == patientID;
                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(color: Colors.teal),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (isEditing) ...[
                                  TextField(
                                    decoration: const InputDecoration(labelText: 'Patient Name'),
                                    onChanged: (value) => handleInputChange('patientname', value),
                                    controller: TextEditingController(text: editPatient['patientname']?.toString() ?? ''),
                                  ),
                                  TextField(
                                    decoration: const InputDecoration(labelText: 'Age'),
                                    onChanged: (value) => handleInputChange('Age', value),
                                    controller: TextEditingController(text: editPatient['Age']?.toString() ?? ''),
                                  ),
                                  TextField(
                                    decoration: const InputDecoration(labelText: 'Gender'),
                                    onChanged: (value) => handleInputChange('Gender', value),
                                    controller: TextEditingController(text: editPatient['Gender']?.toString() ?? ''),
                                  ),
                                  TextField(
                                    decoration: const InputDecoration(labelText: 'Contact'),
                                    onChanged: (value) => handleInputChange('contactnumber', value),
                                    controller: TextEditingController(text: editPatient['contactnumber']?.toString() ?? ''),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      ElevatedButton(
                                        onPressed: handleSaveEdit,
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                                        child: const Text('Save', style: TextStyle(color: Colors.white)),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            editPatient = {};
                                          });
                                        },
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                                        child: const Text('Cancel', style: TextStyle(color: Colors.white)),
                                      ),
                                    ],
                                  ),
                                ] else ...[
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Patient ID: ${patient['patientID']}', style: TextStyle(color: Colors.black)),
                                      Text('Name: ${patient['patientname']}', style: TextStyle(color: Colors.black)),
                                      Text('Age: ${patient['Age']}', style: TextStyle(color: Colors.black)),
                                      Text('Gender: ${patient['Gender']}', style: TextStyle(color: Colors.black)),
                                      Text('Contact: ${patient['contactnumber']}', style: TextStyle(color: Colors.black)),
                                      TextButton(
                                        onPressed: () => handleShowXRay(patientID),
                                        child: const Text('Show X-Ray Image', style: TextStyle(color: Colors.black)),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.more_vert, color: Colors.black),
                                onPressed: () => handleEllipsePress(patientID),
                              ),
                              if (showOptions[patientID] == true) ...[
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.black),
                                  onPressed: () => handleEdit(patient),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.teal),
                                  onPressed: () => handleDelete(patientID),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: handleLogoPress,
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
