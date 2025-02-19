





CREATE VIEW [dbo].[V0055_Candidate_Schedule]
AS
--Changed by Falak on 24-FEB-2011 removed the used of view inside the view.
SELECT     IS1.Resume_Id, IS1.Status, IS1.Rec_Post_Id, IS1.Process_dis_no, IS1.Schedule, IS1.Schedule_Prev, CASE isnull(FS.Status, 0) 
                      WHEN 1 THEN 'Done' WHEN 0 THEN 'Process' END AS Status1, 
		      RM.Cmp_id, RM.Initial + ' ' + RM.Emp_First_Name + ' ' + 
		      ISNULL(RM.Emp_Second_Name,'') + ' ' + RM.Emp_Last_Name AS App_Full_name, 
			RM.Emp_First_Name, RM.Exp_CTC, 
                      ISNULL(RM.Total_Exp, 0) AS Total_Experience, 
			ISNULL(dbo.T0052_HRMS_Posted_Recruitment.Job_title, '') AS Job_Title , RM.File_Name,
			 RM.Resume_Posted_date, RM.Resume_Name, RM.Primary_email,
		      ISNULL(L.Loc_name, '') AS loc_name, 
                      RM.Resume_Status, RM.Date_Of_Birth, RM.Mobile_No
FROM         (SELECT     Resume_Id, Status, Rec_Post_Id, MAX(Process_Dis_No) AS Process_dis_no, 
                                              MAX(CASE Process_dis_No WHEN 1 THEN 'Process 2st Interview>>' WHEN 2 THEN 'Process 3rd Interview>>' WHEN 3 THEN 'Process 4th Interview>>'
                                               END) AS Schedule, 
                                              MAX(CASE Process_dis_No WHEN 1 THEN '1st Completed' WHEN 2 THEN '2nd Completed' WHEN 3 THEN '3rd Completed' END) 
                                              AS Schedule_Prev
                       FROM          dbo.T0055_HRMS_Interview_Schedule WITH (NOLOCK)
                       GROUP BY Resume_Id, Status, Rec_Post_Id) AS IS1  INNER JOIN
                      dbo.T0055_Resume_Master AS RM WITH (NOLOCK) ON IS1.Resume_Id = RM.Resume_Id LEft Outer Join
		      dbo.T0052_HRMS_Posted_Recruitment WITH (NOLOCK) ON dbo.T0052_HRMS_Posted_Recruitment.Rec_Post_Id = RM.Rec_Post_Id Left Outer join
		      dbo.T0001_Location_MAster L WITH (NOLOCK) on L.Loc_Id = RM.Permanent_Loc_ID LEFT OUTER JOIN
                      dbo.T0090_HRMS_RECRUITMENT_FINAL_SCORE AS FS WITH (NOLOCK) ON IS1.Resume_Id = FS.Resume_ID




