



---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0100_TRAINING_APPLICATION]
 @Training_App_Id numeric(18,0) OUTPUT
,@Cmp_Id numeric(18,0)
,@Training_Title varchar(50) 
,@Training_Desc varchar(200)
,@For_Date datetime
,@Posted_Emp_ID numeric(18,0)
,@Skill_ID numeric(18,0)
,@App_Status varchar(1)
,@tran_type varchar(1)
,@Login_ID numeric(18,0)

AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

if @tran_type = 'I'
	Begin
	     if exists(select Training_App_ID from t0100_training_application WITH (NOLOCK) where upper(Training_Title) = upper(@Training_Title) 
		 and For_Date=@For_Date and Posted_Emp_ID=@Posted_Emp_ID and Skill_ID=@Skill_ID and App_Status=@App_Status And Cmp_ID=@Cmp_Id)
		begin
			  set @Training_App_ID = 0
			  Return 
		end
								
		select @Training_App_ID = Isnull(max(Training_App_ID),0) + 1 From t0100_training_application WITH (NOLOCK)
	  
										
		INSERT INTO t0100_training_application	
			    (Training_App_Id,Training_Title,Training_Desc,For_Date,Posted_Emp_ID,Skill_ID,App_Status,Cmp_Id,Login_ID,System_Date)
                   		VALUES(@Training_App_Id,@Training_Title,@Training_Desc,@For_Date,@Posted_Emp_ID,@Skill_ID,@App_Status,@Cmp_Id,@Login_Id,GEtdate())
	
	 Select * from t0100_training_application WITH (NOLOCK)
	End
					
ELSE if @tran_type = 'U'
			Begin
							if exists(select Training_App_ID from t0100_training_application WITH (NOLOCK) where upper(Training_Title) = upper(@Training_Title) 
									  and For_Date=@For_Date and Posted_Emp_ID=@Posted_Emp_ID and Skill_ID=@Skill_ID And Training_App_ID<>@Training_App_ID And Cmp_Id=@Cmp_Id)
								begin
										set @Training_App_ID = 0
										Return 
								end
							if Exists (select Training_App_ID from t0100_training_application WITH (NOLOCK) where Training_App_ID=@Training_App_ID And App_Status <> 'N')
								begin
										set @Training_App_ID = 0
										Return 
								end			
										
										UPDATE t0100_training_application
										set Training_Title=@Training_Title,
										Training_Desc=@Training_Desc,
										For_Date=@For_Date,
										Posted_Emp_ID=@Posted_Emp_ID,
										Skill_ID=@Skill_ID,
										App_Status=@App_Status,
										System_Date=GEtdate()
         									
										where Training_App_ID=@Training_App_ID And Cmp_Id=@Cmp_Id
										
								delete from t0110_training_application_Detail where Training_App_ID=@Training_App_ID 
										
					End
	else if @tran_type = 'D'
					Begin
						if Not exists(select Training_Apr_ID from t0120_training_Approval WITH (NOLOCK) where Training_App_ID=@Training_App_ID And Cmp_Id=@Cmp_id)
							begin
								delete from t0110_training_application_Detail where Training_App_ID = @Training_App_ID
								delete from t0100_training_application where Training_App_ID = @Training_App_ID
							end	
						else
								Set @Training_App_Id=0
								Return
						
							
					END
				RETURN




