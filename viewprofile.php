<?php
// Allow requests from any origin
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json");

require 'dbh.php';

// Retrieve the username from the query parameters
$username = $_GET['username'] ?? '';
error_log("Username received: " . $username); // Log username

try {
    // Prepare and execute the query to fetch user details
    $query = "SELECT username, doctorName, age, gender, department, contactNumber FROM users WHERE username = :username";
    $stmt = $conn->prepare($query);
    $stmt->bindParam(':username', $username);
    $stmt->execute();

    // Fetch the user details
    $doctorDetails = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($doctorDetails) {
        // Return the user details as a JSON response
        echo json_encode($doctorDetails);
    } else {
        // No user found
        $response = array("success" => false, "message" => "No data found");
        echo json_encode($response);
    }
} catch (PDOException $e) {
    // Handle database errors
    $response = array("success" => false, "message" => "Database error: " . $e->getMessage());
    echo json_encode($response);
} catch (Exception $e) {
    // Handle other exceptions
    $response = array("success" => false, "message" => "Error: " . $e->getMessage());
    echo json_encode($response);
}
?>
