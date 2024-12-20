<?php
include_once("dbconnect.php");

if (isset($_POST['action'])) {
    $action = $_POST['action'];
    
    if ($action == 'register_user' && isset($_POST['email']) && isset($_POST['password'])) {
        registerUser($_POST);
    } else {
        sendJsonResponse('error', 'Invalid parameters');
    }
}

function registerUser($data) {
    global $conn;

    $title = $data['title'];
    $firstName = $data['firstName'];
    $lastName = $data['lastName'];
    $phone = $data['phone'];
    $address = $data['address'];
    $email = $data['email'];
    $password = md5($data['password']); // hash the password for storage
    
    $query = "INSERT INTO tbl_admins (title, firstName, lastName, phone, address, email, password) 
              VALUES ('$title', '$firstName', '$lastName', '$phone', '$address', '$email', '$password')";
    
    if (mysqli_query($conn, $query)) {
        sendJsonResponse('success', 'User registered successfully');
    } else {
        sendJsonResponse('error', 'Failed to register user');
    }
}

function sendJsonResponse($status, $message) {
    echo json_encode(['status' => $status, 'data' => $message]);
    exit;
}
?>