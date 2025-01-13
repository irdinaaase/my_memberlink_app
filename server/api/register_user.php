<?php
ini_set('display_errors', 0); 
error_reporting(E_ALL);

include_once("dbconnect.php");

if (!$conn) {
    sendJsonResponse('error', 'Database connection failed');
}

function sendJsonResponse($status, $message) {
    header('Content-Type: application/json');
    header('Access-Control-Allow-Origin: *');
    header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
    header('Access-Control-Allow-Headers: Content-Type, Authorization');
    echo json_encode(['status' => $status, 'message' => $message]);
    exit;
}

if (isset($_POST['action']) && $_POST['action'] === 'register_user') {
    registerUser($_POST);
} else {
    sendJsonResponse('error', 'Invalid action or missing parameters');
}

function registerUser($data) {
    global $conn;

    // Sanitize and validate inputs
    $title = mysqli_real_escape_string($conn, $data['title']);
    $firstName = mysqli_real_escape_string($conn, $data['first_name']);
    $lastName = mysqli_real_escape_string($conn, $data['last_name']);
    $phone = mysqli_real_escape_string($conn, $data['phone']);
    $address = mysqli_real_escape_string($conn, $data['address']);
    $email = mysqli_real_escape_string($conn, $data['email']);
    $password = md5($data['password']);

    // Validate required fields
    if (empty($title) || empty($firstName) || empty($lastName) || empty($phone) || empty($address) || empty($email) || empty($password)) {
        sendJsonResponse('error', 'All fields are required');
    }

    // Check if the email already exists
    $checkEmailQuery = "SELECT * FROM tbl_users WHERE users_email = '$email'";
    $result = mysqli_query($conn, $checkEmailQuery);
    if (mysqli_num_rows($result) > 0) {
        sendJsonResponse('error', 'Email already exists');
    }

    // Insert user into the database
    $query = "INSERT INTO tbl_users (users_title, users_firstName, users_lastName, users_phone, users_address, users_email, users_password) 
              VALUES ('$title', '$firstName', '$lastName', '$phone', '$address', '$email', '$password')";

    if (mysqli_query($conn, $query)) {
        sendJsonResponse('success', 'User registered successfully');
    } else {
        sendJsonResponse('error', 'Failed to register user');
    }
}

sendJsonResponse('error', 'Unknown error occurred');
$conn->close();
?>
