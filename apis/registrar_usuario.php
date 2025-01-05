<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");


$servername = "localhost";
$username = "root"; 
$password = ""; 
$dbname = "appayuntamiento"; 


$conn = new mysqli($servername, $username, $password, $dbname);


if ($conn->connect_error) {
    die("Conexión fallida: " . $conn->connect_error);
}


$nombre_completo = $_POST['nombre_completo'];
$area = $_POST['area'];
$correo_electronico = $_POST['correo'];
$telefono = $_POST['telefono'];
$nombre_usuario = $_POST['nombre_usuario'];
$contrasena = $_POST['contrasena']; 
$rol = $_POST['rol'];

$checkUserQuery = $conn->prepare("SELECT * FROM usuarios WHERE correo_electronico = ? OR nombre_usuario = ?");
$checkUserQuery->bind_param("ss", $correo_electronico, $nombre_usuario);
$checkUserQuery->execute();
$result = $checkUserQuery->get_result();
if ($result->num_rows > 0) {
    echo json_encode(["error" => "Correo o nombre de usuario ya registrados"]);
    exit();
}

$stmt = $conn->prepare("INSERT INTO usuarios (nombre_completo, area, correo_electronico, telefono, nombre_usuario, contrasena, rol) VALUES (?, ?, ?, ?, ?, ?, ?)");
$stmt->bind_param("sssssss", $nombre_completo, $area, $correo_electronico, $telefono, $nombre_usuario, $contrasena, $rol);


if ($stmt->execute()) {
    echo json_encode(["message" => "Nuevo usuario registrado con éxito"]);
} else {
    echo json_encode(["error" => "Error al registrar el usuario", "details" => $stmt->error]);
}

$stmt->close();
$conn->close();
?>
