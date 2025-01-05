<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");


$servername = "localhost";
$username = "root";  
$password = "";  
$dbname = "appayuntamiento";  

function obtenerConexion() {
    global $servername, $username, $password, $dbname;

    $conn = new mysqli($servername, $username, $password, $dbname);


    if ($conn->connect_error) {
        die(json_encode(["status" => "error", "message" => "Conexión fallida: " . $conn->connect_error]));
    }

    return $conn;
}
?>
