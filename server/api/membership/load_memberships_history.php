<?php
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
$paymentId = isset($_GET['payment_id']) ? $_GET['payment_id'] : null;
$page = (int)$_GET['page'];
$results_per_page = 10;
$page_first_result = ($page - 1) * $results_per_page;

if ($paymentId) {
    $sqlLoadHistory = "SELECT p.*, m.memberships_name FROM tbl_memberships_payments p JOIN tbl_memberships m ON p.membership_id = m.membership_id WHERE p.users_id = '$userid' AND p.payments_id = '$paymentId' ORDER BY p.payments_date DESC";
} else {
    $sqlLoadHistory = "SELECT p.*, m.memberships_name FROM tbl_memberships_payments p JOIN tbl_memberships m ON p.membership_id = m.membership_id WHERE p.users_id = '$userid' ORDER BY p.payments_date DESC LIMIT $page_first_result, $results_per_page";
}

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
            $record['membership_id'] = $row['membership_id'];
            $record['memberships_name'] = $row['memberships_name'];
            array_push($history["history"], $record);
        }
        if (!$paymentId) {
            $sqlCount = "SELECT COUNT(*) AS total FROM tbl_memberships_payments WHERE users_id = '$userid'";
            $countResult = $conn->query($sqlCount);
            $totalRecords = $countResult->fetch_assoc()['total'];
            $numofpage = ceil($totalRecords / $results_per_page);
            $response = array('status' => 'success', 'data' => $history, 'numofpage' => $numofpage, 'numberofresult' => $totalRecords);
            error_log("Total records: $totalRecords");
        } else {
            $response = array('status' => 'success', 'data' => $history);
        }
    } else {
        if ($paymentId) {
            $response = array('status' => 'failed', 'message' => 'No payment found with that ID', 'data' => $history);
        } else {    
            $response = array('status' => 'failed', 'message' => 'No membership history found', 'data' => $history);
        }
    }
} else {
    $response = array('status' => 'failed', 'message' => 'Database query failed', 'data' => $history);
}

sendJsonResponse($response);
$conn->close();
?>