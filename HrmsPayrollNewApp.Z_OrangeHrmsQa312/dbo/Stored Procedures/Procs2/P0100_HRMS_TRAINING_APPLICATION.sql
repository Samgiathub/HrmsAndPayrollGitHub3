

---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE  PROCEDURE [dbo].[P0100_HRMS_TRAINING_APPLICATION] 
	 @Training_App_ID		Numeric(18,0) output
	,@Training_id           numeric(18,0)
	,@Training_name         varchar(50)
	,@Training_Desc			varchar(50)
	,@For_Date				datetime
	,@Posted_Emp_ID 		numeric(18,0)
	,@Skill_ID		        numeric(18,0) 
	,@Skill_name            varchar(50) 
	,@App_Status			int	
	,@cmp_id				numeric(18,0)
	,@Login_ID				numeric(18,0)
	,@Trans_Type            char(1)
	,@User_Id numeric(18,0) = 0  -- added By Mukti 19082015
    ,@IP_Address varchar(30)= '' -- added By Mukti 19082015
    ,@Training_Plan tinyint = 0  -- Added By Gadriwala Muslim 26122016
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
--Added By Mukti 19082015(start)
	declare @OldValue as varchar(max)
	declare @OldTraining_id    varchar(50)
	declare @OldTraining_name  varchar(50)
	declare @OldTraining_Desc	varchar(50)
	declare @OldFor_Date		varchar(50)
	declare @OldSkill_ID	    varchar(50)
	declare @OldSkill_name     varchar(50) 
	declare @OldApp_Status		varchar(50)
	declare @OldLogin_ID		varchar(50)
	declare @OldTraining_Plan   varchar(3)
--Added By Mukti 19082015(end)
if @For_Date = ''
set @For_Date = null

if @Posted_Emp_ID = 0
set @Posted_Emp_ID = null

if @cmp_id = 0
set @cmp_id = null

if @Login_ID = 0
set @Login_ID = null

 

	if @Training_id = 0 and @Trans_Type <> 'D'
	  Begin 
		EXEC P0040_HRMS_Training_master @Training_id output ,@Training_name,'',@cmp_id,'i',null
	  End	
	
	if @Skill_ID = 0 and @Trans_Type <> 'D'
	   Begin
		exec P0040_SKILL_MASTER @Skill_ID OUTPUT,@Skill_name,@cmp_id,'','I'
	   End

	If @Trans_Type  = 'I' 
		Begin

	If Exists(select Training_App_ID From T0100_HRMS_TRAINING_APPLICATION WITH (NOLOCK)  Where Cmp_Id = @Cmp_Id and Login_ID = @Login_ID and Training_id = @Training_id and For_Date=@For_Date)
				begin
					set @Training_App_ID = 0
					return 
				end 
			
			select @Training_App_ID = Isnull(max(Training_App_ID),0) + 1 	From T0100_HRMS_TRAINING_APPLICATION  WITH (NOLOCK)
			
			INSERT INTO T0100_HRMS_TRAINING_APPLICATION
			        (
						    Training_App_ID
						    ,Training_id
							,Training_Desc
							,For_Date
							,Posted_Emp_ID
							,Skill_ID
							,App_Status
							,cmp_id
							,Login_ID
							,System_Date
							,Training_Plan
			        )
				VALUES     
					(		 @Training_App_ID
							,@Training_id
							,@Training_Desc
							,@For_Date
							,@Posted_Emp_ID
							,@Skill_ID
							,@App_Status
							,@cmp_id
							,@Login_ID
							,getdate() 
							,@Training_Plan	-- Added by Gadriwala Muslim 26122016
					)
					
					
		--Added By Mukti 19082015(start)
		    set @OldValue = 'New Value' + '#'+ 'Training Id:' + cast(Isnull(@Training_id,0) as varchar(25)) + '#' + 
												'Training Desc:' + cast(Isnull(@Training_Desc,'') as varchar(25)) + '#' + 
												'For_Date:' + cast(Isnull(@For_Date,'') as varchar(25)) + '#' + 
												'Posted Emp ID:' + cast(Isnull(@Posted_Emp_ID,0) as varchar(25)) + '#' + 
												'Skill ID:' + cast(Isnull(@Skill_ID,0) as varchar(25)) + '#' + 
												'App Status:' + cast(Isnull(@App_Status,0) as varchar(25)) + '#' + 
												'Company id:' + cast(Isnull(@cmp_id,0) as varchar(25)) + '#' + 
												'Login ID:' + cast(Isnull(@Login_ID,0) as varchar(25)) + '#' + 
												'System Date:' + cast(getdate() as varchar(25))+ '#' + 
												'Training_Plan:' + CASE when @training_plan = 1 then 'Yes' else 'No' end  
		--Added By Mukti 19082015(end)							
		End
	Else if @Trans_Type = 'U'
 		begin
			If Exists(select Training_App_ID From T0100_HRMS_TRAINING_APPLICATION WITH (NOLOCK) Where Cmp_Id = @Cmp_Id and Login_ID = @Login_ID
											and For_Date=@For_Date and Training_id = @Training_id and Training_App_ID <> @Training_App_ID )
				begin
					set @Training_App_ID = 0
					return 
				end
			--Added By Mukti 19082015(start)	
				select 	@OldTraining_Desc= Training_Desc
							,@OldTraining_id = Training_id
							,@OldFor_Date= For_Date
							,@OldSkill_ID= Skill_ID
							,@OldApp_Status= App_Status
							,@OldLogin_ID=Login_ID
							,@OldTraining_Plan = case WHEN Training_Plan = 1 THEN 'Yes' ELSE 'No' end -- Added by Gadriwala Muslim 26122016
				from T0100_HRMS_TRAINING_APPLICATION WITH (NOLOCK)
				where Training_App_ID = @Training_App_ID
			--Added By Mukti 19082015(end)
			
				UPDATE    T0100_HRMS_TRAINING_APPLICATION
				SET          
							Training_Desc=@Training_Desc
							,Training_id = @Training_id
							,For_Date=@For_Date
							,Skill_ID=@Skill_ID
							,App_Status=@App_Status
							,cmp_id=@cmp_id
							,Login_ID=@Login_ID
							,Training_Plan = @training_Plan -- Added by Gadriwala Muslim 26122016
				where Training_App_ID = @Training_App_ID
				
			--Added By Mukti 19082015(start)
		    set @OldValue =  'Old Value' + '#'+ 'Training Id:' + cast(Isnull(@OldTraining_id,'') as varchar(25)) + '#' + 
												'Training Desc:' + cast(Isnull(@OldTraining_Desc,'') as varchar(25)) + '#' + 
												'For_Date:' + cast(Isnull(@OldFor_Date,'') as varchar(25)) + '#' + 
												'Posted Emp ID:' + cast(Isnull(@Posted_Emp_ID,0) as varchar(25)) + '#' + 
												'Skill ID:' + cast(Isnull(@OldSkill_ID,'') as varchar(25)) + '#' + 
												'App Status:' + cast(Isnull(@OldApp_Status,'') as varchar(25)) + '#' + 
												'Company id:' + cast(Isnull(@cmp_id,'') as varchar(25)) + '#' + 
												'Login ID:' + cast(Isnull(@OldLogin_ID,'') as varchar(25)) + '#' + 
												'Training_Plan:' + @OldTraining_Plan  + '#' + 
		                     'New Value' + '#'+ 'Training Id:' + cast(Isnull(@Training_id,0) as varchar(25)) + '#' + 
												'Training Desc:' + cast(Isnull(@Training_Desc,'') as varchar(25)) + '#' + 
												'For_Date:' + cast(Isnull(@For_Date,'') as varchar(25)) + '#' + 
												'Posted Emp ID:' + cast(Isnull(@Posted_Emp_ID,0) as varchar(25)) + '#' + 
												'Skill ID:' + cast(Isnull(@Skill_ID,0) as varchar(25)) + '#' + 
												'App Status:' + cast(Isnull(@App_Status,0) as varchar(25)) + '#' + 
												'Company id:' + cast(Isnull(@cmp_id,0) as varchar(25)) + '#' + 
												'Login ID:' + cast(Isnull(@Login_ID,0) as varchar(25)) + '#' + 
												'System Date:' + cast(getdate() as varchar(25)) + '#' + 
												'Training_Plan:' + CASE when @training_plan = 1 then 'Yes' else 'No' end 
		  --Added By Mukti 19082015(end)						
		end
	Else If @Trans_Type = 'D'
		 Begin
		 --Mukti(start)23072015
			if exists(select 1 from T0120_HRMS_TRAINING_APPROVAL WITH (NOLOCK) where Training_App_ID = @Training_App_ID and apr_status=1)
			begin
				RAISERROR ('Refrence exist', 16, 2)
				return  
			end
			--Mukti(end)23072015
			
			--Added By Mukti 19082015(start)	
				select 	@OldTraining_Desc= Training_Desc
							,@OldTraining_id = Training_id
							,@OldFor_Date= For_Date
							,@OldSkill_ID= Skill_ID
							,@OldApp_Status= App_Status
							,@OldLogin_ID=Login_ID
							,@OldTraining_Plan = case WHEN Training_Plan = 1 THEN 'Yes' ELSE 'No' end -- Added by Gadriwala Muslim 26122016
				from T0100_HRMS_TRAINING_APPLICATION WITH (NOLOCK)
				where Training_App_ID = @Training_App_ID
			--Added By Mukti 19082015(end)
			
				delete from T0130_HRMS_TRAINING_EMPLOYEE_DETAIL where Training_App_ID = @Training_App_ID and cmp_id=@Cmp_id
				Delete From T0100_HRMS_TRAINING_APPLICATION Where Training_App_ID = @Training_App_ID  and  cmp_id=@Cmp_id
				Delete from T0040_skill_Master where skill_ID=@Skill_ID and cmp_id=@Cmp_id
				
		 --Added By Mukti 19082015(start)
		    set @OldValue =  'Old Value' + '#'+ 'Training Id:' + cast(Isnull(@OldTraining_id,'') as varchar(25)) + '#' + 
												'Training Desc:' + cast(Isnull(@OldTraining_Desc,'') as varchar(25)) + '#' + 
												'For_Date:' + cast(Isnull(@OldFor_Date,'') as varchar(25)) + '#' + 
												'Posted Emp ID:' + cast(Isnull(@Posted_Emp_ID,0) as varchar(25)) + '#' + 
												'Skill ID:' + cast(Isnull(@OldSkill_ID,'') as varchar(25)) + '#' + 
												'App Status:' + cast(Isnull(@OldApp_Status,'') as varchar(25)) + '#' + 
												'Company id:' + cast(Isnull(@cmp_id,'') as varchar(25)) + '#' + 
												'Login ID:' + cast(Isnull(@OldLogin_ID,'') as varchar(25)) + '#' + 
												'Training_Plan:' + @OldTraining_Plan
		 --Added By Mukti 19082015(end)		
		 End
	exec P9999_Audit_Trail @Cmp_ID,@Trans_Type,'Training Application',@OldValue,@Training_App_ID,@User_Id,@IP_Address

RETURN
	



