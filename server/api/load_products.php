<?php

include_once("dbconnect.php");

$results_per_page = 10;
if (isset($_GET['pageno'])) {
    $pageno = (int)$_GET['pageno'];
} else {
    $pageno = 1;
}

$page_first_result = ($pageno - 1) * $results_per_page;

$sqlLoadProducts = "SELECT * FROM `tbl_products` ORDER BY `product_date` DESC";
$result = $conn->query($sqlLoadProducts);
$number_of_result = $result->num_rows;

$number_of_page = ceil($number_of_result / $results_per_page);
$sqlLoadProducts .= " LIMIT $page_first_result, $results_per_page";

$result = $conn->query($sqlLoadProducts);

if ($result->num_rows > 0) {
    $productsArray['products'] = array();
    while ($row = $result->fetch_assoc()) {
        $product = array(
            'product_id' => $row['product_id'],
            'product_name' => $row['product_name'],
            'product_description' => $row['product_description'],
            'product_quantity' => $row['product_quantity'],
            'product_price' => $row['product_price'],
            'product_image' => $row['product_image'],
            'product_date' => $row['product_date'],
        );
        array_push($productsArray['products'], $product);
    }
    $response = array(
        'status' => 'success',
        'data' => $productsArray,
        'numofpage' => $number_of_page,
        'numberofresult' => $number_of_result,
    );
    sendJsonResponse($response);
} else {
    $response = array(
        'status' => 'failed',
        'data' => null,
        'numofpage' => $number_of_page,
        'numberofresult' => $number_of_result,
    );
    sendJsonResponse($response);
}

function sendJsonResponse($sentArray) {
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}

?>
