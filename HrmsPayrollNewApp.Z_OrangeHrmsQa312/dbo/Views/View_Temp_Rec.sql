





CREATE VIEW [dbo].[View_Temp_Rec]
AS
SELECT     TOP 100 PERCENT P.Cmp_id, P.Job_title, P.Rec_End_date, Re.No_of_vacancies, CASE WHEN p.REc_End_Date > getdate() 
                      THEN P.Posted_Status ELSE 4 END AS Posted_Status, 
                      CASE qry.Resume_Status WHEN 0 THEN 'New Applicant' WHEN 1 THEN 'Total Interviewed' WHEN 2 THEN 'On Hold' WHEN 3 THEN 'Rejected' END AS lblStatus,
                       qry.Total_No_App, qry.Rec_Post_Id, qry.Resume_Status, Qry1.Total_No_Final_App
FROM         (SELECT     COUNT(Resume_Id) AS Total_No_App, Rec_Post_Id, Resume_Status
                       FROM          dbo.T0055_Resume_Master WITH (NOLOCK)
                       GROUP BY Rec_Post_Id, Resume_Status) AS qry INNER JOIN
                      dbo.T0052_HRMS_Posted_Recruitment AS P WITH (NOLOCK) ON qry.Rec_Post_Id = P.Rec_Post_Id INNER JOIN
                      dbo.T0050_HRMS_Recruitment_Request AS Re WITH (NOLOCK) ON Re.Rec_Req_ID = P.Rec_Req_ID INNER JOIN
                          (SELECT     COUNT(Resume_ID) AS Total_No_Final_App, Rec_Post_ID
                            FROM          dbo.T0090_HRMS_RECRUITMENT_FINAL_SCORE WITH (NOLOCK)
                            GROUP BY Rec_Post_ID) AS Qry1 ON Qry1.Rec_Post_ID = P.Rec_Post_Id
ORDER BY P.Rec_Post_Id




