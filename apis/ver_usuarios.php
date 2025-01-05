<?php
require_once 'conexion.php';

$conn = obtenerConexion();

$sql = "SELECT * FROM usuarios";
$result = $conn->query($sql);

$usuarios = [];
if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        unset($row['contrasena']); 
        $usuarios[] = $row;
    }
}

echo json_encode($usuarios);
$conn->close();
?>
