





CREATE VIEW [dbo].[V0111_Loan_Transcation]
AS
SELECT     dbo.T0040_LOAN_MASTER.Loan_Name, dbo.T0140_LOAN_TRANSACTION.Loan_Tran_ID, dbo.T0140_LOAN_TRANSACTION.Cmp_ID, 
                      dbo.T0140_LOAN_TRANSACTION.Loan_ID, dbo.T0140_LOAN_TRANSACTION.Emp_ID, dbo.T0140_LOAN_TRANSACTION.For_Date, 
                      dbo.T0140_LOAN_TRANSACTION.Loan_Opening, dbo.T0140_LOAN_TRANSACTION.Loan_Issue, dbo.T0140_LOAN_TRANSACTION.Loan_Return, 
                      dbo.T0140_LOAN_TRANSACTION.Loan_Closing, dbo.T0140_LOAN_TRANSACTION.Loan_Tran_ID AS Expr2, 
                      dbo.T0140_LOAN_TRANSACTION.Loan_ID AS Expr1, dbo.T0140_LOAN_TRANSACTION.Cmp_ID AS Expr3, 
                      dbo.T0140_LOAN_TRANSACTION.Emp_ID AS Expr4, dbo.T0140_LOAN_TRANSACTION.For_Date AS Expr5, 
                      dbo.T0140_LOAN_TRANSACTION.Loan_Opening AS Expr6, dbo.T0140_LOAN_TRANSACTION.Loan_Issue AS Expr7, 
                      dbo.T0140_LOAN_TRANSACTION.Loan_Return AS Expr8, dbo.T0140_LOAN_TRANSACTION.Loan_Closing AS Expr9, 
                      dbo.T0120_LOAN_APPROVAL.Loan_App_ID, dbo.T0120_LOAN_APPROVAL.Loan_Apr_Code
FROM         dbo.T0140_LOAN_TRANSACTION WITH (NOLOCK) INNER JOIN
                      dbo.T0040_LOAN_MASTER WITH (NOLOCK)  ON dbo.T0140_LOAN_TRANSACTION.Loan_ID = dbo.T0040_LOAN_MASTER.Loan_ID INNER JOIN
                      dbo.T0120_LOAN_APPROVAL WITH (NOLOCK)  ON dbo.T0040_LOAN_MASTER.Loan_ID = dbo.T0120_LOAN_APPROVAL.Loan_ID




