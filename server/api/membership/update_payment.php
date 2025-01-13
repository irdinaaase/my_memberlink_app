<?php
error_reporting(E_ALL); // Enable all error reporting for debugging.
ini_set('display_errors', 1);
include_once("dbconnect.php");

// Check database connection
if ($conn->connect_error) {
    error_log("Database Connection Failed: " . $conn->connect_error);
    exit("Error: Failed to connect to database.");
}

// Get parameters from URL
$email = $_GET['users_email'];
$phone = $_GET['users_phone'];
$name = $_GET['users_lastname'];
$userid = $_GET['users_id'];
$amount = $_GET['payments_amount'];
$membershipname = $_GET['memberships_name'];

$data = array(
    'id' => $_GET['billplz']['id'],
    'paid_at' => $_GET['billplz']['paid_at'],
    'paid' => $_GET['billplz']['paid'],
    'x_signature' => $_GET['billplz']['x_signature']
);

$payments_billplz_id = $data['id'];
$paidstatus = $data['paid'] === "true" ? "Success" : "Failed";

// Assign status color based on payment status
$status_color = ($paidstatus === "Success") ? "w3-text-green" : "w3-text-red";

// Verify x_signature
$signing = '';
foreach ($data as $key => $value) {
    $signing .= 'billplz' . $key . $value;
    if ($key === 'paid') {
        break;
    } else {
        $signing .= '|';
    }
}

$secret_key = 'a706fb9b131cfc14313ffce9627bdc172e74f1f6d446be859fce3d83e931392ff75cf4488da920fff8e0e4ce94f4b6270b9c0adcd6985c3db27c73b4ce1f2682';
$signed = hash_hmac('sha256', $signing, $secret_key);

if ($signed !== $data['x_signature']) {
    error_log("Invalid Signature: Expected $signed, Got {$data['x_signature']}");
    exit("Error: Invalid Signature");
}

// Insert or Update the database based on payment status
if ($paidstatus === "Success") {
    // INSERT query for successful payments
    $query = "INSERT INTO `tbl_memberships_payments` 
              (`memberships_name`, `users_id`, `payments_amount`, `payments_status`, `payments_billplz_id`) 
              VALUES (?, ?, ?, ?, ?)";

    $stmt = $conn->prepare($query);
    if (!$stmt) {
        error_log("Statement Preparation Failed: " . $conn->error);
        exit("Error: Failed to prepare statement.");
    }

    // Correctly bind parameters
    $stmt->bind_param('sidss',
        $membershipname,   // Membership name
        $userid,           // User ID
        $amount,           // Payment amount
        $paidstatus,       // Payment status
        $payments_billplz_id // Billplz ID
    );

    if ($stmt->execute()) {
        error_log("Payment record inserted successfully.");
    } else {
        error_log("Error inserting payment record: " . $stmt->error);
        exit("Error: Failed to insert payment record.");
    }

    $stmt->close();
}

// Display the receipt
echo "
<html>
<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">
<link rel=\"stylesheet\" href=\"https://www.w3schools.com/w3css/4/w3.css\">
<body>
<center><h4>Receipt</h4></center>
<table class='w3-table w3-striped'>
<th>Item</th><th>Description</th>
<tr><td>Receipt</td><td>$payments_billplz_id</td></tr>
<tr><td>Name</td><td>$name</td></tr>
<tr><td>Email</td><td>$email</td></tr>
<tr><td>Phone</td><td>$phone</td></tr>
<tr><td>Paid Amount</td><td>RM $amount</td></tr>
<tr><td>Paid Status</td><td class='$status_color'>$paidstatus</td></tr>
</table><br>
</body>
</html>";

$conn->close();
?>
