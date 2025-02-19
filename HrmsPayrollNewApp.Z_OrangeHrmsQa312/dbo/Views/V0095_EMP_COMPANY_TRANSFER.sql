


CREATE VIEW [dbo].[V0095_EMP_COMPANY_TRANSFER]
AS
SELECT     CT.Tran_Id, CT.New_Emp_Id, CT.New_Cmp_Id, CT.New_Branch_Id, CT.New_Cat_Id, CT.New_Grd_Id, CT.New_Dept_Id, CT.New_Desig_Id, CT.New_Type_Id, 
                      CT.New_Shift_Id, CT.New_Client_Id, CT.New_Emp_mngr_Id, CT.Effective_Date, CT.Old_Emp_Id, CSD.New_Basic_Salary, CSD.New_Gross_Salary, CSD.New_CTC, 
                      CSD.Old_Basic_Salary, CSD.Old_Gross_Salary, CSD.Old_CTC, CT.New_Emp_WeekOff_Day, CT.New_Privilege_ID, CT.Old_Privilege_ID, CT.New_SubVertical_ID, 
                      CT.New_Segment_ID, CT.New_SubBranch_ID, CT.New_SalCycle_ID, CT.New_Login_Alias, CT.Old_Login_Alias, CT.ReplaceManager_Cmp_ID, 
                      CT.ReplaceManager_ID
FROM         dbo.T0095_EMP_COMPANY_TRANSFER AS CT WITH (NOLOCK) RIGHT OUTER JOIN
                      dbo.T0100_EMP_COMPANY_TRANSFER_SALARY_DETAIL AS CSD WITH (NOLOCK)  ON CT.Tran_Id = CSD.Tran_Id

