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

// Display the receipt
echo "
<html>
<head>
<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">
<link rel=\"stylesheet\" href=\"https://www.w3schools.com/w3css/4/w3.css\">
<style>
    body {
        background-color: #f3f3f3;
        font-family: 'Harry P', sans-serif;
    }
    .receipt-container {
        max-width: 600px;
        margin: auto;
        padding: 20px;
        border: 2px solid #4b2e83;
        border-radius: 10px;
        background-color: #fff;
        box-shadow: 0 0 15px rgba(0, 0, 0, 0.2);
    }
    .receipt-header {
        text-align: center;
        margin-bottom: 20px;
        color: #4b2e83;
    }
    .receipt-table {
        width: 100%;
        border-collapse: collapse;
    }
    .receipt-table th, .receipt-table td {
        padding: 10px;
        text-align: left;
        border: 1px solid #ddd;
    }
    .receipt-table th {
        background-color: #4b2e83;
        color: #fff;
    }
    .receipt-table tr:nth-child(even) {
        background-color: #f2f2f2;
    }
    .receipt-footer {
        text-align: center;
        margin-top: 20px;
        font-size: 14px;
        color: #555;
    }
</style>
<link href=\"https://fonts.googleapis.com/css2?family=Harry+P&display=swap\" rel=\"stylesheet\">
</head>
<body>
<div class=\"receipt-container\">
    <div class=\"receipt-header\">
        <h2>Payment Receipt</h2>
        <p>Thank you for your payment!</p>
    </div>
    <table class='w3-table w3-striped receipt-table'>
        <tr><th>Item</th><th>Description</th></tr>
        <tr><td>Receipt</td><td>$payments_billplz_id</td></tr>
        <tr><td>Name</td><td>$name</td></tr>
        <tr><td>Email</td><td>$email</td></tr>
        <tr><td>Phone</td><td>$phone</td></tr>
        <tr><td>Membership</td><td>$membershipname</td></tr>
        <tr><td>Paid Amount</td><td>RM $amount</td></tr>
        <tr><td>Paid Status</td><td class='$status_color'>$paidstatus</td></tr>
    </table>
    <div class=\"receipt-footer\">
        <p>For any inquiries, please contact us at support@memberlink.com</p>
    </div>
</div>
</body>
</html>";

$conn->close();
?>