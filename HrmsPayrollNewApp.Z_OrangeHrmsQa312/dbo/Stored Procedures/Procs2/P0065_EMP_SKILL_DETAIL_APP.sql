
---25/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0065_EMP_SKILL_DETAIL_APP]
		 @Row_ID int output
		,@Emp_Tran_ID bigint
        ,@Emp_Application_ID int
		,@Cmp_ID int
		,@Skill_ID numeric 
		,@Skill_Comments varchar(250)
		,@Skill_Experience varchar(50)		
		,@tran_type varchar(1)
		,@Login_Id int=0
		,@Approved_Emp_ID int
		,@Approved_Date datetime = Null
		,@Rpt_Level int 
 
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

		if @Skill_ID = 0 
		set @Skill_ID =  null
		
			if @tran_type ='i' 
			begin
				
				IF exists(select Skill_ID From T0065_EMP_SKILL_DETAIL_APP WITH (NOLOCK)
				where Emp_Tran_ID=@Emp_Tran_ID and Emp_Application_ID=@Emp_Application_ID and Skill_ID = @Skill_ID)
					begin
							set @Row_ID = 0
							return
					end
			
			
				select @Row_ID = isnull(max(Row_ID),0) + 1 from T0065_EMP_SKILL_DETAIL_APP WITH (NOLOCK)
			
			
				INSERT INTO T0065_EMP_SKILL_DETAIL_APP
				                      (Row_ID,Emp_Tran_ID,Emp_Application_ID,Cmp_ID, Skill_ID, Skill_Comments,Skill_Experience,Approved_Emp_ID,Approved_Date,Rpt_Level)
				VALUES     (@Row_ID,@Emp_Tran_ID,@Emp_Application_ID,@Cmp_ID,@Skill_ID,@Skill_Comments,@Skill_Experience,@Approved_Emp_ID,@Approved_Date,@Rpt_Level)
				
			
						
			end 
	else if @tran_type ='u' 
				begin
				
				IF not exists(select Skill_ID From T0065_EMP_SKILL_DETAIL_APP WITH (NOLOCK)
					where Emp_Tran_ID=@Emp_Tran_ID and Emp_Application_ID=@Emp_Application_ID  and Row_ID = @Row_ID) 
					begin
						set @Row_ID = 0
						return
					end
					
				IF exists(select Skill_ID From T0065_EMP_SKILL_DETAIL_APP WITH (NOLOCK)
					where Emp_Tran_ID=@Emp_Tran_ID and Emp_Application_ID=@Emp_Application_ID  and Skill_ID = @Skill_ID and Row_ID <> @Row_ID)
					begin			
						set @Row_ID = 0
						return
					end
					
					UPDATE    T0065_EMP_SKILL_DETAIL_APP
					SET              Cmp_ID = @Cmp_ID,Skill_ID = @Skill_ID, Skill_Comments = @Skill_Comments, Skill_Experience = @Skill_Experience,Approved_Emp_ID=@Approved_Emp_ID,Approved_Date=@Approved_Date,Rpt_Level=@Rpt_Level
					WHERE     (Row_ID = @Row_ID and Emp_Tran_ID=@Emp_Tran_ID and Emp_Application_ID=@Emp_Application_ID  )
					
					
				end
	else if @tran_type ='d'
					delete  from T0065_EMP_SKILL_DETAIL_APP where Row_ID = @Row_ID
					
					
	RETURN

	

