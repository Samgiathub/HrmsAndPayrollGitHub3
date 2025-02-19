


---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0095_MANAGER]		
	 @Tran_ID numeric(9)
	,@Cmp_ID   numeric(9)  
	,@Branch_Id  numeric(9)  
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
	
		INSERT INTO T0095_MANAGERS (Cmp_id,Emp_id,branch_id,Effective_Date) 
		VALUES (@Cmp_ID,@Emp_Id,@Branch_Id,@Effective_date)
	END
	ELSE IF @Transtype  = 'D'
	BEGIN
	
		DELETE FROM T0095_MANAGERS WHERE Tran_id = @Tran_ID
	
	END
	
	--ELSE IF @Transtype = 'U' 
	--BEGIN
		
	--	UPDATE T0095_MANAGERS SET Effective_date = @Effective_date			
	--	WHERE Cmp_Id = @Cmp_ID AND Emp_Id = @Emp_Id AND Branch_Id = @Branch_Id
	
	--END
END


