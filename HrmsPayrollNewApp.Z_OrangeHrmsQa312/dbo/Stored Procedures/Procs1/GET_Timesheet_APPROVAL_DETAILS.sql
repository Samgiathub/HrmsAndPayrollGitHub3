

 

 ---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[GET_Timesheet_APPROVAL_DETAILS]

--@FromDate Datetime,
--@ToDate Datetime,

@Cmp_ID Numeric(18,0),
@Timesheet_Period varchar(50) = null ,
@R_Emp_ID Numeric(18,0) = 0 ,
@Emp_Id Numeric(18,0) = 0

AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	SELECT  (LEFT(Replace(Timesheet_Period,' TO ','#'),CHARINDEX('#',Replace(Timesheet_Period,' TO ','#'))-1)) AS 'FromDate', 
    (right(Replace(Timesheet_Period,' TO ','#'),LEN(Replace(Timesheet_Period,' TO ','#'))-CHARINDEX('#',Replace(Timesheet_Period,' TO ','#') ))) AS 'TODate',
	 Timesheet_Period , (dbo.F_Return_Sec(PARSENAME(REPLACE(Mon,'#','.'),2))) 'Monday', (dbo.F_Return_Sec(PARSENAME(REPLACE(Tue,'#','.'),2))) 'Tuesday' ,
	(dbo.F_Return_Sec(PARSENAME(REPLACE(Wed,'#','.'),2))) 'Wednesday',  (dbo.F_Return_Sec(PARSENAME(REPLACE(Thu,'#','.'),2))) 'Thursday',
	(dbo.F_Return_Sec(PARSENAME(REPLACE(Fri,'#','.'),2))) 'Friday' , (dbo.F_Return_Sec(PARSENAME(REPLACE(Sat,'#','.'),2))) 'Saturday',
	(dbo.F_Return_Sec(PARSENAME(REPLACE(Sun,'#','.'),2))) 'Sunday',  
	(dbo.F_Return_Sec(PARSENAME(REPLACE(Mon,'#','.'),2)) + dbo.F_Return_Sec(PARSENAME(REPLACE(Tue,'#','.'),2)) +  dbo.F_Return_Sec(PARSENAME(REPLACE(Wed,'#','.'),2))+ 
	dbo.F_Return_Sec(PARSENAME(REPLACE(Thu,'#','.'),2))+  dbo.F_Return_Sec(PARSENAME(REPLACE(Fri,'#','.'),2))+  dbo.F_Return_Sec(PARSENAME(REPLACE(Sat,'#','.'),2))+
	dbo.F_Return_Sec(PARSENAME(REPLACE(Sun,'#','.'),2))) as 'TotalSecond' ,(EM.Emp_First_Name +' '+EM.Emp_Last_Name ) as 'EmpName',EM.Emp_Superior,
	ERD.R_Emp_ID ,TTA.Project_Status_ID,TAD.Project_ID,TAD.Task_ID,TTA.Cmp_ID,PS.Project_Status,TTA.Employee_ID, TTA.Timesheet_ID,PS.Color AS 'TSColor'   
	INTO #TimesheetDetails 
	FROM T0100_TS_Application TTA WITH (NOLOCK)
	INNER JOIN T0110_TS_Application_Detail TAD WITH (NOLOCK) ON TTA.Timesheet_ID = TAD.Timesheet_ID 
	INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON TTA.Employee_ID = EM.Emp_ID 

	INNER JOIN T0040_Project_Status PS WITH (NOLOCK) ON TTA.Project_Status_ID = PS.Project_Status_ID  
	LEFT JOIN T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) ON EM.Emp_ID = ERD.Emp_ID  
	WHERE TTA.Timesheet_Type = 'Weekly' AND ISNULL(Timesheet_Period,'') <> '' AND ISDATE(PARSENAME(REPLACE(Mon,'#','.'),2)) = 1
	
	
	--SELECT CONVERT(datetime  , FromDate,103),* FROM #TimesheetDetails
	--RETURN 
	
	IF @Emp_ID = 0 AND @Timesheet_Period = '0'
	
		BEGIN 
			SELECT  EmpName,Timesheet_Period,dbo.F_Return_Hours(SUM(TotalSecond)) AS 'TotalHour',Project_Status,TSColor
			FROM #TimesheetDetails WHERE Cmp_ID = @Cmp_ID --AND CONVERT(datetime  , FromDate,103) BETWEEN  @FromDate AND  @ToDate AND R_Emp_ID = @R_Emp_ID
			AND R_Emp_ID = @R_Emp_ID
			--AND Timesheet_Period = @TimesheetPeriod
			GROUP BY Timesheet_ID,Timesheet_Period,Employee_ID,EmpName,Project_Status,TSColor
		END
	ELSE IF @Emp_ID = 0
		BEGIN 
			SELECT  EmpName,Timesheet_Period,dbo.F_Return_Hours(SUM(TotalSecond)) AS 'TotalHour',Project_Status,TSColor
			FROM #TimesheetDetails WHERE Cmp_ID = @Cmp_ID AND R_Emp_ID = @R_Emp_ID AND Timesheet_Period = @Timesheet_Period
			GROUP BY Timesheet_ID,Timesheet_Period,Employee_ID,EmpName,Project_Status,TSColor
		END 
	ELSE IF @Timesheet_Period = '0'
		BEGIN
			SELECT  EmpName,Timesheet_Period,dbo.F_Return_Hours(SUM(TotalSecond)) AS 'TotalHour',Project_Status,TSColor
			FROM #TimesheetDetails WHERE Cmp_ID = @Cmp_ID AND Employee_ID = @Emp_Id AND R_Emp_ID = @R_Emp_ID
			GROUP BY Timesheet_ID,Timesheet_Period,Employee_ID,EmpName,Project_Status,TSColor
		END
	ELSE
		BEGIN
			SELECT  EmpName,Timesheet_Period,dbo.F_Return_Hours(SUM(TotalSecond)) AS 'TotalHour',Project_Status,TSColor 
			FROM #TimesheetDetails WHERE Cmp_ID = @Cmp_ID AND Employee_ID = @Emp_Id AND R_Emp_ID = @R_Emp_ID AND Timesheet_Period = @Timesheet_Period
			GROUP BY Timesheet_ID,Timesheet_Period,Employee_ID,EmpName,Project_Status,TSColor
		END 
		
	
