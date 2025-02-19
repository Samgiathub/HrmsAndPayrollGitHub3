



---30/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_EMP_FNF_ALLOWANCE_DETAILS] 
 @Tran_ID numeric(18,0) Output
,@Emp_Id numeric(18,0)
,@Ad_ID	numeric(18,0)
,@From_Date datetime
,@To_Date datetime
,@Cmp_id numeric(18,0) = 0
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
		
		Delete from EMP_FNF_ALLOWANCE_DETAILS where Emp_ID=@Emp_ID And Ad_ID=@Ad_ID And isnull(FNF_ID,0) <> 0
		
		if Exists(select Tran_ID from EMP_FNF_ALLOWANCE_DETAILS WITH (NOLOCK) where Emp_ID=@Emp_ID And Ad_ID=@Ad_ID And isnull(FNF_ID,0) = 0)
			Begin
				delete from EMP_FNF_ALLOWANCE_DETAILS where Emp_ID=@Emp_ID And Ad_ID=@Ad_ID And isnull(FNF_ID,0) = 0
			End
		
		Select @Tran_ID = isnull(MAx(Tran_ID),0)+1 from EMP_FNF_ALLOWANCE_DETAILS WITH (NOLOCK)
		
		insert into EMP_FNF_ALLOWANCE_DETAILS(Tran_ID,Emp_Id,Ad_ID,From_Date,To_Date,FNF_ID,Cmp_Id)
		values(@Tran_ID,@Emp_Id,@Ad_ID,@From_Date,@To_Date,0 ,@Cmp_id)
		
RETURN




