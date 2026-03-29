

CREATE DATABASE project3;

DESCRIBE dirty_cafe_sales;
SELECT COUNT(*) FROM dirty_cafe_sales; 

												--  column 1

SELECT DISTINCT COUNT(`Transaction ID`) FROM dirty_cafe_sales; 

SELECT DISTINCT `Transaction ID` FROM dirty_cafe_sales; 

SELECT  `Transaction ID` FROM dirty_cafe_sales WHERE `Transaction ID` IS NULL  ; 

-- changing data type of Column 1  to fix length ie Varchar
ALTER TABLE dirty_cafe_sales
MODIFY COLUMN `Transaction ID` VARCHAR(20);

-- altering Primary key  
ALTER TABLE dirty_cafe_sales
ADD CONSTRAINT pk PRIMARY KEY (`Transaction ID`);

												--  column 2
SELECT DISTINCT item FROM dirty_cafe_sales
ORDER BY 1;
-- so we have 3 impurietiies ERROR , '' . UNKNOWN

SELECT * FROM dirty_cafe_sales
WHERE item IN('','UNKNOWN','ERROR')
ORDER BY item;

UPDATE dirty_cafe_sales
SET item = NULL
WHERE item IN('','UNKOWN','UNKNOWN','ERROR');

												--  column 3
                                                
SELECT  Quantity FROM dirty_cafe_sales
WHERE Quantity IS NULL;
-- no problem in this column  

												--  column 4

SELECT DISTINCT `Price Per Unit` FROM dirty_cafe_sales;

ALTER TABLE dirty_cafe_sales
MODIFY COLUMN `Price Per Unit` DECIMAL(2,1);

-- Column cleared
 
												--  column 5
SELECT DISTINCT `Total Spent` FROM dirty_cafe_sales
ORDER BY 1;

-- filling impurities 

UPDATE dirty_cafe_sales
SET `Total Spent`  = ''
WHERE `Total Spent` IN(NULL);

UPDATE dirty_cafe_sales
SET `Total Spent`  = UPPER(TRIM(`Total Spent`));


ALTER TABLE dirty_cafe_sales
MODIFY COLUMN  `Total Spent` DECIMAL(10,2);

SELECT * FROM dirty_cafe_sales;

-- done 

										-- Column 6  
SELECT DISTINCT `Payment Method` FROM dirty_cafe_sales;                                        

SELECT `Payment Method`,COUNT(`Payment Method`)
FROM dirty_cafe_sales
GROUP BY `Payment Method`;

UPDATE dirty_cafe_sales
SET `Payment Method` = ''
WHERE `Payment Method` IN ('','ERROR','UNKNOWN');
CREATE TABLE dfs AS
SELECT *, 
		LAG(`Payment Method`,1,'Credit Card') OVER () AS Payment_Method
 FROM dirty_cafe_sales
;

SELECT * FROM dfs;

UPDATE dfs
SET `Payment Method` = ''
WHERE `Payment Method` IN ('k');

ALTER TABLE dfs
ADD COLUMN PM VARCHAR(20); 

UPDATE dfs
SET PM = REPLACE(`Payment_method`,`Payment_method`,`Payment Method`) ;

SELECT * ,REPLACE(`Payment_method`,`Payment_method`,`Payment Method`) FROM dfs;

-- WHERE `Payment method` NOT IN ('') ;

SELECT * FROM dfs;

UPDATE dfs
SET PM = Payment_Method
WHERE PM='';                

UPDATE dfs
SET PM = `Payment Method`
WHERE PM='';                

alter table dfs
DROP COLUMN Payment_Method;
 
alter table dfs
DROP COLUMN `Payment Method`;
 
SELECT * FROM dfs;

ALTER TABLE dfs 
CHANGE COLUMN PM `Payment Method` VARCHAR(20);

-- column 6 done 

								-- 	Column 7 
SELECT DISTINCT Location FROM dfs;      
               
SELECT Location, COUNT(Location) FROM dfs
GROUP BY Location; 

SELECT *  FROM dfs
WHERE Location IN('','ERROR','UNKNOWN') AND ITEM IS NULL AND `Transaction Date`IN('','ERROR','UNKNOWN'); 

DELETE FROM dfs
WHERE Location IN('','ERROR','UNKNOWN') AND ITEM IS NULL AND `Transaction Date`IN('','ERROR','UNKNOWN'); 

SELECT *  FROM dfs
WHERE Location IN('','ERROR','UNKNOWN') AND ITEM IS NULL; 

SELECT * , LAG(Location,1,'In-store')
									OVER() AS stagloc 
FROM dfs1;                         


           
-- FIlling some rows of Item
SELECT DISTINCT `Price Per Unit` FROM dfs;

SELECT Item ,Quantity, `Price Per Unit`,`Total Spent`  FROM dfs
WHERE `Price Per Unit` = 1.5;

UPDATE dfs
SET Item = 'Tea'
WHERE `Price Per Unit` = 1.5;
         

SELECT Item ,Quantity, `Price Per Unit`,`Total Spent`  FROM dfs
WHERE `Price Per Unit` = 5.0;

UPDATE dfs
SET Item = 'Salad'
WHERE `Price Per Unit` = 5.0;
                  

SELECT Item ,Quantity, `Price Per Unit`,`Total Spent`  FROM dfs
WHERE `Price Per Unit` = 1.0;

UPDATE dfs
SET Item = 'Cookie'
WHERE `Price Per Unit` = 1.0;                  


SELECT Item ,Quantity, `Price Per Unit`,`Total Spent`  FROM dfs
WHERE `Price Per Unit` = 2.0;

UPDATE dfs
SET Item = 'Coffee'
WHERE `Price Per Unit` = 2.0;                  



SELECT Item ,Quantity, `Price Per Unit`,`Total Spent` FROM dfs
WHERE `Price Per Unit` = 3.0 OR `Price Per Unit` = 4.0 ;

CREATE TABLE dfs1 AS
SELECT * , LAG(Item,1,'') OVER() AS stagitem 
FROM dfs;

DROP TABLE dfs1;

SELECT * , LAG(Item,1,'') OVER() AS stagitem 
FROM dfs
WHERE Item IS NULL or Item IN('Smoothie','Sandwich','Juice','Cake');


UPDATE dfs1
SET Item = ''
WHERE Item IS NULL ;                  

START  TRANSACTION ;

ALTER TABLE dfs1
MODIFY COLUMN stagitem TEXT;

SELECT * FROM dfs1;

UPDATE dfs1
SET Item = COALESCE(Item,Stagitem); 

ALTER TABLE dfs1
DROP COLUMN stagitem; 

-- column 1 and 6 are cleaned
 
SELECT * FROM dfs1;
										
												-- column 7

SELECT DISTINCT Location FROM dfs1;

UPDATE dfs1
SET Location = ''
WHERE Location IN('','ERROR','UNKNOWN');

SELECT Location , COUNT(LOCATION) FROM dfs1
GROUP BY Location;

UPDATE dfs1
SET Location = NULL
WHERE Location = '';
 
CREATE TABLE dfs2 AS 
SELECT * , LAG(Location,1,'In-store')OVER() AS stagLoc 
FROM dfs1;

UPDATE dfs2
SET Location =  COALESCE(Location, stagloc);

ALTER TABLE dfs2
DROP COLUMN stagloc;


									-- Column  8 
SELECT DISTINCT `Transaction Date` FROM dfs1;          

COMMIT ;

SELECT * FROM dfs1;

SELECT `Transaction Date`, COALESCE(STR_TO_DATE(`Transaction Date`,'%Y-%m-%d'),STR_TO_DATE(`Transaction Date`,'%Y/%m/%d'))                
FROM dfs1; 
						

UPDATE dfs1
SET `Transaction Date` = NULL
WHERE `Transaction Date` = 'UNKNOWN ' OR `Transaction Date` = ''  OR `Transaction Date` = 'ERROR';


SELECT DISTINCT `Transaction Date`                
FROM dfs1
ORDER BY 1 DESC; 


SELECT  `Transaction Date`                
FROM dfs1
WHERE `Transaction Date`= '' ; 

UPDATE dfs1
SET `Transaction Date` = NULL
WHERE `Transaction Date` = 'ERROR';


UPDATE dfs1
SET `Transaction Date` = COALESCE(STR_TO_DATE(`Transaction Date`,'%Y-%m-%d'),STR_TO_DATE(`Transaction Date`,'%Y/%m/%d'))      ;                        

ALTER TABLE dfs1
MODIFY COLUMN `Transaction Date` DATE;

-- ####### CLEANING DONE 

SELECT * FROM dfs1;

-- one last updateing total spent column and location column 

UPDATE dfs1
SET `Total Spent`= Quantity * `Price PEr unit` ;

RENAME TABLE dfs to dirty_cafe_sales_stag_1;

RENAME TABLE dfs1 to dirty_cafe_sales_stag_2;

RENAME TABLE dfs2 to FINAL_dfs;

