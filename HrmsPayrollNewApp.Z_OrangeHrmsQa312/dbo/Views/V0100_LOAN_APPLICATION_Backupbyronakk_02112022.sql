


Create VIEW [dbo].[V0100_LOAN_APPLICATION_Backupbyronakk_02112022]
AS
SELECT     dbo.T0040_LOAN_MASTER.Loan_Name, dbo.T0100_LOAN_APPLICATION.Loan_App_ID, dbo.T0100_LOAN_APPLICATION.Cmp_ID, 
                      dbo.T0100_LOAN_APPLICATION.Emp_ID, dbo.T0100_LOAN_APPLICATION.Loan_ID, dbo.T0100_LOAN_APPLICATION.Loan_App_Date, 
                      dbo.T0100_LOAN_APPLICATION.Loan_App_Code, dbo.T0100_LOAN_APPLICATION.Loan_App_Amount, dbo.T0100_LOAN_APPLICATION.Loan_App_No_of_Insttlement, 
                      dbo.T0100_LOAN_APPLICATION.Loan_App_Installment_Amount, dbo.T0100_LOAN_APPLICATION.Loan_App_Comments, dbo.T0080_EMP_MASTER.Emp_Full_Name, 
                      dbo.T0080_EMP_MASTER.Emp_First_Name, dbo.T0100_LOAN_APPLICATION.Loan_status, dbo.T0080_EMP_MASTER.Emp_Left, 
                      dbo.T0080_EMP_MASTER.Mobile_No, dbo.T0080_EMP_MASTER.Other_Email, dbo.T0095_INCREMENT.Branch_ID, dbo.T0080_EMP_MASTER.Emp_code, 
                      dbo.T0080_EMP_MASTER.Emp_Superior AS R_Emp_ID, dbo.T0040_LOAN_MASTER.Loan_Max_Limit, dbo.T0120_LOAN_APPROVAL.Loan_Apr_Amount, 
                      dbo.T0080_EMP_MASTER.Work_Email, dbo.T0120_LOAN_APPROVAL.Loan_Apr_ID, dbo.T0080_EMP_MASTER.Alpha_Emp_Code, 
                      dbo.T0040_DEPARTMENT_MASTER.Dept_Name, dbo.T0040_DESIGNATION_MASTER.Desig_Name, dbo.T0095_INCREMENT.Gross_Salary, 
                      dbo.T0095_INCREMENT.CTC, dbo.T0080_EMP_MASTER.Date_Of_Join, dbo.T0095_INCREMENT.Basic_Salary, dbo.T0030_BRANCH_MASTER.Branch_Name, 
                      dbo.T0100_LOAN_APPLICATION.Guarantor_Emp_ID, dbo.T0040_LOAN_MASTER.Loan_Guarantor, ISNULL(dbo.T0100_LOAN_APPLICATION.Installment_Start_Date, 
                      dbo.T0100_LOAN_APPLICATION.Loan_App_Date) AS Installment_Start_Date, dbo.T0120_LOAN_APPROVAL.Loan_Approval_Remarks, 
                      dbo.T0100_LOAN_APPLICATION.Loan_Interest_Type, dbo.T0100_LOAN_APPLICATION.Loan_Interest_Per, dbo.T0100_LOAN_APPLICATION.Loan_Require_Date, 
                      dbo.T0100_LOAN_APPLICATION.Attachment_Path, dbo.T0040_LOAN_MASTER.Is_attachment, dbo.T0100_LOAN_APPLICATION.No_of_Inst_Loan_Amt, 
                      dbo.T0100_LOAN_APPLICATION.Total_Loan_Int_Amount, dbo.T0100_LOAN_APPLICATION.Loan_Int_Installment_Amount, 
                      dbo.T0040_LOAN_MASTER.Is_Principal_First_than_Int, dbo.T0100_LOAN_APPLICATION.Loan_App_Amount AS Loan_Taken_Amount, 
                      dbo.T0095_INCREMENT.Vertical_ID, dbo.T0095_INCREMENT.SubVertical_ID, dbo.T0095_INCREMENT.Dept_ID, dbo.T0100_LOAN_APPLICATION.Guarantor_Emp_ID2, 
                      dbo.T0040_LOAN_MASTER.Loan_Guarantor2,isnull(T0040_LOAN_MASTER.is_subsidy_loan,0) as is_subsidy_loan,
                      dbo.T0040_LOAN_MASTER.Hide_Loan_Max_Amount,T0040_BANK_MASTER.Bank_Name,
					  T0095_INCREMENT.Inc_Bank_AC_No,
					  --T0040_BANK_MASTER.Bank_Ac_No,
					  isnull(T0080_EMP_MASTER.Ifsc_Code,'')as Ifsc_Code
					  FROM         
					  dbo.T0100_LOAN_APPLICATION WITH (NOLOCK) INNER JOIN
                      dbo.T0040_LOAN_MASTER  WITH (NOLOCK) ON dbo.T0100_LOAN_APPLICATION.Loan_ID = dbo.T0040_LOAN_MASTER.Loan_ID LEFT OUTER JOIN
                      dbo.T0080_EMP_MASTER  WITH (NOLOCK) ON dbo.T0100_LOAN_APPLICATION.Emp_ID = dbo.T0080_EMP_MASTER.Emp_ID INNER JOIN
					   dbo.T0095_INCREMENT  WITH (NOLOCK) ON dbo.T0080_EMP_MASTER.Increment_ID = dbo.T0095_INCREMENT.Increment_ID left join --added by mansi 
                      --dbo.T0095_INCREMENT  WITH (NOLOCK) ON dbo.T0080_EMP_MASTER.Increment_ID = dbo.T0095_INCREMENT.Increment_ID inner join  --commented by mansi
					  --dbo.T0040_BANK_MASTER WITH (NOLOCK) ON dbo.T0040_BANK_MASTER.Bank_ID = dbo.T0080_EMP_MASTER.Bank_ID  LEFT OUTER JOIN
					  dbo.T0040_BANK_MASTER WITH (NOLOCK) ON dbo.T0040_BANK_MASTER.Bank_ID = dbo.T0095_INCREMENT.Bank_ID  LEFT OUTER JOIN
                      dbo.T0040_DEPARTMENT_MASTER  WITH (NOLOCK) ON dbo.T0095_INCREMENT.Dept_ID = dbo.T0040_DEPARTMENT_MASTER.Dept_Id INNER JOIN
                      dbo.T0040_DESIGNATION_MASTER  WITH (NOLOCK) ON dbo.T0095_INCREMENT.Desig_Id = dbo.T0040_DESIGNATION_MASTER.Desig_ID LEFT OUTER JOIN
                      dbo.T0120_LOAN_APPROVAL WITH (NOLOCK)  ON dbo.T0100_LOAN_APPLICATION.Loan_App_ID = dbo.T0120_LOAN_APPROVAL.Loan_App_ID AND 
                      dbo.T0040_LOAN_MASTER.Loan_ID = dbo.T0120_LOAN_APPROVAL.Loan_ID AND  dbo.T0080_EMP_MASTER.Emp_ID = dbo.T0120_LOAN_APPROVAL.Emp_ID LEFT OUTER JOIN
                      dbo.T0030_BRANCH_MASTER  WITH (NOLOCK) ON dbo.T0095_INCREMENT.Branch_ID = dbo.T0030_BRANCH_MASTER.Branch_ID AND 
                      dbo.T0100_LOAN_APPLICATION.Emp_ID = dbo.T0080_EMP_MASTER.Emp_ID



