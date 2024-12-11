<?php
include 'dbh.php'; // Include the dbh.php file for the database connection

// Check if patientID is provided in the query string
if (!isset($_GET['patientID'])) {
    die(json_encode(array("status" => "error", "message" => "PatientID parameter missing")));
}

$patientID = $_GET['patientID'];

// Prepare SQL to delete patient
$sql = "DELETE FROM patients WHERE patientID = ?";

// Use prepared statement for security
$stmt = $conn->prepare($sql);
$stmt->bindParam(1, $patientID, PDO::PARAM_INT);

// Execute the delete statement
if ($stmt->execute()) {
    // Check if any row was affected
    if ($stmt->rowCount() > 0) {
        // Patient deleted successfully
        echo json_encode(array("status" => "success", "message" => "Patient deleted successfully"));
    } else {
        // No rows affected (patient with given ID not found)
        echo json_encode(array("status" => "error", "message" => "No patient found with ID $patientID"));
    }
} else {
    // Error executing delete statement
    echo json_encode(array("status" => "error", "message" => "Failed to delete patient: " . $conn->errorInfo()[2]));
}

// Close statement and connection
$stmt = null;
$conn = null;
?>
