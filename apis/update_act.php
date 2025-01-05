<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

include 'conexion.php'; 

$conn = obtenerConexion();

if ($_SERVER['REQUEST_METHOD'] == 'POST') {

    $id = isset($_POST['id']) ? $_POST['id'] : null;
    $notas = isset($_POST['notas']) ? $_POST['notas'] : null;
    $imagen1 = isset($_POST['imagen1']) ? $_POST['imagen1'] : null;
    $imagen2 = isset($_POST['imagen2']) ? $_POST['imagen2'] : null;

    if (!$id) {
        echo json_encode(["status" => "error", "message" => "Falta el ID de la actividad"]);
        exit;
    }

    if (!$notas) {
        echo json_encode(["status" => "error", "message" => "Faltan las notas"]);
        exit;
    }

    function guardarImagen($imagen_base64, $nombre_prefijo) {
        if ($imagen_base64) {
            $ruta_carpeta = 'C:\\wamp64\\www\\imagenes\\'; 
            $data = base64_decode($imagen_base64);
            $nombre_archivo = uniqid($nombre_prefijo . '_') . '.jpg';
            $ruta_completa = $ruta_carpeta . $nombre_archivo;
            file_put_contents($ruta_completa, $data);
            return $nombre_archivo;
        }
        return null;
    }

    $imagen1_nombre = guardarImagen($imagen1, 'imagen1');
    $imagen2_nombre = guardarImagen($imagen2, 'imagen2');

    $fecha_hora = date('Y-m-d H:i:s');

    $sql = "UPDATE actividades SET notas = ?, imagen1 = ?, imagen2 = ?, fecha_hora = ? WHERE id = ?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("ssssi", $notas, $imagen1_nombre, $imagen2_nombre, $fecha_hora, $id);

    if ($stmt->execute()) {
        echo json_encode(["status" => "success", "message" => "Actividad actualizada exitosamente"]);
    } else {
        echo json_encode(["status" => "error", "message" => "Error al actualizar la actividad"]);
    }

    $stmt->close();
    $conn->close();
} else {
    echo json_encode(["status" => "error", "message" => "Método no permitido"]);
}
?>

