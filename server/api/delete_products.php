<?php
if ( !isset( $_POST ) ) {
    $response = array( 'status' => 'failed', 'data' => null );
    sendJsonResponse( $response );
    die;
}

include_once( 'dbconnect.php' );
$productid = ( $_POST[ 'productid' ] );

$sqlDeleteProduct = "DELETE FROM `tbl_products` WHERE `product_id` = '$productid'";

if ( $conn->query( $sqlDeleteProduct ) === TRUE ) {
    $response = array( 'status' => 'success', 'data' => null );
    sendJsonResponse( $response );
} else {
    $response = array( 'status' => 'failed', 'data' => null );
    sendJsonResponse( $response );
}

function sendJsonResponse( $sentArray ) {
    header( 'Content-Type: application/json' );
    echo json_encode( $sentArray );
}
?>
