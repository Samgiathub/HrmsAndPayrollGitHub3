
CREATE PROCEDURE [dbo].[SP_RPT_DEVIATION_REGISTER]
 @Cmp_ID   numeric,      
 @From_Date  datetime,      
 @To_Date  datetime ,      
 @Branch_ID  numeric   ,      
 @Cat_ID   numeric  ,      
 @Grd_ID   numeric ,      
 @Type_ID  numeric ,      
 @Dept_ID  numeric  ,      
 @Desig_ID  numeric ,      
 @Emp_ID   numeric  ,      
 @Constraint  varchar(max) = '',   
 @Report_For varchar(20)='Format1',   --Added By Jaina 22-09-2015
 @Flag Numeric(1,0) = 0 -- Added by nilesh patel on 23082016
AS      
  	Set Nocount on 
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON     

  CREATE table #Emp_Cons 
 (      
	Emp_ID numeric ,     
	Branch_ID numeric,
	Increment_ID numeric    
 )  
 
	 if @Constraint <> '' 
		Begin
			 Insert Into #Emp_Cons      
			 select  cast(data  as numeric),cast(data  as numeric),cast(data  as numeric)from dbo.Split (@Constraint,'#')    
		End 
	 Else
		Begin
			EXEC SP_RPT_FILL_EMP_CONS  @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID ,@Emp_ID ,@constraint ,0,0,0,0,0,0,0,0,0,0 
		End 
	
	 --Added by Jaina 18-11-2016 Start
	CREATE TABLE #Data      
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
	
	EXEC dbo.P_GET_EMP_INOUT @cmp_id, @From_Date, @To_Date	 	
	-- select * from #Data--mansi
	--Added by Jaina 18-11-2016 End
	   
	 IF OBJECT_ID(N'tempdb..#Emp_Shift') IS NOT NULL
		DROP TABLE #Emp_Shift
	 
	 Create table #Emp_Shift
	 (
		Emp_Id			numeric,
		For_date		datetime,
		Increment_ID	numeric,
		Emp_Late_Time	Numeric,
		Shift_St_Time	Datetime,
		Shift_End_Time	Datetime,
		Is_Night_Shift	tinyint,
		Shift_In_Time	Datetime,
		Shift_Time_Diff Numeric,
		Dev_Shift_ID	Numeric,
		Shift_ID		Numeric,
		Has_Leave		BIT  --Added by Jaina 28-09-2015
	 )
	 
	 Insert into #Emp_Shift(Emp_Id,For_date)
	 SELECT EIO.Emp_ID,For_Date From T0150_EMP_INOUT_RECORD EIO WITH (NOLOCK) INNER JOIN #Emp_Cons E ON EIO.Emp_ID=E.Emp_ID
	 where For_Date >= @From_Date and For_Date <= @To_Date AND EIO.Cmp_ID=@Cmp_ID
	 Group BY EIO.Emp_ID,EIO.For_Date
	 
	 
	 --Add by Nimesh 21 April, 2015
	--This sp retrieves the Shift Rotation as per given employee id and effective date.
	--it will fetch all employee's shift rotation detail if employee id is not specified.
	IF (OBJECT_ID('tempdb..#Rotation') IS NULL)
		Create Table #Rotation (R_EmpID numeric(18,0), R_DayName varchar(25), R_ShiftID numeric(18,0), R_Effective_Date DateTime);
	--The #Rotation table gets re-created in dbo.P0050_UNPIVOT_EMP_ROTATION stored procedure
	Exec dbo.P0050_UNPIVOT_EMP_ROTATION @Cmp_ID, NULL, @To_Date, @Constraint
	
	DECLARE @TEMP_FOR_DATE datetime
	SET	@TEMP_FOR_DATE = @FROM_DATE
	
	WHILE (@TEMP_FOR_DATE <= @TO_DATE)
	BEGIN
		--if the rotation is assigned then only those shift should be assigned which shift_type is 0
		UPDATE	#Emp_Shift SET SHIFT_ID = Shf.Shift_ID
		FROM	#Emp_Shift  p 
				INNER JOIN (
								SELECT	ESD.Shift_ID, ESD.Emp_ID 
								FROM	T0100_EMP_SHIFT_DETAIL ESD WITH (NOLOCK)
								WHERE	ESD.For_Date=(	SELECT	MAX(FOR_DATE) 
														FROM	T0100_EMP_SHIFT_DETAIL ESD1 WITH (NOLOCK)
														WHERE	ESD1.Emp_ID=ESD.Emp_ID AND ESD1.Cmp_ID=ESD.Cmp_ID 
																AND ESD1.For_Date<=@TEMP_FOR_DATE  AND ISNULL(ESD1.Shift_Type, 0) <> 1
													 )
										AND ESD.Cmp_ID=@Cmp_ID 
						    ) Shf ON Shf.Emp_ID = p.EMP_ID
		WHERE	p.For_date=@TEMP_FOR_DATE
		
		--Updating @PRESENT table for Shift_ID
		UPDATE	#Emp_Shift SET SHIFT_ID=R_ShiftID
		FROM	#Rotation R 
		WHERE	R.R_EmpID=EMP_ID AND R.R_DayName = 'Day' + CAST(DATEPART(d, @TEMP_FOR_DATE) As Varchar)
				AND R.R_Effective_Date=(
											SELECT	MAX(R_Effective_Date) FROM #Rotation 
											WHERE	R_Effective_Date <=@TEMP_FOR_DATE
										)			
				AND #Emp_Shift.For_date=@TEMP_FOR_DATE 
				
				

		--Update Shift ID as per the assigned shift in shift detail 
		--Retrieve the shift id from employee shift changed detail table
		UPDATE	#Emp_Shift SET SHIFT_ID = Shf.Shift_ID
		FROM	#Emp_Shift  p 
				INNER JOIN (
							SELECT	ESD.Shift_ID, ESD.Emp_ID 
							FROM	T0100_EMP_SHIFT_DETAIL ESD WITH (NOLOCK)
							WHERE	ESD.Emp_ID IN (
										Select	R.R_EmpID FROM #Rotation R
										WHERE	R_DayName = 'Day' + CAST(DATEPART(d, @TEMP_FOR_DATE) As Varchar) 													
										GROUP BY R.R_EmpID
									)
									AND ESD.For_Date=@TEMP_FOR_DATE AND ESD.Cmp_ID=@Cmp_ID
							) Shf ON Shf.Emp_ID = p.EMP_ID
		WHERE	p.For_date=@TEMP_FOR_DATE
		
		--if (@TEMP_FOR_DATE = '2015-08-05')
		--BEGIN
		--	--SELECT	ESD.Shift_ID, ESD.Emp_ID 
		--	--FROM	T0100_EMP_SHIFT_DETAIL ESD 
		--	--WHERE	ESD.Emp_ID not IN (
		--	--			Select	R.R_EmpID FROM #Rotation R
		--	--			WHERE	R_DayName = 'Day' + CAST(DATEPART(d, @TEMP_FOR_DATE) As Varchar) 													
		--	--			GROUP BY R.R_EmpID
		--	--		)
		--	--		AND ESD.For_Date=@TEMP_FOR_DATE AND ESD.Cmp_ID=@Cmp_ID 
		--END
					
		--if the rotation is not assigned then only those shift should be assigned which shift_type is 1
		UPDATE	#Emp_Shift SET SHIFT_ID = Shf.Shift_ID
		FROM	#Emp_Shift  p 
				INNER JOIN (
							SELECT	ESD.Shift_ID, ESD.Emp_ID 
							FROM	T0100_EMP_SHIFT_DETAIL ESD WITH (NOLOCK)
							WHERE	ESD.Emp_ID NOT IN (
										Select	R.R_EmpID FROM #Rotation R
										WHERE	R_DayName = 'Day' + CAST(DATEPART(d, @TEMP_FOR_DATE) As Varchar) 													
										GROUP BY R.R_EmpID
									)
									AND ESD.For_Date=@TEMP_FOR_DATE AND ESD.Cmp_ID=@Cmp_ID AND IsNull(ESD.Shift_Type,0)=1 
							) Shf ON Shf.Emp_ID = p.EMP_ID
		WHERE	p.For_date=@TEMP_FOR_DATE
		
	
		SET @TEMP_FOR_DATE = DATEADD(DD, 1, @TEMP_FOR_DATE);
	END
	
	/* Added By Jaina 28-09-2015 */
	/*To update flag for leave taken*/
	/*Start*/
	Update  #Emp_Shift set Has_Leave=1
	FROM	#Emp_Shift E  
			INNER JOIN ( 
							SELECT	I.Emp_ID, lt.For_Date 
							FROM	T0140_LEAVE_TRANSACTION lt WITH (NOLOCK) INNER JOIN T0150_EMP_INOUT_RECORD As I WITH (NOLOCK)
									ON I.Cmp_ID= lt.Cmp_ID AND lt.For_Date=I.For_Date AND i.Emp_ID=lt.Emp_ID
						) T ON T.Emp_ID=E.Emp_Id AND T.For_Date=E.For_date

	
	 /*End*/

	
	
	--Updating shift time based on shift id
	Update  #Emp_Shift set 
			Shift_st_Time = Convert(varchar(11),E.For_date,120) + (CASE WHEN S.Is_Half_Day=1 AND s.Week_Day=DATENAME(WEEKDAY, E.For_date) THEN S.Half_St_Time ELSE S.Shift_St_Time END), 
			Shift_End_Time = Convert(varchar(11),E.For_date,120) + (CASE WHEN S.Is_Half_Day=1 AND s.Week_Day=DATENAME(WEEKDAY, E.For_date) THEN S.Half_End_Time ELSE S.Shift_End_Time END),
			Is_Night_Shift = (CASE WHEN (S.Shift_St_Time > S.Shift_End_Time) THEN 1 ELSE 0 END),
			Shift_In_Time = E_IN.In_Time,
			Shift_Time_Diff = CASE WHEN s.Shift_St_Time = '00:00'  THEN
									ABS(DATEDIFF(ss, convert(varchar(11), DATEADD(d,1, E_IN.For_Date), 120)  + S.Shift_St_Time ,E_IN.In_Time))
							  ELSE
									ABS(DATEDIFF(ss, convert(varchar(11), E_IN.For_Date, 120)  + S.Shift_St_Time,E_IN.In_Time))
							  END
	FROM	#Emp_Shift E INNER JOIN T0040_SHIFT_MASTER S WITH (NOLOCK) ON E.Shift_ID=S.Shift_ID
			LEFT OUTER JOIN (	SELECT	MIN(EIO.In_Time) AS In_Time ,EIO.For_Date,EIO.Emp_ID, EIO.Cmp_ID	
								FROM	T0150_EMP_INOUT_RECORD EIO WITH (NOLOCK)
								GROUP BY EIO.For_Date,EIO.Emp_ID,EIO.Cmp_ID
							) E_IN ON E_IN.For_Date=E.For_date AND E_IN.Cmp_ID=S.Cmp_ID AND E_IN.Emp_ID=E.Emp_Id
	WHERE	S.Cmp_ID=@Cmp_ID
	
	--Added by Nimesh for Night Shift
	UPDATE  #Emp_Shift 
	SET		Shift_St_Time = CASE WHEN DATEPART(HH,Shift_St_Time) = 0 THEN DateAdd(d, 1, Shift_St_Time) ELSE Shift_St_Time END,
			Shift_End_Time = CASE WHEN Shift_St_Time > Shift_End_Time THEN DateAdd(d, 1, Shift_End_Time) ELSE Shift_End_Time END
	WHERE	DATEPART(HH,Shift_St_Time) = 0 OR Shift_St_Time > Shift_End_Time
	
	--Getting Late Limit
	Update  #Emp_Shift set 
			Emp_Late_Time=I.Emp_Late_Limit,
			Increment_ID=I.Increment_ID
	FROM	#Emp_Shift E INNER JOIN (	SELECT	EMP_ID,dbo.F_Return_Sec(I.Emp_Late_Limit) As Emp_Late_Limit,Increment_ID
										FROM	T0095_INCREMENT I WITH (NOLOCK)
										WHERE	I.Increment_ID=(SELECT	TOP 1 INCREMENT_ID
																FROM	T0095_INCREMENT I2 WITH (NOLOCK)
																WHERE	I2.Emp_ID=I.Emp_ID AND I2.Cmp_ID=I.Cmp_ID AND I.Increment_Effective_Date <= @TO_DATE
																ORDER BY I2.Increment_Effective_Date DESC, I2.Increment_ID DESC
																)
												AND I.Cmp_ID=@CMP_ID
									) I ON E.Emp_Id=I.Emp_ID
	
	
	
	--Getting Deviation Shift based on employee's in time. if employee came before or after maximum late time limit.
	Update  #Emp_Shift set 
			Dev_Shift_ID=(
							SELECT	TOP 1 SHIFT_ID 
							FROM	T0040_SHIFT_MASTER S WITH (NOLOCK)
							WHERE	S.Cmp_ID=@CMP_ID
							ORDER BY	CASE WHEN s.Shift_St_Time = '00:00' THEN
												ABS(DATEDIFF(ss, convert(varchar(11), DATEADD(d, 1, E.For_date), 120)  + S.Shift_St_Time ,E.Shift_In_Time))
										  ELSE
												ABS(DATEDIFF(ss, convert(varchar(11), E.For_Date, 120)  + S.Shift_St_Time ,E.Shift_In_Time))
										  END 
							--ORDER BY ABS(DATEDIFF(ss, CONVERT(VARCHAR(11), e.For_date, 120) +  S.Shift_St_Time,E.Shift_In_Time))
						 )
	FROM	#Emp_Shift E 
	WHERE	(E.Shift_Time_Diff > E.Emp_Late_Time Or Has_Leave = 1)
			AND DATEPART(HH,Shift_In_Time) NOT IN (22,23, 0, 1, 2)
	
	--For Night Shift Scenario
	UPDATE  E 
	SET		Dev_Shift_ID = SM.Shift_ID
	FROM	#Emp_Shift E 
			CROSS APPLY (SELECT TOP 1 * FROM T0040_SHIFT_MASTER SM WITH (NOLOCK)
						WHERE SM.Cmp_ID=@CMP_ID AND	DATEPART(HH,SM.Shift_St_Time) = DATEPART(HH, E.SHIFT_IN_TIME) 
						ORDER BY 
							CASE WHEN DATEPART(HH,Shift_In_Time) IN (22,23)
								THEN ABS(DATEDIFF(ss, convert(varchar(11), DATEADD(d, 1, E.Shift_In_Time), 120)  + SM.Shift_St_Time ,E.Shift_In_Time))
							ELSE	
								ABS(DATEDIFF(ss, convert(varchar(11), E.For_Date, 120)  + SM.Shift_St_Time ,E.Shift_In_Time))
							END
						) SM			
	WHERE	DATEPART(HH,Shift_In_Time) IN (22,23, 0, 1, 2) AND E.Shift_ID <> SM.Shift_ID
	
		--select * from #Emp_Shift
	--End Nimesh
	
	/*Commented by Nimesh on 07-Sep-2015
	
     declare @cur_Emp_ID numeric(10,0)
	 
	 Declare cur_Emp cursor for Select EMP_ID From #Emp_Cons
	 open cur_Emp 
		fetch next from cur_Emp into @cur_Emp_ID
		while @@fetch_Status = 0
			Begin
			
				Insert into #Emp_Shift(Emp_Id,For_date)
					 SELECT Emp_ID,For_Date From T0150_EMP_INOUT_RECORD   
					 where Emp_ID = @cur_Emp_ID and For_Date >= @From_Date and For_Date <= @To_Date
					 Group BY Emp_ID,For_Date
				fetch next from cur_Emp into @cur_Emp_ID
			End 
		close cur_Emp
		deallocate cur_Emp 
	
	Declare @Cur_Shift_Emp_ID Numeric(18,0)
	 declare @Cur_For_date datetime
	 Declare @Cur_Date_of_Birth Datetime
	 
	 --Declare @Cur_Shift_St_time varchar(10)
	 --Declare @Cur_Shift_End_time varchar(10)
	 Declare @Cur_Shift_St_time Datetime
	 Declare @Cur_Shift_End_time Datetime
	 Declare @Cur_Is_Night_Shift tinyint
	 
	 Declare @Cur_Min_In_Time Datetime	
	 Declare @Shift_Time_Diff Numeric
	 Declare @Emp_Late_Time_Sec Numeric
	 Declare @Shift_ID_Autoshift Numeric
	 
	 Set @Shift_Time_Diff = 0
	 Set @Emp_Late_Time_Sec = 0
	 Set @Shift_ID_Autoshift = 0
	
	Declare Cur_Shift_Emp Cursor For Select Emp_Id,For_date From #Emp_Shift
	 Open Cur_Shift_Emp
		Fetch Next From Cur_Shift_Emp into @Cur_Shift_Emp_ID,@Cur_For_date
			While @@Fetch_Status = 0
				Begin
					exec SP_CURR_T0100_EMP_SHIFT_GET @Cur_Shift_Emp_ID,@Cmp_ID,@Cur_For_date,@Cur_Shift_St_time output ,@Cur_Shift_End_time output
				    
					if @Cur_Shift_St_time > @Cur_Shift_End_time
						Begin
							set @Cur_Is_Night_Shift = 1
						End 
															
					else
						Begin
							set @Cur_Is_Night_Shift = 0
						End 	  
					
					Set @Cur_Min_In_Time = NULL
					
					Select @Emp_Late_Time_Sec = dbo.F_Return_Sec(Emp_Late_Limit) From T0095_INCREMENT I Inner JOIN 
					( SELECT MAX(Increment_ID) as Increment_ID From T0095_INCREMENT I_Q Inner JOIN 
					( Select Max(Increment_Effective_Date) as Effective_Date,Emp_ID From T0095_INCREMENT
						Where Emp_ID = @Cur_Shift_Emp_ID
						Group BY Emp_ID ) as qry
					on I_Q.Emp_ID = qry.Emp_ID and I_Q.Increment_Effective_Date = qry.Effective_Date
					) as qry_1 on qry_1.Increment_ID = I.Increment_ID
					
							
					select @Cur_Min_In_Time = Min(In_time)
					from dbo.T0150_emp_inout_record e 
					Where  E.For_Date = @Cur_For_date and E.Emp_ID = @Cur_Shift_Emp_ID
					group by e.For_Date,e.Emp_ID
					
					set @Cur_Shift_St_time = convert(varchar(11),@Cur_For_date,120) + @Cur_Shift_St_time	
					Set @Cur_Shift_End_time = convert(varchar(11),@Cur_For_date,120) + @Cur_Shift_End_time
					
					if @Cur_Shift_St_time > @Cur_Min_In_Time 
						Begin
							Set @Shift_Time_Diff = DATEDIFF(ss, dbo.F_Return_HHMM(@Cur_Min_In_Time),dbo.F_Return_HHMM(@Cur_Shift_St_time))		
						End
					Else
						Begin
							Set @Shift_Time_Diff = DATEDIFF(ss, dbo.F_Return_HHMM(@Cur_Shift_St_time),dbo.F_Return_HHMM(@Cur_Min_In_Time))
						End 
						
					--select ABS(datediff(s,@Cur_Min_In_Time,cast(CONVERT(VARCHAR(11), @Cur_Min_In_Time, 121)  + CONVERT(VARCHAR(12), Shift_St_Time, 114) as datetime))), *
					--	from T0040_SHIFT_MASTER
					--	where Cmp_ID = @Cmp_ID 
					--	order by ABS(datediff(s,@Cur_Min_In_Time,cast(CONVERT(VARCHAR(11), @Cur_Min_In_Time, 121)  + CONVERT(VARCHAR(12), Shift_St_Time, 114) as datetime)))

					
					select top 1 @Shift_ID_Autoshift = Shift_ID 
						from T0040_SHIFT_MASTER
						where Cmp_ID = @Cmp_ID 
						order by ABS(datediff(s,@Cur_Min_In_Time,cast(CONVERT(VARCHAR(11), @Cur_Min_In_Time, 121)  + CONVERT(VARCHAR(12), Shift_St_Time, 114) as datetime)))
						
					--if isnull(@Shift_ID_Autoshift,0) > 0
					--	Begin
					--			Update #Data 
					--			set Shift_ID=@Shift_ID_Autoshift
					--			where Emp_ID=@Emp_ID_AutoShift and In_time=@In_Time_Autoshift And Shift_ID <> @Shift_ID_Autoshift
					--	End
					
					Update  #Emp_Shift set 
							Shift_st_Time = @Cur_Shift_St_time, 
							Shift_End_Time = @Cur_Shift_End_time ,
							Is_Night_Shift = @Cur_Is_Night_Shift,
							Shift_In_Time = @Cur_Min_In_Time,
							Shift_Time_Diff = @Shift_Time_Diff,
							Emp_Late_Time = @Emp_Late_Time_Sec,
							Dev_Shift_ID = @Shift_ID_Autoshift
					where	Emp_ID = @Cur_Shift_Emp_ID and For_Date = @Cur_For_date
					
					Fetch Next From Cur_Shift_Emp into @Cur_Shift_Emp_ID,@Cur_For_date
				End 
	 Close Cur_Shift_Emp
	 Deallocate Cur_Shift_Emp
	 
	*/
	
	 if @Report_For	= 'Format1'  --Added By Jaina 22-09-2015
		begin	
			
			if @Flag <> 1 
				Begin	
					--print 111---mansi
					Select
						ES.Emp_Id,
						ES.For_date,
						ER.In_Time As IO_In_Time,
						ER.Out_Time AS IO_Ou_Time,
						SHIFT.Shift_Name,
						ES.Shift_St_Time,
						ES.Shift_End_Time,
						Dev.Shift_Name As Dev_Shift_Name,
						(CASE WHEN DEV.Is_Half_Day=1 AND DEV.Week_Day=DATENAME(WEEKDAY, ES.For_date) THEN Dev.Half_St_Time ELSE Dev.Shift_St_Time END)  AS Dev_Shift_St_Time,
						(CASE WHEN DEV.Is_Half_Day=1 AND DEV.Week_Day=DATENAME(WEEKDAY, ES.For_date) THEN Dev.Half_End_Time ELSE Dev.Shift_End_Time END) AS Dev_Shift_End_Time,	
						(CASE	WHEN CAST(DEV.Shift_St_Time As datetime) < CAST(DEV.Shift_End_Time As datetime) THEN
										dbo.F_Return_Hours(DATEDIFF(ss, dbo.F_Return_HHMM(Dev.Shift_St_Time),dbo.F_Return_HHMM(Dev.Shift_End_Time)))
								When DatePart(hh,CAST(ES.Shift_End_Time As datetime)) = 0 Then
										dbo.F_Return_Hours(DATEDIFF(ss, Dev.Shift_St_Time,Dev.Shift_End_Time)) 
								ELSE
										dbo.F_Return_Hours(DATEDIFF(ss, Convert(varchar(11), ES.For_date, 120) + dbo.F_Return_HHMM(Dev.Shift_St_Time), Convert(varchar(11), DateAdd(d,1,ES.For_date), 120) + dbo.F_Return_HHMM(Dev.Shift_End_Time)))
						END)  as Dev_Shift_Hours,
						dbo.F_Return_Hours(ES.Shift_Time_Diff) AS Diff,
						E.Emp_Full_Name,
						E.Alpha_Emp_Code,
						DGM.Desig_Name,
						DM.Dept_Name,
						ER.Duration,
						(Case When CAST(ES.Shift_St_Time As datetime) > CAST(ES.Shift_End_Time As datetime) THEN
								dbo.F_Return_Hours(DATEDIFF(ss, dbo.F_Return_HHMM(ES.Shift_St_Time),dbo.F_Return_HHMM(ES.Shift_End_Time))) 
							When DatePart(hh,CAST(ES.Shift_End_Time As datetime)) = 0 Then
								dbo.F_Return_Hours(DATEDIFF(ss, ES.Shift_St_Time,ES.Shift_End_Time)) 
							Else
								dbo.F_Return_Hours(DATEDIFF(ss, dbo.F_Return_HHMM(ES.Shift_St_Time),dbo.F_Return_HHMM(dateadd(d,1,ES.Shift_End_Time)))) 
						END) as shift_hours,
						E.Alpha_Emp_Code,E.Emp_Full_Name, GM.Grd_ID, GM.Grd_Name, DGM.Desig_ID, DGM.Desig_Name,DM.Dept_Id,DM.Dept_Name,
						BM.Branch_ID,BM.Branch_Name,BM.Comp_Name, BM.Branch_Address,CM.Cmp_Name,CM.Cmp_Address,ETM.Type_ID, ETM.Type_Name
						,I_Q.Vertical_ID,SV.SubVertical_Name,SB.SubBranch_Name,VS.Vertical_Name,ES.Has_Leave      --added jimit 08092015 Added By Jaina 30-09-2015 Has_Leave
				FROM	#Emp_Shift ES 
						inner JOIN T0150_EMP_INOUT_RECORD ER WITH (NOLOCK) on ES.Shift_In_Time = ER.In_Time and ES.Emp_Id = ER.Emp_ID
						inner join T0080_EMP_MASTER E WITH (NOLOCK) on ER.Emp_ID=E.Emp_ID 
						inner join T0010_company_master Cm WITH (NOLOCK) on E.Cmp_ID = Cm.Cmp_ID 
						inner join T0095_INCREMENT I_Q WITH (NOLOCK) ON ES.Emp_Id = I_Q.Emp_ID AND ES.Increment_ID=I_Q.Increment_ID
						inner join T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID 
						LEFT OUTER JOIN T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID 
						LEFT OUTER JOIN T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id 
						LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id 
						INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID 
						LEFT OUTER JOIN T0040_SHIFT_MASTER DEV WITH (NOLOCK) ON ES.Dev_Shift_ID=DEV.Shift_ID AND DEV.Cmp_ID=E.Cmp_ID
						LEFT OUTER JOIN T0040_SHIFT_MASTER SHIFT WITH (NOLOCK) ON ES.Shift_ID=SHIFT.Shift_ID AND SHIFT.Cmp_ID=E.Cmp_ID
						Left OUTER JOIN T0050_SubVertical SV WITH (NOLOCK) ON SV.SubVertical_ID = I_Q.SubVertical_ID and SV.Cmp_ID = I_Q.Cmp_ID
						LEFT OUTER JOIN T0050_SubBranch SB WITH (NOLOCK) ON SB.subBranch_id = I_Q.subBranch_id and SB.Cmp_ID = I_Q.cmp_ID
						LEFT OUTER JOIN T0040_Vertical_Segment VS WITH (NOLOCK) ON VS.Vertical_ID = I_Q.Vertical_ID and VS.Cmp_ID = I_Q.Cmp_ID
				WHERE	--Shift_Time_Diff > Emp_Late_Time and Emp_Late_Time <> 0 AND 
						i_Q.Cmp_ID=@Cmp_ID AND ES.Dev_Shift_ID <> SHIFT.Shift_ID
						ORDER BY ES.EMP_ID , ES.FOR_DATE	--Added By Ramiz on 16/03/2016
				End
			Else
				Begin
				
				Insert into #Emp_Shift_Details(Emp_ID,Cmp_ID,Emp_Code,Emp_Name,Designation,For_date,Shift_St_Time,Shift_End_Time,Shift_Hours,Actual_St_Time,Actual_End_Time,Actual_Hours,Dev_St_Time,Dev_End_Time,Dev_Hours)
						 Select ES.Emp_Id,E.Cmp_ID,E.Alpha_Emp_Code,E.Emp_Full_Name,DGM.Desig_Name,ES.For_date,ES.Shift_St_Time,ES.Shift_End_Time,dbo.F_Return_Hours(DATEDIFF(ss, ES.Shift_St_Time,ES.Shift_End_Time)),ER.In_Time,ER.Out_Time,dbo.F_Return_Hours(DATEDIFF(ss, ER.In_Time,ER.Out_Time)),
						(CASE WHEN DEV.Is_Half_Day=1 AND DEV.Week_Day=DATENAME(WEEKDAY, ES.For_date) THEN Dev.Half_St_Time ELSE Dev.Shift_St_Time END),
						(CASE WHEN DEV.Is_Half_Day=1 AND DEV.Week_Day=DATENAME(WEEKDAY, ES.For_date) THEN Dev.Half_End_Time ELSE Dev.Shift_End_Time END),			
						(CASE WHEN CAST(DEV.Shift_St_Time As datetime) < CAST(DEV.Shift_End_Time As datetime) THEN
							dbo.F_Return_Hours(DATEDIFF(ss, dbo.F_Return_HHMM(Dev.Shift_St_Time),dbo.F_Return_HHMM(Dev.Shift_End_Time)))
						ELSE
							dbo.F_Return_Hours(DATEDIFF(ss, Convert(varchar(11), ES.For_date, 120) + dbo.F_Return_HHMM(Dev.Shift_St_Time), Convert(varchar(11), DateAdd(d,1,ES.For_date), 120) + dbo.F_Return_HHMM(Dev.Shift_End_Time)))
						END) 
				FROM	#Emp_Shift ES 
						inner JOIN T0150_EMP_INOUT_RECORD ER WITH (NOLOCK) on ES.Shift_In_Time = ER.In_Time and ES.Emp_Id = ER.Emp_ID
						inner join T0080_EMP_MASTER E WITH (NOLOCK) on ER.Emp_ID=E.Emp_ID 
						inner join T0010_company_master Cm WITH (NOLOCK) on E.Cmp_ID = Cm.Cmp_ID 
						inner join T0095_INCREMENT I_Q WITH (NOLOCK) ON ES.Emp_Id = I_Q.Emp_ID AND ES.Increment_ID=I_Q.Increment_ID
						inner join T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID 
						LEFT OUTER JOIN T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID 
						LEFT OUTER JOIN T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id 
						LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id 
						INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID 
						LEFT OUTER JOIN T0040_SHIFT_MASTER DEV WITH (NOLOCK) ON ES.Dev_Shift_ID=DEV.Shift_ID AND DEV.Cmp_ID=E.Cmp_ID
						LEFT OUTER JOIN T0040_SHIFT_MASTER SHIFT WITH (NOLOCK) ON ES.Shift_ID=SHIFT.Shift_ID AND SHIFT.Cmp_ID=E.Cmp_ID
						Left OUTER JOIN T0050_SubVertical SV WITH (NOLOCK) ON SV.SubVertical_ID = I_Q.SubVertical_ID and SV.Cmp_ID = I_Q.Cmp_ID
						LEFT OUTER JOIN T0050_SubBranch SB WITH (NOLOCK) ON SB.subBranch_id = I_Q.subBranch_id and SB.Cmp_ID = I_Q.cmp_ID
						LEFT OUTER JOIN T0040_Vertical_Segment VS WITH (NOLOCK) ON VS.Vertical_ID = I_Q.Vertical_ID and VS.Cmp_ID = I_Q.Cmp_ID
				WHERE	--Shift_Time_Diff > Emp_Late_Time and Emp_Late_Time <> 0 AND 
						i_Q.Cmp_ID=@Cmp_ID AND ES.Dev_Shift_ID <> SHIFT.Shift_ID
						ORDER BY ES.EMP_ID , ES.FOR_DATE	
				End
		End
	Else  --Added By Jaina 22-09-2015 Start
		begin	
			
			-- print 222---mansi
			Select
					ES.Emp_Id,
					ES.For_date,
					--D.In_Time As IO_In_Time,--commented by mansi 
					--D.Out_Time AS IO_Ou_Time,--commented by mansi 
					ER.In_Time As IO_In_Time,--added by mansi 
						ER.Out_Time AS IO_Ou_Time,--added by mansi 
					SHIFT.Shift_Name,
					ES.Shift_St_Time,
					ES.Shift_End_Time,
					Dev.Shift_Name As Dev_Shift_Name,
					(CASE WHEN DEV.Is_Half_Day=1 AND DEV.Week_Day=DATENAME(WEEKDAY, ES.For_date) THEN Dev.Half_St_Time ELSE Dev.Shift_St_Time END)  AS Dev_Shift_St_Time,
					(CASE WHEN DEV.Is_Half_Day=1 AND DEV.Week_Day=DATENAME(WEEKDAY, ES.For_date) THEN Dev.Half_End_Time ELSE Dev.Shift_End_Time END) AS Dev_Shift_End_Time,			
					(CASE WHEN CAST(DEV.Shift_St_Time As datetime) < CAST(DEV.Shift_End_Time As datetime) THEN
						dbo.F_Return_Hours(DATEDIFF(ss, dbo.F_Return_HHMM(Dev.Shift_St_Time),dbo.F_Return_HHMM(Dev.Shift_End_Time)))
					ELSE
						dbo.F_Return_Hours(DATEDIFF(ss, Convert(varchar(11), ES.For_date, 120) + dbo.F_Return_HHMM(Dev.Shift_St_Time), Convert(varchar(11), DateAdd(d,1,ES.For_date), 120) + dbo.F_Return_HHMM(Dev.Shift_End_Time)))
					END)  as Dev_Shift_Hours,
					dbo.F_Return_Hours(ES.Shift_Time_Diff) AS Diff,
					E.Emp_Full_Name,
					E.Alpha_Emp_Code,
					DGM.Desig_Name,
					DM.Dept_Name,
					ER.Duration,
					--dbo.F_Return_Hours(DATEDIFF(ss, dbo.F_Return_HHMM(ES.Shift_St_Time),dbo.F_Return_HHMM(ES.Shift_End_Time))) as shift_hours,
					(Case When CAST(ES.Shift_St_Time As datetime) > CAST(ES.Shift_End_Time As datetime) THEN
							dbo.F_Return_Hours(DATEDIFF(ss, dbo.F_Return_HHMM(ES.Shift_St_Time),dbo.F_Return_HHMM(ES.Shift_End_Time))) 
						Else
							dbo.F_Return_Hours(DATEDIFF(ss, dbo.F_Return_HHMM(ES.Shift_St_Time),dbo.F_Return_HHMM(dateadd(d,1,ES.Shift_End_Time)))) 
						END) as shift_hours,
					E.Alpha_Emp_Code,E.Emp_Full_Name, GM.Grd_ID, GM.Grd_Name, DGM.Desig_ID, DGM.Desig_Name,DM.Dept_Id,DM.Dept_Name,
					BM.Branch_ID,BM.Branch_Name,BM.Comp_Name, BM.Branch_Address,CM.Cmp_Name,CM.Cmp_Address,ETM.Type_ID, ETM.Type_Name
					,I_Q.Vertical_ID,SV.SubVertical_Name,SB.SubBranch_Name,VS.Vertical_Name,ES.Has_Leave      --added jimit 08092015 Added By Jaina 30-09-2015 Has_Leave
			FROM	#Emp_Shift ES 
					inner JOIN T0150_EMP_INOUT_RECORD ER WITH (NOLOCK) on ES.Shift_In_Time = ER.In_Time and ES.Emp_Id = ER.Emp_ID
					--inner JOIN #Data D ON D.Emp_Id = ES.Emp_ID and ES.Shift_In_Time = D.In_Time   --Added by Jaina 18-11-2016
					left JOIN #Data D ON D.Emp_Id = ES.Emp_ID and ES.Shift_In_Time = D.In_Time   --added by mansi
					inner join T0080_EMP_MASTER E WITH (NOLOCK) on ER.Emp_ID=E.Emp_ID 
					inner join T0010_company_master Cm WITH (NOLOCK) on E.Cmp_ID = Cm.Cmp_ID 
					inner join T0095_INCREMENT I_Q WITH (NOLOCK) ON ES.Emp_Id = I_Q.Emp_ID AND ES.Increment_ID=I_Q.Increment_ID
					inner join T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID 
					LEFT OUTER JOIN T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID 
					LEFT OUTER JOIN T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id 
					LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id 
					INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID 
					LEFT OUTER JOIN T0040_SHIFT_MASTER DEV WITH (NOLOCK) ON ES.Dev_Shift_ID=DEV.Shift_ID AND DEV.Cmp_ID=E.Cmp_ID
					LEFT OUTER JOIN T0040_SHIFT_MASTER SHIFT WITH (NOLOCK) ON ES.Shift_ID=SHIFT.Shift_ID AND SHIFT.Cmp_ID=E.Cmp_ID
					Left OUTER JOIN T0050_SubVertical SV WITH (NOLOCK) ON SV.SubVertical_ID = I_Q.SubVertical_ID and SV.Cmp_ID = I_Q.Cmp_ID
					LEFT OUTER JOIN T0050_SubBranch SB WITH (NOLOCK) ON SB.subBranch_id = I_Q.subBranch_id and SB.Cmp_ID = I_Q.cmp_ID
					LEFT OUTER JOIN T0040_Vertical_Segment VS WITH (NOLOCK) ON VS.Vertical_ID = I_Q.Vertical_ID and VS.Cmp_ID = I_Q.Cmp_ID
			WHERE	--((Shift_Time_Diff > Emp_Late_Time and Emp_Late_Time <> 0) OR ES.Has_Leave = 1) AND --commented by mansi
			i_Q.Cmp_ID=@Cmp_ID 
			AND ES.Dev_Shift_ID <> SHIFT.Shift_ID---added by mansi 
			ORDER BY ES.EMP_ID , ES.FOR_DATE	--Added By Ramiz on 16/03/2016
		End
		
		--Added By Jaina 22-09-2015 End	
		
	 
 RETURN      




