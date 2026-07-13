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