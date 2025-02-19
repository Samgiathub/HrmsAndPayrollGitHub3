

---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[Rpt_ResumeAgainstJob]
	 @cmp_id as numeric(18,0)
	,@frmdate datetime
	,@todate datetime 
	,@condition as varchar(max)=''
	,@format varchar(50)
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
	
	
	if @condition = ''
	set @condition =' and 1=1'

	declare @query as varchar(max) 
	set @query =''
	
	IF @format='Resume Against Job'
		BEGIN		
			SET @query='select 
				Case When row_number() OVER ( PARTITION BY p.Rec_Post_Id  order by p.Rec_Post_Id ) = 1
				Then  cast(P.Job_title  AS varchar(100)) Else '''' End ''Job Title'',
				Case When row_number() OVER ( PARTITION BY p.Rec_Post_Id  order by p.Rec_Post_Id ) = 1
				Then  cast(P.Rec_Post_Code  AS varchar(100)) Else '''' End ''Job Code'',
				Case When row_number() OVER ( PARTITION BY p.Rec_Post_Id  order by p.Rec_Post_Id ) = 1
				Then  cast(convert(varchar(10),P.Rec_Post_date,105)  AS varchar(100)) Else '''' End ''Posted date'',
				Case When row_number() OVER ( PARTITION BY p.Rec_Post_Id  order by p.Rec_Post_Id ) = 1
				Then  cast(R.No_of_vacancies  AS varchar(100)) Else '''' End ''No of vacancies'',		
				Case When row_number() OVER ( PARTITION BY p.Rec_Post_Id  order by p.Rec_Post_Id ) = 1
				Then case when r.S_Emp_ID is null then ''Admin'' else e.Emp_Full_Name end  Else '''' End  ''Recruiter Name'',
				RM.Resume_Code,rm.Emp_First_Name + '' '' + rm.Emp_Last_Name as ''Applicant Name''
			,case when f.Resume_Status is null then case when rm.Resume_Status =2 then ''Reject'' when rm.Resume_Status =1 then ''Shortlisted'' when rm.Resume_Status=3 then ''On Hold'' else ''Pending'' end 
				else case when rm.Resume_Status =2 then ''Reject'' when rm.Resume_Status =1 then ''Approved'' when rm.Resume_Status=3 then ''On Hold'' else ''Pending'' end end as ''Resume Status''
			,case when f.Tran_ID is not null then case when f.Acceptance = 1 then ''Accepted'' when f.Acceptance=2 then ''Reject''  else '''' end else '''' end as ''Offer Status''		
			,case when isnull(f.Confirm_Emp_id,0) <>0  then ''Yes'' else null end as ''Converted as Employee''
			,convert(varchar(10),RE.Date_Of_Join,105) ''Joining Date'',Source_name as ''Source''
		from V0055_hrms_Resume_Master RM inner join 
			V0052_HRMS_Recruitment_Posted P On RM.Rec_Post_Id = P.Rec_Post_Id  inner join 
			T0050_HRMS_Recruitment_Request R WITH (NOLOCK) on R.Rec_Req_ID = P.Rec_Req_ID left JOIN
			T0080_EMP_MASTER E WITH (NOLOCK) on e.Emp_ID = R.S_Emp_ID left join 
			T0060_RESUME_FINAL F WITH (NOLOCK) on f.Resume_ID = Rm.Resume_Id and f.Rec_post_Id = P.Rec_Post_Id left JOIN
			T0080_EMP_MASTER RE WITH (NOLOCK) on Re.Emp_ID = f.Confirm_Emp_id
		where Rec_Post_date >= ''' + convert(varchar(10),@frmdate,120) + ''' and Rec_Post_date <= ''' + convert(varchar(10),@todate,120) +'''
		and P.Cmp_id =' + cast( @cmp_id  as varchar(18)) 

		--print (@query + @condition + ' ORDER  by p.Rec_Post_Id asc')
		exec(@query + @condition + ' ORDER  by p.Rec_Post_Id asc')
		END
	ELSE	
		BEGIN
			SELECT DISTINCT (ISNULL(RM.Initial,'') + '-' + ISNULL(RM.Emp_First_Name,'') + '-' + ISNULL(RM.Emp_Second_Name,'') + '-' + ISNULL(RM.Emp_Last_Name,''))Name_of_Candidate,
				QM.Qual_Name AS Qualification,RM.Total_Exp,dbo.F_GET_AGE(RM.Date_Of_Birth,GETDATE(),'Y','N') AS Age,
				RE.Desig_Name as Current_Designation,RE.Employer_Name as Current_Industry,RM.Cur_CTC as Current_CTC,
				CASE WHEN RF.Total_CTC=0 THEN RF.Basic_Salay ELSE RF.Total_CTC END AS Offered_CTC,PM.Process_Name,
				ISNULL(HI.Comments,'')Comments1,HI.Comments2,HI.Comments3,HI.Comments4
			FROM T0055_Resume_Master RM WITH (NOLOCK)
			INNER JOIN T0060_RESUME_FINAL RF WITH (NOLOCK) ON RM.Resume_Id=RF.Resume_ID
			INNER JOIN t0055_hrms_interview_schedule HI WITH (NOLOCK) ON HI.Resume_Id=RM.Resume_Id 
			LEFT JOIN
			(SELECT TOP 1 Qual_ID,Resume_ID FROM T0090_HRMS_RESUME_QUALIFICATION WITH (NOLOCK)) RQ ON RM.Resume_Id=RQ.Resume_ID
			LEFT JOIN T0040_QUALIFICATION_MASTER QM WITH (NOLOCK) ON RQ.Qual_ID=QM.Qual_ID
			LEFT JOIN T0090_HRMS_RESUME_EXPERIENCE RE WITH (NOLOCK) ON RE.Resume_ID=RM.Resume_Id
			LEFT JOIN T0055_Interview_Process_Detail PD WITH (NOLOCK) ON PD.Interview_Process_detail_ID=HI.Interview_Process_Detail_Id
			LEFT JOIN T0040_HRMS_R_PROCESS_MASTER PM WITH (NOLOCK) ON PM.Process_ID=PD.Process_ID
			WHERE RM.Cmp_ID=@CMP_ID --AND ISNULL(Emp_First_Name,'') <>''
		
		END
	
END

