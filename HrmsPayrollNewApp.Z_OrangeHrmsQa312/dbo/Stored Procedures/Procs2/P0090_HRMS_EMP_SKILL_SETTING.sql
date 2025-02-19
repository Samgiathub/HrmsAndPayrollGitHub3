




--=======================================================
--ALTER bY  : 
-- Date
--Review By :
--Last Modified By :Nikunj With Disscussion After Girish at 22-April-2010 
--Description : 
---23/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
--=======================================================
CREATE PROCEDURE [dbo].[P0090_HRMS_EMP_SKILL_SETTING]
	@Emp_Skill_ID  numeric(18,0) output,
	@Skill_R_ID numeric(18,0),
	@Emp_ID numeric(18,0),
	@Skill_ID numeric(18,0),
	@Skill_Actual_Rate numeric(18,2),
	@Skilll_Rate_Given numeric(18,2),
	@tran_type char(1)

AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

  If @tran_type='I'
     Begin
	
			select @Emp_Skill_ID = Isnull(max(Emp_Skill_ID),0) + 1 	From T0090_HRMS_EMP_SKILL_SETTING WITH (NOLOCK)
			
			INSERT INTO T0090_HRMS_EMP_SKILL_SETTING
				                      (Emp_Skill_ID, Skill_R_ID, Emp_ID,Skill_ID,Skill_Actual_Rate,Skilll_Rate_Given)
				VALUES     (@Emp_Skill_ID, @Skill_R_ID, @Emp_ID,@Skill_ID,@Skill_Actual_Rate,@Skilll_Rate_Given)
		End
	Else if @tran_type='U'			
	
	  Begin
			Update T0090_HRMS_EMP_SKILL_SETTING
				set Emp_Skill_ID=@Emp_Skill_ID
				  , Skill_R_ID=@Skill_R_ID
				  , Emp_ID=@Emp_ID
				  ,Skill_ID=@Skill_ID
				  ,Skill_Actual_Rate=@Skill_Actual_Rate
				  ,Skilll_Rate_Given=@Skilll_Rate_Given
				Where   Emp_Skill_ID=@Emp_Skill_ID	  
	  
	  End	  
	     Else if @tran_type='D'      
	
		Begin
			Delete from T0090_HRMS_EMP_SKILL_SETTING where  Skill_R_ID = @Skill_R_ID	
		End	
	RETURN




