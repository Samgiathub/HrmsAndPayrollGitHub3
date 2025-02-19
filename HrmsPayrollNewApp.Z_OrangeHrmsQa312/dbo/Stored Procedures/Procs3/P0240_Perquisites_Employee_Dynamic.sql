


-- Created by rohit for It Perq Dynamic
---30/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0240_Perquisites_Employee_Dynamic]  

 @Tran_id	numeric(18, 0) OUTPUT
,@Cmp_id	numeric(18, 0)
,@Emp_id	numeric(18, 0)
,@It_Id	numeric(18, 0)
,@Financial_Year	nvarchar(30)
,@Amount	numeric(18, 2)
,@Tran_Type varchar(1)

AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
		
		declare @currDate as datetime
		select @currDate = GETDATE()
			
		if exists (SELECT TRAN_ID FROM T0240_Perquisites_Employee_dynamic WITH (NOLOCK) where Financial_Year = @Financial_Year and emp_id = @Emp_id and it_id=@It_Id and @Tran_Type = 'I')
			begin
				
				SELECT @Tran_id = TRAN_ID FROM T0240_Perquisites_Employee_dynamic WITH (NOLOCK) where Financial_Year = @Financial_Year and emp_id = @Emp_id  and It_Id= @It_Id
				set @TRAN_TYPE = 	'U'	
			end
		
		IF @TRAN_TYPE = 'I'
			BEGIN
				
				SELECT @TRAN_ID = ISNULL(MAX(TRAN_ID),0) + 1 FROM T0240_Perquisites_Employee_dynamic WITH (NOLOCK)
				
				INSERT INTO T0240_Perquisites_Employee_dynamic
					  ( cmp_id, emp_id, It_Id, Financial_Year, Amount, modify_date)
				VALUES     (@cmp_id,@emp_id,@It_Id,@Financial_Year,@Amount,GETDATE())
						
			END	
		ELSE IF @TRAN_TYPE = 'U'
			BEGIN
			
				SELECT @Tran_id = TRAN_ID FROM T0240_Perquisites_Employee_dynamic WITH (NOLOCK) where Financial_Year = @Financial_Year and emp_id = @Emp_id and It_Id =@It_Id
				UPDATE    T0240_Perquisites_Employee_dynamic
				SET   
				Amount= @Amount,
				modify_date = GETDATE()
				WHERE Tran_id = @Tran_id  and emp_id=@emp_id and It_Id= @It_Id
			END	
		ELSE IF @TRAN_TYPE = 'D'
			BEGIN
				-- Comment by Ali 24102013 
				-- delete T0240_Perquisites_Employee_Car where Tran_id = @Tran_id 
				
				-- Added by Ali 24102013 -- Start
					Delete T0240_Perquisites_Employee_dynamic 
					where cmp_id = @Cmp_id AND Financial_Year = @Financial_Year AND emp_id = @Emp_id and It_Id= @It_Id					
				-- Added by Ali 24102013 -- End
			End
	
RETURN




