
CREATE VIEW [dbo].[V0080_VEHICLE_EMP_DETAILS]
AS
SELECT DISTINCT 
                         em.Cmp_ID,VM.Vehicle_ID, VM.Vehicle_Type, EM.emp_id,
                         CASE WHEN VM.Desig_Wise_Limit = 1 THEN VMD.Max_Limit WHEN VM.Grade_Wise_Limit = 1 THEN VMG.Max_Limit WHEN VM.Branch_Wise_Limit = 1 THEN VMB.Max_Limit ELSE VM.Vehicle_Max_Limit END AS Max_Limit, 
                         CASE WHEN VM.Desig_Wise_Limit = 1 THEN VMD.Employee_Contribution WHEN VM.Grade_Wise_Limit = 1 THEN VMG.Employee_Contribution WHEN VM.Branch_Wise_Limit = 1 THEN VMB.Employee_Contribution END AS Employee_Contribution,
                          VM.No_Of_Year_Limit, VM.Attach_Mandatory, VM.Vehicle_Allow_Beyond_Limit,VM.Eligible_Joining_Months
FROM          	  dbo.V0080_EMP_MASTER_INCREMENT_GET AS EM INNER JOIN
                         dbo.T0040_VEHICLE_TYPE_MASTER AS VM WITH (NOLOCK) ON EM.Cmp_ID = VM.Cmp_ID LEFT OUTER JOIN
                         dbo.T0041_Vehicle_Maxlimit_Design AS VMD WITH (NOLOCK) ON VM.Vehicle_ID = VMD.Vehicle_ID AND VM.Desig_Wise_Limit = 1 AND VMD.Desig_ID = EM.Desig_Id LEFT OUTER JOIN
                         dbo.T0041_Vehicle_Maxlimit_Design AS VMG WITH (NOLOCK) ON VM.Vehicle_ID = VMG.Vehicle_ID AND VM.Grade_Wise_Limit = 1 AND VMG.Grade_ID = EM.Grd_ID LEFT OUTER JOIN
                         dbo.T0041_Vehicle_Maxlimit_Design AS VMB WITH (NOLOCK) ON VM.Vehicle_ID = VMB.Vehicle_ID AND VM.Branch_Wise_Limit = 1 AND VMB.Branch_ID = EM.Branch_ID
