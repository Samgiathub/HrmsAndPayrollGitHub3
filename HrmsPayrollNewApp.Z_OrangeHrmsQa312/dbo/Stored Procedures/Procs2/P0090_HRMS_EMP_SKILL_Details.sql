


---23/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---

CREATE PROCEDURE [dbo].[P0090_HRMS_EMP_SKILL_Details]
	  @Emp_ID Numeric	
     ,@Cmp_ID Numeric
     ,@start_date datetime
     ,@end_date datetime
As			   		   
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	Declare @Temp table
   (
		skill_name varchar(50),
		Emp_Skill_ID numeric(18),--sneha on 1 st apr 2013
		Skill_Id Numeric(18),
		Emp_ID Numeric(18),
        Evaluation_Rate Numeric(18,2),
        Skill_Actual_Rate Numeric(18,2) ,
        Skill_Rate_Employee Numeric(18,2) ,
        Skill_Rate_Superior   Numeric(18,2)            
    )	 			    
    Declare @Max_Rate Numeric(18,2)
    
    --insert into @temp --(Skill_Name,Skilll_Rate_Given,Skill_Id,Cmp_Id,For_Date,Emp_Id,S_Emp_Id,Login_Id,Status,Emp_Full_Name,Emp_Code)values(
    --select * from V0090_Hrms_Emp_Skill_Setting        
    
    select @Max_Rate = max(Rate_Value) from T0030_HRMS_RATING_MASTER WITH (NOLOCK) where Cmp_Id=@Cmp_ID
   --select count(skill_name) as Skill_Mapping_Count,skill_Id,cmp_Id,count(skill_name)*@Max_Rate as Total_Rate ,sum(Skilll_Rate_Given)as Evaluation_Rate,Skill_Name from v0090_hrms_emp_skill_setting group by Skill_Id,emp_id,Cmp_Id,Skill_Name having emp_id=@Emp_ID 
    insert into @Temp(skill_name,Emp_Skill_ID,Skill_Id,Emp_ID,Evaluation_Rate,Skill_Actual_Rate,Skill_Rate_Employee,Skill_Rate_Superior)
	select skill_name,Emp_Skill_ID,skill_id,emp_id,Skilll_Rate_Given,Skill_Actual_Rate,Skill_Rate_Employee,Skill_Rate_Superior
 from V0090_HRMS_EMP_SKILL_SETTING where for_date>=@start_date and for_date<=@end_date and cmp_id=@cmp_id and emp_id=@emp_id 
	--select * from @Temp
	select count(skill_id) as Skill_Mapping_Count,Emp_Skill_ID as Emp_Skill_ID,sum(Evaluation_Rate) as Evaluation_Rate,sum(Skill_Actual_Rate) as Skill_Actual_Rate ,skill_id ,skill_name,emp_id,Skill_Rate_Superior,Skill_Rate_Employee,@Max_Rate as MaxRate from @Temp group by emp_id,skill_id,Emp_Skill_ID,skill_name,Skill_Rate_Employee,Skill_Rate_Superior
    
	RETURN

