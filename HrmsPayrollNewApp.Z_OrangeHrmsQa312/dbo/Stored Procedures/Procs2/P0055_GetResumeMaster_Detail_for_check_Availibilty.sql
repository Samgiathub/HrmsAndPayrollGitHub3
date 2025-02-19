


-- =============================================
-- Author:	Rohit Patel
-- ALTER date: 26 mar 2016
-- Description:	get Resume detail for check availibilty in existing employee.
-- exec P0055_GetResumeMaster_Detail_for_check_Availibilty 'R9:1079',0
-- exec P0055_GetResumeMaster_Detail_for_check_Availibilty '',18
---30/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0055_GetResumeMaster_Detail_for_check_Availibilty]
	@Resume_Code as varchar(50),
	@Resume_Id as int = null
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

Declare @Emp_First_Name as varchar(500)
Declare @Emp_Last_Name as varchar(500)
Declare @FatherName as varchar(500)
Declare @Date_of_Birth as Datetime
Declare @Mobile_No as varchar(100)
Declare @pancardNo as varchar(100)



select @Emp_First_Name = rm.Emp_First_Name 
,@Emp_Last_Name = Emp_Last_Name
,@FatherName = FatherName
,@Date_of_Birth = Date_of_Birth
,@Mobile_No = Mobile_No
,@pancardNo = pancardNo
 from v0055_hrms_Resume_Master rm where rm.Resume_Id = @Resume_Id; 
	

select ROW_NUMBER() OVER(ORDER BY alpha_emp_code asc) AS SrNo,  * from 
(	
Select t0080_emp_master.Emp_ID ,Alpha_Emp_Code,Emp_full_name,Cmp_Name,'Candidate First Name Last name and Father Name Is Same with Existing Employee.' as remarks 
,case when isnull(le.Emp_ID,0)=0 then 'Current Employee' else  case when isnull(Le.Is_Terminate,0) =1 then ' Left(Terminate) employee' else 'Left Employee' end end as Left_Emp
from t0080_emp_master WITH (NOLOCK) inner join t0010_company_master WITH (NOLOCK) on t0080_emp_master.cmp_id = t0010_company_master.cmp_id
left Join T0100_LEFT_EMP LE WITH (NOLOCK) on  t0080_emp_master.Emp_ID = LE.Emp_ID
where upper(emp_first_name) = upper(@Emp_First_Name) and upper(emp_Last_Name) = upper(@Emp_Last_Name) and upper(Father_Name) = upper(@FatherName) 

union 

Select t0080_emp_master.emp_id,Alpha_Emp_Code,Emp_full_name,Cmp_Name ,'Candidate Date Of Birth Same With Existing Employee.' as Remarks 
,case when isnull(le.Emp_ID,0)=0 then 'Current Employee' else  case when isnull(Le.Is_Terminate,0) =1 then ' Left(Terminate) employee' else 'Left Employee' end end as Left_Emp
from t0080_emp_master WITH (NOLOCK) inner join t0010_company_master WITH (NOLOCK) on t0080_emp_master.cmp_id = t0010_company_master.cmp_id  
left Join T0100_LEFT_EMP LE WITH (NOLOCK) on  t0080_emp_master.Emp_ID = LE.Emp_ID
where Date_of_Birth = @Date_of_Birth and upper(emp_Last_Name) = upper(@Emp_Last_Name)
union 

Select t0080_emp_master.emp_id,Alpha_Emp_Code,Emp_full_name,Cmp_Name, 'Candidate Mobile No Same With Existing Employee.' as Remarks 
,case when isnull(le.Emp_ID,0)=0 then 'Current Employee' else  case when isnull(Le.Is_Terminate,0) =1 then ' Left(Terminate) employee' else 'Left Employee' end end as Left_Emp
from t0080_emp_master WITH (NOLOCK) inner join t0010_company_master WITH (NOLOCK) on t0080_emp_master.cmp_id = t0010_company_master.cmp_id  
left Join T0100_LEFT_EMP LE WITH (NOLOCK) on  t0080_emp_master.Emp_ID = LE.Emp_ID
where Mobile_No = @Mobile_No 
union 

Select t0080_emp_master.emp_id,Alpha_Emp_Code,Emp_full_name,Cmp_Name,'Candidate Pancard No Same With Existing Employee.' as Remarks 
,case when isnull(le.Emp_ID,0)=0 then 'Current Employee' else  case when isnull(Le.Is_Terminate,0) =1 then ' Left(Terminate) employee' else 'Left Employee' end end as Left_Emp
from t0080_emp_master WITH (NOLOCK) inner join t0010_company_master WITH (NOLOCK) on t0080_emp_master.cmp_id = t0010_company_master.cmp_id  
left Join T0100_LEFT_EMP LE WITH (NOLOCK) on  t0080_emp_master.Emp_ID = LE.Emp_ID
where pan_no = @pancardNo 
 
) Temp order by Alpha_Emp_Code
		
END


