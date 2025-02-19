



CREATE VIEW [dbo].[V0090_Emp_Reference_Details]
AS
SELECT     dbo.T0090_EMP_REFERENCE_DETAIL.Reference_ID, dbo.T0090_EMP_REFERENCE_DETAIL.Cmp_ID, dbo.T0090_EMP_REFERENCE_DETAIL.Emp_ID, 
                      dbo.T0090_EMP_REFERENCE_DETAIL.R_Emp_ID, dbo.T0090_EMP_REFERENCE_DETAIL.For_Date, dbo.T0090_EMP_REFERENCE_DETAIL.Ref_Description, 
                      (Case when dbo.T0090_EMP_REFERENCE_DETAIL.Amount <> 0.00 THEN Cast(dbo.T0090_EMP_REFERENCE_DETAIL.Amount AS varchar(100)) ELSE '-' END) as Amount, 
                      dbo.T0090_EMP_REFERENCE_DETAIL.Comments, dbo.T0090_EMP_REFERENCE_DETAIL.Source_Type, 
                      dbo.T0090_EMP_REFERENCE_DETAIL.Contact_Person, dbo.T0090_EMP_REFERENCE_DETAIL.Designation, dbo.T0090_EMP_REFERENCE_DETAIL.City, 
                      dbo.T0090_EMP_REFERENCE_DETAIL.Mobile, dbo.T0090_EMP_REFERENCE_DETAIL.Description, dbo.T0030_Source_Type_Master.Source_Type_Name, 
                      dbo.T0080_EMP_MASTER.Emp_Full_Name, dbo.T0080_EMP_MASTER.Alpha_Emp_Code, (CASE WHEN dbo.T0090_EMP_REFERENCE_DETAIL.R_Emp_ID <> 0 THEN
                          (SELECT     Alpha_Emp_Code + ' - ' + Emp_Full_Name
                            FROM          T0080_EMP_MASTER WITH (NOLOCK)
                            WHERE      Emp_ID = dbo.T0090_EMP_REFERENCE_DETAIL.R_Emp_ID) ELSE dbo.T0040_Source_Master.Source_Name END) AS Source_Name,
                            Ref_Month as Month,Ref_Year as year,(Case when Isnull(Ref_Month,0) <> 0 then left(DATENAME(MONTH,'2015-'+ Cast(Ref_Month AS varchar(100)) +'-01'),3)  +'-'+ Cast(Ref_Year AS varchar(100)) else '-' END) as monthyear,
                       (Case When Isnull(dbo.T0090_EMP_REFERENCE_DETAIL.Effect_In_Salary,0) = 1 THEN 'Yes' ELSE 'NO' END) as Effect_In_Salary
FROM         dbo.T0090_EMP_REFERENCE_DETAIL WITH (NOLOCK) INNER JOIN
                      dbo.T0080_EMP_MASTER WITH (NOLOCK) ON dbo.T0090_EMP_REFERENCE_DETAIL.Emp_ID = dbo.T0080_EMP_MASTER.Emp_ID INNER JOIN
                      dbo.T0030_Source_Type_Master WITH (NOLOCK) ON dbo.T0090_EMP_REFERENCE_DETAIL.Source_Type = dbo.T0030_Source_Type_Master.Source_Type_Id LEFT OUTER JOIN
                      dbo.T0040_Source_Master WITH (NOLOCK) ON dbo.T0040_Source_Master.Source_Id = dbo.T0090_EMP_REFERENCE_DETAIL.Source_Name




