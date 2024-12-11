<?php
// Include the database connection from dbh.php
include 'dbh.php';

// Assuming POST method is used to receive patientID
$patientID = $_GET['patientID']; // Use $_POST if sending via POST method

// SQL query to check if patientID exists
$sql = "SELECT COUNT(*) as count FROM patients WHERE patientID = :patientID";
$stmt = $conn->prepare($sql);
$stmt->bindParam(':patientID', $patientID);
$stmt->execute();
$result = $stmt->fetch(PDO::FETCH_ASSOC);

// Return JSON response
header('Content-Type: application/json');
if ($result) {
    echo json_encode(array('exists' => ($result['count'] > 0)));
} else {
    echo json_encode(array('exists' => false));
}
?>
