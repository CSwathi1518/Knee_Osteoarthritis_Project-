<?php
$servername = 'localhost';
$username = 'root';
$password = '';
$dbname = 'knee';

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Check if it's a GET request for retrieving doctor information
if ($_SERVER["REQUEST_METHOD"] === "GET") {
    $username = isset($_GET['username']) ? $_GET['username'] : null;

    $sql = "SELECT username, doctorName, age, gender, department, contactNumber, password FROM users WHERE username = '$username'";

    $result = $conn->query($sql);

    if ($result->num_rows > 0) {
        $row = $result->fetch_assoc();
        $conn->close();
        header('Content-Type: application/json');
        echo json_encode($row);
    } else {
        $response = array("status" => "error", "message" => "Doctor not found");
        echo json_encode($response);
    }
}

// Check if it's a POST request for updating doctor information
if ($_SERVER["REQUEST_METHOD"] === "POST") {
    // Extract the fields to be updated
    $username = $_POST['username'];
    $doctorName = $_POST['doctorName'];
    $age = $_POST['age'];
    $gender = $_POST['gender'];
    $department = $_POST['department'];
    $contactNumber = $_POST['contactNumber'];
    $password = $_POST['password'];

    // Construct the SQL query for updating
    $sql = "UPDATE users SET doctorName='$doctorName', age='$age', gender='$gender', department='$department', contactNumber='$contactNumber', password='$password' WHERE username='$username'";

    if ($conn->query($sql) === TRUE) {
        $response = array("status" => "success", "message" => "Doctor information updated successfully");
        echo json_encode($response);
    } else {
        $response = array("status" => "error", "message" => "Error updating doctor information: " . $conn->error);
        echo json_encode($response);
    }
    $conn->close();
}
?>