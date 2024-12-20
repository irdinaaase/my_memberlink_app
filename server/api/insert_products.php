<?php
if (!isset($_POST['productname'], $_POST['description'], $_POST['price'], $_POST['quantity'], $_POST['image'])) {
    $response = array('status' => 'failed', 'data' => 'Missing required fields');
    sendJsonResponse($response);
    die;
}

include_once("dbconnect.php");
$productName = mysqli_real_escape_string($conn, $_POST['productname']);
$productDescription = mysqli_real_escape_string($conn, $_POST['description']);
$productPrice = mysqli_real_escape_string($conn, $_POST['price']);
$productQuantity = mysqli_real_escape_string($conn, $_POST['quantity']);
$image = $_POST['image'];

$decoded_image = base64_decode($image);
if ($decoded_image === false) {
    $response = array('status' => 'failed', 'data' => 'Invalid image data');
    sendJsonResponse($response);
    die;
}

$filename = "product-" . randomfilename(10) . ".jpg";

$sqlInsertProduct = "INSERT INTO `tbl_products`(`product_name`, `product_description`, `product_price`, `product_quantity`, `product_filename`) VALUES ('$productName','$productDescription','$productPrice','$productQuantity','$filename')";

if ($conn->query($sqlInsertProduct) === TRUE) {
    $path = "../assets/products/" . $filename;
    if (file_put_contents($path, $decoded_image) === false) {
        $response = array('status' => 'failed', 'data' => 'Failed to save image');
        sendJsonResponse($response);
        die;
    }
    $productId = $conn->insert_id;  // Get the inserted product ID
    $response = array('status' => 'success', 'data' => array('product_id' => $productId));
    sendJsonResponse($response);
} else {
    $error = $conn->error;
    $response = array('status' => 'failed', 'data' => 'Database Error: ' . $error);
    sendJsonResponse($response);
}

function randomfilename($length) {
    $key = '';
    $keys = array_merge(range(0, 9), range('a', 'z'));
    for ($i = 0; $i < $length; $i++) {
        $key .= $keys[array_rand($keys)];
    }
    return $key . '-' . time(); // Add timestamp for uniqueness
}

function sendJsonResponse($sentArray)
{
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}
?>
