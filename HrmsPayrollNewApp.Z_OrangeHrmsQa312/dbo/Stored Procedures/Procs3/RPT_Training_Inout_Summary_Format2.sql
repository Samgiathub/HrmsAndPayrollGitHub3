


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[RPT_Training_Inout_Summary_Format2]
	@Cmp_ID		Numeric
	,@From_Date		Datetime 
	,@To_Date		Datetime
	,@Branch_ID		varchar(Max)='' 
	,@Cat_ID		varchar(Max)
	,@Grd_ID		varchar(Max) 
	,@Type_ID		varchar(Max) 
	,@Dept_ID		varchar(Max)='' 
	,@Desig_ID		varchar(Max)
	,@Emp_ID		Numeric
	,@Constraint	varchar(MAX)
	,@Report_Type	tinyint = 0
	,@Training_id   numeric(18,0)
	,@PBranch_ID	varchar(max)= ''
	,@PVertical_ID	varchar(max)= '' 
	,@PSubVertical_ID	varchar(max)= '' 
	,@PDept_ID varchar(max)=''
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN


	IF @PBranch_ID = '0' or @PBranch_ID='' 
		set @PBranch_ID = null   			
	IF @PVertical_ID ='0' or @PVertical_ID = ''		
		set @PVertical_ID = null	
	IF @PsubVertical_ID ='0' or @PsubVertical_ID = ''
		set @PsubVertical_ID = null		
	IF @PDept_ID = '0' or @PDept_Id=''  
		set @PDept_ID = NULL	 
	
	IF @PBranch_ID is null
	BEGIN	
		SELECT   @PBranch_ID = COALESCE(@PBranch_ID + ',', '') + cast(Branch_ID as nvarchar(5))  from T0030_BRANCH_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_ID 
		SET @PBranch_ID = @PBranch_ID + ',0'
	END
	
	IF @PVertical_ID is null
	BEGIN		
		SELECT  @PVertical_ID = COALESCE(@PVertical_ID + ',', '') + cast(Vertical_ID as nvarchar(5))  from T0040_Vertical_Segment WITH (NOLOCK) where Cmp_ID=@Cmp_ID 
		
		IF @PVertical_ID IS NULL
			SET @PVertical_ID = '0'				
		ELSE
			SET @PVertical_ID = @PVertical_ID + ',0'		
	END
	
	IF @PsubVertical_ID is null
	Begin	
		SELECT   @PsubVertical_ID = COALESCE(@PsubVertical_ID + ',', '') + cast(subVertical_ID as nvarchar(5))  from T0050_SubVertical WITH (NOLOCK) where Cmp_ID=@Cmp_ID 
		IF @PsubVertical_ID IS NULL
			SET @PsubVertical_ID = '0';
		ELSE
			SET @PsubVertical_ID = @PsubVertical_ID + ',0'
	END
	
	IF @PDept_ID is null
	Begin
		SELECT   @PDept_ID = COALESCE(@PDept_ID + ',', '') + cast(Dept_ID as nvarchar(5))  from T0040_DEPARTMENT_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_ID 		
		IF @PDept_ID is null
			SET @PDept_ID = '0';
		ELSE
			SET @PDept_ID = @PDept_ID + ',0'
	End	
	
	CREATE TABLE #Emp_Cons 
	 (      
	   Emp_ID numeric ,     
	   Branch_ID numeric,
	   Increment_ID numeric    
	 )  
	EXEC SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,0,0,'','','','',0,0,0,'0',0,0 
	
	DELETE FROM #Emp_Cons
	WHERE NOT EXISTS (
						SELECT	 E.Emp_ID 
						FROM	#Emp_Cons as  E Inner JOIN T0095_INCREMENT AS i WITH (NOLOCK) ON i.Increment_ID = E.Increment_ID
						WHERE	 #Emp_Cons.Increment_ID = E.Increment_ID
						  AND EXISTS (SELECT Data FROM dbo.Split(@PBranch_ID, ',') PB WHERE cast(PB.data AS NUMERIC)=Isnull(I.Branch_ID,0))
						  AND EXISTS (SELECT Data FROM dbo.Split(@PVertical_ID, ',') V WHERE cast(v.data AS NUMERIC)=Isnull(I.Vertical_ID,0))
						  AND EXISTS (SELECT Data FROM dbo.Split(@PsubVertical_ID, ',') S WHERE cast(S.data AS NUMERIC)=Isnull(I.SubVertical_ID,0))
						  AND  EXISTS (SELECT Data FROM dbo.Split(@PDept_ID, ',') D WHERE cast(D.data AS NUMERIC)=Isnull(I.Dept_ID,0))  
						  
					)
	UPDATE #Emp_Cons  set Branch_ID = a.Branch_ID FROM (
		SELECT DISTINCT VE.Emp_ID,VE.branch_id,VE.Increment_ID 
					  FROM dbo.V_Emp_Cons VE inner join
					  #Emp_Cons EC ON  VE.Emp_ID = EC.Emp_ID
		)a
	WHERE a.Emp_ID = #Emp_Cons.Emp_ID   
	
	CREATE TABLE #Training_Attendance
	(
		Cmp_Id				NUMERIC(18,0),
		Cmp_name			VARCHAR(100),
		cmp_Address			VARCHAR(200),
		cmp_logo			IMAGE,
		Training_Apr_Id		NUMERIC(18,0),
		Training_Name       VARCHAR(100),
		Training_code		VARCHAR(50),
		Training_Date		DATETIME,
		Training_Time		DATETIME,
		emp_id				numeric(18),
		Emp_code			 varchar(50),
		Emp_Full_Name		 varchar(50),
		Dept_Name			 varchar(50)
	)
	
	IF @Report_Type = 0
		BEGIN
			INSERT INTO #Training_Attendance
			SELECT C.Cmp_Id,C.Cmp_Name,C.Cmp_Address,C.cmp_logo,TA.Training_Apr_ID,TM.Training_name,TA.Training_Code,
					TS.From_date,TS.From_Time,TIO.emp_id,E.Alpha_Emp_Code,E.Emp_Full_Name,DM.Dept_Name 
			FROM   T0120_HRMS_TRAINING_APPROVAL TA WITH (NOLOCK) INNER JOIN
					(
						SELECT distinct emp_id,Training_Apr_Id
						FROM   T0150_EMP_Training_INOUT_RECORD	WITH (NOLOCK)
				   )TIO ON TIO.Training_Apr_Id = TA.Training_Apr_Id INNER JOIN
				   (
						SELECT MIN(From_date)From_date,MIN(convert(TIME,From_Time))From_Time,Training_App_ID
						FROM   T0120_HRMS_TRAINING_Schedule	WITH (NOLOCK)
						GROUP BY Training_App_ID
				   )TS ON TS.Training_App_ID = TA.Training_App_ID INNER JOIN
				   T0010_COMPANY_MASTER C WITH (NOLOCK) ON C.Cmp_Id = TA.Cmp_ID INNER JOIN
				   T0040_Hrms_Training_master TM WITH (NOLOCK) ON TM.Training_id = TA.Training_id INNER JOIN
				   T0080_EMP_MASTER E WITH (NOLOCK) ON E.Emp_ID = TIO.emp_id INNER JOIN 
				   #Emp_Cons E1 ON E1.Emp_ID = TIO.emp_id INNER JOIN 
						( SELECT I.Branch_ID,I.Grd_ID,I.Dept_ID,I.Desig_ID,I.Emp_ID 
						  FROM dbo.T0095_Increment I WITH (NOLOCK) INNER JOIN 
								( SELECT max(Increment_ID) AS Increment_ID , Emp_ID 
								  FROM dbo.T0095_Increment WITH (NOLOCK)
								  GROUP BY emp_ID  
								) Qry ON
								I.Emp_ID = Qry.Emp_ID AND I.Increment_ID = Qry.Increment_ID	
						)Q_I ON E.EMP_ID = Q_I.EMP_ID LEFT OUTER JOIN
				  T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON Q_I.DEPT_ID = DM.DEPT_ID
			WHERE  TIO.Training_Apr_Id = @Training_id AND TA.cmp_Id = @Cmp_ID 
		END	
	ELSE
		BEGIN
			INSERT INTO #Training_Attendance
			SELECT  C.Cmp_Id,C.Cmp_Name,C.Cmp_Address,C.cmp_logo,TA.Training_Apr_ID,TM.Training_name,TA.Training_Code,
					TS.From_date,TS.From_Time,TED.emp_id,E.Alpha_Emp_Code,E.Emp_Full_Name,DM.Dept_Name 
			FROM   T0130_HRMS_TRAINING_EMPLOYEE_DETAIL TED WITH (NOLOCK) INNER JOIN
				   T0120_HRMS_TRAINING_APPROVAL TA WITH (NOLOCK) on TA.Training_Apr_ID = TED.Training_Apr_Id INNER JOIN
				   (
						SELECT MIN(From_date)From_date,MIN(From_Time)From_Time,Training_App_ID
						FROM   T0120_HRMS_TRAINING_Schedule	WITH (NOLOCK)
						GROUP BY Training_App_ID
				   )TS ON TS.Training_App_ID = TA.Training_App_ID INNER JOIN
				   T0010_COMPANY_MASTER C WITH (NOLOCK) ON C.Cmp_Id = TA.Cmp_ID INNER JOIN
				   T0040_Hrms_Training_master TM WITH (NOLOCK) ON TM.Training_id = TA.Training_id INNER JOIN
				   T0080_EMP_MASTER E WITH (NOLOCK) ON E.Emp_ID = TED.emp_id INNER JOIN 
				   #Emp_Cons E1 ON E1.Emp_ID = TED.emp_id INNER JOIN 
						( SELECT I.Branch_ID,I.Grd_ID,I.Dept_ID,I.Desig_ID,I.Emp_ID 
						  FROM dbo.T0095_Increment I WITH (NOLOCK) INNER JOIN 
								( SELECT max(Increment_ID) AS Increment_ID , Emp_ID 
								  FROM dbo.T0095_Increment WITH (NOLOCK)
								  GROUP BY emp_ID  
								) Qry ON
								I.Emp_ID = Qry.Emp_ID AND I.Increment_ID = Qry.Increment_ID	
						)Q_I ON E.EMP_ID = Q_I.EMP_ID LEFT OUTER JOIN
				  T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON Q_I.DEPT_ID = DM.DEPT_ID
			WHERE  TED.Training_Apr_Id = @Training_id AND TED.cmp_Id = @Cmp_ID 
				   AND NOT EXISTS  (
										SELECT 1 FROM 
											T0150_EMP_Training_INOUT_RECORD EI WITH (NOLOCK)
										where EI.emp_id=TED.Emp_ID and EI.Training_Apr_Id = TED.Training_Apr_ID
									)
		END
	
	
	SELECT  *	 
	FROM #Training_Attendance
	
	DROP TABLE #Training_Attendance
END

