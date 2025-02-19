--------------------
CREATE VIEW [dbo].[V0051_KPA_Master]
AS
SELECT     dbo.T0051_KPA_Master.KPA_Id, dbo.T0051_KPA_Master.Cmp_ID, dbo.T0051_KPA_Master.KPA_Content, KPA_Target, dbo.T0051_KPA_Master.KPA_Weightage, 
                      dbo.T0051_KPA_Master.Desig_id, CASE WHEN dbo.T0051_KPA_Master.Desig_id IS NOT NULL THEN
                          (SELECT     d .Desig_Name + ','
                            FROM          T0040_DESIGNATION_MASTER d WITH (NOLOCK)
                            WHERE      Desig_ID IN
                                                       (SELECT     cast(data AS numeric(18, 0))
                                                         FROM          dbo.Split(ISNULL(dbo.T0051_KPA_Master.Desig_id, '0'), '#')
                                                         WHERE      data <> '') FOR XML path('')) ELSE 'ALL' END AS Desig_Name, dept_Id, CASE WHEN dbo.T0051_KPA_Master.dept_Id IS NOT NULL AND 
                      dbo.T0051_KPA_Master.dept_Id <> '' THEN
                          (SELECT     d .dept_Name + ','
                            FROM          T0040_DEPARTMENT_MASTER d WITH (NOLOCK)
                            WHERE      dept_Id IN
                                                       (SELECT     cast(data AS numeric(18, 0))
                                                         FROM          dbo.Split(ISNULL(dbo.T0051_KPA_Master.dept_Id, '0'), '#')
                                                         WHERE      data <> '') FOR XML path('')) WHEN dbo.T0051_KPA_Master.dept_Id = '' THEN 'ALL' ELSE 'ALL' END AS dept_Name, isnull(Effective_Date,
                          (SELECT     From_Date
                            FROM          T0010_COMPANY_MASTER WITH (NOLOCK)
                            WHERE      Cmp_Id = dbo.T0051_KPA_Master.Cmp_ID)) Effective_Date
FROM         dbo.T0051_KPA_Master WITH (NOLOCK) LEFT OUTER JOIN
                      dbo.T0040_DESIGNATION_MASTER WITH (NOLOCK) ON dbo.T0051_KPA_Master.Desig_id = dbo.T0040_DESIGNATION_MASTER.Desig_ID 



