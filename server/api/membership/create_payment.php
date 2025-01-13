<?php
//error_reporting(0);

$email = $_GET['users_email']; //email
$phone = $_GET['users_phone']; 
$name = $_GET['users_lastname']; 
$userid = $_GET['users_id'];
$amount = $_GET['payments_amount']; 


$api_key = '1c6abab1-45ae-4c0b-88ac-38200e661286';
$collection_id = '6ls750pw';
$host = 'https://www.billplz-sandbox.com/api/v3/bills';

$data = array(
          'collection_id' => $collection_id,
          'email' => $email,
          'mobile' => $phone,
          'name' => $name,
          'amount' => ($amount) * 100, // RM20
          'description' => 'Payment for order by '.$name,
          'callback_url' => "https://humancc.site/irdinabalqis/memberlink/api/return_url",
          'redirect_url' => "https://humancc.site/irdinabalqis/memberlink/api/update_payment.php?users_id=$userid&users_email=$email&users_phone=$phone&payments_amount=$amount&users_lastname=$name" 
);

$process = curl_init($host );
curl_setopt($process, CURLOPT_HEADER, 0);
curl_setopt($process, CURLOPT_USERPWD, $api_key . ":");
curl_setopt($process, CURLOPT_TIMEOUT, 30);
curl_setopt($process, CURLOPT_RETURNTRANSFER, 1);
curl_setopt($process, CURLOPT_SSL_VERIFYHOST, 0);
curl_setopt($process, CURLOPT_SSL_VERIFYPEER, 0);
curl_setopt($process, CURLOPT_POSTFIELDS, http_build_query($data) ); 

$return = curl_exec($process);
curl_close($process);
$bill = json_decode($return, true);
//print_r($bill);
header("Location: {$bill['url']}");
?>