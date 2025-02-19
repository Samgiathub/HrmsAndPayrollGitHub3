
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_Mobile_Monthly_Shift_Roster]

	@Cmp_ID numeric(18,0),
	@From_Date datetime,
	@To_Date datetime,
	@Emp_ID numeric(18,0)
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

CREATE TABLE #ShiftRoaster
(
	Row_ID	numeric(18,0),
	Emp_id	numeric(18,0),
	Cmp_id	numeric(18,0),
	Branch_ID	Numeric(18,0) default 0,
	Alpha_emp_code	nvarchar(50)	NUll,
	Emp_Name_full	nvarchar(200)	NUll,
	For_Date	Datetime			NUll,
	Shift_ID	numeric(18,0)	default 0,
	Shift_Time	nvarchar(200)	default '-',
	Shift_WO	nvarchar(2)		default ''
	
--	HolidayName varchar(100) default ''
)


--INSERT INTO #roster_date exec Get_Roster_Shift_Weekoff_Monthly @Cmp_ID=1,@From_Date='2016-10-01 00:00:00',@To_Date='2016-10-31 00:00:00',@Branch_ID=0,@Cat_ID=0,@Grd_ID=0,@Type_ID=0,@Dept_ID=0,@Desig_ID=0,@Emp_ID=1,@Constraint=N'',@Print=0
INSERT INTO #ShiftRoaster (Row_ID,Emp_id,Cmp_id,Alpha_emp_code,Emp_Name_full,For_Date,Shift_ID,Shift_Time,Shift_WO)
EXEC Get_Roster_Shift_Weekoff_Monthly @Cmp_ID=@Cmp_ID,@From_Date=@From_Date,@To_Date=@To_Date,@Branch_ID=0,@Cat_ID=0,@Grd_ID=0,@Type_ID=0,@Dept_ID=0,@Desig_ID=0,@Emp_ID=@Emp_ID,@Constraint=N'',@Print=0

 --INSERT INTO #ShiftRoaster
SELECT Row_ID,SR.Emp_id,SR.Branch_ID,Alpha_emp_code,Emp_Name_full,For_Date,SR.Shift_ID,Shift_Time,Shift_WO,SM.Shift_Name,
(CASE WHEN Shift_WO = 'W' THEN 'Day Off' ELSE  HM.Hday_Name END) AS 'Hday_Name',
DATENAME(WEEKDAY,For_Date) AS 'DayName'
FROM #ShiftRoaster SR
INNER JOIN  T0040_SHIFT_MASTER SM WITH (NOLOCK) ON SR.Shift_ID = SM.Shift_ID
LEFT JOIN T0040_HOLIDAY_MASTER HM WITH (NOLOCK) ON (SR.For_Date = HM.H_From_Date OR SR.For_Date = HM.H_To_Date) AND SR.Branch_ID = HM.Branch_ID
--WHERE SR.Emp_id = @Emp_ID

