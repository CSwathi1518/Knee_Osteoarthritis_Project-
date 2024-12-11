<?php
// Allow requests from any origin (replace * with the appropriate origin if needed)
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json");

require 'dbh.php';

// Retrieve and decode JSON POST data
$inputJSON = file_get_contents('php://input');
$input = json_decode($inputJSON, true);

// Retrieve decoded POST data
$username = $input['username'] ?? '';
$doctorName = $input['doctorName'] ?? '';
$age = $input['age'] ?? '';
$gender = $input['gender'] ?? '';
$department = $input['department'] ?? '';
$contactNumber = $input['contactNumber'] ?? '';
$password = $input['password'] ?? '';

try {
    // Insert the user into the database
    $query = "INSERT INTO users (username, doctorName, age, gender, department, contactNumber, password) VALUES (:username, :doctorName, :age, :gender, :department, :contactNumber, :password)";
    $stmt = $conn->prepare($query);
    $stmt->bindParam(':username', $username);
    $stmt->bindParam(':doctorName', $doctorName);
    $stmt->bindParam(':age', $age);
    $stmt->bindParam(':gender', $gender);
    $stmt->bindParam(':department', $department);
    $stmt->bindParam(':contactNumber', $contactNumber);
    $stmt->bindParam(':password', $password);

    $stmt->execute();

    $response = array("success" => true, "message" => "User signed up successfully.");
    echo json_encode($response);
} catch (PDOException $e) {
    // Handle database errors
    $response = array("success" => false, "message" => "Database error: " . $e->getMessage());
    echo json_encode($response);
} catch (Exception $e) {
    // Handle other exceptions
    $response = array("success" => false, "message" => "Error: " . $e->getMessage());
    echo json_encode($response);
}
?>