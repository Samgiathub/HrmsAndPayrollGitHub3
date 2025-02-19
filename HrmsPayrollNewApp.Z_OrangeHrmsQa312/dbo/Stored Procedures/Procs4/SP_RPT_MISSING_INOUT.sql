
---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_MISSING_INOUT]      
  @Cmp_ID  numeric      
 ,@From_Date  datetime      
 ,@To_Date  datetime       
 ,@Branch_ID  numeric   = 0      
 ,@Cat_ID  numeric  = 0      
 ,@Grd_ID  numeric = 0      
 ,@Type_ID  numeric  = 0      
 ,@Dept_ID  numeric  = 0      
 ,@Desig_ID  numeric = 0      
 ,@Emp_ID  numeric  = 0      
 ,@Constraint varchar(Max) = ''   
 ,@Report_Type varchar(20) = 'ALL'	--Get Filter wise Report - Ankit 09062015
 ,@Export_Type numeric=0 --Added by Sumit For getting Single punch record 21072016
 
   
AS      
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
  
	IF @Branch_ID = 0      
		SET @Branch_ID = null      
	IF @Cat_ID = 0      
		SET @Cat_ID = null      
	 
	IF @Type_ID = 0      
		SET @Type_ID = null      
	IF @Dept_ID = 0      
		SET @Dept_ID = null      
	IF @Grd_ID = 0      
		SET @Grd_ID = null      
	IF @Emp_ID = 0      
		SET @Emp_ID = null      

	If @Desig_ID = 0      
		SET @Desig_ID = null      
    
	IF @Report_Type = '' OR @Report_Type IS NULL
		SET @Report_Type = 'ALL'
   
	CREATE TABLE #Emp_Cons -- Ankit 08092014 for Same Date Increment
	(      
		Emp_ID numeric ,     
		Branch_ID numeric,
		Increment_ID numeric    
	)  
	 
	EXEC SP_RPT_FILL_EMP_CONS  @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID ,@Emp_ID ,@constraint --,@Sal_Type ,@Salary_Cycle_id ,@Segment_Id ,@Vertical_Id ,@SubVertical_Id ,@SubBranch_Id 


	Create table #Emp_Shift_Missing_Inout
	(
		Emp_Id			NUMERIC(18,0),
		For_date		DATETIME,		
		Shift_St_Time	DATETIME,
		Shift_End_Time	DATETIME,
		Is_Night_Shift	TINYINT,
		Min_Shift_Time	DATETIME,
		Max_Shift_Time	DATETIME,
		Min_In_Time		DATETIME,
		Half_Leave_flag TINYINT		Default(0),
		Max_In_Time		DATETIME, --Added By Ramiz on 04/09/2015
		Shift_ID		NUMERIC
		,Min_out_time		DATETIME  -- Added by rohit for inpunch missing case in cera on 21072016
		,Max_out_time		DATETIME
	)
	CREATE NONCLUSTERED INDEX IX_Emp_Shift_EMPID_FORDATE ON #Emp_Shift_Missing_Inout (EMP_ID, FOR_DATE) INCLUDE (SHIFT_ID,Shift_St_Time,Shift_End_Time);
	
	CREATE table #Data      
	(     
		Emp_Id     numeric ,     
		For_date   datetime,    
		Duration_in_sec  numeric,    
		Shift_ID   numeric ,    
		Shift_Type   numeric ,    
		Emp_OT    numeric ,    
		Emp_OT_min_Limit numeric,    
		Emp_OT_max_Limit numeric,    
		P_days    numeric(12,2) default 0,    
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
		Shift_End_Time datetime,			--Ankit 16112013
		OT_End_Time numeric default 0,	--Ankit 16112013
		Working_Hrs_St_Time tinyint default 0, --Hardik 14/02/2014
		Working_Hrs_End_Time tinyint default 0, --Hardik 14/02/2014
		GatePass_Deduct_Days numeric(18,2) default 0 -- Add by Gadriwala Muslim 05012014
	)  
	CREATE NONCLUSTERED INDEX IX_Data ON dbo.#data(Emp_Id,Shift_ID,For_Date) 
	
	EXEC dbo.P_GET_EMP_INOUT @cmp_id, @FROM_DATE, @TO_DATE	   --Added by Jaina 01-02-2017 end
	
	--select 333,* from #data

			
	Insert into #Emp_Shift_Missing_Inout(Emp_Id,For_date,Min_In_Time,MAX_IN_TIME,Min_out_time,Max_out_time)
	SELECT D1.Emp_ID,D1.For_Date,T.Min_In_Time,T.MAX_IN_TIME ,T.Min_out_time,T.Max_out_time
	From	#Emp_Cons E inner JOIN #Data D1 on D1.Emp_Id=E.Emp_ID
			INNER JOIN (
							SELECT	D.EMP_ID, MIN(D.IN_TIME) AS Min_In_Time,MAX(D.IN_TIME) AS MAX_IN_TIME, MIN(D.Out_Time) AS Min_Out_time,MAX(D.Out_Time) AS MAX_Out_time, D.FOR_DATE
							FROM	#Emp_Cons E 
									INNER JOIN #Data D ON D.Emp_Id = E.Emp_ID	--Added by Jaina 01-02-2017		
							WHERE	D.For_Date >= @From_Date and D.For_Date <= @To_Date
							GROUP	BY D.EMP_ID, D.For_Date
						) T ON D1.EMP_ID=T.EMP_ID AND D1.FOR_DATE=T.FOR_DATE
				
	WHERE	D1.For_Date >= @From_Date and D1.For_Date <= @To_Date
	Group BY D1.Emp_ID,D1.For_Date,T.Min_In_Time,T.MAX_IN_TIME,T.Min_Out_time,T.MAX_Out_time

	--select * from #Data
	--select * from #Emp_Shift_Missing_Inout
	
	--SELECT EIR.Emp_ID,EIR.For_Date,T.Min_In_Time,T.MAX_IN_TIME ,T.Min_out_time,T.Max_out_time
	--From	T0150_EMP_INOUT_RECORD EIR INNER JOIN #Emp_Cons E ON EIR.Emp_ID=E.Emp_ID			
	--		INNER JOIN (
	--						SELECT	EIR1.EMP_ID, MIN(D.IN_TIME) AS Min_In_Time,MAX(D.IN_TIME) AS MAX_IN_TIME, MIN(D.Out_Time) AS Min_Out_time,MAX(D.Out_Time) AS MAX_Out_time, D.FOR_DATE
	--						FROM	T0150_EMP_INOUT_RECORD EIR1 INNER JOIN #Emp_Cons E ON EIR1.Emp_ID=E.Emp_ID
	--								INNER JOIN #Data D ON D.Emp_Id = E.Emp_ID	--Added by Jaina 01-02-2017		
	--						WHERE	EIR1.For_Date >= @From_Date and EIR1.For_Date <= @To_Date
	--						GROUP	BY EIR1.EMP_ID, D.For_Date
	--					) T ON EIR.EMP_ID=T.EMP_ID AND EIR.FOR_DATE=T.FOR_DATE
				
	--WHERE	EIR.For_Date >= @From_Date and EIR.For_Date <= @To_Date
	--Group BY EIR.Emp_ID,EIR.For_Date,T.Min_In_Time,T.MAX_IN_TIME,T.Min_Out_time,T.MAX_Out_time

	
	/*COMMENTED BY NIMESH ON 18-JAN-2016 (NO NEED TO USE CURSOR TO INSERT RECORD IN A TABLE SIMPLY)
	declare @cur_Emp_ID numeric(10,0)

	Declare cur_Emp cursor for Select EMP_ID From #Emp_Cons
	open cur_Emp 
	fetch next from cur_Emp into @cur_Emp_ID
	while @@fetch_Status = 0
		Begin
		
			Insert into #Emp_Shift_Missing_Inout(Emp_Id,For_date)
				 SELECT Emp_ID,For_Date From T0150_EMP_INOUT_RECORD where Emp_ID = @cur_Emp_ID and For_Date >= @From_Date and For_Date <= @To_Date
				 Group BY Emp_ID,For_Date
			fetch next from cur_Emp into @cur_Emp_ID
		End 
	close cur_Emp
	deallocate cur_Emp	
	*/
 
	Declare @Cur_Shift_Emp_ID Numeric(18,0)
	declare @Cur_For_date datetime
	Declare @Cur_Date_of_Birth Datetime



	Declare @tmp_Cur_Shift_St_time varchar(10)      --added by Nimesh 24092015
	Declare @tmp_Cur_Shift_End_time varchar(10)	--added by Nimesh 24092015
	Declare @Cur_Shift_St_time Datetime
	Declare @Cur_Shift_End_time Datetime
	Declare @Cur_Is_Night_Shift tinyint

	Declare @Cur_Min_In_Time Datetime
	Declare @cur_Max_In_Time Datetime
 
	
	--Add by Nimesh 18-Jan-2016
	--This sp retrieves the Shift Rotation as per given employee id and effective date.
	--it will fetch all employee's shift rotation detail if employee id is not specified.
	IF (OBJECT_ID('tempdb..#Rotation') IS NULL)
		CREATE TABLE #Rotation (R_EmpID numeric(18,0), R_DayName varchar(25), R_ShiftID numeric(18,0), R_Effective_Date DateTime);
	--The #Rotation table gets re-created in dbo.P0050_UNPIVOT_EMP_ROTATION stored procedure
	SET @Constraint = NULL;
	SELECT	@Constraint = COALESCE(@Constraint + '#', '') + CAST(EMP_ID AS VARCHAR(10))
	FROM	#Emp_Shift_Missing_Inout E
	GROUP BY Emp_Id
	
	IF (ISNULL(@Constraint,'') <> '')
		Exec dbo.P0050_UNPIVOT_EMP_ROTATION @Cmp_ID, NULL, @To_Date, @Constraint
		
	DECLARE @HAS_ROTATION BIT;
	SET @HAS_ROTATION = 0;
	IF EXISTS(SELECT 1 FROM #Rotation)
		SET @HAS_ROTATION = 1;
 
	SET @Cur_For_date = @From_Date
	WHILE @Cur_For_date <= @TO_DATE
		BEGIN
			--TAKING DEFAULT SHIFT ID
			UPDATE	#Emp_Shift_Missing_Inout
			SET		Shift_ID=ESD.Shift_ID
			FROM	#Emp_Shift_Missing_Inout ES INNER JOIN T0100_EMP_SHIFT_DETAIL ESD ON ES.EMP_ID=ESD.EMP_ID
					INNER JOIN (SELECT	MAX(FOR_DATE) AS FOR_DATE, EMP_ID 
								FROM	T0100_EMP_SHIFT_DETAIL ESD1 WITH (NOLOCK)
								WHERE	ESD1.For_Date <= @Cur_For_date AND Cmp_ID=@Cmp_ID
								AND ESD1.Shift_Type = 0	--Added By Ramiz on 20/01/2018 as Temporary shift was continuing on next day also.
								GROUP BY EMP_ID
								) ESD1 ON ESD.Emp_ID=ESD1.Emp_ID AND ESD.For_Date=ESD1.FOR_DATE
			WHERE	ES.For_date=@Cur_For_date
			
			--UPDATING SHIFT ID ACCORDING TO GIVEN SHIFT ROTATION
			IF (@HAS_ROTATION = 1)
				UPDATE	#Emp_Shift_Missing_Inout 
				SET		SHIFT_ID=R_ShiftID
				FROM	#Rotation R 
				WHERE	R.R_EmpID=#Emp_Shift_Missing_Inout.EMP_ID AND R.R_DayName = 'Day' + CAST(DATEPART(d, @Cur_For_date) As Varchar)
						AND R.R_Effective_Date=(
													SELECT	MAX(R_Effective_Date) FROM #Rotation 
													WHERE	R_Effective_Date <=@Cur_For_date
												)
						AND #Emp_Shift_Missing_Inout.For_date = @Cur_For_date
			
			--IF USER HAS ASSIGNED SHIFT ON THAT PARTICULAR DAY THEN IT SHOULD BE TAKEN FIRST
			UPDATE	#Emp_Shift_Missing_Inout SET SHIFT_ID = Shf.Shift_ID
			FROM	#Emp_Shift_Missing_Inout  p 
					INNER JOIN (
								SELECT	ESD.Shift_ID, ESD.Emp_ID 
								FROM	T0100_EMP_SHIFT_DETAIL ESD WITH (NOLOCK)
								WHERE	EXISTS (
											Select	R.R_EmpID FROM #Rotation R
											WHERE	R_DayName = 'Day' + CAST(DATEPART(d, @Cur_For_date) As Varchar) 													
													AND R.R_EmpID=ESD.Emp_ID
											GROUP BY R.R_EmpID
										)
										AND ESD.For_Date=@Cur_For_date
								) Shf ON Shf.Emp_ID = p.EMP_ID
			WHERE	P.FOR_DATE = @Cur_For_date
						
			--if the rotation is not assigned the only those shift should be assigned which shift_type is 1
			UPDATE	#Emp_Shift_Missing_Inout SET SHIFT_ID = Shf.Shift_ID
			FROM	#Emp_Shift_Missing_Inout  p 
					INNER JOIN (
								SELECT	ESD.Shift_ID, ESD.Emp_ID 
								FROM	T0100_EMP_SHIFT_DETAIL ESD WITH (NOLOCK) 
								WHERE	NOT EXISTS (
											Select	R.R_EmpID FROM #Rotation R
											WHERE	R_DayName = 'Day' + CAST(DATEPART(d, @Cur_For_date) As Varchar) 													
													AND R.R_EmpID=ESD.Emp_ID
											GROUP BY R.R_EmpID
										)
										AND ESD.For_Date=@Cur_For_date AND IsNull(ESD.Shift_Type,0)=1
								) Shf ON Shf.Emp_ID = p.EMP_ID
			WHERE	P.FOR_DATE = @Cur_For_date
			
			SET @Cur_For_date = DATEADD(d, 1, @Cur_For_date)
		END
	
		
	Update  #Emp_Shift_Missing_Inout
	SET		Shift_st_Time = DATEADD(D,Mid_Night_Shift, SM_Shift_St_time), 
			Shift_End_Time = SM_Shift_End_time,
			Is_Night_Shift = SM_Is_Night_Shift,
			Min_Shift_Time = DATEADD(ss,-3600,DATEADD(D,Mid_Night_Shift, SM_Shift_St_time)),
			Max_Shift_Time = DATEADD(ss,7140,DATEADD(D,Mid_Night_Shift, SM_Shift_St_time))
	FROM	#Emp_Shift_Missing_Inout ES INNER JOIN  ( 
				SELECT	EMP_ID, For_date, 
						CAST(CONVERT(VARCHAR(12), For_date, 113) + SM.Shift_St_time AS DATETIME) AS SM_Shift_St_time, 
						CAST(CONVERT(VARCHAR(12), For_date, 113) + SM.Shift_End_time AS DATETIME) AS SM_Shift_End_time,
						(CASE WHEN Cast(SM.Shift_St_time As DATETIME) > Cast(SM.Shift_End_time As DATETIME) THEN 1 ELSE 0 END) As SM_Is_Night_Shift,
						(Case When SM.Shift_St_Time = '00:00' Then 1 Else 0 END) As Mid_Night_Shift
				FROM	#Emp_Shift_Missing_Inout ES INNER JOIN T0040_SHIFT_MASTER SM WITH (NOLOCK) ON ES.SHIFT_ID=SM.SHIFT_ID
						
			) T ON ES.Emp_Id=T.Emp_Id AND ES.For_date=T.For_date
		
	
										
	/*Commented by Nimesh on 18-Jan-2016 (Optimized code for executing loop for only seledate date period (ie. from_date to to_date)
	  Also removed SP_CURR_T0100_EMP_SHIFT_GET stored procedure and placed qqueries to get value from shift rotation and detail table.
	
	Declare Cur_Shift_Emp Cursor For 
	Select Emp_Id,For_date From #Emp_Shift_Missing_Inout
	Open Cur_Shift_Emp
	Fetch Next From Cur_Shift_Emp into @Cur_Shift_Emp_ID,@Cur_For_date
	While @@Fetch_Status = 0
		Begin
			EXEC dbo.SP_CURR_T0100_EMP_SHIFT_GET @Cur_Shift_Emp_ID,@Cmp_ID,@Cur_For_date,@tmp_Cur_Shift_St_time output ,@tmp_Cur_Shift_End_time output
			
			SET @Cur_Shift_St_time = cast(@tmp_Cur_Shift_St_time as DATETIME)
			SET @Cur_Shift_End_time  = CAST(@tmp_Cur_Shift_End_time as DATETIME)
		    
			IF @Cur_Shift_St_time > @Cur_Shift_End_time
				SET @Cur_Is_Night_Shift = 1
			ELSE
				SET @Cur_Is_Night_Shift = 0
			
			SET @Cur_Min_In_Time = NULL
			SET @cur_Max_In_Time = NULL 
					
			SELECT	@Cur_Min_In_Time = Min(In_time)
			FROM	dbo.T0150_emp_inout_record e 
			WHERE	E.For_Date = @Cur_For_date and E.Emp_ID = @Cur_Shift_Emp_ID
			GROUP BY e.For_Date,e.Emp_ID
			
			SET @Cur_Shift_St_time = CONVERT(VARCHAR(11),CASE WHEN @Cur_Shift_St_time = '00:00' THEN DATEADD(dd,1,@Cur_For_date) ELSE @Cur_For_date END,120) + @Cur_Shift_St_time	 -- Condition added by Hardik 21/12/2015 for 12 AM Shift for Nirma
			SET @Cur_Shift_End_time = CONVERT(VARCHAR(11),@Cur_For_date,120) + @Cur_Shift_End_time
			
			--Added By Ramiz on 04/09/2015
			SELECT	@cur_Max_In_Time = Max(In_time)
			FROM	dbo.T0150_emp_inout_record e 
			WHERE	E.For_Date = @Cur_For_date and E.Emp_ID = @Cur_Shift_Emp_ID
			GROUP BY e.For_Date,e.Emp_ID
			--Ended By Ramiz on 04/09/2015
			
			Update  #Emp_Shift_Missing_Inout
			SET		Shift_st_Time = @Cur_Shift_St_time, 
					Shift_End_Time = @Cur_Shift_End_time ,
					Is_Night_Shift = @Cur_Is_Night_Shift,
					Min_Shift_Time = DATEADD(ss,-3600,@Cur_Shift_St_time),
					--Max_Shift_Time = (Case when DATEADD(ss,7200,@Cur_Shift_St_time) = '1900-01-02 00:00:00.000' THEN DATEADD(ss,7140,@Cur_Shift_St_time) ELSE DATEADD(ss,7200,@Cur_Shift_St_time) END)
					Max_Shift_Time = DATEADD(ss,7140,@Cur_Shift_St_time),
					Min_In_Time = @Cur_Min_In_Time,
					Max_In_Time = @cur_Max_In_Time
			WHERE	Emp_ID = @Cur_Shift_Emp_ID and For_Date = @Cur_For_date
			
			FETCH NEXT FROM Cur_Shift_Emp INTO @Cur_Shift_Emp_ID,@Cur_For_date
		END 
	 CLOSE Cur_Shift_Emp
	 DEALLOCATE Cur_Shift_Emp
	 */
	 	 
	 UPDATE	ES 
	 Set	Half_Leave_flag = 1
	 FROM	#Emp_Shift_Missing_Inout ES INNER JOIN V0120_LEAVE_APPROVAL LP ON ES.Emp_Id = LP.Emp_ID AND ES.For_date = LP.From_Date 
	 WHERE	LP.Leave_Assign_As = 'First Half' and LP.Approval_Status = 'A'
		
	
	 IF @Report_Type = 'ALL'
		BEGIN
			SELECT	* 
			FROM    (	SELECT	EIR.*,E.Emp_Code,E.Alpha_Emp_Code,E.Emp_First_Name,E.Emp_Full_Name as Emp_Full_Name_Only,Dept_Name,Desig_Name,Type_Name,Grd_Name,Branch_Name,Date_of_Join,Gender      
								,BM.Comp_Name,BM.Branch_Address,CM.Cmp_Name,Cm.Cmp_address,E.Emp_Left , BM.BRANCH_ID,dbo.F_Return_HHMM(ES.Shift_St_Time)+' - '+ dbo.F_Return_HHMM(ES.Shift_End_Time) as shift_time
								,VS.Vertical_Name , sv.SubVertical_Name	--Added By Ramiz on 07/08/2015  
						FROM	t0150_emp_inout_record EIR WITH (NOLOCK) 
								INNER JOIN #Emp_Cons EC ON EIR.Emp_ID=EC.Emp_ID					
								inner join T0080_EMP_MASTER E WITH (NOLOCK) on EC.Emp_ID=E.Emp_ID 													
								LEFT JOIN #Emp_Shift_Missing_Inout ES on ES.Max_In_Time = EIR.In_Time and ES.Emp_Id = EIR.Emp_ID					
								inner join T0010_company_master Cm WITH (NOLOCK) on E.Cmp_ID = Cm.Cmp_ID 
								inner join T0095_INCREMENT I_Q WITH (NOLOCK) on EC.Emp_ID = I_Q.Emp_ID and  EC.Increment_ID = I_Q.Increment_ID
								inner join T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID 
								INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID 
								LEFT OUTER JOIN T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID 
								LEFT OUTER JOIN T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id 
								LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id 					
								LEFT OUTER JOIN T0040_Vertical_Segment VS WITH (NOLOCK) on I_Q.Vertical_ID = VS.Vertical_ID 
								LEFT OUTER JOIN T0050_SubVertical SV WITH (NOLOCK) on I_Q.SubVertical_ID = SV.SubVertical_ID
						WHERE	E.Cmp_ID = @Cmp_Id and EIR.Out_Time is not null
								And EIR.For_Date >= @From_Date And EIR.For_Date <= @to_Date
								AND Half_Leave_flag <> 1								
								and (ES.Min_In_Time < ES.Min_Shift_Time or ES.Min_In_Time > ES.Max_Shift_Time) 					
						Union 					
				   
						select	EIR.*,E.Emp_Code,E.Alpha_Emp_Code,E.Emp_First_Name,E.Emp_Full_Name as Emp_Full_Name_Only,Dept_Name,Desig_Name,Type_Name,Grd_Name,Branch_Name,Date_of_Join,Gender      
								,BM.Comp_Name,BM.Branch_Address,CM.Cmp_Name,Cm.Cmp_address,E.Emp_Left , BM.BRANCH_ID ,dbo.F_Return_HHMM(ES.Shift_St_Time)+' - '+ dbo.F_Return_HHMM(ES.Shift_End_Time) as shift_time
								,VS.Vertical_Name , sv.SubVertical_Name	--Added By Ramiz on 07/08/2015    
						FROM	t0150_emp_inout_record EIR WITH (NOLOCK)
								INNER JOIN #Emp_Cons EC ON EIR.Emp_ID=EC.Emp_ID					
								inner join T0080_EMP_MASTER E WITH (NOLOCK) on EC.Emp_ID=E.Emp_ID 													
								LEFT JOIN #Emp_Shift_Missing_Inout ES on ES.Max_In_Time = EIR.In_Time and ES.Emp_Id = EIR.Emp_ID					
								inner join T0010_company_master Cm WITH (NOLOCK) on E.Cmp_ID = Cm.Cmp_ID 
								inner join T0095_INCREMENT I_Q WITH (NOLOCK) on EC.Emp_ID = I_Q.Emp_ID and  EC.Increment_ID = I_Q.Increment_ID
								inner join T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID 
								INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID 
								LEFT OUTER JOIN T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID 
								LEFT OUTER JOIN T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id 
								LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id 					
								LEFT OUTER JOIN T0040_Vertical_Segment VS WITH (NOLOCK) on I_Q.Vertical_ID = VS.Vertical_ID 
								LEFT OUTER JOIN T0050_SubVertical SV WITH (NOLOCK) on I_Q.SubVertical_ID = SV.SubVertical_ID
						WHERE	E.Cmp_ID = @Cmp_Id    and (EIR.Out_Time is null or EIR.in_time is null )
								And EIR.For_Date >= @From_Date And EIR.For_Date <= @to_Date									
					)qry  --change by jimit 
			  ORDER BY CASE When IsNumeric(Alpha_Emp_Code) = 1 then 
								Right(Replicate('0',21) + Alpha_Emp_Code, 20)
							When IsNumeric(Alpha_Emp_Code) = 0 then 
								Left(Alpha_Emp_Code + Replicate('',21), 20)
							Else 
								Alpha_Emp_Code
							End
			 --ORDER BY RIGHT(REPLICATE(N' ', 500) + E.ALPHA_EMP_CODE, 500)*/   
		END	
	ELSE IF @Report_Type = 'Odd Shift' 
		BEGIN
		
		IF (@Export_Type=0)
				Begin
					
								SELECT EIR.*,E.Emp_Code,E.Alpha_Emp_Code,E.Emp_First_Name,E.Emp_Full_Name as Emp_Full_Name_Only,Dept_Name,Desig_Name,Type_Name,Grd_Name,Branch_Name,Date_of_Join,Gender      
									 ,BM.Comp_Name,BM.Branch_Address,CM.Cmp_Name,Cm.Cmp_address,E.Emp_Left , BM.BRANCH_ID,dbo.F_Return_HHMM(ES.Shift_St_Time)+' - '+ dbo.F_Return_HHMM(ES.Shift_End_Time) as shift_time
									 ,VS.Vertical_Name , sv.SubVertical_Name	--Added By Ramiz on 07/08/2015    
								FROM t0150_emp_inout_record EIR WITH (NOLOCK) Inner JOIN #Emp_Shift_Missing_Inout ES on ES.Min_In_Time = EIR.In_Time and ES.Emp_Id = EIR.Emp_ID
										 inner join T0080_EMP_MASTER E WITH (NOLOCK) on EIR.Emp_ID=E.Emp_ID inner join           
										T0010_company_master Cm WITH (NOLOCK) on E.Cmp_ID = Cm.Cmp_ID inner join   
									   ( select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID , Vertical_ID , SubVertical_ID from T0095_Increment I WITH (NOLOCK) inner join       
										( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment  WITH (NOLOCK)  -- Ankit 08092014 for Same Date Increment  
										where Increment_Effective_date <= @To_Date      
										and Cmp_ID = @Cmp_ID      
										group by emp_ID  ) Qry on      
										 I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID  ) I_Q		     
										on E.Emp_ID = I_Q.Emp_ID  inner join      
										 T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN      
										 T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN      
										 T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN      
										 T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id INNER JOIN       
										 T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID LEFT OUTER JOIN
										 T0040_Vertical_Segment VS WITH (NOLOCK) on I_Q.Vertical_ID = VS.Vertical_ID LEFT OUTER JOIN
										 T0050_SubVertical SV WITH (NOLOCK) on I_Q.SubVertical_ID = SV.SubVertical_ID 
								WHERE E.Cmp_ID = @Cmp_Id and EIR.Out_Time is not null
										And EIR.For_Date >= @From_Date And EIR.For_Date <= @to_Date
										AND Half_Leave_flag <> 1	
										And E.Emp_ID in (select Emp_ID From #Emp_Cons) 
										And (ES.Min_In_Time < ES.Min_Shift_Time or ES.Min_In_Time > ES.Max_Shift_Time)
										--And (0 > DATEDIFF(ss, dbo.F_Return_HHMM(ES.Min_Shift_Time),dbo.F_Return_HHMM(ES.Min_In_Time))
										--	or 7140 > (case when Is_Night_Shift = 1 then  
										--				case when DATEDIFF(ss, dbo.F_Return_HHMM(ES.Min_In_Time),dbo.F_Return_HHMM(ES.Max_Shift_Time)) > 0 then 
										--				DATEDIFF(ss, dbo.F_Return_HHMM(ES.Min_In_Time),dbo.F_Return_HHMM(ES.Max_Shift_Time))
										--				else 
										--				24*3600 + DATEDIFF(ss, dbo.F_Return_HHMM(ES.Min_In_Time),dbo.F_Return_HHMM(ES.Max_Shift_Time))
										--				end
										--			  Else
										--				DATEDIFF(ss, dbo.F_Return_HHMM(ES.Min_In_Time),dbo.F_Return_HHMM(ES.Max_Shift_Time))
										--	 End) ) 
								ORDER BY CASE WHEN IsNumeric(Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + Alpha_Emp_Code, 20)
											When IsNumeric(Alpha_Emp_Code) = 0 then Left(Alpha_Emp_Code + Replicate('',21), 20)
										 Else Alpha_Emp_Code 
								End
							
					
				End
		Else
			Begin
				SELECT E.Alpha_Emp_Code as [Employee Code],E.Emp_Full_Name as [Employee Name],Dept_Name as Department,Desig_Name as Designation,Type_Name as [Employee Type],Grd_Name as Grade,Branch_Name as Branch,      
					 --BM.Comp_Name,BM.Branch_Address,CM.Cmp_Name,Cm.Cmp_address,E.Emp_Left , 
					 --BM.BRANCH_ID,
					 dbo.F_Return_HHMM(ES.Shift_St_Time)+' - '+ dbo.F_Return_HHMM(ES.Shift_End_Time) as [Shift Time]
					 ,convert(varchar(12),EIR.For_Date,103) as [For Date],
					 substring(CONVERT(VARCHAR, EIR.In_Time, 108),0,6) AS [In Time],
					 substring(CONVERT(VARCHAR, EIR.Out_Time, 108),0,6) AS [Out Time]
					 --,VS.Vertical_Name , sv.SubVertical_Name	--Added By Ramiz on 07/08/2015    					 
			FROM t0150_emp_inout_record EIR WITH (NOLOCK) Inner JOIN #Emp_Shift_Missing_Inout ES on ES.Min_In_Time = EIR.In_Time and ES.Emp_Id = EIR.Emp_ID
					 inner join T0080_EMP_MASTER E WITH (NOLOCK) on EIR.Emp_ID=E.Emp_ID inner join           
					T0010_company_master Cm WITH (NOLOCK) on E.Cmp_ID = Cm.Cmp_ID inner join   
				   ( select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID , Vertical_ID , SubVertical_ID from T0095_Increment I WITH (NOLOCK) inner join       
					( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK)   -- Ankit 08092014 for Same Date Increment  
					where Increment_Effective_date <= @To_Date      
					and Cmp_ID = @Cmp_ID      
					group by emp_ID  ) Qry on      
					 I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID  ) I_Q		     
					on E.Emp_ID = I_Q.Emp_ID  inner join      
					 T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN      
					 T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN      
					 T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN      
					 T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id INNER JOIN       
					 T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID LEFT OUTER JOIN
					 T0040_Vertical_Segment VS WITH (NOLOCK) on I_Q.Vertical_ID = VS.Vertical_ID LEFT OUTER JOIN
					 T0050_SubVertical SV WITH (NOLOCK) on I_Q.SubVertical_ID = SV.SubVertical_ID 
			WHERE E.Cmp_ID = @Cmp_Id and EIR.Out_Time is not null
					And EIR.For_Date >= @From_Date And EIR.For_Date <= @to_Date
					AND Half_Leave_flag <> 1	
					And E.Emp_ID in (select Emp_ID From #Emp_Cons) 
					And (ES.Min_In_Time < ES.Min_Shift_Time or ES.Min_In_Time > ES.Max_Shift_Time)
					--And (0 > DATEDIFF(ss, dbo.F_Return_HHMM(ES.Min_Shift_Time),dbo.F_Return_HHMM(ES.Min_In_Time))
					--	or 7140 > (case when Is_Night_Shift = 1 then  
					--				case when DATEDIFF(ss, dbo.F_Return_HHMM(ES.Min_In_Time),dbo.F_Return_HHMM(ES.Max_Shift_Time)) > 0 then 
					--				DATEDIFF(ss, dbo.F_Return_HHMM(ES.Min_In_Time),dbo.F_Return_HHMM(ES.Max_Shift_Time))
					--				else 
					--				24*3600 + DATEDIFF(ss, dbo.F_Return_HHMM(ES.Min_In_Time),dbo.F_Return_HHMM(ES.Max_Shift_Time))
					--				end
					--			  Else
					--				DATEDIFF(ss, dbo.F_Return_HHMM(ES.Min_In_Time),dbo.F_Return_HHMM(ES.Max_Shift_Time))
					--	 End) ) 
			ORDER BY CASE WHEN IsNumeric(Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + Alpha_Emp_Code, 20)
						When IsNumeric(Alpha_Emp_Code) = 0 then Left(Alpha_Emp_Code + Replicate('',21), 20)
					 Else Alpha_Emp_Code End
			End		
					 
		END
	ELSE IF @Report_Type = 'Only Single Punch'
		BEGIN
			
			if (@Export_Type=4) -- For Excel
				Begin
						SELECT	E.Alpha_Emp_Code as [Employee Code],E.Emp_Full_Name as [Employee Name],
									Desig_Name as Designation,Dept_Name as Department,dbo.F_Return_HHMM(ES.Shift_St_Time)+' - '+ dbo.F_Return_HHMM(ES.Shift_End_Time) as [Shift Time]
									,Convert(varchar(12),EIR.For_Date,103) as [For Date],--'="' + EIR.In_Time   + '"' as In_Time, '="' + EIR.Out_Time  + '"' as Out_Time
									--EIR.In_Time,EIR.Out_Time
									substring(CONVERT(VARCHAR, EIR.In_Time, 108),0,6) AS [In Time],
									substring(CONVERT(VARCHAR, EIR.Out_Time, 108),0,6) AS [Out Time]
							--E.Emp_Code,Dept_Name,Desig_Name,Type_Name,Grd_Name,Branch_Name,Date_of_Join,Gender      
									 --,BM.Comp_Name,BM.Branch_Address,CM.Cmp_Name,Cm.Cmp_address,E.Emp_Left , BM.BRANCH_ID ,dbo.F_Return_HHMM(ES.Shift_St_Time)+' - '+ dbo.F_Return_HHMM(ES.Shift_End_Time) as shift_time
									 --,VS.Vertical_Name , sv.SubVertical_Name	--Added By Ramiz on 07/08/2015
							FROM	t0150_emp_inout_record EIR WITH (NOLOCK) Inner JOIN #Emp_Shift_Missing_Inout ES on 
									--ES.Min_In_Time = EIR.In_Time 
									(ES.Min_In_Time = EIR.In_Time or ES.Max_out_time = EIR.Out_Time)
									and ES.Emp_Id = EIR.Emp_ID
									 inner join T0080_EMP_MASTER E WITH (NOLOCK) on EIR.Emp_ID=E.Emp_ID inner join 
									--t0150_emp_inout_record EIR inner join T0080_EMP_MASTER E on EIR.Emp_ID=E.Emp_ID inner join           
									T0010_company_master Cm WITH (NOLOCK) on E.Cmp_ID = Cm.Cmp_ID inner join   
								   ( select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID , Vertical_ID , SubVertical_ID from T0095_Increment I WITH (NOLOCK) inner join       
									( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment  WITH (NOLOCK)  -- Ankit 08092014 for Same Date Increment  
									where Increment_Effective_date <= @To_Date      
									and Cmp_ID = @Cmp_ID      
									group by emp_ID  ) Qry on      
									 I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID  ) I_Q		     
									on E.Emp_ID = I_Q.Emp_ID  inner join      
									 T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN      
									 T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN      
									 T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN      
									 T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id INNER JOIN       
									 T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID LEFT OUTER JOIN
									 T0040_Vertical_Segment VS WITH (NOLOCK) on I_Q.Vertical_ID = VS.Vertical_ID LEFT OUTER JOIN
									 T0050_SubVertical SV WITH (NOLOCK) on I_Q.SubVertical_ID = SV.SubVertical_ID
									 --Inner JOIN
									 --T0040_SHIFT_MASTER SM ON SM.Shift_ID = E.Shift_ID
							WHERE E.Cmp_ID = @Cmp_Id    and (EIR.Out_Time is null or EIR.In_Time is null)--EIR.Out_Time is null
									And EIR.For_Date >= @From_Date And EIR.For_Date <= @to_Date	
									AND Half_Leave_flag <> 1
									And E.Emp_ID in (select Emp_ID From #Emp_Cons) 
							ORDER BY CASE WHEN IsNumeric(Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + Alpha_Emp_Code, 20)
										When IsNumeric(Alpha_Emp_Code) = 0 then Left(Alpha_Emp_Code + Replicate('',21), 20)
									 Else Alpha_Emp_Code End
				End
			Else
				Begin
							--select * from #data
						SELECT	EIR.*,E.Emp_Code,E.Alpha_Emp_Code,E.Emp_First_Name,E.Emp_Full_Name as Emp_Full_Name_Only,Dept_Name,Desig_Name,Type_Name,Grd_Name,Branch_Name,Date_of_Join,Gender      
								 ,BM.Comp_Name,BM.Branch_Address,CM.Cmp_Name,Cm.Cmp_address,E.Emp_Left , BM.BRANCH_ID ,dbo.F_Return_HHMM(ES.Shift_St_Time)+' - '+ dbo.F_Return_HHMM(ES.Shift_End_Time) as shift_time
								 ,VS.Vertical_Name , sv.SubVertical_Name	--Added By Ramiz on 07/08/2015
						FROM	
								--t0150_emp_inout_record EIR Inner JOIN #Emp_Shift_Missing_Inout ES 
								--on (ES.Min_In_Time = EIR.In_Time or ES.Max_out_time = EIR.Out_Time) and ES.Emp_Id = EIR.Emp_ID
								#Data EIR Inner JOIN #Emp_Shift_Missing_Inout ES 
								on ES.FOR_DATE = EIR.FOR_DATE and ES.Emp_Id = EIR.Emp_ID
								
								inner join T0080_EMP_MASTER E WITH (NOLOCK) on EIR.Emp_ID=E.Emp_ID inner join 
								--t0150_emp_inout_record EIR inner join T0080_EMP_MASTER E on EIR.Emp_ID=E.Emp_ID inner join           
								T0010_company_master Cm WITH (NOLOCK) on E.Cmp_ID = Cm.Cmp_ID inner join   
							   ( select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID , Vertical_ID , SubVertical_ID from T0095_Increment I WITH (NOLOCK) inner join       
								( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK)   -- Ankit 08092014 for Same Date Increment  
								where Increment_Effective_date <= @To_Date      
								and Cmp_ID = @Cmp_ID      
								group by emp_ID  ) Qry on      
								 I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID  ) I_Q		     
								on E.Emp_ID = I_Q.Emp_ID  inner join      
								 T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN      
								 T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN      
								 T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN      
								 T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id INNER JOIN       
								 T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID LEFT OUTER JOIN
								 T0040_Vertical_Segment VS WITH (NOLOCK) on I_Q.Vertical_ID = VS.Vertical_ID LEFT OUTER JOIN
								 T0050_SubVertical SV WITH (NOLOCK) on I_Q.SubVertical_ID = SV.SubVertical_ID
								 --Inner JOIN
								 --T0040_SHIFT_MASTER SM ON SM.Shift_ID = E.Shift_ID
						WHERE E.Cmp_ID = @Cmp_Id    and (EIR.Out_Time is null or EIR.In_Time is null)
								And EIR.For_Date >= @From_Date And EIR.For_Date <= @to_Date	
								AND Half_Leave_flag <> 1
								And E.Emp_ID in (select Emp_ID From #Emp_Cons) 
						ORDER BY CASE WHEN IsNumeric(Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + Alpha_Emp_Code, 20)
									When IsNumeric(Alpha_Emp_Code) = 0 then Left(Alpha_Emp_Code + Replicate('',21), 20)
								 Else Alpha_Emp_Code End
				End		 
		END
	ELSE IF @Report_Type = 'Odd Punch'		--Added By Ramiz on 04/09/2015 to Show Employee with 3 or 5 Punches (i.e. Odd Punches)
		BEGIN

			SELECT	EIR.IO_Tran_ID,EC.Emp_ID,E.Cmp_ID,D.For_Date,D.In_Time,D.Out_Time,EIR.Duration,EIR.Reason,EIR.IP_Address,EIR.In_Date_Time,EIR.Out_Date_Time,EIR.Skip_Count,EIR.Late_Calc_Not_App
					,EIR.Chk_By_Superior,EIR.Sup_Comment,EIR.Half_Full_day,EIR.Is_Cancel_Late_In,EIR.Is_Cancel_Late_In,EIR.Is_Cancel_Early_Out,EIR.Is_Default_In,EIR.Is_Default_Out,EIR.Cmp_Prp_In_Flag
					,EIR.Is_Cmp_Purpose,EIR.App_Date,EIR.Apr_Date,EIR.System_Date,EIR.Other_Reason,EIR.ManualEntryFlag
					,E.Emp_Code,E.Alpha_Emp_Code,E.Emp_First_Name,E.Emp_Full_Name as Emp_Full_Name_Only,Dept_Name,Desig_Name,Type_Name,Grd_Name,Branch_Name,Date_of_Join,Gender      
					,BM.Comp_Name,BM.Branch_Address,CM.Cmp_Name,Cm.Cmp_address,E.Emp_Left , BM.BRANCH_ID ,dbo.F_Return_HHMM(ES.Shift_St_Time)+' - '+ dbo.F_Return_HHMM(ES.Shift_End_Time) as shift_time
					,VS.Vertical_Name , sv.SubVertical_Name	--Added By Ramiz on 07/08/2015
			FROM	#Data D 
					INNER JOIN #Emp_Cons EC ON D.Emp_ID=EC.Emp_ID					
					inner join T0080_EMP_MASTER E WITH (NOLOCK) on EC.Emp_ID=E.Emp_ID 					
					INNER JOIN t0150_emp_inout_record EIR WITH (NOLOCK) ON EIR.Emp_ID=D.Emp_Id AND EIR.For_Date = D.For_date -- AND (EIR.In_Time BETWEEN D.In_Time and d.Out_time OR EIR.Out_Time BETWEEN D.In_Time AND D.Out_time)
					LEFT JOIN #Emp_Shift_Missing_Inout ES on ES.Max_In_Time = EIR.In_Time and ES.Emp_Id = EIR.Emp_ID					
					inner join T0010_company_master Cm WITH (NOLOCK) on E.Cmp_ID = Cm.Cmp_ID 
					inner join T0095_INCREMENT I_Q WITH (NOLOCK) on E.Emp_ID = I_Q.Emp_ID  and EC.Increment_ID = I_Q.Increment_ID
					inner join T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID 
					INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID 
					LEFT OUTER JOIN T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID 
					LEFT OUTER JOIN T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id 
					LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id 					
					LEFT OUTER JOIN T0040_Vertical_Segment VS WITH (NOLOCK) on I_Q.Vertical_ID = VS.Vertical_ID 
					LEFT OUTER JOIN T0050_SubVertical SV WITH (NOLOCK) on I_Q.SubVertical_ID = SV.SubVertical_ID
			WHERE	E.Cmp_ID = @Cmp_Id  and EIR.Out_Time is null
					And EIR.For_Date >= @From_Date And EIR.For_Date <= @to_Date	
					AND Half_Leave_flag <> 1
					And E.Emp_ID in (select Emp_ID From #Emp_Cons) 
			ORDER BY CASE WHEN IsNumeric(Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + Alpha_Emp_Code, 20)
						When IsNumeric(Alpha_Emp_Code) = 0 then Left(Alpha_Emp_Code + Replicate('',21), 20)
					 Else Alpha_Emp_Code End
		END
	
		   
 RETURN
  
  
  

