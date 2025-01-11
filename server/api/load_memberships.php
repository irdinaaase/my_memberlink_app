<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);
error_log("Loading memberships...");

// Add CORS headers
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Accept');

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    header('HTTP/1.1 200 OK');
    exit();
}

include_once("dbconnect.php");

if (!$conn) {
    $response = array('status' => 'failed', 'message' => 'Database connection failed');
    sendJsonResponse($response);
    die();
}

function sendJsonResponse($sentArray) {
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}

try {
    $sqlLoadMemberships = "SELECT * FROM tbl_memberships ORDER BY memberships_price ASC";
    error_log("SQL Query: " . $sqlLoadMemberships);
    $result = $conn->query($sqlLoadMemberships);

    if ($result) {
        if ($result->num_rows > 0) {
            $memberships["memberships"] = array();
            while ($row = $result->fetch_assoc()) {
                $membership = array();
                $membership['memberships_id'] = $row['memberships_id'];
                $membership['memberships_name'] = $row['memberships_name'];
                $membership['memberships_description'] = $row['memberships_description'];
                $membership['memberships_price'] = $row['memberships_price'];
                $membership['memberships_duration'] = $row['memberships_duration'];
                $membership['memberships_benefits'] = $row['memberships_benefits'];
                $membership['memberships_terms'] = $row['memberships_terms'];
                array_push($memberships["memberships"], $membership);
            }
            $response = array('status' => 'success', 'data' => $memberships);
        } else {
            $response = array('status' => 'failed', 'message' => 'No memberships found');
        }
    } else {
        $response = array('status' => 'failed', 'message' => 'Database query failed');
        error_log("MySQL Error: " . $conn->error);
    }
} catch (Exception $e) {
    $response = array('status' => 'failed', 'message' => 'Server error: ' . $e->getMessage());
    error_log("Error: " . $e->getMessage());
} finally {
    sendJsonResponse($response);
    $conn->close();
}
?> 