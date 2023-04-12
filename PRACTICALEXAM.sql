--DROP DATABASE RentACar
--create Database RentACar
--use RentACar
DROP TABLE  CarType
CREATE TABLE CarType(
	tid INT PRIMARY KEY IDENTITY,
	tname VARCHAR(50),
	tdesc VARCHAR(300)
)
DROP TABLE Car
CREATE TABLE Car(
	carid INT PRIMARY KEY IDENTITY,
	carname VARCHAR(100),
	cardesc VARCHAR(500),
	tid INT FOREIGN KEY REFERENCES CarType(tid)
)
DROP TABLE Company
CREATE TABLE Company(
	comid INT PRIMARY KEY IDENTITY,
	comname VARCHAR (100) UNIQUE
)
DROP Table Branch
CREATE TABLE Branch(
	bid INT PRIMARY KEY IDENTITY,
	bname VARCHAR(100) UNIQUE,
	badd VARCHAR(200),
	comid INT FOREIGN KEY REFERENCES Company(comid)
)
DROP TABLE RentPrice
CREATE TABLE RentPrice(
	bid INT FOREIGN KEY REFERENCES Branch(bid),
	carid INT FOREIGN KEY REFERENCES Car(carid),
	no_cars INT,
	price REAL
)

DELETE FROM CarType
INSERT INTO CarType VALUES ('Coupe','2 doors'),('Hatchback','Small car'),('SUV','Big Car')
SELECT * FROM CarType

DELETE FROM Car
INSERT INTO Car VALUES ('GT86','Toyota NA Coupe',1),('C63','Mercedes Powerful Coupe',1),('Golf VII','Volkswagen Hatchback',2),('A Klasse','Mercedes Hatchback',2),('Volvo XC90','Volvo really big car',3),('GLE','Mercedes stylish SUV',3)
SELECT * FROM Car

DELETE FROM Company
INSERT INTO Company VALUES ('CompanyA'),('CompanyB')
SELECT * FROM Company

DELETE FROM Branch
INSERT INTO Branch VALUES ('BranchA1','Arad',1),('BranchB1','ClugNapoka',2),('BranchB2','CRAIOVA LOL',2)
SELECT * FROM Branch

DELETE FROM RentPrice
INSERT INTO RentPrice VALUES (1,1,2,45.6),(1,3,3,59.7),(2,1,5,36.5),(2,2,3,45.0),(2,3,3,45.0),(3,4,1,67.9),(3,5,3,69.9),(3,1,3,69.9)
SELECT * FROM RentPrice

GO
CREATE OR ALTER PROCEDURE insertCar(@BR VARCHAR(100), @CAR VARCHAR(100), @NR INT, @PR REAL)
AS
	DECLARE @branch_id INT = (SELECT BCH.bid
							FROM Branch BCH
							WHERE BCH.bname = @BR)
	IF @branch_id is NULL
	BEGIN
		RAISERROR('No such branch',10,1)
		RETURN
	END
	DECLARE @car_id INT = (SELECT CR.carid
							FROM Car CR
							WHERE CR.carname = @CAR)
	IF (SELECT COUNT(*) FROM RentPrice RP WHERE RP.bid = @branch_id AND RP.carid = @car_id) = 0
	BEGIN
		INSERT INTO RentPrice VALUES (@branch_id,@car_id,@NR,@PR)
	END
	ELSE
	BEGIN
		UPDATE RentPrice SET no_cars = @NR, price = @PR
		WHERE bid = @branch_id AND carid = @car_id
	END

GO

EXEC insertCar 'BranchA1','GLE',2,67.9;



GO
CREATE OR ALTER VIEW companiesWithAllCars
AS

SELECT COMP.comname
FROM Company COMP
	WHERE COMP.comid IN (
		SELECT BR.comid
		FROM Branch BR
		RIGHT JOIN
		RentPrice RP ON BR.bid = RP.bid
		GROUP BY BR.comid
		HAVING COUNT(*) = (SELECT COUNT(*) FROM Car)
	)

GO

SELECT * FROM companiesWithAllCars;


GO
CREATE OR ALTER FUNCTION avgPriceLessR(@R INT)
RETURNS TABLE
AS
RETURN
SELECT CR.carname FROM Car CR
WHERE CR.carid IN (SELECT RP.carid 
					FROM RentPrice RP
					GROUP BY RP.carid
					HAVING AVG(price)<@R
					)
GO

SELECT * FROM avgPriceLessR(60);