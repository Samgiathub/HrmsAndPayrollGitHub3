

-- =============================================
-- Author:		Mukti chauhan
-- Create date: 29-01-2016
---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[RPT_Recruitment_Budget_Report]
	 @cmp_id as numeric(18,0)
	,@frmdate datetime
	,@todate datetime 
	,@condition as varchar(max)=''
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
		
	if @condition = ''
	set @condition =' and 1=1'
	declare @query as varchar(max) 
	set @query =''
	
	set @query='select hp.Rec_Post_Code as Job_Code,hr.Job_Title,convert(varchar(15),Posted_date,103) as Application_Date,
				convert(varchar(15),hp.Rec_Start_date,103) as Opening_From_date,convert(varchar(15),hp.Rec_End_date,103) as Opening_To_date,jm.Job_Code as Job_Description_Code,
				Branch_Name,Desig_Name as Designation,Dept_Name as Department,gm.Grd_Name as Grade,sv.SubVertical_Name,
				[Type_Name] as Employee_Type,case when ISNULL(Type_Of_Opening,0)=0 then '''' when ISNULL(Type_Of_Opening,0)=1 then ''New Opening'' 
				when ISNULL(Type_Of_Opening,0)=2 then ''Replacement Opening'' end as Type_Of_Opening,
				case when ISNULL(Budgeted,0)=0 then ''No'' when ISNULL(Budgeted,0)=1 then ''Yes'' end as Budgeted,
				hr.Branch_id,hr.Dept_Id,hr.Grade_Id,hr.Type_ID,DATEDIFF(DAY,hp.Rec_Start_date,hp.Rec_End_date)Turn_Over_Time
				from V0050_HRMS_Recruitment_Request hr
				left join  T0050_JobDescription_Master jm WITH (NOLOCK) on hr.JD_CodeId=jm.Job_Id
				left join  T0040_GRADE_MASTER gm WITH (NOLOCK) on gm.Grd_ID=hr.Grade_Id
				left join  T0050_SubVertical sv WITH (NOLOCK) on sv.SubVertical_ID=hr.SubVertical_Id
				left join T0052_HRMS_Posted_Recruitment hp WITH (NOLOCK) on hp.Rec_Req_ID=hr.Rec_Req_ID
				where Posted_date >= ''' + convert(varchar(10),@frmdate,120) + ''' and Posted_date <= ''' + convert(varchar(10),@todate,120) +'''
				and hr.Cmp_id =' + cast( @cmp_id  as varchar(18)) 

--print (@query + @condition + ' ORDER  by hr.Rec_Req_ID asc')
	exec(@query + @condition + ' ORDER  by hr.Rec_Req_ID asc')
END

