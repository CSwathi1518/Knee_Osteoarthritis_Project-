<?php
// Include the database connection file
require_once('dbh.php');

// Set the headers to force the browser to download the file
header('Content-Type: text/csv; charset=utf-8');
header('Content-Disposition: attachment; filename="data_export.csv"');

// Open the output stream
$output = fopen('php://output', 'w');

// Use a SQL query to fetch all rows from the 'patients' table
$query = "SELECT * FROM patients";
$result = $conn->query($query);

// Check if there are results
if ($result && $result->num_rows > 0) {
    // Fetch the field names (column headers) from the first row
    $fields = $result->fetch_fields();
    $header = [];
    foreach ($fields as $field) {
        $header[] = $field->name;  // Get the column name
    }

    // Write the column headers to the CSV file
    fputcsv($output, $header);

    // Write the data rows to the CSV file
    while ($row = $result->fetch_assoc()) {
        fputcsv($output, $row);  // Write each row
    }
} else {
    echo "No data found.";
}

// Close the output stream
fclose($output);

// Close the database connection
$conn->close();
?>
