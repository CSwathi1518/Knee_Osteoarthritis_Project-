<?php
header('Content-Type: application/json');

// Include the database connection file
include 'dbh.php';

// Get the JSON data from the request body
$input = file_get_contents('php://input');
$data = json_decode($input, true);

// Validate the input data
if (!isset($data['patientID']) || !isset($data['patientname']) || !isset($data['Age']) || !isset($data['Gender']) || !isset($data['contactnumber'])) {
    echo json_encode(['status' => 'error', 'message' => 'Invalid input data']);
    exit;
}

$patientID = $data['patientID'];
$patientname = $data['patientname'];
$Age = $data['Age'];
$Gender = $data['Gender'];
$contactnumber = $data['contactnumber'];

// Prepare and execute the update statement
$sql = "UPDATE patients SET patientname = :patientname, Age = :Age, Gender = :Gender, contactnumber = :contactnumber WHERE patientID = :patientID";
$stmt = $conn->prepare($sql);

try {
    $stmt->execute(['patientname' => $patientname, 'Age' => $Age, 'Gender' => $Gender, 'contactnumber' => $contactnumber, 'patientID' => $patientID]);
    echo json_encode(['status' => 'success', 'message' => 'Patient details updated successfully']);
} catch (PDOException $e) {
    echo json_encode(['status' => 'error', 'message' => 'Failed to update patient details: ' . $e->getMessage()]);
}
?>
