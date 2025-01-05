<?php
require_once 'conexion.php';


$conn = obtenerConexion();


if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $nombreUsuario = $_POST['nombre_usuario'] ?? '';

    if (!empty($nombreUsuario)) {
        $stmt = $conn->prepare("DELETE FROM usuarios WHERE nombre_usuario = ?");
        $stmt->bind_param("s", $nombreUsuario);

        if ($stmt->execute()) {
            if ($stmt->affected_rows > 0) {
                echo json_encode([
                    "success" => true,
                    "message" => "Usuario eliminado con éxito."
                ]);
            } else {
                echo json_encode([
                    "success" => false,
                    "message" => "No se encontró un usuario con ese nombre."
                ]);
            }
        } else {
            echo json_encode([
                "success" => false,
                "message" => "Error al eliminar el usuario."
            ]);
        }
        $stmt->close();
    } else {
        echo json_encode([
            "success" => false,
            "message" => "El nombre de usuario es obligatorio."
        ]);
    }
} else {
    echo json_encode([
        "success" => false,
        "message" => "Método no permitido. Utiliza POST."
    ]);
}
$conn->close();
?>
