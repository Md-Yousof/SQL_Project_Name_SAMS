--==========================================================
--Project Name: "Saving Account Management System"
--===========================================================


USE master
GO

DROP DATABASE IF EXISTS ClienSavingAcc
GO

--==========Get The SQL Server Data_Path========== 
DECLARE @data_path nvarchar(256);
SET @data_path = (SELECT SUBSTRING(physical_name, 1, CHARINDEX(N'master.mdf', LOWER(physical_name)) - 1)
FROM master.sys.master_files
WHERE database_id = 1 AND file_id = 1);

--======Execute The Database With Custom in Default Location=========--
EXECUTE ('CREATE DATABASE ClienSavingAcc
ON PRIMARY
     (NAME = ClienSavingAcc_data, FILENAME = ''' + @data_path + 'ClienSavingAcc_data.mdf'', 
       SIZE = 20MB, MAXSIZE = Unlimited, FILEGROWTH = 5MB)
LOG ON 
     (NAME = ClienSavingAcc_log, FILENAME = ''' + @data_path + 'ClienSavingAcc_log.ldf'',
      SIZE = 10MB, MAXSIZE = 100MB, FILEGROWTH = 1%)');
GO


USE ClienSavingAcc
GO

--====Create Schema name=======-
CREATE SCHEMA csa
GO

DROP TABLE IF Exists BranchOfBld
GO


USE ClienSavingAcc
CREATE TABLE csa.BranchOfBank
(
BranchID INT PRIMARY KEY IDENTITY(100,1),
BranchName VARCHAR(30) NOT NULL,
BranchEmail NVARCHAR(50) NOT NULL CHECK (BranchEmail LIKE '%@gmail.com'),
BranchPhoneNo VARCHAR(15) NOT NULL
);
GO


USE ClienSavingAcc
CREATE TABLE csa.Clien
(
ClienID	INT PRIMARY KEY IDENTITY(200,1),
ClienFirstName VARCHAR(15) NOT NULL,
ClienLastName NVARCHAR(10) SPARSE NULL,
ClienAddress VARCHAR(40) NOT NULL,
ClienPhoneNo VARCHAR(15) UNIQUE CHECK(ClienPhoneNo LIKE '018%' or ClienPhoneNo LIKE '017%' or ClienPhoneNo LIKE '016%'),
BranchID INT FOREIGN KEY REFERENCES csa.BranchOfBank(BranchID)
);
Go


USE ClienSavingAcc
CREATE TABLE  csa.Deposit
(
AccountNumber INT PRIMARY KEY IDENTITY(300,1),
BeiginingBalance MONEY,
DepositBalance MONEY,
EndingBalance MONEY,
ClienID INT FOREIGN KEY REFERENCES csa.Clien(ClienID),
BranchID INT FOREIGN KEY REFERENCES  csa.BranchOfBank(BranchID)
);
GO


USE ClienSavingAcc
Create Table csa.Withdraw 
(
WithdrawID INT IDENTITY,
WitdrawAmount MONEY,
AccountNumber INT FOREIGN KEY REFERENCES csa.Deposit(AccountNumber)
);
GO

SELECT * FROM csa.BranchOfBank
SELECT * FROM csa.Clien
SELECT * FROM csa.Deposit
SELECT * FROM csa.Withdraw



--======Alter Table_Add column_Drop Column And Change Data type====--
--===================================================================--

   --====ADD COLUMN=======--
ALTER TABLE csa.Clien
ADD ClienEmail NVARCHAR(30)
GO

SELECT * FROM csa.Clien
GO

   --====Change Data type=====--
ALTER TABLE csa.BranchOfBank
ALTER COLUMN BranchPhoneNo NVARCHAR(15) NOT NULL

GO

SELECT * FROM csa.BranchOfBank
GO

   --====Drop Column=====--
ALTER TABLE csa.Clien
DROP COLUMN  ClienEmail 
GO

SELECT * FROM csa.Clien
GO

--========Crate Clustered and Non-Clustered Index======--
--=======================================================--

      --===Clustered Index=======--
CREATE CLUSTERED INDEX CI_Withdraw 
ON csa.Withdraw(WithdrawID)
GO

    --=== Non-Clustered Index====--
CREATE NONCLUSTERED INDEX NCI_Clien
ON csa.Clien(ClienPhoneNo)
GO


--====Create Scalar Function And Tabular Function============--
--==============================================================--

     --====Scalar Function=======--
CREATE FUNCTION fn_TotalBalance
 (
	 @beiginingBalance MONEY,
	 @depositebalance MONEY
 )
RETURNS MONEY
AS
BEGIN
    DECLARE @TotalBalance MONEY
    SET @TotalBalance = (@beiginingBalance + @depositebalance)
    RETURN @TotalBalance
END
GO

     --====Tabular Function=========-
CREATE FUNCTION fn_Tabular
(
	@accountnumber INT
)
RETURNS TABLE
AS
RETURN
	(
	SELECT  D.AccountNumber, BeiginingBalance, DepositBalance, WitdrawAmount, EndingBalance
	FROM csa.Deposit AS D
	JOIN csa.Withdraw  AS W
	ON D.AccountNumber= W.AccountNumber
	WHERE D.AccountNumber = @accountnumber
	)
GO


--============Create Sequence================--
--=============================================--
CREATE SEQUENCE Seq_BranchOfBank
AS INT
   START WITH 1
   INCREMENT BY 1
   MINVALUE 1
   MAXVALUE 1000
   NO CYCLE
   Cache 10;
GO




    --======Create View, View With Schemabainding and ENCRYPTION=====
--================================================================--

        --======Create View======--
CREATE VIEW vw_BalanceDetail
AS
	(
	SELECT D.AccountNumber, ClienFirstName, BeiginingBalance, DepositBalance, WitdrawAmount, EndingBalance
	FROM csa.Deposit AS D
	JOIN csa.Withdraw  AS W
	ON D.AccountNumber = W.AccountNumber
	JOIN csa.Clien AS C
	ON C.ClienID= D.ClienID
	);
GO

SELECT * FROM vw_BalanceDetail
GO


   --===View With Encryption====--
CREATE VIEW vw_Balance
WITH SCHEMABINDING
AS
(
	SELECT D.AccountNumber, BeiginingBalance, DepositBalance, WitdrawAmount, EndingBalance
	FROM csa.Deposit AS D
	JOIN csa.Withdraw  AS W
	ON D.AccountNumber = W.AccountNumber
	);
GO


   --===View With Encryption====--
CREATE VIEW vw_Clien
WITH ENCRYPTION
AS
(
  SELECT ClienFirstName,ClienLastName, ClienAddress, ClienPhoneNo
  FROM csa.Clien
);
GO


--=====Create Store Procedure And Sproc With Commit,Rollbac,Try,Catch=====-
--==========================================================================--

--====Create Store Procedure=====--
CREATE PROC sp_CrudOperationAA
@branchID INT,
@branchName VARCHAR(30),
@branchEmail VARCHAR(40),
@branchPhoneNo VARCHAR(15),

@clienID INT,
@clienFirstName VARCHAR(15),
@clienLastName NVARCHAR(10),
@clienAddress VARCHAR(40),
@clienPhoneNo VARCHAR(15),
@cbranchID INT,

@tablename varchar(25),
@operationname varchar(20)

AS
BEGIN
	IF (@tablename = 'BranchOfBank' AND @operationname = 'INSERT')
		BEGIN
			Insert INTO csa.BranchOfBank values(@branchName, @branchEmail, @branchPhoneNo)
		END
	IF (@tablename = 'BranchOfBank' AND @operationname = 'UPDATE')
		BEGIN
			UPDATE csa.BranchOfBank  SET BranchName = @branchName, BranchEmail = @branchEmail, 
									   	 BranchPhoneNo = @branchPhoneNo WHERE BranchID=BranchID
		END
	IF (@tablename = 'BranchOfBank' AND @operationname = 'DELETE')
		BEGIN
			DELETE FROM csa.BranchOfBank WHERE BranchID=BranchID
		END


	IF (@tablename = 'Clien' AND @operationname = 'INSERT')
		BEGIN
			Insert INTO csa.Clien values(@clienFirstName,@clienLastName,@clienAddress,@clienPhoneNo,@cbranchID)
		END
	IF (@tablename = 'Clien' AND @operationname = 'UPDATE')
		BEGIN
			UPDATE csa.Clien SET ClienFirstName = @clienFirstName, ClienLastName = @clienLastName,ClienAddress = @clienAddress,
					ClienPhoneNo = @clienPhoneNo, BranchID= @cbranchID WHERE ClienID=@clienID
		END
	IF (@tablename = 'Clien' AND @operationname = 'DELETE')
		BEGIN
			DELETE FROM csa.Clien WHERE ClienID=@clienID
		END
END
GO


--=====Store Procedure(Commit,Rollbac,Try,Catch)=====-
CREATE PROC sp_Withdraw
@withdrawID INT,
@witdrawAmount MONEY,
@accountNumber INT,
@message varchar(30) output	 
As
Begin
	Set Nocount On
	Begin Try
		Begin Transaction
			Insert Into csa.Withdraw(WithdrawID, WitdrawAmount, AccountNumber)
			values (@withdrawID,@witdrawAmount,@accountNumber)
			set @message='Data Inserted Successfully'
			print @message
		Commit Transaction	
	End Try
	Begin Catch
		Rollback transaction	
		Print 'Something goes wrong'
	End Catch
End
GO


--==========Create table For Trigger==========--
--===============================================--

USE ClienSavingAcc
CREATE TABLE csa.Branch_Audit
(
BranchID INT,
BranchName VARCHAR(30),
BranchEmail NVARCHAR(50),
BranchPhoneNo VARCHAR(15),
ActionName varchar(100),
ActionTime datetime
);
GO

--======CREATE AFTER TRIGGER FOR INSERT, UPDATE AND DELETE===--
--=======================================================--

    --=====For INSERT Trigger Operation========--
CREATE TRIGGER trg_AfterInsert ON csa.BranchOfBank
FOR INSERT
AS
DECLARE @branchID INT, @branchName VARCHAR(30),@branchEmail NVARCHAR(50),@branchPhoneNo VARCHAR(15),@actionName varchar(100)

SELECT @branchID = i.BranchID from inserted i
SELECT @branchName = i.BranchName from inserted i
SELECT @branchEmail = i.BranchEmail from inserted i
SELECT @branchPhoneNo = i.BranchPhoneNo from inserted i
SET @actionName = 'Inserted Record -- After Insert Trigger Fired'

INSERT INTO csa.Branch_Audit(BranchID, BranchName, BranchEmail, BranchPhoneNo, ActionName, ActionTime)
							VALUES(@branchID, @branchName, @branchEmail, @branchPhoneNo, @ActionName, GETDATE())
PRINT 'After Insert Trigger Fired!!!!'
GO


SELECT * FROM csa.BranchOfBank
SELECT * FROM  csa.Branch_Audit
GO

      --======For Update Trigger Operation======--
CREATE TRIGGER trg_AfterUpdate ON csa.BranchOfBank
FOR UPDATE
AS
DECLARE @branchID INT, @branchName VARCHAR(30),@branchEmail NVARCHAR(50),@branchPhoneNo VARCHAR(15),@actionName varchar(100)
SELECT @branchID = i.BranchID FROM inserted i
SELECT @branchName = i.BranchName FROM inserted i
SELECT @branchEmail = i.BranchEmail FROM inserted i
SELECT @branchPhoneNo = i.BranchPhoneNo FROM inserted i

IF UPDATE(BranchName)
	SET @ActionName = 'Update BranchName -- After Update Trigger Fired'
IF UPDATE(BranchEmail)
	SET @ActionName = 'Update BranchEmail -- After Update Trigger Fired'
IF UPDATE(BranchPhoneNo)
	SET @ActionName = 'Update BranchPhoneNo -- After Update Trigger Fired'

INSERT INTO csa.Branch_Audit(BranchID, BranchName, BranchEmail, BranchPhoneNo, ActionName, ActionTime)
						VALUES(@branchID, @branchName, @branchEmail, @branchPhoneNo, @ActionName, GETDATE())
PRINT 'After Update Trigger Fired!!!!'
GO


      --======For Delete Trigger Operation======--
CREATE TRIGGER trg_AfterDelete ON csa.BranchOfBank
FOR DELETE
AS
DECLARE @branchID INT, @branchName VARCHAR(30),@branchEmail NVARCHAR(50),@branchPhoneNo VARCHAR(15),@actionName varchar(100)
SELECT @branchID = i.BranchID FROM inserted i
SELECT @branchName = i.BranchName FROM inserted i
SELECT @branchEmail = i.BranchEmail FROM inserted i
SELECT @branchPhoneNo = i.BranchPhoneNo FROM inserted i
SET @actionName = 'Deleted -- After Delete Trigger Fired'
INSERT INTO csa.Branch_Audit(BranchID, BranchName, BranchEmail, BranchPhoneNo, ActionName, ActionTime)
						VALUES(@branchID, @branchName, @branchEmail, @branchPhoneNo, @ActionName, GETDATE())
PRINT 'After Deleted Trigger Fired!!!!'
GO


--======CREATE INSTEAD TRIGGER OF INSERT, UPDATE AND DELETE TRIGGER===--
--=====================================================================--

     --===Instread Of Insert Trigger Operation====--
CREATE TRIGGER trgInsteadOfInsert ON csa.BranchOfBank
INSTEAD OF INSERT
AS
DECLARE @branchID INT, @branchName VARCHAR(30),@branchEmail NVARCHAR(50),@branchPhoneNo VARCHAR(15),@actionName varchar(100)
SELECT @branchID = i.BranchID from inserted i
SELECT @branchName = i.BranchName from inserted i
SELECT @branchEmail = i.BranchEmail from inserted i
SELECT @branchPhoneNo = i.BranchPhoneNo from inserted i
SET @actionName = 'Inserted Record -- Instead Of Insert Trigger'

IF(@branchID >=99)
	RAISERROR('Cannot Insert where BranchID >= 99',16,1);
ELSE
	INSERT INTO csa.BranchOfBank(BranchName, BranchEmail, BranchPhoneNo)
	           VALUES(@branchName,@branchEmail,@branchPhoneNo)
	INSERT INTO csa.Branch_Audit(BranchID,BranchName,BranchEmail,BranchPhoneNo,ActionName,ActionTime) 
	           VALUES(@@identity,@branchName, @branchEmail, @branchPhoneNo,@ActionName,getdate());

PRINT 'Record Inserted -- Instead Of Insert Trigger.'
GO


     --===Instread Of Update Trigger Operation====--
CREATE TRIGGER trgInsteadOfUpdate ON csa.BranchOfBank
INSTEAD OF UPDATE
AS
DECLARE @branchID INT, @branchName VARCHAR(30),@branchEmail NVARCHAR(50),@branchPhoneNo VARCHAR(15),@actionName varchar(100)
SELECT @branchID = i.BranchID FROM inserted i
SELECT @branchName = i.BranchName FROM inserted i
SELECT @branchEmail = i.BranchEmail FROM inserted i
SELECT @branchPhoneNo = i.BranchPhoneNo FROM inserted i
SET @actionName = 'Instead of Update Trigger Fired !!!'

BEGIN
	UPDATE csa.BranchOfBank SET BranchName = @branchName, BranchEmail= @branchEmail, BranchPhoneNo= @branchPhoneNo
			WHERE BranchID=@branchID
	INSERT INTO csa.Branch_Audit(BranchID,BranchName,BranchEmail,BranchPhoneNo,ActionName,ActionTime)
	VALUES(@@IDENTITY, @branchName, @branchEmail, @branchPhoneNo, @actionName,getdate())

	PRINT 'Information updated Successfully '
END
GO


      --===Instread Of Delete Trigger Operation====--
CREATE TRIGGER trgInsteadOfDelete ON csa.BranchOfBank
INSTEAD OF DELETE
AS
DECLARE @branchID INT, @branchName VARCHAR(30),@branchEmail NVARCHAR(50),@branchPhoneNo VARCHAR(15),@actionName varchar(100)
SELECT @branchID = d.BranchID FROM Deleted d
SELECT @branchName = d.BranchName FROM Deleted d
SELECT @branchEmail = d.BranchEmail FROM Deleted d
SELECT @branchPhoneNo = d.BranchPhoneNo FROM Deleted d
SET @actionName = 'Instead of Delete Trigger Fired'

BEGIN
	BEGIN TRAN
	BEGIN
	DELETE FROM csa.BranchOfBank
	WHERE BranchID=@branchID

	INSERT INTO csa.Branch_Audit(BranchID,BranchName,BranchEmail,BranchPhoneNo,ActionName,ActionTime)
	VALUES(@@IDENTITY, @branchName, @branchEmail, @branchPhoneNo, @actionName,getdate())
	END
	COMMIT TRAN

	PRINT 'Information updated Successfully '
END
GO


 --===All the triggers can be enabled/disabled==--
 --=================================================--

    --====Disable Trigger===--
ALTER TABLE csa.BranchOfBank Disable TRIGGER ALL
GO
    --====Enable Trigger===--
ALTER TABLE csa.BranchOfBank ENABLE TRIGGER ALL
GO


 --===Create Local temporary Table and Global Temporary Table ==--
--===============================================================--

    --====Local temporary Table===---
CREATE Table #UpdateAcc
(
AccountNo Int primary key identity,
ClienFName Varchar(30),
ClienLName Varchar(30),
BranchName Varchar(30),
UpPhoneNo Varchar(30) Unique CHECK(UpPhoneNo Like '018%' Or UpPhoneNo Like '017%' Or UpPhoneNo Like '016%'),
);
GO

SELECT * FROM #UpdateAcc


    --===Global Temporary Table====--
Create table ##ClossAcc
(
ClossAccID int identity,
AccountNo int,
ClienFName Varchar(30),
ClienLName Varchar(30),
WendindBalance money
);
GO

SELECT * FROM ##ClossAcc
GO



