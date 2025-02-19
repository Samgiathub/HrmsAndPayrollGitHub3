





CREATE VIEW [dbo].[V0010_HR_Cmp_Req]
AS
SELECT     dbo.T0010_HR_Comp_Req.Vacancy_ID, dbo.T0010_HR_Comp_Req.Cmp_Req_ID, dbo.T0010_HR_Comp_Req.Experience, 
                      dbo.T0010_HR_Comp_Req.Job_Desc, dbo.T0010_HR_Comp_Req.Qual_ID, dbo.T0010_HR_Comp_Req.Type_ID, dbo.T0010_HR_Comp_Req.Desig_ID, 
                      dbo.T0010_HR_Comp_Req.Cmp_ID, dbo.T0010_HR_Comp_Req.Loc_ID, dbo.T0010_HR_Comp_Req.Posted_Date, dbo.T0010_HR_Comp_Req.Email, 
                      dbo.T0010_HR_Comp_Req.ContactName, dbo.T0010_HR_Comp_Req.City, dbo.T0010_HR_Comp_Req.Vacancy_Code, 
                      dbo.T0040_QUALIFICATION_MASTER.Qual_Name, dbo.T0001_LOCATION_MASTER.Loc_name, dbo.T0040_Vacancy_Master.Vacancy_Name
FROM         dbo.T0010_HR_Comp_Req WITH (NOLOCK) INNER JOIN
                      dbo.T0040_QUALIFICATION_MASTER WITH (NOLOCK)  ON dbo.T0010_HR_Comp_Req.Qual_ID = dbo.T0040_QUALIFICATION_MASTER.Qual_ID INNER JOIN
                      dbo.T0001_LOCATION_MASTER WITH (NOLOCK)  ON dbo.T0010_HR_Comp_Req.Loc_ID = dbo.T0001_LOCATION_MASTER.Loc_ID INNER JOIN
                      dbo.T0040_Vacancy_Master WITH (NOLOCK)  ON dbo.T0010_HR_Comp_Req.Vacancy_ID = dbo.T0040_Vacancy_Master.Vacancy_ID




