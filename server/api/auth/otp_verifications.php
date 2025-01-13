<?php
include_once("dbconnect.php");
require 'vendor/autoload.php'; // Load PHPMailer via Composer autoload

use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

if (isset($_POST['action'])) {
    $action = $_POST['action'];
    
    if ($action == 'send_otp' && isset($_POST['email'])) {
        sendOTP($_POST['email']);
    } elseif ($action == 'verify_otp' && isset($_POST['email']) && isset($_POST['otp'])) {
        verifyOTP($_POST['email'], $_POST['otp']);
    } elseif ($action == 'register_user') {
        registerUser($_POST);
    } else {
        sendJsonResponse('error', 'Invalid parameters');
    }
}

function sendOTP($email) {
    global $conn;

    $otp = rand(100000, 999999); // Generate a 6-digit OTP
    $expiry_time = date('Y-m-d H:i:s', strtotime('+5 minutes')); // OTP valid for 5 minutes

    $query = "INSERT INTO otp_verifications (email, otp, expiry_time) VALUES ('$email', '$otp', '$expiry_time')";
    
    if (mysqli_query($conn, $query)) {
        try {
            $mail = new PHPMailer(true);
            $mail->isSMTP();
            $mail->Host       = 'smtp.gmail.com'; 
            $mail->SMTPAuth   = true;
            $mail->Username   = 'your_email@gmail.com';  // Update with your email
            $mail->Password   = 'your_password';         // Update with your app password
            $mail->SMTPSecure = PHPMailer::ENCRYPTION_STARTTLS;
            $mail->Port       = 587;

            $mail->setFrom('your_email@gmail.com', 'My App'); 
            $mail->addAddress($email); 

            $mail->isHTML(true);
            $mail->Subject = 'Your OTP Code';
            $mail->Body    = "Your OTP is <b>$otp</b>. It expires in 5 minutes.";

            $mail->send();
            sendJsonResponse('success', 'OTP sent successfully');
        } catch (Exception $e) {
            sendJsonResponse('error', "Mailer Error: {$mail->ErrorInfo}");
        }
    } else {
        sendJsonResponse('error', 'Database error');
    }
}

function verifyOTP($email, $otp) {
    global $conn;

    $query = "SELECT * FROM otp_verifications WHERE email = '$email' AND otp = '$otp' AND expiry_time >= NOW() ORDER BY created_at DESC LIMIT 1";
    $result = mysqli_query($conn, $query);

    if (mysqli_num_rows($result) > 0) {
        sendJsonResponse('success', 'OTP verified');
    } else {
        sendJsonResponse('error', 'Invalid or expired OTP');
    }
}

function registerUser($data) {
    global $conn;

    $email = $data['email'];
    $password = md5($data['password']); // Hash password

    $query = "INSERT INTO tbl_admins (email, password) VALUES ('$email', '$password')";

    if (mysqli_query($conn, $query)) {
        sendJsonResponse('success', 'User registered successfully');
    } else {
        sendJsonResponse('error', 'Failed to register user');
    }
}

function sendJsonResponse($status, $message) {
    echo json_encode(['status' => $status, 'data' => $message]);
    exit;
}
?>
