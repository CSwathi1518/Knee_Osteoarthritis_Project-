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

// Check if 'username' and 'password' keys exist in $request_data
if (isset($request_data['username']) && isset($request_data['password'])) {
    // Get the username and password from the decoded JSON data
    $username = $request_data['username'];
    $password = $request_data['password'];

    if (isset($request_data['register']) && $request_data['register'] === true) {
        // Registration
        $sql = "INSERT INTO users (username, password) VALUES (:username, :password)";
        $stmt = $conn->prepare($sql);
        $stmt->bindParam(':username', $username, PDO::PARAM_STR);
        $stmt->bindParam(':password', $password, PDO::PARAM_STR);
        $stmt->execute();

        // Check if the insertion was successful
        if ($stmt->rowCount() > 0) {
            $response['status'] = "success";
            $response['message'] = "Registration successful!";
        } else {
            $response['status'] = "error";
            $response['message'] = "Failed to register user";
        }

        // Close the prepared statement
        $stmt->closeCursor();

    // Query to check login credentials using prepared statements
    } else{
            $sql = "SELECT * FROM users WHERE username = :username AND password = :password";
            $stmt = $conn->prepare($sql);
            $stmt->bindParam(':username', $username, PDO::PARAM_STR);
            $stmt->bindParam(':password', $password, PDO::PARAM_STR);
            $stmt->execute();

                // Check if login credentials are valid
            if ($stmt->rowCount() > 0) {
                    $response['status'] = "success";
                    $response['message'] = "Login successful!";
            } else {
                    $response['status'] = "error";
                    $response['message'] = "Invalid username or password";
            }

                // Close the prepared statement
            $stmt->closeCursor();
        }
} else {
    // Handle the case where 'username' or 'password' is missing
    $response['status'] = "error";
    $response['message'] = "Invalid request data";
}

// Close the database connection
$conn = null;

// Respond with JSON
echo json_encode($response);
?>
