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
$patientID = $input['patientID'] ?? '';
$patientname = $input['patientname'] ?? '';
$Age = $input['Age'] ?? '';
$Gender = $input['Gender'] ?? '';
$contactnumber = $input['contactnumber'] ?? '';

// Check if any required field is empty
if (empty($patientID) || empty($patientname) || empty($Age) || empty($Gender) || empty($contactnumber)) {
    $response = array("success" => false, "message" => "All fields are required.");
    echo json_encode($response);
    exit;
}

try {
    // Insert the user into the database
    $query = "INSERT INTO patients (patientID, patientname, Age, Gender, contactnumber) VALUES (:patientID, :patientname, :Age, :Gender, :contactnumber)";
    $stmt = $conn->prepare($query);
    $stmt->bindParam(':patientID', $patientID);
    $stmt->bindParam(':patientname', $patientname);
    $stmt->bindParam(':Age', $Age);
    $stmt->bindParam(':Gender', $Gender);
    $stmt->bindParam(':contactnumber', $contactnumber);

    $stmt->execute();

    $response = array("success" => true, "message" => "Patient added successfully.");
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