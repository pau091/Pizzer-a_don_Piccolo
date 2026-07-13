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