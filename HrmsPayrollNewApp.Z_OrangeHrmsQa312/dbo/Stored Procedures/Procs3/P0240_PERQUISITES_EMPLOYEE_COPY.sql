

-- =============================================
-- Author:		<Author,,Ankit>
-- Create date: <Create Date,,27042016>
-- Description:	<Description,,Copy Financial Year Record>
---25/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0240_PERQUISITES_EMPLOYEE_COPY]
	@Cmp_id				NUMERIC(18, 0) = 0
	,@Financial_Year_From	NVARCHAR(30) = '2015-2016'
	,@Financial_Year_To		NVARCHAR(30) = '2016-2017'
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	DECLARE @Tran_id	NUMERIC(18, 0) 
	DECLARE @Emp_id		NUMERIC(18, 0)
	DECLARE @Perquisites_id	NUMERIC(18, 0)
	DECLARE @Financial_Year	NVARCHAR(30)
	DECLARE @On_Rent		TINYINT
	DECLARE @On_Rent_From	DATETIME
	DECLARE @On_Rent_To		DATETIME
	DECLARE @Cmp_Quarter		TINYINT
	DECLARE @Cmp_Quarter_From	DATETIME
	DECLARE @Cmp_Quarter_To	DATETIME
	DECLARE @Salary			NUMERIC(18, 2)
	DECLARE @On_Rent_Per	NUMERIC(18, 2)
	DECLARE @Cmp_Quater_Per	NUMERIC(18, 2)
	DECLARE @Total_Rent_Amt	NUMERIC(18, 2)
	DECLARE @Total_Furnish_Amt	NUMERIC(18, 2)
	DECLARE @Population			NVARCHAR(50)
	DECLARE @On_Rent_days		NUMERIC(18, 2)
	DECLARE @Cmp_Quarter_days	NUMERIC(18, 2)
	DECLARE @Month			NUMERIC(18, 0)
	DECLARE @Per_Rent_Amt	NUMERIC(18, 2)
	DECLARE @Per_Quater_Amt NUMERIC(18, 2)
	DECLARE @Tran_Type		VARCHAR(1)
	DECLARE @Old_Tran_ID	NUMERIC
	DECLARE @Old_Year		DATETIME
	DECLARE @Tran_ID_Car	NUMERIC
	
	DECLARE CurrPerq CURSOR FOR
		SELECT Emp_id FROM V0240_Perquisites_Employee_New WHERE Cmp_id = @Cmp_id AND Financial_Year = @Financial_Year_From-- AND Emp_id = 131
	OPEN CurrPerq
	FETCH NEXT FROM CurrPerq INTO @Emp_id
	WHILE @@FETCH_STATUS =0
		BEGIN
			SET @Old_Tran_ID = 0
			SET @Tran_ID_Car = 0
			SET @TRAN_ID = 0
			
			SELECT @Old_Tran_ID = Tran_id FROM T0240_PERQUISITES_EMPLOYEE WITH (NOLOCK)
			WHERE Cmp_id = @Cmp_id AND Financial_Year = @Financial_Year_From  AND Emp_id = @Emp_id
			
			SELECT @TRAN_ID = ISNULL(MAX(TRAN_ID),0) + 1 FROM T0240_PERQUISITES_EMPLOYEE WITH (NOLOCK)
			
			INSERT INTO	T0240_PERQUISITES_EMPLOYEE
			SELECT @TRAN_ID/*Tran_ID*/,Cmp_id,Emp_id,Perquisites_id,@Financial_Year_To/*Financial_Year*/,On_Rent,
				CASE WHEN On_Rent_From = '9999-12-31 00:00:00.000' THEN On_Rent_From ELSE DATEADD(YEAR,1,On_Rent_From) END,
				CASE WHEN On_Rent_To = '9999-12-31 00:00:00.000' THEN On_Rent_To ELSE DATEADD(YEAR,1,On_Rent_To)END ,Cmp_Quarter,
				CASE WHEN Cmp_Quarter_From = '9999-12-31 00:00:00.000' THEN Cmp_Quarter_From ELSE DATEADD(YEAR,1,Cmp_Quarter_From) END,
				CASE WHEN Cmp_Quarter_From = '9999-12-31 00:00:00.000' THEN Cmp_Quarter_To ELSE DATEADD(YEAR,1,Cmp_Quarter_To) END,
				Salary,
				On_Rent_Per,Cmp_Quater_Per,Total_Rent_Amt,Total_Furnish_Amt,[Population],On_Rent_days,Cmp_Quarter_days,[MONTH],Per_Rent_Amt,Per_Quater_Amt,GETDATE()/*Change_Date*/
			FROM T0240_PERQUISITES_EMPLOYEE WITH (NOLOCK)
			WHERE Cmp_id = @Cmp_id AND Financial_Year = @Financial_Year_From  AND Emp_id = @Emp_id AND Tran_id = @Old_Tran_ID
					
		
			INSERT INTO T0250_Perquisites_Employee_Monthly_Rent
			SELECT @Tran_id,[MONTH],[YEAR] + 1/*[Year]*/,Amount FROM T0250_Perquisites_Employee_Monthly_Rent WITH (NOLOCK) WHERE Perq_Tran_Id = @Old_Tran_ID
		 	
			SELECT @Tran_ID_Car = ISNULL(MAX(Tran_id),0) + 1 FROM T0240_Perquisites_Employee_Car WITH (NOLOCK)
			
			INSERT INTO T0240_Perquisites_Employee_Car
			SELECT @Tran_ID_Car/*Tran_id*/,cmp_id,emp_id,perquisites_id,@Financial_Year_To/*Financial_Year*/,usage_type,owned_type,Actual_Expencse,is_Depreciation,Cost_of_car,Car_HP,is_Chauffeur
					,Chauffeur_Salary,no_of_month,amount_recovered,Total_perq_Amt_per_month,Total_perq_Amt,GETDATE()/*Change_Date*/
			FROM T0240_Perquisites_Employee_Car WITH (NOLOCK)
			WHERE Cmp_id = @Cmp_id AND Financial_Year = @Financial_Year_From  AND Emp_id = @Emp_id
			
			SET @Tran_ID_Car =0
			SELECT @Tran_ID_Car = ISNULL(MAX(Trans_ID),0) + 1 FROM T0240_PERQUISITES_EMPLOYEE_GEW WITH (NOLOCK)
			INSERT INTO T0240_PERQUISITES_EMPLOYEE_GEW
			SELECT @Tran_ID_Car/*Trans_ID*/,Cmp_id,Emp_id,@Financial_Year_To/*Financial_Year*/,Total_Amount,DATEADD(YEAR,1,From_Date),DATEADD(YEAR,1,To_Date),GETDATE()/*ChangeDate */
			FROM T0240_PERQUISITES_EMPLOYEE_GEW WITH (NOLOCK)
			WHERE Cmp_id = @Cmp_id AND Financial_Year = @Financial_Year_From AND Emp_id = @Emp_id
			
			
			SET @Old_Tran_ID = 0
			SELECT @Old_Tran_ID = Trans_ID FROM T0240_PERQUISITES_EMPLOYEE_GEW WITH (NOLOCK) WHERE Cmp_id = @Cmp_id AND Financial_Year = @Financial_Year_From AND Emp_id = @Emp_id
			
			INSERT INTO T0250_Perquisites_Employee_Monthly_GEW
			SELECT @Tran_ID_Car/*Perq_Tran_Id*/,[MONTH],[YEAR] +1,Amount
			FROM T0250_Perquisites_Employee_Monthly_GEW  WITH (NOLOCK)
			WHERE Perq_Tran_Id = @Old_Tran_ID
			
			FETCH NEXT FROM CurrPerq INTO @Emp_id
		END
	CLOSE CurrPerq
	DEALLOCATE CurrPerq	
	
	
	    
END

