<?php
include_once("dbconnect.php");

if (!isset($_POST)) {
    $response = array('status' => 'failed', 'message' => 'Invalid request');
    sendJsonResponse($response);
    die();
}

$userId = $_POST['user_id'];
$membershipsId = $_POST['memberships_id'];
$paymentsAmount = $_POST['payments_amount'];
$description = $_POST['description'];

// Billplz API Configuration
$api_key = 'YOUR_BILLPLZ_API_KEY';
$collection_id = 'YOUR_COLLECTION_ID';
$sandbox = true; // Set to false for production

// Create Bill
$data = array(
    'collection_id' => $collection_id,
    'email' => $userEmail,  // Get from user profile
    'name' => $userName,    // Get from user profile
    'amount' => $paymentsAmount * 100,
    'description' => $description,
    'callback_url' => $callback_url,
    'redirect_url' => $redirect_url,
    'reference_1_label' => 'User ID',
    'reference_1' => $userId,
    'reference_2_label' => 'Memberships ID',
    'reference_2' => $membershipsId
);

$curl = curl_init();
$api_url = $sandbox ? 'https://www.billplz-sandbox.com/api/v3/bills' : 'https://www.billplz.com/api/v3/bills';

curl_setopt($curl, CURLOPT_URL, $api_url);
curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
curl_setopt($curl, CURLOPT_USERPWD, $api_key . ":");
curl_setopt($curl, CURLOPT_POST, true);
curl_setopt($curl, CURLOPT_POSTFIELDS, $data);

$result = curl_exec($curl);
$info = curl_getinfo($curl);
curl_close($curl);

if ($info['http_code'] == 200) {
    $billplz = json_decode($result);
    $response = array(
        'status' => 'success',
        'billplz_url' => $billplz->url
    );
} else {
    $response = array(
        'status' => 'failed',
        'message' => 'Failed to create bill'
    );
}

sendJsonResponse($response);

function sendJsonResponse($sentArray) {
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}
?> 