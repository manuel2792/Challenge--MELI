-- 1. Listar los usuarios que cumplan años el día de hoy cuya cantidad de ventas realizadas en enero 2020 sea superior a 1500. 

SELECT 
  c.FirstName, 
  c.LastName, 
  c.Email
FROM Customer c
JOIN Order o  
  ON c.CustomerID = o.CustomerID
WHERE EXTRACT(MONTH FROM c.BirthDate) = EXTRACT(MONTH FROM CURRENT_DATE()) AND EXTRACT(DAY FROM c.BirthDate) = EXTRACT(DAY FROM CURRENT_DATE()) 
AND o.OrderDate BETWEEN '2020-01-01' AND '2020-01-31'
AND c.usertype = 'Seller'
GROUP BY c.CustomerID, c.FirstName, c.LastName, c.Email
HAVING COUNT(o.OrderID) > 1500;


-- 2. Por cada mes del 2020, se solicita el top 5 de usuarios que más vendieron($) en la categoría Celulares. Se requiere el mes y año de análisis, nombre y apellido del vendedor, cantidad de ventas realizadas, 
--cantidad de productos vendidos y el monto total transaccionado. 

SELECT 
    EXTRACT(YEAR FROM o.OrderDate) AS Year,
    EXTRACT(MONTH FROM o.OrderDate) AS Month,
    c.FirstName,
    c.LastName,
    COUNT(o.OrderID) AS TotalOrders,
    SUM(o.Quantity) AS TotalItemsSold,
    SUM(o.TotalAmount) AS TotalAmount
FROM Order o
JOIN Customer c ON o.CustomerID = c.CustomerID AND c.usertype = 'Seller'
JOIN Item i ON o.ItemID = i.ItemID
JOIN Category cat ON i.CategoryID = cat.CategoryID
WHERE EXTRACT(YEAR FROM o.OrderDate) = 2020
  AND cat.CategoryName = 'Celulares'
GROUP BY Year, Month, c.FirstName, c.LastName
ORDER BY Year, Month, TotalAmount DESC
LIMIT 5;


-- 3. Se solicita poblar una nueva tabla con el precio y estado de los Ítems a fin del día. Tener en cuenta que debe ser reprocesable. Vale resaltar que en la tabla Item, vamos a tener únicamente el último estado informado por la 
PK definida. (Se puede resolver a través de StoredProcedure) 


-- Crear la tabla DailyItemState
CREATE TABLE DailyItemState (
    ItemID INT,
    Price DECIMAL(10, 2),
    State VARCHAR(50),
    Date DATE,
    PRIMARY KEY (ItemID, Date),
    FOREIGN KEY (ItemID) REFERENCES Item(ItemID)
);

-- Crear el procedimiento almacenado PopulateDailyItemState
DELIMITER //

CREATE PROCEDURE PopulateDailyItemState()
BEGIN
    DECLARE current_date DATE;
    SET current_date = CURDATE();
    
    -- Elimina registros de hoy (si los hay) para evitar duplicados
    DELETE FROM DailyItemState WHERE Date = current_date;
    
    -- Inserta el estado actual de los ítems en la tabla de historial
    INSERT INTO DailyItemState (ItemID, Price, State, Date)
    SELECT ItemID, Price, State, current_date
    FROM Item;
END //

DELIMITER ;

-- Crear el evento programado
CREATE EVENT daily_item_state_event
ON SCHEDULE EVERY 1 DAY
STARTS '2025-02-23 00:00:00'
DO
    CALL PopulateDailyItemState();

-- Asegúrate de que el scheduler de eventos esté habilitado
SET GLOBAL event_scheduler = ON;
