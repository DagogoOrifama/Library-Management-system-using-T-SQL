/*
* File: Dagogo_Orifama.sql
* Title: Design and Implementation of a Library Database Management System (LMS) using TSQL
* Author: Dagogo Orifama
* StudentID: @00704109
* Module: Advanced Databases
* -------------------------------------------------------------------------------
* *****************************************Description***************************
* -------------------------------------------------------------------------------
* This file contains the T-SQL implementaion of the LMS, this includes table creation, relationships between tables
* views, temporary tables, user-defined functions, triggers and stored procedures providing functionalies to the LMS.
* 
*/

-- Create Database
CREATE DATABASE LibraryManagementSystem;

--Connect to the Database
USE LibraryManagementSystem;

-- CREATE Address Table
CREATE TABLE Address (
    AddressID INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
    Address1 NVARCHAR(50)  NOT NULL,
    Address2 NVARCHAR(50)  NULL,
    City NVARCHAR(50)  NULL,
    Postcode NVARCHAR(15)  NOT NULL,
	CONSTRAINT UC_AddressPc UNIQUE (Address1, Postcode)
);

-- Create Author Table
CREATE TABLE Author (
    AuthorID INT IDENTITY NOT NULL PRIMARY KEY,
    FirstName NVARCHAR(50)  NOT NULL,
    MiddleName NVARCHAR(50)  NULL,
    LastName NVARCHAR(50)  NOT NULL
);

-- Create Category Table
CREATE TABLE Category (
    CategoryID INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
    CategoryName NVARCHAR(200)  NOT NULL
);

-- Create ItemType Table
CREATE TABLE ItemType (
    ItemTypeID INT  NOT NULL PRIMARY KEY,
    ItemTypeName NVARCHAR(50) UNIQUE  NOT NULL
);

-- Create Item Table
CREATE TABLE Item (
    ItemID INT  IDENTITY(1, 1) NOT NULL PRIMARY KEY,
    Title NVARCHAR(200)  NOT NULL,
    CategoryID INT  NOT NULL FOREIGN KEY (CategoryID)
	REFERENCES Category (CategoryID),
    ItemTypeID INT  NOT NULL FOREIGN KEY (ItemTypeID)
	REFERENCES ItemType (ItemTypeID)
);

-- Create Publisher Table
CREATE TABLE Publisher (
    PublisherID INT IDENTITY(1, 1)  NOT NULL PRIMARY KEY,
    PublisherName NVARCHAR(100) UNIQUE  NOT NULL
);

-- Create ItemStatus Table
CREATE TABLE ItemStatus (
    ItemStatusID INT  NOT NULL PRIMARY KEY,
    StatusName NVARCHAR(20)  NOT NULL
);

-- Create ItemCopy Table
CREATE TABLE ItemCopy (
    ItemCopyID INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
    PublicationYear INT  NOT NULL,
    ItemID INT  NOT NULL FOREIGN KEY (ItemID)
	REFERENCES Item (ItemID),
	ISBN INT NULL,
	DateAdded DATE NOT NULL,
	DateRemoved DATE NULL,
    PublisherID INT  NOT NULL FOREIGN KEY (PublisherID)
	REFERENCES Publisher (PublisherID),
	TotalCopy INT  NOT NULL,
    AvailableCopy INT NOT NULL,
	ItemStatusID INT NOT NULL FOREIGN KEY (ItemStatusID)
	REFERENCES ItemStatus (ItemStatusID)
);

-- Create MemberStatus Table
CREATE TABLE MemberStatus (
    MemberStatusID INT  NOT NULL PRIMARY KEY,
    StatusName NVARCHAR(20)  NOT NULL
);

--Create Member Table
CREATE TABLE Member (
    MemberID INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
    Title NVARCHAR(8)  NOT NULL,
    FirstName NVARCHAR(50)  NOT NULL,
    MiddleName NVARCHAR(50)  NULL,
    LastName NVARCHAR(50)  NOT NULL,
    DOB DATE  NOT NULL,
    Email NVARCHAR(50) NULL CHECK (Email LIKE '%_@_%._%'),
    Phone NVARCHAR(25)  NULL,
    AddressID INT  NOT NULL FOREIGN KEY (AddressID)
	REFERENCES Address (AddressID),
    MembershipStartDate DATE  NOT NULL,
    MembershipEndDate DATE  NULL,
    MemberStatusID INT  NOT NULL FOREIGN KEY (MemberStatusID)
	REFERENCES MemberStatus (MemberStatusID)
);

-- Create Loan Table
CREATE TABLE Loan (
    LoanID INT IDENTITY(1, 1) NOT NULL PRIMARY KEY ,
    ItemCopyID INT  NOT NULL FOREIGN KEY (ItemCopyID)
	REFERENCES ItemCopy (ItemCopyID),
    MemberID INT  NOT NULL FOREIGN KEY (MemberID)
	REFERENCES Member (MemberID),
    LoanDate DATE  NOT NULL,
    DueDate DATE  NOT NULL,
    ReturnDate DATE  NULL
);

-- Create Fine Table 
CREATE TABLE Fine (
    FineID INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
    MemberID INT  NOT NULL FOREIGN KEY (MemberID)
	REFERENCES Member (MemberID),
    LoanID INT  NOT NULL FOREIGN KEY (LoanID)
	REFERENCES Loan (LoanID),
    FineDate DATE  NOT NULL,
    FineAmount MONEY  NULL
);

-- Create ItemAuthor Table
CREATE TABLE ItemAuthor (
    ItemID INT  NOT NULL FOREIGN KEY (ItemID)
	REFERENCES Item (ItemID),
    AuthorID INT  NOT NULL FOREIGN KEY (AuthorID)
	REFERENCES Author (AuthorID)
);

-- Create Login Table
CREATE TABLE Login (
    LoginID INT IDENTITY(1, 1) NOT NULL PRIMARY KEY ,
    Username NVARCHAR(50)  UNIQUE NOT NULL,
    MemberID INT  NOT NULL FOREIGN KEY (MemberID)
	REFERENCES Member (MemberID),
    PasswordHash BINARY(64)  NOT NULL,
	PasswordSalt NVARCHAR(50)  NOT NULL
);

-- Create PaymentMethod Table
CREATE TABLE PaymentMethod (
    PaymentMethodID INT  NOT NULL PRIMARY KEY,
    MethodName NVARCHAR(15)  NOT NULL
);

-- Create Repayment Table
CREATE TABLE Repayment (
    RepaymentID INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
    MemberID INT  NOT NULL FOREIGN KEY (MemberID)
	REFERENCES Member (MemberID),
    PaymentDate DATETIME  NOT NULL,
    PaymentAmount MONEY  NOT NULL,
    PaymentMethodID INT  NOT NULL FOREIGN KEY (PaymentMethodID)
	REFERENCES PaymentMethod (PaymentMethodID)
);

-- Create ReservationStatus Table
CREATE TABLE ReservationStatus (
    ReservationStatusID INT  NOT NULL PRIMARY KEY,
    StatusName NVARCHAR(50)  NOT NULL
);

-- Ceate Reservation Table
CREATE TABLE Reservation (
    ReservationID INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
    ItemCopyID INT  NOT NULL FOREIGN KEY (ItemCopyID)
	REFERENCES ItemCopy (ItemCopyID),
    MemberID INT  NOT NULL FOREIGN KEY (MemberID)
	REFERENCES Member (MemberID),
    ReservationDate DATE  NOT NULL,
    ReservationStatusID INT  NOT NULL FOREIGN KEY (ReservationStatusID)
	REFERENCES ReservationStatus (ReservationStatusID)
);




--QUESTION 2A
--Stored procedure to search the Library catalogue for matching character strings by title
CREATE OR ALTER PROCEDURE uspSearchItems
	@SearchString NVARCHAR(100)
AS
BEGIN
	SET NOCOUNT ON;
	-- select the Item and ItemCopy table to return item details
	SELECT * FROM dbo.Item a 
	INNER JOIN dbo.ItemCopy b 
	ON a.ItemID = b.ItemID
	WHERE Title LIKE + '%' + @SearchString + '%'
	ORDER BY b.PublicationYear DESC;
END

--QUESTION 2B
-- Procedure to return a full list of all items currently on loan which have a due date of less
--than five days from the current date.
CREATE OR ALTER FUNCTION uf_LoanItemWithDuedate()
RETURNS TABLE
AS
RETURN(

	SELECT * FROM dbo.Loan
	WHERE DATEDIFF(DAY, GETDATE(), DueDate) <= 5
);

--QUESTION 2C
--A procedure to add new members to the Library
DROP PROCEDURE IF EXISTS uspAddNewMember;
CREATE PROCEDURE uspAddNewMember
	@Username NVARCHAR(50),
	@Password NVARCHAR(50),
	@Title NVARCHAR(8), 
	@FirstName NVARCHAR(50), 
	@MiddleName NVARCHAR(50) = NULL, 
	@LastName NVARCHAR(50), 
	@DOB DATE, 
	@Email NVARCHAR(50) = NULL, 
	@Phone NVARCHAR(25)  = NULL, 
	@Address1 NVARCHAR(50),
	@Address2 NVARCHAR(50) = NULL,
	@City NVARCHAR(50) = NULL,
	@Postcode NVARCHAR(15)
AS
BEGIN TRANSACTION
BEGIN TRY
	DECLARE @NewMemberID INT;
	DECLARE @AddressID INT;
	DECLARE @AddressCount INT = NULL;
	DECLARE @NewAddressID INT = NULL;
	--Generates the unique salt to be using for password encryption
	DECLARE @PasswordSalt NVARCHAR(50) = CONVERT(UNIQUEIDENTIFIER, CRYPT_GEN_RANDOM(32));
	--Encrypting the inputed member password and salt combination using the SHA2_512 encryption algorithm
	DECLARE @PasswordHash BINARY(64) = HASHBYTES('sha2_512', @Password + CAST(@PasswordSalt AS NVARCHAR(50)));
	
	--Check if the address is already on the Address table the get the AddressID
	SELECT @AddressID = AddressID FROM dbo.Address
	WHERE Address1 = @Address1 AND Postcode = @Postcode;

	SELECT @AddressCount = COUNT(AddressID) FROM dbo.Address 
			WHERE Address1 = @Address1 AND Postcode = @Postcode;

	-- new address record for the member
	IF @AddressCount = 1
	BEGIN
		-- Get the AddressID for the inserted record
		SET @NewAddressID = @AddressID;
	END
	ELSE
	BEGIN
		--Insert Member Address to Address Table
		INSERT INTO dbo.Address (Address1, Address2, City, Postcode)
		VALUES (@Address1, @Address2, @City, @Postcode);

		-- Get the AddressID for the inserted record
		SET @NewAddressID = @@IDENTITY;
	END

	-- Insert Member details with above @AddressID into the Member table
	INSERT INTO dbo.Member (Title, FirstName, MiddleName, LastName, DOB, Email, Phone,
				AddressID, MembershipStartDate, MembershipEndDate, MemberStatusID)
	VALUES (@Title, @FirstName, @MiddleName, @LastName, @DOB, @Email, @Phone, 
			@NewAddressID, CONVERT(DATE,GETDATE()), NULL, 1)
	
	-- Get the MemberID for the inserted record
	SET @NewMemberID = @@IDENTITY;

	--insert Member Login details to Login Table
	INSERT INTO dbo.Login (Username, MemberID, PasswordHash, PasswordSalt)
	VALUES(@Username, @NewMemberID, @PasswordHash, @PasswordSalt);
	
COMMIT TRANSACTION
END TRY
BEGIN CATCH
	-- There was an error
	IF @@TRANCOUNT > 0
	ROLLBACK TRANSACTION
	DECLARE @ErrMsg nvarchar(4000), @ErrSeverity int
	SELECT @ErrMsg = ERROR_MESSAGE(), @ErrSeverity =
	ERROR_SEVERITY()
	RAISERROR(@ErrMsg, @ErrSeverity, 1)
END CATCH

--QUESTION 2D
--A procedure to update details of existing members in the Library 
CREATE OR ALTER PROCEDURE uspUpdateExistingMember
	@Username NVARCHAR(50),
	@Password NVARCHAR(50) = NULL,
	@Title NVARCHAR(8) = NULL, 
	@FirstName NVARCHAR(50) = NULL, 
	@MiddleName NVARCHAR(50) = NULL, 
	@LastName NVARCHAR(50) = NULL, 
	@DOB DATE = NULL,
	@Email NVARCHAR(50) = NULL, 
	@Phone NVARCHAR(25) = NULL, 
	@MembershipEndDate DATE = NULL, 
	@MemberStatusID INT = NULL,
	@Address1 NVARCHAR(50) = NULL,
	@Address2 NVARCHAR(50) = NULL,
	@City NVARCHAR(50) = NULL,
	@Postcode NVARCHAR(15) = NULL
	--@AddressCount INT OUTPUT,
	--@NewAddressID INT OUTPUT
AS
BEGIN TRANSACTION
BEGIN TRY
	DECLARE @MemberID INT = NULL;
	DECLARE @AddressID INT = NULL;
	DECLARE @AddressCount INT = NULL;
	DECLARE @NewAddressID INT = NULL;
	DECLARE @MemExist INT = NULL;
	--Generates the unique salt to be using for password encryption
	DECLARE @PasswordSalt NVARCHAR(50) = CONVERT(UNIQUEIDENTIFIER, CRYPT_GEN_RANDOM(32));
	--Encrypting the inputed member password and salt combination using the SHA2_512 encryption algorithm
	DECLARE @PasswordHash BINARY(64) = HASHBYTES('sha2_512', @Password + CAST(@PasswordSalt AS NVARCHAR(50)));
		
	--Retrive MemberID from the Table
	SELECT @MemberID = MemberID  FROM dbo.Member 
	WHERE MemberID = (SELECT MemberID FROM dbo.Login WHERE Username = @Username)

	-- CHECK if the member exists by checking if the MemberID appears once in the Member table
	SELECT @MemExist = COUNT(MemberID) FROM dbo.Member WHERE MemberID = @MemberID;
	IF @MemExist = 1
	BEGIN
		-- Checks if the address of the member was also specified to be updated
		IF @Address1 IS NOT NULL AND @Postcode IS NOT NULL
		BEGIN
			--Retrive AddressID of the member from the Address Table
			SELECT @AddressID = AddressID FROM dbo.Address
			WHERE AddressID = (SELECT AddressID FROM dbo.Member WHERE MemberID = @MemberID)

			-- Check the number of persons with the same address in the member table
			SELECT @AddressCount = COUNT(AddressID) FROM dbo.Member 
			WHERE AddressID = @AddressID

			-- If the address exit more than once on the members table, then we insert a 
			-- new address record for the member
			IF @AddressCount > 1
			BEGIN
				--insert a new address record into the address table
				INSERT INTO dbo.Address (Address1, Address2, City, Postcode)
				VALUES (@Address1, @Address2, @City, @Postcode);

				-- Get the AddressID for the inserted record
				SET @NewAddressID = @@IDENTITY;
			END
			ELSE
			BEGIN
				-- If the address exits just once on the members table
				--UPDATE existing address record
				UPDATE dbo.Address 
				SET Address1 = @Address1,
					Address2 = @Address2, 
					City = @City,
					Postcode =  @Postcode
				WHERE AddressID = @AddressID;

				-- Set @NewAddressID to zero since no new record was inserted
				SET @NewAddressID = 0;
			END
		END
		-- Insert Member details with above @AddressID into the Member table
		UPDATE dbo.Member 
		SET Title = CASE WHEN @Title IS NOT NULL THEN @Title ELSE Title END, 
			FirstName = CASE WHEN @FirstName IS NOT NULL THEN @FirstName ELSE FirstName END, 
			MiddleName = CASE WHEN @MiddleName IS NOT NULL THEN @MiddleName ELSE MiddleName END, 
			LastName = CASE WHEN @LastName IS NOT NULL THEN @LastName ELSE LastName END, 
			DOB = CASE WHEN @DOB IS NOT NULL THEN @DOB ELSE DOB END,
			Email = CASE WHEN @Email IS NOT NULL THEN @Email ELSE Email END, 
			Phone = CASE WHEN @Phone IS NOT NULL THEN @Phone ELSE Phone END,
			AddressID = CASE WHEN @AddressCount > 1 THEN @NewAddressID 
						ELSE AddressID END, 
		    MembershipEndDate = CASE WHEN @MembershipEndDate IS NOT NULL THEN @MembershipEndDate ELSE MembershipEndDate END, 
			MemberStatusID = CASE WHEN @MemberStatusID IS NOT NULL THEN @MemberStatusID ELSE MemberStatusID END
		WHERE MemberID = @MemberID;

		-- Update the member password credentials on the Login Table
		UPDATE dbo.Login
		SET PasswordHash = CASE WHEN @Password IS NOT NULL THEN @PasswordHash ELSE PasswordHash END, 
			PasswordSalt = CASE WHEN @Password IS NOT NULL THEN @PasswordSalt ELSE PasswordSalt END
		WHERE MemberID = @MemberID;
	END
COMMIT TRANSACTION
END TRY
BEGIN CATCH
	-- There was an error
	IF @@TRANCOUNT > 0
	ROLLBACK TRANSACTION
	DECLARE @ErrMsg nvarchar(4000), @ErrSeverity int
	SELECT @ErrMsg = ERROR_MESSAGE(), @ErrSeverity =
	ERROR_SEVERITY()
	RAISERROR(@ErrMsg, @ErrSeverity, 1)
END CATCH

-- QUESTION 3
-- A view of the previous and current loan history, with their respective
-- item and fine details
--Check if the view exist if it does delete it
IF OBJECT_ID('LoanHistoryView', 'V') IS NOT NULL
	DROP VIEW LoanHistoryView;
CREATE OR ALTER VIEW LoanHistoryView (LoanID, ItemCopyID, ItemTitle, PublicationYear, ISBN, ItemAddedDate,
MemberID, FineAmount, LoanDate, DueDate, ReturnDate)
AS
SELECT ln.LoanID, ic.ItemCopyID, it.Title, ic.PublicationYear, ic.ISBN, ic.DateAdded, 
ln.MemberID, fi.FineAmount, ln.LoanDate, ln.DueDate, ln.ReturnDate
FROM dbo.Fine fi RIGHT JOIN dbo.Loan ln  
ON fi.LoanID = ln.LoanID INNER JOIN dbo.ItemCopy ic
ON ln.ItemCopyID = ic.ItemCopyID INNER JOIN dbo.Item it
ON ic.ItemID = it.ItemID;

-- QUESTION 4
/*
Trigger that updates the current status of an item automatically updates to
'Available' when the book is returned.
*/
DROP TRIGGER IF EXISTS UpdateItemStatus;
CREATE TRIGGER UpdateItemStatus
ON dbo.Loan
AFTER UPDATE
AS
BEGIN
	IF UPDATE(ReturnDate)
	BEGIN
		UPDATE dbo.ItemCopy
		--Even if book is loan, the TotalCopy value should not change
		--checks if the 
		SET ItemStatusID = CASE WHEN (ItemStatusID = 2 AND  TotalCopy > 0) 
						   THEN 1 ELSE ItemStatusID END,
			AvailableCopy = CASE WHEN (ItemStatusID = 2 AND  TotalCopy > 0) 
						    THEN AvailableCopy + 1 ELSE AvailableCopy END
		FROM dbo.ItemCopy
		INNER JOIN INSERTED ON dbo.ItemCopy.ItemCopyID = INSERTED.ItemCopyID
		INNER JOIN DELETED ON dbo.ItemCopy.ItemCopyID = DELETED.ItemCopyID
		WHERE INSERTED.ReturnDate IS NOT NULL
		AND INSERTED.ItemCopyID = DELETED.ItemCopyID
	END
END

--QUESTION 5
-- Function to get total number of Loans given on a particular date
CREATE OR ALTER FUNCTION uf_GetTotalNumberOfLoanByDate (@LoanDate DATE)
RETURNS TABLE
AS
RETURN
(
	SELECT @LoanDate AS SpecifiedDate, COUNT(LoanID) AS TotalLoans
	FROM dbo.loan 
	WHERE LoanDate = @LoanDate
)


----------------------------------------------------------------Extra Question 1------------------------------------------------------------------
-- A temporary table to show a list of inactive members
DROP TABLE IF EXISTS #InactiveMember;
CREATE TABLE #InactiveMember(
    MemberID INT NOT NULL PRIMARY KEY,
    Title NVARCHAR(8)  NOT NULL,
    FirstName NVARCHAR(50)  NOT NULL,
    MiddleName NVARCHAR(50)  NULL,
    LastName NVARCHAR(50)  NOT NULL,
    DOB DATE  NOT NULL,
    Email NVARCHAR(50) NULL ,
    Phone NVARCHAR(25)  NULL,
    AddressID INT  NOT NULL ,
    MembershipStartDate DATE  NOT NULL,
    MembershipEndDate DATE  NULL,
    MemberStatusID INT  NOT NULL 
);
-- A trigger that triggers on update when a member's status is inactive and MembershipEndDate is updated
DROP TRIGGER IF EXISTS GetInactiveMember;
CREATE TRIGGER GetInactiveMember
ON dbo.Member
AFTER UPDATE
AS
BEGIN
	IF UPDATE(MembershipEndDate)
	BEGIN
		INSERT INTO #InactiveMember(MemberID, Title, FirstName, MiddleName, LastName, DOB, Email, Phone,
						AddressID, MembershipStartDate, MembershipEndDate, MemberStatusID)
		SELECT * FROM dbo.Member WHERE MemberID = (SELECT MemberID 
													FROM INSERTED 
													WHERE MembershipEndDate IS NOT NULL AND MemberStatusID = 2)
	END
END

----------------------------------------------------------------Extra Question 2------------------------------------------------------------------
--A Table-valued function to show list of Items which are lost or removed
-- from the library, If Item is a book ISBN is added
DROP FUNCTION IF EXISTS uf_LostRemovedItem;
CREATE FUNCTION uf_LostRemovedItem()
RETURNS @LostRemovedItemView TABLE
(
	ItemID INT, 
	ISBN INT, 
	DateRemoved DATE
)
AS
BEGIN
	INSERT INTO @LostRemovedItemView (ItemID, ISBN, DateRemoved)
	SELECT ItemID, 
			CASE WHEN ISBN IS NOT NULL THEN ISBN ELSE NULL END,
			DateRemoved
	FROM dbo.ItemCopy 
	WHERE ItemStatusID = 4 OR ItemStatusID = 5 
	RETURN
END

----------------------------------------------------------------Extra Question 3------------------------------------------------------------------
-- Procedure to add a Repayment
DROP PROCEDURE IF EXISTS uspAddNewPayment;
CREATE PROCEDURE uspAddNewPayment
	@PublicationYear INT,
	@ISBN INT = NULL,	
	@ItemTitle NVARCHAR(50),
	@ItemTypeName NVARCHAR(15),
	@MemberUsername NVARCHAR(50),
	@PaymentAmount MONEY,
	@PaymentMethod NVARCHAR(15)

AS
BEGIN TRANSACTION
BEGIN TRY
	DECLARE @FineAmount INT;
	DECLARE @MemberID INT;
	DECLARE @PaymentDate DATE;
	DECLARE @PaymentMethodID INT;
	DECLARE @LoanID INT;
	DECLARE @ItemCopyID INT;
	

	--Get the Member details from the Login table
	SELECT  @MemberID = MemberID FROM dbo.Login WHERE Username = @MemberUsername

	-- Get the payment method ID
	SELECT @PaymentMethodID = PaymentMethodID FROM dbo.PaymentMethod WHERE MethodName = @PaymentMethod
	
	--Set loan Date as current date
	SET @PaymentDate = GETDATE() 

	--Check the Item Type then get item details
	SELECT  @ItemTypeName = ItemTypeName FROM dbo.ItemType WHERE ItemTypeName = @ItemTypeName
	IF @ItemTypeName = 'Book'
	BEGIN
		--If item is a book get the Item detail USING the ISBN
		SELECT  @ItemCopyID = ItemCopyID 
		FROM dbo.ItemCopy WHERE ISBN = @ISBN
	END
	ELSE
	BEGIN
		--If item is not a book get the Item detail USING the item title and publication year
		SELECT  @ItemCopyID = ic.ItemCopyID 
		FROM dbo.ItemCopy ic INNER JOIN dbo.Item i
		ON ic.ItemID = i.ItemID
		WHERE i.Title = @ItemTitle AND ic.PublicationYear = @PublicationYear
	END
	
	-- Get loanID from the Loan that has a fine in the fine table
	SELECT @LoanID = ln.LoanID FROM dbo.Fine fi
	INNER JOIN dbo.Loan ln
	ON fi.LoanID = ln.LoanID WHERE fi.MemberID = @MemberID 

	--Insert New Repayment Details
	INSERT INTO dbo.Repayment(MemberID, PaymentDate, PaymentAmount, PaymentMethodID)
	VALUES (@MemberID, @PaymentDate, @PaymentAmount, @PaymentMethodID);

	-- if insert statement was successful then update the Fine by reducing FineAmount by PaymentAmount
	if @@ROWCOUNT > 0
	BEGIN
		UPDATE dbo.Fine
		SET FineAmount = FineAmount - @PaymentAmount
		WHERE FineID = (SELECT FineID FROM dbo.Fine WHERE LoanID = @LoanID)
		
		PRINT 'Payment record was added successfully';
	END
	ELSE
	BEGIN
		PRINT 'Payment Insertion Failed';
	END

COMMIT TRANSACTION
END TRY
BEGIN CATCH
	-- There was an error
	IF @@TRANCOUNT > 0
	ROLLBACK TRANSACTION
	DECLARE @ErrMsg nvarchar(4000), @ErrSeverity int
	SELECT @ErrMsg = ERROR_MESSAGE(), @ErrSeverity =
	ERROR_SEVERITY()
	RAISERROR(@ErrMsg, @ErrSeverity, 1)
END CATCH

----------------------------------------------------------------Extra Question 4------------------------------------------------------------------
--Procedure to add a loan
DROP PROCEDURE IF EXISTS uspAddNewLoan;
CREATE PROCEDURE uspAddNewLoan
	@ItemTitle NVARCHAR(50),
	@ItemTypeName NVARCHAR(15),
	@PublicationYear INT,
	@ISBN INT = NULL,
	@MemberUsername NVARCHAR(50),
	@LoanDate DATE = NULL,
	@DueDate DATE = NULL
AS
BEGIN TRANSACTION
BEGIN TRY
	DECLARE @ItemCopyID INT;
	DECLARE @MemberID INT;
	

	--Get the Member details from the Login table
	SELECT  @MemberID = MemberID FROM dbo.Login WHERE Username = @MemberUsername

	--Check the Item Type then get item details
	SELECT  @ItemTypeName = ItemTypeName FROM dbo.ItemType WHERE ItemTypeName = @ItemTypeName
	IF @ItemTypeName = 'Book'
	BEGIN
		--If item is a book get the Item detail USING the ISBN
		SELECT  @ItemCopyID = ItemCopyID 
		FROM dbo.ItemCopy WHERE ISBN = @ISBN
	END
	ELSE
	BEGIN
		--If item is not a book get the Item detail USING the item title and publication year
		SELECT  @ItemCopyID = ic.ItemCopyID 
		FROM dbo.ItemCopy ic INNER JOIN dbo.Item i
		ON ic.ItemID = i.ItemID 
		WHERE i.Title = @ItemTitle AND ic.PublicationYear = @PublicationYear
	END
	--Set loan Date as current date
	SET @LoanDate = CONVERT(DATE,GETDATE()) 
	-- set due date as 7days from current date
	SET @DueDate = CONVERT(DATE, DATEADD(DAY, 7, GETDATE()))

	--Insert New Loan Details
	INSERT INTO dbo.Loan(ItemCopyID, MemberID, LoanDate, DueDate)
	VALUES (@ItemCopyID, @MemberID, @LoanDate, @DueDate);

	-- if sert statement was successful the update the ItemCopy by reducing AvailableCopy by 1
	if @@ROWCOUNT > 0
	BEGIN
		UPDATE dbo.ItemCopy
		SET AvailableCopy = AvailableCopy - 1
		WHERE ItemCopyID = @ItemCopyID
		
		PRINT 'Library Item was added successfully';
	END
	ELSE
	BEGIN
		PRINT 'Item Insertion Failed';
	END

COMMIT TRANSACTION
END TRY
BEGIN CATCH
	-- There was an error
	IF @@TRANCOUNT > 0
	ROLLBACK TRANSACTION
	DECLARE @ErrMsg nvarchar(4000), @ErrSeverity int
	SELECT @ErrMsg = ERROR_MESSAGE(), @ErrSeverity =
	ERROR_SEVERITY()
	RAISERROR(@ErrMsg, @ErrSeverity, 1)
END CATCH

-- **********************************************Procedure to  calculate overdue fine when an item is overdue******************************************
CREATE OR ALTER PROCEDURE uspCalculateFineDaily
AS
BEGIN
	DECLARE @CheckDayDiff INT;
	DECLARE @DayDiff INT;
	DECLARE @MemberID INT;
	DECLARE @CountMemberID INT;
	DECLARE @CalculateFine INT;
	DECLARE @LoanID INT;
	

	SELECT @CheckDayDiff = DATEDIFF(DAY, GETDATE(), DueDate), @LoanID = LoanID FROM dbo.Loan
	IF @CheckDayDiff <= 0 
	BEGIN
		SELECT @CalculateFine = DATEDIFF(DAY, DueDate, GETDATE())* 0.1, @MemberID = MemberID FROM dbo.Loan
		SELECT @CountMemberID = COUNT(MemberID) FROM dbo.Fine WHERE MemberID = @MemberID
		IF @CountMemberID > 0
		BEGIN
			UPDATE dbo.Fine
			SET FineAmount = @CalculateFine
			WHERE MemberID = @MemberID
		END
		ELSE
		BEGIN
			INSERT INTO dbo.Fine (MemberID, LoanID, FineDate, FineAmount)
			VALUES (@MemberID, @LoanID, CONVERT(DATE,GETDATE()), 0.1)
		END
	END
END

------------------------------------------------------------------ACCESS and SECUTITY------------------------------------------------------------------
-- Create login with the password specified
CREATE LOGIN LMS_LOGIN WITH PASSWORD = 'Wisdo@179!dg';
GO

-- Create user for LMS_LOGIN login
CREATE USER CHRISDANIEL FOR LOGIN LMS_LOGIN;
GO

-- Grant connect permission to the user CHRISDANIEL
GRANT CONNECT TO CHRISDANIEL;
GO

--Grant CHRISDANIEL SELECT permissions on the tables, functions, stored procedures and views within the schema dbo schemaGRANT SELECT ON SCHEMA :: dbo TO CHRISDANIEL;
GO

-- Create login with the password specified for another user
CREATE LOGIN LMS_LOGIN_ADMIN WITH PASSWORD = '@@3efsdo@179!dg';
GO

-- Create another user for LMS_LOGIN login
CREATE USER LMS_ADMIN FOR LOGIN LMS_LOGIN_ADMIN;
GO

-- Grant connect permission to the user LMS_ADMIN
GRANT CONNECT TO LMS_ADMIN;
GO

-- Grant library admin insert, select and update permission with the option to grant these privileges to other users. 
GRANT SELECT, INSERT, UPDATE ON SCHEMA :: dbo TO LMS_ADMIN WITH GRANT OPTION;
GO


-- *********************************************************Inserting Values into the various table*****************************************************
-- Inserting Values into address table
INSERT INTO dbo.Address (Address1, Address2, City, Postcode)
VALUES ('26910 Indela Road', NULL, 'Montreal', 'H1Y 2H5'),
		('2681 Eagle Peak', NULL, 'Bellevue', '98004'),
		('7943 Walnut Ave', NULL, 'Renton', '98055'),
		('6388 Lake City Way', NULL, 'Burnaby', 'V5A 3A6'),
		('25 Danger Street West', 'Floor 7', 'Toronto', 'M4B 1V5'),
		('800 Interchange Blvd.', 'Suite 2501', 'Austin', '78701'),
		('90025 Sterling St', NULL, 'Irving', '75061'),
		('One Dancing, Rr No. 25', 'Box 8033', 'Round Rock', '78664'),
		('9995 West Central Entrance', NULL, 'Duluth', '55802'),
		('Science Park South, Birchwood', 'Stanford House', 'Warrington', 'WA3 7BH');


-- Inserting Values into Author table
INSERT INTO dbo.Author(FirstName, MiddleName, LastName)
VALUES  ('Natalee', 'Madelon', 'Nuzzi'),
		 ('Michaella', null, 'Coverdill'),
		 ('Cori', null, 'Itzkin'),
		 ('Jennifer', 'Esteban', 'Peetermann'),
		 ('Filberto', 'Flint', 'Wreiford'),
		 ('Ardene', null, 'Hackin'),
		 ('Cami', null, 'Pont'),
		 ('Florette', 'Rozella', 'Brazier'),
		 ('Myca', 'Von', 'Timlett'),
		 ('Devan', null, 'Merman'),
		 ('Wilhelmina', 'Jeno', 'Goucher'),
		 ('Richy', 'Linet', 'Rotherham'),
		 ('Kati', null, 'Carabet'),
		 ('Fonz', null, 'Lochet'),
		 ('Rem', 'Nanny', 'Nast');

-- Inserting Values into Category table
INSERT INTO dbo.Category(CategoryName)
VALUES  ('Engineering'),('Project Management'),('Sciences'),('Art and Culture'),
		 ('Marketing'), ('Accounting'), ('Business Administration'), ('Law'),
		 ('Nursing'), ('Medicine');

-- Insert data into into ItemType Table
INSERT INTO dbo.ItemType (ItemTypeID, ItemTypeName)
VALUES  (1, 'Book'),
		(2, 'Journal'),
		(3, 'DVD'),
		(4, 'Other Media');

-- Insert data into into Item Table
INSERT INTO dbo.Item (Title, CategoryID, ItemTypeID)
VALUES ('Introduction to Engineering', 1, 1),
		('The Analysis of Advance Arts', 4, 2),
		('Advance Visualization with Panda', 3, 1),
		('Agriculatural Tractors and Repairs', 1, 4),
		('Thermodynamics Simplified', 1, 3),
		('Surgery For Dummy', 10, 1),
		('Advanced Mathematics', 2, 1),
		('Understanding management accounting practices', 6, 2),
		('Judicial Law and Practices', 8, 1),
		('Nursing Practices and Medical Philosophies', 9, 3),
		('Civil Enginering Drawing Series', 1, 3),
		('Dynamic Marketing for Organizational Growth', 5, 2),
		('Project Management Mastery', 2, 1),
		('Introduction to Business Admistration', 7, 1),
		('Crime Detection Series', 8, 4),
		('Cultural Studies in the 21st Century', 4, 2),
		('Organic Chemistry', 2, 1),
		('Advanced Accounting Solutions', 6, 4),
		('Machine Learning Algorithm Simplified', 3, 3),
		('Medical Operations for Dummy', 10, 1);

-- Insert data into into Publisher Table
INSERT INTO dbo.Publisher(PublisherName)
VALUES  ('Harper Collins'),('Dagoris Solutions'),('Simon & Schuster'),('Penguin Random House'),
		('Macmillan'),('Dummies Publishing'),('David Fickling Books'),('Joffe Books'),
		('Severn House'),('McGraw Hill');

-- Insert data into into ItemStatus Table
INSERT INTO dbo.ItemStatus(ItemStatusID, StatusName)
VALUES  (1, 'Available'),
		(2, 'On Loan'),
		(3, 'Overdue'),
		(4, 'Removed'),
		(5, 'Lost');


-- Insert data into into ItemCopy Table
INSERT INTO ItemCopy (PublicationYear, ItemID, ISBN, DateAdded, DateRemoved, PublisherID, TotalCopy, AvailableCopy, ItemStatusID)
VALUES (1978, 1, '031702729', '2020-11-15', null, 1, 2, 2, 1),
		(2007, 2, null, '2008-07-18', null, 1, 1, 0, 1),
		(2011, 3, '137758222', '2015-11-23', null, 5, 1, 0, 1),
		(2011, 4, null, '2016-12-18', null, 10, 3, 3, 1),
		(2011, 5, null, '2009-03-11', null, 5, 2, 2, 1),
		(2011, 6, '286148649', '2018-11-15', null, 7, 1, 0, 1),
		(1998, 7, '682388716', '2019-03-26', null, 2, 3, 3, 1),
		(2003, 8, null, '2019-10-04', null, 8, 3, 3, 1),
		(1973, 9, '348236291', '2017-04-11', null, 9, 1, 1, 1),
		(2006, 10, null, '2022-04-18', null, 3, 3, 3, 1),
		(1996, 11, null, '2016-12-15', null, 3, 2, 2, 1),
		(2003, 12, null, '2018-02-22', null, 7, 1, 1, 1),
		(2003, 13, '208702353', '2016-03-28', null, 3, 1, 1, 1),
		(1997, 14, '315363760', '2016-03-27', null, 1, 2, 2, 1),
		(1993, 15, null, '2019-11-07', null, 10, 2, 2, 1),
		(2001, 16, null, '2021-09-26', null, 5, 3, 3, 1),
		(1995, 17, '617826923', '2019-08-26', null, 1, 1, 1, 1),
		(1995, 18, null, '2019-05-19', null, 7, 3, 3, 1),
		(1984, 19, null, '2018-04-20', null, 6, 1, 1, 1),
		(1993, 20, '886324376', '2021-06-15', null, 4, 1, 1, 1),
		(2013, 2, null, '2014-01-18', null, 1, 1, 1, 1),
		(2022, 5, null, '2022-11-11', null, 5, 2, 2, 1),
		(2014, 9, '348236456', '2015-02-11', null, 3, 1, 0, 1),
		(2013, 7, '682388932', '2021-03-16', null, 10, 3, 3, 1),
		(2011, 3, '137758333', '2015-11-23', null, 10, 1, 1, 1);

-- Insert data into into MemberStatus Table
INSERT INTO dbo.MemberStatus (MemberStatusID, StatusName)
VALUES  (1, 'Active'),
		(2, 'Inactive');
		
-- Insert data into into MemberStatus Table
INSERT INTO dbo.Member (Title, FirstName, MiddleName, LastName, DOB, Email, Phone,
AddressID, MembershipStartDate, MembershipEndDate, MemberStatusID)
VALUES  ('Mr', 'Toma', 'Nina', 'Neicho', '1988-07-24', 'nneicho0@delicious.com', '2349377398', 1, '2009-12-31', '2013-12-01', 1),
		 ('Ms', 'Keene', 'Frans', 'McCleod', '1988-06-21', null, '4627888357', 2, '2018-11-13', '2013-01-27', 1),
		 ('Mr', 'Florie', 'Bambi', 'Quinby', '1978-07-22', 'bquinby2@over-blog.com', null, 3, '2016-10-18', '2019-09-05', 1),
		 ('Dr', 'Katie', null, 'Peddowe', '1990-11-08', 'rpeddowe3@163.com', null, 4, '2011-06-08', '2015-01-15', 2),
		 ('Mrs', 'Rivkah', 'Rey', 'Adolthine', '1977-04-10', 'radolthine4@europa.eu', '9169303399', 5, '2010-09-04', '2019-12-30', 1),
		 ('Dr', 'Pernell', null, 'Girardy', '1977-07-21', 'sgirardy5@cdbaby.com', null, 6, '2008-12-11', '2016-04-08', 1),
		 ('Ms', 'Nelli', 'Laurie', 'Willans', '1979-04-29', 'lwillans6@disqus.com', '1585263623', 7, '2008-10-03', '2017-03-22', 2),
		 ('Mr', 'Brynn', 'Verine', 'Stean', '1992-04-18', null, '1475972252', 8, '2022-04-28', '2018-06-21', 1),
		 ('Dr', 'Emiline', 'Anica', 'Struijs', '1970-04-12', 'astruijs8@cargocollective.com', '4693450079', 9, '2019-08-30', '2016-06-26', 1),
		 ('Mrs', 'Konrad', null, 'Urion', '1997-05-15', 'murion9@abc.net.au', null, 10, '2013-11-25', '2019-07-15', 1),
		 ('Dr', 'Lucina', null, 'McFayden', '1973-05-29', 'amcfaydena@cmu.edu', '3122833575', 1, '2017-03-24', '2019-09-03', 1),
		 ('Mr', 'Dru', 'Raychel', 'Pitt', '1990-08-16', 'rpittb@bbc.co.uk', null, 3, '2022-09-05', '2014-01-03', 2),
		 ('Dr', 'Leslie', null, 'Lethlay', '1983-01-17', 'olethlayc@skype.com', null, 5, '2008-08-16', '2014-11-05', 1),
		 ('Mrs', 'Rosaline', null, 'Ricardo', '1994-01-07', 'ericardod@springer.com', '6541678582', 6, '2019-12-09', '2014-01-22', 1),
		 ('Mrs', 'Blakeley', 'Mercy', 'Stieger', '1994-07-16', 'mstiegere@sciencedirect.com', '7198397011', 2, '2016-04-20', '2016-03-06', 1),
		 ('Dr', 'Lettie', 'Reinaldos', 'Kepling', '1987-06-26', 'rkeplingf@symantec.com', '9644973166', 7, '2022-04-22', '2022-05-04', 2),
		 ('Ms', 'Hillery', null, 'Snazle', '1988-12-11', 'osnazleg@netvibes.com', null, 4, '2020-02-29', '2016-07-05', 1),
		 ('Ms', 'Alica', null, 'Cereceres', '1985-03-21', 'ccereceresh@4shared.com', '3582596763', 8, '2019-05-26', '2018-05-28', 1),
		 ('Mrs', 'Josefa', null, 'Pridding', '1996-05-20', null, null, 9, '2020-05-05', '2014-03-12', 1),
		 ('Mr', 'Janel', null, 'Merry', '1998-02-10', 'mmerryj@blogtalkradio.com', null, 3, '2008-05-31', '2023-04-03', 1);


-- Insert data into into Loan Table
INSERT INTO dbo.Loan (ItemCopyID, MemberID, LoanDate, DueDate, ReturnDate)
VALUES (2, 10, '2023-03-28', '2023-04-10', null),
		(3, 16, '2023-04-04', '2023-04-15', '2023-04-06'),
		(23, 12, '2023-03-20', '2023-04-01', null),
		(6, 15, '2023-04-01', '2023-04-08', null),
		(13, 18, '2023-04-02', '2023-04-17', null),
		(17, 10, '2023-04-30', '2023-05-05', null);

-- Insert data into into Fine Table
INSERT INTO dbo.Fine(MemberID, LoanID, FineDate, FineAmount)
VALUES (12, 3, '2023-04-02', 0.4);

-- Insert data into into ItemAuthor Table
INSERT INTO dbo.ItemAuthor(ItemID, AuthorID)
VALUES (1, 2), (2, 10), (3, 1), (4, 3), (5, 4), (6, 5), (7, 6), (8, 7), (9, 9), (10, 8), (11, 15), (12, 11),
		(12, 2), (14, 14), (15, 13), (16, 2), (17, 1), (18, 7), (19, 12), (20, 2), (2, 1), (5, 12), (12, 2);

-- Insert data into PaymentMethod Table
INSERT INTO dbo.PaymentMethod (PaymentMethodID, MethodName)
VALUES (1, 'Cash'), (2, 'Card');

-- Insert data into Repayment Table
INSERT INTO dbo.Repayment (MemberID, PaymentDate, PaymentAmount, PaymentMethodID)
VALUES (12, '2023-04-05', 0.2, 2);

-- Insert data into ReservationStatus Table
INSERT INTO dbo.ReservationStatus (ReservationStatusID, StatusName)
VALUES (1, 'Successful'), (2, 'Cancelled');

-- Insert data into Reservation Table
INSERT INTO Reservation (ItemCopyID, MemberID, ReservationDate, ReservationStatusID)
VALUES (10, 12, '2023-04-05', 1), (16, 14, '2023-04-05', 2);



/*
	INSERTING DATA INTO THE LOGIN TABLE
	The username, password for all users was made in the for FirstName_LastName
	The password was encrypted using the encryption algorithm, the password was made more secure by
	generating a random unique, combining it with the password. The SHA2_512 encryption algorithm
	was applied on the combined value to generate a secure password hash.

*/
INSERT INTO dbo.Login (Username, MemberID, PasswordHash, PasswordSalt)
SELECT  b.Username, a.MemberID, b.passwordHash, b.salt
FROM dbo.Member a
CROSS APPLY (
	SELECT CONCAT(a.FirstName,'_',a.LastName) AS Username,
	 HASHBYTES('SHA2_512', CONCAT(a.FirstName,'_', a.LastName) + CAST(CONVERT(UNIQUEIDENTIFIER, CRYPT_GEN_RANDOM(32)) AS NVARCHAR(50))) AS passwordHash,
	 CONVERT(UNIQUEIDENTIFIER, CRYPT_GEN_RANDOM(32)) AS salt
)b;


--************************************************************Testing the created functions, views, triggers and procedures*****************************

--*********************************************************Test the procedure in QUESTION 2A*******************************
EXEC uspSearchItems @SearchString = 'Advance';


--*********************************************************Testing the function in QUESTION 2B******************************
SELECT * FROM dbo.uf_LoanItemWithDuedate()

--*********************************************************Testing the procedure in QUESTION 2C*****************************
-- add new member without already existing address
EXEC uspAddNewMember
	@Username = 'Sandy345',
	@Password = 'werf@@zie',
	@Title = 'Mrs', 
	@FirstName = 'Sandra', 
	@LastName = 'Chimezie', 
	@DOB = '1990-04-23', 
	@Email = 'Sandy345@gmail.com', 
	@Phone = '0746811278', 
	@Address1 = '23 Iyana Ipaja Street',
	@City = 'Lagos',
	@Postcode = '705001'

-- Validate the result of the member insertion
SELECT ad.* FROM dbo.Address ad INNER JOIN dbo.Member mb
ON ad.AddressID = mb.AddressID INNER JOIN dbo.Login lg
ON mb.MemberID = lg.MemberID WHERE lg.Username = 'Sandy345'

SELECT * FROM dbo.Member WHERE Email = 'Sandy345@gmail.com'
SELECT * FROM dbo.Login WHERE Username = 'Sandy345'

-- add new member with already existing address
EXEC uspAddNewMember
	@Username = 'Promise671',
	@Password = 'Wer#fprom',
	@Title = 'Mr', 
	@FirstName = 'Promise', 
	@LastName = 'Johnson', 
	@DOB = '1998-02-12', 
	@Email = 'Promise671@gmail.com', 
	@Phone = '07468719021', 
	@Address1 = '23 Iyana Ipaja Street',
	@City = 'Lagos',
	@Postcode = '705001'

	-- Validate the result of the member insertion
SELECT ad.* FROM dbo.Address ad INNER JOIN dbo.Member mb
ON ad.AddressID = mb.AddressID INNER JOIN dbo.Login lg
ON mb.MemberID = lg.MemberID WHERE lg.Username = 'Promise671'

SELECT * FROM dbo.Member WHERE Email = 'Promise671@gmail.com'
SELECT * FROM dbo.Login WHERE Username = 'Promise671'


-- ******************************************Testing the procedure in QUESTION 2D*************************************
-- the address is not on the address table
EXEC uspUpdateExistingMember
	@Username = 'Promise671',
	@Password = 'Wer#fp345',
	@Title = 'Mr', 
	@FirstName = 'Promise', 
	@LastName = 'Johnson', 
	@DOB = '1998-02-05', 
	@Email = 'Promise671@gmail.com', 
	@Phone = '07468719021', 
	@Address1 = '50 Ikeja Ipaja Street',
	@City = 'Lagos',
	@Postcode = '705062'


-- Update memberid of 15 with addressid of 17
UPDATE dbo.Member
SET AddressID = 17
WHERE MemberID = 15

SELECT * FROM dbo.Member WHERE MemberID = 15
-- Update member
EXEC uspUpdateExistingMember
	@Username = 'Promise671',
	@Address1 = '150 Tourist Ipaja Street',
	@City = 'Lagos',
	@Postcode = '705221'

-- validate the updates
SELECT * FROM dbo.Member where Email = 'Promise671@gmail.com'
SELECT * FROM dbo.Address	WHERE AddressID = (SELECT 
AddressID FROM dbo.Member WHERE MemberID = 
(SELECT MemberID FROM dbo.Login WHERE Username = 'Promise671'))
SELECT * FROM dbo.Login WHERE Username = 'Promise671'


-- ****************************Testing view in QUESTION 3***********************************
SELECT * FROM LoanHistoryView

-- ****************************Testing trigger in QUESTION 4********************************
--Update Loan Table to test trigger
UPDATE dbo.Loan
SET ReturnDate = '2023-04-07'
WHERE LoanID = 5

--validate result
SELECT * FROM dbo.Loan WHERE LoanID = 5
SELECT * FROM dbo.ItemCopy WHERE ItemCopyID = 6

--****************************Test the function in QUESTION 5********************************
SELECT * FROM uf_GetTotalNumberOfLoanByDate('2023-04-01')

--****************************Test the the trigger in Extra Question 1***********************
UPDATE dbo.Member 
SET MembershipEndDate = '2023-03-19', 
	MemberStatusID = 2 
WHERE MemberID = 17;

-- Checking if the trigger inserted value into the temporary table
SELECT * FROM #InactiveMember

----***************************Testing the function in Extra Question 2**********************
-- update some items status to removed or lost to test Extra Question 2 function
UPDATE dbo.ItemCopy SET AvailableCopy = 0, ItemStatusID = 4 WHERE ItemCopyID = 19
UPDATE dbo.ItemCopy SET AvailableCopy = 0, ItemStatusID = 5 WHERE ItemCopyID = 20
UPDATE dbo.ItemCopy SET AvailableCopy = 0, ItemStatusID = 4 WHERE ItemCopyID = 21

-- Test the above function to view the lost or removed items
SELECT * FROM dbo.uf_LostRemovedItem()

--****************************Execute the procedure in Extra Question 3**********************
EXEC uspAddNewPayment
	@PublicationYear = 2011,
	@ISBN = 137758222,
	@MemberUsername = 'Brynn_Stean',
	@PaymentAmount  = 0.2,
	@PaymentMethod = 'Card',
	@ItemTitle = 'Advance Visualization with Panda',
	@ItemTypeName = 'Book'

--***************************Executing procedure in Extra Question 4*************************
EXEC uspAddNewLoan
	@ItemTitle = 'Introduction to Engineering',
	@ItemTypeName = 'Book',
	@PublicationYear = '1978',
	@ISBN = 31702729,
	@MemberUsername = 'Katie_Peddowe'