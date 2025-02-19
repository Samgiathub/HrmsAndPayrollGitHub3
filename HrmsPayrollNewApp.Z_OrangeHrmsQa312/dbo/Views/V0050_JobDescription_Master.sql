





CREATE VIEW [dbo].[V0050_JobDescription_Master]
AS
SELECT     dbo.T0050_JobDescription_Master.Job_Id, dbo.T0050_JobDescription_Master.Cmp_Id, dbo.T0050_JobDescription_Master.Job_Code, 
                      dbo.T0050_JobDescription_Master.Effective_Date, dbo.T0050_JobDescription_Master.Exp_Min, dbo.T0050_JobDescription_Master.Exp_Max, 
                      dbo.T0050_JobDescription_Master.Branch_Id, dbo.T0050_JobDescription_Master.Grade_Id, dbo.T0050_JobDescription_Master.Desig_Id, 
                      dbo.T0050_JobDescription_Master.Dept_Id, dbo.T0050_JobDescription_Master.Qual_Id, CASE WHEN T0050_JobDescription_Master.Branch_Id IS NOT NULL 
                      THEN
                          (SELECT     B.Branch_Name + ','
                            FROM          T0030_BRANCH_MASTER B WITH (NOLOCK)
                            WHERE      B.Branch_Id IN
                                                       (SELECT     cast(data AS numeric(18, 0))
                                                         FROM          dbo.Split(ISNULL(dbo.T0050_JobDescription_Master.Branch_Id, '0'), '#')
                                                         WHERE      data <> '') FOR XML path('')) ELSE 'ALL' END AS Branch_Name, CASE WHEN T0050_JobDescription_Master.Grade_Id IS NOT NULL 
                      THEN
                          (SELECT     g.Grd_Name + ','
                            FROM          T0040_GRADE_MASTER G WITH (NOLOCK)
                            WHERE      g.Grd_ID IN
                                                       (SELECT     cast(data AS numeric(18, 0))
                                                         FROM          dbo.Split(ISNULL(dbo.T0050_JobDescription_Master.Grade_Id, '0'), '#')
                                                         WHERE      data <> '') FOR XML path('')) ELSE 'ALL' END AS Grd_Name, CASE WHEN T0050_JobDescription_Master.Dept_Id IS NOT NULL 
                      THEN
                          (SELECT     d .Dept_Name + ','
                            FROM          T0040_DEPARTMENT_MASTER D WITH (NOLOCK)
                            WHERE      d .Dept_Id IN
                                                       (SELECT     cast(data AS numeric(18, 0))
                                                         FROM          dbo.Split(ISNULL(dbo.T0050_JobDescription_Master.Dept_Id, '0'), '#')
                                                         WHERE      data <> '') FOR XML path('')) ELSE 'ALL' END AS Dept_Name, CASE WHEN T0050_JobDescription_Master.Desig_Id IS NOT NULL 
                      THEN
                          (SELECT     Dg.Desig_Name + ','
                            FROM          T0040_DESIGNATION_MASTER Dg WITH (NOLOCK)
                            WHERE      Dg.Desig_ID IN
                                                       (SELECT     cast(data AS numeric(18, 0))
                                                         FROM          dbo.Split(ISNULL(dbo.T0050_JobDescription_Master.Desig_ID, '0'), '#')
                                                         WHERE      data <> '') FOR XML path('')) ELSE 'ALL' END AS Desig_Name, CASE WHEN T0050_JobDescription_Master.Qual_Id IS NOT NULL 
                      THEN
                          (SELECT     s.Qual_Name + ','
                            FROM          T0040_Qualification_MASTER s WITH (NOLOCK)
                            WHERE      s.Qual_ID IN
                                                       (SELECT     cast(data AS numeric(18, 0))
                                                         FROM          dbo.Split(ISNULL(dbo.T0050_JobDescription_Master.Qual_Id, '0'), '#')
                                                         WHERE      data <> '') FOR XML path('')) ELSE 'ALL' END AS Qual_Name,attach_doc,
                                     case when [status]=0 then 'Pending' when ([status]=1 OR [status] IS NULL) then 'Approved' else 'Rejected' end as [status],ISNULL(Job_Title,'')Job_Title,
                 Document_ID,Experience_Type
FROM         dbo.T0050_JobDescription_Master WITH (NOLOCK)




