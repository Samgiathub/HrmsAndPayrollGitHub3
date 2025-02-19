
---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[Rpt_Appraisal_Status]
	 @cmp_id    as numeric(18,0)
	,@SA_Startdate   as datetime 
	,@SA_Todate   as datetime
	,@Constraint	varchar(max)=''
	
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN

	if @Constraint =''
		set @Constraint =' and 1=1'
		
	declare @query varchar(max)
	set @query ='select IA.InitiateId,IA.SA_Status,IA.Overall_Status,E.Emp_Id,E.Emp_Full_Name as EmployeeName,E.Alpha_Emp_Code as EmployeeCode,convert(datetime,IA.SA_Startdate,103) as Startdate,convert(datetime,IA.SA_Enddate,103) as Enddate,B.Branch_Name as Branch,D.Dept_Name as Department,Dg.Desig_Name as Designation,G.Grd_Name as Grade
,case when IA.SA_Status=0 then ''Self Assessment Approval Pending'' 
	  When IA.SA_Status=4 then ''Self Assessment Not Submitted''
	  When IA.SA_Status=1 and IA.Overall_Status is null then ''Self Assessment Approved'' 
	  When IA.SA_Status=1 and IA.Overall_Status =0 then ''Performance Assessment Approved''
	  When IA.SA_Status=1 and IA.Overall_Status =1 then ''Group Head Approved''
	  When IA.SA_Status=1 and IA.Overall_Status =2 then ''Send for Reporting Review''
	  When IA.SA_Status=1 and IA.Overall_Status =3 then ''Sent For Final Approval''
	  When IA.SA_Status=1 and IA.Overall_Status =4 then ''Send for Group Head Review''
	  When IA.SA_Status=1 and IA.Overall_Status =6 then ''Approved by HOD''
	  When IA.SA_Status=1 and IA.Overall_Status =7 then ''Send for Group Head Approval By HOD''
      When IA.SA_Status=1 and IA.Overall_Status =5 then ''Approved''
      When IA.SA_Status=2 and IA.Overall_Status is null then ''Self Assessment Sent back for Review''
	end as ''Current Status''
  ,convert(datetime,IA.SA_SubmissionDate,103)''Employee Assessment SubmissionDate'' 
  ,convert(datetime,IA.SA_ApprovedDate,103)''Employee Assessment Approved Date''
  ,isnull((IA.ApprovedCode +''-''+ IA.Approved_Name),''Admin'') as ''Employee Assessment Approved By''  
   ,IA.PerApprovedBy as ''Performance Assessment Approved By''
 From V0050_HRMS_InitiateAppraisal IA 
inner join T0080_EMP_MASTER E WITH (NOLOCK) ON E.Emp_ID = IA.Emp_Id 
inner JOIN T0095_INCREMENT I WITH (NOLOCK) ON I.Emp_ID = E.Emp_ID and --I.Increment_Effective_Date = (select max(Increment_Effective_Date) from T0095_INCREMENT WITH (NOLOCK) where Increment_Effective_Date <= '''+ cast(@SA_Startdate as varchar(12))  +''' and emp_id = E.emp_id)
I.Increment_ID = (select max(i2.Increment_ID) from T0095_INCREMENT  i2 where i2.Emp_ID = I.Emp_ID
and i2.Increment_Effective_Date = (select max(i3.Increment_Effective_Date) from T0095_INCREMENT i3 WITH (NOLOCK) WHERE i3.Emp_ID = i2.Emp_ID and Increment_Effective_Date <= '''+ cast(@SA_Startdate as varchar(12))  +''' ))
left Join T0030_BRANCH_MASTER B WITH (NOLOCK) on B.Branch_ID = I.Branch_ID
left join T0040_DEPARTMENT_MASTER D WITH (NOLOCK) on D.Dept_Id = I.Dept_ID
left join T0040_DESIGNATION_MASTER DG WITH (NOLOCK) on DG.Desig_ID = I.Desig_Id
left join T0040_GRADE_MASTER G WITH (NOLOCK) on G.Grd_ID = I.Grd_ID
where IA.SA_Startdate >= '''+ cast(@SA_Startdate as varchar(12)) +''' and IA.SA_Startdate <= ''' +  cast(@SA_Todate as varchar(12)) + '''
and IA.cmp_Id=' + cast(@cmp_id as varchar(18))
	
	--print (@query + @Constraint)
	exec (@query + @Constraint)
	
END

