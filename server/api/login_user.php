<?php
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    $response = array('status' => 'failed', 'data' => 'Invalid request method');
    sendJsonResponse($response);
    die();
}

include_once("dbconnect.php");

if (!$conn) {
    $response = array('status' => 'failed', 'message' => 'Database connection failed');
    sendJsonResponse($response);
    die();
}

function sendJsonResponse($sentArray) {
    header('Content-Type: application/json');
    header('Access-Control-Allow-Origin: *');
    header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
    header('Access-Control-Allow-Headers: Content-Type, Authorization');
    echo json_encode($sentArray);
    exit();
}

if (!isset($_POST['email']) || !isset($_POST['password'])) {
    sendJsonResponse(array('status' => 'failed', 'message' => 'Missing credentials'));
}

$email = mysqli_real_escape_string($conn, $_POST['email']);
$password = md5($_POST['password']);

// Query to check login credentials
$sqllogin = "SELECT * FROM `tbl_users` WHERE `users_email` = ? AND `users_password` = ?";
$stmt = $conn->prepare($sqllogin);
$stmt->bind_param("ss", $email, $password);
$stmt->execute();
$result = $stmt->get_result();

if (!$result) {
    sendJsonResponse(array('status' => 'failed', 'message' => mysqli_error($conn)));
}

if ($result->num_rows > 0) {
    $userdata = $result->fetch_assoc();
    sendJsonResponse(array(
        'status' => 'success',
        'data' => array(
            'user_id' => $userdata['users_id'],
            'user_email' => $userdata['users_email'],
            'user_name' => $userdata['users_name']
        )
    ));
} else {
    sendJsonResponse(array('status' => 'failed', 'message' => 'Invalid credentials'));
}

$conn->close();
?>
