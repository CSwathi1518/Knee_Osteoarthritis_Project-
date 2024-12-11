<?php
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

// Get the POST data from the request
$DoctorId = $_POST['DoctorId'];
$name = $_POST['name'];
$contactNo = $_POST['contactNo'];
$age = $_POST['age'];
$gender = $_POST['gender'];
$password = $_POST['password'];
$confirmPassword = $_POST['confirmPassword'];

// Validate form inputs
if (empty($DoctorId) || empty($name) || empty($contactNo) || empty($age) || empty($gender) ||  empty($password) || empty($confirmPassword)) {
    die(json_encode(["success" => false, "message" => "Please fill in all required fields."]));
}

// Check if passwords match
if ($password !== $confirmPassword) {
    die(json_encode(["success" => false, "message" => "Passwords do not match."]));
}

// Upload image
$imageDir = "uploads/";
$imagePath = $imageDir . basename($_FILES["image"]["name"]);

if (move_uploaded_file($_FILES["image"]["tmp_name"], $imagePath)) {
    // Image uploaded successfully, proceed with database insertion

    // Prepare SQL statement
    $sql = "INSERT INTO doctor (DoctorId, name, contactNo, age, gender,  password, confirmPassword, image) VALUES (?, ?, ?, ?, ?, ?, ?)";
    $stmt = $conn->prepare($sql);

    // Bind parameters
    $stmt->bind_param("sssisdssssisss", $DoctorId, $name, $contactNo, $age, $gender,  $password, $confirmPassword, $imagePath);

    // Execute statement
    if ($stmt->execute()) {
        echo json_encode(["success" => true, "message" => "Form submitted successfully."]);
    } else {
        echo json_encode(["success" => false, "message" => "Error inserting data into database: " . $stmt->error]);
    }

    // Close statement
    $stmt->close();
} else {
    // Image upload failed
    die(json_encode(["success" => false, "message" => "Error uploading image."]));
}

// Close connection
$conn->close();

?>