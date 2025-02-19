CREATE PROCEDURE [dbo].[P_Continous_Absent_Reminder_DBA]

--CREATED BY :- Parichay Shah.
--CREATED ON :- 30-11-2020
--DETAILS    :- To mail, Today's Continuous Absent Report For
--					EMPLOYEE_Continuous_Absent_1_2
--					EMPLOYEE_Continuous_Absent_3_4
--					EMPLOYEE_Continuous_Absent_5_6

--EXEC [P_Continous_Absent_Reminder_DBA] 1,'',3
@CMP_ID_PASS NUMERIC(18,0) = 0,
@CC_EMAIL NVARCHAR(MAX) = '',
@CON_ABSENT_DAYS VARCHAR(10) = '3'
AS 
BEGIN   
SET NOCOUNT ON	
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
SET ANSI_WARNINGS OFF;

	DECLARE @DATE VARCHAR(11)   
    DECLARE @APPROVAL_DAY AS NUMERIC    
    DECLARE @ReminderTemplate AS NVARCHAR(4000)
    Declare @From_Date as datetime
    Declare @To_date as datetime
	DECLARE @History_Id NUMERIC
	--DECLARE @CMP_ID_PASS AS NUMERIC = 1
	--DECLARE @CON_ABSENT_DAYS VARCHAR(10) = '3'
      
	set @To_date   = CAST(GETDATE() AS varchar(11))
	set @From_Date  = DATEADD(DD,(@CON_ABSENT_DAYS + 10)*-1, @TO_DATE)
	select  @From_Date,@To_date
    SET @DATE = CAST(GETDATE() AS varchar(11))
          
    IF OBJECT_ID('tempdb..#Temp') IS NOT NULL 
        BEGIN
            DROP TABLE #Temp
        END

	DECLARE @CONSTRAINT VARCHAR(MAX);
		
SELECT @CONSTRAINT = COALESCE(@CONSTRAINT + '#','') + CAST(I.EMP_ID AS varchar(10))
FROM FN_GETEMPINCREMENT (@CMP_ID_PASS,0,GETDATE()) I1 INNER JOIN
	T0095_INCREMENT I WITH (NOLOCK) ON I1.Increment_ID = I.Increment_ID INNER JOIN
	T0080_EMP_MASTER E WITH (NOLOCK) ON I.Emp_ID = E.Emp_ID LEFT OUTER JOIN
	T0040_GRADE_MASTER G WITH (NOLOCK) ON I.Grd_ID = G.Grd_ID LEFT OUTER JOIN
	Active_InActive_Users A WITH (NOLOCK) ON I.Emp_ID = A.Emp_ID
WHERE I.Cmp_ID = @CMP_ID_PASS AND ISNULL(I.Emp_Fix_Salary,0) <> 1 
		AND (E.Emp_Left_Date is null OR E.Emp_Left_Date > @To_Date) and E.Date_Of_Join <= @To_Date
		AND ISNULL(A.Is_Active,1) = 1

CREATE TABLE #ContinuousLeave (Emp_ID numeric, Emp_code varchar(20), Emp_Full_Name nvarchar(300), Branch_Address nvarchar(300), comp_name nvarchar(300), 
Branch_Name nvarchar(300), Dept_Name nvarchar(300), Grd_Name nvarchar(300), Desig_Name nvarchar(300), P_From_date datetime, P_To_Date datetime, 
BRANCH_ID numeric, cmp_name nvarchar(300), cmp_address nvarchar(300), Mobile_No varchar(30), Emp_First_Name nvarchar(300), F_Dt datetime, toDate datetime, 
Absent_Day Numeric(18,0), Type_Name nvarchar(300), Reporting_Manager nvarchar(300), Vertical_Name nvarchar(300), SubVertical_Name nvarchar(300))
		
	IF @CONSTRAINT IS NOT NULL
		
	INSERT INTO #ContinuousLeave
		exec SP_RPT_EMP_ATTENDANCE_MUSTER_GET @Cmp_ID=@cmp_id_Pass,@From_Date=@From_Date,@To_Date=@To_Date,@Branch_ID=0,@Cat_ID=0,@Grd_ID=0,@Type_ID=0,
		@Dept_ID=0,@Desig_ID=0,@Emp_ID=0,@Constraint=@CONSTRAINT,@Report_For='ABSENT_CON',@Con_Absent_Days=@Con_Absent_Days 

--select * from #ContinuousLeave

----------------------------------------------------------------------------------------------------------------------
DECLARE @vSubject AS NVARCHAR (255)
DECLARE @vXML_String AS NVARCHAR (MAX)
DECLARE @vBody AS NVARCHAR (MAX)                  
DECLARE @Unit char(2) ='MB'  
DECLARE @vRecipients AS VARCHAR (MAX)
DECLARE @vCopy_Recipients AS VARCHAR (MAX)
SET @vRecipients = 'dba@orangewebtech.com;'
--SET @vCopy_Recipients = 'sajid@orangewebtech.com;' 

SET @vSubject = 'HRMS : '+@@SERVERNAME+'- Today''s Continuous Absent Report'
SET @vXML_String = ''
SET @vBody = ''

----------------------------------------------------------------------------------------------------------------------
IF OBJECT_ID ('tempdb.dbo.#Continuous_Absent_1_2') IS NOT NULL
BEGIN
		DROP TABLE dbo.#Continuous_Absent_1_2
END

select Emp_code AS Code,
Emp_Full_Name AS EmployeeName,
Branch_Name AS Branch,
Dept_Name AS Department,
Desig_Name AS Designation,
Isnull(convert(varchar(11),F_Dt,103),'-') AS FromDate,
Isnull(convert(varchar(11),toDate,103),'-') AS ToDate,
Isnull((DATEDIFF(d, F_DT, toDate) +1),'-') AS AbsentDays
INTO dbo.#Continuous_Absent_1_2
from #ContinuousLeave
WHERE Isnull((DATEDIFF(d, F_DT, toDate) +1),'-') >= 1 AND Isnull((DATEDIFF(d, F_DT, toDate) +1),'-') <= 2

IF @@ROWCOUNT = 0
BEGIN
	GOTO skip_Feed_Details_1_2
END

SET @vXML_String =
	CONVERT (NVARCHAR (MAX),
		(	SELECT
				 '',X.Code AS 'td'
				,'',X.EmployeeName AS 'td'
				,'',X.Branch AS 'td'
				,'',X.Department AS 'td'
				,'',X.Designation AS 'td'
				,'',X.FromDate AS 'td'
				,'',X.ToDate AS 'td'
				,'',X.AbsentDays AS 'td'
			FROM
				dbo.#Continuous_Absent_1_2 X
			FOR
				XML PATH ('tr')
		)
	)

SET @vBody = @vBody+

	'<html>
		<br><br>
		<h3 style="color:blue;"><left>EMPLOYEE_Continuous_Absent_1_2</left></h3>
		<left>
			<table border=1 cellpadding=2>
				<tr>
					<th>Code</th>
					<th>EmployeeName</th>
					<th>Branch</th>
					<th>Department</th>
					<th>Designation</th>
					<th>FromDate</th>
					<th>ToDate</th>
					<th>AbsentDays</th>
				</tr>'
SELECT @vBody
SET @vBody = @vBody+@vXML_String+
	'	</table>
		</left>'

skip_Feed_Details_1_2:	

IF OBJECT_ID ('tempdb.dbo.#Continuous_Absent_1_2') IS NOT NULL
BEGIN
		DROP TABLE dbo.#Continuous_Absent_1_2
END
----------------------------------------------------------------------------------------------------------------------
IF OBJECT_ID ('tempdb.dbo.#Continuous_Absent_3_4') IS NOT NULL
BEGIN
		DROP TABLE dbo.#Continuous_Absent_3_4
END

select Emp_code AS Code,
Emp_Full_Name AS EmployeeName,
Branch_Name AS Branch,
Dept_Name AS Department,
Desig_Name AS Designation,
Isnull(convert(varchar(11),F_Dt,103),'-') AS FromDate,
Isnull(convert(varchar(11),toDate,103),'-') AS ToDate,
Isnull((DATEDIFF(d, F_DT, toDate) +1),'-') AS AbsentDays
INTO dbo.#Continuous_Absent_3_4
from #ContinuousLeave
WHERE Isnull((DATEDIFF(d, F_DT, toDate) +1),'-') >= 3 AND Isnull((DATEDIFF(d, F_DT, toDate) +1),'-') <= 4

IF @@ROWCOUNT = 0
BEGIN
	GOTO skip_Feed_Details_3_4
END

SET @vXML_String =
	CONVERT (NVARCHAR (MAX),
		(	SELECT
				 '',X.Code AS 'td'
				,'',X.EmployeeName AS 'td'
				,'',X.Branch AS 'td'
				,'',X.Department AS 'td'
				,'',X.Designation AS 'td'
				,'',X.FromDate AS 'td'
				,'',X.ToDate AS 'td'
				,'',X.AbsentDays AS 'td'
			FROM
				dbo.#Continuous_Absent_3_4 X
			FOR
				XML PATH ('tr')
		)
	)

SET @vBody = @vBody+

	'<html>
		<br><br>
		<h3 style="color:blue;"><left>EMPLOYEE_Continuous_Absent_3_4</left></h3>
		<left>
			<table border=1 cellpadding=2>
				<tr>
					<th>Code</th>
					<th>EmployeeName</th>
					<th>Branch</th>
					<th>Department</th>
					<th>Designation</th>
					<th>FromDate</th>
					<th>ToDate</th>
					<th>AbsentDays</th>
				</tr>'

SET @vBody = @vBody+@vXML_String+
	'	</table>
		</left>'

skip_Feed_Details_3_4:	

IF OBJECT_ID ('tempdb.dbo.#Continuous_Absent_3_4') IS NOT NULL
BEGIN
		DROP TABLE dbo.#Continuous_Absent_3_4
END
----------------------------------------------------------------------------------------------------------------------
IF OBJECT_ID ('tempdb.dbo.#Continuous_Absent_5_6') IS NOT NULL
BEGIN
		DROP TABLE dbo.#Continuous_Absent_5_6
END

select Emp_code AS Code,
Emp_Full_Name AS EmployeeName,
Branch_Name AS Branch,
Dept_Name AS Department,
Desig_Name AS Designation,
Isnull(convert(varchar(11),F_Dt,103),'-') AS FromDate,
Isnull(convert(varchar(11),toDate,103),'-') AS ToDate,
Isnull((DATEDIFF(d, F_DT, toDate) +1),'-') AS AbsentDays
INTO dbo.#Continuous_Absent_5_6
from #ContinuousLeave
WHERE Isnull((DATEDIFF(d, F_DT, toDate) +1),'-') >= 5 AND Isnull((DATEDIFF(d, F_DT, toDate) +1),'-') <= 6

IF @@ROWCOUNT = 0
BEGIN
	GOTO skip_Feed_Details_5_6
END

SET @vXML_String =
	CONVERT (NVARCHAR (MAX),
		(	SELECT
				 '',X.Code AS 'td'
				,'',X.EmployeeName AS 'td'
				,'',X.Branch AS 'td'
				,'',X.Department AS 'td'
				,'',X.Designation AS 'td'
				,'',X.FromDate AS 'td'
				,'',X.ToDate AS 'td'
				,'',X.AbsentDays AS 'td'
			FROM
				dbo.#Continuous_Absent_5_6 X
			FOR
				XML PATH ('tr')
		)
	)

SET @vBody = @vBody+

	'<html>
		<br><br>
		<h3 style="color:blue;"><left>EMPLOYEE_Continuous_Absent_5_6</left></h3>
		<left>
			<table border=1 cellpadding=2>
				<tr>
					<th>Code</th>
					<th>EmployeeName</th>
					<th>Branch</th>
					<th>Department</th>
					<th>Designation</th>
					<th>FromDate</th>
					<th>ToDate</th>
					<th>AbsentDays</th>
				</tr>'

SET @vBody = @vBody+@vXML_String+
	'	</table>
		</left>'

skip_Feed_Details_5_6:	

IF OBJECT_ID ('tempdb.dbo.#Continuous_Absent_5_6') IS NOT NULL
BEGIN
		DROP TABLE dbo.#Continuous_Absent_5_6
END
----------------------------------------------------------------------------------------------------------------------
--	Finalize @vBody Variable Contents
----------------------------------------------------------------------------------------------------------------------

SET @vBody =

	'	<html>
			<body>
			<style type="text/css">
				table {font-size:8.0pt;font-family:Arial;text-align:left;}
				tr {text-align:left;}
			</style>'

	+@vBody+

	'	</body>
		</html>'

SET @vBody = REPLACE (@vBody,'<td>right_align','<td align="right">')

----------------------------------------------------------------------------------------------------------------------
--	 Deliver Results / Notification 
----------------------------------------------------------------------------------------------------------------------
	
EXEC msdb.dbo.sp_send_dbmail
	 @profile_name = 'SQL08R2_Alert_Email'
	,@recipients = @vRecipients
	,@copy_recipients = @vCopy_Recipients
	,@subject = @vSubject
	,@body = @vBody
	,@body_format = 'HTML'

drop table #ContinuousLeave;

END