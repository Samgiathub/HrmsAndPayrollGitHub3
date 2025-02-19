
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0240_Perquisites_Employee_Car_Insert]  

 @Tran_id	numeric(18, 0) OUTPUT
,@Cmp_id	numeric(18, 0)
,@Emp_id	numeric(18, 0)
,@Perquisites_id	numeric(18, 0)
,@Financial_Year	nvarchar(30)
,@usage_type	numeric(18, 0)
,@owned_type	numeric(18, 0)
,@Actual_Expencse	numeric(18, 2)
,@is_Depreciation	tinyint
,@Cost_of_car	numeric(18, 2)
,@Car_HP	numeric(18, 0)
,@is_Chauffeur	tinyint
,@Chauffeur_Salary	numeric(18, 2)
,@no_of_month	numeric(18, 0)
,@amount_recovered	numeric(18, 2)
,@Total_perq_Amt_per_month	numeric(18, 2)
,@Total_perq_Amt	numeric(18, 2)
,@Tran_Type varchar(1)

AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON  
		
		declare @currDate as datetime
		select @currDate = GETDATE()
			
		if exists (SELECT TRAN_ID FROM T0240_Perquisites_Employee_Car WITH (NOLOCK) where Financial_Year = @Financial_Year and emp_id = @Emp_id and @Tran_Type = 'I')
			begin
				
				SELECT @Tran_id = TRAN_ID FROM T0240_Perquisites_Employee_Car WITH (NOLOCK) where Financial_Year = @Financial_Year and emp_id = @Emp_id 
				set @TRAN_TYPE = 	'U'	
			end
		
		IF @TRAN_TYPE = 'I'
			BEGIN
				
				SELECT @TRAN_ID = ISNULL(MAX(TRAN_ID),0) + 1 FROM T0240_Perquisites_Employee_Car WITH (NOLOCK)
				
				INSERT INTO T0240_Perquisites_Employee_Car
					  (Tran_id, cmp_id, emp_id, perquisites_id, Financial_Year, usage_type, owned_type, Actual_Expencse, is_Depreciation, Cost_of_car, Car_HP, is_Chauffeur, Chauffeur_Salary, no_of_month, amount_recovered, Total_perq_Amt_per_month, Total_perq_Amt,Change_date)
				VALUES     (@Tran_id,@cmp_id,@emp_id,@perquisites_id,@Financial_Year,@usage_type,@owned_type,@Actual_Expencse,@is_Depreciation,@Cost_of_car,@Car_HP,@is_Chauffeur,@Chauffeur_Salary,@no_of_month,@amount_recovered,@Total_perq_Amt_per_month,@Total_perq_Amt,GETDATE())
						
			END	
		ELSE IF @TRAN_TYPE = 'U'
			BEGIN
			
				SELECT @Tran_id = TRAN_ID FROM T0240_Perquisites_Employee_Car WITH (NOLOCK) where Financial_Year = @Financial_Year and emp_id = @Emp_id 
				UPDATE    T0240_Perquisites_Employee_Car
				SET     usage_type = @usage_type, 
						owned_type = @owned_type, 
						Actual_Expencse = @Actual_Expencse, 
						is_Depreciation = @is_Depreciation, 
						Cost_of_car = @Cost_of_car, 
						Car_HP = @Car_HP, 
						is_Chauffeur = @is_Chauffeur, 
						Chauffeur_Salary = @Chauffeur_Salary, 
						no_of_month = @no_of_month,
						amount_recovered = @amount_recovered, 
						Total_perq_Amt_per_month = @Total_perq_Amt_per_month, 
						Total_perq_Amt = @Total_perq_Amt,
						change_date = getdate()
						WHERE Tran_id = @Tran_id 
			END	
		ELSE IF @TRAN_TYPE = 'D'
			BEGIN
				-- Comment by Ali 24102013 
				-- delete T0240_Perquisites_Employee_Car where Tran_id = @Tran_id 
				
				-- Added by Ali 24102013 -- Start
					Delete T0240_Perquisites_Employee_Car 
					where cmp_id = @Cmp_id AND Financial_Year = @Financial_Year AND emp_id = @Emp_id					
				-- Added by Ali 24102013 -- End
			End
	
RETURN




