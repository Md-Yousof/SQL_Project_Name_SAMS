
---=====CRUD Operation======-- 

USE ClienSavingAcc
GO

     
SELECT * FROM csa.BranchOfBank
SELECT * FROM csa.Clien
SELECT * FROM csa.Deposit
SELECT * FROM csa.Withdraw
GO


          --===========INSERT==========--
USE ClienSavingAcc
INSERT INTO csa.BranchOfBank (BranchName, BranchEmail, BranchPhoneNo)
									VALUES('IsDBCoxBazar Branch','IsDBCoxsBazar@Gmail.com', '01614478547')
GO
INSERT INTO csa.BranchOfBank (BranchName, BranchEmail, BranchPhoneNo)
									VALUES('IsDBRamo Branch', 'IsDBRamo@Gmail.com','01671473345')
GO
INSERT INTO csa.BranchOfBank (BranchName, BranchEmail, BranchPhoneNo)
									VALUES('IsDBChokria Branch', 'IsDBCokria@Gmail.com', '01685578544')
GO
INSERT INTO csa.BranchOfBank (BranchName, BranchEmail, BranchPhoneNo)
									VALUES('IsDBCtg Branch', 'IsDBCtg@Gmail.com','01681477455')
GO
INSERT INTO csa.BranchOfBank (BranchName, BranchEmail, BranchPhoneNo)
									VALUES('IsDBDhaka Branch', 'IsDBDhaka@Gmail.com','01621477435')
GO
INSERT INTO csa.BranchOfBank (BranchName, BranchEmail, BranchPhoneNo)
									VALUES('IsDBKholna Branch', 'IsDBKholna@Gmail.com','01621477456')
GO

SELECT * FROM csa.BranchOfBank
GO


Use ClienSavingAcc
Insert Into csa.Clien( ClienFirstName, ClienLastName, ClienAddress, ClienPhoneNo,BranchID)
						    	Values('Md','Yousof','CoxBazar','018128966', 100),
									  ('Md','Mojahed','Ak Khan', '018478541', 102),
									  ('Jahangir', 'Alom','CDA', '017458745', 103),
									  ('Norul','Huda', 'Dhaka', '0173585573', 102),
									  ('Kamrul','Azad','Foyslake','0173445872', 103),
									  ('Mostofa','Azad','Foyslake','0173445879', 104)

GO

SELECT * FROM csa.Clien
GO


Use ClienSavingAcc
Insert Into  csa.Deposit(BeiginingBalance, DepositBalance, EndingBalance, ClienID,BranchID)
						Values(500, 5000, 5500, 200, 100),
							  (200, 3000, 3200, 201, 101),
							  (300, 3000, 3300, 202, 102),
							  (400, 5600, 6000, 203, 103),
							  (300, 5700, 6000, 203, 104),
							  (100, 9900, 10000, 201, 103)
GO

SELECT * FROM csa.Deposit
GO


Use ClienSavingAcc
Insert Into  csa.Withdraw (WitdrawAmount, AccountNumber)
							Values(500, 301), (400, 302), (200, 303), 
								  (100, 304),(5000, 301), (300, 304)
GO

SELECT * FROM csa.Withdraw
GO


       --======INSERT Using Store Procedure(sp_CrudOperationAA)=====--
EXEC sp_CrudOperationAA  115, 'ChakBazarIsDB', 'CBazarIsDB@gmail.com', '016777666', 205, 'Md', 'Yousof', 'CoxBazar', '01632916036',110, 'Update', 'INSERT' 
GO

SELECT * FROM csa.BranchOfBank
SELECT * FROM csa.Clien
GO

       --======INSERT Using Store Procedure(sp_Withdraw)=====--
EXEC sp_Withdraw 1001,500,301,'paid'
GO

SELECT * FROM csa.Withdraw
GO


--===========UPDATE BranchOfBank======--
UPDATE  csa.BranchOfBank
SET BranchName='IsDBRasshahi', BranchEmail= 'RasshahiDB@gmail.com', BranchPhoneNo= '0167775455' 
WHERE BranchID=105
GO

     --========For Update (For After Trigger Operation) BranchOfBank======--
UPDATE  csa.BranchOfBank SET BranchName='RamoIsDB', BranchEmail= 'RamoIsDB@gmail.com', BranchPhoneNo= '016772754' WHERE BranchID=104
GO

SELECT * FROM csa.BranchOfBank
SELECT * FROM  csa.Branch_Audit --(Trigger Table)
GO


--===========DELETE Row From The Table Withdraw======--
DELETE FROM csa.Withdraw  
WHERE WithdrawID=5
GO

    --======DELETE Row (For Delete Trigger Operation)======--
DELETE FROM csa.BranchOfBank where BranchID=106
GO 

SELECT * FROM csa.BranchOfBank
SELECT * FROM  csa.Branch_Audit --(Trigger Table)
GO


SELECT * FROM csa.Withdraw
GO


--=================================================--
		--==SELECT STATEMENT==-- 
--=================================================--

    --======Select Query For Total Using Scalar Function =========--
Print dbo.fn_TotalBalance(500,100)
GO

     --====Select Query Using Tabular Function=========-
SELECT * FROM fn_Tabular (301)
GO


   --===Select Query Using View ====--
SELECT *
FROM vw_BalanceDetail
GO


--======Join With Multiple Table Using Corralation/Alias Name=====-- 
--========================================================--

    --========INNER JOIN=======--
SELECT b.BranchID, d.AccountNumber, BranchName, BranchPhoneNo, ClienFirstName, ClienLastName, EndingBalance, WitdrawAmount
FROM csa.BranchOfBank b
INNER JOIN csa.Clien c ON b.BranchID = c.BranchID
INNER JOIN csa.Deposit d ON c.BranchID = d.BranchID
INNER JOIN csa.Withdraw w ON d.AccountNumber = w.AccountNumber
ORDER BY d.AccountNumber 
GO


    --=======LEFT JOIN=======--
SELECT *
FROM csa.Deposit d
LEFT JOIN csa.Withdraw w 
ON d.AccountNumber = w.AccountNumber
ORDER BY w.AccountNumber
GO

   --======RIGHT JOIN========--
SELECT b.BranchName, ClienFirstName, ClienLastName
FROM csa.BranchOfBank b
RIGHT JOIN csa.Clien c 
ON b.BranchID = c.BranchID
ORDER BY b.BranchName
GO

   --======Full JOIN=======--
SELECT b.BranchName, ClienFirstName, ClienLastName, ClienPhoneNo
FROM csa.BranchOfBank b
Full JOIN csa.Clien c 
ON b.BranchID = c.BranchID
ORDER BY ClienFirstName
GO

      --=====Cross JOIN=====--
SELECT  *
FROM csa.BranchOfBank b
Cross Join csa.Clien c 
GO

     --======Self JOIN=======--
SELECT DISTINCT c1.ClienFirstName, c2.ClienLastName
FROM csa.Clien c1
Join csa.Clien c2
On c1.ClienID = c2.ClienID
GO


    --======UNION======--
SELECT AccountNumber, EndingBalance
FROM csa.Deposit
UNION 
SELECT WitdrawAmount,WithdrawID 
FROM csa.Withdraw 


    --======UNION ALL======--
SELECT AccountNumber, EndingBalance
FROM csa.Deposit
UNION All
SELECT WitdrawAmount,WithdrawID 
FROM csa.Withdraw 



--=====Aggregate And Built in function,Clause and Six Clause==---
--=========================================================================--

     --====Select Query For Trigger Table====--
SELECT *
FROM  csa.Branch_Audit
WHERE BranchID = 100
GO

   --===Select Query Total No of Deposit Count====--
SELECT COUNT(*) AS NumberOfInvoices 
From csa.Deposit 
GO

      --==Sum Of BeiginingBalance======--
SELECT SUM(BeiginingBalance) AS BeiginingBalance 
FROM csa.Deposit
GO


    --===Avg of EndingBalance===---
SELECT AVG(EndingBalance) AS [Average of InvoiceTotal]
FROM csa.Deposit
GO


   --====Max of WitdrawAmount====--
SELECT MAX(WitdrawAmount) AS [Highest of InvoiceTotal] 
FROM csa.Withdraw 
GO


    --===Min of WitdrawAmount====
SELECT MIN(WitdrawAmount) AS [Lowest of InvoiceTotal]
FROM csa.Withdraw 
GO


     --====Altogather with in a batch====
SELECT  COUNT(*) AS NumberOfDeposit,
		SUM(EndingBalance) AS [Sum of EndingBalance] ,
		AVG(EndingBalance) AS [Average of EndingBalance] ,
		MAX(EndingBalance) AS [Highest of  EndingBalance],
		MIN(EndingBalance) AS [Lowest of  EndingBalance] 
FROM  csa.Deposit
GO


    --====Claculation for total Balance======--
SELECT SUM(BeiginingBalance + DepositBalance) AS totalBalance
FROM csa.Deposit
GO


--===03 Claculation for total due with where Total WitdrawAmount is greater than 100===
SELECT COUNT(*) AS NumberOfInvoices,
       SUM(WitdrawAmount) AS TotalWitdrawAmount
FROM csa.Withdraw 
WHERE WitdrawAmount> 100;
GO


--====Search condition with clause===--
SELECT TOP 10 BranchName, COUNT(*) AS BranchCount, AVG(EndingBalance) AS EndingBalanceAvg
FROM csa.BranchOfBank 
JOIN csa.Clien ON csa.BranchOfBank .BranchID=csa.Clien.BranchID
JOIN csa.Deposit ON csa.Clien.ClienID =  csa.Deposit.ClienID
GROUP BY BranchName 
HAVING AVG(EndingBalance) > 100
ORDER BY BranchName, EndingBalanceAvg;
GO


    --==Final summay row with ROLLUP==--
Select WithdrawID, COUNT (*) AS WithdrawCount, SUM (WitdrawAmount) AS WitdrawAmountTotal
FROM csa.Withdraw 
GROUP BY WithdrawID WITH ROLLUP
GO


   --===Final summay row with ROLLUP And use WILDCARD==--
Select ClienFirstName, ClienLastName, COUNT (*) AS ClienCount
FROM csa.Clien
WHERE ClienFirstName Like '[A-U]%'
GROUP BY ClienFirstName, ClienLastName WITH ROLLUP
ORDER BY ClienFirstName DESC, ClienLastName DESC;
GO


   --====Final summay row with CUBE====---
Select AccountNumber, COUNT (*) AS BranchIDCount, SUM (EndingBalance) AS EndingBalanceTotal
FROM csa.Deposit
GROUP BY AccountNumber WITH CUBE
GO

     --==Final summay row with ROLLUP Using Join Table==--
SELECT TOP 10 BranchName, COUNT(*) AS BranchCount, AVG(EndingBalance) AS EndingBalanceAvg
FROM csa.BranchOfBank 
JOIN csa.Clien ON csa.BranchOfBank .BranchID=csa.Clien.BranchID
JOIN csa.Deposit ON csa.Clien.ClienID =  csa.Deposit.ClienID
GROUP BY BranchName with ROLLUP 
HAVING AVG(EndingBalance) > 100
ORDER BY BranchName, EndingBalanceAvg;
GO


   --===a summary query Use DISTINCT Clause ========--
SELECT Count(DISTINCT ClienID) As numberofClien,
	  Count(ClienID) As numberofinvoices,
	   Avg(BranchID) As totalBranchID
FROM csa.Clien
WHERE ClienID > = 100;
GO


      --=======Group by Grouping ========-
SELECT  BranchName,ClienFirstName, ClienLastName, COUNT(*) AS BranchCount
FROM csa.BranchOfBank 
JOIN csa.Clien ON csa.BranchOfBank .BranchID=csa.Clien.BranchID
JOIN csa.Deposit ON csa.Clien.ClienID =  csa.Deposit.ClienID
GROUP BY GROUPING SETS((ClienFirstName,ClienLastName),BranchName,())
ORDER BY BranchName, ClienFirstName;
GO


    --======TOP Clause With TIES OR IS NULL======--
SELECT TOP 10 With TIES ClienID, ClienFirstName, ClienLastName
FROM csa.Clien
WHERE ClienLastName Is NOT Null
ORDER BY ClienID DESC
GO


    --======TOP Clause With PERCENT OR IS NULL======--
SELECT TOP 5 Percent ClienID, ClienFirstName, ClienLastName
FROM csa.Clien
WHERE ClienLastName Is NOT Null
ORDER BY ClienID DESC
GO



   --===Built in function==---
---===============================---

   --======Cast=========
SELECT CAST(EndingBalance AS char(11)) As ChangeDataTyp
FROM csa.Deposit
WHERE EndingBalance >= 0;
GO

    --====== Convert======
SELECT * 
FROM csa.Withdraw 
WHERE CONVERT(Bigint, WithdrawID, 110) = 2;
GO


      --===TRY_CONVERT function====--
Select Try_convert (varchar, WithdrawID) as varcharWithdrawID,
	Try_convert(varchar, WitdrawAmount,1) as varcharAmount_1,
	Try_convert(varchar, AccountNumber,107) as varcharNumber_107
From csa.Withdraw 
Go


     --=======ROW_NUMBER Function=====--
SELECT BranchID, ROW_NUMBER() OVER(ORDER BY BranchID) AS RowNumber, BranchName
FROM csa.BranchOfBank;
GO 

   --=======RANK Function =====--
SELECT BranchID, RANK() OVER(ORDER BY BranchName) AS Rank, BranchName
FROM csa.BranchOfBank;
GO 

   --======LEFT function Use Concatenation===--
Select ClienFirstName, ClienLastName,
	  LEFT(ClienFirstName, 3)+ '_' +LEFT(ClienLastName, 1) As Initials
From  csa.Clien
Go

   --======RIGHT and LEFT function Use Concatenation===--
Select ClienPhoneNo, ClienFirstName, ClienLastName, 
	RIGHT(ClienPhoneNo, 8)+ ': '+ LEFT(ClienFirstName, 3)+ '_' +	LEFT(ClienLastName, 1) As InitialsProfile
From  csa.Clien
Go


    --=======Simple CASE function========
SELECT BranchName, BranchID,
CASE BranchID
	WHEN 100 THEN 'Branch Of Ctg'
	WHEN 101 THEN 'Branch Of CoxBazar'
	WHEN 102 THEN 'Branch Of Ramo'
	WHEN 103 THEN 'Branch Of ChokBazar'
END AS Branch
FROM csa.BranchOfBank
GO


    --=====IIF Function=====
SELECT AccountNumber, Sum(EndingBalance) As SumBalance,
	IIF(SUM(EndingBalance) < 5000, 'Low', 'High') AS BalanceRank
FROM csa.Deposit
GROUP BY AccountNumber
GO


   --======CHOOSE Function=======
SELECT WithdrawID, AccountNumber, WitdrawAmount, 
		CHOOSE(WitdrawAmount, 'More Then 100', 'More Then 100', 'More Then 100', 'More Then 100') AS Balance
FROM csa.Withdraw 
GO


   ---=======OFFSET, FETCH======--
SELECT *
FROM csa.Withdraw 
WHERE WithdrawID <> 0
ORDER BY WithdrawID ASC
	OFFSET 0 ROWS
	FETCH NEXT 3 ROWS ONLY; 
GO



      --===========Numaric Function===========---
--==================================================--

       --=======FLOOR and CEILING=====--
SELECT EndingBalance, FLOOR(EndingBalance) AS FLOOR_EB
FROM csa.Deposit

SELECT WitdrawAmount, CEILING (WitdrawAmount) AS CEILING_EB
FROM csa.Withdraw 


   --========CTE=======-
WITH My_CTE
As
(
SELECT ClienFirstName, ClienLastName, ClienAddress, ClienPhoneNo 
FROM csa.Clien
)
SELECT * FROM My_CTE 
GO




--=========Extra Build in Fun====------
Select SYSDATETIME() as [SYSDATETIME]
Select SYSDATETIMEOffset() as [SYSDATETIMEOffset]
Select GETUTCDATE() as [GETUTCDATE]
Select GETDATE() as [GETDATE]
GO

Select DATEDIFF (yy, CAST('04/20/1999' as datetime), GETDATE()) As Years,
DATEDIFF (MM, CAST('04/20/1999' as datetime), GETDATE()) As Months,
DATEDIFF (DD, CAST('04/20/1999' as datetime), GETDATE ()) As Day
GO
                                                                                 

Select DATEDIFF (yy, CAST('1993/01/01' as datetime), GETDATE()) As Years,
DATEDIFF (MM, CAST('1993/01/01' as datetime), GETDATE()) As Months,
DATEDIFF (DD, CAST('1993/01/01' as datetime), GETDATE ()) As Day
GO




