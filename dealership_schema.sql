/* ============================================================
   Car Dealership Inventory Management Database
   SQL Server 2022 (T-SQL)
   Schema rebuild — BCIT SQL Database System project
   ============================================================ */

CREATE DATABASE DealershipDB;
GO

USE DealershipDB;
GO

/* ------------------------------------------------------------
   Makes: normalized vehicle manufacturer lookup
   ------------------------------------------------------------ */
CREATE TABLE Makes (
    MakeID      INT             IDENTITY(1,1) PRIMARY KEY,
    MakeName    NVARCHAR(50)    NOT NULL UNIQUE
);
GO

/* ------------------------------------------------------------
   Models: each model belongs to exactly one make
   ------------------------------------------------------------ */
CREATE TABLE Models (
    ModelID     INT             IDENTITY(1,1) PRIMARY KEY,
    MakeID      INT             NOT NULL,
    ModelName   NVARCHAR(50)    NOT NULL,
    CONSTRAINT FK_Models_Makes FOREIGN KEY (MakeID) REFERENCES Makes(MakeID),
    CONSTRAINT UQ_Models_MakeModel UNIQUE (MakeID, ModelName)
);
GO

/* ------------------------------------------------------------
   Vehicles: individual inventory units
   ------------------------------------------------------------ */
CREATE TABLE Vehicles (
    VIN         CHAR(17)        PRIMARY KEY,
    ModelID     INT             NOT NULL,
    ModelYear   SMALLINT        NOT NULL,
    Trim        NVARCHAR(50)    NULL,
    Mileage     INT             NOT NULL DEFAULT 0,
    Price       DECIMAL(10,2)   NOT NULL,
    Status      NVARCHAR(20)    NOT NULL DEFAULT 'In Stock',
    CONSTRAINT FK_Vehicles_Models FOREIGN KEY (ModelID) REFERENCES Models(ModelID),
    CONSTRAINT CK_Vehicles_Status CHECK (Status IN ('In Stock', 'Pending Sale', 'Sold')),
    CONSTRAINT CK_Vehicles_Mileage CHECK (Mileage >= 0),
    CONSTRAINT CK_Vehicles_Price CHECK (Price >= 0),
    CONSTRAINT CK_Vehicles_VIN_Length CHECK (LEN(VIN) = 17)
);
GO

/* ------------------------------------------------------------
   Customers
   ------------------------------------------------------------ */
CREATE TABLE Customers (
    CustomerID  INT             IDENTITY(1,1) PRIMARY KEY,
    FirstName   NVARCHAR(50)    NOT NULL,
    LastName    NVARCHAR(50)    NOT NULL,
    Email       NVARCHAR(100)   NULL UNIQUE,
    Phone       NVARCHAR(20)    NULL
);
GO

/* ------------------------------------------------------------
   Salespeople
   ------------------------------------------------------------ */
CREATE TABLE Salespeople (
    SalespersonID   INT             IDENTITY(1,1) PRIMARY KEY,
    FirstName       NVARCHAR(50)    NOT NULL,
    LastName        NVARCHAR(50)    NOT NULL,
    HireDate        DATE            NOT NULL
);
GO

/* ------------------------------------------------------------
   SalesTransactions: one row per completed sale.
   VIN is UNIQUE here because a given vehicle can only be sold once.
   ------------------------------------------------------------ */
CREATE TABLE SalesTransactions (
    TransactionID   INT             IDENTITY(1,1) PRIMARY KEY,
    VIN             CHAR(17)        NOT NULL UNIQUE,
    CustomerID      INT             NOT NULL,
    SalespersonID   INT             NOT NULL,
    SaleDate        DATE            NOT NULL,
    SalePrice       DECIMAL(10,2)   NOT NULL,
    CONSTRAINT FK_Sales_Vehicles FOREIGN KEY (VIN) REFERENCES Vehicles(VIN),
    CONSTRAINT FK_Sales_Customers FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    CONSTRAINT FK_Sales_Salespeople FOREIGN KEY (SalespersonID) REFERENCES Salespeople(SalespersonID),
    CONSTRAINT CK_Sales_Price CHECK (SalePrice >= 0)
);
GO

/* ------------------------------------------------------------
   InventoryLog: status/history trail per vehicle over time.
   This is what makes "aging inventory" and "arrivals over time"
   reports possible later — Vehicles alone is just a snapshot.
   ------------------------------------------------------------ */
CREATE TABLE InventoryLog (
    LogID       INT             IDENTITY(1,1) PRIMARY KEY,
    VIN         CHAR(17)        NOT NULL,
    EventDate   DATE            NOT NULL,
    EventType   NVARCHAR(30)    NOT NULL,
    Notes       NVARCHAR(200)   NULL,
    CONSTRAINT FK_InventoryLog_Vehicles FOREIGN KEY (VIN) REFERENCES Vehicles(VIN),
    CONSTRAINT CK_InventoryLog_EventType CHECK (EventType IN (
        'Arrived - New', 'Arrived - Trade-In', 'Price Change', 'Status Change', 'Sold'
    ))
);
GO
