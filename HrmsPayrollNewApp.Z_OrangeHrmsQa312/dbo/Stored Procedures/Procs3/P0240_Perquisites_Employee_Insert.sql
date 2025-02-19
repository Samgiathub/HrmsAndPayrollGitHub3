
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0240_Perquisites_Employee_Insert]  

 @Tran_id	numeric(18, 0) OUTPUT
,@Cmp_id	numeric(18, 0)
,@Emp_id	numeric(18, 0)
,@Perquisites_id	numeric(18, 0)
,@Financial_Year	nvarchar(30)
,@On_Rent	tinyint
,@On_Rent_From	datetime
,@On_Rent_To	datetime
,@Cmp_Quarter	tinyint
,@Cmp_Quarter_From	datetime
,@Cmp_Quarter_To	datetime
,@Salary	numeric(18, 2)
,@On_Rent_Per	numeric(18, 2)
,@Cmp_Quater_Per	numeric(18, 2)
,@Total_Rent_Amt	numeric(18, 2)
,@Total_Furnish_Amt	numeric(18, 2)
,@Population	nvarchar(50)
,@On_Rent_days	numeric(18, 2)
,@Cmp_Quarter_days	numeric(18, 2)
,@Month	numeric(18, 0)
,@Per_Rent_Amt	numeric(18, 2)
,@Per_Quater_Amt numeric(18, 2)
,@Tran_Type varchar(1)

AS  
 SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON 
		
		declare @currDate as datetime
		select @currDate = GETDATE()
		
		IF @Tran_Type <> 'D' 
		BEGIN
			IF exists (SELECT Tran_id FROM T0240_PERQUISITES_EMPLOYEE WITH (NOLOCK) where Financial_Year = @Financial_Year and Emp_id = @Emp_id And Cmp_id = @Cmp_id)
				BEGIN									
						set @Tran_Type = 	'U'
				END
			ELSE
				BEGIN
						set @Tran_Type = 	'I'
				END
		END
		
		
		IF @TRAN_TYPE = 'I'
			BEGIN
										
				SELECT @TRAN_ID = ISNULL(MAX(TRAN_ID),0) + 1 FROM T0240_PERQUISITES_EMPLOYEE WITH (NOLOCK)
				
				INSERT INTO T0240_PERQUISITES_EMPLOYEE
						(TRAN_ID, CMP_ID, EMP_ID, PERQUISITES_ID, FINANCIAL_YEAR, ON_RENT, ON_RENT_FROM, ON_RENT_TO, CMP_QUARTER, CMP_QUARTER_FROM, CMP_QUARTER_TO, SALARY,ON_RENT_PER, CMP_QUATER_PER, TOTAL_RENT_AMT, TOTAL_FURNISH_AMT, POPULATION, ON_RENT_DAYS, CMP_QUARTER_DAYS, MONTH, PER_RENT_AMT, PER_QUATER_AMT,Change_Date)
				VALUES  (@TRAN_ID,@CMP_ID,@EMP_ID,@PERQUISITES_ID,@FINANCIAL_YEAR,@ON_RENT,@ON_RENT_FROM,@ON_RENT_TO,@CMP_QUARTER,@CMP_QUARTER_FROM,@CMP_QUARTER_TO,@SALARY,@ON_RENT_PER,@CMP_QUATER_PER,@TOTAL_RENT_AMT,@TOTAL_FURNISH_AMT,@POPULATION,@ON_RENT_DAYS,@CMP_QUARTER_DAYS,@MONTH,@PER_RENT_AMT,@PER_QUATER_AMT,@currDate)
					
			END	
		ELSE IF @TRAN_TYPE = 'U'
			BEGIN
			
				Select @Tran_id = Tran_id from T0240_Perquisites_Employee WITH (NOLOCK) where Cmp_id = @Cmp_id AND Financial_Year = @Financial_Year AND Emp_id = @Emp_id
				
				UPDATE    T0240_Perquisites_Employee
				SET       Financial_Year = @FINANCIAL_YEAR, On_Rent = @ON_RENT, 
						  On_Rent_From = @ON_RENT_FROM, On_Rent_To = @ON_RENT_TO, Cmp_Quarter = @CMP_QUARTER, Cmp_Quarter_From = @CMP_QUARTER_FROM, 
						  Cmp_Quarter_To = @CMP_QUARTER_TO, Salary = @SALARY, On_Rent_Per = @ON_RENT_PER, Cmp_Quater_Per = @CMP_QUATER_PER, 
						  Total_Rent_Amt = @TOTAL_RENT_AMT, Total_Furnish_Amt = @TOTAL_FURNISH_AMT, Population = @POPULATION, On_Rent_days = @ON_RENT_DAYS, 
						  Cmp_Quarter_days = @CMP_QUARTER_DAYS, Month = @MONTH, Per_Rent_Amt = @PER_RENT_AMT, Per_Quater_Amt = @PER_QUATER_AMT
						  ,change_date = @currDate
						--WHERE Tran_id = @Tran_id Commect by Ali 24102013
				where Cmp_id = @Cmp_id AND Financial_Year = @Financial_Year AND Emp_id = @Emp_id
				
			END	
		ELSE IF @TRAN_TYPE = 'D'
			BEGIN
				
				-- Comment by Ali 24102013 
				--delete t0250_Perquisites_Employee_Monthly_Rent where Perq_Tran_Id = @Tran_id
				--delete T0240_Perquisites_Employee where Tran_id = @Tran_id							
				
				-- Added by Ali 24102013 -- Start
					Declare @pTran_Id as numeric 
					Set @pTran_Id = 0										
					Select @pTran_Id = Tran_id from  T0240_Perquisites_Employee WITH (NOLOCK)
					where Cmp_id = @Cmp_id AND Financial_Year = @Financial_Year AND Emp_id = @Emp_id
				
					Delete T0240_Perquisites_Employee 
					where Cmp_id = @Cmp_id AND Financial_Year = @Financial_Year AND Emp_id = @Emp_id	
					
					Delete T0250_Perquisites_Employee_Monthly_Rent 
					where Perq_Tran_Id  = @pTran_Id				
				-- Added by Ali 24102013 -- End
				
			End
	
RETURN




