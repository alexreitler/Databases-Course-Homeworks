use Forgery;

--INSERT STATEMENTS
INSERT INTO Products (
	pid,
	pname,
	pweight,
	pamount,
	pminamount
) VALUES 
	(1,'',12,30,10),
	(1,'',14,10,15), --Violation
	(3,'',10,15,15),
	(4,'',9,40,30),
	(5,'',45,120,100),
	(6,'',30,30,40)
;

INSERT INTO Employee (
	eid,
	ename,
	erole
) VALUES 
	(1,'Ion','worker'),
	(2,'Mihai','worker'),
	(3,'Andrei','worker'),
	(4,'Ghita','worker'),
	(5,'Mihnea','groupmanager'),
	(6,'Gheo','groupmanager'),
	(7,'BigBoss','generalmanager');

INSERT INTO Clients (
	cid,
	first_order,
	unpaid_value,
	adress
) VALUES 
	(1,20/10/2017,0,'SatuMare'),
	(2,17/07/2019,3504,'Craiova'),
	(3,19/09/2019,11450,'Bucuresti');

INSERT INTO InOrders(
	ioid,
	cid,
	odid,
	order_status
) VALUES 
	(1, 1, NULL, 'In preparation'),
	(2, 2, 1, 'ready'),
	(3, 3, 1, 'ready');


-- UPDATES
-- I bought materials
UPDATE RawMaterials
SET mamount = minamount + 100
WHERE mamount < minamount  -- <

--Loaded all of client 3s orders
UPDATE InOrders
SET order_status = 'ready'
WHERE (cid = 3 AND order_status = 'In preparation')  -- AND (in WHERE)

--We don't deliver there
UPDATE Clients
SET adress = 'no delivery'
WHERE adress IN ('Vaslui','Craiova','Caracal')  -- IN

--DELETES

--Furnace working for 1 or 2 hours is just maintanence
DELETE FROM FurnaceHours WHERE fhours BETWEEN 1 and 2 -- BETWEEN

--We will no longer be working with subsidiaries of XCorp
DELETE FROM Clients WHERE cname LIKE '%XCo%' -- LIKE

--UNIONS

--I want to see all non management employees
SELECT D.dname FROM Drivers D
UNION -- UNION
SELECT E.ename FROM Employee E WHERE E.erole NOT IN ('groupmanager','generalmanager')

-- Investors want to know about special cases in our orders

SELECT DISTINCT I.ioid FROM InOrders I -- DISTINCT
WHERE (I.ovalue > 10000 AND I.order_status = 'finished') OR order_status = 'cancelled' -- OR & condition with AND, OR, () in WHERE
ORDER BY I.ovalue DESC-- ORDER BY

-- INTERSECT & IN

-- There are things that we just resell, this are categorised both as raw materials and products. We list them:

SELECT R.mname FROM RawMaterials R
INTERSECT   -- INTERSECT
SELECT P.pname FROM Products P

-- Same just with IN

SELECT R.mname FROM RawMaterials R
WHERE R.mname IN (SELECT P.pname FROM Products P) -- IN , subquerry in IN

-- EXCEPT & NOT IN

-- Products that are not in any orders, and are holding up our warehouse space for no reason and send them as free samples

SELECT TOP 5 Prd.pid --TOP
FROM (SELECT P.pid, P.pamount - 5 AS NewAmount FROM Products P -- arithmetic in SELECT
ORDER BY P.pamount DESC
EXCEPT 
SELECT O.pid FROM ProductOrderRelation O) Prd

-- Same with NOT IN and without extras to not pick ALL the low hanging fruits

SELECT P.pid from Products P
WHERE P.pid NOT IN (SELECT O.pid FROM ProductOrderRelation O)

--JOINS

-- See which driver takes what van 

SELECT D.dname, V.registration
FROM Drivers D INNER JOIN DeliveryVans V ON D.assigned_van = V.vid -- INNER JOIN

-- See what the drivers have to load up in which van, also shows drivers with nothing assigned
--Joins three tables
SELECT D.dname, V.registration, OD.odid
FROM Drivers D
LEFT JOIN DeliveryVans V ON D.assigned_van = V.vid -- LEFT JOIN
LEFT JOIN OutDeliveries OD ON D.did = OD.did

-- see all active orders above 5000 value and the clients that made them, listing clients that do not have such orders

SELECT OP.ioid, C.cname
FROM (
	SELECT O.ioid, O.ovalue - 200 AS ovalue, O.cid, O.order_status FROM InOrders O -- subquerry in FROM and arithmetic in SELECT
	WHERE (O.order_status NOT IN ('cancelled','finished') AND O.ovalue > 5000)) OP --AND IN WHERE
RIGHT JOIN Clients C ON OP.cid = C.cid -- RIGHT JOIN
ORDER BY OP.ovalue DESC -- ORDER BY

-- See top 5 raw materials that are blocking production 
-- FUL JOIN, 2 many to many relations
SELECT DISTINCT TOP 5 RMP.mname
FROM (SELECT RM.mname, P.pid, P.pname, OO.ooid
FROM Products P
FULL JOIN MaterialsProductRelation MPR ON P.pid = MPR.pid
FULL JOIN RawMaterials RM ON MPR.mid = RM.mid
FULL JOIN OrderMaterialRelation OMR ON RM.mid = OMR.mid
FULL JOIN OutOrders OO ON OMR.ooid = OO.ooid
WHERE P.pamount < P.pminamount AND RM.mamount = 0
GROUP BY RM.mname --GROUP BY
ORDER BY COUNT(P.pid) DESC) RMP --COUNT


-- IN with subquerry in subquerry

-- print raw materials which are used in products that are ordered

SELECT DISTINCT RM.mname -- DISTINCT
FROM RawMaterials RM 
WHERE RM.mid IN(
	SELECT RaM.mid
	FROM RawMaterials RaM
	INNER JOIN MaterialsProductRelation MPR ON RaM.mid = MPR.mid
	INNER JOIN Products P ON MPR.pid = P.pid
	WHERE P.pid IN 
	(
		SELECT Prd.pid
		FROM Products Prd
		INNER JOIN ProductOrderRelation POR ON POR.pid = Prd.pid
	)
)

-- double min amount of products that are in at least 3 orders

SELECT P.pname, P.pminamount * 2 AS NewMinAmount
FROM Products P
WHERE EXISTS (
	SELECT * 
	FROM Products Prd
	INNER JOIN ProductOrderRelation POR ON Prd.pid = POR.pid
	WHERE COUNT(Prd.pid) > 3
)


--list products that are not ordered

SELECT P.pname
FROM Products P
WHERE P.pid NOT IN (
	SELECT Prd.pname, Prd.pid
	FROM Products Prd
	WHERE EXISTS (
		SELECT * 
		FROM Products Prds
		INNER JOIN ProductOrderRelation POR ON Prds.pid = POR.pid
	)
)