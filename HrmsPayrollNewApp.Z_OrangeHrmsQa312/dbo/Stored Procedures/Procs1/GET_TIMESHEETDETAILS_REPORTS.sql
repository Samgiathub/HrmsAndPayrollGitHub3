 ---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[GET_TIMESHEETDETAILS_REPORTS]
@Cmp_ID Numeric(18,0),
@Fromdate Datetime,
@Todate Datetime,
@Branch_ID numeric(18,0),
@Cat_ID numeric(18,0),
@Grd_ID	numeric(18,0),
@Type_ID numeric(18,0),
@Dept_ID numeric(18,0),
@Desig_ID numeric(18,0),
@Emp_ID varchar(MAX),
@Groupby varchar(50) = '',
@ReportFormat varchar(50) = '',
@ReportType varchar(50) = '',
@TimesheetStatus varchar(50) = ''
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

	If @ReportFormat = 'Default'
	Begin
			
			IF @Groupby = 'Employee'
				BEGIN
					SELECT Employee_ID,EmpName,Project_ID,Project_Name,Task_ID,Task_Name,Task_Code,
					dbo.F_Return_Hours(sum(Monday) + sum(Tuesday) + sum(Wednesday) + sum(Thursday) + sum(Friday) + sum(Saturday) + sum(Sunday)) AS 'Total Hour',
					(sum(Monday) + sum(Tuesday) + sum(Wednesday) + sum(Thursday) + sum(Friday) + sum(Saturday) + sum(Sunday)) AS 'Total Sec'
					FROM V0100_TS_ProjectDetails VTD
					INNER JOIN #Emp_Temp ET ON VTD.Employee_ID = ET.Emp_ID
					WHERE  Cmp_ID = @Cmp_ID AND CONVERT(datetime,FromDate,103) >= CONVERT(datetime,@Fromdate,103) AND CONVERT(datetime,TODate,103) <= CONVERT(datetime,@Todate,103)
					GROUP BY Employee_ID,EmpName,Project_ID,Project_Name,Task_ID,Task_Name,Task_Code
					ORDER BY EmpName
				END
			ELSE IF @Groupby = 'Project'
				BEGIN
					
					SELECT Employee_ID,EmpName,Project_ID,Project_Name,Task_ID,Task_Name,Task_Code,
					dbo.F_Return_Hours(sum(Monday) + sum(Tuesday) + sum(Wednesday) + sum(Thursday) + sum(Friday) + sum(Saturday) + sum(Sunday)) AS 'Total Hour',
					(sum(Monday) + sum(Tuesday) + sum(Wednesday) + sum(Thursday) + sum(Friday) + sum(Saturday) + sum(Sunday)) AS 'Total Sec'
					FROM V0100_TS_ProjectDetails VTD
					INNER JOIN #Emp_Temp ET ON VTD.Employee_ID = ET.Emp_ID
					WHERE  Cmp_ID = @Cmp_ID AND CONVERT(datetime,FromDate,103) >= CONVERT(datetime,@Fromdate,103) AND CONVERT(datetime,TODate,103) <= CONVERT(datetime,@Todate,103)
					GROUP BY Project_ID,Project_Name,Task_ID,Task_Name,Employee_ID,EmpName,Task_Code
					ORDER BY EmpName
				END
			ELSE
				BEGIN
					SELECT Employee_ID,EmpName,Project_ID,Project_Name,Task_ID,Task_Name,Task_Code,VTD.DEPT_ID,TDM.Dept_Name,TCM.Cmp_Name,TCM.Cmp_Address,
					dbo.F_Return_Hours(sum(Monday) + sum(Tuesday) + sum(Wednesday) + sum(Thursday) + sum(Friday) + sum(Saturday) + sum(Sunday)) AS 'Total Hour',
					(sum(Monday) + sum(Tuesday) + sum(Wednesday) + sum(Thursday) + sum(Friday) + sum(Saturday) + sum(Sunday)) AS 'Total Sec'
					FROM V0100_TS_ProjectDetails VTD
					INNER JOIN #Emp_Temp ET ON VTD.Employee_ID = ET.Emp_ID
					INNER JOIN T0040_DEPARTMENT_MASTER TDM WITH (NOLOCK) ON VTD.DEPT_ID = TDM.Dept_Id
					INNER JOIN T0010_COMPANY_MASTER TCM WITH (NOLOCK) ON VTD.Cmp_ID = TCM.Cmp_Id
					WHERE  VTD.Cmp_ID = @Cmp_ID AND  convert(datetime,FromDate,103) >= @Fromdate AND CONVERT(datetime,TODate,103) <= @Todate
					GROUP BY VTD.DEPT_ID,TDM.Dept_Name,Project_ID,Project_Name,Task_ID,Task_Name,Employee_ID,EmpName,Task_Code,TCM.Cmp_Name,TCM.Cmp_Address
					ORDER BY EmpName
				END
	End

	--Added by Mr.Mehul on 14-12-2022
	If @ReportFormat = 'Summary'
	Begin
			--DECLARE @StartDate DATE = @Fromdate 
			--DECLARE @EndDate DATE = @Todate 
			--;WITH Cal(n) AS
			--(SELECT 0 UNION ALL SELECT n + 1 FROM Cal WHERE n < DATEDIFF(DAY, @StartDate, @EndDate)),
			--FnlDt(d) AS (SELECT DATEADD(DAY, n, @StartDate) FROM Cal),FinalCte AS
			--(SELECT [Date] = CONVERT(DATE,d),[DayName] =  DATENAME(WEEKDAY, d) FROM FnlDt)
			
			--Select * Into #temp from 
			--(SELECT CAST([DayName] AS VARCHAR(50)) + ' ' + cast([Date] AS VARCHAR(50)) as DATEDay ,
			--[date],[dAYNAME] FROM finalCte) as Tr
		
		
		If @TimesheetStatus = 'P'
		Begin 
			Select TE.Alpha_Emp_Code as 'Employee Code',TE.Emp_Full_Name as 'Employee Name'
			,(Select Emp_Full_Name from T0080_EMP_MASTER where Emp_ID=TE.Emp_Superior and cmp_id=@Cmp_ID) as 'Reporting Manager'
			,Client_Name as 'Client Name',Project_Code as 'Project Code',GT.Project_Name as 'Project Name',DPM.Dept_Name as 'Department Name',
			GT.Monday,Monday_Des as 'Mondays Description',GT.Tuesday,Tuesday_Des as 'Tuesdays Description',GT.Wednesday,Wednesday_Des as 'Wednesdays Description',
			GT.Thursday,Thursday_Des as 'Thursdays Description',GT.Friday,Friday_Des as 'Fridays Description',GT.Saturday,Saturday_Des as 'Saturdays Description',GT.Sunday,Sunday_Des as 'Sundays Description',
			
			dbo.F_Return_Hours(sum(VTD.Monday) + sum(VTD.Tuesday) + sum(VTD.Wednesday) + sum(VTD.Thursday) + sum(VTD.Friday) + sum(VTD.Saturday) + sum(VTD.Sunday)) AS 'Total Hour',
			format(convert(date,substring(GT.Timesheet_Period,0,11),103),'dd-MM-yyyy')  as 'From Date',
			format(convert(date,substring(GT.Timesheet_Period,14,24),103),'dd-MM-yyyy') as 'To date' ,PS.Project_Status as 'Status'
			--,tp.DATEDay
			from Get_Timesheet_Details GT
			inner join T0100_TS_Application TA on TA.Timesheet_ID = GT.Timesheet_ID
			INNER JOIN #Emp_Temp ET ON TA.Employee_ID = ET.Emp_ID
			inner join T0080_EMP_MASTER TE on TE.Emp_ID = TA.Employee_ID
			LEFT OUTER JOIN
				(
					SELECT	EMP_ID,I.CMP_ID,I.BRANCH_ID,I.DEPT_ID,I.DESIG_ID,I.GROSS_SALARY
									FROM	T0095_INCREMENT I WITH (NOLOCK)
									WHERE	I.INCREMENT_ID =(
																SELECT	TOP 1 INCREMENT_ID
																FROM	T0095_INCREMENT I1 WITH (NOLOCK)
																WHERE	I1.EMP_ID=I.EMP_ID AND I1.CMP_ID=I.CMP_ID
																ORDER BY	INCREMENT_EFFECTIVE_DATE DESC, INCREMENT_ID DESC
															)
			) AS B ON B.EMP_ID = ET.EMP_ID AND B.CMP_ID=TE.CMP_ID
			LEFT JOIN T0040_Project_Status PS WITH (NOLOCK) ON TA.Project_Status_ID = PS.Project_Status_ID 
			LEFT JOIN T0040_DEPARTMENT_MASTER DPM WITH (NOLOCK) ON DPM.Dept_Id = b.Dept_ID
			--inner join #temp tp on tp.Date = convert(date,substring(GT.Timesheet_Period,14,24),103)
			LEft Join V0100_TS_ProjectDetails_Timesheet_Summary VTD on VTD.Timesheet_Detail_ID =  GT.Timesheet_Detail_ID
			where GT.cmp_id = @Cmp_ID and 
			--convert(date,substring(GT.Timesheet_Period,0,11),103) >= convert(date,@Fromdate ,103) 
			--and convert(date,substring(GT.Timesheet_Period,14,24),103) <= convert(date,@Todate ,103)
			(convert(date,substring(GT.Timesheet_Period,0,11),103) >= convert(date,@Fromdate ,103) and 
			convert(date,substring(GT.Timesheet_Period,0,11),103) <= convert(date,@Todate ,103) or
			convert(date,substring(GT.Timesheet_Period,14,24),103) <= convert(date,@Todate ,103) and 
			convert(date,substring(GT.Timesheet_Period,0,11),103) >= convert(date,@Todate ,103)) 
			and PS.Project_Status = 'Submitted'

			GROUP BY TE.Alpha_Emp_Code ,TE.Emp_Full_Name 
			,Client_Name ,Project_Code ,GT.Project_Name ,DPM.Dept_Name ,
			GT.Monday,GT.Tuesday,GT.Wednesday,GT.Thursday,GT.Friday,GT.Saturday,GT.Sunday,PS.Project_Status,TE.Emp_Superior, 
			GT.Monday_Des,GT.Tuesday_Des,GT.Wednesday_Des,GT.Thursday_Des,GT.Friday_Des,GT.Saturday_Des,GT.Sunday_Des,GT.Timesheet_Period

		End

		If @TimesheetStatus = 'A'
		Begin 
		
			Select TE.Alpha_Emp_Code as 'Employee Code',TE.Emp_Full_Name as 'Employee Name'
			,(Select Emp_Full_Name from T0080_EMP_MASTER where Emp_ID=TE.Emp_Superior and cmp_id=@Cmp_ID) as 'Reporting Manager'
			,Client_Name as 'Client Name',Project_Code as 'Project Code',GT.Project_Name as 'Project Name',DPM.Dept_Name as 'Department Name',
			GT.Monday,Monday_Des as 'Mondays Description',GT.Tuesday,Tuesday_Des as 'Tuesdays Description',GT.Wednesday,Wednesday_Des as 'Wednesdays Description',
			GT.Thursday,Thursday_Des as 'Thursdays Description',GT.Friday,Friday_Des as 'Fridays Description',GT.Saturday,Saturday_Des as 'Saturdays Description',GT.Sunday,Sunday_Des as 'Sundays Description',
			dbo.F_Return_Hours(sum(VTD.Monday) + sum(VTD.Tuesday) + sum(VTD.Wednesday) + sum(VTD.Thursday) + sum(VTD.Friday) + sum(VTD.Saturday) + sum(VTD.Sunday)) AS 'Total Hour',
			format(convert(date,substring(GT.Timesheet_Period,0,11),103),'dd-MM-yyyy')  as 'From Date',
			format(convert(date,substring(GT.Timesheet_Period,14,24),103),'dd-MM-yyyy') as 'To date' ,Ps.Project_Status as 'Status'
			--,tp.DATEDay
			from Get_Timesheet_Details GT
			inner join T0100_TS_Application TA on TA.Timesheet_ID = GT.Timesheet_ID
			INNER JOIN #Emp_Temp ET ON TA.Employee_ID = ET.Emp_ID
			LEFT JOIN T0040_Project_Status PS WITH (NOLOCK) ON TA.Project_Status_ID = PS.Project_Status_ID 
			--inner join #temp tp on tp.Date = convert(date,substring(GT.Timesheet_Period,14,24),103)
			inner join T0080_EMP_MASTER TE on TE.Emp_ID = TA.Employee_ID
			LEFT OUTER JOIN
				(
					SELECT	EMP_ID,I.CMP_ID,I.BRANCH_ID,I.DEPT_ID,I.DESIG_ID,I.GROSS_SALARY
									FROM	T0095_INCREMENT I WITH (NOLOCK)
									WHERE	I.INCREMENT_ID =(
																SELECT	TOP 1 INCREMENT_ID
																FROM	T0095_INCREMENT I1 WITH (NOLOCK)
																WHERE	I1.EMP_ID=I.EMP_ID AND I1.CMP_ID=I.CMP_ID
																ORDER BY	INCREMENT_EFFECTIVE_DATE DESC, INCREMENT_ID DESC
															)
			) AS B ON B.EMP_ID = ET.EMP_ID AND B.CMP_ID=TE.CMP_ID
			LEFT JOIN T0040_DEPARTMENT_MASTER DPM WITH (NOLOCK) ON DPM.Dept_Id = b.Dept_ID
			LEft Join V0100_TS_ProjectDetails_Timesheet_Summary VTD on VTD.Timesheet_Detail_ID =  GT.Timesheet_Detail_ID
			where GT.cmp_id = @Cmp_ID and 
			--convert(date,substring(GT.Timesheet_Period,0,11),103) >= convert(date,@Fromdate ,103) 
			--and convert(date,substring(GT.Timesheet_Period,14,24),103) <= convert(date,@Todate ,103)
			(convert(date,substring(GT.Timesheet_Period,0,11),103) >= convert(date,@Fromdate ,103) and 
			convert(date,substring(GT.Timesheet_Period,0,11),103) <= convert(date,@Todate ,103) or
			convert(date,substring(GT.Timesheet_Period,14,24),103) <= convert(date,@Todate ,103) and 
			convert(date,substring(GT.Timesheet_Period,0,11),103) >= convert(date,@Todate ,103)) 
			and PS.Project_Status = 'Approve'

			GROUP BY TE.Alpha_Emp_Code ,TE.Emp_Full_Name 
			,Client_Name ,Project_Code ,GT.Project_Name ,DPM.Dept_Name ,
			GT.Monday,GT.Tuesday,GT.Wednesday,GT.Thursday,GT.Friday,GT.Saturday,GT.Sunday,PS.Project_Status,TE.Emp_Superior, 
			GT.Monday_Des,GT.Tuesday_Des,GT.Wednesday_Des,GT.Thursday_Des,GT.Friday_Des,GT.Saturday_Des,GT.Sunday_Des,GT.Timesheet_Period

		End		

		If @TimesheetStatus = 'R'
		Begin 
			
			Select TE.Alpha_Emp_Code as 'Employee Code',TE.Emp_Full_Name as 'Employee Name'
			,(Select Emp_Full_Name from T0080_EMP_MASTER where Emp_ID=TE.Emp_Superior and cmp_id=@Cmp_ID) as 'Reporting Manager'
			,Client_Name as 'Client Name',Project_Code as 'Project Code',GT.Project_Name as 'Project Name',DPM.Dept_Name as 'Department Name',
			GT.Monday,Monday_Des as 'Mondays Description',GT.Tuesday,Tuesday_Des as 'Tuesdays Description',GT.Wednesday,Wednesday_Des as 'Wednesdays Description',
			GT.Thursday,Thursday_Des as 'Thursdays Description',GT.Friday,Friday_Des as 'Fridays Description',GT.Saturday,Saturday_Des as 'Saturdays Description',GT.Sunday,Sunday_Des as 'Sundays Description',
			dbo.F_Return_Hours(sum(VTD.Monday) + sum(VTD.Tuesday) + sum(VTD.Wednesday) + sum(VTD.Thursday) + sum(VTD.Friday) + sum(VTD.Saturday) + sum(VTD.Sunday)) AS 'Total Hour',
			format(convert(date,substring(GT.Timesheet_Period,0,11),103),'dd-MM-yyyy')  as 'From Date',
			format(convert(date,substring(GT.Timesheet_Period,14,24),103),'dd-MM-yyyy') as 'To date' ,Ps.Project_Status as 'Status'
			from Get_Timesheet_Details GT
			inner join T0100_TS_Application TA on TA.Timesheet_ID = GT.Timesheet_ID
			INNER JOIN #Emp_Temp ET ON TA.Employee_ID = ET.Emp_ID
			LEFT JOIN T0040_Project_Status PS WITH (NOLOCK) ON TA.Project_Status_ID = PS.Project_Status_ID 
			--inner join #temp tp on tp.Date = convert(date,substring(GT.Timesheet_Period,14,24),103)
			inner join T0080_EMP_MASTER TE on TE.Emp_ID = TA.Employee_ID
			LEFT OUTER JOIN
				(
					SELECT	EMP_ID,I.CMP_ID,I.BRANCH_ID,I.DEPT_ID,I.DESIG_ID,I.GROSS_SALARY
									FROM	T0095_INCREMENT I WITH (NOLOCK)
									WHERE	I.INCREMENT_ID =(
																SELECT	TOP 1 INCREMENT_ID
																FROM	T0095_INCREMENT I1 WITH (NOLOCK)
																WHERE	I1.EMP_ID=I.EMP_ID AND I1.CMP_ID=I.CMP_ID
																ORDER BY	INCREMENT_EFFECTIVE_DATE DESC, INCREMENT_ID DESC
															)
			) AS B ON B.EMP_ID = ET.EMP_ID AND B.CMP_ID=TE.CMP_ID
			LEFT JOIN T0040_DEPARTMENT_MASTER DPM WITH (NOLOCK) ON DPM.Dept_Id = b.Dept_ID
			LEft Join V0100_TS_ProjectDetails_Timesheet_Summary VTD on VTD.Timesheet_Detail_ID =  GT.Timesheet_Detail_ID
			where GT.cmp_id = @Cmp_ID and 
			--convert(date,substring(GT.Timesheet_Period,0,11),103) >= convert(date,@Fromdate ,103) 
			--and convert(date,substring(GT.Timesheet_Period,14,24),103) <= convert(date,@Todate ,103)
			(convert(date,substring(GT.Timesheet_Period,0,11),103) >= convert(date,@Fromdate ,103) and 
			convert(date,substring(GT.Timesheet_Period,0,11),103) <= convert(date,@Todate ,103) or
			convert(date,substring(GT.Timesheet_Period,14,24),103) <= convert(date,@Todate ,103) and 
			convert(date,substring(GT.Timesheet_Period,0,11),103) >= convert(date,@Todate ,103)) 
			and PS.Project_Status = 'Rejected'

			GROUP BY TE.Alpha_Emp_Code ,TE.Emp_Full_Name 
			,Client_Name ,Project_Code ,GT.Project_Name ,DPM.Dept_Name ,
			GT.Monday,GT.Tuesday,GT.Wednesday,GT.Thursday,GT.Friday,GT.Saturday,GT.Sunday,PS.Project_Status,TE.Emp_Superior, 
			GT.Monday_Des,GT.Tuesday_Des,GT.Wednesday_Des,GT.Thursday_Des,GT.Friday_Des,GT.Saturday_Des,GT.Sunday_Des,GT.Timesheet_Period

		End		
		--Commented by Deepali - old code -28032024- for ahana -start
		If @TimesheetStatus = 'F'
		Begin 
		print 'old Export format'
	
			--select * from Get_Timesheet_Details where Project_Code in ('NAHAIIM4:NGINDOH','SDATIIM1:SSINEUH','EKOTOOT2:SSARCIC','SSHEIIM1:PSAWSCL')
			--select * from T0040_Client_Master where Client_ID in (166)
			--select * from T0110_TS_Application_Detail where Client_ID in (166)
			
			Select GT.Timesheet_Detail_ID,TE.Alpha_Emp_Code as 'Employee Code',TE.Emp_Full_Name as 'Employee Name'
			,(Select Emp_Full_Name from T0080_EMP_MASTER where Emp_ID=TE.Emp_Superior and cmp_id=@Cmp_ID) as 'Reporting Manager'
			,Client_Name as 'Client Name',Project_Code as 'Project Code',GT.Project_Name as 'Project Name',DPM.Dept_Name as 'Department Name',
			GT.Monday,Monday_Des as 'Mondays Description',GT.Tuesday,Tuesday_Des as 'Tuesdays Description',GT.Wednesday,Wednesday_Des as 'Wednesdays Description',
			GT.Thursday,Thursday_Des as 'Thursdays Description',GT.Friday,Friday_Des as 'Fridays Description',GT.Saturday,Saturday_Des as 'Saturdays Description',GT.Sunday,Sunday_Des as 'Sundays Description',
			dbo.F_Return_Hours(sum(VTD.Monday) + sum(VTD.Tuesday) + sum(VTD.Wednesday) + sum(VTD.Thursday) + sum(VTD.Friday) + sum(VTD.Saturday) + sum(VTD.Sunday)) AS 'Total Hour',
			
			format(convert(date,substring(GT.Timesheet_Period,0,11),103),'dd-MM-yyyy')  as 'From Date',
			format(convert(date,substring(GT.Timesheet_Period,14,24),103),'dd-MM-yyyy') as 'To date' ,
			Ps.Project_Status as 'Status'			

			from Get_Timesheet_Details GT
			inner join T0100_TS_Application TA on TA.Timesheet_ID = GT.Timesheet_ID
			INNER JOIN #Emp_Temp ET ON TA.Employee_ID = ET.Emp_ID
			LEFT JOIN T0040_Project_Status PS WITH (NOLOCK) ON TA.Project_Status_ID = PS.Project_Status_ID 
			
			--inner join #temp tp on tp.Date = convert(date,substring(GT.Timesheet_Period,14,24),103)
			--inner join T0040_TS_Project_Master TSPM on TSPM.Project_ID = GT.Project_ID
			inner join T0080_EMP_MASTER TE on TE.Emp_ID = TA.Employee_ID
			--left join T0040_DEPARTMENT_MASTER DM on dm.Dept_Id=TE.Dept_ID
			
			LEFT OUTER JOIN
				(
					SELECT	EMP_ID,I.CMP_ID,I.BRANCH_ID,I.DEPT_ID,I.DESIG_ID,I.GROSS_SALARY
									FROM	T0095_INCREMENT I WITH (NOLOCK)
									WHERE	I.INCREMENT_ID =(
																SELECT	TOP 1 INCREMENT_ID
																FROM	T0095_INCREMENT I1 WITH (NOLOCK)
																WHERE	I1.EMP_ID=I.EMP_ID AND I1.CMP_ID=I.CMP_ID
																ORDER BY	INCREMENT_EFFECTIVE_DATE DESC, INCREMENT_ID DESC
															)
			) AS B ON B.EMP_ID = ET.EMP_ID AND B.CMP_ID=TE.CMP_ID
			LEFT JOIN T0040_DEPARTMENT_MASTER DPM WITH (NOLOCK) ON DPM.Dept_Id = b.Dept_ID
			LEft Join V0100_TS_ProjectDetails_Timesheet_Summary VTD on VTD.Timesheet_Detail_ID =  GT.Timesheet_Detail_ID
			where GT.cmp_id = @Cmp_ID and 
			--New code -

			 convert(date,@Fromdate ,103)  between  convert(date,substring(GT.Timesheet_Period,0,11),103)  and convert(date,substring(GT.Timesheet_Period,14,24),103)
			 or 
			 convert(date,@Todate ,103)  between  convert(date,substring(GT.Timesheet_Period,0,11),103)  and convert(date,substring(GT.Timesheet_Period,14,24),103)
			 or
			(convert(date,substring(GT.Timesheet_Period,0,11),103) >= convert(date,@Fromdate ,103) 
			and convert(date,substring(GT.Timesheet_Period,14,24),103) <= convert(date,@Todate ,103)
			or convert(date,substring(GT.Timesheet_Period,14,24),103) >= convert(date,@Fromdate ,103)
			and 
			convert(date,substring(GT.Timesheet_Period,0,11),103) <= convert(date,@Todate ,103)) 


			--old code commented-Deepali -20032023 
			--(convert(date,substring(GT.Timesheet_Period,0,11),103) >= convert(date,@Fromdate ,103) and 
			--convert(date,substring(GT.Timesheet_Period,0,11),103) <= convert(date,@Todate ,103) or
			--convert(date,substring(GT.Timesheet_Period,14,24),103) <= convert(date,@Todate ,103) and 
			--convert(date,substring(GT.Timesheet_Period,0,11),103) >= convert(date,@Todate ,103)) 
			--old code commented-Deepali -20032023 
			--New code --
			-- TA.Entry_Date BETWEEN CONVERT(date, @FromDate, 103) AND CONVERT(date, @Todate, 103)

			
			GROUP BY GT.Timesheet_Detail_ID,TE.Alpha_Emp_Code ,TE.Emp_Full_Name 
			,Client_Name ,Project_Code ,GT.Project_Name ,DPM.Dept_Name ,
			GT.Monday,GT.Tuesday,GT.Wednesday,GT.Thursday,GT.Friday,GT.Saturday,GT.Sunday,PS.Project_Status,TE.Emp_Superior, 
			GT.Monday_Des,GT.Tuesday_Des,GT.Wednesday_Des,GT.Thursday_Des,GT.Friday_Des,GT.Saturday_Des,GT.Sunday_Des,
			GT.Timesheet_Period

			order by  format(convert(date,substring(GT.Timesheet_Period,0,11),103),'dd-MM-yyyy') desc

		End		
	--Commented by Deepali - old code -28032024- for ahana -end 
	--============================================================================================================
--added by Deepali - Testing Timesheet-27032024  for ahana -Start   
		
If @TimesheetStatus = 'E'
Begin 			
		-------------------------
IF OBJECT_ID('Temp_Week_Date_Timesheet', 'U') IS NOT NULL
    DROP TABLE Temp_Week_Date_Timesheet;

	
IF OBJECT_ID('Temp_Weekly_Timesheet', 'U') IS NOT NULL
    DROP TABLE Temp_Weekly_Timesheet;

SELECT 
	@Fromdate as from_date ,
	@Todate as To_date ,
	CONVERT(date, SUBSTRING(TA.Timesheet_Period, 0, 11), 103) AS 'WeekStart_date',
	 CONVERT(date, SUBSTRING(TA.Timesheet_Period, 14, 24), 103) AS 'WeekEnd_date'  ,
    CONVERT(date, SUBSTRING(TA.Timesheet_Period, 0, 11), 103) AS 'Monday_date',
    DATEADD(day, 1, CONVERT(date, SUBSTRING(TA.Timesheet_Period, 0, 11), 103)) AS 'tuesday_date',
    DATEADD(day, 2, CONVERT(date, SUBSTRING(TA.Timesheet_Period, 0, 11), 103)) AS 'wednesday_date',
    DATEADD(day, 3, CONVERT(date, SUBSTRING(TA.Timesheet_Period, 0, 11), 103)) AS 'thursday_date',
    DATEADD(day, 4, CONVERT(date, SUBSTRING(TA.Timesheet_Period, 0, 11), 103)) AS 'friday_date',
    DATEADD(day, 5, CONVERT(date, SUBSTRING(TA.Timesheet_Period, 0, 11), 103)) AS 'saturday_date',
    DATEADD(day, 6, CONVERT(date, SUBSTRING(TA.Timesheet_Period, 0, 11), 103)) AS 'sunday_date',   

	TA.Timesheet_ID,TAD.Timesheet_Detail_ID,TA.Cmp_ID,TA.Employee_ID,TA.Timesheet_Period,
	TAD.Mon, TAD.Tue, TAD.Wed,TAD.Thu, TAD.Fri, TAD.Sat, TAD.Sun,PS.Project_Status_ID

	into Temp_Week_Date_Timesheet
	
FROM
    T0100_TS_Application TA
INNER JOIN 
    T0110_TS_Application_Detail TAD ON TA.Timesheet_ID = TAD.Timesheet_ID
		INNER JOIN #Emp_Temp ET ON TA.Employee_ID = ET.Emp_ID
		LEFT JOIN T0040_Project_Status PS WITH (NOLOCK) ON TA.Project_Status_ID = PS.Project_Status_ID 	
WHERE 
   
			 convert(date,@Fromdate ,103)  between  convert(date,substring(TA.Timesheet_Period,0,11),103)  and convert(date,substring(TA.Timesheet_Period,14,24),103)
			 or 
			 convert(date,@Todate ,103)  between  convert(date,substring(TA.Timesheet_Period,0,11),103)  and convert(date,substring(TA.Timesheet_Period,14,24),103)
			 or
			(convert(date,substring(TA.Timesheet_Period,0,11),103) >= convert(date,@Fromdate ,103) 
			and convert(date,substring(TA.Timesheet_Period,14,24),103) <= convert(date,@Todate ,103)
			or convert(date,substring(TA.Timesheet_Period,14,24),103) >= convert(date,@Fromdate ,103)
			and 
			convert(date,substring(TA.Timesheet_Period,0,11),103) <=convert(date,@Todate ,103)) 

	--drop table Temp_Week_Date_Timesheet

	print '11111'
	SELECT 
    TWD.*,GT.Monday_Des,GT.Tuesday_Des,GT.Wednesday_Des,GT.Thursday_Des,GT.Friday_Des,GT.Saturday_Des,GT.Sunday_Des,
    CASE WHEN Monday_date < from_date  or Monday_date > To_date THEN '0' ELSE isnull((LEFT(Mon,CHARINDEX('#',Mon )-1)),0) END AS Monday,
	 CASE WHEN tuesday_date < from_date or tuesday_date > To_date  THEN '0' ELSE isnull((LEFT(Tue,CHARINDEX('#',Tue )-1)),0) END AS Tuesday,
	  CASE WHEN wednesday_date < from_date or wednesday_date > To_date  THEN '0' ELSE isnull((LEFT(Wed,CHARINDEX('#',Wed )-1)),0) END AS Wednesday,
	   CASE WHEN thursday_date < from_date or thursday_date > To_date  THEN '0' ELSE isnull((LEFT(Thu,CHARINDEX('#',Thu )-1)),0) END AS Thursday,
	    CASE WHEN friday_date < from_date or friday_date > To_date  THEN '0' ELSE isnull((LEFT(Fri,CHARINDEX('#',Fri )-1)),0) END AS Friday,
		  CASE WHEN saturday_date < from_date or saturday_date > To_date  THEN '0' ELSE isnull((LEFT(Sat,CHARINDEX('#',Sat )-1)),0) END AS Saturday,
		CASE WHEN sunday_date < from_date or sunday_date > To_date  THEN '0' ELSE isnull((LEFT(Sun,CHARINDEX('#',Sun )-1)),0) END AS Sunday,
		---------------
		 CASE WHEN Monday_date < from_date  or Monday_date > To_date THEN '-' ELSE Monday_Des END AS Monday_Desc,
	 CASE WHEN tuesday_date < from_date or tuesday_date > To_date  THEN '-' ELSE Tuesday_Des END AS Tuesday_Desc,
	  CASE WHEN wednesday_date < from_date or wednesday_date > To_date  THEN '-' ELSE Wednesday_Des END AS Wednesday_Desc,
	   CASE WHEN thursday_date < from_date or thursday_date > To_date  THEN '-' ELSE Thursday_Des END AS Thursday_Desc,
	    CASE WHEN friday_date < from_date or friday_date > To_date  THEN '-' ELSE Friday_Des END AS Friday_Desc,
		  CASE WHEN saturday_date < from_date or saturday_date > To_date  THEN '-' ELSE Saturday_Des END AS Saturday_Desc,
		CASE WHEN sunday_date < from_date or sunday_date > To_date  THEN '-' ELSE Sunday_Des END AS Sunday_Desc,

		---------------

		CASE WHEN   WeekStart_date < from_date  THEN from_date ELSE WeekStart_date END AS WeekStart,
		CASE WHEN   WeekEnd_date > To_date  THEN To_date ELSE WeekEnd_date END AS WeekEnd

		Into Temp_Weekly_Timesheet	
		FROM   Temp_Week_Date_Timesheet TWD inner join  Get_Timesheet_Details GT  on TWD.Timesheet_ID = GT.Timesheet_ID  and TWD.Timesheet_Detail_ID= GT.Timesheet_Detail_ID
	print '22222'
	--	-------------------------
			
			Select GT.Timesheet_Detail_ID,TE.Alpha_Emp_Code as 'Employee Code',TE.Emp_Full_Name as 'Employee Name'
			,(Select Emp_Full_Name from T0080_EMP_MASTER where Emp_ID=TE.Emp_Superior and cmp_id=@Cmp_ID) as 'Reporting Manager'
			,Client_Name as 'Client Name',Project_Code as 'Project Code',GT.Project_Name as 'Project Name',DPM.Dept_Name as 'Department Name',
			TWD.Monday,TWD.Monday_Desc as 'Mondays Description',
			TWD.Tuesday,TWD.Tuesday_Desc as 'Tuesdays Description',
			TWD.Wednesday,TWD.Wednesday_Desc as 'Wednesdays Description',
			TWD.Thursday,TWD.Thursday_Desc as 'Thursdays Description',
			TWD.Friday,TWD.Friday_Desc as 'Fridays Description',
			TWD.Saturday,TWD.Saturday_Desc as 'Saturdays Description',
			TWD.Sunday,TWD.Sunday_Desc as 'Sundays Description',		
			--dbo.F_Return_Hours_Timesheet((dbo.F_Return_Sec(sum(TWD.monday)) + dbo.F_Return_Sec(sum(TWD.Tuesday)) + dbo.F_Return_Sec(sum(TWD.wednesday)) +  
   --         dbo.F_Return_Sec(sum(TWD.Thursday)) + dbo.F_Return_Sec(sum(TWD.friday)) + dbo.F_Return_Sec(sum(TWD.saturday)) + dbo.F_Return_Sec(sum(TWD.sunday)))
			-- ) AS 'Total Hours',	
			 
			 		dbo.F_Return_Hours_Timesheet((dbo.F_Return_Sec(TWD.monday) + dbo.F_Return_Sec(TWD.Tuesday) + dbo.F_Return_Sec(TWD.wednesday) +  
            dbo.F_Return_Sec(TWD.Thursday) + dbo.F_Return_Sec(TWD.friday) + dbo.F_Return_Sec(TWD.saturday) + dbo.F_Return_Sec(TWD.sunday))
			 ) AS 'Total Hours',	
			CONVERT(varchar, CONVERT(date, TWD.WeekStart), 103) as 'From Date',
			CONVERT(varchar, CONVERT(date, TWD.WeekEnd), 103) as 'To date' ,
	
			 Ps.Project_Status as 'Status'
			from Get_Timesheet_Details GT
			inner join T0100_TS_Application TA on TA.Timesheet_ID = GT.Timesheet_ID
			inner join Temp_Weekly_Timesheet TWD on TA.Timesheet_ID = TWD.Timesheet_ID and TWD.Employee_ID = TA.Employee_ID 
			and TWD.Timesheet_Detail_ID= GT.Timesheet_Detail_ID
			INNER JOIN #Emp_Temp ET ON TA.Employee_ID = ET.Emp_ID
			LEFT JOIN T0040_Project_Status PS WITH (NOLOCK) ON TA.Project_Status_ID = PS.Project_Status_ID 			
			inner join T0080_EMP_MASTER TE on TE.Emp_ID = TWD.Employee_ID
			LEFT OUTER JOIN
				(
					SELECT	EMP_ID,I.CMP_ID,I.BRANCH_ID,I.DEPT_ID,I.DESIG_ID,I.GROSS_SALARY
									FROM	T0095_INCREMENT I WITH (NOLOCK)
									WHERE	I.INCREMENT_ID =(
																SELECT	TOP 1 INCREMENT_ID
																FROM	T0095_INCREMENT I1 WITH (NOLOCK)
																WHERE	I1.EMP_ID=I.EMP_ID AND I1.CMP_ID=I.CMP_ID
																ORDER BY	INCREMENT_EFFECTIVE_DATE DESC, INCREMENT_ID DESC
															)
			) AS B ON B.EMP_ID = ET.EMP_ID AND B.CMP_ID=TE.CMP_ID
			LEFT JOIN T0040_DEPARTMENT_MASTER DPM WITH (NOLOCK) ON DPM.Dept_Id = b.Dept_ID
			LEft Join V0100_TS_ProjectDetails_Timesheet_Summary VTD on VTD.Timesheet_Detail_ID =  GT.Timesheet_Detail_ID


			where GT.cmp_id = @Cmp_ID and 
	
			 convert(date,@Fromdate ,103)  between  convert(date,substring(GT.Timesheet_Period,0,11),103)  and convert(date,substring(GT.Timesheet_Period,14,24),103)
			 or 
			 convert(date,@Todate ,103)  between  convert(date,substring(GT.Timesheet_Period,0,11),103)  and convert(date,substring(GT.Timesheet_Period,14,24),103)
			 or
			(convert(date,substring(GT.Timesheet_Period,0,11),103) >= convert(date,@Fromdate ,103) 
			and convert(date,substring(GT.Timesheet_Period,14,24),103) <= convert(date,@Todate ,103)
			or convert(date,substring(GT.Timesheet_Period,14,24),103) >= convert(date,@Fromdate ,103)
			and 
			convert(date,substring(GT.Timesheet_Period,0,11),103) <= convert(date,@Todate ,103)) 
			
			GROUP BY GT.Timesheet_Detail_ID,TE.Alpha_Emp_Code ,TE.Emp_Full_Name 
			,Client_Name ,Project_Code ,GT.Project_Name ,DPM.Dept_Name ,
			TWD.Monday,TWD.Tuesday,TWD.Wednesday,TWD.Thursday,TWD.Friday,TWD.Saturday,TWD.Sunday,
			PS.Project_Status,TE.Emp_Superior, 
			TWD.Monday_Desc,TWD.Tuesday_Desc,TWD.Wednesday_Desc,TWD.Thursday_Desc,TWD.Friday_Desc,TWD.Saturday_Desc,TWD.Sunday_Desc,
			GT.Timesheet_Period,
			TWD.WeekStart ,
			TWD.WeekEnd,
			TWD.Mon,TWD.Tue,TWD.Wed, TWD.Thu,TWD.fri,TWD.Sat,TWD.Sun
			order by  TWD.WeekStart 

		End		
			--added by Deepali - Testing Timesheet-27032024  for ahana -End   
	End

	
