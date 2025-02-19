

 
CREATE PROCEDURE [dbo].[GET_Timesheet_Report]      
	@Month numeric(18,0),    
	@Year numeric(18,0),    
	@Cmp_ID Numeric(18,0),    
	@Emp_Id varchar(MAX),
	@Branch_ID numeric(18,0) = 0,
	@report_type varchar(200) =''

AS 

        SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON


DECLARE @MonthStartDate datetime      
DECLARE @MonthEndDate datetime
DECLARE @MonthTotal_Days Numeric(18,2)
DECLARE @Monthname varchar(50)           

SELECT @MonthStartDate = dbo.GET_MONTH_ST_DATE(@Month,@Year)      
SELECT @MonthEndDate = dbo.GET_MONTH_END_DATE (@Month,@Year)      
SELECT @MonthTotal_Days = DATENAME(d,@MonthEndDate)
SELECT @Monthname = DATENAME(m,@MonthEndDate)
		
IF @report_type = 'Collection'
	BEGIN
		IF @Branch_ID <> 0
			BEGIN
				SELECT CM.Collection_ID,CM.CollectionMonth,CM.CollectionYear,CD.Project_ID,CD.Service_Type,CD.Contract_Type,
				CD.FedoraCharges,CD.Practice_Collection,CD.TotalCharges,CD.Exchange_Rate,CD.Total_Fedora_Charges,CD.Other_Remarks,
				PM.Project_Name,PM.Project_Code,TCM.Cmp_Name,TCM.Cmp_Address,(CASE WHEN ISNULL(CD.Invoice,0) = 0  THEN 'No'  ELSE 'Yes'  END) AS 'Invoice',
				(CASE WHEN ISNULL(CD.Payment,0) = 0  THEN 'No' ELSE 'Yes' END) AS 'Payment'
				FROM T0040_Collection_Master CM WITH (NOLOCK)
				INNER JOIN T0050_Collection_Details CD WITH (NOLOCK) ON CM.Collection_ID = CD.Collection_ID
				INNER JOIN T0040_TS_Project_Master PM WITH (NOLOCK) ON CD.Project_ID = PM.Project_ID
				INNER JOIN T0010_COMPANY_MASTER TCM WITH (NOLOCK) ON CM.Cmp_ID = TCM.Cmp_Id 
				WHERE CM.CollectionMonth =@Monthname AND CM.CollectionYear = @Year AND PM.Branch_ID = @Branch_ID
			END
		ELSE
			BEGIN
				SELECT CM.Collection_ID,CM.CollectionMonth,CM.CollectionYear,CD.Project_ID,CD.Service_Type,CD.Contract_Type,
				CD.FedoraCharges,CD.Practice_Collection,CD.TotalCharges,CD.Exchange_Rate,CD.Total_Fedora_Charges,CD.Other_Remarks,
				PM.Project_Name,PM.Project_Code,TCM.Cmp_Name,TCM.Cmp_Address,(CASE WHEN ISNULL(CD.Invoice,0) = 0  THEN 'No'  ELSE 'Yes'  END) AS 'Invoice',
				(CASE WHEN ISNULL(CD.Payment,0) = 0  THEN 'No' ELSE 'Yes' END) AS 'Payment'
				FROM T0040_Collection_Master CM WITH (NOLOCK)
				INNER JOIN T0050_Collection_Details CD WITH (NOLOCK) ON CM.Collection_ID = CD.Collection_ID
				INNER JOIN T0040_TS_Project_Master PM WITH (NOLOCK) ON CD.Project_ID = PM.Project_ID
				INNER JOIN T0010_COMPANY_MASTER TCM WITH (NOLOCK) ON CM.Cmp_ID = TCM.Cmp_Id 
				WHERE CM.CollectionMonth =@Monthname AND CM.CollectionYear = @Year 
			END
			
	END
IF @report_type = 'Manager'
	BEGIN
		SELECT EM.Emp_ID ,(EM.Initial + ' ' + ISNULL(EM.Emp_First_Name,'')+' '+ISNULL(EM.Emp_Second_Name,'')+' '+ISNULL(EM.Emp_Last_Name,'')) AS 'EmpFullName' ,
		BM.Branch_ID,BM.Branch_Name,BM.Cmp_ID,CM.Cmp_Name ,CM.Cmp_Address,CM.Cmp_City,CM.Cmp_PinCode,DM.Dept_Name ,TDM.Desig_Name,
		TMS.Net_Amount,TMS.Actually_Gross_Salary,Datename(mm,TMS.Month_St_Date) as 'MonthName',year(TMS.Month_St_Date) AS 'Year'
		FROM T0080_EMP_MASTER EM WITH (NOLOCK)
		LEFT JOIN ( SELECT DISTINCT Employee_ID FROM T0100_TS_Application WITH (NOLOCK) WHERE MONTH(Entry_Date) = @Month AND YEAR(Entry_Date) = @Year
		) TA ON EM.Emp_ID = TA.Employee_ID  
		LEFT JOIN T0200_MONTHLY_SALARY TMS WITH (NOLOCK) ON EM.Emp_ID = TMS.Emp_ID 
		INNER JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) ON EM.Cmp_ID = CM.Cmp_Id 
		INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON EM.Branch_ID = BM.Branch_ID
		LEFT JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON EM.Dept_ID = DM.Dept_Id 
		LEFT JOIN T0040_DESIGNATION_MASTER TDM WITH (NOLOCK) ON EM.Desig_Id = TDM.Desig_ID 
		WHERE ISNULL(TA.Employee_ID ,0) = 0 AND TMS.Month_St_Date = @MonthStartDate AND TMS.Month_End_Date = @MonthEndDate
		ORDER BY EM.Emp_ID  
	END
ELSE
	BEGIN
	
		DECLARE @TotalHour VARCHAR(20)
		DECLARE @TotalSec numeric(18,0)
		DECLARE @CaptureSec numeric(18,0)
		DECLARE @CaptureHour VARCHAR(20) 
		DECLARE @strTotalHour VARCHAR(20) 
		DECLARE @strDiffHour VARCHAR(20)
		DECLARE @DiffHour numeric(18,2)
		DECLARE @DiffSec numeric(18,0)
		DECLARE @HourSalary numeric(18,2)      
		DECLARE @CaptureSalary numeric(18,2)      
		DECLARE @DiffSalary numeric(18,2)      
		DECLARE @Shift_Day_Hour Varchar(20)
		DECLARE @Shift_Day_Sec Numeric
		DECLARE @StrHoliday_Date Varchar(MAX)
		DECLARE @WeekoffDay varchar(50)
		DECLARE @StrWeekoff_Date Varchar(MAX)
		DECLARE @HalfDayDate varchar(MAX)
		--DECLARE @HalfDay numeric(18,2)
		--DECLARE @HalfDayHour varchar(50)
		--DECLARE @FullDayHour varchar(50)
		DECLARE @HalfDaySec numeric(18,0)
		DECLARE @FullDaySec numeric(18,0)
		DECLARE @OverheadCost numeric(18,2)

		DECLARE @Sal_cal_Days numeric(18,2)   
				 
		
		DECLARE @Holiday_Days Numeric(12,2)      
		DECLARE @Weekoff_Days Numeric(12,2)   
		DECLARE @Working_Days Numeric(12,2)      
		DECLARE @Cancel_Weekoff Numeric(12,2)      
		DECLARE @Cancel_Holiday Numeric(12,2)      
		DECLARE @Actual_Working_Sec Numeric 
		      
		    
		DECLARE @Actual_Working_Hours Varchar(20)  
		DECLARE @NetSalary numeric(18,2)      
		DECLARE @ActualGrossSalary numeric(18,2)      
		DECLARE @Sat_Day varchar(50)      
		DECLARE @Sat_Hour varchar(50)
		
		DECLARE @NTotalHour Numeric(18,2) 
		DECLARE @NCaptureHour Numeric(18,2)
		DECLARE @ShiftName varchar(50)
		
		DECLARE @ID Numeric(18,0)    
		DECLARE @EmpFullName varchar(50) 
		DECLARE @EmpFullNameSup varchar(50) 
		DECLARE @HalfDayHour varchar(50)
		DECLARE @FullDayHour varchar(50)
		DECLARE @HalfWeekDay varchar(50)
		DECLARE @FullDayCount int
		DECLARE @HalfDayCount int
		
		DECLARE @Training Numeric(18,2)
		DECLARE @AppraisalBonus Numeric(18,2)

		

		CREATE TABLE #EmployeeData                 
		   (                 
			Employee_Id   numeric(18,0),    
			EmpFullname varchar(50),
			EmpFullnameSup varchar(50), 
			ShiftName varchar(50), 
			NetSalary numeric(18,2),    
			CaptureSalary numeric(18,2),    
			DiffSalary numeric(18,2),    
			TotalHour VARCHAR(50),   
			TotalSec numeric(18,0),    
			CaptureHour VARCHAR(50),    
			CaptureSec numeric(18,0),
			DiffHour numeric(18,2),
			DiffSec numeric(18,0),
			HourSalary numeric(18,2),
			Cmp_ID numeric(18,0),
			TsMonth varchar(50),
			TsYear numeric(18,0),
			strDiffHour varchar(20),
			strTotalHour varchar(20)
		   )    
		
		
		BEGIN TRY
		
			;WITH Days_Of_The_Week AS (
				SELECT 1 AS day_number, 'Sunday' AS day_name UNION ALL
				SELECT 2 AS day_number, 'Monday' AS day_name UNION ALL
				SELECT 3 AS day_number, 'Tuesday' AS day_name UNION ALL
				SELECT 4 AS day_number, 'Wednesday' AS day_name UNION ALL
				SELECT 5 AS day_number, 'Thursday' AS day_name UNION ALL
				SELECT 6 AS day_number, 'Friday' AS day_name UNION ALL
				SELECT 7 AS day_number, 'Saturday' AS day_name
				
			)
			SELECT day_name,(1 + DATEDIFF(wk, @MonthStartDate, @MonthEndDate) -
			CASE WHEN DATEPART(weekday, @MonthStartDate) > day_number THEN 1 ELSE 0 END -
			CASE WHEN DATEPART(weekday, @MonthEndDate)   < day_number THEN 1 ELSE 0 END) AS 'DaysCount'
	        
			INTO #tblWeekDay
			FROM Days_Of_The_Week
			
			--- Count Full Days and Half Days  as Per Week day START ---
			SELECT @FullDayCount = SUM(DaysCount) FROM #tblWeekDay WHERE day_name <>  'Sunday' AND day_name <> 'Saturday'
			SELECT @HalfDayCount =  SUM(DaysCount) FROM #tblWeekDay WHERE day_name <>  'Sunday' AND day_name = 'Saturday'
			--- Count Full Days and Half Days  as Per define in shift Master END ---
					
			
			
			--SELECT * FROM #tblWeekDay
	    
			
			DECLARE TIMESHEET_CURSOR CURSOR FOR SELECT data from dbo.Split(@Emp_ID,'#')      
			OPEN TIMESHEET_CURSOR    
			FETCH NEXT FROM TIMESHEET_CURSOR INTO @ID    
			WHILE @@fetch_status = 0    
				BEGIN    
					--SELECT  EIR.For_Date,@TotalHour = dbo.F_Return_Hours(SUM(dbo.F_Return_Sec((CASE WHEN DATENAME(dw, EIR.For_Date) = SM.Week_Day THEN SM.Half_Dur ELSE SM.Shift_Dur END)))),
					--@TotalSec = SUM(dbo.F_Return_Sec((CASE WHEN DATENAME(dw, EIR.For_Date) = SM.Week_Day THEN SM.Half_Dur ELSE SM.Shift_Dur END))),
					--@EmpFullName =(EM.Initial + ' ' + ISNULL(EM.Emp_First_Name,'')+' '+ISNULL(EM.Emp_Second_Name,'')+' '+ISNULL(EM.Emp_Last_Name,'')),
					--@ShiftName = SM.Shift_Name
					--FROM T0150_EMP_INOUT_RECORD EIR
					--INNER JOIN T0080_EMP_MASTER EM ON EIR.Emp_ID = EM.Emp_ID
					--INNER JOIN T0040_SHIFT_MASTER SM ON EM.Shift_ID = SM.Shift_ID 
					--WHERE EIR.Emp_ID = @ID AND MONTH(EIR.For_Date) = @Month AND YEAR(EIR.For_Date) = @Year
					--GROUP BY EM.Initial,EM.Emp_First_Name,EM.Emp_Second_Name,EM.Emp_Last_Name,SM.Shift_Name
					
					SET @Training = 0.00
					SET @AppraisalBonus = 0.00
					
					SELECT  @WeekoffDay = Weekoff_Day FROM V0100_WEEKOFF_ADJ WHERE Emp_ID = @ID
					
					SELECT @EmpFullName = VM.Emp_Full_Name_new,@EmpFullNameSup = VM.Emp_Full_Name_Superior,@ShiftName = SM.Shift_Name,
					@HalfWeekDay = SM.Week_Day,@FullDayHour = SM.Shift_Dur,@HalfDayHour = SM.Half_Dur
					FROM V0080_Employee_Master VM
					INNER JOIN T0040_SHIFT_MASTER SM WITH (NOLOCK) ON VM.Shift_ID = SM.Shift_ID
					WHERE VM.Emp_ID = @ID
					
					--- Count Full Days and Half Days  as Per define in shift Master START ---
					--SELECT @FullDayCount = SUM(DaysCount) FROM tblWeekDay WHERE day_name <>  @WeekoffDay AND day_name <> @HalfWeekDay
					--SELECT @HalfDayCount =  SUM(DaysCount) FROM tblWeekDay WHERE day_name <>  @WeekoffDay AND day_name = @HalfWeekDay
					--- Count Full Days and Half Days  as Per define in shift Master END ---
					
					--- Count Full Days and Half Days  as Per Week day START ---
					--SELECT @FullDayCount = SUM(DaysCount) FROM tblWeekDay WHERE day_name <>  @WeekoffDay AND day_name <> 'Saturday'
					--SELECT @HalfDayCount =  SUM(DaysCount) FROM tblWeekDay WHERE day_name <>  @WeekoffDay AND day_name = 'Saturday'
					--- Count Full Days and Half Days  as Per define in shift Master END ---
					
					SET @FullDayHour = '09:00'
					SET @HalfDayHour = '05:00'
					
					--SELECT @FullDayCount,@FullDayHour,@HalfDayCount,@HalfDayHour,@WeekoffDay,@HalfWeekDay
					
					--SELECT dbo.F_Return_Sec(@FullDayHour) * @FullDayCount,dbo.F_Return_Hours(dbo.F_Return_Sec(@FullDayHour) * @FullDayCount),(dbo.F_Return_Sec(@HalfDayHour) * @HalfDayCount),dbo.F_Return_Hours(dbo.F_Return_Sec(@HalfDayHour) * @HalfDayCount)
					
					SET @TotalHour = dbo.F_Return_Hours((dbo.F_Return_Sec(@FullDayHour) * @FullDayCount) + (dbo.F_Return_Sec(@HalfDayHour) * @HalfDayCount))
					
					--select @FullDayCount,@HalfDayCount,@FullDayHour,@HalfDayHour, @TotalHour
					
					--SELECT @TotalHour = dbo.F_Return_Hours(SUM(Att.TotalHour)),@TotalSec = SUM(Att.TotalSec),@EmpFullName = Att.EmpFullName,@ShiftName = Att.ShiftName 
					--FROM
					--(
					--	SELECT DISTINCT EIR.For_Date,(dbo.F_Return_Sec((CASE WHEN DATENAME(dw, EIR.For_Date) = SM.Week_Day THEN SM.Half_Dur ELSE SM.Shift_Dur END))) as 'TotalHour',
					--	dbo.F_Return_Sec((CASE WHEN DATENAME(dw, EIR.For_Date) = SM.Week_Day THEN SM.Half_Dur ELSE SM.Shift_Dur END)) as 'TotalSec',
					--	(EM.Initial + ' ' + ISNULL(EM.Emp_First_Name,'')+' '+ISNULL(EM.Emp_Second_Name,'')+' '+ISNULL(EM.Emp_Last_Name,'')) as 'EmpFullName',
					--	SM.Shift_Name as 'ShiftName'
					--	FROM T0150_EMP_INOUT_RECORD EIR
					--	INNER JOIN T0080_EMP_MASTER EM ON EIR.Emp_ID = EM.Emp_ID
					--	INNER JOIN T0040_SHIFT_MASTER SM ON EM.Shift_ID = SM.Shift_ID 
					--	WHERE EIR.Emp_ID = @ID AND MONTH(EIR.For_Date) = @Month  AND YEAR(EIR.For_Date) = @Year
					--) Att

					--GROUP BY Att.EmpFullName,Att.ShiftName
					
					
					SELECT @CaptureSec = SUM(dbo.F_Return_Sec(ISNULL(Total_Time,0))),
					@CaptureHour = dbo.F_Return_Hours(SUM(dbo.F_Return_Sec(ISNULL(Total_Time,0)))) 
					FROM T0100_TS_Application WITH (NOLOCK) 
					WHERE Timesheet_Type ='Daily' AND MONTH(Entry_Date) = @Month AND YEAR(Entry_Date) = @Year AND Employee_ID = @ID
					
					SELECT @Training = ISNULL(MAD.M_AD_Amount,0.00)--,MAD.Emp_ID,AD.AD_NAME,MAD.M_AD_Percentage,MAD.M_AD_Flag
					FROM T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK)
					INNER JOIN T0050_AD_MASTER AD WITH (NOLOCK) ON MAD.AD_ID = AD.AD_ID
					WHERE MAD.Emp_ID = @ID AND AD.AD_NAME = 'Training' AND MONTH(For_Date) = @Month AND YEAR(For_Date) = @Year
					
					SELECT @AppraisalBonus = ISNULL(MAD.M_AD_Amount,0.00) --,MAD.Emp_ID,AD.AD_NAME,MAD.M_AD_Percentage,MAD.M_AD_Flag
					FROM T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK)
					INNER JOIN T0050_AD_MASTER AD WITH (NOLOCK) ON MAD.AD_ID = AD.AD_ID
					WHERE MAD.Emp_ID = @ID AND AD.AD_NAME = 'Appraisal Bonus' AND MONTH(For_Date) = @Month AND YEAR(For_Date) = @Year
					
					SELECT @NetSalary=isnull(Net_Amount,0.00),@ActualGrossSalary=ISNULL(Gross_Salary,0.00) 
					FROM T0200_MONTHLY_SALARY WITH (NOLOCK) where Emp_ID = @ID and Month_St_Date = @MonthStartDate and Month_End_Date = @MonthEndDate
					
					
					--SELECT @ActualGrossSalary AS 'BEFORE',@ID,@EmpFullName,@Training,@AppraisalBonus
					--SELECT @ID,@Training,@AppraisalBonus
					SET @ActualGrossSalary = (@ActualGrossSalary - ISNULL(@Training,0.00)) - ISNULL(@AppraisalBonus,0.00)
					
					--SELECT @ActualGrossSalary AS 'AFTER',@ID,@EmpFullName
					--SELECT @NetSalary,@ActualGrossSalary
					
					SET @TotalSec = dbo.F_Return_Sec(@TotalHour)
							
					IF (@TotalSec < @CaptureSec)
						BEGIN
							SET @DiffHour = CONVERT(numeric (18,2),  REPLACE(dbo.F_Return_Hours(dbo.F_Return_Sec(@CaptureHour) -  dbo.F_Return_Sec(@TotalHour)),':','.') )
							SET @strDiffHour = '-' + CONVERT(varchar(20), @DiffHour)
							
							SET @DiffSec = @CaptureSec -  @TotalSec
						END
					ELSE
						BEGIN
							SET @DiffHour = CONVERT(numeric (18,2),  REPLACE(dbo.F_Return_Hours(dbo.F_Return_Sec(@TotalHour) -  dbo.F_Return_Sec(@CaptureHour)),':','.'))
							SET @strDiffHour = CONVERT(varchar(20), @DiffHour)
							SET @DiffSec = @TotalSec - @CaptureSec
						END
						
					SET @NTotalHour = CONVERT(numeric (18,2),  REPLACE (@TotalHour,':','.'))    
					
					SET @NCaptureHour  = CONVERT(numeric (18,2),  REPLACE (@CaptureHour,':','.')) 
					
					INSERT INTO #EmployeeData (Employee_Id,EmpFullname,EmpFullnameSup,ShiftName,NetSalary,CaptureSalary,DiffSalary,TotalHour,TotalSec,CaptureHour,CaptureSec,DiffHour,DiffSec,HourSalary,Cmp_ID,TsMonth,TsYear,strDiffHour)  
					VALUES(@ID,@EmpFullName,@EmpFullNameSup,@ShiftName,@ActualGrossSalary,@CaptureSalary,@DiffSalary,@TotalHour,@TotalSec,@CaptureHour,@CaptureSec,@DiffHour,@DiffSec,@HourSalary,@Cmp_ID,@Monthname,@Year,@strDiffHour )  
					FETCH NEXT FROM TIMESHEET_CURSOR INTO @ID   
																								
																																							 
					
					--SELECT * from #EmployeeData
				END
			CLOSE TIMESHEET_CURSOR              
			DEALLOCATE TIMESHEET_CURSOR  
			
			
		
			SELECT @strTotalHour = dbo.F_Return_Hours(sum(dbo.F_Return_Sec(Total_Time))) 
			FROM T0100_TS_Application WITH (NOLOCK) where MONTH(Entry_Date) = @Month AND YEAR(Entry_Date) = @Year
			UPDATE #EmployeeData SET strTotalHour = @strTotalHour
			
			--SELECT * from #EmployeeData
			
			
			
			SELECT TS.Employee_Id,EmpFullname,NetSalary,TotalSec,CaptureSec,strDiffHour,DiffSec,
			(CASE WHEN ShiftName = 'WORK FROM HOME' THEN '0.00' ELSE CaptureHour END) AS 'CaptureHour',
			(CASE WHEN ShiftName = 'WORK FROM HOME' THEN '0.00' ELSE strDiffHour END) AS 'DiffHour',
			(CASE WHEN ShiftName = 'WORK FROM HOME' THEN '0.00' ELSE TotalHour END) AS 'TotalHour',
			(dbo.F_Return_Hours(SUM(dbo.F_Return_Sec(Total_Time)))) as 'WorkingHour',SUM(dbo.F_Return_Sec(Total_Time)) as  'WorkingSec',
			CONVERT(numeric(18,2), (((SUM(dbo.F_Return_Sec(Total_Time))) / NULLIF(CaptureSec,0))*100 ))  as 'WorkingPercentage',
			CONVERT(numeric(18,2),((ED.NetSalary  * (CONVERT(numeric(18,2), (((SUM(dbo.F_Return_Sec(Total_Time))) / NULLIF(CaptureSec,0))*100 ))))/100)) AS 'CaptureSalary',
			CONVERT(numeric(18,2),((ED.DiffHour  * CONVERT(numeric(18,2), (((SUM(dbo.F_Return_Sec(Total_Time))) / NULLIF(CaptureSec,0))*100 ))) / 100)) AS 'AdditionalHour',
			TS.Cmp_ID,TsMonth,TsYear,TS.Project_ID,ShiftName,strTotalHour
			INTO #ProjectData 
			FROM T0100_TS_Application  TS WITH (NOLOCK)
			INNER JOIN  #EmployeeData ED ON TS.Employee_Id = ED.Employee_Id
			WHERE TS.Timesheet_Type ='Daily' and Entry_Date between @MonthStartDate and @MonthEndDate 
			GROUP BY TS.Employee_Id,TS.Project_ID ,EmpFullname,NetSalary,CaptureSalary,DiffSalary ,TotalHour,TotalSec,CaptureHour,CaptureSec,DiffHour,DiffSec,TS.Cmp_ID,TsMonth,TsYear ,HourSalary,ShiftName,strDiffHour,strTotalHour
			
			--SELECT * FROM #ProjectData
			
			SELECT PM.Project_ID, pd.Employee_Id,pd.EmpFullname,TEM.Emp_Full_Name AS 'ProjectManager', pd.NetSalary,pd.TotalSec,
			pd.CaptureSec,pd.strDiffHour,pd.DiffSec,CaptureHour,DiffHour,TotalHour,WorkingHour,WorkingSec,WorkingPercentage,
			CaptureSalary,AdditionalHour,dbo.F_Return_Sec(REPLACE(AdditionalHour,'.',':')) as 'AdditionalSec',PM.Project_Name,
			pd.TsMonth,pd.TsYear,WorkingPercentage AS 'SalaryPercentage',CaptureSalary AS 'AdditionalCost',Overhead_Calculation,
			CM.Cmp_Name ,CM.Cmp_Address,BM.Branch_Name,BM.Branch_Address,TCM.Cat_Name,TGM.Grd_Name,DM.Dept_Name,TDM.Desig_Name,
			strTotalHour,(WorkingSec + dbo.F_Return_Sec(REPLACE(AdditionalHour,'.',':')) ) AS 'OverheadSec',
			(dbo.F_Return_Hours(WorkingSec + dbo.F_Return_Sec(REPLACE(AdditionalHour,'.',':')))) AS 'OverheadHour'
			INTO #demo_tbl
			FROM #ProjectData pd 
			LEFT JOIN T0040_TS_Project_Master PM WITH (NOLOCK) ON pd.Project_ID  = PM.Project_ID
			LEFT JOIN T0050_TS_Project_Detail TPD WITH (NOLOCK) ON PM.Project_ID = TPD.Project_ID
			LEFT JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) ON pd.Cmp_ID = CM.Cmp_Id 
			LEFT JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON pd.Employee_Id = EM.Emp_ID
			LEFT JOIN T0080_EMP_MASTER TEM WITH (NOLOCK) ON TEM.Emp_ID = TPD.Assign_To
			LEFT JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON EM.Branch_ID = BM.Branch_ID
			LEFT JOIN T0030_CATEGORY_MASTER TCM WITH (NOLOCK) ON EM.Cat_ID = TCM.Cat_ID 
			LEFT JOIN T0040_GRADE_MASTER TGM WITH (NOLOCK) on EM.Grd_ID = TGM.Grd_ID 
			LEFT JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON EM.Dept_ID = DM.Dept_Id 
			LEFT JOIN T0040_DESIGNATION_MASTER TDM WITH (NOLOCK) ON EM.Desig_Id = TDM.Desig_ID 
			WHERE ISNULL(TEM.Emp_Full_Name,'') <> ''
			ORDER BY pd.Employee_Id 
			
		  
			--SELECT * FROM #demo_tbl
			SELECT Project_ID,Project_cost,OverHead_Month,OverHead_Year INTO #ProjectCost FROM T0040_OverHead_Master WITH (NOLOCK) WHERE OverHead_Month = @Monthname AND OverHead_Year = @Year
			
			--SELECT * FROM #ProjectCost
			
			SELECT DT.Project_ID ,Project_Name,WorkingPercentage,AdditionalSec,WorkingSec,strTotalHour,AdditionalHour,TotalHour,WorkingHour,CaptureSalary,
			(CASE WHEN Overhead_Calculation = 1 THEN Project_cost ELSE '0.00' END) AS 'Project_cost',OverheadSec,OverheadHour,
			TsMonth,TsYear,Cmp_Name,Cmp_Address,Branch_Name,Branch_Address,Cat_Name,Grd_Name,Dept_Name,Desig_Name
			,dbo.F_Return_Sec(WorkingHour) as 'CaptureSec',
			dbo.F_Return_Sec(REPLACE(DiffHour,'.',':')) AS 'DiffSec',Overhead_Calculation,ProjectManager --,0.00 AS 'Costperhour'
			INTO #OverHeadCost 
			FROM #demo_tbl DT 
			INNER JOIN #ProjectCost PC ON DT.TsMonth = PC.OverHead_Month AND TsYear = OverHead_Year
			
			--SELECT * FROM #OverHeadCost
		
			
			ALTER TABLE #OverHeadCost ADD Costperhour numeric(18,2)
			
			
			
			--SELECT SUM(CONVERT(NUMERIC(18,2), REPLACE(OverheadHour,':','.'))) FROM #OverHeadCost
			SELECT @OverheadCost = (Project_cost / SUM(CONVERT(NUMERIC(18,2), REPLACE(OverheadHour,':','.')))) FROM #OverHeadCost
			GROUP BY Project_cost
			
			--SELECT @OverheadCost
			--SELECT sum(overheadsec),SUM(CONVERT(NUMERIC(18,2), REPLACE(OverheadHour,':','.'))) FROM #OverHeadCost
			 
			UPDATE #OverHeadCost SET Costperhour = @OverheadCost WHERE Project_cost <> 0.00
			
			--SELECT Project_cost,Costperhour,* from #OverHeadCost
			--SELECT * FROM #OverHeadCost
			
			
			
			IF @report_type = ''
				BEGIN
					 select * from #demo_tbl WHERE ISNULL(ProjectManager,'') <> '' ORDER BY Employee_ID
				END
			ELSE 
				BEGIN
				
					SELECT Project_Name,ProjectManager,Project_ID,Project_cost,ISNULL(Costperhour,0.00) as 'Costperhour' ,
					--CONVERT(numeric(18,2),(SUM(CONVERT(NUMERIC(18,2), REPLACE(OverheadHour,':','.'))) * Costperhour )) as 'OverHead',
					(CONVERT(NUMERIC(18,2), REPLACE(dbo.F_Return_Hours(SUM(WorkingSec) + SUM(AdditionalSec)) ,':','.')) * ISNULL(Costperhour,0.00) ) as 'OverHead',
					--(CASE WHEN Overhead_Calculation = 1 THEN (CONVERT(NUMERIC(18,2), REPLACE(dbo.F_Return_Hours(SUM(WorkingSec) + SUM(AdditionalSec)) ,':','.')) * Costperhour ) ELSE '0.00' END ) as 'OverHead',
					CONVERT(numeric(18,2), (SUM(CaptureSalary)+(CONVERT(numeric(18,2), REPLACE(dbo.F_Return_Hours(SUM(WorkingSec) + SUM(AdditionalSec)),':','.')) * ISNULL(Costperhour,0.00))) ) AS 'TotalCost',
					--(CASE WHEN Overhead_Calculation = 1 THEN CONVERT(numeric(18,2), (SUM(CaptureSalary)+(CONVERT(numeric(18,2), REPLACE(dbo.F_Return_Hours(SUM(WorkingSec) + SUM(AdditionalSec)),':','.')) * Costperhour)) ) ELSE '0.00' END ) AS 'TotalCost',
					SUM(WorkingSec) as 'CaptureSec',SUM(AdditionalSec)as 'AdditionalSec',(SUM(WorkingSec) + SUM(AdditionalSec)) as 'TotalSec',
					dbo.F_Return_Hours(SUM(WorkingSec)) as 'CaptureHour',
					dbo.F_Return_Hours(SUM(AdditionalSec))as 'AdditionalHour',dbo.F_Return_Hours((SUM(WorkingSec) + SUM(AdditionalSec))) as 'TotalHour',
					SUM(DiffSec) as 'DiffSec',
					--max(Costperhour) as 'Costperhour',
					SUM(CaptureSalary) AS 'CaptureSalary',
					TsMonth,TsYear,Cmp_Name,Cmp_Address
					from #OverHeadCost
					WHERE ISNULL(ProjectManager,'') <> ''
					GROUP BY Project_ID,Project_Name,Project_cost,TsMonth,TsYear,Cmp_Name,Cmp_Address,Costperhour,Overhead_Calculation,ProjectManager--,OverheadHour
					ORDER BY Project_Name,Project_ID
				END
			DROP TABLE #ProjectCost
			DROP TABLE #demo_tbl
			DROP TABLE #OverHeadCost
			DROP TABLE #tblWeekDay
		END TRY
		BEGIN CATCH
			DROP TABLE #ProjectCost
			DROP TABLE #demo_tbl
			DROP TABLE #OverHeadCost
			DROP TABLE #tblWeekDay
		END CATCH
	END
	

