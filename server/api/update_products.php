<?php
if (!isset($_POST)) {
    $response = array('status' => 'failed', 'data' => null);
    sendJsonResponse($response);
    die;
}

$productid = $_POST['productid'];
$productName = $_POST['productname'];
$productDescription = addslashes($_POST['description']);
$productPrice = $_POST['price'];
$productQuantity = $_POST['quantity'];
$image = $_POST['image'];

// $filename = $_POST['filename'];
$filename = "product-" . randomfilename(10) . ".jpg";

// Construct the SQL update query based on the conditions
if ($productPrice == "NA" && $productQuantity == "NA") {
    $sqlUpdateProduct = "UPDATE `tbl_products` SET `product_name`='$productName', `product_description`='$productDescription'";
}
if ($productPrice != "NA" && $productQuantity == "NA") {
    $sqlUpdateProduct = "UPDATE `tbl_products` SET `product_name`='$productName', `product_description`='$productDescription', `product_price`='$productPrice'";
}
if ($productPrice == "NA" && $productQuantity != "NA") {
    $sqlUpdateProduct = "UPDATE `tbl_products` SET `product_name`='$productName', `product_description`='$productDescription', `product_quantity`='$productQuantity'";
}
if ($productPrice != "NA" && $productQuantity != "NA") {
    $sqlUpdateProduct = "UPDATE `tbl_products` SET `product_name`='$productName', `product_description`='$productDescription', `product_price`='$productPrice', `product_quantity`='$productQuantity'";
}
if ($image != "NA") {
    $sqlUpdateProduct = $sqlUpdateProduct . ", `product_filename`='$filename' WHERE `product_id`='$productid'";
} else {
    $sqlUpdateProduct = $sqlUpdateProduct . " WHERE `product_id`='$productid'";
}

include_once("dbconnect.php");

if ($conn->query($sqlUpdateProduct) === TRUE) {
    if ($image != "NA") {
        $decoded_image = base64_decode($image);
        $path = "../assets/products/" . $filename;
        file_put_contents($path, $decoded_image);
    }
    $response = array('status' => 'success', 'data' => null);
    sendJsonResponse($response);
} else {
    $response = array('status' => 'failed', 'data' => null);
    sendJsonResponse($response);
}

function sendJsonResponse($sentArray)
{
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}

function randomfilename($length) {
    $key = '';
    $keys = array_merge(range(0, 9), range('a', 'z'));

    for ($i = 0; $i < $length; $i++) {
        $key .= $keys[array_rand($keys)];
    }
    return $key;
}
?>
