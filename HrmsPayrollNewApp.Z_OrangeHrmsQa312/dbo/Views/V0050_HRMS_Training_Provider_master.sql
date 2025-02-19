





CREATE VIEW [dbo].[V0050_HRMS_Training_Provider_master]
AS
SELECT     dbo.T0050_HRMS_Training_Provider_master.Training_Pro_ID, 
CASE WHEN (isnull(Provider_TypeId, 0)= 1  and isnull(Provider_Name,'') = '')
THEN  'Internal Provider' else dbo.T0050_HRMS_Training_Provider_master.Provider_Name end as Provider_Name,  '' as emp_full_name,
                      dbo.T0050_HRMS_Training_Provider_master.Provider_contact_Name, dbo.T0050_HRMS_Training_Provider_master.Provider_Number, 
                      dbo.T0050_HRMS_Training_Provider_master.Provider_Detail, dbo.T0050_HRMS_Training_Provider_master.Provider_Email, 
                      dbo.T0050_HRMS_Training_Provider_master.Provider_Website, dbo.T0050_HRMS_Training_Provider_master.Training_id, 
                      dbo.T0050_HRMS_Training_Provider_master.cmp_id, dbo.T0050_HRMS_Training_Provider_master.Provider_Emp_Id, 
                      dbo.T0050_HRMS_Training_Provider_master.Provider_TypeId, dbo.T0040_Hrms_Training_master.Training_name, 
                      CASE WHEN isnull(Provider_TypeId, 0) = 0 THEN 'External' ELSE 'Internal' END AS Provider_Type, dbo.T0050_HRMS_Training_Provider_master.Provider_FacultyId, 
                      dbo.T0050_HRMS_Training_Provider_master.Provider_InstituteId, dbo.T0050_Training_Institute_Master.Training_InstituteName, 
                      dbo.T0050_Training_Institute_Master.Training_InstituteCode, T0050_HRMS_Training_Provider_master.Training_Institute_LocId, 
                      T0050_Training_Location_Master.Institute_LocationCode,  ISNULL(CASE WHEN isnull(Provider_TypeId, 0)= 0 THEN 
                      CASE WHEN dbo.T0050_HRMS_Training_Provider_master.Provider_FacultyId IS NOT NULL THEN
                          (SELECT     d .Faculty_Name + ','
                            FROM          T0055_Training_Faculty d WITH (NOLOCK)
                            WHERE      d .Training_FacultyId IN
                                                       (SELECT     cast(data AS numeric(18, 0))
                                                         FROM          dbo.Split(ISNULL(dbo.T0050_HRMS_Training_Provider_master.Provider_FacultyId, '0'), '#')
                                                         WHERE      data <> '') FOR XML path('')) ELSE ' ' END 
                      ELSE CASE WHEN dbo.T0050_HRMS_Training_Provider_master.Provider_Emp_Id IS NOT NULL THEN
                          (SELECT     d.Alpha_Emp_Code + '- ' + d.Emp_Full_Name + ','
                            FROM          T0080_EMP_MASTER d WITH (NOLOCK)
                            WHERE      d .Emp_Id IN
                                       (SELECT     cast(data AS numeric(18, 0))
                                         FROM          dbo.Split(ISNULL(dbo.T0050_HRMS_Training_Provider_master.Provider_Emp_Id, '0'), '#')
                                         WHERE      data <> '') FOR XML path('')) ELSE ' ' END END,'') AS Faculty_Name
FROM         dbo.T0040_Hrms_Training_master WITH (NOLOCK) RIGHT OUTER JOIN
                      dbo.T0050_HRMS_Training_Provider_master WITH (NOLOCK) ON 
                      dbo.T0040_Hrms_Training_master.Training_id = dbo.T0050_HRMS_Training_Provider_master.Training_id LEFT OUTER JOIN
                      dbo.T0050_Training_Institute_Master WITH (NOLOCK) ON Training_InstituteId = T0050_HRMS_Training_Provider_master.Provider_InstituteId LEFT OUTER JOIN
                      dbo.T0050_Training_Location_Master WITH (NOLOCK) ON 
                      T0050_Training_Location_Master.Training_Institute_LocId = T0050_HRMS_Training_Provider_master.Training_Institute_LocId




