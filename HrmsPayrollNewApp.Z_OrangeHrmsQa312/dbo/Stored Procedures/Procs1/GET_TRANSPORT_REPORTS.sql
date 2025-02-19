

 ---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[GET_TRANSPORT_REPORTS]
	@FromDate datetime,
	@ToDate	datetime,
	@Emp_ID varchar(MAX),
	@ReportType int,
	@Route_ID varchar(MAX) = '',
	@Month int = 0,
	@Year int = 0
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

IF OBJECT_ID('tempdb..#Emp_Temp') IS NOT NULL
	BEGIN
		DROP TABLE #Emp_Temp
	END
	
CREATE TABLE #Emp_Temp 
(      
	Emp_ID numeric(18,0)
)  
IF @Emp_ID <> ''
	BEGIN
		INSERT INTO #Emp_Temp SELECT CAST(Data AS numeric) FROM dbo.Split(@Emp_ID,'#')       
	END
	
IF OBJECT_ID('tempdb..#Route_Temp') IS NOT NULL
	BEGIN
		DROP TABLE #Route_Temp
	END
	
CREATE TABLE #Route_Temp
(      
	Route_ID numeric(18,0)
)  
IF @Route_ID <> ''
	BEGIN
		INSERT INTO #Route_Temp SELECT CAST(Data AS numeric) FROM dbo.Split(@Route_ID,',')       
	END
ELSE
	BEGIN
		INSERT INTO #Route_Temp  SELECT Route_ID FROM T0040_Route_Master 
	END

IF @ReportType = 0  -- Route Wise Employee Report
	BEGIN
		SELECT ETR.Emp_ID,ETR.Route_ID,ETR.Pickup_ID,(RM.Route_No+' - '+RM.Route_Name) AS 'Route_Name',RM.Route_KM,RM.Route_No,RM.Fuel_Place,PSM.Pickup_Name,PSM.Pickup_KM,
		PSFM.Fare ,PSFM.Discount,PSFM.NetFare,EM.Emp_code,EM.Alpha_Emp_Code,DM.Dept_Name,VS.Vertical_Name,BS.Segment_Name,
		(EM.Initial+' '+EM.Emp_First_Name+' '+ISNULL(EM.Emp_Second_Name,'')+' '+ISNULL(EM.Emp_Last_Name,'')) AS 'Emp_FullName',
		PSFM.Month,PSFM.Year,PSFM.PresentDays,PSFM.Absent,(PSFM.NetFare * PSFM.PresentDays) AS 'TotalAmt',TRM.ReportingMgr,
		CM.Cmp_Name,Cm.Cmp_Address,--0.00 AS 'Net_Amount',0.00 AS 'Gross_Salary',0.00 AS 'Actually_Gross_Salary'
		ISNULL(MS.Net_Amount,0.00) AS 'Net_Amount',ISNULL(MS.Gross_Salary,0.00) AS 'Gross_Salary',CONVERT(varchar(11),@FromDate,103) AS 'FromDate',
		CONVERT(varchar(11),@ToDate,103) as 'Todate'
		--ISNULL(MS.Actually_Gross_Salary ,0.00) AS 'Actually_Gross_Salary'
		FROM T0040_Employee_Transport_Registration ETR WITH (NOLOCK)
		--INNER JOIN T0040_Route_Master RM ON ETR.Route_ID = RM.Route_ID
		INNER JOIN T0040_PickupStation_Master PSM WITH (NOLOCK) ON ETR.Pickup_ID = PSM.Pickup_ID
		INNER JOIN T0040_Route_Master RM WITH (NOLOCK) ON PSM.Route_ID = RM.Route_ID
		INNER JOIN 
		(
			SELECT TPS.Emp_ID,PS.Fare_ID,PS.Pickup_ID,PS.Fare,PS.Discount,PS.NetFare,PS.Effective_Date,PS.Cmp_ID,TPS.Month,TPS.Year,TPS.PresentDays,TPS.Absent
			FROM T0040_PickupStation_Fare_Master PS WITH (NOLOCK)
			INNER JOIN
			(
				SELECT EAI.Emp_ID,EAI.Month,EAI.Year,ETR.Pickup_ID,MAX(PFM.Effective_Date) AS 'Effective_Date',EAI.PresentDays,EAI.Absent
				FROM T0040_Employee_Transport_Registration ETR WITH (NOLOCK)
				INNER JOIN T0170_EMP_ATTENDANCE_IMPORT_TRANSPORT EAI WITH (NOLOCK) ON ETR.Emp_ID = EAI.Emp_ID
				INNER JOIN T0040_PickupStation_Fare_Master PFM WITH (NOLOCK) ON ETR.Pickup_ID = PFM.Pickup_ID and YEAR(PFM.Effective_Date) <= EAI.Year 
				AND month(PFM.Effective_Date) <= EAI.Month 
				GROUP BY EAI.Emp_ID,EAI.Month,EAI.Year,ETR.Pickup_ID,EAI.PresentDays,EAI.Absent
				) TPS ON PS.Pickup_ID = TPS.Pickup_ID AND PS.Effective_Date  = TPS.Effective_Date 
		) PSFM ON ETR.Emp_ID = PSFM.Emp_ID AND ETR.Pickup_ID = PSFM.Pickup_ID
		INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON ETR.Emp_ID = EM.Emp_ID
		INNER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON EM.Dept_ID = DM.Dept_Id
		LEFT JOIN
		(
			SELECT TI.Segment_ID,TI.Vertical_ID,TI.Emp_ID,TI.Increment_ID   FROM T0095_INCREMENT TI WITH (NOLOCK)
			INNER JOIN 
			(
				SELECT MAX(Increment_Effective_Date) AS 'Increment_Effective_Date',Increment_ID FROM T0095_INCREMENT WITH (NOLOCK)
				GROUP BY Increment_ID
			) TIT ON TI.Increment_ID = TIT.Increment_ID 
		) TIIT ON EM.Increment_ID = TIIT.Increment_ID AND EM.Emp_ID = TIIT.Emp_ID 
		LEFT JOIN T0040_Vertical_Segment VS WITH (NOLOCK) ON TIIT.Vertical_ID = VS.Vertical_ID
		LEFT JOIN T0040_Business_Segment BS WITH (NOLOCK) ON TIIT.Segment_ID = BS.Segment_ID 
		LEFT JOIN
		(
			SELECT TEM.Emp_code,TEM.Alpha_Emp_Code,TEM.Emp_ID,
			(TEM.Initial+' '+TEM.Emp_First_Name+' '+ISNULL(TEM.Emp_Second_Name,'')+' '+ISNULL(TEM.Emp_Last_Name,'')) AS 'ReportingMgr' 
			FROM T0080_EMP_MASTER TEM WITH (NOLOCK)
			INNER JOIN
			(
				SELECT MAX(Effect_Date) AS 'Effect_Date',R_Emp_ID FROM T0090_EMP_REPORTING_DETAIL WITH (NOLOCK) GROUP BY R_Emp_ID 
			) TM ON TEM.Emp_ID = TM.R_Emp_ID
		) TRM ON EM.Emp_Superior = TRM.Emp_ID 
		INNER JOIN #Emp_Temp ET  ON ETR.Emp_ID = ET.Emp_ID
		INNER JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) ON ETR.Cmp_ID = CM.Cmp_Id
		LEFT JOIN T0200_MONTHLY_SALARY MS WITH (NOLOCK) ON ETR.Emp_ID = MS.Emp_ID AND Month(MS.Month_St_Date)= PSFM.Month  AND YEAR(MS.Month_St_Date) = PSFM.Year  
		--LEFT JOIN T0200_MONTHLY_SALARY MS ON ETR.Emp_ID = MS.Emp_ID --AND MS.Month_St_Date=  @FromDate  AND MS.Month_St_Date <= @ToDate
		WHERE MS.Month_St_Date >= @FromDate AND MS.Month_St_Date <= @ToDate
		
		ORDER BY EM.Emp_ID,PSFM.Year ,PSFM.Month  
	END
ELSE IF @ReportType = 1  -- Section Wise Transportation Report
	BEGIN
		
		SELECT ETR.Emp_ID,ETR.Route_ID,ETR.Pickup_ID,ETR.Vehicle_ID,CONVERT(varchar(11),ETR.Effective_Date,103) AS 'Effective_Date',
		RM.Route_Name,RM.Route_No,VM.Vehicle_No,VM.Vehicle_Name,EM.Emp_code,EM.Alpha_Emp_Code,VS.Vertical_Name,BS.Segment_Name,
		(EM.Initial+' '+EM.Emp_First_Name+' '+ISNULL(EM.Emp_Second_Name,'')+' '+ISNULL(EM.Emp_Last_Name,'')) AS 'Emp_FullName',
		TRM.ReportingMgr,CM.Cmp_Name,Cm.Cmp_Address,PM.Pickup_Name,EM.Work_Tel_No,EM.Mobile_No,EM.Alpha_Emp_Code,TIIT.Vertical_ID,TIIT.Segment_ID,
		CONVERT(varchar(11),@FromDate,103) AS 'FromDate',CONVERT(varchar(11),@ToDate,103) as 'Todate'
		FROM T0040_Employee_Transport_Registration ETR WITH (NOLOCK)
		INNER JOIN T0040_Route_Master RM WITH (NOLOCK) ON ETR.Route_ID = RM.Route_ID
		INNER JOIN T0040_Vehicle_Master VM WITH (NOLOCK) ON ETR.Vehicle_ID = VM.Vehicle_ID
		INNER JOIN T0040_PickupStation_Master PM WITH (NOLOCK) ON ETR.Pickup_ID = PM.Pickup_ID
		INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON ETR.Emp_ID = EM.Emp_ID
		LEFT JOIN
		(
			SELECT TI.Segment_ID,TI.Vertical_ID,TI.Emp_ID,TI.Increment_ID   FROM T0095_INCREMENT TI WITH (NOLOCK)
			INNER JOIN 
			(
				SELECT MAX(Increment_Effective_Date) AS 'Increment_Effective_Date',Increment_ID FROM T0095_INCREMENT WITH (NOLOCK)
				GROUP BY Increment_ID
			) TIT ON TI.Increment_ID = TIT.Increment_ID 
		) TIIT ON EM.Increment_ID = TIIT.Increment_ID AND EM.Emp_ID = TIIT.Emp_ID 
		LEFT JOIN T0040_Vertical_Segment VS WITH (NOLOCK) ON TIIT.Vertical_ID = VS.Vertical_ID
		LEFT JOIN T0040_Business_Segment BS WITH (NOLOCK) ON TIIT.Segment_ID = BS.Segment_ID
		LEFT JOIN
		(
			SELECT TEM.Emp_code,TEM.Alpha_Emp_Code,TEM.Emp_ID,
			(TEM.Initial+' '+TEM.Emp_First_Name+' '+ISNULL(TEM.Emp_Second_Name,'')+' '+ISNULL(TEM.Emp_Last_Name,'')) AS 'ReportingMgr' 
			FROM T0080_EMP_MASTER TEM WITH (NOLOCK)
			INNER JOIN
			(
				SELECT MAX(Effect_Date) AS 'Effect_Date',R_Emp_ID
				FROM T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)
				GROUP BY R_Emp_ID 
			) TM ON TEM.Emp_ID = TM.R_Emp_ID
		) TRM ON EM.Emp_Superior = TRM.Emp_ID 
		
		INNER JOIN #Emp_Temp ET  ON ETR.Emp_ID = ET.Emp_ID
		INNER JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) ON ETR.Cmp_ID = CM.Cmp_Id
		WHERE ETR.Effective_Date >= @FromDate AND ETR.Effective_Date <= @ToDate --AND EM.Emp_code = 3019
		ORDER BY TIIT.Vertical_ID 
		
		
	END
ELSE IF @ReportType = 2  -- Route Wise Employee Related Report
	BEGIN
		SELECT DISTINCT ETR.Emp_ID,ETR.Route_ID,ETR.Pickup_ID,(RM.Route_No+' - '+RM.Route_Name) AS 'Route_Name',RM.Route_KM,RM.Route_No,RM.Fuel_Place,PSM.Pickup_Name,PSM.Pickup_KM,
		PSFM.Fare ,PSFM.Discount,PSFM.NetFare,EM.Emp_code,EM.Alpha_Emp_Code,DM.Dept_Name,VS.Vertical_Name,BS.Segment_Name,
		(EM.Initial+' '+EM.Emp_First_Name+' '+ISNULL(EM.Emp_Second_Name,'')+' '+ISNULL(EM.Emp_Last_Name,'')) AS 'Emp_FullName',
		PSFM.Month,PSFM.Year,PSFM.PresentDays,PSFM.Absent,(PSFM.NetFare * PSFM.PresentDays) AS 'TotalAmt',
		(PSFM.Fare - PSFM.NetFare) AS 'CmpShare', TRM.ReportingMgr,CM.Cmp_Name,Cm.Cmp_Address,
		(CASE WHEN ETR.Transport_Type = 'T' THEN 'Temporary' ELSE 'Permanent' END) AS 'Transport_Type',
		(DATENAME(MONTH ,DATEADD(MONTH,@Month,0)- 1)) AS 'MonthName',@Year as 'YearName'
		FROM T0040_Employee_Transport_Registration ETR WITH (NOLOCK)
		INNER JOIN T0040_Route_Master RM WITH (NOLOCK) ON ETR.Route_ID = RM.Route_ID
		INNER JOIN T0040_PickupStation_Master PSM WITH (NOLOCK) ON ETR.Pickup_ID = PSM.Pickup_ID
		INNER JOIN 
		(
			SELECT TPS.Emp_ID,PS.Fare_ID,PS.Pickup_ID,PS.Fare,PS.Discount,PS.NetFare,PS.Effective_Date,PS.Cmp_ID,TPS.Month,TPS.Year,TPS.PresentDays,TPS.Absent
			FROM T0040_PickupStation_Fare_Master PS WITH (NOLOCK)
			INNER JOIN
			(
				SELECT EAI.Emp_ID,EAI.Month,EAI.Year,ETR.Pickup_ID,MAX(PFM.Effective_Date) AS 'Effective_Date',EAI.PresentDays,EAI.Absent
				FROM T0040_Employee_Transport_Registration ETR WITH (NOLOCK)
				INNER JOIN T0170_EMP_ATTENDANCE_IMPORT_TRANSPORT EAI WITH (NOLOCK) ON ETR.Emp_ID = EAI.Emp_ID
				INNER JOIN T0040_PickupStation_Fare_Master PFM WITH (NOLOCK) ON ETR.Pickup_ID = PFM.Pickup_ID and YEAR(PFM.Effective_Date) <= EAI.Year 
				AND month(PFM.Effective_Date) <= EAI.Month  
				GROUP BY EAI.Emp_ID,EAI.Month,EAI.Year,ETR.Pickup_ID,EAI.PresentDays,EAI.Absent
				) TPS ON PS.Pickup_ID = TPS.Pickup_ID AND PS.Effective_Date  = TPS.Effective_Date 
		) PSFM ON ETR.Emp_ID = PSFM.Emp_ID AND ETR.Pickup_ID = PSFM.Pickup_ID
		INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON ETR.Emp_ID = EM.Emp_ID
		INNER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON EM.Dept_ID = DM.Dept_Id
		LEFT JOIN T0040_Vertical_Segment VS WITH (NOLOCK) ON EM.Vertical_ID = VS.Vertical_ID
		LEFT JOIN T0040_Business_Segment BS WITH (NOLOCK) ON EM.Segment_ID = BS.Segment_ID 
		LEFT JOIN
		(
			SELECT TEM.Emp_code,TEM.Alpha_Emp_Code,TEM.Emp_ID,
			(TEM.Initial+' '+TEM.Emp_First_Name+' '+ISNULL(TEM.Emp_Second_Name,'')+' '+ISNULL(TEM.Emp_Last_Name,'')) AS 'ReportingMgr' 
			FROM T0080_EMP_MASTER TEM WITH (NOLOCK)
			INNER JOIN
			(
				SELECT MAX(Effect_Date) AS 'Effect_Date',R_Emp_ID FROM T0090_EMP_REPORTING_DETAIL WITH (NOLOCK) GROUP BY R_Emp_ID 
			) TM ON TEM.Emp_ID = TM.R_Emp_ID
		) TRM ON EM.Emp_Superior = TRM.Emp_ID 
		INNER JOIN #Emp_Temp ET  ON ETR.Emp_ID = ET.Emp_ID
		INNER JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) ON ETR.Cmp_ID = CM.Cmp_Id
		
		--WHERE ETR.Effective_Date >= @FromDate AND ETR.Effective_Date <= @ToDate
		--WHERE PSFM.Month >= Month(@FromDate) AND PSFM.Year >= Year(@FromDate) AND PSFM.Month >= Month(@ToDate) AND PSFM.Year >= Year(@ToDate)--AND ETR.Effective_Date <= @ToDate
		
		WHERE PSFM.Month = @Month AND PSFM.Year = @Year
		ORDER BY ETR.Emp_ID--,PSFM.Year ,PSFM.Month  
	END
ELSE IF @ReportType = 3  -- All Route Details Report
	BEGIN
		SELECT RM.Route_ID,RM.Route_No,RM.Route_Name,ETR.Pickup_ID,PM.Pickup_Name,CM.Cmp_Name,CM.Cmp_Address,
		COUNT(ETR.Emp_ID) AS 'Employee',SUM(PFM.NetFare) AS 'EmpShare',
		SUM(PFM.Fare-PFM.NetFare) AS 'CmpShare',SUM(PFM.Fare) AS 'TotalFare',
		CONVERT(varchar(11),@FromDate,103) AS 'FromDate',CONVERT(varchar(11),@ToDate,103) as 'Todate'
		FROM T0040_Route_Master RM WITH (NOLOCK)
		INNER JOIN T0040_Employee_Transport_Registration ETR WITH (NOLOCK) ON RM.Route_ID = ETR.Route_ID
		INNER JOIN T0040_PickupStation_Master PM WITH (NOLOCK) ON ETR.Pickup_ID = PM.Pickup_ID
		INNER JOIN T0040_PickupStation_Fare_Master PFM WITH (NOLOCK) ON ETR.Pickup_ID = PFM.Pickup_ID
		INNER JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) ON ETR.Cmp_ID = CM.Cmp_Id
		INNER JOIN #Emp_Temp ET ON ETR.Emp_ID = ET.Emp_ID
		WHERE RM.Effective_Date >= @FromDate AND RM.Effective_Date <= @ToDate
		GROUP BY RM.Route_ID,RM.Route_No,RM.Route_Name,ETR.Pickup_ID,PM.Pickup_Name,CM.Cmp_Name,CM.Cmp_Address
	END
ELSE IF @ReportType = 4  -- Private Vehicle Driver & Route Details
	BEGIN
		SELECT EM.Route_ID,RM.Route_No,RM.Route_Name,RM.Route_KM, 
		RM.Vehicle_ID,VM.Vehicle_Name,VM.Vehicle_No,VM.Vehicle_Type,VM.Vehicle_Owner,VM.Driver_Name,
		VM.Driver_ContactNo,EM.Designation_Name,EM.Alpha_Emp_Code,EM.Mobile_No,EM.Work_Tel_No,
		CM.Cmp_Name,CM.Cmp_Address,EM.Emp_FullName,
		CONVERT(varchar(11),@FromDate,103) AS 'FromDate',CONVERT(varchar(11),@ToDate,103) as 'Todate'
		FROM T0040_Vehicle_Master VM WITH (NOLOCK)
		INNER JOIN T0050_Route_Vehicle_Details RVD WITH (NOLOCK) ON VM.Vehicle_ID = RVD.Vehicle_ID
		INNER JOIN T0040_Route_Master RM WITH (NOLOCK) ON RVD.Route_ID = RM.Route_ID
		LEFT JOIN
		(
			SELECT ETR.Emp_ID,ETR.Route_ID,DM.Designation_Name,DM.Designation_ID,TEM.Alpha_Emp_Code,TEM.Mobile_No,
			TEM.Work_Tel_No,ETR.Cmp_ID,
			(TEM.Alpha_Emp_Code +' - '+TEM.Initial+' '+TEM.Emp_First_Name+' '+ISNULL(TEM.Emp_Second_Name,'')+' '+ISNULL(TEM.Emp_Last_Name,'')) AS 'Emp_FullName'
			FROM T0040_Employee_Transport_Registration ETR WITH (NOLOCK)
			INNER JOIN T0040_DESIGNATION_MASTER_TRANSPORT DM WITH (NOLOCK) ON ETR.Designation_ID = DM.Designation_ID
			INNER JOIN T0080_EMP_MASTER TEM WITH (NOLOCK) ON ETR.Emp_ID = TEM.Emp_ID 
			WHERE DM.Designation_Name = 'Conductor'
		) EM ON RM.Route_ID = EM.Route_ID 
		INNER JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) ON RM.Cmp_ID = CM.Cmp_Id
		--INNER JOIN #Emp_Temp ET ON EM.Emp_ID = ET.Emp_ID
		WHERE Vehicle_Owner = 'Other Company' AND RM.Effective_Date >= @FromDate AND RM.Effective_Date <= @ToDate
	END
ELSE IF @ReportType = 5  -- Staff Bus Driver & Route Details
	BEGIN
		SELECT ETR.Emp_ID,ETR.Route_ID,ETR.Designation_ID,VM.Vehicle_Name,VM.Vehicle_No,DM.Designation_Name,
		VM.Vehicle_Owner,VM.Vehicle_ID,RM.Route_No,RM.Route_Name,RM.Route_KM,EM.Alpha_Emp_Code,EM.Emp_code,EM.Work_Tel_No,
		EM.Mobile_No,(EM.Alpha_Emp_Code +' - '+ EM.Initial+' '+EM.Emp_First_Name+' '+ISNULL(EM.Emp_Second_Name,'')+' '+ISNULL(EM.Emp_Last_Name,'')) AS 'Emp_FullName',
		CM.Cmp_Name,CM.Cmp_Address,
		CONVERT(varchar(11),@FromDate,103) AS 'FromDate',CONVERT(varchar(11),@ToDate,103) as 'Todate'
		FROM T0040_Employee_Transport_Registration ETR WITH (NOLOCK)
		INNER JOIN T0050_Route_Vehicle_Details RVD WITH (NOLOCK) ON ETR.Vehicle_ID = RVD.Vehicle_ID AND ETR.Route_ID = RVD.Route_ID
		INNER JOIN T0040_Route_Master RM WITH (NOLOCK) ON RVD.Route_ID = RM.Route_ID
		INNER JOIN T0040_Vehicle_Master VM WITH (NOLOCK) ON RVD.Vehicle_ID = VM.Vehicle_ID
		INNER JOIN T0040_DESIGNATION_MASTER_TRANSPORT DM WITH (NOLOCK) ON ETR.Designation_ID = DM.Designation_ID
		INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON ETR.Emp_ID = EM.Emp_ID
		INNER JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) ON ETR.Cmp_ID = CM.Cmp_Id
		--INNER JOIN #Emp_Temp ET ON EM.Emp_ID = ET.Emp_ID
		--INNER JOIN #Route_Temp RT ON RM.Route_ID = RT.Route_ID
		WHERE VM.Vehicle_Owner = 'Company' AND RM.Effective_Date >= @FromDate AND RM.Effective_Date <= @ToDate
		ORDER BY VM.Vehicle_ID 
	END
ELSE IF @ReportType = 6  -- Route Wise Pick Station & Fair
	BEGIN
		SELECT RM.Route_ID,RM.Route_Name,RM.Route_No,RM.Route_KM,RM.Vehicle_ID,PM.Pickup_ID,PM.Pickup_Name,PM.Pickup_KM,
		PFM.Fare,PFM.Discount,PFM.NetFare,CONVERT(varchar(11),PFM.Effective_Date,103) AS 'Effective_Date',
		CM.Cmp_Name,CM.Cmp_Address,(PFM.Fare - PFM.NetFare) AS 'DiscAmt',
		CONVERT(varchar(11),@FromDate,103) AS 'FromDate',CONVERT(varchar(11),@ToDate,103) as 'Todate'
		FROM T0040_PickupStation_Master PM WITH (NOLOCK)
		INNER JOIN T0040_PickupStation_Fare_Master PFM WITH (NOLOCK) ON PM.Pickup_ID = PFM.Pickup_ID
		INNER JOIN T0040_Route_Master RM WITH (NOLOCK) ON PM.Route_ID = RM.Route_ID
		INNER JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) ON RM.Cmp_ID = CM.Cmp_Id
		INNER JOIN #Route_Temp RT ON PM.Route_ID = RT.Route_ID
		
		--WHERE (RM.Effective_Date >= @FromDate AND RM.Effective_Date <= @ToDate) OR 
		--(PFM.Effective_Date >= @FromDate AND PFM.Effective_Date <= @ToDate)
		WHERE RM.Effective_Date >= @FromDate AND RM.Effective_Date <= @ToDate
		ORDER BY PM.Pickup_ID
		--INNER JOIN T0040_Employee_Transport_Registration ETR ON ETR.Pickup_ID = PM.Pickup_ID
		
		
	END
	


