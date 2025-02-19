
---20/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_GET_RESUME_FEEDBACK]  
    @Cmp_ID  Numeric (18,0) 
   ,@rec_post_id Numeric (18,0) 
   ,@resume_ID Numeric (18,0) 
  
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	if @resume_ID=0
		set @resume_ID=null
	if @rec_post_id=0
		set @rec_post_id=null
	if @Cmp_ID=0
	    set @Cmp_ID=null
	 
	  select distinct isnull(gender,'M') as gender,p.position,Q.primary_email,mobile_no,
	  q.Date_Of_Birth,Q.Cur_CTC,q.file_name,p.rec_post_code,p.job_title,Q.resume_code,
	   Q.emp_first_name + ' ' + isnull(Q.Emp_Second_Name,'')  + ' '+ Q.emp_last_name  as emp_name,
	  Q.Total_Exp,isnull(h.emp_file_name,'')emp_file_name	   
	  from v0055_HRMS_Interview_Schedule  E
	 left outer join t0055_resume_master Q WITH (NOLOCK) on E.Resume_id=Q.resume_id 
	 left join T0052_HRMS_Posted_Recruitment p WITH (NOLOCK) on p.Rec_Post_Id = e.Rec_Post_Id --added by sneha on 6 july to display jobtitle of employees without interview process
	 left join T0090_HRMS_RESUME_EXPERIENCE re WITH (NOLOCK) on re.Resume_ID=Q.Resume_Id
	 left join T0090_HRMS_RESUME_HEALTH h WITH (NOLOCK) on h.Resume_ID=Q.Resume_Id --added on 11 Sep 2015
	 where E.cmp_id=isnull(@Cmp_ID,E.cmp_id)  and E.rec_post_id=isnull(@rec_post_id,E.rec_post_id) and E.resume_ID=isnull(@resume_ID,E.resume_ID) 	 
	 --and isnull(E.status,0)<>0
	
	DECLARE @Interview_Schedule_Id AS INT
	SELECT @Interview_Schedule_Id=Interview_Schedule_Id FROM v0055_HRMS_Interview_Schedule WHERE  cmp_id=isnull(@Cmp_ID,cmp_id)  
	and rec_post_id=isnull(@rec_post_id,rec_post_id) AND resume_ID=isnull(@resume_ID,resume_ID)

	--INSERT INTO #PROCESS_RATING
	SELECT IFD1.TOT_RATING1,IFD2.TOT_RATING2,IFD3.TOT_RATING3,IFD4.TOT_RATING4
	INTO #PROCESS_RATING
	FROM v0055_HRMS_Interview_Schedule HIS
	INNER JOIN T0040_HRMS_General_Setting HG WITH (NOLOCK) on HIS.rec_post_id=HG.rec_post_id AND HIS.Process_ID=HG.Process_ID
	LEFT JOIN 
	(SELECT SUM(RATING)AS TOT_RATING1,Rec_Post_Id,Interview_Schedule_Id,Emp_id FROM T0060_Hrms_Interview_Feedback_detail
	 GROUP BY Emp_id,Rec_Post_Id,Interview_Schedule_Id)IFD1 ON IFD1.Rec_Post_Id=HIS.Rec_Post_Id AND IFD1.Interview_Schedule_Id=HIS.Interview_Schedule_Id  AND HIS.S_Emp_Id=IFD1.Emp_id
	LEFT JOIN 
	(SELECT SUM(RATING)AS TOT_RATING2,Rec_Post_Id,Interview_Schedule_Id,Emp_id FROM T0060_Hrms_Interview_Feedback_detail
	 GROUP BY Emp_id,Rec_Post_Id,Interview_Schedule_Id)IFD2 ON IFD2.Rec_Post_Id=HIS.Rec_Post_Id AND IFD2.Interview_Schedule_Id=HIS.Interview_Schedule_Id AND HIS.S_Emp_Id2=IFD2.Emp_id
	LEFT JOIN 
	(SELECT SUM(RATING)AS TOT_RATING3,Rec_Post_Id,Interview_Schedule_Id,Emp_id FROM T0060_Hrms_Interview_Feedback_detail
	 GROUP BY Emp_id,Rec_Post_Id,Interview_Schedule_Id)IFD3 ON IFD3.Rec_Post_Id=HIS.Rec_Post_Id AND IFD3.Interview_Schedule_Id=HIS.Interview_Schedule_Id AND HIS.S_Emp_Id3=IFD3.Emp_id
	LEFT JOIN 
	(SELECT SUM(RATING)AS TOT_RATING4,Rec_Post_Id,Interview_Schedule_Id,Emp_id FROM T0060_Hrms_Interview_Feedback_detail
	 GROUP BY Emp_id,Rec_Post_Id,Interview_Schedule_Id)IFD4 ON IFD3.Rec_Post_Id=HIS.Rec_Post_Id AND IFD4.Interview_Schedule_Id=HIS.Interview_Schedule_Id AND HIS.S_Emp_Id4=IFD4.Emp_id
	WHERE  HIS.cmp_id=isnull(@Cmp_ID,HIS.cmp_id)  and HIS.rec_post_id=isnull(@rec_post_id,HIS.rec_post_id) AND HIS.resume_ID=isnull(@resume_ID,HIS.resume_ID)
	AND HIS.Interview_Schedule_Id=@Interview_Schedule_Id
	
	--SELECT * FROM #PROCESS_RATING
	 SELECT status as a_status,HG.Min_Rate,HG.Actual_Rate as Max_Rate,IP.Process_id,IP.Process_name,IP.emp_full_name_new as superior,IP. member1,IP.member2,IP.member3,
			ISNULL(PR.TOT_RATING1,0)rating,ISNULL(PR.TOT_RATING2,0)rating2,ISNULL(PR.TOT_RATING3,0)rating3,ISNULL(PR.TOT_RATING4,0)rating4,			
		   isnull(cast((ISNULL(PR.TOT_RATING1,0)+ ISNULL(PR.TOT_RATING2,0) + ISNULL(PR.TOT_RATING3,0) + ISNULL(PR.TOT_RATING4,0))/
		   case when (case when ISNULL(PR.TOT_RATING1,0)>0 then 1 else 0 end +  case when ISNULL(PR.TOT_RATING2,0)>0 then 1 else 0 end + case when ISNULL(PR.TOT_RATING3,0)>0 then 1 else 0 end + case when ISNULL(PR.TOT_RATING4,0)>0 then 1 else 0 end)=0 then 1 else case when ISNULL(PR.TOT_RATING1,0)>0 then 1 else 0 end +  case when ISNULL(PR.TOT_RATING2,0)>0 then 1 else 0 end + case when ISNULL(PR.TOT_RATING3,0)>0 then 1 else 0 end + case when ISNULL(PR.TOT_RATING4,0)>0 then 1 else 0 end end as numeric(18,2)),0) as total,
		   CASE WHEN status=0 then 'Pending' when status=1 then 'Approved' when status=2 then 'Rejected' when status=3 then 'Hold' end as status,IP.Comments,IP.Comments2,IP.comments3,IP.comments4, IP.Process_ID ,hd.Doc_Title,hd.HR_Doc_ID	
	 FROM v0055_HRMS_Interview_Schedule  IP 
	 left outer join T0040_HRMS_General_Setting HG WITH (NOLOCK) on IP.rec_post_id=HG.rec_post_id and IP.Process_id=HG.Process_id
	 LEFT OUTER JOIN T0040_HR_DOC_MASTER hd WITH (NOLOCK) on IP.HR_DOC_ID=hd.hr_doc_id and IP.cmp_id=hd.cmp_id 
	 LEFT JOIN #PROCESS_RATING PR ON 1=1
	 WHERE IP.cmp_id=isnull(@Cmp_ID,IP.cmp_id) and IP.Process_Name <> '' and IP.rec_post_id=isnull(@rec_post_id,IP.rec_post_id) and IP.resume_ID=isnull(@resume_ID,resume_ID) --and isnull(status,0)<>0
	
	select Employer_Name,St_Date,End_Date from T0090_HRMS_RESUME_EXPERIENCE WITH (NOLOCK) where  Resume_ID=@resume_ID
	order by End_Date desc
	RETURN   
  
  
  

