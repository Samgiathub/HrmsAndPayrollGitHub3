

-- =============================================
-- Author:		Mukti Chauhan
-- Create date: 23-02-2017
-- Description:	GET_HOLIDAY_WEEKOFF_DATA 
---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[SP_GET_HOLIDAY_WEEKOFF_DATA]
  @Cmp_ID    numeric        
 ,@From_Date   datetime        
 --,@To_Date    datetime
 ,@Emp_ID    numeric        
 ,@constraint   varchar(MAX)  
 ,@Weekoff_Type numeric
 ,@Branch_ID			VARCHAR(MAX) = ''
 ,@Grd_ID			VARCHAR(MAX) = ''
 ,@Cat_ID			VARCHAR(MAX) = ''	
 ,@Dept_ID			VARCHAR(MAX) = ''
 ,@Desig_ID			VARCHAR(MAX) = ''	
 ,@Vertical_ID		VARCHAR(MAX) = ''
 ,@SubVertical_ID	VARCHAR(MAX) = ''
 ,@Type_ID			numeric  = 0
 ,@Segment_Id VARCHAR(MAX) = ''	
 ,@SubBranch_ID	VARCHAR(MAX) = ''
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	
	DECLARE @Required_Execution BIT;
	DECLARE @Return_Record_set numeric = 1 
	
	CREATE TABLE #Emp_Cons 
			(      
				Emp_ID numeric ,     
				Branch_ID numeric,
				Increment_ID numeric,
				--For_date datetime,
				--Employee_Code Varchar(250),      
				--Employee_Name Varchar(500),
				--Dept_Name VARCHAR(500),
				--Desig_Name VARCHAR(500)    
			);
				
	exec SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@From_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,'',0,0,@Segment_Id,@Vertical_Id,@SubVertical_Id,@SubBranch_ID,0,0,0,'0',0,0               
				
					
    --(To get holiday/weekoff data for all employees in seperate table)
	--*************************************************************************/
	IF OBJECT_ID('tempdb..#EMP_HOLIDAY') IS NULL
		BEGIN
			CREATE TABLE #EMP_HOLIDAY(EMP_ID NUMERIC, FOR_DATE DATETIME, IS_CANCEL BIT, Is_Half tinyint, Is_P_Comp tinyint, H_DAY numeric(4,1));
			CREATE UNIQUE CLUSTERED INDEX IX_EMP_HOLIDAY_EMPID_FORDATE ON #EMP_HOLIDAY(EMP_ID, FOR_DATE);
		END

	IF OBJECT_ID('tempdb..#Emp_WeekOff') IS NULL
		BEGIN
			CREATE TABLE #EMP_WEEKOFF
			(
				Row_ID			NUMERIC,
				Emp_ID			NUMERIC,
				For_Date		DATETIME,
				Weekoff_day		VARCHAR(10),
				W_Day			numeric(4,1),
				Is_Cancel		BIT
			)
			CREATE CLUSTERED INDEX IX_Emp_WeekOff_EmpID_ForDate ON #EMP_WEEKOFF(Emp_ID, For_Date)		
		END
  	IF OBJECT_ID('tempdb..#Emp_WeekOff_Holiday') IS NULL
	BEGIN
		--Holiday & WeekOff - In colon(;) seperated string (Without Cancel) : Used in SP_CALCULATE_PRESENT_DAYS
		CREATE TABLE #Emp_WeekOff_Holiday
		(
			Emp_ID				NUMERIC,
			WeekOffDate			VARCHAR(Max),
			WeekOffCount		NUMERIC(4,1),
			HolidayDate			VARCHAR(Max),
			HolidayCount		NUMERIC(4,1),
			HalfHolidayDate		VARCHAR(Max),
			HalfHolidayCount	NUMERIC(4,1),
			OptHolidayDate		VARCHAR(Max),
			OptHolidayCount		NUMERIC(4,1)
		);
		SET @Required_Execution  = 1;
	END 
	
	IF OBJECT_ID('tempdb..#EMP_HW_CONS') IS NULL
	BEGIN	
	
		--Holiday & Weekoff - In colon(;) seperated string (With Cancel) : Used in SP_CALCULATE_PRESENT_DAYS
		CREATE TABLE #EMP_HW_CONS
		(
			Emp_ID				NUMERIC,
			WeekOffDate			Varchar(Max),
			WeekOffCount		NUMERIC(4,1),
			CancelWeekOff		Varchar(Max),
			CancelWeekOffCount	NUMERIC(4,1),
			HolidayDate			Varchar(MAX),
			HolidayCount		NUMERIC(4,1),
			HalfHolidayDate		Varchar(MAX),
			HalfHolidayCount	NUMERIC(4,1),
			CancelHoliday		Varchar(Max),
			CancelHolidayCount	NUMERIC(4,1)
		);
		
		CREATE UNIQUE CLUSTERED INDEX IX_EMP_HW_CONS_EmpID ON #EMP_HW_CONS(Emp_ID)
		
		SET @Required_Execution  =1;		
	END
	

	IF @Required_Execution = 1
	BEGIN
		DECLARE @All_Weekoff BIT
		SET @All_Weekoff = 1;
		
		EXEC SP_GET_HW_ALL @CONSTRAINT=@CONSTRAINT,@CMP_ID=@Cmp_ID, @FROM_DATE=@FROM_DATE, @To_Date=@From_Date, @All_Weekoff = @All_Weekoff, @Exec_Mode=0		

--select * from #EMP_HW_CONS
--select * from #EMP_WEEKOFF
--select * from #Emp_WeekOff_Holiday

		if @Weekoff_Type=1 --for Assign Weekoff to fetch records not assigned weekoff
			BEGIN			
				--select vi.Emp_Full_Name,vi.Dept_Name,vi.Desig_Name,em.Alpha_Emp_Code,ho.* from #Emp_WeekOff_Holiday ho 
				--inner join #Emp_Cons es on ho.emp_id=es.Emp_ID		
				--inner join V0095_Increment_All_Data vi on es.Increment_ID=vi.Increment_ID
				--inner join T0080_EMP_MASTER em on em.Emp_ID=es.Emp_ID
				--Where charindex(';' + cast(@FROM_DATE as varchar(11)) + ';',ho.WeekOffDate)<0					
				select es.Emp_ID,vi.Emp_Full_Name,vi.Dept_Name,vi.Desig_Name,em.Alpha_Emp_Code from #Emp_Cons es
				inner join V0095_Increment_All_Data vi on es.Increment_ID=vi.Increment_ID
				inner join T0080_EMP_MASTER em WITH (NOLOCK) on em.Emp_ID=es.Emp_ID
				WHERE NOT EXISTS(SELECT 1 FROM #EMP_WEEKOFF WO WHERE ES.Emp_ID=WO.Emp_ID AND WO.For_Date= @FROM_DATE)
				--where es.Emp_ID NOT IN(select hw.Emp_ID  from #EMP_HW_CONS hw 
				--where charindex(';' + cast(@FROM_DATE as varchar(11)),hw.WeekOffDate)>0)				
			END
		else   --for Cancel Weekoff to fetch records already assigned weekoff
			BEGIN			
				select vi.Emp_Full_Name,vi.Dept_Name,vi.Desig_Name,em.Alpha_Emp_Code,hw.* from #EMP_HW_CONS hw
				inner join #Emp_Cons es on hw.emp_id=es.Emp_ID	
				inner join V0095_Increment_All_Data vi on es.Increment_ID=vi.Increment_ID
				inner join T0080_EMP_MASTER em WITH (NOLOCK) on em.Emp_ID=es.Emp_ID
				WHERE EXISTS(SELECT 1 FROM #EMP_WEEKOFF WO WHERE ES.Emp_ID=WO.Emp_ID AND WO.For_Date = @FROM_DATE)
				--Where charindex(';' + cast(@FROM_DATE as varchar(11)),hw.WeekOffDate)>0
			END
			
		--Insert Into #Data(Emp_Id,For_date,Employee_Code,Employee_Name)
		--values()
	END 
END


