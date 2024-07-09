import React, { useState, useEffect } from 'react';
import { View, Text, StyleSheet, ActivityIndicator, ScrollView, Dimensions, TouchableOpacity, TextInput, Image, RefreshControl, Alert } from 'react-native';
import { useNavigation } from '@react-navigation/native';
import Ionicons from 'react-native-vector-icons/Ionicons';
import Logo from './assets/add.png'; 
import NewPatientScreen from './NewPatientScreen'; // Import NewPatientScreen component

const ListOfPatientsScreen = () => {
  const navigation = useNavigation();

  const [patients, setPatients] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [searchQuery, setSearchQuery] = useState('');
  const [refreshing, setRefreshing] = useState(false);
  const [showOptions, setShowOptions] = useState({}); // State to manage options visibility for each patient

  useEffect(() => {
    fetchPatientList();
  }, []);

  const fetchPatientList = () => {
    fetch('http://192.168.166.193/demo/patientlist.php')
      .then(response => {
        if (!response.ok) {
          throw new Error('Network response was not ok');
        }
        return response.json();
      })
      .then(data => {
        if (data && !data.status) {
          setPatients(data);
          setLoading(false);
          setError(null); // Clear any previous error
        } else {
          setError(data.message || 'No data found');
          setLoading(false);
        }
      })
      .catch(error => {
        console.error('Error fetching patient details:', error);
        setError('Error fetching data: ' + error.message); // Update state with specific error message
        setLoading(false);
      });
  };

  const handleBack = () => {
    navigation.goBack();
  };

  const handleEllipsePress = (patientID) => {
    setShowOptions(prevState => ({
      ...prevState,
      [patientID]: !prevState[patientID], // Toggle options visibility for the clicked patient
    }));
  };

  const handleEdit = (patientID) => {
    // Navigate to edit screen or implement edit logic
    navigation.navigate('EditPatientScreen', { patientID });
  };

  const deletePatient = (patientID) => {
    // Perform API call to delete patient from 'patients' table
    fetch(`http://192.168.166.193/demo/deletePatient.php?patientID=${patientID}`, {
      method: 'DELETE',
    })
    .then(response => {
      if (!response.ok) {
        throw new Error('Network response was not ok');
      }
      // Update state after successful deletion
      setPatients(patients.filter(patient => patient.patientID !== patientID));
      setShowOptions(prevState => ({
        ...prevState,
        [patientID]: false, // Hide options after deletion
      }));
  
      // Now, perform API call to delete image record from 'JointSpace' table
      fetch(`http://192.168.166.193/demo/deleteJointSpace.php?patientID=${patientID}`, {
        method: 'DELETE',
      })
      .then(response => {
        if (!response.ok) {
          throw new Error('Network response was not ok');
        }
        Alert.alert('Success', 'Patient and associated image deleted successfully.');
      })
      .catch(error => {
        console.error('Error deleting joint space record:', error);
        Alert.alert('Error', 'Failed to delete associated image.');
      });
  
      Alert.alert('Success', 'Patient deleted successfully.');
    })
    .catch(error => {
      console.error('Error deleting patient:', error);
      Alert.alert('Error', 'Failed to delete patient.');
    });
  };
  

  const handleSubmit = () => {
    fetchPatientList();
  };

  const onRefresh = () => {
    setRefreshing(true);
    fetchPatientList();
    setRefreshing(false);
  };

  const handleShowXRay = (patientID) => {
    navigation.navigate('ViewHistoryScreen', { patientID });
  };

  const filteredPatients = patients.filter(patient =>
    patient.patientname.toLowerCase().includes(searchQuery.toLowerCase())
  );

  const handleLogoPress = () => {
    navigation.navigate('NewPatientScreen'); // Navigate to NewPatientScreen
  };

  return (
    <View style={styles.container}>
      <View style={styles.topContainer}>
        <TouchableOpacity style={styles.backArrowContainer} onPress={handleBack}>
          <Image source={require('./assets/left arrow.png')} style={styles.backArrowImage} />
          <Text style={styles.listText}>List Of Patients</Text>
        </TouchableOpacity>
        <Image source={require('./assets/new.png')} style={styles.rightImage} />
      </View>
      <View style={styles.searchContainer}>
        <Ionicons name="search" size={Dimensions.get('window').height * 0.025} color="#8e8e93" style={styles.searchIcon} />
        <TextInput
          style={styles.searchBox}
          placeholder="Search"
          value={searchQuery}
          onChangeText={text => setSearchQuery(text)}
        />
      </View>
      <ScrollView
        style={styles.scrollView}
        refreshControl={
          <RefreshControl
            refreshing={refreshing}
            onRefresh={onRefresh}
          />
        }
      >
        {loading ? (
          <ActivityIndicator size="large" color="#ffffff" />
        ) : error ? (
          <Text style={styles.errorText}>{error}</Text>
        ) : filteredPatients.length > 0 ? (
          filteredPatients.map(patient => (
            <View key={patient.patientID} style={styles.whiteContainer}>
              <TouchableOpacity style={styles.ellipse} onPress={() => handleEllipsePress(patient.patientID)}>
                <View style={styles.dot} />
                <View style={styles.dot} />
                <View style={styles.dot} />
              </TouchableOpacity>
              <View style={styles.detailsContainer}>
                <Text style={styles.detail}>Patient ID: {patient.patientID}</Text>
                <Text style={styles.detail}>Patient Name: {patient.patientname}</Text>
                <Text style={styles.detail}>Age: {patient.Age}</Text>
                <Text style={styles.detail}>Gender: {patient.Gender}</Text>
                <Text style={styles.detail}>Contact: {patient.contactnumber}</Text>
                <TouchableOpacity style={styles.showXRayButton} onPress={() => handleShowXRay(patient.patientID)}>
                  <Text style={styles.showXRayText}>Show X-Ray Image</Text>
                </TouchableOpacity>
              </View>
              {showOptions[patient.patientID] && (
                <View style={styles.optionsContainer}>
                  {/* Edit and Delete options */}
                  <TouchableOpacity style={styles.option} onPress={() => handleEdit(patient.patientID)}>
                    <Text style={styles.optionText}>Edit</Text>
                  </TouchableOpacity>
                  <TouchableOpacity style={styles.option} onPress={() => deletePatient(patient.patientID)}>
                    <Text style={styles.optionText}>Delete</Text>
                  </TouchableOpacity>

                </View>
              )}
            </View>
          ))
        ) : (
          <Text style={styles.errorText}>No patients found</Text>
        )}
      </ScrollView>
      <TouchableOpacity style={styles.logoContainer} onPress={handleLogoPress}>
        <Image source={Logo} style={styles.logo} />
      </TouchableOpacity>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#ffffff',
    position: 'relative',
  },
  topContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'flex-start',
    width: '100%',
    height: Dimensions.get('window').height * 0.15,
    backgroundColor: '#fff',
    paddingHorizontal: Dimensions.get('window').width * 0.04,
  },
  listText: {
    fontSize: Dimensions.get('window').width * 0.07,
    fontWeight: 'bold',
    color: '#000',
    marginTop: Dimensions.get('window').height * -0.04,
    marginBottom: Dimensions.get('window').height * 0.090,
    alignSelf: 'center',
    marginLeft: Dimensions.get('window').width * 0.19,
  },
  searchContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    marginHorizontal: Dimensions.get('window').width * 0.05,
    marginBottom: Dimensions.get('window').height * 0.02,
    marginTop: Dimensions.get('window').height * 0.02,
    backgroundColor: '#fff',
    borderColor: '#148c8c',
    borderWidth: 1,
    borderRadius: 10,
    paddingHorizontal: Dimensions.get('window').width * 0.03,
    height: Dimensions.get('window').height * 0.05,
  },
  searchIcon: {
    marginRight: Dimensions.get('window').width * 0.02,
  },
  searchBox: {
    flex: 1,
    paddingVertical: Dimensions.get('window').height * 0.01,
    marginTop: Dimensions.get('window').height * 0.01,
    borderRadius: 10,
  },
  scrollView: {
    flex: 1,
  },
  whiteContainer: {
    backgroundColor: '#ffffff',
    marginBottom: Dimensions.get('window').height * 0.05,
    borderRadius: 10,
    borderColor: '#148c8c',
    borderWidth: 1,
    elevation: 3,
    marginHorizontal: Dimensions.get('window').width * 0.05,
  },
  ellipse: {
    position: 'absolute',
    top: 10,
    right: 10,
    width: 30,
    height: 30,
    backgroundColor: '#fff',
    justifyContent: 'center',
    alignItems: 'center',
    borderRadius: 15,
    zIndex: 1,
  },
  dot: {
    width: 6,
    height: 6,
    backgroundColor: 'black',
    borderRadius: 3,
    marginVertical: 1,
  },
  optionsContainer: {
    position: 'absolute',
    top: 50,
    right: 10,
    backgroundColor: '#fff',
    borderRadius: 10,
    borderWidth: 1,
    borderColor: '#148c8c',
    zIndex: 1,
    elevation: 3,
  },
  option: {
    padding: 10,
  },
  optionText: {
    fontSize: Dimensions.get('window').height * 0.02,
    color: '#000',
  },
  detailsContainer: {
    paddingVertical: Dimensions.get('window').height * 0.03,
    paddingHorizontal: Dimensions.get('window').width * 0.05,
    zIndex: 0,
  },
  detail: {
    fontSize: Dimensions.get('window').height * 0.025,
    color: '#2A2E3B',
    marginBottom: Dimensions.get('window').height * 0.02,
  },
  errorText: {
    fontSize: Dimensions.get('window').height * 0.022,
    color: 'red',
    textAlign: 'center',
  },
  logoContainer: {
    position: 'absolute',
    bottom: 40,
    right: 20,
    width: Dimensions.get('window').width * 0.15,
    height: Dimensions.get('window').width * 0.15,
    backgroundColor: '#148c8c',
    borderRadius: Dimensions.get('window').width * 0.25,
    zIndex: 0,
    justifyContent: 'center',
    alignItems: 'center',
  },
  logo: {
    width: '40%',
    height: '40%',
    resizeMode: 'contain',
  },
  backArrowContainer: {
    backgroundColor: 'transparent',
  },
  backArrowImage: {
    width: 25,
    height: 25,
    resizeMode: 'contain',
    marginLeft: Dimensions.get('window').width * 0.04,
    marginTop: Dimensions.get('window').height * 0.18,
  },
  rightImage: {
    width: 45,
    height: 45,
    resizeMode: 'contain',
    marginRight: Dimensions.get('window').width * 0.08,
    marginLeft: Dimensions.get('window').width * 0.04,
    marginTop: Dimensions.get('window').height * 0.08,
  },
  showXRayButton: {
    marginTop: Dimensions.get('window').height * 0.02,
    backgroundColor: '#148c8c',
    borderRadius: 5,
    paddingVertical: Dimensions.get('window').height * 0.01,
    paddingHorizontal: Dimensions.get('window').width * 0.05,
  },
  showXRayText: {
    color: '#fff',
    fontSize: Dimensions.get('window').height * 0.02,
    textAlign: 'center',
  },
});

export default ListOfPatientsScreen;
