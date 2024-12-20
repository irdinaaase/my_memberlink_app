<?php
include_once 'dbconnect.php';

header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $userid = $_POST['userid'] ?? '';

    $sql = "SELECT profile_picture, last_name, title, membership_points FROM users WHERE id = ?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param('s', $userid);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows > 0) {
        $row = $result->fetch_assoc();

        echo json_encode([
            'status' => 'success',
            'data' => [
                'profile_picture' => $row['profile_picture'] ?: 'https://via.placeholder.com/150',
                'last_name' => $row['last_name'],
                'title' => $row['title'],
                'membership_points' => $row['membership_points']
            ]
        ]);
    } else {
        echo json_encode(['status' => 'error', 'message' => 'User not found']);
    }
} else {
    echo json_encode(['status' => 'error', 'message' => 'Invalid request method']);
}

$conn->close();
?>
