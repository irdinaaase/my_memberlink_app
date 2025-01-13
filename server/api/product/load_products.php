<?php

include_once("dbconnect.php");

$results_per_page = 4;

if ($conn->connect_error) {
    $response = array(
        'status' => 'failed',
        'message' => 'Database connection failed: ' . $conn->connect_error,
        'data' => null,
    );
    sendJsonResponse($response);
    die();
}

// Sanitize page number input
$pageno = isset($_GET['pageno']) ? (int)$_GET['pageno'] : 1;

// Calculate the first result on the page
$page_first_result = ($pageno - 1) * $results_per_page;

// Query to count the total number of products
$sqlCountProducts = "SELECT COUNT(*) AS total FROM `tbl_products`";
$countResult = $conn->query($sqlCountProducts);
if (!$countResult) {
    $response = array(
        'status' => 'failed',
        'message' => 'Failed to count products: ' . $conn->error,
        'data' => null,
    );
    sendJsonResponse($response);
    die();
}
$countRow = $countResult->fetch_assoc();
$number_of_result = $countRow['total'];

// Calculate total number of pages
$number_of_page = ceil($number_of_result / $results_per_page);

// Validate the page number
if ($pageno > $number_of_page || $pageno < 1) {
    $response = array(
        'status' => 'failed',
        'message' => 'Invalid page number. Please try again.',
        'data' => null,
    );
    sendJsonResponse($response);
    die();
}

// Query to load the products for the current page
$sqlLoadProducts = "SELECT * FROM `tbl_products` ORDER BY `product_date` DESC LIMIT $page_first_result, $results_per_page";
$result = $conn->query($sqlLoadProducts);

if (!$result) {
    $response = array(
        'status' => 'failed',
        'message' => 'Failed to load products: ' . $conn->error,
        'data' => null,
    );
    sendJsonResponse($response);
    die();
}

if ($result->num_rows > 0) {
    $productsArray['products'] = array();
    while ($row = $result->fetch_assoc()) {
        $product = array(
            'product_id' => $row['product_id'],
            'product_name' => $row['product_name'],
            'product_description' => $row['product_description'],
            'product_filename' => $row['product_filename'],
            'product_quantity' => (int)$row['product_quantity'],
            'product_price' => (float)$row['product_price'],
            'product_date' => $row['product_date'],
        );
        array_push($productsArray['products'], $product);
    }

    $response = array(
        'status' => 'success',
        'message' => 'Products loaded successfully.',
        'data' => $productsArray,
        'numofpage' => $number_of_page,
        'numberofresult' => $number_of_result,
    );
    sendJsonResponse($response);
} else {
    $response = array(
        'status' => 'failed',
        'message' => 'No products available.',
        'data' => null,
        'numofpage' => $number_of_page,
        'numberofresult' => $number_of_result,
    );
    sendJsonResponse($response);
}

function sendJsonResponse($sentArray) {
    header('Content-Type: application/json');
    echo json_encode($sentArray, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES);
}

?>
