<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);
error_log("Loading membership history...");

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
}

$userid = $_GET['users_id'];
$sqlLoadHistory = "SELECT * FROM tbl_memberships_payments WHERE users_id = '$userid' ORDER BY payments_date DESC";
error_log("SQL Query: " . $sqlLoadHistory);
$result = $conn->query($sqlLoadHistory);

$history = array();
if ($result) {
    if ($result->num_rows > 0) {
        $history["history"] = array();
        while ($row = $result->fetch_assoc()) {
            $record = array();
            $record['payments_id'] = $row['payments_id'];
            $record['payments_amount'] = $row['payments_amount'];
            $record['payments_status'] = $row['payments_status'];
            $record['payments_date'] = $row['payments_date'];
            array_push($history["history"], $record);
        }
        $response = array('status' => 'success', 'data' => $history);
    } else {
        $response = array('status' => 'failed', 'message' => 'No membership history found', 'data' => $history);
    }
} else {
    $response = array('status' => 'failed', 'message' => 'Database query failed', 'data' => $history);
    if (is_object($conn)) {
        error_log("MySQL Error: " . $conn->error);
    } else {
        error_log("MySQL Error: Connection is not an object");
    }
}

sendJsonResponse($response);
$conn->close();
?>
