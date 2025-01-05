<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

include 'conexion.php'; 

$conn = obtenerConexion();

$baseUrl = "https://a4c9-2806-10ae-16-7e24-50e3-d50b-ea77-b605.ngrok-free.app/imagenes/";

$fechaInicio = isset($_POST['fechaInicio']) ? $_POST['fechaInicio'] : null;
$fechaFin = isset($_POST['fechaFin']) ? $_POST['fechaFin'] : null;

if ($fechaInicio && $fechaFin) {

    $query = "SELECT * FROM actividades WHERE DATE(fecha_hora) >= ? AND DATE(fecha_hora) <= ?";
    $stmt = $conn->prepare($query);
    $stmt->bind_param("ss", $fechaInicio, $fechaFin); 
    $stmt->execute();
    $result = $stmt->get_result();
} else {
    
    $query = "SELECT * FROM actividades";
    $result = $conn->query($query);
}

if ($result->num_rows > 0) {
    $actividades = [];
    while ($row = $result->fetch_assoc()) {
        $row['imagen1'] = $baseUrl . $row['imagen1'];
        $row['imagen2'] = $baseUrl . $row['imagen2'];
        $actividades[] = [
            "id" => $row['id'],
            "area" => $row['area'],
            "nombre_actividad" => $row['nombre_actividad'],
            "ubicacion" => $row['ubicacion'],
            "descripcion" => $row['descripcion'],
            "notas" => $row['notas'],
            "imagen1" => $row['imagen1'],
            "imagen2" => $row['imagen2'],
            "fecha_hora" => $row['fecha_hora']
        ];
    }
    echo json_encode(["status" => "success", "actividades" => $actividades]);
} else {
    echo json_encode(["status" => "error", "message" => "No se encontraron actividades"]);
}

$conn->close();
?>
