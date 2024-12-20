<?php
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    $response = array('status' => 'failed', 'data' => 'Invalid request method');
    sendJsonResponse($response);
    die;
}

include_once("dbconnect.php");

$email = mysqli_real_escape_string($conn, $_POST['email']);
$password = md5($_POST['password']); // Ensure your database uses sha1 hashed passwords

// Query to check login credentials
$sqllogin = "SELECT `admin_email` FROM `tbl_admins` WHERE `admin_email` = '$email' AND `admin_password` = '$password'";
$result = $conn->query($sqllogin);

if (!$result) {
    // SQL error handling
    $response = array('status' => 'failed', 'data' => mysqli_error($conn));
    sendJsonResponse($response);
    die;
}

if ($result->num_rows > 0) {
    // Login success
    $response = array('status' => 'success', 'data' => null);
    sendJsonResponse($response);
} else {
    // Login failed
    $response = array('status' => 'failed', 'data' => 'Invalid email or password');
    sendJsonResponse($response);
}

function sendJsonResponse($sentArray)
{
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}
?>
