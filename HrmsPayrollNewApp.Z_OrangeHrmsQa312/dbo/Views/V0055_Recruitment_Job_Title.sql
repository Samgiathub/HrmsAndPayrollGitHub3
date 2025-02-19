



CREATE VIEW [dbo].[V0055_Recruitment_Job_Title]
AS
SELECT Cmp_id,STUFF((SELECT ', ' + A.[Job_title] FROM V0052_HRMS_recruitment_Posted A WITH (NOLOCK)
Where A.[Cmp_id]=B.[Cmp_id] AND Posted_Status = 1   and ((GETDATE() >= Rec_Start_Date  and  GETDATE() <= Rec_end_Date ) or
(Rec_End_Date >=  GETDATE() and   Rec_end_date  <= GETDATE())) FOR XML PATH('')),1,1,'') As [Job_title]
From V0052_HRMS_recruitment_Posted B WITH (NOLOCK)
where Posted_Status = 1   and ((GETDATE() >= Rec_Start_Date  and  GETDATE() <= Rec_end_Date ) or
(Rec_End_Date >=  GETDATE() and   Rec_end_date  <= GETDATE())) Group By [Cmp_id]


