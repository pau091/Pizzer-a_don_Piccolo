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
