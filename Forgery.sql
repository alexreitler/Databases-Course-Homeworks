--DROP DATABASE Forgery

--CREATE DATABASE Forgery

USE Forgery
GO

DROP TABLE IF EXISTS Employee
CREATE TABLE Employee(
eid INT PRIMARY KEY IDENTITY,
ename VARCHAR(100) NOT NULL,
erole VARCHAR(100) NOT NULL CHECK (erole IN ('worker','groupmanager','generalmanager')),
manager_id INT REFERENCES Employee(eid)
)

DROP TABLE IF EXISTS EmployeeGroup
CREATE TABLE EmployeeGroup (
gid INT PRIMARY KEY IDENTITY,
manager_id INT FOREIGN KEY REFERENCES Employee(eid) NOT NULL
)

DROP TABLE IF EXISTS EmployeePay
CREATE TABLE EmployeePay (
epay INT NOT NULL,
erole VARCHAR(100) NOT NULL
CHECK (erole IN ('worker','groupmanager','generalmanager'))
)

DROP TABLE IF EXISTS EmployeeGroupRelation
CREATE TABLE  EmployeeGroupRelation(
eid INT FOREIGN KEY REFERENCES Employee(eid) UNIQUE NOT NULL,
gid INT FOREIGN KEY REFERENCES EmployeeGroup(gid) NOT NULL,
CONSTRAINT pk_EmployeeGroupRelation PRIMARY KEY (eid, gid)
)

DROP TABLE IF EXISTS WorkShift
CREATE TABLE  WorkShift(
wsid INT,
wsdate DATE,
shifttype CHAR(3),
gid INT FOREIGN KEY REFERENCES EmployeeGroup(gid) NOT NULL,
CONSTRAINT WORKSHIFT_PRIMARY_KEY PRIMARY KEY(wsid)
)

DROP TABLE IF EXISTS Products
CREATE TABLE Products (
pid INT PRIMARY KEY IDENTITY,
pname VARCHAR(20) NOT NULL,
pweight REAL,
pamount INT,
pminamount INT
)

DROP TABLE IF EXISTS Prices
CREATE TABLE Prices (
pprice INT NOT NULL
)

DROP TABLE IF EXISTS ShiftProductRelation
CREATE TABLE ShiftProductRelation (
pid INT FOREIGN KEY REFERENCES Products(pid) NOT NULL,
wsid INT FOREIGN KEY REFERENCES WorkShift(wsid) NOT NULL,
amountmade INT,
CONSTRAINT pk_ShiftProductRelation PRIMARY KEY (pid, wsid)
)

DROP TABLE IF EXISTS FurnaceHours
CREATE TABLE FurnaceHours (
fhours REAL NOT NULL
)

DROP TABLE IF EXISTS RawMaterials
CREATE TABLE RawMaterials (
mid INT PRIMARY KEY IDENTITY,
mname VARCHAR(50) NOT NULL,
mamount REAL,
minamount REAL
)

DROP TABLE IF EXISTS MaterialsProductRelation
CREATE TABLE MaterialsProductRelation (
pid INT FOREIGN KEY REFERENCES Products(pid) NOT NULL,
mid INT FOREIGN KEY REFERENCES RawMaterials(mid) NOT NULL,
material_qty INT NOT NULL,
CONSTRAINT pk_MPR PRIMARY KEY (pid, mid)
)

DROP TABLE IF EXISTS OutOrders
CREATE TABLE OutOrders (
ooid INT PRIMARY KEY IDENTITY,
ovalue REAL
)

DROP TABLE IF EXISTS InDeliveries
CREATE TABLE InDeliveries (
idid INT PRIMARY KEY IDENTITY
)

DROP TABLE IF EXISTS OrderMaterialRelation
CREATE TABLE OrderMaterialRelation (
mid INT FOREIGN KEY REFERENCES RawMaterials(mid) NOT NULL,
ooid INT FOREIGN KEY REFERENCES OutOrders(ooid) NOT NULL,
)

DROP TABLE IF EXISTS OutOrderInDeliveryRelation
CREATE TABLE OutOrderInDeliveryRelation (
ooid INT FOREIGN KEY REFERENCES OutOrders(ooid) UNIQUE NOT NULL,
idid INT FOREIGN KEY REFERENCES InDeliveries(idid) NOT NULL
)

DROP TABLE IF EXISTS Clients
CREATE TABLE Clients (
cid INT PRIMARY KEY IDENTITY,
cname VARCHAR(200) NOT NULL,
first_order DATE,
unpaid_value REAL,
adress VARCHAR(500) NOT NULL
)

DROP TABLE IF EXISTS DeliveryVans
CREATE TABLE DeliveryVans (
vid INT PRIMARY KEY IDENTITY,
registration INT UNIQUE,
capacity INT
)


DROP TABLE IF EXISTS Drivers
CREATE TABLE Drivers (
did INT PRIMARY KEY IDENTITY,
dname VARCHAR(100),
assigned_van INT FOREIGN KEY REFERENCES DeliveryVans(vid) NOT NULL,
deliveries_done INT
)

DROP TABLE IF EXISTS OutDeliveries
CREATE TABLE OutDeliveries (
odid INT PRIMARY KEY IDENTITY,
did INT FOREIGN KEY REFERENCES Drivers(did) NOT NULL,
dstatus VARCHAR(15) NOT NULL
)

DROP TABLE IF EXISTS InOrders
CREATE TABLE InOrders (
ioid INT PRIMARY KEY IDENTITY,
cid INT FOREIGN KEY REFERENCES Clients(cid) NOT NULL,
odid INT FOREIGN KEY REFERENCES OutDeliveries(odid),
order_status VARCHAR(15) NOT NULL
)

DROP TABLE IF EXISTS ProductOrderRelation
CREATE TABLE ProductOrderRelation (
ioid INT FOREIGN KEY REFERENCES InOrders(ioid) NOT NULL,
pid INT FOREIGN KEY REFERENCES Products(pid) NOT NULL,
qty INT NOT NULL DEFAULT 1
)


DROP TABLE IF EXISTS Bills
CREATE TABLE Bills (
bid INT,
bvalue REAL,
pay_by_date DATE
)

DROP TABLE IF EXISTS DriverVanRelation
CREATE TABLE DriverVanRelation (
dvid INT PRIMARY KEY IDENTITY,
did INT FOREIGN KEY REFERENCES Drivers(did),
vid INT FOREIGN KEY REFERENCES DeliveryVans(vid)
)
