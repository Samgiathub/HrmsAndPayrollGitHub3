

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[RPT_Training_CalenderYear_Format2]
    @Cmp_ID				Numeric(18,0)
	,@From_Date			Datetime 
	,@To_Date			Datetime
	,@Branch_ID			varchar(Max) 
	,@Cat_ID			varchar(Max)
	,@Grd_ID			varchar(Max) 
	,@Type_ID			varchar(Max) 
	,@Dept_ID			varchar(Max) 
	,@Desig_ID			varchar(Max)
	,@Emp_ID			Numeric(18,0)
	,@Constraint		varchar(MAX)=''
	,@Training_ID		numeric(18,0)=0
	,@Training_TypeId	numeric(18,0) 	
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
	
		
	IF @Training_TypeId = 0
		BEGIN
			SELECT TT.Training_Type_ID,TT.Training_TypeName,Cmp_Name,CT.Cmp_Id,
			Cmp_Address,cmp_logo,
			CONVERT(VARCHAR(25),@From_Date,103) as PeriodFrom,
			CONVERT(VARCHAR(25),@To_Date,103) as PeriodTo
			FROM   T0030_Hrms_Training_Type TT WITH (NOLOCK) INNER JOIN
				   T0010_COMPANY_MASTER CT WITH (NOLOCK) ON CT.Cmp_Id = tt.Cmp_Id
			WHERE TT.Cmp_Id = @Cmp_ID
			
			SELECT  CONVERT(VARCHAR(25),k.From_date,103) TrainingFromDate,
					CONVERT(VARCHAR(25),k.To_date,103) TrainingToDate,
					DATEPART(MONTH,k.From_date)TrainingMonth,
					DATENAME(MONTH, k.From_date) TrainingMonthName,
					--CASE WHEN ROW_NUMBER() OVER (PARTITION BY DATEPART(MONTH,k.From_date),TC.Training_Category_Name ORDER BY DATEPART(MONTH,k.From_date),TC.Training_Category_Name) =1
					--THEN TC.Training_Category_Name ELSE '' END AS Training_Category_Name,
					 Training_Category_Name,
					TM.Training_Category_Id,
					T0120_HRMS_TRAINING_APPROVAL.Training_Apr_ID,
					Training_Code,			
					TM.Training_name,
					Place,
					ISNULL(TE.empcount,0)empcount,
					Training_Cost,
					TC.Cmp_Id,
					T0120_HRMS_TRAINING_APPROVAL.Training_Type
			FROM T0120_HRMS_TRAINING_APPROVAL WITH (NOLOCK) INNER JOIN
				(
					SELECT MIN(From_date)From_date,MAX(To_date)To_date,Training_App_ID
					FROM T0120_HRMS_TRAINING_Schedule WITH (NOLOCK)
					WHERE Cmp_ID = @Cmp_ID 
					GROUP BY Training_App_ID
				)k on k.Training_App_ID = T0120_HRMS_TRAINING_APPROVAL.Training_App_ID INNER JOIN
				T0040_Hrms_Training_master TM WITH (NOLOCK) on TM.Training_id = T0120_HRMS_TRAINING_APPROVAL.Training_id LEFT JOIN
				T0030_Hrms_Training_Category TC WITH (NOLOCK) on TC.Training_Category_ID = TM.Training_Category_Id LEFT JOIN
				(
					SELECT COUNT(1)empcount,Training_Apr_ID
					FROM T0130_HRMS_TRAINING_EMPLOYEE_DETAIL WITH (NOLOCK)
					WHERE cmp_id = @Cmp_ID and ( Emp_tran_status = 1 or Emp_tran_status = 4)
					GROUP by Training_Apr_ID
				)TE ON TE.Training_Apr_ID = T0120_HRMS_TRAINING_APPROVAL.Training_Apr_ID 
			WHERE T0120_HRMS_TRAINING_APPROVAL.Cmp_ID = @Cmp_ID AND k.From_date >= @From_Date AND k.From_date<= @To_Date
			ORDER BY DATEPART(MONTH,k.From_date),TC.Training_Category_Name
		END
	ELSE
		BEGIN
			SELECT TT.Training_Type_ID,TT.Training_TypeName,Cmp_Name,CT.Cmp_Id,Cmp_Address,cmp_logo 
				,CONVERT(VARCHAR(25),@From_Date,103) as PeriodFrom,
				 CONVERT(VARCHAR(25),@To_Date,103) as PeriodTo
			FROM   T0030_Hrms_Training_Type TT WITH (NOLOCK) INNER JOIN
				   T0010_COMPANY_MASTER CT WITH (NOLOCK) ON CT.Cmp_Id = tt.Cmp_Id
			WHERE TT.Cmp_Id = @Cmp_ID and TT.Training_Type_ID = @Training_TypeId
			
			SELECT  CONVERT(VARCHAR(25),k.From_date,103) TrainingFromDate,
					CONVERT(VARCHAR(25),k.To_date,103) TrainingToDate,
					DATEPART(MONTH,k.From_date)TrainingMonth,
					DATENAME(MONTH, k.From_date) TrainingMonthName,
					--CASE WHEN ROW_NUMBER() OVER (PARTITION BY DATEPART(MONTH,k.From_date),TC.Training_Category_Name ORDER BY DATEPART(MONTH,k.From_date),TC.Training_Category_Name) =1
					--THEN TC.Training_Category_Name ELSE '' END AS Training_Category_Name,
					Training_Category_Name,
					TM.Training_Category_Id,
					T0120_HRMS_TRAINING_APPROVAL.Training_Apr_ID,
					Training_Code,			
					TM.Training_name,
					Place,
					ISNULL(TE.empcount,0)empcount,
					Training_Cost,
					TC.Cmp_Id,
					T0120_HRMS_TRAINING_APPROVAL.Training_Type
		FROM T0120_HRMS_TRAINING_APPROVAL WITH (NOLOCK) INNER JOIN
			(
				SELECT MIN(From_date)From_date,MAX(To_date)To_date,Training_App_ID
				FROM T0120_HRMS_TRAINING_Schedule WITH (NOLOCK)
				WHERE Cmp_ID = @Cmp_ID 
				GROUP BY Training_App_ID
			)k on k.Training_App_ID = T0120_HRMS_TRAINING_APPROVAL.Training_App_ID INNER JOIN
			T0040_Hrms_Training_master TM WITH (NOLOCK) on TM.Training_id = T0120_HRMS_TRAINING_APPROVAL.Training_id LEFT JOIN
			T0030_Hrms_Training_Category TC WITH (NOLOCK) on TC.Training_Category_ID = TM.Training_Category_Id LEFT JOIN
			(
				SELECT COUNT(1)empcount,Training_Apr_ID
				FROM T0130_HRMS_TRAINING_EMPLOYEE_DETAIL WITH (NOLOCK)
				WHERE cmp_id = @Cmp_ID and ( Emp_tran_status = 1 or Emp_tran_status = 4)
				GROUP by Training_Apr_ID
			)TE ON TE.Training_Apr_ID = T0120_HRMS_TRAINING_APPROVAL.Training_Apr_ID
		WHERE T0120_HRMS_TRAINING_APPROVAL.Cmp_ID = @Cmp_ID AND k.From_date >= @From_Date AND k.From_date<= @To_Date
			and T0120_HRMS_TRAINING_APPROVAL.Training_Type = @Training_TypeId
		ORDER BY DATEPART(MONTH,k.From_date),TC.Training_Category_Name
	END
END

