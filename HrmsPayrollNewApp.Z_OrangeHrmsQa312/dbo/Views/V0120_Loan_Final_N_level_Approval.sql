





CREATE VIEW [dbo].[V0120_Loan_Final_N_level_Approval]  
AS  
  
SELECT    Loan_Name, Emp_Id, Emp_code, Emp_Full_Name,  Cmp_Id, Loan_Apr_Status As Loan_Status,Loan_App_ID,   
      Loan_Apr_ID, Loan_Apr_Date As Application_Date, Alpha_Emp_Code, Loan_ID, Loan_App_Code,  
     Loan_Apr_Amount As Loan_App_Amount, Loan_Apr_Amount As Loan_Apr_Amount,Emp_First_Name  
                  ,1 AS 'is_Final_Approved', 0 AS 'S_Emp_ID_A' ,Loan_Apr_Date As Loan_App_Date -- Loan_App_Date Added by nilesh on 26112016 for Applicaton Date Wise Searching
FROM      V0120_LOAN_APPROVAL WITH (NOLOCK) 
UNION ALL  
SELECT    Loan_Name,  Emp_ID, Emp_code, Emp_Full_Name,  Cmp_ID, qry.Loan_status, LAD.Loan_App_ID,   
                  Loan_Apr_ID, Loan_App_Date As Application_Date, Alpha_Emp_Code, Loan_ID, Loan_App_Code,   
                  Loan_App_Amount As Loan_App_Amount,Qry.Loan_Apr_Amount as Loan_Apr_Amount, Emp_First_Name  
      ,0 AS 'is_Final_Approved', qry.s_emp_id AS 'S_Emp_ID_A'  ,Loan_App_Date -- Loan_App_Date Added by nilesh on 26112016 for Applicaton Date Wise Searching
FROM         V0100_LOAN_APPLICATION LAD WITH (NOLOCK)  INNER JOIN  
           (SELECT     lla.Loan_App_ID, lla.s_emp_id, lla.Loan_Apr_Amount as Loan_Apr_Amount,lla.Loan_Apr_Status as  Loan_status
                            FROM          T0115_Loan_Level_Approval lla WITH (NOLOCK) INNER JOIN  
                                                       (SELECT     max(Rpt_Level) Rpt_Level, Loan_App_ID  
                                                         FROM          T0115_Loan_Level_Approval WITH (NOLOCK)  
                                                         GROUP BY Loan_App_ID) AS Qry ON Qry.Rpt_Level = lla.Rpt_Level AND Qry.Loan_App_ID = lla.Loan_App_ID INNER JOIN  
                                                   T0100_LOAN_APPLICATION LA WITH (NOLOCK) ON la.Loan_App_ID = lla.Loan_App_ID  
                            WHERE      (lla.Loan_Apr_Status <> 'N' )) AS qry ON LAD.Loan_App_ID = qry.Loan_App_ID  
                               -- Changed by Gadriwala Muslim 16112016 - lla.Loan_Apr_Status = 'A' to lla.Loan_Apr_Status <> 'N'  Rejected Record Not Come
  



