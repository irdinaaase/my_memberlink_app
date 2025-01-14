<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);
error_log("Loading available memberships...");

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

$sqlLoadMemberships = "SELECT * FROM tbl_memberships ORDER BY memberships_name ASC";
error_log("SQL Query: " . $sqlLoadMemberships);
$result = $conn->query($sqlLoadMemberships);

$memberships = array();
if ($result) {
    if ($result->num_rows > 0) {
        $memberships["memberships"] = array();
        while ($row = $result->fetch_assoc()) {
            $record = array();
            $record['memberships_id'] = $row['memberships_id'];
            $record['memberships_name'] = $row['memberships_name'];
            $record['memberships_description'] = $row['memberships_description'];
            $record['memberships_price'] = $row['memberships_price'];
            $record['memberships_duration'] = $row['memberships_duration'];
            $record['memberships_benefits'] = $row['memberships_benefits'];
            $record['memberships_terms'] = $row['memberships_terms'];
            array_push($memberships["memberships"], $record);
        }
        $response = array('status' => 'success', 'data' => $memberships);
    } else {
        $response = array('status' => 'failed', 'message' => 'No memberships found', 'data' => $memberships);
    }
} else {
    $response = array('status' => 'failed', 'message' => 'Database query failed', 'data' => $memberships);
    if (is_object($conn)) {
        error_log("MySQL Error: " . $conn->error);
    } else {
        error_log("MySQL Error: Connection is not an object");
    }
}

sendJsonResponse($response);
$conn->close();
?>
