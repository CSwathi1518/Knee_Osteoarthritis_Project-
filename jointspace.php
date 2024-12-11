<?php
// Include the dbh.php file for the database connection
require_once 'dbh.php'; // Ensure the path is correct

// Enable error logging
error_log("POST data: " . print_r($_POST, true)); // Log the POST data received
error_log("FILES data: " . print_r($_FILES, true)); // Log the FILES data received

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Access-Control-Allow-Methods: GET, POST");
header("Content-Type: application/json");

// Handle POST request for form submission
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Validate and sanitize form inputs for POST request
    $patientID = isset($_POST['patient_id']) ? trim($_POST['patient_id']) : '';
    $className = isset($_POST['class_name']) ? trim($_POST['class_name']) : '';
    $confidenceScore = isset($_POST['confidence_score']) ? trim($_POST['confidence_score']) : '';

    // Initialize response array
    $response = ['success' => false, 'message' => ''];

    // Check if file was uploaded
    if (isset($_FILES['image']) && $_FILES['image']['error'] === UPLOAD_ERR_OK) {
        $fileTmpPath = $_FILES['image']['tmp_name'];
        $fileName = $_FILES['image']['name'];
        $uploadFileDir = 'uploads/'; // Ensure this directory exists and is writable
        $dest_path = $uploadFileDir . basename($fileName);

        // Check if the uploaded file is an image
        $check = getimagesize($fileTmpPath);
        if ($check === false) {
            $response['message'] = 'File is not an image.';
            error_log($response['message']);
            echo json_encode($response);
            exit();
        }

        // Move the file to the upload directory
        if (move_uploaded_file($fileTmpPath, $dest_path)) {
            // Prepare and execute database query to insert patient data
            try {
                $stmt = $conn->prepare("
                    INSERT INTO images (image_name, image_path, patient_id, prediction, confidence_score) 
                    VALUES (?, ?, ?, ?, ?) 
                    ON DUPLICATE KEY UPDATE prediction = ?, confidence_score = ?
                ");

                // Execute the insert query
                $stmt->execute([
                    basename($fileName),
                    $dest_path,
                    $patientID,
                    $className,
                    $confidenceScore,
                    $className,
                    $confidenceScore
                ]);

                $response['success'] = true;
                $response['message'] = 'File successfully uploaded and patient data saved.';
            } catch (PDOException $e) {
                $response['message'] = 'Database query failed: ' . $e->getMessage();
                error_log($response['message']); // Log the error
            }
        } else {
            $response['message'] = 'Error moving the uploaded file.';
        }
    } else {
        $response['message'] = 'No file uploaded or upload error: ' . $_FILES['image']['error'];
        error_log($response['message']); // Log the error
    }

    // Return response in JSON format
    echo json_encode($response);
    exit();
}

// Close the database connection
$conn = null; // Close PDO connection
?>
