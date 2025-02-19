



---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_Graphics_Gender_Detail] 
	@Cmp_ID numeric
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	
	CREATE table #Gender
	(
	  Male varchar(20),
	  Female varchar(20)
	)
	
	insert into #Gender(Male,Female)
	
	Select Gender,'' from T0080_Emp_Master WITH (NOLOCK) where cmp_id=@Cmp_ID and Gender ='M'
	
	
    update #Gender       
		set Female = Gender      
			from T0080_Emp_Master  where Gender='F' and cmp_id=@Cmp_ID
	
	Select * from #Gender
	
	
	RETURN




