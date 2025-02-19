
---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[Sp_Get_Holiday_Weekoff]        
  @Cmp_ID    numeric        
 ,@From_Date   datetime        
 ,@To_Date    datetime         
 ,@Emp_id   numeric
 ,@Use_Table tinyint = 0 -- Added by Gadriwala Muslim 15062015        
 
AS        
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	--create table #Emp_Weekoff 
	--(
	--	Emp_ID  numeric(18,0),
	--	Cmp_ID  numeric(18,0),
	--	For_Date datetime,
	--	W_Day   numeric(18,2)
	--)
	--create table #Emp_Holiday 
	--(
	--	Emp_ID numeric(18,0),
	--	Cmp_ID numeric(18,0),
	--	For_Date datetime,
	--	H_Day numeric(18,2),
	--	is_Half_Day tinyint
	--)


	CREATE TABLE #Emp_WeekOff_Holiday1
	(
		Emp_ID numeric(18,0),
		Cmp_ID numeric(18,0),
		For_Date datetime,
		Status	nvarchar(50)
	)

	CREATE TABLE #EMP_HOLIDAY(EMP_ID NUMERIC, FOR_DATE DATETIME, IS_CANCEL BIT, Is_Half tinyint, Is_P_Comp tinyint, H_DAY numeric(4,1));
	CREATE UNIQUE CLUSTERED INDEX IX_EMP_HOLIDAY_EMPID_FORDATE ON #EMP_HOLIDAY(EMP_ID, FOR_DATE);

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

	DECLARE @CONSTRAINT VARCHAR(20)
	SET @CONSTRAINT = CAST(@Emp_id AS VARCHAR(20))
		
	EXEC SP_GET_HW_ALL @CONSTRAINT=@CONSTRAINT,@CMP_ID=@Cmp_ID, @FROM_DATE=@FROM_DATE, @TO_DATE=@TO_DATE, @All_Weekoff = 1, @Exec_Mode=0		


	IF @Use_Table = 1   -- Added by Gadriwala Muslim 15062015
		BEGIN
			--exec SP_EMP_WEEKOFF_DATE_GET @Emp_id,@Cmp_ID,@From_Date,@To_Date,null,null,9,'',@varWeekOff_Date output ,@Weekoff_days output,@Cancel_WeekOff output,1
			--Exec dbo.SP_EMP_HOLIDAY_DATE_GET @Emp_id,@Cmp_ID,@From_Date,@To_Date,null,null,9,@StrHoliday_Date output,@Holiday_days output,@Cancel_Holiday output,1,0
						
			IF EXISTS (SELECT 1 FROM #EMP_WEEKOFF)
				BEGIN
					
					DELETE	W 
					FROM	#EMP_WEEKOFF W
					WHERE	EXISTS(SELECT 1 FROM #EMP_HOLIDAY H WHERE W.Emp_ID=H.EMP_ID AND W.For_Date=H.FOR_DATE AND H.IS_CANCEL=0)
					
					INSERT	INTO #Emp_WeekOff_Holiday1(Emp_ID,Cmp_ID,For_Date,[Status])	
					SELECT	Emp_ID,@Cmp_ID,For_Date,'Weekoff'
					FROM	#Emp_Weekoff
				END
			IF EXISTS(SELECT 1 FROM #EMP_HOLIDAY)
				BEGIN	
					INSERT	INTO #Emp_WeekOff_Holiday1(Emp_ID,Cmp_ID,For_Date,[Status])	
					SELECT	Emp_ID,@Cmp_ID,For_Date,'Holiday' 
					FROM	#Emp_Holiday 	
				END	
			SELECT * FROM #Emp_WeekOff_Holiday1
		END 
	ELSE
		BEGIN
			--exec SP_EMP_WEEKOFF_DATE_GET @Emp_id,@Cmp_ID,@From_Date,@To_Date,null,null,9,'',@varWeekOff_Date output ,@Weekoff_days output,@Cancel_WeekOff output
			--Exec dbo.SP_EMP_HOLIDAY_DATE_GET @Emp_id,@Cmp_ID,@From_Date,@To_Date,null,null,9,@StrHoliday_Date output,@Holiday_days output,@Cancel_Holiday output,0,0
		
		
		
			--INSERT INTO #WeekOff_Holiday(Weekoff_days,Holidays,Weekoff_Dates,Holiday_Dates)
			--SELECT @Weekoff_days AS Weekoff_days,@Holiday_days AS Holidays,@varWeekOff_Date AS Weekoff_Date,@StrHoliday_Date AS Holiday_Date

			Declare @varHoliday_Date AS varchar(max)
			DECLARE @varWeekOff_Date AS varchar(max)
			DECLARE @Weekoff_Days AS numeric(18,0)
			--declare @Cancel_WeekOff AS numeric(18,0)
			DECLARE @Holiday_Days AS numeric(18,0)
			--declare @Cancel_Holiday AS numeric(18,0)
			SELECT @Weekoff_days = SUM(W_DAY) FROM #EMP_WEEKOFF 
			SELECT @Holiday_Days = SUM(H_DAY) FROM #EMP_HOLIDAY 

			SELECT @varWeekOff_Date = COALESCE(@varWeekOff_Date + ';', '') + CAST(FOR_DATE AS VARCHAR(11)) FROM #EMP_WEEKOFF 
			SELECT @varHoliday_Date = COALESCE(@varHoliday_Date + ';', '') + CAST(FOR_DATE AS VARCHAR(11)) FROM #EMP_HOLIDAY

			INSERT INTO #WeekOff_Holiday(Weekoff_days,Holidays,Weekoff_Dates,Holiday_Dates)
			SELECT @Weekoff_Days AS Weekoff_days,@Holiday_Days AS Holidays,@varWeekOff_Date AS Weekoff_Date,@varHoliday_Date AS Holiday_Date
		END	
