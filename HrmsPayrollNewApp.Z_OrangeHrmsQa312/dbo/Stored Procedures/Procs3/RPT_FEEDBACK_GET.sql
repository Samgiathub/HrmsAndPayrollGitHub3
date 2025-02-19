CREATE PROCEDURE [dbo].[RPT_FEEDBACK_GET]
	@Cmp_id numeric,
	@Emp_id numeric,
	@Process_id numeric,
	@Resume_id1 numeric,
	@rec_post_id1 numeric,
	@approve_by varchar(100),
	@approve_date datetime
as
BEGIN
	SET NOCOUNT ON;
	
		DECLARE @INDUCTION_FEEDBACK AS INT
        SET @INDUCTION_FEEDBACK = 0
        
        SELECT @INDUCTION_FEEDBACK=1
		FROM T0040_HRMS_R_PROCESS_MASTER 
        WHERE UPPER(Process_Name)='INDUCTION FEEDBACK' AND Process_ID=@Process_id
        
        if @INDUCTION_FEEDBACK =0 
			BEGIN				
				select distinct isnull(rm.emp_first_name,'') + ' ' + isnull(rm.emp_second_name,'') + ' ' + rm.emp_last_name as Emp_Full_Name,
					'' as Alpha_Emp_Code,0 as Total_score,HPR.QUE_Detail,
					fd.Emp_id,@approve_by as Login_Name,@approve_date as approve_date,fd.[Description],	
					hr.Job_title,hr.Rec_Post_Code,rm.Resume_Code,GETDATE() as date1,
					pr.Process_Name,cm.Cmp_Name,HPR.Dis_No,cast(fd.Rating AS NUMERIC(18,2))Rating,HPR.Question_Type,FD.Interview_Schedule_Id,HIS.Comments,
					CASE WHEN [Status]=1 then 'Approved' WHEN [Status]=2 then 'Rejected' ELSE 'Hold' END AS [Status]
				from T0055_Resume_Master RM  WITH (NOLOCK)
				INNER JOIN T0055_Interview_Process_Question_Detail IQ WITH (NOLOCK) ON IQ.Process_ID=@Process_id AND rm.Rec_Post_Id=IQ.Rec_Post_Id
				INNER JOIN V0045_HRMS_R_PROCESS_TEMPLATE HPR ON HPR.Process_Q_ID=IQ.Process_Q_ID and hpr.Process_ID=@Process_id 
				INNER JOIN T0055_HRMS_Interview_Schedule HIS WITH (NOLOCK) ON HIS.Resume_Id=RM.Resume_Id --AND HIS.Rec_Post_Id=RM.Rec_Post_Id
				LEFT JOIN v0060_Hrms_Interview_Feedback_detail fd on fd.rec_post_id=@rec_post_id1 and fd.Process_Q_ID=IQ.Process_Q_ID
				and fd.Interview_Schedule_Id=HIS.Interview_Schedule_Id	
				INNER join V0052_HRMS_Recruitment_Posted hr on rm.Rec_Post_Id=hr.Rec_Post_Id and RM.Cmp_id=hr.Cmp_id
				INNER join T0040_HRMS_R_PROCESS_MASTER pr WITH (NOLOCK) on pr.Process_ID=@Process_id and pr.Cmp_id=RM.Cmp_id
				INNER join  T0045_HRMS_R_PROCESS_TEMPLATE p WITH (NOLOCK) on iq.Process_Q_ID=p.Process_Q_ID and rm.Cmp_id=p.Cmp_ID 
				and p.Process_ID=@Process_id
				INNER join T0010_COMPANY_MASTER cm WITH (NOLOCK) on cm.Cmp_Id=RM.Cmp_Id			
				where RM.cmp_id=@Cmp_id   and RM.rec_post_id=@rec_post_id1 AND RM.Resume_Id=@Resume_id1 AND FD.Interview_Schedule_Id  IS NOT NULL
				ORDER BY HPR.Dis_No
			END
		ELSE
			BEGIN
					select distinct  isnull(rm.Initial,'') + ' ' + isnull(rm.emp_first_name,'') + ' ' + isnull(rm.emp_second_name,'') + ' ' + rm.emp_last_name as Emp_Full_Name,
						'' as Alpha_Emp_Code,fd.Rating,0 as Total_score,fd.[Description],
						CASE WHEN ISNULL(HPR.QUE_Detail,'') <> '' THEN HPR.QUE_Detail ELSE p.QUE_Detail END AS QUE_Detail,
						fd.Emp_id,fd.Feedback_detail_id,@approve_by as Login_Name,@approve_date as approve_date,	
						hr.Job_title,hr.Rec_Post_Code,rm.Resume_Code,GETDATE() as date1, 
						pr.Process_Name,cm.Cmp_Name,HIS.Comments,[Status]
					from T0055_Resume_Master RM	WITH (NOLOCK)				
					LEFT join v0060_Hrms_Interview_Feedback_detail fd on fd.rec_post_id=@rec_post_id1 --and fd.resume_id=@Resume_id1
					LEFT join V0045_HRMS_R_PROCESS_TEMPLATE HPR ON HPR.Process_ID=FD.Process_ID AND HPR.Question_Type='Title'
					LEFT join V0052_HRMS_Recruitment_Posted hr on fd.Rec_Post_Id=hr.Rec_Post_Id and RM.Cmp_id=hr.Cmp_id
					LEFT join T0040_HRMS_R_PROCESS_MASTER pr WITH (NOLOCK) on pr.Process_ID=@Process_id and pr.Cmp_id=RM.Cmp_id
					LEFT join  T0045_HRMS_R_PROCESS_TEMPLATE p WITH (NOLOCK) on fd.Process_Q_ID=p.Process_Q_ID and p.Process_ID=@Process_id
					INNER join T0010_COMPANY_MASTER cm WITH (NOLOCK) on cm.Cmp_Id=RM.Cmp_Id
					INNER JOIN T0055_Interview_Process_Detail IPD WITH (NOLOCK) ON IPD.Interview_Process_detail_ID=@Process_id
					LEFT JOIN t0055_hrms_interview_schedule HIS WITH (NOLOCK) ON HIS.Rec_Post_Id=FD.Rec_Post_Id and HIS.Resume_Id=@Resume_id1 AND ISNULL(HIS.Comments,'')<>'' AND HIS.Interview_Process_Detail_Id=IPD.Interview_Process_detail_ID
					where RM.cmp_id=@Cmp_id and RM.Resume_Id=@Resume_id1
					
			END

	--SELECT distinct isnull(rm.Initial,'') + ' ' + isnull(rm.emp_first_name,'') + ' ' + isnull(rm.emp_second_name,'') + ' ' + rm.emp_last_name as Emp_Full_Name,
	--'' as Alpha_Emp_Code,l.Rating,i_q.[Description],p.QUE_Detail,
	--i_q.Emp_id,i_q.Feedback_detail_id,
	--@approve_by as Login_Name,@approve_date as approve_date,	
	--hr.Job_title,hr.Rec_Post_Code,rm.Resume_Code,GETDATE() as date1,his.Comments, CASE WHEN his.[Status] = 1 THEN 'Approve' When his.[Status] = 2 THEN 'Reject' When his.[Status] = 3 THEN 'Hold' ELSE '' END AS 
	--[Status],pr.Process_Name
	--from T0060_Hrms_Interview_Feedback_detail fd inner join
	--(select distinct I.Emp_Id ,i.Process_Q_ID,Cmp_id,Rec_Post_Id,Rating,[Description],i.Feedback_detail_id,i.Interview_Schedule_Id  from T0060_Hrms_Interview_Feedback_detail I inner join 
	--	(select max(Feedback_detail_id) as Feedback_detail_id,emp_id ,Process_Q_ID from T0060_Hrms_Interview_Feedback_detail
	--				where Cmp_ID = @Cmp_id and Emp_id=@Emp_id group by Process_Q_ID,Emp_id ) Qry on
	-- Qry.Emp_id=@Emp_id and i.Emp_id=@Emp_id and i.Feedback_detail_id=Qry.Feedback_detail_id) i_q on  i_q.Emp_id=@Emp_id 
	--inner join  T0045_HRMS_R_PROCESS_TEMPLATE p on i_q.Process_Q_ID=p.Process_Q_ID and i_q.Cmp_id=p.Cmp_ID and p.Process_ID=@Process_id
	--inner join T0040_HRMS_R_PROCESS_MASTER pr on pr.Process_ID=@Process_id and pr.Cmp_id=@Cmp_id
	--inner join V0052_HRMS_Recruitment_Posted hr on i_q.Rec_Post_Id=hr.Rec_Post_Id and i_q.Cmp_id=hr.Cmp_id
	--inner join T0055_Resume_Master rm on rm.Resume_Id=@Resume_id1
	--inner join t0055_hrms_interview_schedule his on his.Resume_Id=@Resume_id1 and his.Cmp_ID=@Cmp_id and his.Interview_Schedule_Id=i_q.Interview_Schedule_Id
	--inner join dbo.v0060_Hrms_Interview_Feedback_detail l ON his.Interview_Schedule_Id =l.Interview_Schedule_Id  and l.Cmp_id=his.Cmp_ID 
	--where i_q.Emp_id=@Emp_id and p.Process_ID=@Process_id and hr.Rec_Post_Id=@rec_post_id1 order by p.QUE_Detail desc
END


