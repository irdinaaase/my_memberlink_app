<?php
include_once("dbconnect.php");

if (!isset($_POST)) {
    $response = array('status' => 'failed', 'message' => 'Invalid request');
    sendJsonResponse($response);
    die();
}

$userId = $_POST['user_id'];
$membershipId = $_POST['membership_id'];
$amount = $_POST['amount'];
$paymentMethod = $_POST['payment_method'];

// Start transaction
$conn->begin_transaction();

try {
    // Insert purchase record
    $sqlInsertPurchase = "INSERT INTO tbl_membership_purchases 
        (membership_id, user_id, amount, payment_method) 
        VALUES (?, ?, ?, ?)";
    
    $stmt = $conn->prepare($sqlInsertPurchase);
    $stmt->bind_param("iids", $membershipId, $userId, $amount, $paymentMethod);
    
    if (!$stmt->execute()) {
        throw new Exception("Failed to record purchase");
    }

    // Update user's membership status
    $sqlUpdateUser = "UPDATE tbl_users SET 
        membership_id = ?,
        membership_status = 'Active'
        WHERE user_id = ?";
    
    $stmt = $conn->prepare($sqlUpdateUser);
    $stmt->bind_param("ii", $membershipId, $userId);
    
    if (!$stmt->execute()) {
        throw new Exception("Failed to update user membership");
    }

    // Commit transaction
    $conn->commit();
    
    $response = array(
        'status' => 'success',
        'message' => 'Membership purchased successfully'
    );
    sendJsonResponse($response);

} catch (Exception $e) {
    // Rollback transaction on error
    $conn->rollback();
    $response = array(
        'status' => 'failed',
        'message' => $e->getMessage()
    );
    sendJsonResponse($response);
}

function sendJsonResponse($sentArray) {
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}
?> 