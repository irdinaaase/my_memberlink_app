<?php
include_once("dbconnect.php");

// Check if required fields are passed in POST request
if (!isset($_POST['email'], $_POST['password'], $_POST['title'], $_POST['firstName'], $_POST['lastName'], $_POST['phone'], $_POST['address']) || 
    empty($_POST['email']) || empty($_POST['password']) || empty($_POST['firstName']) || empty($_POST['lastName'])) {
    $response = array('status' => 'failed', 'data' => 'Missing required fields');
    sendJsonResponse($response);
    die();
}

// Sanitize and validate user inputs
$title = $conn->real_escape_string($_POST['title']);
$firstName = $conn->real_escape_string($_POST['firstName']);
$lastName = $conn->real_escape_string($_POST['lastName']);
$phone = $conn->real_escape_string($_POST['phone']);
$address = $conn->real_escape_string($_POST['address']);
$email = $conn->real_escape_string($_POST['email']);

// Hash the password
$password = sha1($_POST['password']); // Consider using `password_hash` in production

// Insert the data into the database
$sqlinsert = "INSERT INTO `tbl_admins`(`admin_title`,`admin_firstName`,`admin_lastName`,`admin_phone`,`admin_address`,`admin_email`, `admin_pass`) VALUES ('$title','$firstName','$lastName','$phone','$address','$email', '$password')";

// Execute the query and send appropriate response
if ($conn->query($sqlinsert) === TRUE) {
    $response = array('status' => 'success', 'data' => null);
    sendJsonResponse($response);
} else {
    $response = array('status' => 'failed', 'data' => 'Database error: ' . $conn->error);
    sendJsonResponse($response);
}

// Function to send JSON response
function sendJsonResponse($sentArray) {
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}
?>
