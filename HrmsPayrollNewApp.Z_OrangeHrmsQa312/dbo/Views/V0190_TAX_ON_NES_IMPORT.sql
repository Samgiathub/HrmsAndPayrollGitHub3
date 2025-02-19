




CREATE VIEW [dbo].[V0190_TAX_ON_NES_IMPORT]
AS
SELECT				  TOD.Tran_ID, TOD.Emp_ID,TOD.AD_ID, 
                      TOD.Month, TOD.Year,
                      dbo.T0050_AD_MASTER.AD_SORT_NAME, dbo.T0050_AD_MASTER.AD_CALCULATE_ON, dbo.T0050_AD_MASTER.CMP_ID, 
                      TOD.TDS_Amount as Amount, E.Emp_Full_Name, E.Branch_ID, 
                      E.Emp_code,0 AS Increment_ID, E.Alpha_Emp_Code,TOD.Is_Repeat,tod.Comments,Hide_In_Reports,Emp_Left
FROM         dbo.T0050_AD_MASTER WITH (NOLOCK) INNER JOIN
                      dbo.T0190_TAX_IMPORT_ON_NOT_EFFECT_SALARY TOD WITH (NOLOCK)  ON dbo.T0050_AD_MASTER.AD_ID = TOD.AD_ID INNER JOIN
                      dbo.T0080_EMP_MASTER E WITH (NOLOCK)  ON TOD.Emp_ID = E.Emp_ID




