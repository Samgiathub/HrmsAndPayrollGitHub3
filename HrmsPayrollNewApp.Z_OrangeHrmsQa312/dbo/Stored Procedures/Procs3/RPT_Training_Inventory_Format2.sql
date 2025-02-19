
---20/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[RPT_Training_Inventory_Format2]
	 @Cmp_ID		Numeric
	,@From_Date		Datetime 
	,@To_Date		Datetime
	,@Branch_ID		varchar(Max) 
	,@Cat_ID		varchar(Max)
	,@Grd_ID		varchar(Max) 
	,@Type_ID		varchar(Max) 
	,@Dept_ID		varchar(Max) 
	,@Desig_ID		varchar(Max)
	,@Emp_ID		Numeric
	,@Constraint	varchar(MAX)
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
	
	
	CREATE TABLE #First_Table
	(
		Cmp_Id				NUMERIC(18,0),
		Cmp_name			VARCHAR(100),
		cmp_Address			VARCHAR(200),
		cmp_logo			IMAGE,
		Branch_id			NUMERIC(18,0),
		Training_Year		INT
	)
	
	CREATE TABLE #Second_Table
	(
		Training_Apr_Id		NUMERIC(18,0),
		Training_Name       VARCHAR(100),
		Training_code		VARCHAR(50),
		Training_Date		DATETIME,
		Trainer_Name		VARCHAR(100),
		Branch_Id			NUMERIC(18,0),
		Training_Year		INT,
		Training_Month		VARCHAR(15)
	)
	
	IF @Branch_ID <>''
		BEGIN 
			INSERT INTO #First_Table
			SELECT C.Cmp_Id,C.Cmp_Name,CASE WHEN ISNULL(B.Branch_Address,Cmp_Address) ='' THEN C.Cmp_Address ELSE B.Branch_Address END,C.cmp_logo,isnull(B.Branch_ID,0),DATEPART(YEAR,@From_Date)
			FROM   T0030_BRANCH_MASTER B WITH (NOLOCK) INNER JOIN
				   T0010_COMPANY_MASTER C WITH (NOLOCK) on C.Cmp_Id = B.Cmp_ID INNER JOIN 
				   (
						select Data from dbo.Split(@Branch_ID,'#')
				   )Sp on sp.Data = B.Branch_ID	
			WHERE B.Cmp_ID = @Cmp_ID
						
			INSERT INTO #Second_Table	   
			SELECT  TA.Training_Apr_ID,TM.Training_name,isnull(TA.Training_Code,TA.Training_Apr_ID),From_date,TA.Faculty,FT.Branch_id,
					DATEPART(YEAR,From_date),dbo.F_GET_MONTH_NAME(DATEPART(MONTH,From_date))
			FROM   T0120_HRMS_TRAINING_APPROVAL TA WITH (NOLOCK)  INNER JOIN
				   T0040_Hrms_Training_master TM WITH (NOLOCK) on TM.Training_id = TA.Training_id INNER JOIN
				   (
						SELECT  MIN(From_date)From_date,Training_App_ID
						FROM  T0120_HRMS_TRAINING_Schedule WITH (NOLOCK)
						GROUP BY Training_App_ID
				   )TS on TS.Training_App_ID = TA.Training_App_ID Inner JOIN
				   #First_Table FT on FT.cmp_id = TA.Cmp_ID
			WHERE EXISTS(
							SELECT data FROM dbo.Split(TA.branch_Id,'#')TB
							WHERE TB.Data<>'' and  TB.data = FT.Branch_id
						)	
				AND TA.Cmp_ID = @Cmp_ID	AND TS.From_date >= @From_Date AND TS.From_date<= @To_Date
		END
	ELSE
		BEGIN 
			INSERT INTO #First_Table
			SELECT Cmp_Id,Cmp_Name,Cmp_Address,cmp_logo,0,DATEPART(YEAR,@From_Date)
			FROM  T0010_COMPANY_MASTER WITH (NOLOCK)
			WHERE Cmp_Id = @Cmp_ID
			
			INSERT INTO #Second_Table
			SELECT  TA.Training_Apr_ID,TM.Training_name,isnull(TA.Training_Code,TA.Training_Apr_ID),From_date,TA.Faculty,0,
					DATEPART(YEAR,From_date),dbo.F_GET_MONTH_NAME(DATEPART(MONTH,From_date))
			FROM   T0120_HRMS_TRAINING_APPROVAL TA  WITH (NOLOCK) INNER JOIN
				   T0040_Hrms_Training_master TM WITH (NOLOCK) on TM.Training_id = TA.Training_id INNER JOIN
				   (
						SELECT  MIN(From_date)From_date,Training_App_ID
						FROM  T0120_HRMS_TRAINING_Schedule WITH (NOLOCK)
						GROUP BY Training_App_ID
				   )TS on TS.Training_App_ID = TA.Training_App_ID
			WHERE TA.Cmp_ID = @Cmp_ID AND TS.From_date >= @From_Date AND TS.From_date<= @To_Date	
		END
		
	
		
	SELECT * FROM #First_Table
	SELECT * FROM #Second_Table order by Training_Date
	
	
	DROP TABLE #First_Table
	DROP TABLE #Second_Table
END

