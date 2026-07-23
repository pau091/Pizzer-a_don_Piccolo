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
    telefono VARCHAR (100) NOT NULL,
    zona_asignada VARCHAR(100) NOT NULL,
    estado ENUM('activo', 'inactivo') NOT NULL DEFAULT 'activo'
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
-- La columna ESTADO esta en PEDIDOS donde se informa si el pedido esta EN_RUTA, ENTREGADO O CANCELADO
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
INSERT INTO repartidores (nombre, telefono, zona_asignada, estado) VALUES
('Diego Torres', 31245451175, 'Zona Norte', 'activo'),
('Andres Mendoza', 6765756743, 'Zona Sur', 'activo');

DESCRIBE repartidores;

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


-- ============================================================================
-- 3.TRIGGERS, PROCEDIMIENTOS Y FUNCIONES
-- ============================================================================

DELIMITER //

-- TRIGGER: Descuenta ingredientes del stock de forma estándar y segura para MySQL
CREATE TRIGGER after_pedido_pizza_insert
AFTER INSERT ON pedido_pizza
FOR EACH ROW
BEGIN
    UPDATE ingredientes AS i
    SET i.stock_actual = i.stock_actual - (
        SELECT pi.cantidad_usada * NEW.cantidad
        FROM pizza_ingredientes  pi
        WHERE pi.id_ingrediente = i.id AND pi.id_pizza = NEW.id_pizza
    )
    WHERE i.id IN (
        SELECT pi.id_ingrediente 
        FROM pizza_ingredientes pi 
        WHERE pi.id_pizza = NEW.id_pizza
    );
END//

-- TRIGGER: Registra cambios si se actualiza el precio de alguna pizza (Auditoría)
CREATE TRIGGER after_pizza_price_update
AFTER UPDATE ON pizzas
FOR EACH ROW
BEGIN
    IF OLD.precio_base <> NEW.precio_base THEN
        INSERT INTO historial_precios (id_pizza, precio_anterior, precio_nuevo)
        VALUES (NEW.id, OLD.precio_base, NEW.precio_base);
    END IF;
END//

-- FUNCIONES: Registra la entrega del domicilio y cambia el estado del pedido
CREATE PROCEDURE registrar_entrega_domicilio(
    IN p_id_pedido INT,
    IN p_hora_entrega DATETIME
)
BEGIN
    UPDATE domicilios 
    SET hora_entrega = p_hora_entrega 
    WHERE id_pedido = p_id_pedido;
    
    UPDATE pedidos 
    SET estado_pedido = 'entregado' 
    WHERE id = p_id_pedido;
END//

-- FUNCION:  Calcula el costo total de fabricación/materia prima de una pizza
CREATE FUNCTION calcular_costo_fabricacion_pizza(p_id_pizza INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE v_costo_total DECIMAL(10,2);
    
    SELECT SUM(pi.cantidad_usada * i.costo) INTO v_costo_total
    FROM pizza_ingredientes pi
    JOIN ingredientes i ON pi.id_ingrediente = i.id
    WHERE pi.id_pizza = p_id_pizza;
    
    RETURN IFNULL(v_costo_total, 0.00);
END//

DELIMITER ;


-- ============================================================================
-- 4. REPORTES (VIEWS)
-- ============================================================================

-- Vista: Ver el total gastado por cada cliente
CREATE VIEW vista_resumen_pedidos_cliente AS
SELECT c.nombre AS cliente, COUNT(p.id) AS total_pedidos, SUM(p.total) AS dinero_gastado
FROM clientes c
LEFT JOIN pedidos p ON c.id = p.id_cliente
GROUP BY c.id, c.nombre;

-- Vista: Ver qué ingredientes tienen menos stock del mínimo
CREATE VIEW vista_stock_critico AS
SELECT nombre, stock_actual, stock_minimo
FROM ingredientes
WHERE stock_actual < stock_minimo;

-- vista desempeños---------------------
CREATE VIEW vista_desempeno_repartidor AS
SELECT nombre, TIMESTAMPDIFF(MINUTE, d.hora_salida, d.hora_entrega) AS promedio_minutos, COUNT(d.id) AS total_entregas
FROM repartidores r
JOIN domicilios d ON r.id = d.id
GROUP BY r.id;

SELECT * FROM  vista_desempeno_repartidor;

-- SELECCION DE TODA LA TALA REPARTIDORES -----


-- ============================================================================
-- 5. CONSULTAS DE CONSULTORÍA REQUERIDAS (QUERIES)
-- ============================================================================

-- Consulta 1: Consultar pedidos usando un rango de fechas (BETWEEN)
SELECT id, id_cliente, fecha_hora, total 
FROM pedidos 
WHERE fecha_hora BETWEEN '2026-01-01' AND '2026-12-31';

-- Consulta 2: Conocer las pizzas más vendidas ordenadas de mayor a menor (JOIN y GROUP BY)
SELECT p.nombre, SUM(pp.cantidad) AS total_vendido
FROM pedido_pizza pp
JOIN pizzas p ON pp.id_pizza = p.id
GROUP BY p.id, p.nombre
ORDER BY total_vendido DESC;

-- Consulta 3: Buscar pizzas que contengan una palabra específica (LIKE)
SELECT * FROM pizzas WHERE nombre LIKE '%Especial%';

-- Consulta 4: [NUEVA] Consulta compleja con subconsulta y agregación
-- Obtener los clientes que han gastado más dinero que el promedio general de compras de la pizzería
SELECT c.nombre, SUM(p.total) AS total_gastado
FROM clientes c
JOIN pedidos p ON c.id = p.id_cliente
GROUP BY c.id, c.nombre
HAVING SUM(p.total) > (SELECT AVG(total) FROM pedidos);

-- FUNCIONES ( Muestra el precio base frente al costo real de insumos)
SELECT nombre, precio_base, calcular_costo_fabricacion_pizza(id) AS costo_materiales
FROM pizzas;


-- Consulta de entregas realizadas por cada repartidor con su nombre 
SELECT r.nombre, COUNT(*) AS entregas, p.estado_pedido
FROM  repartidores r
JOIN pedidos p ON p.id = r.id
WHERE p.estado_pedido = 'entregado'
GROUP BY r.nombre;

-- CONSULTA PEDIDOS DEMORADOS de más de 40m  ---- 
SELECT d.id, estado, TIMESTAMPDIFF(MINUTE, hora_salida, hora_entrega) AS tiempo
FROM domicilios d
JOIN repartidores r ON r.id = d.id
WHERE TIMESTAMPDIFF(MINUTE, d.hora_salida, d.hora_entrega) > 20; 
-- no se registran pedidos si no se demoran menos de 40 minutos 

-- repartidores con estado activo que su pedido no fue entregado

SELECT id, estado
FROM repartidores r
WHERE estado = 'activo';



-- DROP DATABASE IF EXISTS pizzeria_don_piccolo;