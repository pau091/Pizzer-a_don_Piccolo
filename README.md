# 🍕 Sistema de Base de Datos - Pizzería Don Piccolo

Este proyecto consiste en el diseño, implementación y automatización de una base de datos relacional robusta en MySQL para gestionar las operaciones comerciales, el inventario de ingredientes, las recetas del menú, el flujo de pedidos y la logística de domicilios de la pizzería "Don Piccolo".

---

## 🗂️ Explicación de las Tablas y Relaciones

El sistema se compone de tablas maestras, tablas intermedias para resolver relaciones de muchos a muchos, una tabla de auditoría histórica y una entidad para logística de despachos:

1. **`clientes`**: Almacena los datos de contacto esenciales (nombre, teléfono, dirección y correo electrónico) de las personas que realizan pedidos.
2. **`repartidores`**: Registra al personal encargado de las entregas, su zona asignada y su estado actual de disponibilidad (`disponible`/`no disponible`).
3. **`ingredientes`**: Controla el inventario de la materia prima, registrando el stock actual, el stock mínimo de alerta y el costo unitario de cada insumo.
4. **`pizzas`**: El catálogo del menú de la pizzería, detallando el nombre, tamaño, precio base y su clasificación (`vegetariana`, `especial`, `clásica`).
5. **`pizza_ingredientes` (Relación Muchos a Muchos)**: Representa las **recetas** del menú. Asocia las pizzas con sus respectivos ingredientes y define la cantidad exacta de insumo que utiliza cada preparación.
6. **`pedidos`**: Registra la cabecera de las ventas, almacenando el cliente que compra, la fecha y hora, el método de pago, el estado del pedido y el monto total facturado.
7. **`pedido_pizza` (Relación Muchos a Muchos)**: Detalla el contenido de cada pedido, asociando qué pizzas se vendieron y en qué cantidad dentro de cada orden de compra.
8. **`domicilios` (Relación Uno a Uno)**: Controla la logística de despachos. Se vincula con `pedidos` de forma única (`UNIQUE`) para garantizar que un pedido solo corresponda a una entrega, asignando un repartidor, tiempos de salida/entrega, distancia y costo de envío.
9. **`historial_precios`**: Tabla de auditoría interna que registra automáticamente los cambios manuales en los precios base de las pizzas para mantener un rastreo histórico.

---

## 🚀 Instrucciones para Ejecutar el Script

Para garantizar que todos los componentes, relaciones, restricciones de llaves foráneas, funciones y triggers se carguen de manera correcta sin conflictos de dependencias, debe seguir estrictamente este orden de ejecución en Visual Studio Code o su cliente de confianza de MySQL:

1. **`database.sql`**: Ejecútelo primero para limpiar bases de datos anteriores, crear la estructura de tablas, definir las llaves primarias/foráneas e insertar los datos iniciales de prueba (`seeders`).
2. **`funciones.sql`**: Ejecútelo en segundo lugar para compilar la lógica del procedimiento almacenado de domicilios y la función de cálculo de costos en el servidor.
3. **`triggers.sql`**: Ejecútelo en tercer lugar para activar la automatización del descuento automático de inventario y la auditoría de precios.
4. **`vistas.sql`**: Ejecútelo en cuarto lugar para habilitar los objetos de reportes precalculados de administración.
5. **`consultas.sql`**: Ejecútelo al final para correr y probar la analítica de datos obligatoria requerida en la consultoría del proyecto.


--- tabla DRAW SQL --> https://ibb.co/PGySH27D

## 🔍 Ejemplos de Consultas Requeridas

A continuación, se presentan los ejemplos de consultas SQL avanzadas incluidas en el archivo de analítica para evaluar el comportamiento del sistema:



### 1. Consulta con Filtro de Rangos (`BETWEEN`)
Obtiene todos los pedidos registrados en el transcurso del año actual:
```sql
SELECT id, id_cliente, fecha_hora, total 
FROM pedidos 
WHERE fecha_hora BETWEEN '2026-01-01' AND '2026-12-31';

2. Consulta de Agregación y Ordenamiento (JOIN y GROUP BY)
Identifica cuáles son los productos del menú más vendidos en la pizzería ordenados de mayor a menor demanda:

SQL
SELECT p.nombre, SUM(pp.cantidad) AS total_vendido
FROM pedido_pizza pp
JOIN pizzas p ON pp.id_pizza = p.id
GROUP BY p.id, p.nombre
ORDER BY total_vendido DESC;

3. Búsqueda por Patrones de Texto (LIKE)
Filtra y extrae las pizzas que pertenezcan o contengan la palabra de categoría "Especial":

SQL
SELECT * FROM pizzas WHERE nombre LIKE '%Especial%';

4. Consulta Compleja Avanzada (HAVING y Subconsulta)
Encuentra los clientes de alto valor cuyo gasto acumulado total en compras supera el promedio general de ventas de todo el negocio:

SQL
SELECT c.nombre, SUM(p.total) AS total_gastado
FROM clientes c
JOIN pedidos p ON c.id = p.id_cliente
GROUP BY c.id, c.nombre
HAVING SUM(p.total) > (SELECT AVG(total) FROM pedidos);

5. Validación de Lógica Programable con la Función Personalizada
Muestra el catálogo de pizzas comparando de manera directa su precio de venta al público frente al costo neto real de sus insumos en inventario:

SQL
SELECT nombre, precio_base, calcular_costo_fabricacion_pizza(id) AS costo_materiales
FROM pizzas;