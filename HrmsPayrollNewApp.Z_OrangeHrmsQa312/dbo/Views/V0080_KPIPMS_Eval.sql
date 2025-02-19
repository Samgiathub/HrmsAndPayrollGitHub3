



CREATE VIEW [dbo].[V0080_KPIPMS_Eval]
AS
SELECT DISTINCT 
                      k.KPIPMS_ID, k.Cmp_ID, k.Emp_ID, k.KPIPMS_Type, k.KPIPMS_Name, k.KPIPMS_FinancialYr, k.KPIPMS_Status, k.KPIPMS_FinalRating, k.KPIPMS_EmProcessFair, 
                      k.KPIPMS_EmpAgree, k.KPIPMS_EmpComments, k.KPIPMS_ProcessFairSup, k.KPIPMS_SupAgree, k.KPIPMS_SupComments, k.KPIPMS_EmpEarlyComment, 
                      k.KPIPMS_SupEarlyComment, k.KPIMPS_StartedOn, k.KPIPMS_EarlyComment, k.KPIMPS_EmpAppOn, k.KPIMPS_SupAppOn, k.KPIPMS_FinalApproved, k.Final_Score, 
                      k.SignOff_EmpDate, k.SignOff_SupDate, k.Final_Close, k.Final_ClosedOn, k.Final_ClosedBy, k.Final_ClosingComment, k.Final_Training, E1.Emp_Full_Name, 
                      E1.Alpha_Emp_Code, k.KPIPMS_ManagerScore
FROM         dbo.T0080_KPIPMS_EVAL AS k WITH (NOLOCK) LEFT OUTER JOIN
                      dbo.T0080_EMP_MASTER AS E1 WITH (NOLOCK)  ON E1.Emp_ID = k.Emp_ID LEFT OUTER JOIN
                      dbo.T0080_EMP_MASTER AS E2 WITH (NOLOCK)  ON E2.Emp_ID = E1.Emp_Superior


