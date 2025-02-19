


CREATE VIEW [dbo].[V0110_Car_Retention]
AS
SELECT        AD.AD_NAME, CR.AD_ID, CR.AD_Amount, CR.Effective_Date, CR.No_of_Month, EM.Alpha_Emp_Code, EM.Emp_Full_Name, EM.Emp_ID, EM.Cmp_ID, CR.Tran_ID
FROM            dbo.T0110_Car_Retention AS CR WITH (NOLOCK) INNER JOIN
                         dbo.T0050_AD_MASTER AS AD WITH (NOLOCK)  ON CR.AD_ID = AD.AD_ID INNER JOIN
                         dbo.T0080_EMP_MASTER AS EM WITH (NOLOCK)  ON EM.Emp_ID = CR.Emp_ID
WHERE        (AD.AD_DEF_ID = 23)

