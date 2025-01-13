<?php

include_once("dbconnect.php");
if (!$conn) {
    sendJsonResponse(array('status' => 'failed', 'message' => 'Database connection failed'));
    die();
}

function sendJsonResponse($sentArray) {
    header('Content-Type: application/json');
    header('Access-Control-Allow-Origin: *');
    header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
    header('Access-Control-Allow-Headers: Content-Type, Authorization');
    echo json_encode($sentArray);
    exit();
}

$results_per_page = max(1, 10); // Ensure results_per_page is at least 1
$pageno = isset($_GET['pageno']) ? max(1, (int)$_GET['pageno']) : 1;
$page_first_result = ($pageno - 1) * $results_per_page;

try {
    $sqlCount = "SELECT COUNT(*) as total FROM `tbl_news`";
    $countResult = $conn->query($sqlCount);
    if (!$countResult) {
        throw new Exception("Failed to fetch total count");
    }
    $total = $countResult->fetch_assoc()['total'];
    $number_of_page = ceil($total / $results_per_page);

    $sqlloadnews = "SELECT * FROM `tbl_news` ORDER BY `news_date` DESC LIMIT ?, ?";
    $stmt = $conn->prepare($sqlloadnews);
    $stmt->bind_param("ii", $page_first_result, $results_per_page);
    if (!$stmt->execute()) {
        throw new Exception("SQL execution error: " . $stmt->error);
    }
    $result = $stmt->get_result();

    if ($result->num_rows > 0) {
        $newsarray = array();
        while ($row = $result->fetch_assoc()) {
            $newsarray[] = array(
                'news_id' => $row['news_id'],
                'news_title' => $row['news_title'],
                'news_details' => $row['news_details'],
                'news_date' => $row['news_date']
            );
        }
        sendJsonResponse(array(
            'status' => 'success',
            'data' => $newsarray,
            'numofpage' => $number_of_page,
            'numberofresult' => $total
        ));
    } else {
        sendJsonResponse(array('status' => 'failed', 'message' => 'No news found'));
    }
} catch (Exception $e) {
    error_log($e->getMessage());
    sendJsonResponse(array('status' => 'failed', 'message' => 'Error occurred: ' . $e->getMessage()));
}

$conn->close();
?>
