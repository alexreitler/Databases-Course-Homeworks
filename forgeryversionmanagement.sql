USE Forgery;

-- modify the type of a column
GO
CREATE OR ALTER PROCEDURE setRawMaterialAmountDecimal
AS
	ALTER TABLE RawMaterials ALTER COLUMN mamount DECIMAL(5,2)


GO
CREATE OR ALTER PROCEDURE setRawMaterialAmountInt
AS
	ALTER TABLE RawMaterials ALTER COLUMN mamount INT


-- add/remove column

GO
CREATE OR ALTER PROCEDURE addSupplierToRawMaterials
AS
	ALTER TABLE RawMaterials ADD Suppliers VARCHAR(200)


GO
CREATE OR ALTER PROCEDURE removeSupplierToRawMaterials
AS
	ALTER TABLE RawMaterials DROP COLUMN Suppliers


-- add/remove a DEFAULT constraint

GO
CREATE OR ALTER PROCEDURE addDefaultToRoleFromEmployee
AS
	ALTER TABLE Employee ADD CONSTRAINT default_role DEFAULT('worker') FOR erole


GO
CREATE OR ALTER PROCEDURE removeDefaultToRoleFromEmployee
AS
	ALTER TABLE Employee DROP CONSTRAINT default_role



-- add/remove primary key

GO
CREATE OR ALTER PROCEDURE addPayPrimaryKey
AS
	ALTER TABLE EmployeePay
		ADD CONSTRAINT PAY_PRIMARY_KEY PRIMARY KEY(erole)

GO 
CREATE OR ALTER PROCEDURE removePayPrimaryKey
AS
	ALTER TABLE EmployeePay
		DROP CONSTRAINT PAY_PRIMARY_KEY


-- add/remove candidate key

GO
CREATE OR ALTER PROCEDURE newCandidateKeyRawMaterials
AS	
	ALTER TABLE RawMaterials
		ADD CONSTRAINT RAWMATERIALS_CANDIDATE_KEY UNIQUE(mname)

GO
CREATE OR ALTER PROCEDURE removeCandidateKeyRawMaterials
AS
	ALTER TABLE RawMaterials
		DROP CONSTRAINT RAWMATERIALS_CANDIDATE_KEY


-- add/remove foreign key

GO
CREATE OR ALTER PROCEDURE newForeignKeyEmployee 
AS
	ALTER TABLE Employee
		ADD CONSTRAINT EMPLOYEE_FOREIGN_KEY FOREIGN KEY(erole) REFERENCES EmployeePay(erole)

GO
CREATE OR ALTER PROCEDURE removeForeignKeyEmployee
AS
	ALTER TABLE Employee
		DROP CONSTRAINT EMPLOYEE_FOREIGN_KEY



-- create / drop table 

GO
CREATE OR ALTER PROCEDURE addMaintanance 
AS
	CREATE TABLE Maintanance (
		mdate DATE,
		mcost INT,
		on_asset VARCHAR(30)
	)

GO 
CREATE OR ALTER PROCEDURE dropMaintanance
AS
	DROP TABLE Maintanance


-- a table that contains the current version of the database schema

GO

CREATE TABLE versionTable (
	version INT
)

INSERT INTO versionTable 
VALUES
	(1) -- this is the initial version


-- a table that contains the initial version, the version after the execution of the procedure and the procedure that changes the table in this way
CREATE TABLE procedureTable (
	initial_version INT,
	final_version INT,
	procedure_name VARCHAR(MAX),
	PRIMARY KEY (initial_version, final_version)
)

INSERT INTO procedureTable
VALUES
	(1, 2, 'setRawMaterialAmountDecimal'),
	(2, 1, 'setRawMaterialAmountInt'),
	(2, 3, 'addSupplierToRawMaterials'), 
	(3, 2, 'removeSupplierToRawMaterials'),
	(3, 4, 'addDefaultToRoleFromEmployee'),
	(4, 3, 'removeDefaultToRoleFromEmployee'),
	(4, 5, 'addPayPrimaryKey'),
	(5, 4, 'removePayPrimaryKey'),
	(5, 6, 'newCandidateKeyRawMaterials'),
	(6, 5, 'removeCandidateKeyRawMaterials'),
	(6, 7, 'newForeignKeyEmployee'),
	(7, 6, 'removeForeignKeyEmployee'),
	(7, 8, 'addMaintanance'),
	(8, 7, 'dropMaintanance')


-- procedure to bring the database to the specified version
GO
CREATE OR ALTER PROCEDURE goToVersion(@newVersion INT) 
AS
	DECLARE @current_version INT
	DECLARE @procedureName VARCHAR(MAX)
	SELECT @current_version = version FROM versionTable

	IF (@newVersion > (SELECT MAX(final_version) FROM procedureTable) OR @newVersion < 1)
		RAISERROR ('Bad version', 10, 1)
	ELSE
	BEGIN
		IF @newVersion = @current_version
			PRINT('You are already on this version!');
		ELSE
		BEGIN
			IF @current_version > @newVersion
			BEGIN
				WHILE @current_version > @newVersion 
					BEGIN
						SELECT @procedureName = procedure_name FROM procedureTable WHERE initial_version = @current_version AND final_version = @current_version-1
						PRINT('Executing ' + @procedureName);
						EXEC (@procedureName)
						SET @current_version = @current_version - 1
					END
			END

			IF @current_version < @newVersion
			BEGIN
				WHILE @current_version < @newVersion 
					BEGIN
						SELECT @procedureName = procedure_name FROM procedureTable WHERE initial_version = @current_version AND final_version = @current_version+1
						PRINT('Executing ' + @procedureName);
						EXEC (@procedureName)
						SET @current_version = @current_version + 1
					END
			END

			UPDATE versionTable SET version = @newVersion
		END
	END

GO

EXEC goToVersion 1

GO

SELECT *
FROM versionTable

SELECT *
FROM procedureTable