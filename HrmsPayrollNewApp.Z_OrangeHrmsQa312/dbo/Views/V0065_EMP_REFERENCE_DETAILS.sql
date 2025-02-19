



CREATE VIEW [dbo].[V0065_EMP_REFERENCE_DETAILS]
AS
SELECT     dbo.T0065_EMP_REFERENCE_DETAIL_APP.Reference_ID, dbo.T0065_EMP_REFERENCE_DETAIL_APP.Cmp_ID, dbo.T0065_EMP_REFERENCE_DETAIL_APP.Emp_Tran_ID, 
                      dbo.T0065_EMP_REFERENCE_DETAIL_APP.Emp_Application_ID, dbo.T0065_EMP_REFERENCE_DETAIL_APP.Approved_Emp_ID, dbo.T0065_EMP_REFERENCE_DETAIL_APP.Approved_Date, 
                      dbo.T0065_EMP_REFERENCE_DETAIL_APP.Rpt_Level, dbo.T0065_EMP_REFERENCE_DETAIL_APP.R_Emp_ID, dbo.T0065_EMP_REFERENCE_DETAIL_APP.Ref_Description, 
                      (CASE WHEN dbo.T0065_EMP_REFERENCE_DETAIL_APP.Amount <> 0.00 THEN CAST(dbo.T0065_EMP_REFERENCE_DETAIL_APP.Amount AS varchar(100)) ELSE '-' END) AS Amount, 
                      dbo.T0065_EMP_REFERENCE_DETAIL_APP.Comments, dbo.T0065_EMP_REFERENCE_DETAIL_APP.Source_Type, dbo.T0065_EMP_REFERENCE_DETAIL_APP.Contact_Person, 
                      dbo.T0065_EMP_REFERENCE_DETAIL_APP.Designation, dbo.T0065_EMP_REFERENCE_DETAIL_APP.City, dbo.T0065_EMP_REFERENCE_DETAIL_APP.Mobile, 
                      dbo.T0065_EMP_REFERENCE_DETAIL_APP.Description, dbo.T0030_Source_Type_Master.Source_Type_Name, dbo.T0060_EMP_MASTER_APP.Emp_Full_Name, 
                      dbo.T0060_EMP_MASTER_APP.Alpha_Emp_Code, (CASE WHEN dbo.T0065_EMP_REFERENCE_DETAIL_APP.R_Emp_ID <> 0 THEN
                          (SELECT     Alpha_Emp_Code + ' - ' + Emp_Full_Name
                            FROM          T0060_EMP_MASTER_APP WITH (NOLOCK) 
                            WHERE      Emp_Tran_ID = dbo.T0065_EMP_REFERENCE_DETAIL_APP.Emp_Tran_ID) ELSE dbo.T0040_Source_Master.Source_Name END) AS Source_Name, 
                      dbo.T0065_EMP_REFERENCE_DETAIL_APP.Ref_Month AS Month, dbo.T0065_EMP_REFERENCE_DETAIL_APP.Ref_Year AS year, (CASE WHEN Isnull(Ref_Month, 0) 
                      <> 0 THEN LEFT(DATENAME(MONTH, '2015-' + CAST(Ref_Month AS varchar(100)) + '-01'), 3) + '-' + CAST(Ref_Year AS varchar(100)) ELSE '-' END) AS monthyear
FROM         dbo.T0065_EMP_REFERENCE_DETAIL_APP WITH (NOLOCK) INNER JOIN
                      dbo.T0060_EMP_MASTER_APP WITH (NOLOCK)  ON dbo.T0065_EMP_REFERENCE_DETAIL_APP.Emp_Tran_ID = dbo.T0060_EMP_MASTER_APP.Emp_Tran_ID INNER JOIN
                      dbo.T0030_Source_Type_Master WITH (NOLOCK)  ON dbo.T0065_EMP_REFERENCE_DETAIL_APP.Source_Type = dbo.T0030_Source_Type_Master.Source_Type_Id LEFT OUTER JOIN
                      dbo.T0040_Source_Master WITH (NOLOCK)  ON dbo.T0040_Source_Master.Source_Id = dbo.T0065_EMP_REFERENCE_DETAIL_APP.Source_Name


