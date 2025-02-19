





CREATE VIEW [dbo].[V9999_Salary_Export_Detail]
AS
SELECT     dbo.T9999_Salary_Export_Detail.Sal_Exp_Id, dbo.T9999_Salary_Export_Detail.Cmp_Id, dbo.T9999_Salary_Export_Detail.Sal_Exp_Trn_Id, 
                      dbo.T9999_Salary_Export_Detail.Emp_Id, dbo.T9999_Salary_Export_Detail.Tally_Led_Name, dbo.T9999_Salary_Export_Detail.Dr_Amount, 
                      dbo.T9999_Salary_Export_Detail.Cr_Amount, dbo.T9999_Salary_Export_Detail.Comment, dbo.T9999_Salary_Export.Vch_No, 
                      dbo.T9999_Salary_Export.Vch_Type, dbo.T9999_Salary_Export.Vch_Date, dbo.T9999_Salary_Export.Month_Date, 
                      dbo.T9999_Salary_Export.Vch_Comments
FROM         dbo.T9999_Salary_Export WITH (NOLOCK) RIGHT OUTER JOIN
                      dbo.T9999_Salary_Export_Detail WITH (NOLOCK)  ON dbo.T9999_Salary_Export.Sal_Exp_Id = dbo.T9999_Salary_Export_Detail.Sal_Exp_Id




