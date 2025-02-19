





CREATE  VIEW [dbo].[GET_SALARY_CHEQUE_PRINTING]
AS
SELECT     dbo.T0010_Company_Master.Cmp_Name as Company_Name, Qry.Cmp_Id AS Company_Id, Qry.Bank_ID, Qry.Date_Top, Qry.Date_Left, Qry.Name_Top, Qry.Name_Left, 
                      Qry.Amount_Top, Qry.Amount_Left, Qry.AmtWords_Top, Qry.AmtWords_Left, Qry.AmtWords_Top2, Qry.AmtWords_Left2, Qry.Cmp_Flag, Qry.Sing_Flag, 
                      Qry.Cmp_Top, Qry.Cmp_Left, Qry.Sing_Top, Qry.Sing_left, Qry.Cmp_Name, Qry.Payee_Flag, Qry.Payee_Top, Qry.Payee_Left, Qry.AcNO_Flag, 
                      Qry.AcNo_Top, Qry.AcNo_Left, Qry.OverThan_Flag, Qry.OverThan_Top, Qry.OverThan_Left, Qry.Director_Flag, Qry.Director_Top, Qry.Director_Left, 
                      Qry.Director_Name, Qry.Bearer_Flag, Qry.Bearer_Top, Qry.Bearer_Left, Qry.Bank_Name as BankName, Qry.Is_Default, dbo.T0200_MONTHLY_SALARY.Net_Amount, 
                      dbo.T0200_MONTHLY_SALARY.Sal_Generate_Date as Generate_Date, I.Inc_Bank_AC_No as Payment_Mode, dbo.T0080_Emp_Master.Emp_Full_Name as Emp_Name, Month(dbo.T0200_MONTHLY_SALARY.Month_End_Date) as Month, 
                      Year(dbo.T0200_MONTHLY_SALARY.Month_End_Date) As Year, dbo.T0200_MONTHLY_SALARY.Emp_Id, dbo.T0080_Emp_Master.Alpha_Emp_code as code, dbo.T0200_MONTHLY_SALARY.Gross_Salary as Total_Earn_Amount, 
                      dbo.T0200_MONTHLY_SALARY.Total_Dedu_Amount, dbo.F_Number_TO_Word(dbo.T0200_MONTHLY_SALARY.Net_Amount) AS Amount_In_Word
FROM         dbo.T0200_MONTHLY_SALARY WITH (NOLOCK) INNER JOIN
                          (SELECT     dbo.CHEQUE_PRINTING_SETUP.Company_ID as Cmp_Id, dbo.CHEQUE_PRINTING_SETUP.Bank_ID, dbo.CHEQUE_PRINTING_SETUP.Date_Top, 
                                                   dbo.CHEQUE_PRINTING_SETUP.Date_Left, dbo.CHEQUE_PRINTING_SETUP.Name_Top, dbo.CHEQUE_PRINTING_SETUP.Name_Left, 
                                                   dbo.CHEQUE_PRINTING_SETUP.Amount_Top, dbo.CHEQUE_PRINTING_SETUP.Amount_Left, 
                                                   dbo.CHEQUE_PRINTING_SETUP.AmtWords_Top, dbo.CHEQUE_PRINTING_SETUP.AmtWords_Left, 
                                                   dbo.CHEQUE_PRINTING_SETUP.AmtWords_Top2, dbo.CHEQUE_PRINTING_SETUP.AmtWords_Left2, 
                                                   dbo.CHEQUE_PRINTING_SETUP.Cmp_Flag, dbo.CHEQUE_PRINTING_SETUP.Sing_Flag, dbo.CHEQUE_PRINTING_SETUP.Cmp_Top, 
                                                   dbo.CHEQUE_PRINTING_SETUP.Cmp_Left, dbo.CHEQUE_PRINTING_SETUP.Sing_Top, dbo.CHEQUE_PRINTING_SETUP.Sing_left, 
                                                   dbo.CHEQUE_PRINTING_SETUP.Cmp_Name, dbo.CHEQUE_PRINTING_SETUP.Payee_Flag, dbo.CHEQUE_PRINTING_SETUP.Payee_Top, 
                                                   dbo.CHEQUE_PRINTING_SETUP.Payee_Left, dbo.CHEQUE_PRINTING_SETUP.AcNO_Flag, dbo.CHEQUE_PRINTING_SETUP.AcNo_Top, 
                                                   dbo.CHEQUE_PRINTING_SETUP.AcNo_Left, dbo.CHEQUE_PRINTING_SETUP.OverThan_Flag, 
                                                   dbo.CHEQUE_PRINTING_SETUP.OverThan_Top, dbo.CHEQUE_PRINTING_SETUP.OverThan_Left, 
                                                   dbo.CHEQUE_PRINTING_SETUP.Director_Flag, dbo.CHEQUE_PRINTING_SETUP.Director_Top, 
                                                   dbo.CHEQUE_PRINTING_SETUP.Director_Left, dbo.CHEQUE_PRINTING_SETUP.Director_Name, 
                                                   dbo.CHEQUE_PRINTING_SETUP.Bearer_Flag, dbo.CHEQUE_PRINTING_SETUP.Bearer_Top, 
                                                   dbo.CHEQUE_PRINTING_SETUP.Bearer_Left, dbo.T0040_Bank_Master.Bank_Name, dbo.T0040_Bank_Master.Is_Default
                            FROM          dbo.CHEQUE_PRINTING_SETUP WITH (NOLOCK)  INNER JOIN
                                                   dbo.T0040_Bank_Master  WITH (NOLOCK) ON dbo.CHEQUE_PRINTING_SETUP.Bank_ID = dbo.T0040_Bank_Master.Bank_ID
                            WHERE      (dbo.T0040_Bank_Master.Is_Default = 'Y')) AS Qry ON dbo.T0200_MONTHLY_SALARY.Cmp_Id = Qry.Cmp_Id INNER JOIN
                      dbo.T0080_Emp_Master WITH (NOLOCK)  ON dbo.T0200_MONTHLY_SALARY.Emp_Id = dbo.T0080_Emp_Master.Emp_Id INNER JOIN
                      dbo.T0010_Company_Master WITH (NOLOCK)  ON dbo.T0200_MONTHLY_SALARY.Cmp_Id = dbo.T0010_Company_Master.Cmp_Id Inner Join
                      dbo.T0095_INCREMENT I WITH (NOLOCK)  on T0080_EMP_MASTER.Increment_ID = I.Increment_ID and T0080_EMP_MASTER.Emp_ID = I.Emp_ID




