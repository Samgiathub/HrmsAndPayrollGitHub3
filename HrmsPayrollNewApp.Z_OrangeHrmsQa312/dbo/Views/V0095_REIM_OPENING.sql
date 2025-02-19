


CREATE VIEW [dbo].[V0095_REIM_OPENING]
AS
SELECT     T0095_Reim_Opening.reim_Op_ID,
		   T0095_Reim_Opening.Emp_ID,
		   T0095_Reim_Opening.Cmp_ID,
		   T0095_Reim_Opening.RC_ID,
		   T0095_Reim_Opening.For_Date,
		   T0095_Reim_Opening.Reim_Opening_Amount,
		   T0080_EMP_MASTER.Emp_Full_Name,
		   T0080_EMP_MASTER.Alpha_Code,
		   T0080_EMP_MASTER.Alpha_Emp_Code,
		   T0050_AD_MASTER.AD_NAME
FROM         dbo.T0095_Reim_Opening WITH (NOLOCK) LEFT OUTER JOIN
                      dbo.T0080_EMP_MASTER WITH (NOLOCK)  ON dbo.T0095_Reim_Opening.Emp_Id = dbo.T0080_EMP_MASTER.Emp_ID LEFT OUTER JOIN
                      dbo.T0050_AD_MASTER WITH (NOLOCK)  on dbo.T0095_Reim_Opening.rc_ID = dbo.T0050_AD_MASTER.AD_ID
