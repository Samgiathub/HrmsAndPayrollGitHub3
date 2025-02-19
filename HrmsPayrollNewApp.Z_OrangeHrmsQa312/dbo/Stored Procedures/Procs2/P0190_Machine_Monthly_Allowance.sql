

-- =============================================
-- Author:		SHAIKH RAMIZ
-- Create date: 04-04-2018
-- Description:	THIS SP IS USED FOR IMPORTING COLOR BEAM ALLOWANCE ON MONTHLY BASIS
---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0190_Machine_Monthly_Allowance]
	@Cmp_ID			NUMERIC ,
	@Machine_Name	VARCHAR(100),
	@Salary_Month	INT,    
	@Salary_Year	INT,
	@Allow_Amount	NUMERIC(18,2),
	@Comments		VARCHAR(200),
	@User_Id		NUMERIC(18,0) = 0,
    @IP_Address		VARCHAR(30)= '',
	@Log_Status		INT = 0 OUTPUT,
	@GUID			VARCHAR(2000) = '',
	@Delete_Tran_ID		VARCHAR(MAX) = ''
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
	
	/* DECLARE VARIABLES HERE */
	DECLARE @For_Date		DATETIME
	DECLARE @LogDesc		NVARCHAR(MAX)
	DECLARE @Machine_ID		NUMERIC
	DECLARE @Tran_Type	CHAR
	
	/*SET DEFAULT VAUILES OF VARIABLES HERE*/
	SET @For_Date = '1900-01-01'
	SET @LogDesc = ''
	SET @Tran_Type = 'I'
	
	/*INSERT ERROR IN LOGS TABLE*/
	IF @Salary_Month > 12 OR @Salary_Year < 2000    
	RETURN
	
	IF @Delete_Tran_ID <> ''	--IF DELETE TRAN TYPE IS PASSED THEN TRAN TYPE WILL BE "DELETE"
		SET @Tran_Type = 'D'

	IF @Tran_Type = 'I'
		BEGIN
			IF @Machine_Name = ''  
				BEGIN
					Set @Log_Status = 1
					INSERT INTO dbo.T0080_Import_Log VALUES (0,@Cmp_Id,@Machine_Name ,'Machine Name Doesn''t exists',@Machine_Name,'Enter proper Machine Name',GetDate(),'Machine Monthly Allowance Import',@GUID)			
					RETURN
				END
			IF @Salary_Year = 0 
				BEGIN
					Set @Log_Status = 1
					INSERT INTO dbo.T0080_Import_Log VALUES (0,@Cmp_Id,@Machine_Name ,'Year details Doesn''t exists',@Machine_Name,'Enter proper Year Details',GETDATE(),'Machine Monthly Allowance Import',@GUID)			
					RETURN
				END	
			IF @Salary_Month = 0 
				BEGIN
					Set @Log_Status = 1
					INSERT INTO dbo.T0080_Import_Log VALUES (0,@Cmp_Id,@Machine_Name ,'Month details Doesn''t exists',@Machine_Name,'Enter proper Month Details',GETDATE(),'Machine Monthly Allowance Import',@GUID)			
					RETURN
				END
			 
			 SELECT @For_Date = dbo.GET_MONTH_END_DATE(@Salary_Month,@Salary_Year) 
			 SELECT @Machine_ID = ISNULL(MACHINE_ID,0) FROM T0040_Machine_Master WITH (NOLOCK) WHERE Machine_Name = @Machine_Name
		 
		 
			 IF EXISTS(SELECT 1 FROM T0200_MONTHLY_SALARY WITH (NOLOCK) WHERE CMP_ID = @Cmp_ID AND MONTH(Month_End_Date) = @Salary_Month and YEAR(Month_End_Date) = @Salary_Year) -- IF SALARY EXISTS OF THAT MONTH THEN DO NOT INSERT
				BEGIN
					SET @LogDesc = 'Month = '+cast(@Salary_Month as varchar)+', Year = '+cast(@Salary_Year as varchar)
					INSERT INTO dbo.T0080_Import_Log VALUES (0,@Cmp_ID,@Machine_Name,'Salary Exists for ' +@LogDesc ,'','Delete Salary Before Import',GETDATE(),'Machine Monthly Allowance Import',@GUID)
					SET @Log_Status=1
					RETURN 
				END
			
			IF EXISTS (SELECT 1 FROM T0190_MACHINE_MONTHLY_ALLOWANCE WITH (NOLOCK) WHERE CMP_ID = @Cmp_ID AND Machine_ID = @Machine_ID AND Salary_Month = @Salary_Month AND Salary_Year = @Salary_Year )
				BEGIN
					UPDATE T0190_MACHINE_MONTHLY_ALLOWANCE
					SET For_Date = @For_Date, Allow_amount = @Allow_Amount,Comments = @Comments
					WHERE  Machine_ID = @Machine_ID AND Salary_Month = @Salary_Month AND Salary_Year = @Salary_Year AND CMP_ID = @Cmp_ID
				END
			ELSE
				BEGIN
					INSERT INTO T0190_MACHINE_MONTHLY_ALLOWANCE
						( Cmp_ID, Machine_ID, Salary_Month, Salary_Year, For_Date, Allow_amount, Comments,Import_Date)
					VALUES
						( @Cmp_ID, @Machine_ID, @Salary_Month, @Salary_Year, @For_Date, @Allow_Amount, @Comments,GETDATE())  
				END
		END
	ELSE IF @Tran_Type = 'D'
		BEGIN
			 IF EXISTS(SELECT 1 FROM T0200_MONTHLY_SALARY WITH (NOLOCK) WHERE CMP_ID = @Cmp_ID AND MONTH(Month_End_Date) = @Salary_Month and YEAR(Month_End_Date) = @Salary_Year) -- IF SALARY EXISTS OF THAT MONTH THEN DO NOT DELETE
				BEGIN
					RAISERROR('@@Cannot be Deleted , Salary Exists@@' , 16 , 1)
					SET @Log_Status=1
					RETURN 
				END
			ELSE
				BEGIN	
					DELETE FROM T0190_MACHINE_MONTHLY_ALLOWANCE 
					WHERE ALLOW_TRAN_ID IN (SELECT CAST(DATA AS NUMERIC) FROM dbo.split(@Delete_Tran_ID , '#') where data <> '')
				END
		END
		

END

