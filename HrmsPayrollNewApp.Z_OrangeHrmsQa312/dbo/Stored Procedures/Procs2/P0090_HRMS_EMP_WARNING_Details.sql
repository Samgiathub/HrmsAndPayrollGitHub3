


---25/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---

CREATE PROCEDURE [dbo].[P0090_HRMS_EMP_WARNING_Details]
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
		War_Name      varchar(50),
		Deduct_Rate   Numeric(18),
		Warr_Date     DateTime,
        Warr_Reason   Varchar(50),
        Issue_By      Varchar(50),  
        Authorised_By Varchar(50)         
    )	 			    
    
    --Declare @Max_Rate Numeric(18)    
    --insert into @temp --(Skill_Name,Skilll_Rate_Given,Skill_Id,Cmp_Id,For_Date,Emp_Id,S_Emp_Id,Login_Id,Status,Emp_Full_Name,Emp_Code)values(
    --select * from V0090_Hrms_Emp_Skill_Setting            
    
   --select count(skill_name) as Skill_Mapping_Count,skill_Id,cmp_Id,count(skill_name)*@Max_Rate as Total_Rate ,sum(Skilll_Rate_Given)as Evaluation_Rate,Skill_Name from v0090_hrms_emp_skill_setting group by Skill_Id,emp_id,Cmp_Id,Skill_Name having emp_id=@Emp_ID 
    insert into @Temp(War_Name,Deduct_Rate,Warr_Date ,Warr_Reason,Issue_By,Authorised_By)
	select War_Name,Deduct_Rate,Warr_Date,Warr_Reason,Issue_By,Authorised_By from V0100_Warning_Details where Warr_Date Between @start_date and  @end_date and cmp_id=@cmp_id and emp_id=@emp_id 
	
	select Count(War_Name)As Warming_Count,War_Name,sum(Deduct_Rate) as Deduct_Rate,Warr_Date,Warr_Reason,Issue_By,Authorised_By  from @Temp group by War_Name,Warr_Date,Warr_Reason,Issue_By,Authorised_By    
	RETURN




