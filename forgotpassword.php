<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header('Content-Type: application/json');

require "dbh.php"; // Connect to the database

// Get the raw POST data as a string
$json_data = file_get_contents("php://input");

// Decode the JSON data into an associative array
$request_data = json_decode($json_data, true); 

// Check if 'email' key exists in $request_data
if (isset($request_data['email'])) {
    // Get the email from the decoded JSON data
    $email = $request_data['email'];

    // Check if the provided email exists in the database
    $sql = "SELECT * FROM users WHERE email = :email";
    $stmt = $conn->prepare($sql);
    $stmt->bindParam(':email', $email, PDO::PARAM_STR);
    $stmt->execute();

    // Check if a user with the provided email exists
    if ($stmt->rowCount() > 0) {
        // Generate a random password (you might want to implement a more secure method)
        $newPassword = generateRandomPassword();

        // Update the user's password in the database
        $sqlUpdate = "UPDATE users SET password = :newPassword WHERE email = :email";
        $stmtUpdate = $conn->prepare($sqlUpdate);
        $stmtUpdate->bindParam(':newPassword', $newPassword, PDO::PARAM_STR);
        $stmtUpdate->bindParam(':email', $email, PDO::PARAM_STR);
        $stmtUpdate->execute();

        // Respond with success and include the new password
        $response['status'] = "success";
        $response['message'] = "Password reset successfully!";
        $response['newPassword'] = $newPassword;
    } else {
        // Respond with error if no user found
        $response['status'] = "error";
        $response['message'] = "No user found with the provided email";
    }

    // Close the prepared statement
    $stmt->closeCursor();
} else {
    // Handle the case where 'email' is missing
    $response['status'] = "error";
    $response['message'] = "Invalid request data";
}

// Close the database connection
$conn = null;

// Respond with JSON
echo json_encode($response);

// Function to generate a random password
function generateRandomPassword($length = 8) {
    $characters = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
    $password = '';
    for ($i = 0; $i < $length; $i++) {
        $password .= $characters[rand(0, strlen($characters) - 1)];
    }
    return $password;
}
?>