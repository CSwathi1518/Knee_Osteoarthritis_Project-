import React, { useState } from 'react';
import { View, Text, TextInput, TouchableOpacity, StyleSheet, Image,ImageBackground, Alert } from 'react-native';
import { useNavigation } from '@react-navigation/native';

const LoginScreen = () => {
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const navigation = useNavigation();

  const handleLogin = () => {
    // Check if username and password are provided
    if (!username || !password) {
      showAlert('Please enter both username and password.');
      return;
    }

    // Your login API URL
    const loginApiUrl = 'http://192.168.144.193/demo/project.php';

    // Make a POST request to the login API
    fetch(loginApiUrl, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ username, password }),
    })
      .then(response => response.json())
      .then(data => {
        console.log('Login Response:', data);
        if (data.status === 'success') {
          showAlert('Login successful!');
          navigation.navigate('Dashboard'); // Navigate to the Dashboard screen
        } else {
          showAlert('Invalid username or password. Please try again.');
        }
      })
      .catch(error => {
        console.error('Login Error:', error);
        showAlert('Login failed. Please try again later.');
      });
  };

  const showAlert = (message) => {
    Alert.alert('Status', message);
  };

  return (
    <ImageBackground
      source={require('./assets/background.png')}
      style={styles.backgroundImage}
      resizeMode="contain" // Ensure the entire image is covered without distortion
    >
      <View style={styles.container}>
      <View style={styles.logoContainer}>
        <Image
          style={styles.logoImage}
          source={require('./assets/knee.png')} // Replace with your local image path
        />
      </View>

        <Text style={styles.title}>Knee-OA </Text>
        <TextInput
          style={styles.input}
          placeholder="Username"
          onChangeText={(text) => setUsername(text)}
          value={username}
        />
        <TextInput
          style={styles.input}
          placeholder="Password"
          secureTextEntry
          onChangeText={(text) => setPassword(text)}
          value={password}
        />
        <TouchableOpacity style={styles.button} onPress={handleLogin}>
          <Text style={styles.buttonText}>LOGIN </Text>
        </TouchableOpacity>
        <TouchableOpacity onPress={() => navigation.navigate('SignUp')}>
          <Text style={styles.signUpText}>Sign Up</Text>
        </TouchableOpacity>
        <TouchableOpacity onPress={() => navigation.navigate('ForgotPassword')}>
          <Text style={styles.forgotPasswordText}>Forgot Password</Text>
        </TouchableOpacity>
      </View>
    </ImageBackground>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  backgroundImage: {
    flex: 1,
    justifyContent: 'center',
    resizeMode: 'cover',
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    marginTop: 10,
    marginBottom: 30,
    color: 'black',
  },
  input: {
    height: 40,
    width: '65%',
    borderColor: '#93FCDD',
    borderWidth: 1,
    marginBottom: 20,
    paddingLeft: 10,
    backgroundColor: '#93FCDD',
    opacity: 0.8,
  },
  button: {
    backgroundColor: '#A580F3',
    padding: 10,
    borderRadius: 8,
    marginTop: 10,
  },
  buttonText: {
    color: 'black',
    fontSize: 16,
    paddingLeft: 10,
  },
  signUpText: {
    color: 'black',
    marginTop: 10,
    fontSize: 16,
  },
  forgotPasswordText: {
    color: 'black',
    marginTop: 10,
    fontSize: 16,
  },
});

export default LoginScreen;
