



---19/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0055_HRMS_Skill_Rate_Detail]
@skill_Detail_Id		numeric(18) output
,@Skill_ID				numeric(18,0)
,@Skill_d_id			numeric(18) 
,@Skill_Actual_Rate		numeric(18,2)
,@Skill_R_Rate_Min		numeric(18,2)
,@Skill_R_Rate_Max		numeric(18,2)
,@tran_type				char
            
           
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	if Upper(@tran_type) ='I' 
		begin		
			if @Skill_d_id = 0
				Begin	
					set @skill_Detail_Id = 0
					Return							
				End
		
			if exists (Select skill_Detail_Id  from T0055_HRMS_Skill_Rate_Detail WITH (NOLOCK) Where Skill_ID = @Skill_ID And Skill_d_id = @Skill_d_id) 
				begin				
					set @skill_Detail_Id = 0
					RETURN 
				end
					select @skill_Detail_Id = isnull(max(skill_Detail_Id),0) + 1 from T0055_HRMS_Skill_Rate_Detail WITH (NOLOCK)
						
					insert into T0055_HRMS_Skill_Rate_Detail
											(
											skill_Detail_Id
											,Skill_ID
											,Skill_d_id
											,Skill_Actual_Rate
											,Skill_R_Rate_Min
											,Skill_R_Rate_Max
											) 
											
					values(
							@skill_Detail_Id
							,@Skill_ID
							,@Skill_d_id
							,@Skill_Actual_Rate
							,@Skill_R_Rate_Min
							,@Skill_R_Rate_Max
							)

		end 
	else if upper(@tran_type) ='U' 
	begin
			select @skill_Detail_Id = isnull(max(skill_Detail_Id),0) + 1 from T0055_HRMS_Skill_Rate_Detail WITH (NOLOCK)
						
					insert into T0055_HRMS_Skill_Rate_Detail
											(
											skill_Detail_Id
											,Skill_ID
											,Skill_d_id
											,Skill_Actual_Rate
											,Skill_R_Rate_Min
											,Skill_R_Rate_Max
											) 
											
					values(
							@skill_Detail_Id
							,@Skill_ID
							,@Skill_d_id
							,@Skill_Actual_Rate
							,@Skill_R_Rate_Min
							,@Skill_R_Rate_Max
							)

					
				/*Update T0055_HRMS_Skill_Rate_Detail 
				Set 
				Skill_d_id=@Skill_d_id
					,Skill_Actual_Rate=@Skill_Actual_Rate
					,Skill_R_Rate_Min=@Skill_R_Rate_Min
					,Skill_R_Rate_Max=@Skill_R_Rate_Max
				where skill_Detail_Id = @skill_Detail_Id  */
		end	
	else if upper(@tran_type) ='D'
		Begin
		delete  from T0055_HRMS_Skill_Rate_Detail where skill_Detail_Id=@skill_Detail_Id 
		end
			
	RETURN




