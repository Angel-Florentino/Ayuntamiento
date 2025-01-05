<?php
require_once 'conexion.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $data = json_decode(file_get_contents("php://input"), true);

    $nombre_actividad = $data['nombre_actividad'] ?? null;
    $ubicacion = $data['ubicacion'] ?? null;
    $descripcion = $data['descripcion'] ?? null;
    $notas = $data['notas'] ?? null;
    $imagen1 = $data['imagen1'] ?? null; 
    $imagen2 = $data['imagen2'] ?? null;
    $area = $data['area'] ?? null;
    $fecha_hora = date('Y-m-d H:i:s'); 

    if (!$nombre_actividad) {
        echo json_encode(["status" => "error", "message" => "El nombre de la actividad es obligatorio."]);
        exit;
    }

    if (!$area) {
        echo json_encode(["status" => "error", "message" => "El área es obligatoria."]);
        exit;
    }

    function guardarImagen($imagen_base64, $nombre_prefijo) {
        if ($imagen_base64) {
            $ruta_carpeta = 'C:\\wamp64\\www\\imagenes\\'; 
            $data = base64_decode($imagen_base64); 
            $nombre_archivo = uniqid($nombre_prefijo . '_') . '.jpg'; 
            $ruta_completa = $ruta_carpeta . $nombre_archivo; 

            if (!is_dir($ruta_carpeta)) {
                mkdir($ruta_carpeta, 0777, true); 
            }

            if (file_put_contents($ruta_completa, $data)) {
                return $nombre_archivo; 
            }
        }
        return null; 
    }

    $nombre_imagen1 = guardarImagen($imagen1, 'img1');
    $nombre_imagen2 = guardarImagen($imagen2, 'img2');

    $conn = obtenerConexion();

    $stmt = $conn->prepare("INSERT INTO actividades (area, nombre_actividad, ubicacion, descripcion, notas, imagen1, imagen2, fecha_hora) 
                            VALUES (?, ?, ?, ?, ?, ?, ?, ?)");
    $stmt->bind_param(
        "ssssssss",
        $area,
        $nombre_actividad,
        $ubicacion,
        $descripcion,
        $notas,
        $nombre_imagen1,
        $nombre_imagen2,
        $fecha_hora
    );

    if ($stmt->execute()) {
        echo json_encode(["status" => "success", "message" => "Actividad registrada exitosamente."]);
    } else {
        echo json_encode(["status" => "error", "message" => "Error al registrar la actividad: " . $stmt->error]);
    }

    $stmt->close();
    $conn->close();
} else {
    echo json_encode(["status" => "error", "message" => "Método no permitido."]);
}
