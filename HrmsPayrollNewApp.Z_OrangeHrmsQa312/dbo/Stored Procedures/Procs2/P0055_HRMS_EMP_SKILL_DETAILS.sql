




--=======================================================
--ALTER bY  : 
-- Date
--Review By :
--Last Modified By :Nikunj With Disscussion After Girish at 22-April-2010 
--Description : 
---19/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
--=======================================================
CREATE PROCEDURE [dbo].[P0055_HRMS_EMP_SKILL_DETAILS]
		@Skill_R_ID NUMERIC(18,0) output,
		@Cmp_ID NUMERIC(18,0),
		@For_Date dATETIME,
		@Emp_ID  NUMERIC(18,0),
		@S_Emp_ID NUMERIC(18,0),
		@Login_ID NUMERIC(18,0),
		@Status cHAR(1),
		@Skill_Actual_Rate NUMERIC(18,2),
		@Skill_Rate_Given NUMERIC(18,2),
		@tran_type char(1)	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	if @S_Emp_ID = 0
	set @S_Emp_ID = NULL
	
	if @tran_type='I' 
	        Begin
				
					if exists (Select Skill_R_ID  from t0055_HRMS_EMP_SKILL_DETAILS WITH (NOLOCK) Where For_Date = @For_Date and Cmp_ID=@Cmp_ID and Emp_ID=@Emp_ID) 
						begin
							set @Skill_R_ID=0
							RETURN 
						end

						select @Skill_R_ID = isnull(max(Skill_R_ID),0) + 1 from t0055_HRMS_EMP_SKILL_DETAILS WITH (NOLOCK)
						
						insert into t0055_HRMS_EMP_SKILL_DETAILS
							(Skill_R_ID ,
							Cmp_ID ,
							For_Date, 
							Emp_ID ,
							S_Emp_ID, 
							Login_ID ,
							Status,
							Skill_Actual_Rate,
							Skill_Rate_Given
							) Values
							(@Skill_R_ID, 
							@Cmp_ID ,
							@For_Date, 
							@Emp_ID ,
							@S_Emp_ID, 
							@Login_ID ,
							@Status,
							@Skill_Actual_Rate,
							@Skill_Rate_Given
							) 
					End		
							
	Else if @tran_type='U' 	
		Begin				 
		            Update t0055_HRMS_EMP_SKILL_DETAILS
		                  	  	set	Skill_R_ID =@Skill_R_ID,
							Cmp_ID = @Cmp_ID,
							For_Date = @For_date, 
							Emp_ID = @Emp_ID,
							S_Emp_ID = @S_Emp_ID, 
							Login_ID = @Login_ID,
							Status = @Status,
							Skill_Actual_Rate=@Skill_Actual_Rate,
							Skill_Rate_Given=@Skill_Rate_Given
			     where Skill_R_ID = @Skill_R_ID
		End	
	Else if  @tran_type='D' 											
	        Begin         	        
				if Exists (select Emp_Skill_ID from T0090_HRMS_EMP_SKILL_SETTING WITH (NOLOCK) where  Skill_R_ID = @Skill_R_ID)
					Begin
							Delete from T0090_HRMS_EMP_SKILL_SETTING where  Skill_R_ID = @Skill_R_ID
					End	
							Delete from T0055_HRMS_EMP_SKILL_DETAILS Where Skill_R_ID = @Skill_R_ID  						        
	        End	
	RETURN
	
	


