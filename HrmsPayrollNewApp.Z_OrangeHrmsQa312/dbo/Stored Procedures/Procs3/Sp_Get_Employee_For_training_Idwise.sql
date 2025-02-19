



---20/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[Sp_Get_Employee_For_training_Idwise]
 @Tran_App_ID      numeric(18,0)
,@Cmp_ID          numeric(18,0)
,@Branch_ID		  numeric(18,0)	
,@s_Emp_ID		  numeric(18,0)	
,@Login_ID		  numeric(18,0)	
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

Declare @Is_Default numeric(18,0)
Declare @Branch  numeric(18,0)

if @Branch_ID <> 0 
	BEgin
		Select Em.Emp_ID,Emp_Code,Emp_Full_Name from T0080_Emp_Master EM WITH (NOLOCK) 
		inner join t0095_increment I WITH (NOLOCK) on
		Em.Increment_ID = I.Increment_ID where EM.Cmp_ID = @Cmp_ID and Emp_Left <> 'Y' And I.Branch_Id=@Branch_ID
	End
else
	Begin
		if @s_Emp_ID <> 0
			BEgin
				Select Em.Emp_ID,Emp_Code,Emp_Full_Name from T0080_Emp_Master EM WITH (NOLOCK) 
				inner join t0095_increment I WITH (NOLOCK) on
				Em.Increment_ID = I.Increment_ID where EM.Cmp_ID = @Cmp_ID and Emp_Left <> 'Y' And Em.Emp_Superior = @S_Emp_ID
			End
		else
			Begin
			
			select @Login_ID=Login_ID from t0100_training_application WITH (NOLOCK) where Training_App_ID=@Tran_App_ID
				select @Is_Default=	Is_Default,@Branch = isnull(Branch_ID,0) from t0011_login WITH (NOLOCK) where Login_ID=@Login_ID
				if @Is_Default = 0 And @Branch <> 0 
					Begin
							Select Em.Emp_ID,Emp_Code,Emp_Full_Name from T0080_Emp_Master EM WITH (NOLOCK)
							inner join t0095_increment I WITH (NOLOCK) on
							Em.Increment_ID = I.Increment_ID where EM.Cmp_ID = @Cmp_ID and Emp_Left <> 'Y' And I.Branch_id=@Branch
					End
				else	
					Begin
							Select Em.Emp_ID,Emp_Code,Emp_Full_Name from T0080_Emp_Master EM WITH (NOLOCK)
							inner join t0095_increment I WITH (NOLOCK) on
							Em.Increment_ID = I.Increment_ID where EM.Cmp_ID = @Cmp_ID and Emp_Left <> 'Y' 
					End
					
			
					
			End
	End	

RETURN




