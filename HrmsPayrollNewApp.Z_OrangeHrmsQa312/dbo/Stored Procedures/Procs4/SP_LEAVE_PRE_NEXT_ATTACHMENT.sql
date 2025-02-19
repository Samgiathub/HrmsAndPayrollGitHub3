CREATE PROCEDURE [dbo].[SP_LEAVE_PRE_NEXT_ATTACHMENT]
	@Cmp_Id as numeric
	,@Emp_Id as numeric
	,@Leave_Id as numeric	
	,@From_Date as DATETIME 
	,@To_Date as DATETIME 
	,@Leave_Application_ID as numeric = 0  --Added by Jaina 31-03-2017
	,@Period as numeric(18,2) = 0 --Added by Jaina 21-02-2019
	,@Leave_Type as varchar(max) = '' --Added by Jaina 21-02-2019
AS
	BEGIN
		
		Set Nocount on 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

		DECLARE @RETURN INT 
		DECLARE @Attachment_day as numeric(18,2)
		Declare @Before_date datetime;
		Declare @After_date datetime;

		Set @RETURN = 0
		Set @Attachment_day =0		
	
		Declare @F_Date datetime
		Declare @T_Date datetime
		DECLARE @TMP_DATE DATETIME;
		DECLARE @Cnt As numeric(18,2) --=0
		DECLARE @Leave_Cnt As numeric(18,2)  --=0
		declare @Ltype varchar(15)
	
		if exists(
					SELECT	1 
					from	T0040_LEAVE_MASTER WITH (NOLOCK)
					where	Cmp_ID=@Cmp_id and Leave_ID =@Leave_ID and is_Document_Required = 1
					)
			BEGIN
				CREATE table #Employee_Leave
					(
						Emp_Id numeric(18,0),
						For_Date datetime,
						Leave_Id numeric(18,0),
						Leave_Period numeric(18,2),
						Leave_Type varchar(50),
						Application_Id numeric(18,0),
						Approval_Id numeric(18,0),
						Leave_Start_Time DateTime,
						Leave_End_Time DateTime
					)
				
				set @F_Date =dateadd(d,-10,@FROM_DATE)
				set @T_Date =dateadd(d,10,@To_Date)
				
				EXEC P_GET_LEAVE_DETAIL @CMP_ID,@EMP_ID,@F_Date,@T_Date
				
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
				
				EXEC SP_GET_HW_ALL @CONSTRAINT=@Emp_Id,@CMP_ID=@Cmp_ID, @FROM_DATE=@F_Date, @TO_DATE=@T_Date, @All_Weekoff = 1, @Exec_Mode=0		
												
				select @Attachment_day = Attachment_Days from T0040_LEAVE_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_id and Leave_ID =@Leave_ID and is_Document_Required = 1
		
				CREATE TABLE #tblLeaveDate
					(
						RowId	int,
						LeaveDate	Date,
						LName	char(1)
					)
				create CLUSTERED INDEX in_tblLeaveDate on #tblLeaveDate (LeaveDate);


				DECLARE @StDate DATETIME
				DECLARE @EdDate	DATETIME
				DECLARE @intRow INT 
				SET @intRow=1
			
				WHILE ( @intRow <= 7)
					BEGIN
						if @intRow=1
							begin
								Insert into #tblLeaveDate(RowId,LeaveDate,LName)
								Select '0',@From_Date,''
							end
			    
						Insert into #tblLeaveDate(RowId,LeaveDate,LName)
						Select CONVERT(VARCHAR,@intRow),@From_Date+(@intRow*-1),''
					    
						Insert into #tblLeaveDate(RowId,LeaveDate,LName)
						Select CONVERT(VARCHAR,@intRow),@From_Date+@intRow,''
					    
						SET @StDate = @From_Date+(@intRow*-1)
						SET @EDDate = @From_Date+(@intRow)
					   
						SET @intRow  = @intRow  + 1
					END

				Update	#tblLeaveDate 
				Set		LName = 'L' 
				Where	LeaveDate between @From_Date And @To_date
				
				Update	#tblLeaveDate 
				Set		LName='L' 
				From	#tblLeaveDate AS A
						Inner Join #Employee_Leave AS B On A.LeaveDate = B.For_Date
				where	Leave_Id = @Leave_ID 
				
				Update #tblLeaveDate
				set		LName = 'W'
				From	#tblLeaveDate AS A
						Inner Join #EMP_WEEKOFF AS B On A.LeaveDate = Cast(B.For_Date as date)
				
				Update #tblLeaveDate
				set		LName = 'H'
				From	#tblLeaveDate AS A
						Inner Join #EMP_HOLIDAY AS B On A.LeaveDate = Cast(B.For_Date as date)


				--Added by ronakk 11122023 for proper logic check
				SELECT LeaveDate
				     AS CurrentDate,
				    LAG(LeaveDate) OVER (ORDER BY LeaveDate) AS PreviousDate,
				    CASE 
				        WHEN DATEDIFF(DAY, LAG(LeaveDate) OVER (ORDER BY LeaveDate), LeaveDate) = 1 
				        THEN 'Continuity'
				        ELSE 'Gap Detected'
				    END AS ContinuityStatus
				into #LCCheck  FROM  #tblLeaveDate where LName='L'


				select  case when count(1)+1 >= @Attachment_day then 1 else 0 end  from #LCCheck where ContinuityStatus = 'Continuity'

				--End by ronakk 11122023 for proper logic check

				--DECLARE @Counter Numeric(18,2)
				--SET @Counter= 0

				

				--WHILE ( @StDate <= @EDDate)
				--	BEGIN
				--		If EXISTS (Select 1 From #tblLeaveDate Where LeaveDate =Cast(@StDate as date)And LName='L' )
				--			BEGIN
				--				
				--				
				--				Set @Counter = @Counter+1
				--
				--			
				--				if @Counter >= @Attachment_day
				--					Begin
				--						SET @StDate = @EDDate
				--						set @Counter = 1
				--						break;
				--					END
				--				Else  
				--					Begin
				--						SET @Counter =0
				--					End
				--			END
				--		Else
				--			Begin
				--				SET @Counter =0
				--			End
				--		SET @StDate  = @StDate+1
				--	END

				--SELECT @COUNTER		
			END

	END
		/*
		--Set @Attachment_day = (select top 1 Attachment_Days	from #Employee_Leave)
		set @Before_date =DATEADD(d, -(@Attachment_day-1), @From_Date)
		set @After_date =DATEADD(d, (@Attachment_day-1), @From_Date)

		--select * from #Employee_Leave
		--print @Attachment_day
		--print @Before_date
		--print @After_date
		
		
		SET @TMP_DATE = @From_Date;
		
		--print @TMP_DATE
		
		DECLARE @Required_Execution BIT;
		SET @Required_Execution = 0;

		IF OBJECT_ID('tempdb..#EMP_HOLIDAY') IS NULL
			BEGIN
				CREATE TABLE #EMP_HOLIDAY(EMP_ID NUMERIC, FOR_DATE DATETIME, IS_CANCEL BIT, Is_Half tinyint, Is_P_Comp tinyint, H_DAY numeric(4,1));
				CREATE UNIQUE CLUSTERED INDEX IX_EMP_HOLIDAY_EMPID_FORDATE ON #EMP_HOLIDAY(EMP_ID, FOR_DATE);
				SET @Required_Execution=1
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
				SET @Required_Execution=1
			END
			IF @Required_Execution = 1
				BEGIN
					EXEC SP_GET_HW_ALL @CONSTRAINT=@Emp_Id,@CMP_ID=@Cmp_ID, @FROM_DATE=@F_Date, @TO_DATE=@T_Date, @All_Weekoff = 1, @Exec_Mode=0		
				END
			
			 Bdate:
			 if exists(select 1 from #EMP_WEEKOFF where For_Date = @Before_date)
				 BEGIN
						SET @Before_date = DATEADD(d,-1,@Before_date )
						Goto Bdate;
				 End
			 Adate:
			 if exists(select 1 from #EMP_WEEKOFF where For_Date = @After_date)
				 begin
					SET @After_date = DATEADD(d,1,@After_date )
						Goto Adate;
				 ENd
				 
				 
			 insert into #Employee_Leave (Emp_Id,For_Date,Leave_Id,Leave_Period,Leave_Type)
			 SELECT Emp_ID,For_Date,@Leave_Id,W_Day,'Weekoff' from #EMP_WEEKOFF
				
			 insert into #Employee_Leave (Emp_Id,For_Date,Leave_Id,Leave_Period,Leave_Type)
			 select EMP_ID,FOR_DATE,@Leave_Id,H_DAY,'Holiday' from #EMP_HOLIDAY
				--select * from #Employee_Leave
				
			--changed jimit 19042016
			SET @Cnt = 0
			SET @Leave_Cnt = 0
			--ended
			
			

			delete from #Employee_Leave where Leave_Id <> @LEave_ID
			delete FROM #Employee_Leave where For_Date < @Before_date 
			delete FROM #Employee_Leave where For_Date > @After_date
			delete FROM #Employee_Leave where Application_Id = @Leave_Application_ID
			--select * from #Employee_Leave
			
		--select @TMP_DATE,@Before_date
		--SELECT * FROM #Employee_Leave

			if(@TMP_DATE >= @Before_date OR @TMP_DATE <= @After_date) 			
			BEGIN		
				IF EXISTS(SELECT 1 FROM #Employee_Leave where For_Date Between @Before_date and @TMP_DATE)			
				BEGIN	
					
					WHILE (@TMP_DATE >= @Before_date)
					BEGIN	
							

						  IF exists(select 1 FROM #Employee_Leave where For_Date = @TMP_DATE and Leave_Type Not IN ('Weekoff','Holiday'))
							  BEGIN					
								select @Cnt = sum(Leave_Period) FROM #Employee_Leave where For_Date = @TMP_DATE and Leave_Type Not IN ('Weekoff','Holiday')
								group BY For_Date
								set @Leave_Cnt = @Leave_Cnt + @Cnt										
							  END	
						  else if exists(select * from #Employee_Leave where For_Date = @TMP_DATE and Leave_Type In ('Weekoff','Holiday'))
							  begin
								 print 'Weekoff/Holiday'				
							  END
						 -- else
							--begin								
							--		--select @Cnt = sum(Leave_Period) FROM #Employee_Leave where For_Date = @TMP_DATE and Leave_Type Not IN ('Weekoff','Holiday')
							--		--group BY For_Date
							--		--set @Leave_Cnt = @Leave_Cnt + @Cnt																
							--		break;
							--end
						  set @TMP_DATE = DATEADD(d,-1,@TMP_DATE)								
					END
					
					
				end	
				
				IF @From_Date = @To_Date
					SET @TMP_DATE = DATEADD(d,1,@From_Date);
				else
					set @TMP_DATE = @To_Date			
				--select @TMP_DATE,@After_date	
				
				IF EXISTS(SELECT * FROM #Employee_Leave where For_Date Between @TMP_DATE and @After_date)			
				BEGIN			
					WHILE (@TMP_DATE <= @After_date)
					BEGIN
					--select @TMP_DATE						
						 IF exists(select 1 FROM #Employee_Leave where For_Date = @TMP_DATE and Leave_Type Not IN ('Weekoff','Holiday'))
							 BEGIN					
								select @Cnt = sum(Leave_Period) FROM #Employee_Leave where For_Date = @TMP_DATE and Leave_Type Not IN ('Weekoff','Holiday')
								group BY For_Date
								set @Leave_Cnt = @Leave_Cnt + @Cnt	

							 END
						 else if exists(select 1 from #Employee_Leave where For_Date = @TMP_DATE and Leave_Type In ('Weekoff','Holiday'))
							  begin
								 print 'Weekoff/Holiday'				
							  END
						 -- else
							--begin
							--	--select @Cnt = sum(Leave_Period) FROM #Employee_Leave where For_Date = @TMP_DATE and Leave_Type Not IN ('Weekoff','Holiday')
							--	--	group BY For_Date
							--	--	set @Leave_Cnt = @Leave_Cnt + @Cnt	
							--	break;
							--end
						 set @TMP_DATE = DATEADD(d,1,@TMP_DATE)
						 
					END
					--select @Leave_Cnt,2,@TMP_DATE,@After_date
				END
					
					
	
				set @Leave_Cnt = @Leave_Cnt + @Period
				
				--select @Leave_Cnt
				
				IF  @Leave_Cnt >= (@Attachment_day)
						SET @RETURN = 1;
						
					select @RETURN AS Column1
						 return;
				END	
			 ELSE
					
					SET @RETURN = 0;
					--select @RETURN
					
			
			END	
			*/
