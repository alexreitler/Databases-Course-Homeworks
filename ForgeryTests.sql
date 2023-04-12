USE Forgery

-- Uses tables Products, WorkShift and ShiftProductRelation
--SET IDENTITY_INSERT Employee OFF
--INSERT INTO Employee (eid, ename, erole) VALUES (1,'Mihai','groupmanager')
--SET IDENTITY_INSERT EmployeeGroup ON
--INSERT INTO EmployeeGroup (gid, manager_id) VALUES (1,1)
--INSERT INTO EmployeeGroup (gid, manager_id) VALUES (2,1)
--INSERT INTO EmployeeGroup (gid, manager_id) VALUES (3,1)

--SELECT * FROM Employee

--SELECT * FROM EmployeeGroup


GO 
CREATE OR ALTER VIEW ViewProducts
AS 
	SELECT * 
	FROM Products
GO 

CREATE OR ALTER VIEW ViewProductsAndShifts
AS 
	SELECT Products.pid, ShiftProductRelation.wsid
	FROM Products INNER JOIN ShiftProductRelation ON Products.pid = ShiftProductRelation.pid
GO

CREATE OR ALTER VIEW ViewShiftsAndProductsGrouped
AS 
	SELECT WorkShift.wsid
	FROM WorkShift INNER JOIN ShiftProductRelation ON WorkShift.wsid = ShiftProductRelation.wsid
	GROUP BY WorkShift.wsid
	
GO

DELETE FROM TestViews

DELETE FROM Tables
SET IDENTITY_INSERT Tables ON
INSERT INTO Tables (TableID, Name) VALUES(1, 'Products'),(2, 'WorkShift'),(3, 'ShiftProductRelation')
SET IDENTITY_INSERT Tables OFF

DELETE FROM Views 
SET IDENTITY_INSERT Views ON
INSERT INTO Views (ViewID, Name) VALUES (1, 'ViewProducts'),(2, 'ViewProductsAndShifts'),(3, 'ViewShiftsAndProductsGrouped')
SET IDENTITY_INSERT Views OFF

DELETE FROM Tests 
SET IDENTITY_INSERT Tests ON
INSERT INTO Tests (TestID , Name) VALUES(1,'selectView'),(2,'insertProduct'),(3,'deleteProduct'),(4,'insertShift'),(5,'deleteShift'),(6,'insertRelation'),(7,'deleteRelation') 
SET IDENTITY_INSERT Tests OFF

SELECT * FROM Tests
SELECT * FROM Tables 
SELECT * FROM Views


INSERT INTO TestViews VALUES (1,1)
INSERT INTO TestViews VALUES (1,2)
INSERT INTO TestViews VALUES (1,3)

DELETE FROM TestTables 
INSERT INTO TestTables VALUES (2, 1, 100, 1)
INSERT INTO TestTables VALUES (4, 2, 1000, 2)
INSERT INTO TestTables VALUES (6, 3, 10000, 3)

SELECT * FROM TestTables

GO
CREATE OR ALTER PROC insertProduct 
AS 
	DECLARE @crt INT = 1
	DECLARE @rows INT
	SELECT @rows = NoOfRows FROM TestTables WHERE TestId = 2
	SET IDENTITY_INSERT Products ON
	WHILE @crt <= @rows 
	BEGIN 
		INSERT INTO Products (pid, pname, pweight, pamount, pminamount) VALUES (@crt,convert(varchar(7),@crt),FLOOR(RAND()*(100-0+1)+0),CONVERT(INT,FLOOR(RAND()*(50-10+1)+10)),CONVERT(INT,FLOOR(RAND()*(30-5+1)+5)))
		SET @crt = @crt + 1 
	END 
	SET IDENTITY_INSERT Products OFF

GO 
CREATE OR ALTER PROC deleteProduct
AS 
	DELETE FROM Products WHERE pid>=1;

GO 
CREATE OR ALTER PROC insertShift
AS 
	DECLARE @crt INT = 1
	DECLARE @rows INT
	SELECT @rows = NoOfRows FROM TestTables WHERE TestId = 4
	WHILE @crt <= @rows 
	BEGIN 
		INSERT INTO WorkShift (wsid, wsdate, shifttype, gid) VALUES (@crt,GETDATE(),CONVERT(INT,FLOOR(RAND()*(3-1+1)+1)),CONVERT(INT,FLOOR(RAND()*(3-1+1)+1)))
		SET @crt = @crt + 1 
	END

GO 
CREATE OR ALTER PROC deleteShift
AS 
	DELETE FROM WorkShift;

GO
CREATE OR ALTER PROC insertRelation
AS 
	DECLARE @crt INT = 1
	DECLARE @rows INT
	DECLARE @products INT
	DECLARE @shifts INT
	SELECT @rows = NoOfRows FROM TestTables WHERE TestID = 6
	SELECT @products = NoOfRows FROM TestTables WHERE TestID = 2
	SELECT @shifts = NoOfRows FROM TestTables WHERE TestID = 4
	WHILE @crt <= @rows 
	BEGIN 
		INSERT INTO ShiftProductRelation (pid, wsid, amountmade) VALUES (CONVERT(INT,FLOOR(RAND()*(@products-0+1)+0)),CONVERT(INT,FLOOR(RAND()*(@shifts-0+1)+0)),CONVERT(INT,FLOOR(RAND()*(50-10+1)+10)))
		SET @crt = @crt + 1 
	END

GO 
CREATE OR ALTER PROC deleteRelation
AS 
	DELETE FROM ShiftProductRelation;

SELECT * FROM Views


GO

INSERT INTO TestRuns (Description) VALUES ('test1')

GO

CREATE OR ALTER PROC TestRunProc
AS 
	DECLARE @ID INT;
	SET @ID = (SELECT MAX(TestRunID)+1 FROM TestRuns)
	DECLARE @startall DATETIME;
	DECLARE @start1 DATETIME;
	DECLARE @start2 DATETIME;
	DECLARE @start3 DATETIME;
	DECLARE @start4 DATETIME;
	DECLARE @start5 DATETIME;
	DECLARE @start6 DATETIME;
	DECLARE @start7 DATETIME;
	DECLARE @start8 DATETIME;
	DECLARE @start9 DATETIME;
	DECLARE @end1 DATETIME;
	DECLARE @end2 DATETIME;
	DECLARE @end3 DATETIME;
	DECLARE @end4 DATETIME;
	DECLARE @end5 DATETIME;
	DECLARE @end6 DATETIME;
	DECLARE @end7 DATETIME;
	DECLARE @end8 DATETIME;
	DECLARE @end9 DATETIME;
	DECLARE @endall DATETIME;

	SET @startall = GETDATE();

	SET @start6 = GETDATE();
	PRINT('deleting data from ShiftProductRelation')
	EXEC deleteRelation;
	SET @end6 = GETDATE();
	INSERT INTO TestRunTables VALUES (@ID, 3, @start6, @end6);

	SET @start4 = GETDATE();
	PRINT('deleting data from WorkShifts')
	EXEC deleteShift;
	SET @end4 = GETDATE();
	INSERT INTO TestRunTables VALUES (@ID, 2, @start4, @end4);

	SET @start2 = GETDATE();
	PRINT('deleting data from Products')
	EXEC deleteProduct;
	SET @end2 = GETDATE();
	INSERT INTO TestRunTables VALUES (@ID, 1, @start2, @end2);

	SET @start1 = GETDATE();
	PRINT('inserting data into Products')
	EXEC insertProduct;
	SET @end1 = GETDATE();
	INSERT INTO TestRunTables VALUES (@ID, 1, @start1, @end1);

	SET @start3 = GETDATE();
	PRINT('inserting data into WorkShifts')
	EXEC insertShift;
	SET @end3 = GETDATE();
	INSERT INTO TestRunTables VALUES (@ID, 2, @start3, @end3);

	SET @start5 = GETDATE();
	PRINT('inserting data into ShiftProductRelation')
	EXEC insertRelation;
	SET @end5 = GETDATE();
	INSERT INTO TestRunTables VALUES (@ID, 3, @start5, @end5);

		SET @start7 = GETDATE();
	PRINT ('executing view 1')
	EXEC ('SELECT * FROM ViewProducts');
	SET @end7 = GETDATE();
    INSERT INTO TestRunViews VALUES (@ID, 1, @start7, @end7);

	SET @start8 = GETDATE();
	PRINT ('executing view 2')
	EXEC ('SELECT * FROM ViewProductsAndShifts');
	SET @end8 = GETDATE();
    INSERT INTO TestRunViews VALUES (@ID, 2, @start8, @end8);

	SET @start9 = GETDATE();
	PRINT ('executing view 3')
	EXEC ('SELECT * FROM ViewShiftsAndProductsGrouped');
	SET @end9 = GETDATE();
    INSERT INTO TestRunViews VALUES (@ID, 3, @start9, @end9);

	SET @endall = GETDATE();


	INSERT INTO TestRuns (StartAt, EndAt) VALUES (@startall, @endall);

	GO

EXEC TestRunProc;

SELECT * FROM TestRuns
SELECT * FROM TestRunViews
SELECT * FROM TestRunTables

--DELETE FROM TestRunViews
--DELETE FROM TestRunTables
--DELETE FROM TestRuns
