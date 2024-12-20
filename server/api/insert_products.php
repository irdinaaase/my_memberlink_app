<?php
header('Content-Type: application/json');

// Include database connection
include_once("dbconnect.php");

// Helper function to send JSON responses
function sendJsonResponse($response)
{
    error_log("Sending JSON response: " . json_encode($response)); // Debug log
    echo json_encode($response);
    exit();
}

// Check if the request is POST
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    error_log("Invalid request method: " . $_SERVER['REQUEST_METHOD']); // Debug log
    $response = ['status' => 'failed', 'data' => 'Invalid request method'];
    sendJsonResponse($response);
}

// Retrieve and sanitize input data
$product_name = isset($_POST['product_name']) ? addslashes($_POST['product_name']) : null;
$product_description = isset($_POST['product_description']) ? addslashes($_POST['product_description']) : null;
$product_quantity = isset($_POST['product_quantity']) ? intval($_POST['product_quantity']) : null;
$product_price = isset($_POST['product_price']) ? floatval($_POST['product_price']) : null;
$product_filename = isset($_POST['product_filename']) ? $_POST['product_filename'] : null;

// Debug logs for input values
error_log("Received product data: Name=$product_name, Description=$product_description, Quantity=$product_quantity, Price=$product_price");

// Validate required fields
if (!$product_name || !$product_description || !$product_quantity || !$product_price || !$product_filename) {
    error_log("Validation failed: Missing required fields"); // Debug log
    $response = ['status' => 'failed', 'data' => 'Missing required fields'];
    sendJsonResponse($response);
}

// Generate a unique filename for the image
$image_filename = "product-" . uniqid() . ".jpg";
error_log("Generated image filename: $image_filename"); // Debug log

// Decode the base64 image
$decoded_image = base64_decode($product_filename);
if ($decoded_image === false) {
    error_log("Image decoding failed: Invalid base64 format for product_filename"); // Debug log
    $response = ['status' => 'failed', 'data' => 'Invalid image format'];
    sendJsonResponse($response);
} else {
    error_log("Base64 image decoding successful"); // Debug log
}


// Save the image file to the server
$image_path = "../assets/products/" . $image_filename;
if (file_put_contents($image_path, $decoded_image) === false) {
    error_log("Failed to save image file: $image_path"); // Debug log
    $response = ['status' => 'failed', 'data' => 'Failed to save image file'];
    sendJsonResponse($response);
}
error_log("Image saved successfully at: $image_path"); // Debug log

// Insert product details into the database
$sqlInsertProduct = "INSERT INTO tbl_products 
    (product_name, product_description, product_quantity, product_price, product_filename, product_date) 
    VALUES (?, ?, ?, ?, ?, NOW())";

$stmt = $conn->prepare($sqlInsertProduct);
if ($stmt === false) {
    error_log("Database prepare error: " . $conn->error); // Debug log
    $response = ['status' => 'failed', 'data' => 'Database prepare error: ' . $conn->error];
    sendJsonResponse($response);
}

$stmt->bind_param("ssids", $product_name, $product_description, $product_quantity, $product_price, $image_filename);
if ($stmt->execute()) {
    error_log("Product inserted successfully into the database"); // Debug log
    $response = ['status' => 'success', 'data' => 'Product inserted successfully'];
} else {
    error_log("Database execution error: " . $stmt->error); // Debug log
    $response = ['status' => 'failed', 'data' => 'Database execution error: ' . $stmt->error];
}

// Close the statement and connection
$stmt->close();
error_log("Statement closed successfully"); // Debug log
$conn->close();
error_log("Database connection closed successfully"); // Debug log

// Send the response
sendJsonResponse($response);
?>
