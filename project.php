<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

require "dbh.php"; // Connect to the database

// Get the raw POST data as a string
$json_data = file_get_contents("php://input");

// Decode the JSON data into an associative array
$request_data = json_decode($json_data, true);

// Check if required fields are present
if (isset($request_data['username']) && isset($request_data['password'])) {
    // Extract data from request
    $username = $request_data['username'];
    $password = $request_data['password'];

    // Handle registration
    if (isset($request_data['register'])) {
        // Check if confirm_password field is present
        if (isset($request_data['confirm_password'])) {
            $confirm_password = $request_data['confirm_password'];

            // Check if passwords match
            if ($password !== $confirm_password) {
                $response['status'] = "error";
                $response['message'] = "Passwords do not match";
            } else {
                // Perform registration
                $sql = "INSERT INTO users (username, password) VALUES (:username, :password)";
                $stmt = $conn->prepare($sql);
                $stmt->bindParam(':username', $username, PDO::PARAM_STR);
                $stmt->bindParam(':password', $hashed_password, PDO::PARAM_STR);
                $hashed_password = password_hash($password, PASSWORD_DEFAULT); // Hash the password
                $stmt->execute();

                // Execute the statement
                if ($stmt->rowCount() > 0) {
                    $response['status'] = "success";
                    $response['message'] = "Registration successful!";
                } else {
                    $response['status'] = "error";
                    $response['message'] = "Failed to register user";
                }
                $stmt->closeCursor();
            }
        } else {
            $response['status'] = "error";
            $response['message'] = "Confirm password field missing";
        }
    } else {
        // Handle login
        $sql = "SELECT * FROM users WHERE username = :username AND password = :password";
        $stmt = $conn->prepare($sql);
        $stmt->bindParam(':username', $username, PDO::PARAM_STR);
        $stmt->bindParam(':password', $hashed_password, PDO::PARAM_STR);
        $hashed_password = $request_data['password'];
        $stmt->execute();

        // Execute the statement
        if ($stmt->rowCount() > 0) {
            $response['status'] = "success";
            $response['message'] = "Login successful!";
        } else {
            $response['status'] = "error";
            $response['message'] = "Invalid username or password";
        }
        $stmt->closeCursor();
    }
} else {
    // Handle case where required fields are missing
    $response['status'] = "error";
    $response['message'] = "Invalid request data";
}

// Close the database connection
$conn = null;

// Respond with JSON
echo json_encode($response);
?>
