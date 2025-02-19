





CREATE VIEW [dbo].[V0045_HRMS_R_PROCESS_TEMPLATE]
AS
SELECT     dbo.T0040_HRMS_R_PROCESS_MASTER.Process_Name, dbo.T0045_HRMS_R_PROCESS_TEMPLATE.Process_Q_ID, 
                      dbo.T0045_HRMS_R_PROCESS_TEMPLATE.Cmp_ID, dbo.T0045_HRMS_R_PROCESS_TEMPLATE.Process_ID, 
                      dbo.T0045_HRMS_R_PROCESS_TEMPLATE.QUE_Detail, CASE WHEN ISNULL(dbo.T0045_HRMS_R_PROCESS_TEMPLATE.IS_Title, 0) 
                      = 0 THEN 'No' ELSE 'Yes' END AS IS_Title, CASE WHEN ISNULL(dbo.T0045_HRMS_R_PROCESS_TEMPLATE.Is_Description, 0) 
                      = 0 THEN 'No' ELSE 'Yes' END AS Is_Description, CASE WHEN ISNULL(dbo.T0045_HRMS_R_PROCESS_TEMPLATE.Is_Raiting, 0) 
                      = 0 THEN 'No' ELSE 'Yes' END AS Is_Raiting, CASE WHEN ISNULL(dbo.T0045_HRMS_R_PROCESS_TEMPLATE.is_dynamic, 0) 
                      = 0 THEN 'No' ELSE 'Yes' END AS is_dynamic, dbo.T0045_HRMS_R_PROCESS_TEMPLATE.Dis_No,
                      CASE WHEN Question_Type = 0 THEN '' ELSE CASE WHEN Question_Type = 1 THEN 'Title' ELSE CASE WHEN Question_Type = 2 THEN 'Text' ELSE CASE WHEN Question_Type
                       = 4 THEN 'Multiple Choice' ELSE CASE WHEN Question_Type = 5 THEN 'CheckBoxList' ELSE CASE WHEN Question_Type = 6 THEN 'DropDownList' ELSE CASE WHEN Question_Type = 7 THEN 'Multiple Choice Grid'  ELSE 'Paragraph Text'
                       END END END END END END END Question_Type,Question_Option,Question_Type as Question_Type1
FROM         dbo.T0045_HRMS_R_PROCESS_TEMPLATE WITH (NOLOCK) LEFT OUTER JOIN
                      dbo.T0040_HRMS_R_PROCESS_MASTER  WITH (NOLOCK) ON 
                      dbo.T0045_HRMS_R_PROCESS_TEMPLATE.Process_ID = dbo.T0040_HRMS_R_PROCESS_MASTER.Process_ID




