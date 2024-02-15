// Dashboard.js
import React from 'react';
import { View, Text, TouchableOpacity, ImageBackground,StyleSheet } from 'react-native';

export default function Dashboard({ navigation }) {
  // Define functions to handle button presses
  const handleUPLOADXRAY = () => {
    // Handle the press for Gym Training button
    // You can navigate to another screen or perform any action you desire
    alert('Upload x-ray button pressed!');
  };

  const handleGOBACK = () => {
    // Handle the press for Gym Works button
    alert('Go Back button pressed!');
  };

  const handleGoBack = () => {
    // Perform the logout, e.g., clear the user's session, reset state, etc.
  
    // Navigate to the lock screen page
    navigation.navigate('LoginScreen'); // Replace 'LockScreen' with the name of your lock screen page
  };

  return (
    <ImageBackground
      source={require('./assets/background.png')}
      style={styles.backgroundImage}
      resizeMode="contain" // Ensure the entire image is covered without distortion
    >
    <View style={styles.container}>
      <Text style={styles.header}>MENU</Text>

      {/* Buttons for each attribute */}
      <TouchableOpacity style={styles.button} onPress={handleUPLOADXRAY}>
        <Text style={styles.buttonText}>Upload x ray images of knee joint For joint space width measurement</Text>
      </TouchableOpacity>

      <TouchableOpacity style={styles.button} onPress={handleGOBACK}>
        <Text style={styles.buttonText}>GO BACK</Text>
      </TouchableOpacity>
    </View>
    </ImageBackground>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    padding: 16,
  },
  backgroundImage: {
    flex: 1,
    justifyContent: 'center',
  },
  header: {
    fontSize: 24,
    fontWeight: 'bold',
    marginBottom: 16,
  },
  button: {
    backgroundColor: '#93FCDD',
    padding: 10,
    borderRadius: 8,
    marginTop: 60,
    alignItems: 'center',
  },
  buttonText: {
    color: 'black',
    fontSize: 16,
    fontWeight: 'bold',
  },
});
