


-- Created By rohit on 14092015 for Department Head
---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0095_Department_Manager]		
	 @Tran_ID numeric(9)
	,@Cmp_ID   numeric(9)  
	,@Dept_Id  numeric(9)  
	,@Effective_date datetime	
	,@Emp_Id numeric(9)  
	,@Transtype  varchar(1) 
   
AS
BEGIN

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	IF @Transtype  = 'I'
	BEGIN
	
		INSERT INTO T0095_Department_Manager (Cmp_id,Emp_id,Dept_Id,Effective_Date) 
		VALUES (@Cmp_ID,@Emp_Id,@Dept_Id,@Effective_date)
	END
	ELSE IF @Transtype  = 'D'
	BEGIN
	
		DELETE FROM T0095_Department_Manager WHERE Tran_id = @Tran_ID and Cmp_id = @Cmp_ID
	
	END
	
	--ELSE IF @Transtype = 'U' 
	--BEGIN
		
	--	UPDATE T0095_MANAGERS SET Effective_date = @Effective_date			
	--	WHERE Cmp_Id = @Cmp_ID AND Emp_Id = @Emp_Id AND Branch_Id = @Branch_Id
	
	--END
END


