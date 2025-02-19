

-- =============================================
-- Author:		Siddharth Pathak
-- Create date: 22/05/2014
-- Description:	Export of Data On Home import
---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[SP_HOME_EXPORT_AS_PER_FORMAT]
	@Cmp_ID			numeric
	,@Export_Format	numeric = 0
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.

	if @Export_Format = 0
	begin
		select Alpha_emp_code as [Emp Code],Initial as [Initial Name],Emp_First_Name as [First Name],Emp_Second_Name as [Second Name],Emp_Last_Name as [Last Name],t2.Branch_Name as Branch,
		t3.Grd_Name as grade,t4.Dept_Name as Department,t5.Cat_Name as Category,t6.Desig_Name,t7.Type_Name as [Type],shift_name as [General Shift],Bank_Name as [Bank_Name],PAN_NO as [PAN NO],
		'' as [ESIC NO],'' as [PF NO],t1.Date_Of_Birth as DOB,t1.Marital_Status as [Merital Status],Gender,Nationality,t10.Loc_name as [Location],Street_1 as [Address], City,[State],zip_Code
		as [Post Box],Home_Tel_No as [Tel No],Mobile_No as [Mobile No],Work_Tel_No as [Work Tel No],Work_Email as [Work Email],Other_Email as [Other Email],Present_Street as [Address],
		Present_city as [City],Present_State as [State],Present_Post_Box as [Post Box],t11.basic_salary as Salary,t11.Gross_Salary,t11.Wages_Type,t11.Salary_Basis_On,t11.Payment_mode,
		t11.Inc_Bank_Ac_No as Emp_Bank_Ac_No,t11.Emp_OT,t11.Emp_OT_Min_Limit as Min_Limit,t11.Emp_OT_Max_Limit as Max_Limit,t11.Emp_Late_mark as Late_Mark,t11.Emp_Full_PF as Full_PF,
		t11.Emp_PT_Amount as [Prof. tax],t11.Emp_Fix_Salary as [Fix Salary],t1.Blood_Group,t1.Enroll_No,t1.Father_name,t9.Bank_BSR_Code as Bank_IFSC_NO,t1.Emp_Confirm_Date as Confirmation_Date,
		t1.Probation,Old_Ref_No,t1.Alpha_Code,Emp_Superior,Is_LWF,t11.Emp_WeekOff_OT_Rate as Weekoff_OT_Rate,t11.Emp_Holiday_OT_Rate as Holiday_OT_Rate,t12.Segment_name as Business_Segment,
		t13.Vertical_Name as Vertical,t14.subvertical_Name,'' [Group of Joining],t15.subbranch_Name as Sub_Branch,t16.Name as Salary_Cycle,
		t1.* from t0080_emp_master t1 WITH (NOLOCK)
		inner join (select i1.* from t0095_increment i1 WITH (NOLOCK)
					inner join (select emp_id,max(increment_effective_date) as idate from T0095_INCREMENT WITH (NOLOCK) group by Emp_ID) i2
					on i1.emp_id = i2.emp_id and i1.Increment_Effective_Date = i2.idate) as t11 on t1.emp_id = t11.emp_id and t1.cmp_id = t11.Cmp_ID 
		inner join t0030_branch_master t2 WITH (NOLOCK) on t11.cmp_id = t2.Cmp_ID and t11.Branch_ID = t2.Branch_ID 
		inner join T0040_GRADE_MASTER t3 WITH (NOLOCK) on t11.Cmp_ID = t2.Cmp_ID and t11.Grd_ID = t3.Grd_ID 
		Left Outer join T0040_DEPARTMENT_MASTER t4 WITH (NOLOCK) on t11.cmp_id = t4.cmp_ID and t11.Dept_ID = t4.Dept_Id 
		Left Outer join T0030_CATEGORY_MASTER t5 WITH (NOLOCK) on t11.cmp_id = t5.cmp_id and t11.Cat_ID = t5.Cat_ID 
		Inner Join T0040_designation_master t6 WITH (NOLOCK) on t11.Cmp_ID = t6.Cmp_ID and t11.Desig_Id = t6.Desig_ID 
		Inner Join T0040_TYPE_MASTER t7 WITH (NOLOCK) on t11.Cmp_ID = t2.Cmp_ID and t11.Type_ID = t7.Type_ID 
		left outer join (select s1.Emp_ID,s1.Cmp_ID,s2.shift_Name from T0100_EMP_SHIFT_DETAIL s1 WITH (NOLOCK)
					inner join T0040_SHIFT_MASTER s2 WITH (NOLOCK) on s1.shift_id = s2.shift_id
					inner join (select Emp_ID,max(for_Date) as For_Date from T0100_EMP_SHIFT_DETAIL WITH (NOLOCK)
								where for_Date<=getdate() and shift_type = 0 group by Emp_ID) s3 on s1.For_Date = s3.For_Date 
								and s1.Emp_ID = s3.Emp_ID) t8 on t1.cmp_ID = t8.cmp_ID and t1.emp_ID = t8.Emp_ID 
		left outer join T0040_BANK_MASTER t9 WITH (NOLOCK) on t1.bank_id= t9.Bank_ID and t1.Cmp_ID = t9.Cmp_Id
		inner join T0001_LOCATION_MASTER t10 WITH (NOLOCK) on t1.loc_id = t10.loc_id
		left outer join T0040_Business_Segment t12 WITH (NOLOCK) on t11.Segment_ID = t12.Segment_ID
		left outer join T0040_Vertical_Segment t13 WITH (NOLOCK) on t11.vertical_id = t13.vertical_id
		left outer join t0050_subvertical t14 WITH (NOLOCK) on t11.SubVertical_ID = t14.subvertical_id
		left outer join t0050_subbranch t15 WITH (NOLOCK) on t11.subbranch_id = t15.subbranch_id
		left outer join (select s1.*,s2.Name from t0095_emp_salary_cycle s1 WITH (NOLOCK)
						inner join T0040_Salary_Cycle_Master s2 WITH (NOLOCK)
						on s1.SalDate_id = s2.tran_ID
						inner join (select Emp_id,max(effective_date) as edate from t0095_emp_salary_cycle WITH (NOLOCK) group by Emp_id) s3
						on s1.emp_id = s3.Emp_id and s1.Effective_date = s3.edate) t16 on t11.emp_id = t16.Emp_id 
		where t11.Cmp_ID = @Cmp_ID 
	end
END

