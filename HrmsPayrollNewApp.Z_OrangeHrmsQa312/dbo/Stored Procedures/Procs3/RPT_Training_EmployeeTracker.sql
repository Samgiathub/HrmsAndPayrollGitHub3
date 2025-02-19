

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---20/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[RPT_Training_EmployeeTracker]
		 @Cmp_ID		Numeric(18,0)
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
	
	CREATE TABLE #Emp_Cons 
	 (      
		   Emp_ID numeric ,  
		   Branch_ID numeric, 
		   Increment_ID numeric    
	 )  
	
	EXEC SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,0,0,'','','','',0,0,0,'0',0,0 
		
	UPDATE #Emp_Cons  SET Branch_ID = a.Branch_ID FROM (
		SELECT DISTINCT VE.Emp_ID,VE.Branch_ID,VE.Increment_ID 
					  FROM dbo.V_Emp_Cons VE inner join
					  #Emp_Cons EC on  VE.Emp_ID = EC.Emp_ID
		)a
	WHERE a.Emp_ID = #Emp_Cons.Emp_ID 
	
	CREATE TABLE #Employee_Dept
	(
		Emp_Id		NUMERIC(18,0),
		Employee	VARCHAR(200),
		Dept_Id		NUMERIC(18,0),
		Dept_Name	VARCHAR(100)		
	)
	
	IF @Dept_ID <>''
		BEGIN			
			Insert INTO #Employee_Dept
			SELECT E.Emp_ID,EM.Alpha_Emp_Code Employee,I.dept_Id,D.Dept_Name FROM --(EM.Alpha_Emp_Code +'-'+ EM.Emp_Full_Name)
				#Emp_Cons E INNER JOIN 
				T0080_EMP_MASTER EM WITH (NOLOCK) on EM.Emp_ID = E.Emp_ID INNER JOIN 
				T0095_INCREMENT I WITH (NOLOCK) on I.Increment_ID = E.Increment_ID LEFT JOIN 
				T0040_DEPARTMENT_MASTER D WITH (NOLOCK) on D.Dept_Id = I.Dept_ID
			WHERE em.Emp_Left<>'Y' 
			--and I.Dept_ID = (select data from dbo.Split(@Dept_ID,'#'))
			and ISNULL(I.Dept_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Dept_ID,ISNULL(I.Dept_ID,0)),'#'))--Mukti(16062017) 
		END	
	CREATE TABLE #Training_Emp
	(
		 Training_Apr_ID		numeric(18,0)
		,Trainingdate			datetime
		,Training_name			varchar(500)
		,Dept_Id				numeric(18,0)
		,Dept_Name				varchar(100)
		,Cmp_name			varchar(100)
		,cmp_Address			varchar(200)
		,cmp_logo			   image
		,Emp_Id					numeric(18,0)
		,Emp_Full_Name			Varchar(200)
		,Eligible				varchar(50)
	)	
	INSERT INTO #Training_Emp(Training_Apr_ID,Trainingdate,Training_name,Dept_Id,Dept_Name,Cmp_name,cmp_Address,cmp_logo,Emp_Id,Emp_Full_Name)
	SELECT  TA.Training_Apr_ID,TS.Trainingdate,(isnull(TA.Training_Code,TA.Training_Apr_ID) +'-'+ TM.Training_name),ED.Dept_Id,
	ED.Dept_Name,c.Cmp_Name,c.Cmp_Address,c.cmp_logo,ED.Emp_ID,ED.Employee
	FROM T0120_HRMS_TRAINING_APPROVAL TA WITH (NOLOCK) INNER JOIN
	(
		SELECT MIN(From_date)Trainingdate,Training_App_ID
		FROM T0120_HRMS_TRAINING_Schedule WITH (NOLOCK)
		GROUP by Training_App_ID 
	)TS ON TS.Training_App_ID = TA.Training_App_ID INNER JOIN
	T0040_Hrms_Training_master TM WITH (NOLOCK) on TM.Training_id = TA.Training_id INNER JOIN
	T0010_COMPANY_MASTER c WITH (NOLOCK) on c.Cmp_Id = TA.Cmp_ID 
	CROSS JOIN #Employee_Dept ED 
	WHERE TA.Cmp_ID = @Cmp_ID AND TS.Trainingdate >= @From_Date AND TS.Trainingdate <= @To_Date AND TA.Apr_Status =1 
			
	UPDATE #Training_Emp
	SET Eligible = S.eligible
	FROM
	(
		SELECT TA.Training_Apr_ID,TA.Emp_Id,
				CASE WHEN TE.Emp_ID IS NOT NULL THEN 
						CASE WHEN TI.emp_id is NULL THEN '' ELSE CONVERT(VARCHAR(15),TI.For_date,105) END
					ELSE 'X' 
					END AS eligible
		FROM #Training_Emp TA LEFT JOIN
		T0130_HRMS_TRAINING_EMPLOYEE_DETAIL TE WITH (NOLOCK) ON TE.Training_Apr_ID = TA.Training_Apr_ID and 
		TA.Emp_Id = TE.Emp_ID left JOIN
		(
			SELECT min(For_date)For_date,Training_Apr_Id,emp_id
			FROM T0150_EMP_Training_INOUT_RECORD WITH (NOLOCK)
			WHERE cmp_Id = @Cmp_ID
			GROUP BY Training_Apr_Id ,emp_id
		)TI ON TI.Training_Apr_Id = TE.Training_Apr_ID 
		and TE.Emp_Id = TI.emp_id
		WHERE   (TE.Emp_tran_status =1 OR TE.Emp_tran_status=4) 
	)S
	WHERE #Training_Emp.Training_Apr_ID = S.Training_Apr_ID and  #Training_Emp.Emp_Id = s.Emp_Id	 
	
	UPDATE #Training_Emp
	SET Eligible = 'X'
	WHERE Eligible is NULL
	
	DECLARE @query VARCHAR(max)
	DECLARE @columns VARCHAR(8000)

	SELECT @columns = COALESCE(@columns + ',[' + cast(Emp_Full_Name AS VARCHAR(200)) + ']',
				'[' + cast(Emp_Full_Name AS VARCHAR(200))+ ']')
				 FROM #Training_Emp
				GROUP BY Emp_Full_Name,Emp_Id
				ORDER by Emp_Id ASC
				
	SET @query = 'SELECT  Cmp_name,cmp_Address, Trainingdate,Dept_Name,ROW_NUMBER() OVER(ORDER BY Trainingdate) AS SrNo,Training_name as Topic,dbo.F_GET_MONTH_NAME(datepart(MONTH,Trainingdate)) ''Scheduled Month'','+ @columns +','''' as Remarks,'''' as ''Verified by HOD''
			  FROM   (
						SELECT 
							 Training_Apr_ID,Training_name,Trainingdate,Dept_Id,Dept_Name,emp_full_name,Eligible,Cmp_name,cmp_Address 
						FROM #Training_Emp 
					)  as s 
			PIVOT
				(
					max(Eligible)
					FOR [Emp_Full_Name] IN (' + @columns + ')
				)AS T order by Trainingdate'
			 
	--print @query
	exec(@query)

	DROP TABLE #Emp_Cons
	DROP TABLE #Employee_Dept
	DROP TABLE #Training_Emp
END

