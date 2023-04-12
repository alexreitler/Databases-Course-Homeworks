USE Forgery

-- Tables creation

DELETE FROM DeliveryVans
DELETE FROM Drivers
DELETE FROM DriverVanRelation

-- Procedure to generate and insert random data into DeliveryVans
GO
CREATE OR ALTER PROCEDURE insertIntoVans(@rows INT) AS
BEGIN
	DECLARE @crt INT = 1
	SET IDENTITY_INSERT DeliveryVans ON
	WHILE @rows > @crt
	BEGIN
		INSERT INTO DeliveryVans (vid, registration, capacity) VALUES (@crt, @crt, CONVERT(INT,FLOOR(RAND()*(3500-1200+1)+1200)))
		SET @crt = @crt + 1
	END
	SET IDENTITY_INSERT DeliveryVans OFF
END

-- Procedure to generate and insert random data into Drivers
GO
CREATE OR ALTER PROCEDURE insertIntoDrivers(@rows INT) AS
BEGIN
	DECLARE @crt INT = 1
	SET IDENTITY_INSERT Drivers ON
	WHILE @rows > @crt
	BEGIN
		INSERT INTO Drivers (did, dname, deliveries_done) VALUES (@crt, convert(varchar(7),@crt), CONVERT(INT,FLOOR(RAND()*(300-0+1)+0)))
		SET @crt = @crt + 1
	END
	SET IDENTITY_INSERT Drivers OFF
END

-- Procedure to generate and insert random data into DriverVanRelation
GO
CREATE OR ALTER PROCEDURE insertIntoRelation(@rows INT) AS
BEGIN
	DECLARE @did INT
	DECLARE @vid INT
	DECLARE @crt INT = 1
	SET IDENTITY_INSERT DriverVanRelation ON
	WHILE @rows > @crt
	BEGIN
		SET @did = (SELECT TOP 1 did FROM Drivers ORDER BY NEWID())
		SET @vid = (SELECT TOP 1 vid FROM DeliveryVans ORDER BY NEWID())
		INSERT INTO DriverVanRelation (dvid, did, vid) VALUES(@crt, @did, @vid)
		SET @crt = @crt + 1
	END
	SET IDENTITY_INSERT DriverVanRelation ON
END
GO
-- Inserting data
EXEC insertIntoVans 5000
EXEC insertIntoDrivers 7500
EXEC insertIntoRelation 3000

GO

SELECT *
FROM Drivers

SELECT *
FROM DeliveryVans

SELECT *
FROM DriverVanRelation

GO

/* 
TASKS
OBS: 
- We have a clustered index automatically created for the aid column from Ta
- We have a nonclustered index automatically created for the a2 column from Ta
- We have a clustered index automatically created for the bid column from Tb
- We have a clustered index automatically created for the cid column from Tc
*/

-- a) Write queries on Ta such that their execution plans contain the following operators:
-- clustered index scan - scan the entire table 
-- Cost: 0.0176698
SELECT *
FROM DeliveryVans

-- clustered index seek - return a specific subset of rows from a clustered index
-- Cost: 0.0034481
SELECT *
FROM DeliveryVans
WHERE vid < 152

-- nonclustered index scan - scan the entire nonclustered index
-- Cost: 0.0147068
SELECT registration
FROM DeliveryVans
ORDER BY registration

-- nonclustered index seek - return a specific subset of rows from a nonclustered index
-- Cost: 0.0033161
SELECT registration
FROM DeliveryVans
WHERE registration BETWEEN 100 AND 130

-- key lookup - nonclustered index seek + key lookup - the data is found in a nonclustered index, but additional data is needed
-- Cost: 0.0065704
SELECT capacity, registration
FROM DeliveryVans
WHERE registration = 544

-- b) Write a query on table Tb with a WHERE clause of the form WHERE b2 = value and analyze its execution plan. Create a nonclustered index that can speed up the query. Examine the execution plan again.
SELECT *
FROM Drivers
WHERE dname = '250'

GO

-- Before creating a nonclustered index we have a clustered index scan with the cost: 0.0307902
DROP INDEX IF EXISTS Drivers_dname_index ON Drivers
CREATE NONCLUSTERED INDEX Drivers_dname_index ON Drivers(dname)

-- After creating the nonclustered index on b2, we have a noclustered index seek with the cost: 0.0065704

-- c) Create a view that joins at least 2 tables. Check whether existing indexes are helpful; if not, reassess existing indexes / examine the cardinality of the tables.

GO
CREATE OR ALTER VIEW View1 AS
	SELECT V.vid, D.did, R.dvid
	FROM DriverVanRelation R
	INNER JOIN DeliveryVans V ON V.vid = R.vid
	INNER JOIN Drivers D ON D.did = R.did
	WHERE D.dname = '400' AND V.capacity < 2500

GO
SELECT *
FROM View1

-- With existing indexes(the automatically created ones + nonclustered index on b2): 0.056705
-- When adding a nonclustered index on a3 to the existing indexes: 0.056705
-- Without the nonclustered index on b2 and the nonclustered index on a3: 0.0878116
-- Automatically created indexes + nonclustered index on b2 + nonclustered index on a3 + nonclustered index on (aid, bid) from Tc: 0.0101102

DROP INDEX IF EXISTS DeliveryVans_capacity_index ON DeliveryVans
CREATE NONCLUSTERED INDEX DeliveryVans_capacity_index ON DeliveryVans(capacity)

DROP INDEX IF EXISTS Relation_index ON DriverVanRelation
CREATE NONCLUSTERED INDEX Relation_index ON DriverVanRelation(did,vid)