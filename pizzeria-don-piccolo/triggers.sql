-- TRIGGER: Descuenta ingredientes del stock de forma estándar y segura para MySQL
CREATE TRIGGER after_pedido_pizza_insert
AFTER INSERT ON pedido_pizza
FOR EACH ROW
BEGIN
    UPDATE ingredientes i
    SET i.stock_actual = i.stock_actual - (
        SELECT pi.cantidad_usada * NEW.cantidad
        FROM pizza_ingredientes pi
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
