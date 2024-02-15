import React, { useState } from 'react';
import { View, Text, TextInput, TouchableOpacity, StyleSheet, ImageBackground, Alert } from 'react-native';
import { useNavigation } from '@react-navigation/native';

const SignUpScreen = () => {
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [phoneNumber, setPhoneNumber] = useState('');
  const [email, setEmail] = useState('');
  const navigation = useNavigation();

  const handleSignUp = () => {
    if (!username || !password || !phoneNumber || !email) {
      showAlert('Please fill in all fields');
      return;
    }

    const registerApiUrl = 'http://192.168.144.193/demo/signup.php';

    fetch(registerApiUrl, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ username, password, phoneNumber, email }),
    })
      .then(response => response.json())
      .then(data => {
        showAlert(data.message);
        if (data.status === 'success') {
          navigation.navigate('Login');
        }
      })
      .catch(error => {
        console.error('Registration Error:', error);
        showAlert('Registration failed. Please try again.');
      });
  };

  const showAlert = (message) => {
    Alert.alert('Status', message);
  };

  return (
    <ImageBackground
      source={require('./assets/background.png')}
      style={styles.backgroundImage}
    >
      <View style={styles.container}>
        <Text style={styles.title}>REGISTER</Text>
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
        <TextInput
          style={styles.input}
          placeholder="Phone Number"
          onChangeText={(text) => setPhoneNumber(text)}
          value={phoneNumber}
        />
        <TextInput
          style={styles.input}
          placeholder="Email"
          onChangeText={(text) => setEmail(text)}
          value={email}
        />
        <TouchableOpacity style={styles.button} onPress={handleSignUp}>
          <Text style={styles.buttonText}>SIGN UP</Text>
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
    resizeMode: 'stretch',
    justifyContent: 'center',
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    marginBottom: 30,
    color: 'black',
  },
  input: {
    height: 40,
    width: '80%',
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
  },
});

export default SignUpScreen;
