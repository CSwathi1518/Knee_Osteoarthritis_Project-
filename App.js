import React, { useState } from 'react';
import { Alert, 
  Image, 
  StyleSheet,
  ImageBackground, 
  Text, 
  TextInput, 
  TouchableOpacity,
  Animated, 
  View } from 'react-native';
import Dashboard from './dashboard';

const App = () => {
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [isLoggedIn, setLoggedIn] = useState(false);

  const handleSignUp = () => {
    const registerApiUrl = 'http://172.18.21.46/kneeOA/project.php';

    fetch(registerApiUrl, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ username, password, register: true }),
    })
      .then(response => response.json())
      .then(data => {
        console.log('Registration Response:', data);
        showAlert(data.message);
        if (data.status === 'success') {
          setLoggedIn(true);
        }
      })
      .catch(error => {
        console.error('Registration Error:', error);
        showAlert('Registration failed. Please try again.');
      });
  };

  const handleLogin = () => {
    const loginApiUrl = 'http://192.168.144.193/kneeOA/project.php'; 
    
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
          setLoggedIn(true);
        } else {
          showAlert('Login failed. Please try again.');
        }
      })
      .catch(error => {
        console.error('Login Error:', error);
        showAlert('Login failed. Please try again.');
      });
  };
  

  const handleForgotPassword = () => {
    // Validate email
    if (username === '') {
      showAlert('Username is required');
      return;
    }
    
    // Initiate password reset
    const forgotPasswordApiUrl = 'http://192.168.144.193/kneeOA/project.php';
  
    fetch(forgotPasswordApiUrl, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ username, forgotPassword: true }),
    })
      .then(response => {
        if (!response.ok) {
          throw new Error(`HTTP error! Status: ${response.status}`);
        }
        return response.json();
      })
      .then(data => {
        console.log('Forgot Password Response:', data);
  
        if (data.status === 'success') {
          showAlert('Password reset email sent! Please check your inbox.');
        } else {
          showAlert(data.message || 'Password reset failed. Please try again.');
        }
      })
      .catch(error => {
        console.error('Forgot Password Error:', error);
        showAlert('Password reset failed. Please try again.');
      });
  };
  
  

  const handleLogout = () => {
    setLoggedIn(false);
  };

  const showAlert = message => {
    Alert.alert('Status', message);
  };

  const animateButton = () => {
    Animated.timing(signUpButtonOpacity, {
      toValue: 0.5,
      duration: 300,
      useNativeDriver: true,
    }).start();
  };

  if (isLoggedIn) {
    return <Dashboard username={username} handleLogout={handleLogout} />;
  }

  return (
    <ImageBackground
      source={{
        uri: 'https://th.bing.com/th/id/OIP.PgtPOmh-AiHfTEV_KYL05AAAAA?rs=1&pid=ImgDetMain',
      }}
      style={styles.backgroundImage}
    >
      <View style={styles.container}>
        <View style={styles.circleContainer}>
          <Image
            source={{
              uri: 'https://thumbs.dreamstime.com/z/arthritis-ray-rgb-color-icon-joint-deformity-depiction-osteoarthritis-diagnosis-medical-imaging-evidence-bones-inflammation-233160746.jpg',
            }}
            style={styles.profileImage}
          />
        </View>
        <View style={styles.inputContainer}>
          <TextInput
            style={styles.input}
            placeholder="Username"
            onChangeText={text => setUsername(text)}
            value={username}
          />
          <TextInput
            style={styles.input}
            placeholder="Password"
            secureTextEntry
            onChangeText={text => setPassword(text)}
            value={password}
          />
        </View>
        <View style={styles.buttonContainer}>
          <TouchableOpacity style={styles.button} onPress={handleLogin}>
            <Text style={styles.buttonText}>Login</Text>
          </TouchableOpacity>
          <TouchableOpacity style={styles.signUpText} onPress={handleSignUp}>
            <Text style={styles.signUpText}>Sign Up</Text>
          </TouchableOpacity>
        </View>
        <TouchableOpacity
          onPress={handleForgotPassword}
          style={styles.forgotPassword}
        >
          <Text style={styles.forgotPasswordText}>Forgot Password?</Text>
        </TouchableOpacity>
      </View>
    </ImageBackground>
  );
};

const styles = StyleSheet.create({
  backgroundImage: {
    flex: 1,
    resizeMode: 'cover',
    justifyContent: 'center',
  },
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center', 
  },
  circleContainer: {
    marginBottom: 40,
    alignItems: 'center',
  },
  profileImage: {
    width: 100,
    height: 100,
  },
  inputContainer: {
    marginBottom: 20,
  },
  input: {
    height: 40,
    width: 250, 
    borderColor: '#333', 
    borderWidth: 1,
    marginBottom: 10,
    paddingLeft: 10,
    backgroundColor: '#fff',
    borderRadius: 8,
  },
  button: {
    backgroundColor: 'green',
    padding: 10,
    borderRadius: 10,
    marginTop: 4,
  },
  buttonText: {
    color: 'white',
    fontSize: 16,
    fontWeight: 'bold',
  },

  signUpText: {
    color: 'white',
    textAlign: 'center',
    fontSize: 15,
    alignSelf: 'center',
    marginTop: 5,
  },

  buttonText: {
    color: 'white',
    fontSize: 15,
    fontWeight: '200',
    textAlign: 'center',
    padding: 5,
  },
  forgotPasswordText: {
    color: 'white',
    fontSize: 16,
    textAlign: 'center', // Center the text horizontally
    alignSelf: 'center',
    marginTop: 5,
  },
});

export default App;
