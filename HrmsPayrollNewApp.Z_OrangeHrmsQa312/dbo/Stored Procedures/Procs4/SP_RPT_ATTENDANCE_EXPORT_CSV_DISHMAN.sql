--AUTHOR : HARDIK BAROT
--DATE : 08/11/2019
--PURPOSE : DIRECTLY EXPORT FIRST IN LAST OUT IN CSV FORMAT FOR IMPORT TO OTHER SOFTWARE AT DISHMAN CLIENT
---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_ATTENDANCE_EXPORT_CSV_DISHMAN]
	 @Cmp_ID 		numeric
	,@From_Date		datetime
	,@To_Date 		datetime
	,@Branch_ID		numeric
	,@Cat_ID 		numeric 
	,@Grd_ID 		numeric
	,@Type_ID 		numeric
	,@Dept_ID 		numeric
	,@Desig_ID 		numeric
	,@Emp_ID 		numeric
	,@constraint 	varchar(MAX)
	,@Report_For	varchar(50)
	,@SQL_ServerName varchar(200)
	,@Database_Name varchar(100)
	,@Export_Path varchar(300)
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	  
	
	IF @Branch_ID = 0  
		SET @Branch_ID = NULL
		
	IF @Cat_ID = 0  
		SET @Cat_ID = NULL

	IF @Grd_ID = 0  
		SET @Grd_ID = NULL

	IF @Type_ID = 0  
		SET @Type_ID = NULL

	IF @Dept_ID = 0  
		SET @Dept_ID = NULL

	IF @Desig_ID = 0  
		SET @Desig_ID = NULL

	IF @Emp_ID = 0  
		SET @Emp_ID = NULL

	If @From_Date Is Null
		Set @From_Date = Cast(GetDate()-1 As Varchar(11))

	If @To_Date Is Null
		Set @To_Date = Cast(GetDate()-1 As Varchar(11))

	CREATE TABLE #Emp_Cons 
	(      
		Emp_ID numeric ,     
		Branch_ID numeric,
		Increment_ID numeric    
	)  


	EXEC SP_RPT_FILL_EMP_CONS  @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID ,@Emp_ID ,@constraint ,0 ,0 ,0,0,0,0,0,0,0,0,0,0
	
	
	CREATE TABLE #Data         
	(         
		Emp_Id   numeric ,         
		For_date datetime,        
		Duration_in_sec numeric,        
		Shift_ID numeric ,        
		Shift_Type numeric ,        
		Emp_OT  numeric ,        
		Emp_OT_min_Limit numeric,        
		Emp_OT_max_Limit numeric,        
		P_days  numeric(12,2) default 0,        
		OT_Sec  numeric default 0  ,
		In_Time datetime,
		Shift_Start_Time datetime,
		OT_Start_Time numeric default 0,
		Shift_Change tinyint default 0,
		Flag int default 0,
		Weekoff_OT_Sec  numeric default 0,
		Holiday_OT_Sec  numeric default 0,
		Chk_By_Superior numeric default 0,
		IO_Tran_Id	   numeric default 0, -- io_tran_id is used for is_cmp_purpose (t0150_emp_inout)
		OUT_Time datetime,
		Shift_End_Time datetime,			--Ankit 16112013
		OT_End_Time numeric default 0,	--Ankit 16112013
		Working_Hrs_St_Time tinyint default 0, --Hardik 14/02/2014
		Working_Hrs_End_Time tinyint default 0, --Hardik 14/02/2014
		GatePass_Deduct_Days numeric(18,2) default 0 -- Add by Gadriwala Muslim 05012014
	)        

	CREATE NONCLUSTERED INDEX ix_Data_Emp_Id_For_date on #Data(Emp_Id,For_Date);

	EXEC P_GET_EMP_INOUT @Cmp_ID, @FROM_DATE, @TO_DATE

	IF OBJECT_ID('DATA_ATTENDANCE') IS NOT NULL
		DROP TABLE DATA_ATTENDANCE

	SELECT Alpha_Emp_Code as UserId, Convert(varchar(50),In_Time,126) As StartDate, Convert(varchar(50),In_Time,126) As StartTime, 
		Convert(varchar(50),Out_Time,126) As EndDate, Convert(varchar(50),Out_Time,126) As EndTime
	INTO DATA_ATTENDANCE
	FROM #DATA D 
		Inner Join T0080_EMP_MASTER E WITH (NOLOCK)  On D.Emp_Id = E.Emp_ID

	--SQLCMD -S acer-7\sql08r2 -d orange_hrms -Q "SELECT TOP 10 * FROM T0080_Emp_Master sp" -s "," -o "e:\result.csv"
	--SELECT * FROM DATA_ATTENDANCE
	Declare @Qry varchar(4000)
	Declare @File_Name varchar(100)
	--Set @File_Name = 'Att_' + Cast(DateName(dd,@From_Date) as Varchar(2)) + Cast(Month(@From_Date) as varchar(2)) + Cast(Year(@From_Date) As Varchar(4)) + '.csv'
	Set @File_Name = Convert(varchar,@From_Date,112) + '.csv'
	Set @Qry = ' SQLCMD -S ' + @SQL_ServerName + ' -d '+ @Database_Name+ ' -Q "SELECT UserId, StartDate, StartTime, EndDate, EndTime FROM DATA_ATTENDANCE" -s "," -o "' + @Export_Path + @File_Name + '"'

	EXEC  master..xp_cmdshell @Qry,no_output
	--EXEC  master..xp_cmdshell ' SQLCMD -S Acer-7\SQL08R2 -d Orange_HRMS -Q "SELECT UserId, StartDate, StartTime, EndDate, EndTime FROM DATA_ATTENDANCE" -s "," -o "e:\result.csv"'
	
RETURN