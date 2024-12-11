<?php
// Database Connection
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "knee";

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Get data from POST request
$username = $_POST['username'];
$password = $_POST['password'];

// Prepare SQL statement
$sql = "INSERT INTO user_credentials (username, password) VALUES ('$username', '$password')";

if ($conn->query($sql) === TRUE) {
    echo json_encode(array("status" => "success", "message" => "Data stored successfully"));
} else {
    echo json_encode(array("status" => "error", "message" => "Error storing data: " . $conn->error));
}

$conn->close();
?>
