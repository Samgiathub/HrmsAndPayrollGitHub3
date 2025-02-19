
---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0240_Perquisites_Employee_GEW_Insert]  

 @Tran_id	numeric(18, 0) OUTPUT
,@Cmp_id	numeric(18, 0)
,@Emp_id	numeric(18, 0)
,@Financial_Year	nvarchar(30)
,@Total_Amount	numeric(18,0)
,@From_Date 	datetime
,@To_Date	datetime
,@Tran_Type varchar(1)

AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

		declare @currDate as datetime
		select @currDate = GETDATE()
		
		IF @Tran_Type <> 'D' 
		BEGIN
			IF exists (SELECT Trans_ID FROM T0240_PERQUISITES_EMPLOYEE_GEW WITH (NOLOCK) where Financial_Year = @Financial_Year and Emp_id = @Emp_id And Cmp_id = @Cmp_id)
				BEGIN									
						set @Tran_Type = 	'U'
				END
			ELSE
				BEGIN
						set @Tran_Type = 	'I'
				END
		END
			
			
		IF @Tran_Type = 'I'
			BEGIN
				
					SELECT @Tran_id = ISNULL(MAX(Trans_ID),0) + 1 FROM T0240_PERQUISITES_EMPLOYEE_GEW WITH (NOLOCK)
					
					INSERT INTO T0240_PERQUISITES_EMPLOYEE_GEW
							(Trans_ID, Cmp_id, Emp_id, Financial_Year, Total_Amount, From_Date, To_Date)
					VALUES  (@Tran_id,@Cmp_id,@Emp_id,@Financial_Year,@Total_Amount,@From_Date,@To_Date)
					
			END	
		ELSE IF @Tran_Type = 'U'
			BEGIN

					Select @Tran_id = Trans_ID from T0240_PERQUISITES_EMPLOYEE_GEW WITH (NOLOCK) where Cmp_id = @Cmp_id AND Financial_Year = @Financial_Year AND Emp_id = @Emp_id
					
					UPDATE    T0240_PERQUISITES_EMPLOYEE_GEW
					SET       Financial_Year = @Financial_Year, Total_Amount = @Total_Amount, 
							  From_Date = @From_Date, To_Date = @To_Date,ChangeDate = @currDate
					where Cmp_id = @Cmp_id AND Financial_Year = @Financial_Year AND Emp_id = @Emp_id
				
			END	
		ELSE IF @Tran_Type = 'D'
			BEGIN				
					Declare @pTran_Id as numeric 
					Set @pTran_Id = 0										
					Select @pTran_Id = Trans_ID from  T0240_PERQUISITES_EMPLOYEE_GEW WITH (NOLOCK)
					where Cmp_id = @Cmp_id AND Financial_Year = @Financial_Year AND Emp_id = @Emp_id
				
					Delete T0240_PERQUISITES_EMPLOYEE_GEW
					where Cmp_id = @Cmp_id AND Financial_Year = @Financial_Year AND Emp_id = @Emp_id	
					
					Delete T0250_Perquisites_Employee_Monthly_GEW
					where Perq_Tran_Id  = @pTran_Id				
			End	
RETURN




