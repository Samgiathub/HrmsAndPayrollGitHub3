


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---20/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[RPT_Training_Record_Format2]
	 @Cmp_ID		Numeric
	,@From_Date		Datetime 
	,@To_Date		Datetime
	,@Branch_ID		varchar(Max)  = null
	,@Cat_ID		varchar(Max) = null
	,@Grd_ID		varchar(Max)  = null
	,@Type_ID		varchar(Max)  = null
	,@Dept_ID		varchar(Max)  = null
	,@Desig_ID		varchar(Max) = null
	,@Training_ID	numeric(18,0)
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
	
	SELECT  Training_Apr_ID,Training_Code,
			Training_name,Training_Director,
		CONVERT(VARCHAR(25),TS.From_date,103)From_date,
		CONVERT(VARCHAR(25),TS.To_date,103)To_date,T0040_Hrms_Training_master.Training_id,c.Cmp_Name,C.Cmp_Address,C.cmp_logo
	FROM  T0120_HRMS_TRAINING_APPROVAL WITH (NOLOCK) INNER JOIN
		   T0040_Hrms_Training_master WITH (NOLOCK) ON T0040_Hrms_Training_master.Training_id = T0120_HRMS_TRAINING_APPROVAL.Training_id INNER JOIN
		   (
				SELECT MIN(From_date)From_date,MAX(To_date)To_date,Training_App_ID
				FROM T0120_HRMS_TRAINING_Schedule WITH (NOLOCK)
				GROUP BY Training_App_ID
		   )TS on TS.Training_App_ID = T0120_HRMS_TRAINING_APPROVAL.Training_App_ID INNER JOIN
		   T0010_COMPANY_MASTER C WITH (NOLOCK) on C.Cmp_Id = T0120_HRMS_TRAINING_APPROVAL.Cmp_ID
	WHERE T0120_HRMS_TRAINING_APPROVAL.Cmp_ID = @Cmp_ID and Training_Apr_ID = @Training_ID
	
	
	SELECT CASE WHEN ROW_NUMBER() OVER ( PARTITION BY D.Dept_Id ORDER BY D.Dept_Name,DG.Desig_Name) = 1
		  THEN  D.Dept_Name ELSE '' END AS 'Dept_Name', 
			  ROW_NUMBER() OVER (ORDER BY d.Dept_Name,dg.Desig_Name) AS 'Sr.No.',	
			   TE.Emp_ID,
			   E.Alpha_Emp_Code,
			   E.Emp_Full_Name,
			   DG.Desig_Name,
			   ISNULL(D.Dept_Id,0)Dept_Id,
			   TE.Training_Apr_ID
	FROM  T0130_HRMS_TRAINING_EMPLOYEE_DETAIL TE WITH (NOLOCK) INNER JOIN
		  T0080_EMP_MASTER E WITH (NOLOCK) on E.Emp_ID = TE.Emp_ID INNER JOIN
		  (
			 SELECT T0095_INCREMENT.Emp_ID,T0095_INCREMENT.Increment_ID,Grd_ID,Desig_Id,Dept_ID,Branch_ID
			 FROM  T0095_INCREMENT WITH (NOLOCK) INNER JOIN
				   (
						SELECT MAX(Increment_ID)Increment_ID,T0095_INCREMENT.Emp_ID
						FROM  T0095_INCREMENT WITH (NOLOCK) INNER JOIN
						(
							SELECT max(Increment_Effective_Date)Increment_Effective_Date,Emp_ID
							FROM T0095_INCREMENT WITH (NOLOCK)
							WHERE Cmp_ID = @cmp_id
							GROUP BY Emp_ID
						)I2 on I2.Emp_ID = T0095_INCREMENT.Emp_ID
						WHERE Cmp_ID = @cmp_id
						GROUP BY T0095_INCREMENT.Emp_ID
				   )I1 on I1.Increment_ID = T0095_INCREMENT.Increment_ID and I1.Emp_ID = T0095_INCREMENT.Emp_ID
		  )I on I.Emp_ID = TE.Emp_ID LEFT JOIN
		  T0040_DEPARTMENT_MASTER D WITH (NOLOCK) ON D.Dept_Id = I.Dept_ID LEFT JOIN
		  T0040_DESIGNATION_MASTER DG WITH (NOLOCK) ON DG.Desig_ID = I.Desig_Id LEFT JOIN
		  T0040_GRADE_MASTER G WITH (NOLOCK) ON G.Grd_ID = I.Grd_ID
	WHERE Training_Apr_ID = @Training_ID and (Emp_tran_status = 1 or Emp_tran_status = 4)
	ORDER by D.Dept_Name,DG.Desig_Name
END


