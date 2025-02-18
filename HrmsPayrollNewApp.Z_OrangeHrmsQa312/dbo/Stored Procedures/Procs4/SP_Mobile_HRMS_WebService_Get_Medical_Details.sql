﻿

--exec SP_Mobile_HRMS_WebService_Get_Medical_Details 121,21164,6,2022
CREATE PROCEDURE [dbo].[SP_Mobile_HRMS_WebService_Get_Medical_Details]  
@Cmp_Id numeric(18,0),
@Emp_Id numeric(18,0),
@Month numeric(18,0),
@Year numeric(18,0)
AS    
BEGIN

SET NOCOUNT ON		
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
SELECT  Isnull(MA.APP_ID,0) as APP_ID,Isnull(MA.App_For,0) as App_For,Isnull(MA.APP_DATE,GETDATE()) as APP_DATE,
Isnull(MA.CMP_ID,0) as CMP_ID,EM.EMP_FULL_NAME,
Isnull(EM.EMP_ID,0) as EMP_ID,IM.INCIDENT_NAME,EM.ALPHA_EMP_CODE,Isnull(MA.DATE_OF_INCIDENT,GETDATE()) as DATE_OF_INCIDENT
FROM T0500_MEDICAL_APPLICATION MA INNER JOIN T0040_INCIDENT_MASTER IM ON MA.INCIDENT_ID = IM.INCIDENT_ID INNER JOIN T0080_EMP_MASTER EM ON EM.EMP_ID = MA.EMP_ID
WHERE MA.APP_ID <> 0 AND MA.CMP_ID=@Cmp_Id and Month(App_Date) = @Month and Year(App_Date) = @Year and Created_by = @Emp_Id ORDER BY APP_ID DESC


--SELECT 'DEEPAL' AS MEDICALNAME, '99999' AS CONTACTNO, 'DEEPAL@GMAIL' AS EMAIL , 'ADDRESS' AS MEDICALADDR

Declare @Branch_ID as numeric(18,0) = 0

SELECT @Branch_ID = Q_I.Branch_ID
FROM   t0080_emp_master E 
	   INNER JOIN (SELECT I.branch_id, I.grd_id, I.dept_id, I.desig_id, I.emp_id ,I.Center_ID
				   FROM   t0095_increment I 
						  INNER JOIN (SELECT Max(increment_effective_date) AS For_Date, emp_id 
									  FROM   t0095_increment 
									  WHERE  increment_effective_date <= Getdate() AND cmp_id = @Cmp_Id
									  GROUP  BY emp_id) Qry 
									  ON I.emp_id = Qry.emp_id AND I.increment_effective_date = Qry.for_date)Q_I 
					ON E.emp_id = Q_I.emp_id 
WHERE e.Emp_ID = @Emp_Id

IF EXISTS(SELECT 1 FROM T0511_OFFICER_DETAILS WHERE OFFICER_BRANCH = @BRANCH_ID)
BEGIN 
	SELECT OFFICER_NAME AS MEDICALNAME ,CONTACT AS CONTACTNO,EMAILID AS EMAIL,ADDRESS  AS MEDICALADDR 
	FROM T0511_OFFICER_DETAILS WHERE OFFICER_BRANCH = @BRANCH_ID
END
ELSE
	SELECT TOP 1 OFFICER_NAME AS MEDICALNAME ,CONTACT AS CONTACTNO,EMAILID AS EMAIL,ADDRESS  AS MEDICALADDR 
	FROM T0511_OFFICER_DETAILS WHERE OFFICER_BRANCH = 0
END

