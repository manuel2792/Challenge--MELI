-- El script DDL es suponiendo que utilizan BigQuery

-- Crear tabla Customers
--particiono por BirthDate para mejorar rendimiento en búsquedas por fecha.
CREATE OR REPLACE TABLE Customer (
    CustomerID INT64,
    Email STRING,
    FirstName STRING,
    LastName STRING,
    Gender STRING(1),
    Address STRING,
    BirthDate DATE,
    PhoneNumber STRING,
    userType STRING
) PARTITION BY BirthDate;

-- Crear tabla Category
CREATE OR REPLACE TABLE Category (
    CategoryID INT64,
    CategoryName STRING,
    Path STRING
);

-- Crear tabla Item
-- Particiono por DeactivationDate para facilitar limpieza de datos.
CREATE OR REPLACE TABLE Item (
    ItemID INT64,
    Name STRING,
    Description STRING,
    CategoryID INT64,
    Price NUMERIC(17, 2),
    State STRING,
    DeactivationDate DATE,
    SellerID INT64
) PARTITION BY DeactivationDate;

-- Crear tabla Order
--particiono por OrderDate para optimizar consultas históricas
CREATE OR REPLACE TABLE Orders (
    OrderID INT64,
    CustomerID INT64,
    OrderDate DATE,
    TotalAmount NUMERIC(17, 2),
    Status STRING
) PARTITION BY OrderDate;

-- Crear tabla OrderItem
CREATE OR REPLACE TABLE OrderItem (
    OrderItemID INT64,
    OrderID INT64,
    ItemID INT64,
    Quantity INT64,
    Price NUMERIC(10, 2)
);
