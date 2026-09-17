-- Query 1: Inventory count by make/model (In Stock only)

SELECT 
    mk.MakeName, 
    md.ModelName, 
    COUNT(*) AS UnitsInStock
FROM Vehicles v
JOIN Models md ON v.ModelID = md.ModelID
JOIN Makes mk ON md.MakeID = mk.MakeID
WHERE v.Status = 'In Stock'
GROUP BY mk.MakeName, md.ModelName
ORDER BY mk.MakeName, UnitsInStock DESC;

-- Query 2: Average price and mileage by model (currently on the lot)
SELECT
    mk.MakeName,
    md.ModelName,
    COUNT(*) AS UnitsOnLot,
    ROUND(AVG(v.Price), 2) AS AvgPrice,
    ROUND(AVG(v.Mileage), 0) AS AvgMileage
FROM Vehicles v
JOIN Models md ON v.ModelID = md.ModelID
JOIN Makes mk ON md.MakeID = mk.MakeID
WHERE v.Status <> 'Sold'
GROUP BY mk.MakeName, md.ModelName
ORDER BY mk.MakeName, md.ModelName;

-- Query 3: Low-stock alert (fewer than 4 units currently In Stock)
SELECT
    mk.MakeName,
    md.ModelName,
    COUNT(*) AS UnitsInStock
FROM Vehicles v
JOIN Models md ON v.ModelID = md.ModelID
JOIN Makes mk ON md.MakeID = mk.MakeID
WHERE v.Status = 'In Stock'
GROUP BY mk.MakeName, md.ModelName
HAVING COUNT(*) < 4
ORDER BY UnitsInStock ASC;

-- Query 4: Sales performance by salesperson
SELECT
    sp.FirstName + ' ' + sp.LastName AS Salesperson,
    COUNT(st.TransactionID) AS UnitsSold,
    ISNULL(SUM(st.SalePrice), 0) AS TotalRevenue,
    ROUND(AVG(st.SalePrice), 2) AS AvgSalePrice
FROM Salespeople sp
LEFT JOIN SalesTransactions st ON sp.SalespersonID = st.SalespersonID
GROUP BY sp.FirstName, sp.LastName
ORDER BY TotalRevenue DESC;

-- Query 5: Aging inventory (top 15 oldest In Stock vehicles)
SELECT TOP 15
    mk.MakeName,
    md.ModelName,
    v.Trim,
    v.Price,
    il.EventDate AS ArrivalDate,
    DATEDIFF(DAY, il.EventDate, GETDATE()) AS DaysOnLot
FROM Vehicles v
JOIN Models md ON v.ModelID = md.ModelID
JOIN Makes mk ON md.MakeID = mk.MakeID
JOIN InventoryLog il ON v.VIN = il.VIN
WHERE v.Status = 'In Stock'
  AND il.EventType IN ('Arrived - New', 'Arrived - Trade-In')
ORDER BY DaysOnLot DESC;