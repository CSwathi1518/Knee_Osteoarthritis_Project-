<?php
// Include database connection or configuration
include 'dbh.php';

// Set headers for JSON response
header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405); // Method Not Allowed
    echo json_encode(['message' => 'Method not allowed']);
    exit;
}

// Base URL for serving uploaded files
$base_url = "http://172.25.35.148/demo/uploads.php"; // Replace with your local network IP address

// Directory for uploaded files
$upload_dir = 'uploads/';

// Ensure the upload directory exists
if (!is_dir($upload_dir)) {
    mkdir($upload_dir, 0755, true);
}

// Check if file is uploaded
if (!isset($_FILES['image'])) {
    http_response_code(400); // Bad Request
    echo json_encode(['message' => 'No file uploaded']);
    exit;
}

// Handle the file upload
$file = $_FILES['image'];

if ($file['error'] !== UPLOAD_ERR_OK) {
    http_response_code(500); // Server Error
    echo json_encode(['message' => 'File upload error', 'error' => $file['error']]);
    exit;
}

// Move uploaded file to upload directory
$tmp_name = $file['tmp_name'];
$name = basename($file['name']);
$target_file = $upload_dir . $name;

if (!move_uploaded_file($tmp_name, $target_file)) {
    http_response_code(500); // Server Error
    echo json_encode(['message' => 'Failed to move uploaded file']);
    exit;
}

// Construct full URL of the uploaded file
$file_url = $base_url . $target_file;

try {
    // Save the file URL in the database
    $stmt = $conn->prepare("INSERT INTO images (url) VALUES (:url)");
    $stmt->bindParam(':url', $file_url);

    if ($stmt->execute()) {
        // Return JSON response with success message and file URL
        http_response_code(201); // Created
        echo json_encode(['message' => 'File uploaded successfully', 'url' => $file_url]);
    } else {
        http_response_code(500); // Server Error
        echo json_encode(['message' => 'Database error: ' . $stmt->errorInfo()[2]]);
    }
} catch (PDOException $e) {
    http_response_code(500); // Server Error
    echo json_encode(['message' => 'Database error: ' . $e->getMessage()]);
}

// Close database connection
$conn = null;
?>
