




--nikunj
---25/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0090_HRMS_EMP_SKILL_SETTING_View]
	   @Cmp_ID Numeric
	--,@Emp_ID Numeric	
As
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	--Declare @Temp table
    --(
     --  Skill_Name Varchar(50),
      -- Skilll_Rate_Given Numeric(18),
       --Skill_Id Numeric(18),
       --Skill_R_Id Numeric(18),
       --Cmp_Id Numeric(18),
       --For_Date DateTime,
       --Emp_ID Numeric(18),
       ---S_Emp_ID Numeric(18),
       --Login_Id Numeric(18),
       --Status Numeric(18),
       --Emp_Full_Name Varchar(50),
       --Emp_Code Numeric(18)              
    --)	 			    
    Declare @Max_Rate Numeric(18)
    
    --insert into @temp --(Skill_Name,Skilll_Rate_Given,Skill_Id,Cmp_Id,For_Date,Emp_Id,S_Emp_Id,Login_Id,Status,Emp_Full_Name,Emp_Code)values(
    --select * from V0090_Hrms_Emp_Skill_Setting        
    
    select @Max_Rate = max(Rate_Value) from T0030_HRMS_RATING_MASTER WITH (NOLOCK) where Cmp_Id=@Cmp_ID
    select count(skill_name) as Skill_Mapping_Count,skill_Id,cmp_Id,count(skill_name)*@Max_Rate as Total_Rate ,sum(Skilll_Rate_Given)as Evaluation_Rate,Skill_Name from v0090_hrms_emp_skill_setting group by Skill_Id,Cmp_Id,Skill_Name    
    
	RETURN




