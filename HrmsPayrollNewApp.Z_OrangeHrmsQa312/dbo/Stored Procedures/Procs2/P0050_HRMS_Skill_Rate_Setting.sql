



---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0050_HRMS_Skill_Rate_Setting]
@Skill_d_id numeric(18) output
,@cmp_id numeric(18)
,@Dept_Id numeric(18)
,@Branch_Id numeric(18)
,@Grd_id numeric(18)
,@desig_id numeric(18)
,@avg_Skill_Actual_Rate numeric(18,2)
,@avg_Skill_R_Rate_Min numeric(18,2)
,@avg_Skill_R_Rate_Max numeric(18,2)
,@skill_Eval_duration numeric(18)
,@for_date datetime
,@tran_type as char(1)            
           
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	if @cmp_id = 0 
	 set @cmp_id  = null
	if @dept_id=0
	 set @dept_id =null
	if @branch_id =0 
	 set @branch_id = null
	if @grd_id = 0 
	 set @grd_id = null
	if @desig_id = 0
	  set @desig_id = null
	  
	if Upper(@tran_type) ='I' 
		begin
		
			if exists (Select Skill_d_id  from dbo.T0050_HRMS_Skill_Rate_Setting WITH (NOLOCK) Where cmp_id=@CMP_ID AND branch_id=@branch_id AND dept_id = @dept_id AND desig_id=@desig_id AND Grd_id=@Grd_id)
				begin				
					set @Skill_d_id = 0					
						RAISERROR('Duplicate Setting',16,2)					
					RETURN 
				end
				
					select @Skill_d_id = isnull(max(Skill_d_id),0) + 1 from dbo.T0050_HRMS_Skill_Rate_Setting WITH (NOLOCK)
						
					insert into dbo.T0050_HRMS_Skill_Rate_Setting(
											Skill_d_id
											,cmp_id
											,Dept_Id
											,Branch_Id
											,Grd_id
											,desig_id
											,avg_Skill_Actual_Rate
											,avg_Skill_R_Rate_Min
											,avg_Skill_R_Rate_Max
											,skill_Eval_duration
											,fore_date
											) 
											
								values(@Skill_d_id
										,@Cmp_ID
										,@Dept_Id
										,@Branch_Id
										,@Grd_id
										,@desig_id
										,@avg_Skill_Actual_Rate
										,@avg_Skill_R_Rate_Min
										,@avg_Skill_R_Rate_Max
										,@skill_Eval_duration
										,@for_date										
										)
		end 
	else if upper(@tran_type) ='U' 
		begin
				delete from dbo.t0055_HRMS_Skill_Rate_Detail where Skill_d_id = @Skill_d_id 
				
				Update dbo.T0050_HRMS_Skill_Rate_Setting 
				Set 
					 avg_Skill_Actual_Rate=@avg_Skill_Actual_Rate
					,avg_Skill_R_Rate_Min=@avg_Skill_R_Rate_Min
					,avg_Skill_R_Rate_Max=@avg_Skill_R_Rate_Max
					,skill_Eval_duration=@skill_Eval_duration
					,fore_date=@for_date					
				where Skill_d_id = @Skill_d_id  
		end	
	else if upper(@tran_type) ='D'
		Begin
			if Exists(select Skill_d_id from dbo.t0055_HRMS_Skill_Rate_Detail WITH (NOLOCK) where Skill_d_id=@Skill_d_id)
				Begin
					delete from  dbo.t0055_HRMS_Skill_Rate_Detail where Skill_d_id=@Skill_d_id 
				End
				delete  from dbo.T0050_HRMS_Skill_Rate_Setting where Skill_d_id=@Skill_d_id 
		end
			
			
			
	RETURN




