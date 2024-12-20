<?php
// Disable error display in production
ini_set('display_errors', 0);
error_reporting(E_ALL);

include_once("dbconnect.php");

if (isset($_POST['action'])) {
    $action = $_POST['action'];
    
    // Check if it's the correct action
    if ($action == 'register_user' && isset($_POST['email']) && isset($_POST['password'])) {
        registerUser($_POST);
    } else {
        sendJsonResponse('error', 'Invalid parameters or missing data');
    }
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
    $password = md5($data['password']); // hash the password for storage

    // Validate required fields
    if (empty($title) || empty($firstName) || empty($lastName) || empty($phone) || empty($address) || empty($email) || empty($password)) {
        sendJsonResponse('error', 'All fields are required');
    }

    // Check if the email already exists (Use 'admin_email' instead of 'email')
    $checkEmailQuery = "SELECT * FROM tbl_admins WHERE admin_email = '$email'";  // Update 'email' to 'admin_email'
    $result = mysqli_query($conn, $checkEmailQuery);
    if (mysqli_num_rows($result) > 0) {
        sendJsonResponse('error', 'Email already exists');
    }

    // Insert user into the database (Use 'admin_email' for the email column)
    $query = "INSERT INTO tbl_admins (admin_title, admin_firstName, admin_lastName, admin_phone, admin_address, admin_email, admin_password) 
              VALUES ('$title', '$firstName', '$lastName', '$phone', '$address', '$email', '$password')";
    
    if (mysqli_query($conn, $query)) {
        sendJsonResponse('success', 'User registered successfully');
    } else {
        sendJsonResponse('error', 'Failed to register user');
    }
}

// Function to send JSON response
function sendJsonResponse($status, $message) {
    // Make sure the header is set to JSON
    header('Content-Type: application/json');
    echo json_encode(['status' => $status, 'data' => $message]);
    exit;
}
?>
