<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

include 'conexion.php'; 

$conn = obtenerConexion();

if ($_SERVER['REQUEST_METHOD'] == 'GET') {


    $query = "SELECT id, area, nombre_actividad, ubicacion, descripcion FROM actividades";
    $result = $conn->query($query);

    if ($result->num_rows > 0) {
        $actividades = [];
        while ($row = $result->fetch_assoc()) {
            $actividades[] = $row;
        }
        echo json_encode(["status" => "success", "actividades" => $actividades]);
    } else {
        echo json_encode(["status" => "error", "message" => "No se encontraron actividades"]);
    }
} else {
    echo json_encode(["status" => "error", "message" => "Método no permitido"]);
}

$conn->close();
?>
