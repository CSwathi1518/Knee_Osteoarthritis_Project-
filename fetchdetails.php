<?php
// Include the dbh.php file for the database connection
require_once 'dbh.php'; // Ensure the path is correct

// Enable error logging
error_reporting(E_ALL);
ini_set('display_errors', 1);
error_log("Accessing the patient data script."); // Log access to the script

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Access-Control-Allow-Methods: GET");
header("Content-Type: application/json");

// Handle GET request for fetching patient details
if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    $patientID = isset($_GET['patientID']) ? trim($_GET['patientID']) : '';

    // Initialize response array
    $response = ['status' => '', 'data' => [], 'message' => ''];

    if ($patientID) {
        // Prepare and execute database query to fetch patient data
        try {
            $stmt = $conn->prepare("SELECT patient_id, image_path, prediction, confidence_score FROM images WHERE patient_id = ?");
            $stmt->execute([$patientID]);

            // Fetch all records
            $records = $stmt->fetchAll(PDO::FETCH_ASSOC);

            if ($records) {
                $response['status'] = 'success';
                $response['data'] = $records;
            } else {
                $response['status'] = 'no_data';
                $response['message'] = 'No records found for this patient ID.';
            }
        } catch (PDOException $e) {
            $response['status'] = 'error';
            $response['message'] = 'Database query failed: ' . $e->getMessage();
            error_log($response['message']); // Log the error for debugging
        }
    } else {
        $response['status'] = 'error';
        $response['message'] = 'Patient ID is required.';
    }

    // Return response in JSON format
    echo json_encode($response);
    exit();
}

// Close the database connection
$conn = null; // Close PDO connection
?>
