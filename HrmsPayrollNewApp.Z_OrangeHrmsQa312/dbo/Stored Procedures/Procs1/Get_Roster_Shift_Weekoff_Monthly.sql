
---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[Get_Roster_Shift_Weekoff_Monthly]

	 @Cmp_ID		NUMERIC
	,@From_Date		DATETIME
	,@To_Date		DATETIME 
	,@Branch_ID		NUMERIC = 0
	,@Cat_ID		NUMERIC = 0
	,@Grd_ID		NUMERIC = 0
	,@Type_ID		NUMERIC = 0
	,@Dept_ID		NUMERIC = 0
	,@Desig_ID		NUMERIC = 0
	,@Emp_ID		NUMERIC = 0
	,@Constraint	VARCHAR(MAX) = ''
	,@Print			TinyInt = 0
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	IF @Branch_ID = 0
		SET @Branch_ID = NULL
	IF @Cat_ID = 0
		SET @Cat_ID = NULL
		 
	IF @Type_ID = 0
		SET @Type_ID = NULL
	IF @Dept_ID = 0
		SET @Dept_ID = NULL
	IF @Grd_ID = 0
		SET @Grd_ID = NULL
	IF @Emp_ID = 0
		SET @Emp_ID = NULL
		
	IF @Desig_ID = 0
		SET @Desig_ID = NULL
		
	
	CREATE TABLE #Emp_Cons 
	(      
		Emp_ID NUMERIC,     
		Branch_ID NUMERIC,
		Increment_ID NUMERIC    
	)   
	 
	EXEC SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,0,0,'','','','',0,0,0,'0',0,0

	
	
	--DEclare @For_date Datetime
	--Declare @Row_id	NUMERIC(18,0)
	--Declare @New_To_Date Datetime
	--Declare @Is_Cancel_Holiday_WO_HO_same_day tinyint --Added By nilesh on 01122015(For Cancel Holiday When WO/HO on Same Day
 --   SET @Is_Cancel_Holiday_WO_HO_same_day = 0
	
	--Declare #ATT_PERIOD  table
	--  (
	--	For_Date	datetime,
	--	Row_ID		NUMERIC
	--  )

	 
	-- Declare @Date_Diff NUMERIC 
	 
	-- SET @Date_Diff = datediff(d,@From_Date,@to_DAte) + 1 
	-- SET @New_To_Date = @To_Date
	  
	--SET @For_Date = @From_Date
	--SET @Row_ID = 1
	--While @For_Date <= @New_To_Date
	--	begin
			
	--		insert into #ATT_PERIOD 
	--		select @For_Date ,@Row_ID
	--		SET @Row_ID =@Row_ID + 1
	--		SET @for_Date = dateadd(d,1,@for_date)
	--	end
		
	CREATE TABLE	#ATT_PERIOD
	(
		For_Date	datetime,
		Row_ID		numeric
	)
	CREATE UNIQUE CLUSTERED INDEX IX_ATT_PERIOD ON #ATT_PERIOD(FOR_DATE)

	INSERT INTO #ATT_PERIOD
	SELECT	DATEADD(D, ROW_ID, @From_Date) AS FOR_DATE, ROW_ID
	FROM	(SELECT (ROW_NUMBER() OVER(ORDER BY OBJECT_ID) - 1) ROW_ID
			 FROM	SYS.objects O) T 
	WHERE	DATEADD(D, ROW_ID, @From_Date) <= @To_Date

		 	
	
	CREATE TABLE #ROSTER_DATE 
	(
		Row_ID	NUMERIC(18,0),
		Emp_id	NUMERIC(18,0),
		Cmp_id	NUMERIC(18,0),
		Branch_ID	NUMERIC(18,0) default 0,
		Alpha_emp_code	nvarchar(50)	NULL,
		Emp_Name_full	nvarchar(200)	NULL,
		For_Date	Datetime			NULL,
		Shift_ID	NUMERIC(18,0)	default 0,
		Shift_Time	nvarchar(200)	default '-',
		Shift_WO	nvarchar(2)		default ''			
	)
		
	INSERT	INTO #ROSTER_DATE (Row_ID,Emp_ID,Cmp_ID,Alpha_emp_code,Emp_Name_full,For_Date)
	SELECT 	Row_ID,Emp_ID ,@Cmp_ID, NULL,NULL,For_Date 
	FROM	#ATT_PERIOD cross join #Emp_Cons
	
	
	UPDATE	#ROSTER_DATE
	SET		Alpha_emp_code = E.Alpha_Emp_Code,
			Emp_Name_full = Emp_Full_Name,
			Branch_ID = EC.Branch_ID
	FROM	T0080_EMP_MASTER E 
			INNER JOIN #Emp_Cons EC ON E.Emp_ID=EC.Emp_ID
			INNER JOIN #ROSTER_DATE B ON  E.Emp_ID = B.Emp_ID AND B.Cmp_id  = E.Cmp_ID
			
				
	--IF @Branch_ID is NULL
	--	Begin
	--		Select @Branch_ID = Branch_ID From #ROSTER_DATE where Emp_id = @Emp_ID
	--	End
		
	--select @Is_Cancel_Holiday_WO_HO_same_day = Is_Cancel_Holiday_WO_HO_same_day
	--from T0040_GENERAL_SETTING where cmp_ID = @cmp_ID and Branch_ID = @Branch_ID    
	--and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING where For_Date <= @To_Date and Branch_ID = @Branch_ID and Cmp_ID = @Cmp_ID)
				
	----Start-----------Shift Roster---------------
	
	--Add by Nimesh 27 May, 2015
	--This sp retrieves the Shift Rotation as per given employee id and effective date.
	--it will fetch all employee's shift rotation detail IF employee id is not specified.
	IF @Constraint = '' AND @Emp_ID > 0
		SET @Constraint = CAST(@EMP_ID AS VARCHAR(10));
	IF (OBJECT_ID('tempdb..#Rotation') IS NULL)
		Create Table #Rotation (R_EmpID NUMERIC(18,0), R_DayName varchar(25), R_ShiftID NUMERIC(18,0), R_Effective_Date DateTime);
	--The #Rotation table gets re-created in dbo.P0050_UNPIVOT_EMP_ROTATION stored procedure
	Exec dbo.P0050_UNPIVOT_EMP_ROTATION @Cmp_ID, NULL, @To_Date, @Constraint
		
	
	
	Declare @For_date_Curr Datetime
	Declare @branch_id_cur NUMERIC(18,0)
		
		
	DECLARE curRoster CURSOR FOR
	SELECT For_Date From #ROSTER_DATE
	
	Open curRoster
	FETCH NEXT FROM curRoster INTO @For_date_Curr
	WHILE @@FETCH_STATUS = 0
		BEGIN
			/*
			  UPDATE #ROSTER_DATE        
			  SET Shift_ID   = Q1.Shift_ID   ,Shift_WO = 'S'      
			  FROM #ROSTER_DATE d inner Join        
				 (select q.Shift_ID ,q.Emp_ID,isNULL(shift_type,0) shift_type ,q.For_Date from T0100_Emp_Shift_Detail sd inner join        
				 (select for_Date ,Emp_Id,Shift_ID   from T0100_Emp_Shift_Detail    as esdsub       
				 where Cmp_Id =@Cmp_ID and isNULL(shift_type,0)  = 0 and for_Date = (select max(for_Date) from T0100_Emp_Shift_Detail where emp_id = esdsub.emp_id and Cmp_Id =@Cmp_ID and isNULL(shift_type,0)  = 0 and For_Date <= @For_date_Curr ) )q on sd.Emp_ID =q.Emp_ID and sd.For_Date =q.For_Date)q1  on d.emp_ID = q1.emp_ID         
			  WHERE D.For_Date = @For_date_Curr     
			    
			                                 
			  UPDATE #ROSTER_DATE        
			  SET Shift_ID   = Q1.Shift_ID ,Shift_WO = 'S'
			  FROM #ROSTER_DATE d inner Join        
				(select q.Shift_ID ,q.Emp_ID,isNULL(shift_type,0) shift_type,q.For_Date from T0100_Emp_Shift_Detail   sd inner join        
				(select for_Date ,Emp_Id,Shift_ID   from T0100_Emp_Shift_Detail          as esdsub   
				 where Cmp_Id =@Cmp_ID and isNULL(shift_type,0)  = 1 and for_Date = (select max(for_Date) from T0100_Emp_Shift_Detail where  emp_id = esdsub.emp_id and Cmp_Id =@Cmp_ID and  isNULL(shift_type,0)  = 1 and For_Date <= @For_date_Curr ) )q on sd.Emp_ID =q.Emp_ID and sd.For_Date =q.For_Date)q1  on d.emp_ID = q1.emp_ID         
			  WHERE D.For_Date = @For_date_Curr 
			*/
			
			--Modified by Nimesh 20 May 2015
			--Updating default shift info From Shift Detail
			UPDATE	#ROSTER_DATE 
			SET		Shift_ID = Shf.Shift_ID,
					Shift_WO = 'S'
			FROM	#ROSTER_DATE D 
					INNER JOIN (SELECT	ESD.Shift_ID, ESD.Emp_ID, ESD.Shift_Type
								FROM	T0100_EMP_SHIFT_DETAIL ESD WITH (NOLOCK)
										INNER JOIN (SELECT	MAX(For_Date) AS For_Date,Emp_ID 
													FROM	T0100_EMP_SHIFT_DETAIL WITH (NOLOCK) 
													WHERE	Cmp_ID = ISNULL(@Cmp_ID,Cmp_ID) AND For_Date <= @For_date_Curr and isNULL(Shift_Type,0)=0 
													GROUP BY Emp_ID) S ON ESD.Emp_ID = S.Emp_ID AND ESD.For_Date=S.For_Date
								) SHF ON SHF.Emp_ID = D.EMP_ID 
			WHERE	D.For_Date=@For_date_Curr
			
		    
			--Updating Shift ID From Rotation
			UPDATE	#ROSTER_DATE 
			SET		Shift_ID=SM.Shift_ID, Shift_WO='S'
			FROM	#Rotation R 
					INNER JOIN T0040_SHIFT_MASTER SM ON R.R_ShiftID=SM.Shift_ID					
					INNER JOIN (SELECT	MAX(R_Effective_Date) AS R_Effective_Date, R_EmpID
								FROM	#Rotation R1 
								WHERE	R_Effective_Date<=@For_date_Curr
								GROUP BY R_EmpID) R1 ON R1.R_Effective_Date=R.R_Effective_Date AND R1.R_EmpID=R.R_EmpID
			WHERE	SM.Cmp_ID=@Cmp_ID AND R.R_DayName = 'Day' + CAST(DATEPART(d, @For_date_Curr) As Varchar) 
					AND Emp_Id=R.R_EmpID AND For_Date=@For_date_Curr
						--AND R.R_Effective_Date=(SELECT MAX(R_Effective_Date)
						--FROM #Rotation R1 WHERE R1.R_EmpID=Emp_Id AND 
						--	 R_Effective_Date<=@For_date_Curr) 
					
					
			
			--Updating Shift ID from Employee Shift Detail where ForDate=@TempDate ANd Shift_Type=0 
			--And Rotation should be assigned to that particular employee
			UPDATE	D 
			SET		SHIFT_ID=ESD.SHIFT_ID, Shift_WO = 'S'
			FROM	#ROSTER_DATE D 
					INNER JOIN (SELECT	ESD.Shift_ID, ESD.Emp_ID, ESD.Shift_Type,esd.For_Date
								FROM	T0100_EMP_SHIFT_DETAIL ESD WITH (NOLOCK)
								WHERE	Cmp_ID = ISNULL(@Cmp_ID,Cmp_ID) AND For_Date = @For_date_Curr
								) ESD ON D.Emp_Id=ESD.Emp_ID AND D.For_date=ESD.For_Date				
					
			WHERE	EXISTS (Select	1 FROM #Rotation R
							WHERE	R_DayName = 'Day' + CAST(DATEPART(d, @For_date_Curr) As Varchar) AND R_Effective_Date<=@For_date_Curr
									AND R.R_EmpID=D.Emp_ID) 
					AND D.For_date=@For_date_Curr
					
				

			--Updating Shift ID from Employee Shift Detail where ForDate=@TempDate ANd Shift_Type=1 
			--And Rotation should not be assigned to that particular employee
			UPDATE	#ROSTER_DATE 
			SET		SHIFT_ID=ESD.SHIFT_ID, Shift_WO = 'S'
			FROM	#ROSTER_DATE D 
					INNER JOIN (SELECT	ESD.Shift_ID, ESD.Emp_ID, ESD.Shift_Type, ESD.For_Date
								FROM	T0100_EMP_SHIFT_DETAIL ESD WITH (NOLOCK)
								WHERE	Cmp_ID = ISNULL(@Cmp_ID,Cmp_ID) AND For_Date = @For_date_Curr) ESD ON D.Emp_Id=ESD.Emp_ID AND D.For_date=ESD.For_Date				
			WHERE	IsNULL(ESD.Shift_Type,0)=1 AND D.For_date=@For_date_Curr
					AND NOT EXISTS (Select	1 FROM #Rotation R
									WHERE	R_DayName = 'Day' + CAST(DATEPART(d, @For_date_Curr) As Varchar) 
											AND R_Effective_Date<=@For_date_Curr AND ESD.Emp_ID=R.R_EmpID) 
					
					
			--select ESD.SHIFT_ID, Shift_WO = 'S'
			--FROM	#ROSTER_DATE D INNER JOIN (SELECT esd.Shift_ID, esd.Emp_ID, esd.Shift_Type,esd.For_Date
			--		FROM T0100_EMP_SHIFT_DETAIL esd WHERE Cmp_ID = ISNULL(@Cmp_ID,Cmp_ID) AND For_Date = @For_date_Curr) ESD ON
			--		D.Emp_Id=ESD.Emp_ID AND D.For_date=ESD.For_Date				
			--WHERE	IsNULL(ESD.Shift_Type,0)=1 AND ESD.Emp_ID NOT IN (Select R.R_EmpID FROM #Rotation R
			--			WHERE R_DayName = 'Day' + CAST(DATEPART(d, @For_date_Curr) As Varchar) AND R_Effective_Date<=@For_date_Curr
			--			GROUP BY R.R_EmpID) 
			--		AND D.For_date=@For_date_Curr		
					
					
					
			--End Nimesh			
			  
			 ----Holiday
			UPDATE	D			 ----Optional Holiday  
			SET		Shift_WO = 'H'
			FROM	#ROSTER_DATE D 
					INNER JOIN (SELECT	OHAPR.Emp_ID,HM.Hday_Name,OHAPR.Op_Holiday_Apr_Date,HM.H_From_Date,HM.H_To_Date,OHAPR.Op_Holiday_Apr_Status,
										Case when OHAPR.Op_Holiday_Apr_Status = 'A' then 'Approved' When OHAPR.Op_Holiday_Apr_Status = 'R' then 'Rejected' end as Apr_Status
								FROM	T0120_Op_Holiday_Approval OHAPR WITH (NOLOCK)
										INNER JOIN T0100_OP_Holiday_Application OHAPP WITH (NOLOCK) ON OHAPR.Op_Holiday_App_ID = OHAPP.Op_Holiday_App_ID 
										INNER JOIN T0040_HOLIDAY_MASTER HM WITH (NOLOCK) ON HM.Hday_ID = OHAPR.HDay_ID 
								WHERE	OHAPR.Cmp_ID = @Cmp_ID And OHAPR.Emp_ID =@Emp_ID 
										AND (HM.H_From_Date BETWEEN @From_Date AND @To_Date) AND OHAPR.Op_Holiday_Apr_Status = 'A'
								)Q1 ON D.Emp_id = Q1.Emp_ID AND (D.For_Date = H_From_Date OR d.For_Date = H_To_Date)
			WHERE	D.For_Date = @For_date_Curr And D.Emp_id = @Emp_ID
			
			---- Holiday
			  

			  
			FETCH NEXT FROM curRoster INTO @For_date_Curr	
		END
	CLOSE curRoster
	DEALLOCATE curRoster	
	----End-----------Shift Roster--------------------
	
	----Start-----------Week OFF Roster---------------
	
	--Declare cur_emp_roster cursor for 
	--	select @from_date,Branch_ID from #ROSTER_DATE
	--open cur_emp_roster
	--fetch next from cur_emp_roster into @For_date_Curr ,@branch_id_cur 
	--while @@fetch_Status = 0
	--	begin 
	
	--Declare @StrWeekoff_Date nvarchar(Max)
	--Declare @varCancelWeekOff_Date nvarchar(Max)
	--Declare @Weekoff_Days NUMERIC(12,2)    
	--Declare @Cancel_Weekoff NUMERIC(12,2)    
		
	--SET @StrWeekoff_Date = ''
	--SET @Weekoff_Days = 0
	--SET @Cancel_Weekoff = 0
	--SET @varCancelWeekOff_Date = ''
		
	--Declare @StrHoliday_Date nvarchar(Max)
	--Declare @Holiday_days NUMERIC(12,2)
	--Declare @Cancel_Holiday NUMERIC(12,2)
		
	--SET @StrHoliday_Date = ''
	--SET @Holiday_days = 0
	--SET @Cancel_Weekoff = 0
		
	--	IF @Is_Cancel_Holiday_WO_HO_same_day = 1
	--		Begin
	--			Exec SP_EMP_WEEKOFF_DATE_GET @Emp_ID,@Cmp_ID,@From_Date,@To_Date,NULL,NULL,9,'',@StrWeekoff_Date output,@Weekoff_Days output ,@Cancel_Weekoff output ,0,0,0,@varCancelWeekOff_Date output   
	--			Exec SP_EMP_HOLIDAY_DATE_GET @Emp_ID,@Cmp_ID,@From_Date,@To_Date,NULL,NULL,9,@StrHoliday_Date output,@Holiday_days output,@Cancel_Holiday output,0,0,@StrWeekoff_Date,1
	--		End
	--	Else
	--		Begin
	--			Exec SP_EMP_HOLIDAY_DATE_GET @Emp_ID,@Cmp_ID,@From_Date,@To_Date,NULL,NULL,9,@StrHoliday_Date output,@Holiday_days output,@Cancel_Holiday output,0,0,@StrWeekoff_Date,1
	--			Exec SP_EMP_WEEKOFF_DATE_GET @Emp_ID,@Cmp_ID,@From_Date,@To_Date,NULL,NULL,9,'',@StrWeekoff_Date output,@Weekoff_Days output ,@Cancel_Weekoff output ,0,0,0,@varCancelWeekOff_Date output
	--		End
		
				
		--SELECT @StrWeekoff_Date,@varCancelWeekOff_Date
		 
		--SET @StrWeekoff_Date = @StrWeekoff_Date + @varCancelWeekOff_Date
			 
			  -- Comment by nilesh Patel on 01122015 -Start
					--declare @W_date datetime
				
					--Declare cur_W_roster cursor for 			 
					--	select data from dbo.Split(@StrWeekoff_Date,';')
					--open cur_W_roster
					--FETCH NEXT FROM cur_W_roster INTO @W_date
					--while @@fetch_Status = 0
					--		BEGIN 
							
					--			update #ROSTER_DATE SET Shift_WO = 'W'
					--			WHERE For_Date = @W_date AND Emp_id = @Emp_ID
								
					--			FETCH NEXT FROM cur_W_roster into @W_date
					--		END 
					--close cur_W_roster
					--Deallocate cur_W_roster
					
			 -- Comment by nilesh Patel on 01122015 -End					
				
	
					
	--		fetch next from cur_emp_roster into @For_date_Curr ,@branch_id_cur 
	--	end 
	--close cur_emp_roster
	--Deallocate cur_emp_roster
	
	----End-----------Week OFF Roster-----------------
	
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
	
	CREATE table #EMP_HW_CONS
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
		)
	
	--Comment by Jaina 02-02-2018 (After Discuss with Nimeshbhai)
	EXEC SP_GET_HW_ALL @CONSTRAINT=@CONSTRAINT,@CMP_ID=@Cmp_ID, @FROM_DATE=@FROM_DATE, @TO_DATE=@TO_DATE, @All_Weekoff = 1, @Exec_Mode=0
	--exec SP_EMP_HOLIDAY_WEEKOFF_ALL @Cmp_ID=@Cmp_ID,@FROM_DATE=@FROM_DATE, @TO_DATE=@TO_DATE,@All_Weekoff = 0,@Constraint =''  --Added by Jaina 02-02-2018
	
	--Added by Jaina 02-02-2018
	alter table #ROSTER_DATE add Fix_Weekoff Bit 
	--ronak--
	
	Select Compoff_App_ID,Alpha_Emp_Code,Emp_Full_Name,Branch_Name,Desig_Name as[Designation],Extra_Work_Date,Extra_Work_Hours
	,Extra_Work_Reason,case when Application_Status='P' then 'Pending'when Application_Status='A' 
	then 'Approve' else 'Reject' end Application_Status 
	into #temp
	 from V0120_COMPOFFAPPROVE_DETAIL 
	where Cmp_ID=@Cmp_ID and Application_Status = 'A' AND Emp_ID=@Emp_ID
	

	UPDATE	#ROSTER_DATE
	SET		Shift_WO = 'W' 
	FROM	#ROSTER_DATE Att INNER JOIN #EMP_WEEKOFF W ON Att.For_date = W.For_Date AND ATT.Emp_id = W.Emp_ID
		
	UPDATE	#ROSTER_DATE 
	SET		Shift_WO = 'C' 
	FROM	#ROSTER_DATE Att 
	INNER JOIN #temp T on Att.Alpha_emp_code =t.Alpha_Emp_Code  and Att.For_date = t.Extra_Work_Date 
	
	
	--Added by Jaina 02-02-2018
	UPDATE	#ROSTER_DATE
	SET		Fix_Weekoff = 1 
	FROM	#ROSTER_DATE Att INNER JOIN #EMP_WEEKOFF W ON Att.For_date = W.For_Date AND ATT.Emp_id = W.Emp_ID
	where Shift_WO = 'W' and W.Row_ID <> 0
	
	
	UPDATE	#ROSTER_DATE
	SET		Shift_WO = 'HO' 
	FROM	#ROSTER_DATE Att INNER JOIN #EMP_HOLIDAY H ON Att.For_date = H.For_Date AND ATT.Emp_id = H.Emp_ID

		
	SELECT	Row_ID,Emp_id,RD.Cmp_id	,Alpha_emp_code	,Emp_Name_full,For_Date,RD.Shift_ID,
			(Shift_St_Time +'-'+Shift_End_Time ) AS Shift_Time	,Shift_WO,Fix_Weekoff
	FROM	#ROSTER_DATE RD 
				LEFT OUTER JOIN T0040_SHIFT_MASTER SM WITH (NOLOCK) ON RD.Shift_ID = SM.Shift_ID
		
RETURN




