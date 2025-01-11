<?php
include_once("dbconnect.php");

// Get payment status from Billplz
$data = $_GET;
$paymentsStatus = $data['billplz']['paid'] === 'true' ? 'Paid' : 'Failed';
$adminId = $data['billplz']['reference_1'];
$membershipsId = $data['billplz']['reference_2'];
$paymentsBillplzId = $data['billplz']['id'];

if ($paymentsStatus === 'Paid') {
    // Start transaction
    $conn->begin_transaction();

    try {
        // Update purchase status
        $sqlUpdatePayment = "UPDATE tbl_memberships_payments 
            SET payments_status = 'Paid', 
                payments_billplz_id = ? 
            WHERE admin_id = ? 
            AND memberships_id = ? 
            AND payments_status = 'Pending'";
        
        $stmt = $conn->prepare($sqlUpdatePayment);
        $stmt->bind_param("ssi", $paymentsBillplzId, $adminId, $membershipsId);
        
        if (!$stmt->execute()) {
            throw new Exception("Failed to update purchase status");
        }

        // Update admin's membership status
        $sqlUpdateAdmin = "UPDATE tbl_admins 
            SET memberships_id = ?,
                memberships_status = 'Active' 
            WHERE admin_id = ?";
        
        $stmt = $conn->prepare($sqlUpdateAdmin);
        $stmt->bind_param("is", $membershipsId, $adminId);
        
        if (!$stmt->execute()) {
            throw new Exception("Failed to update admin membership");
        }

        $conn->commit();
    } catch (Exception $e) {
        $conn->rollback();
        error_log("Payment processing error: " . $e->getMessage());
    }
}

// Redirect back to app
header("Location: memberlink://payment/" . $paymentsStatus);
?> 