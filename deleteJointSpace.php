<?php
// Include dbh.php to use the database connection
include 'dbh.php';

// Check if patientID is provided in the query string
if (!isset($_GET['patientID'])) {
    die(json_encode(array("status" => "error", "message" => "PatientID parameter missing")));
}

$patientID = $_GET['patientID'];

// Prepare SQL to delete patient from 'JointSpace' table
$sql = "DELETE FROM JointSpace WHERE patientID = ?";

// Use prepared statement for security
$stmt = $conn->prepare($sql);
$stmt->bindParam(1, $patientID, PDO::PARAM_INT);

// Execute the delete statement
if ($stmt->execute()) {
    // Check if any row was affected
    if ($stmt->rowCount() > 0) {
        // Image record deleted successfully
        echo json_encode(array("status" => "success", "message" => "Image record deleted successfully"));
    } else {
        // No rows affected (patient with given ID not found)
        echo json_encode(array("status" => "error", "message" => "No image record found for patient with ID $patientID"));
    }
} else {
    // Error executing delete statement
    echo json_encode(array("status" => "error", "message" => "Failed to delete image record: " . $stmt->errorInfo()[2]));
}

// Close connection
$conn = null;
?>
