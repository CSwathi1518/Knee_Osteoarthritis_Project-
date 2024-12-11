<?php
include 'dbh.php'; // Include the dbh.php file to get the connection object $conn

// Check connection
if (!$conn) {
    die(json_encode(array("status" => "error", "message" => "Connection failed")));
}

// Prepare SQL query to fetch all patients and order by patientID
$sql = "SELECT * FROM patients ORDER BY patientID ASC";

try {
    $stmt = $conn->prepare($sql);
    $stmt->execute();

    $patients = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // Return patients array as JSON response
    header('Content-Type: application/json');
    echo json_encode($patients);
} catch (PDOException $e) {
    // Handle query error
    $response = array("status" => "error", "message" => "Query failed: " . $e->getMessage());
    header('Content-Type: application/json');
    echo json_encode($response);
}

// Close connection
$conn = null;
?>
