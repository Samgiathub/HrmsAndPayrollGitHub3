﻿


 
CREATE VIEW [dbo].[V0095_EMP_GEO_LOCATION_ASSIGN]
AS
SELECT EGL.Emp_Geo_Location_ID,EGL.Emp_ID,EGL.Cmp_ID,EGL.Effective_Date,EGL.Login_ID,
(EM.Alpha_Emp_Code + ' - ' + EM.Emp_Full_Name ) AS 'Emp_Full_Name',EM.Alpha_Emp_Code
FROM T0095_EMP_GEO_LOCATION_ASSIGN EGL WITH (NOLOCK)
INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON EGL.Emp_ID = EM.Emp_ID



