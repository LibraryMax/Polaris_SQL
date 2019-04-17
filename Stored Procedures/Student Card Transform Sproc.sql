SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Max Cohen>
-- Create date: <Create Date,,3/14/2019>
-- Description:	<Description,,Script to turn school output files into useable TRN formatted files>
-- =============================================
ALTER PROCEDURE dbo.transform 
	-- Add the parameters for the stored procedure here
	@TableName nvarchar(MAX)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @SQL nvarchar(MAX)
	CREATE TABLE #Temp (
		Creation_Date nvarchar(50),
		Last_Name nvarchar(100),
		First_Name nvarchar(100),
		Barcode nvarchar(10),
		Expiration_Date nvarchar(50),
		Password nvarchar(10),
		Registration_Date nvarchar(50),
		Birth_Date nvarchar(50),
		Street_Address nvarchar(100),
		City nvarchar(15),
		State_Abbreviation nvarchar(25),
		Zip_Code nvarchar(10),
		Phone nvarchar(10)
	)
    -- Insert statements for procedure here
	SET @SQL =
		'INSERT INTO
		#Temp(
			Creation_Date,
			Last_Name,
			First_Name,
			Barcode,
			Expiration_Date,
			Password,
			Registration_Date,
			Birth_Date,
			Street_Address,
			City,
			State_Abbreviation,
			Zip_Code,
			Phone
			)
		SELECT
		CONVERT(VARCHAR(10),GETDATE(), 120),
		Stu_Last_Name,
		Stu_First_Name,
		Other_ID,
		CONVERT(VARCHAR(10), DATEADD (yy, 99, GETDATE()), 120),
		Other_ID,
		CONVERT(VARCHAR(10),GETDATE(), 120),
		CONCAT(RIGHT(Birthdate,4), ''-'', LEFT( Birthdate,2), ''-'', SUBSTRING(Birthdate, 3, 2)),
		COALESCE(
			IIF(
				St_Addr_Mail IS NULL,
				PO_Box_Mail,
				St_Addr_Mail
			),''''),
		COALESCE(City_Mail,'''') ,
		COALESCE(State_Mail,''''),
		COALESCE(Zip_Code_Mail,''''),
		COALESCE(Primary_Phone, '''')' +
		'FROM ' + @TableName

	EXEC(@SQL)

	SELECT 
		'5'			+'|'+-- 7 for Update / Add, 5 for New
		Creation_Date  + '|' + --Creation Date
		Last_Name		+'|'+-- Last Name
		First_Name		+'|'+-- First Name
		''	 	+'|'+-- Middle Initial
		''			+'|'+-- Title
		''			+'|'+-- Suffix
		'13'			+'|'+-- Patron Code ID - 2 is Juvenile, 14 is Outreach Juvenile
		'13'			+'|'+-- Patron Branch ID - 12 is Outreach
		Barcode	+'|'+-- Patron Barcode (temp, until given actual barcode)
		Expiration_Date  + '|' + -- Expiration Date, 99 years in future
		''	+'|'+-- Patron Statistical Code
		'N'	+'|'+-- Gender, M/F/N
		Password	+'|'+-- Password
		'1'	+'|'+-- Language ID (1 for English)
		Registration_Date	+ '|' + -- Registration Date
		Birth_Date  + '|' + --Birth Date
		''	+'|'+-- Permission - DO NOT USE
		'0'	+'|'+-- Maintain Reading List - 0 for No list, 1 for Yes Maintain
		''	+'|'+-- Former ID
		'' +'|'+-- User Defined 1 - Guardian
		'No' 	+'|'+-- User Defined 2 - Temporary Resident
		''	+'|'+-- User Defined 3 - Name on ID
		''	+'|'+-- User Defined 4 
		'Yes' 	+'|'+-- User Defined 5 - SIP2
		'0'	+'|'+-- Do not Delete - 1=Staff not able to delete, 0=Staff May delete
		'0' +'|'+-- Exclude From Billing - 1=never bill, 0=may be billed
		'0'	+'|'+-- Exclude from Collection
		'0'	+'|'+-- Exclude from Holds - 1=Not sent holds notifications, 0=send hold notifications
		'0'	+'|'+-- Exclude from OverDue - 1=no overdue notes, 0=send overdues
		'0' 	+'|'+-- Plain Text Notifications - 1=PlainText, 0=HTML notifications
		'~Home'	+'|'+-- Free address Label -Type of address= ~Home, ~School, ~Work, etc.
		'1' 	+'|'+-- NEW FIELD - Address Type - 1=Generic, 2=Notice
		Street_Address +'|'+-- Street One
		''	+'|'+-- Street Two
		City			+'|'+-- City
		State_Abbreviation		+'|'+-- State
		Zip_Code 			+'|'+-- Postal Code
		'' 				+'|'+-- Zip PlusFour only
		'Kitsap'		+'|'+-- County
		'1' 			+'|'+-- Country (1=USA)
		'2021-01-01'	+'|'+-- Address Check Date
		'' 			+'|'+-- Email Address
		'' 			+'|'+-- Alternate Email Address
		Phone +'|'+-- Phone Voice 1
		'' 		 +'|'+-- Phone 1 Carrier ID
		'' 		 +'|'+-- Phone Voice 2
		'' 		 +'|'+-- Phone 2 Carrier ID 
		'' 		 +'|'+-- Phone Voice 3
		'' 		 +'|'+-- Phone 3 Carrier ID 
		'' 		 +'|'+-- Fax Number
		'3'		 +'|'+-- Delivery Option ID (1 for mail, 2 email, 3 Phone1 etc.) - Required
		'' 		 +'|'+-- Patron Record ID - added by Polaris, not required in file
		''		 +'|'+-- SMS Enabled
		'' 		 +'|'+-- eReceipt Option - 2=email, 8=Text Message, 100=Both
		'' 		 +'|'+-- Txt Phone Number - which phone for text messages
		'0'		 +'|'+-- Exclude from almost overdue/auto renew
		'0'		 +'|'+-- Exclude from patron record expiration
		'0'		      -- Exclude from inactive patron notices
	FROM #Temp
	ORDER BY Last_Name, First_Name

	DROP TABLE #Temp
END
GO
