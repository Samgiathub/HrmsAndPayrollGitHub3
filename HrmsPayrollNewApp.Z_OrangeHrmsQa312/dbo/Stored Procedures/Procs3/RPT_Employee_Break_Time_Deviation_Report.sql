

-- =============================================
-- Author:		<Author,Nimesh Parmar>
-- Create date: <Create Date,01-Nov-2018>
-- Description:	<Description,For Getting Employee Break Time Deviation Record>
---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[RPT_Employee_Break_Time_Deviation_Report]
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
	,@Report_For	varchar(50) = 'EMP RECORD'
	,@Export_Type	varchar(50) = ''
	,@Type			numeric = 0 
	,@Con_Absent_Days   numeric = 0 
	,@Cancel_WKOF Numeric = 0 
	,@P_Branch varchar(max) = '' 
	,@P_Department varchar(max) = '' 
	,@P_Vertical varchar(max) = ''  
	,@P_SubVertical varchar(max) = '' 
	,@Leave_Flag Numeric(18,0) = 0	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	--set ansi_warnings off;

	
	CREATE TABLE #DATA     
	(     
		Emp_Id     numeric ,     
		For_date   datetime,    
		Duration_in_sec  numeric,    
		Shift_ID   numeric ,    
		Shift_Type   numeric ,    
		Emp_OT    numeric ,    
		Emp_OT_min_Limit numeric,    
		Emp_OT_max_Limit numeric,    
		P_days    numeric(12,3) default 0,
		OT_Sec    numeric default 0,
		In_Time datetime default null,
		Shift_Start_Time datetime default null,
		OT_Start_Time numeric default 0,
		Shift_Change tinyint default 0 ,
		Flag Int Default 0  ,
		Weekoff_OT_Sec  numeric default 0,
		Holiday_OT_Sec  numeric default 0,
		Chk_By_Superior numeric default 0,
		IO_Tran_Id	   numeric default 0,
		Out_time datetime default null,
		Shift_End_Time datetime,		
		OT_End_Time numeric default 0,	
		Working_Hrs_St_Time tinyint default 0, 
		Working_Hrs_End_Time tinyint default 0, 
		GatePass_Deduct_Days numeric(18,2) default 0 
	)  
	CREATE NONCLUSTERED INDEX IX_Data ON dbo.#data
	(
		Emp_Id,Shift_ID,For_Date
	) 
				
	IF @Branch_ID = 0  
		set @Branch_ID = null
		
	IF @Cat_ID = 0  
		set @Cat_ID = null

	IF @Grd_ID = 0  
		set @Grd_ID = null

	IF @Type_ID = 0  
		set @Type_ID = null

	IF @Dept_ID = 0  
		set @Dept_ID = null

	IF @Desig_ID = 0  
		set @Desig_ID = null

	IF @Emp_ID = 0  
		set @Emp_ID = null
	
	
	 IF (@P_Branch = '' OR @P_Branch = '0') 
		SET @P_Branch = NULL;    
	
	 IF (@P_Vertical = '' OR @P_Vertical = '0')
		SET @P_Vertical = NULL
	
	IF (@P_Subvertical = '' OR @P_Subvertical = '0') 
		set @P_Subvertical = NULL
	
	IF (@P_Department = '' OR @P_Department = '0') 
		set @P_Department = NULL

	if @P_Branch is null
		Begin	
			select   @P_Branch = COALESCE(@P_Branch + ',', '') + cast(Branch_ID as nvarchar(5))  from T0030_BRANCH_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_ID 
			set @P_Branch = @P_Branch + ',0'
		End
	
	if @P_Vertical is null
		Begin	
			select   @P_Vertical = COALESCE(@P_Vertical + ',', '') + cast(Vertical_ID as nvarchar(5))  from T0040_Vertical_Segment WITH (NOLOCK) where Cmp_ID=@Cmp_ID 
		
			If @P_Vertical IS NULL
				set @P_Vertical = '0';
			else
				set @P_Vertical = @P_Vertical + ',0'		
		End
	if @P_Subvertical is null
		Begin	
			select   @P_Subvertical = COALESCE(@P_Subvertical + ',', '') + cast(subVertical_ID as nvarchar(5))  from T0050_SubVertical WITH (NOLOCK) where Cmp_ID=@Cmp_ID 
		
			If @P_Subvertical IS NULL
				set @P_Subvertical = '0';
			else
				set @P_Subvertical = @P_Subvertical + ',0'
		End
	IF @P_Department is null
		Begin
			select   @P_Department = COALESCE(@P_Department + ',', '') + cast(Dept_ID as nvarchar(5))  from T0040_DEPARTMENT_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_ID 		
		
			if @P_Department is null
				set @P_Department = '0';
			else
				set @P_Department = @P_Department + ',0'
		End
	
	
	CREATE TABLE #Emp_Cons 
	 (      
		Emp_ID numeric ,     
		Branch_ID numeric,
		Increment_ID numeric
	 )      
	
	EXEC SP_RPT_FILL_EMP_CONS  @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID ,@Emp_ID ,@constraint 
	,0 ,0 ,0,0,0,0,0,0,0,0,0,0
	
	CREATE UNIQUE CLUSTERED INDEX IX_EMP_CONS_EMPID ON #Emp_Cons (EMP_ID);


	EXEC P_GET_EMP_INOUT @Cmp_ID, @FROM_DATE, @TO_DATE,1 
	
	
	
	CREATE TABLE #SHIFT_BREAK
	(
		Emp_ID		INT,
		For_Date	DateTime,
		Shift_ID	INT,		
		Break_ID	INT,
		Break_Start	DateTime,
		Break_End	DateTime,
		Daviation	BIT
	)
	
	
	INSERT INTO #SHIFT_BREAK(Emp_ID, For_Date, Shift_ID)
	SELECT	D.EMP_ID, D.FOR_DATE, D.Shift_ID
	FROM	#Data D 
			INNER JOIN T0040_SHIFT_MASTER SM WITH (NOLOCK) ON D.Shift_ID=SM.Shift_ID			
	
	
	
	--Employee Wise Break
	UPDATE	SB
	SET		Break_ID = (
							SELECT Top 1	Break_ID 
							FROM			T0100_BREAK_TIME BT1 WITH (NOLOCK)
							WHERE			BT1.Emp_ID=SB.Emp_ID AND BT1.Effective_Date <= SB.For_Date 
							Order By		BT1.Effective_Date Desc
						)
	FROM	#SHIFT_BREAK SB
			INNER JOIN (
							SELECT DISTINCT EMP_ID 
							FROM			T0100_BREAK_TIME BT WITH (NOLOCK)
							WHERE			CMP_ID=@CMP_ID
						) BT ON SB.EMP_ID=BT.EMP_ID
	
	--Branch + Department Wise Break		
	UPDATE	SB
	SET		Break_ID = (
							SELECT	Top 1	Break_ID 
							FROM			T0100_BREAK_TIME BT1 WITH (NOLOCK)
							WHERE			BT1.Dept_ID=I.Dept_ID AND BT1.Branch_ID=EC.Branch_ID AND BT1.Effective_Date <= SB.For_Date 
							Order By		BT1.Effective_Date Desc
						)
	FROM	#SHIFT_BREAK SB
			INNER JOIN #EMP_CONS EC ON SB.EMP_ID=EC.EMP_ID
			INNER JOIN T0095_INCREMENT I ON EC.Increment_ID=I.Increment_ID
	WHERE	Break_ID IS NULL
	
	
	UPDATE	SB
	SET		Break_Start = SB.For_Date +  BT.Break_Start_Time,
			Break_End = SB.For_Date +  BT.Break_End_Time
	FROM	#SHIFT_BREAK SB
			INNER JOIN T0100_BREAK_TIME BT ON SB.Break_ID=BT.Break_ID
			
	

	--For Night Shift Break
	UPDATE	SB
	SET		Break_Start = Break_Start + 1,
			Break_End = Break_End +  1
	FROM	#SHIFT_BREAK SB
	WHERE	DATEPART(HH, Break_Start) BETWEEN 0 AND 8
	
	
	
	UPDATE	SB
	SET		Daviation = 1
	FROM	#SHIFT_BREAK SB
			INNER JOIN #Data D ON SB.Break_Start NOT BETWEEN D.In_Time AND D.Out_Time
			
	

	SELECT	D.EMP_ID, D.FOR_DATE, D.Shift_ID, D.In_Time, D.Out_Time, SB.Break_Start, SB.Break_End, 
			CONVERT(DATETIME, convert(varchar(17), DI.IO_DateTime, 113), 113) As IO_DateTime, DI.IO_TRAN_ID, DI.Enroll_No,
			ROW_NUMBER() OVER(PARTITION BY D.EMP_ID, D.FOR_DATE ORDER BY D.EMP_ID, D.FOR_DATE, DI.IO_DATETIME) AS ROW_ID 
	INTO	#DAV_INOUT	
	FROM	T9999_DEVICE_INOUT_DETAIL DI WITH (NOLOCK)
			INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON DI.Enroll_No=E.Enroll_No
			INNER JOIN #DATA D ON D.Emp_ID=E.Emp_ID AND DI.IO_DateTime BETWEEN D.In_Time AND DATEADD(N, 1,IsNull(D.Out_Time, D.In_Time))
			INNER JOIN #SHIFT_BREAK SB ON D.EMP_ID=SB.EMP_ID AND D.FOR_DATE = SB.FOR_DATE
	

	SELECT	*, I.ROW_ID % 2 As Flag
	INTO	#DAV_PRC
	FROM	#DAV_INOUT I 
	WHERE	IsNull(I.OUT_TIME, I.In_Time) <> I.IO_DATETIME AND I.In_Time <> I.IO_DATETIME
	
	

	DROP TABLE #DAV_INOUT
	
	SELECT	ROW_NUMBER() OVER(PARTITION BY BS.EMP_ID, D.FOR_DATE ORDER BY BS.EMP_ID, BS.FOR_DATE, O.IO_DATETIME) AS ROW_ID, BS.Emp_ID, BS.For_Date, BS.Shift_ID, D.In_Time, D.Out_Time, BS.Break_Start, BS.Break_End, 
			O.IO_DATETIME As [Out], I.IO_DateTime As [In], I.IO_DateTime - O.IO_DATETIME As Duration
	INTO	#FINAL
	FROM	#SHIFT_BREAK BS 
			INNER JOIN #DATA D ON BS.EMP_ID = D.EMP_ID AND BS.FOR_DATE = D.FOR_DATE
			LEFT OUTER JOIN #DAV_PRC O ON D.EMP_ID=O.EMP_ID AND D.FOR_DATE=O.FOR_DATE AND O.Flag = 0
			LEFT OUTER JOIN #DAV_PRC I ON O.ROW_ID = I.ROW_ID-1 AND I.EMP_ID=O.EMP_ID AND I.FOR_DATE=O.FOR_DATE AND I.Flag = 1
		
	DROP TABLE #DAV_PRC
	

	
	DELETE FROM #FINAL 
	WHERE ([OUT] IS NULL AND [IN] IS NULL) OR
			([OUT] BETWEEN Break_Start AND Break_End  AND [In] BETWEEN Break_Start AND Break_End)

	CREATE TABLE #COL_SORT_INDEX
	(
		ID	INT,
		ColName Varchar(32)
	)
	INSERT INTO #COL_SORT_INDEX
	VALUES(1, 'Out')
	INSERT INTO #COL_SORT_INDEX
	VALUES(2, 'In')
	INSERT INTO #COL_SORT_INDEX
	VALUES(3, 'Duration')
	
	

	SELECT	T.*, SORT.ID
	INTO	#UNPVT
	FROM	(SELECT ROW_ID, Emp_ID, For_Date, [IN], [OUT], [Duration]
			 FROM	#FINAL) F
			 UNPIVOT
			 (
				LabelValue FOR LabelName IN ( [IN], [OUT], [Duration])
			 ) t
			 INNER JOIN #COL_SORT_INDEX SORT ON T.LabelName=SORT.ColName


	DECLARE @COLS VARCHAR(MAX)
	SELECT	@COLS = COALESCE(@COLS + ',' , '') + QUOTENAME(LabelName + '_' + Cast(Row_ID As Varchar(10)))
	from	(SELECT DISTINCT ROW_ID, LabelName, ID FROM #UNPVT) T
	ORDER BY ROW_ID,  ID

	DECLARE @QUERY VARCHAR(MAX)
	

	UPDATE	#UNPVT SET LabelName = LabelName + '_' + Cast(ROW_ID as  Varchar(10))
		

	SET @QUERY = 'SELECT	EM.Alpha_Emp_Code AS [Employee_Code],Em.Emp_Full_Name AS [Employee_Name],
							Convert(Varchar(12),BS.For_Date,103) as For_Date,SM.Shift_Name,Sm.Shift_St_Time AS [Shift_Start_Time],Sm.Shift_End_Time AS [Shift_End_Time],
							cast(DATEPART(hour, D.In_Time) as varchar) + '':'' + cast(DATEPART(minute,D.In_Time) as varchar) as In_Time, 
							cast(DATEPART(hour, D.Out_Time) as varchar) + '':'' + cast(DATEPART(minute,D.Out_Time) as varchar) as Out_Time, 
							cast(DATEPART(hour, BS.Break_Start) as varchar) + '':'' + cast(DATEPART(minute,BS.Break_Start) as varchar) as Break_Start,
							cast(DATEPART(hour, BS.Break_End) as varchar) + '':'' + cast(DATEPART(minute, BS.Break_End) as varchar) as Break_End, 								
							' + @COLS + '
				FROM	
						(SELECT		*
						 FROM	(
									SELECT	EMP_ID,FOR_DATE,LabelName,cast(DATEPART(hour, LabelValue) as varchar) + '':'' + cast(DATEPART(minute, LabelValue) as varchar) LabelValue FROM #UNPVT
								) U PIVOT
								(
									MAX(LabelValue) FOR LabelName IN(' + @COLS + ')
								) T 
						) P 
						INNER JOIN #SHIFT_BREAK BS on P.Emp_ID=BS.Emp_ID AND P.For_Date=BS.For_Date
						INNER JOIN #DATA D ON BS.EMP_ID = D.EMP_ID AND BS.FOR_DATE = D.FOR_DATE
						INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON EM.Emp_ID = D.Emp_ID 
						INNER JOIN T0040_SHIFT_MASTER SM WITH (NOLOCK) ON Sm.Shift_ID =D.Shift_ID'
	
	EXEC (@QUERY)	
	
	
RETURN

