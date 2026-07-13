-- ============================================================================
-- PROYECTO: Pizzería Don Piccolo
-- ============================================================================

DROP DATABASE IF EXISTS pizzeria_don_piccolo;
CREATE DATABASE pizzeria_don_piccolo;
USE pizzeria_don_piccolo;

-- ============================================================================
-- 1. TABLAS Y RELACIONES (DDL)
-- ============================================================================

-- Tabla: clientes
CREATE TABLE clientes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    telefono VARCHAR(20) NOT NULL,
    direccion VARCHAR(255) NOT NULL,
    correo_electronico VARCHAR(100) NOT NULL
);

-- Tabla: repartidores
CREATE TABLE repartidores (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    zona_asignada VARCHAR(100) NOT NULL,
    estado ENUM('disponible', 'no disponible') NOT NULL DEFAULT 'disponible'
);

-- Tabla: ingredientes
CREATE TABLE ingredientes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    stock_actual INT NOT NULL,
    stock_minimo INT NOT NULL,
    costo DECIMAL(10,2) NOT NULL
);

-- Tabla: pizzas
CREATE TABLE pizzas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    tamano VARCHAR(20) NOT NULL,
    precio_base DECIMAL(10,2) NOT NULL,
    tipo_pizza ENUM('vegetariana', 'especial', 'clásica') NOT NULL
);

-- Tabla intermedia: pizza_ingredientes (Relación Muchos a Muchos de Recetas)
CREATE TABLE pizza_ingredientes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_pizza INT NOT NULL,
    id_ingrediente INT NOT NULL,
    cantidad_usada INT NOT NULL,
    FOREIGN KEY (id_pizza) REFERENCES pizzas (id),
    FOREIGN KEY (id_ingrediente) REFERENCES ingredientes (id)
);

-- Tabla: pedidos
CREATE TABLE pedidos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT NOT NULL,
    fecha_hora DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    metodo_pago ENUM('efectivo', 'tarjeta', 'app') NOT NULL,
    estado_pedido ENUM('pendiente', 'en preparación', 'entregado', 'cancelado') NOT NULL DEFAULT 'pendiente',
    total DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    FOREIGN KEY (id_cliente) REFERENCES clientes (id)
);

-- Tabla intermedia: pedido_pizza (Relación de los pedidos con las pizzas que lleva)
CREATE TABLE pedido_pizza (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_pedido INT NOT NULL,
    id_pizza INT NOT NULL,
    cantidad INT NOT NULL,
    FOREIGN KEY (id_pedido) REFERENCES pedidos (id),
    FOREIGN KEY (id_pizza) REFERENCES pizzas (id)
);

-- Tabla: domicilios
CREATE TABLE domicilios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_pedido INT NOT NULL UNIQUE,
    id_repartidor INT NOT NULL,
    hora_salida DATETIME NOT NULL,
    hora_entrega DATETIME NULL,
    distancia DECIMAL(5,2) NOT NULL,
    costo_envio DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (id_pedido) REFERENCES pedidos (id),
    FOREIGN KEY (id_repartidor) REFERENCES repartidores (id)
);

-- Tabla de auditoría: historial_precios
CREATE TABLE historial_precios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_pizza INT NOT NULL,
    precio_anterior DECIMAL(10,2) NOT NULL,
    precio_nuevo DECIMAL(10,2) NOT NULL,
    fecha_cambio DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_pizza) REFERENCES pizzas (id)
);


-- ============================================================================
-- 2. DATOS DE PRUEBA COMPLETOS (SEEDERS)
-- ============================================================================

-- Clientes iniciales
INSERT INTO clientes (nombre, telefono, direccion, correo_electronico) VALUES
('Juan Perez', '3151234567', 'Calle 45 #12-34', 'juan.perez@email.com'),
('Maria Gomez', '3109876543', 'Av. Santander #56-78', 'maria.gomez@email.com');

-- Personal de reparto
INSERT INTO repartidores (nombre, zona_asignada, estado) VALUES
('Diego Torres', 'Zona Norte', 'disponible'),
('Andres Mendoza', 'Zona Sur', 'disponible');

-- Materia prima del inventario
INSERT INTO ingredientes (nombre, stock_actual, stock_minimo, costo) VALUES
('Queso Mozzarella', 500, 50, 1500.00),
('Pepperoni', 300, 30, 2500.00),
('Salsa de Tomate', 1000, 100, 500.00);

-- Menú de pizzas disponibles
INSERT INTO pizzas (nombre, tamano, precio_base, tipo_pizza) VALUES
('Margarita', 'Mediana', 25000.00, 'clásica'),
('Pepperoni Especial', 'Familiar', 42000.00, 'especial');

-- Recetas de las pizzas (ingredientes necesarios)
INSERT INTO pizza_ingredientes (id_pizza, id_ingrediente, cantidad_usada) VALUES
(1, 1, 2), (1, 3, 1),
(2, 1, 3), (2, 2, 2);

-- Historial de pedidos reales
INSERT INTO pedidos (id_cliente, fecha_hora, metodo_pago, estado_pedido, total) VALUES
(1, '2026-07-11 19:30:00', 'efectivo', 'entregado', 25000.00),
(2, '2026-07-11 20:00:00', 'tarjeta', 'pendiente', 42000.00);

-- Detalle de qué pizzas se vendieron en cada pedido
INSERT INTO pedido_pizza (id_pedido, id_pizza, cantidad) VALUES
(1, 1, 1), 
(2, 2, 1); 

-- Logística de despachos y entregas de domicilios
INSERT INTO domicilios (id_pedido, id_repartidor, hora_salida, hora_entrega, distancia, costo_envio) VALUES
(1, 1, '2026-07-11 19:40:00', '2026-07-11 20:05:00', 3.5, 5000.00);