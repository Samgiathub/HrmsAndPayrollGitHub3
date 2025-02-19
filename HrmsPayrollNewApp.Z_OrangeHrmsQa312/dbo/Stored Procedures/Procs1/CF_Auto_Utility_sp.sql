CREATE PROCEDURE [dbo].[CF_Auto_Utility_sp]
	@Cmp_ID_Pass	NUMERIC(18,0) = 0,
	@CC_Email		Nvarchar(max) = '',
	@Sch_Id			Numeric = 0
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
--RETURN -- Sajid
	BEGIN	
	
	
	DECLARE @Cmp_ID AS NUMERIC
	DECLARE @Cmp_Name AS varchar(100)
	DECLARE @Leave_ID AS NUMERIC
	DECLARE @Leave_CF_Type AS VARCHAR(32)
	DECLARE @Leave_CF_ID NUMERIC
	DECLARE @CF_DAYS	NUMERIC(18,4)
	DECLARE @Emp_ID		NUMERIC
	DECLARE @LeaveIDs	Varchar(1024)

	DECLARE @Start_Date AS DATETIME
	DECLARE @End_Date AS DATETIME
	DECLARE @For_Date AS DATETIME
	DECLARE @From_Date AS DATETIME
	DECLARE @To_Date AS DATETIME
	DECLARE @Is_Success AS INT  -- = 0
	DECLARE @Message AS varchar(50) -- = ''

	DECLARE @CF_Leave_Days	NUMERIC(18,4)  ------- Add By Jignesh Patel 09-Sep-2021------------
	Declare @Tran_type_flag varchar(30)	------- Add By Jignesh Patel 09-Sep-2021------------

	DECLARE @CF_For_Date	 AS DATETIME
	DECLARE @CF_From_Date	 AS DATETIME
	DECLARE @CF_To_Date		AS DATETIME


	CREATE TABLE #LEAVE_CF_DETAIL
	(
		[LEAVE_CF_ID] [NUMERIC](18, 0) NOT NULL identity(1,1),
		[Cmp_ID] [NUMERIC](18, 0) NOT NULL,
		[Emp_ID] [NUMERIC](18, 0) NOT NULL,
		[Leave_ID] [NUMERIC](18, 0) NOT NULL,
		[CF_For_Date] [DATETIME] NOT NULL,
		[CF_From_Date] [DATETIME] NOT NULL,
		[CF_To_Date] [DATETIME] NOT NULL,
		[CF_P_Days] [NUMERIC](18, 2) NOT NULL,
		[CF_Leave_Days] [NUMERIC](22, 8) NOT NULL,
		[CF_Type] [varchar](50) NOT NULL,
		[Exceed_CF_Days] [NUMERIC](22, 8) NULL,
		[Leave_CompOff_Dates] [nvarchar](MAX) NULL,
		[Is_Fnf] [tinyint] NOT NULL,
		[Advance_Leave_Balance] [NUMERIC](18, 2) NOT NULL DEFAULT 0,
		[Advance_Leave_Recover_balance] [NUMERIC](18, 2) NOT NULL DEFAULT 0,
		[Is_Advance_Leave_Balance][tinyint] NOT NULL DEFAULT 0
	)

	SELECT @LeaveIDs = LeaveIDs FROM t0299_Schedule_Master WITH (NOLOCK) Where Sch_id=@Sch_Id

	SET @Is_Success = 0  --added jimit 18042016
	SET @Message = ''  --added jimit 18042016
	
	SET @From_Date = CONVERT(DATETIME, CONVERT(VARCHAR(10),  GETDATE(), 103), 103)
	
	IF YEAR(GETDATE()) = YEAR(@From_Date)
		SET @From_Date = DATEADD(M, -1, @From_Date)

	SET @From_Date = DATEADD(d, (DAY(@From_Date)-1) * -1, @From_Date)
	SET @To_Date = DATEADD(D, -1, DATEADD(M, 1, @FROM_DATE))
	
	
	DECLARE @OUT INT
 
	IF @Cmp_ID_Pass = 0 
		SET @Cmp_ID_Pass = NULL
	
	CREATE TABLE #AutoCFLog 
	(
		out1      int
	)
	CREATE TABLE #CF_Detail 
	(
		leave_cf_id      NUMERIC(18,0),
		cf_leave_days	numeric(18,0),
		cf_p_days		numeric(18,0),
		cf_type			varchar (100),
		leave_id			numeric(18,0),
		emp_id			numeric(18,0)
	)	


	DECLARE curComp CURSOR FAST_FORWARD FOR 
	SELECT	Cmp_Id,IsNull(Cmp_Name,'') AS Cmp_Name 
	FROM	T0010_COMPANY_MASTER WITH (NOLOCK)
	WHERE	Cmp_Id = isnull(@Cmp_ID_Pass,Cmp_Id)

	OPEN curComp
	FETCH NEXT FROM curComp INTO @Cmp_ID,@Cmp_Name
	
	WHILE @@FETCH_STATUS = 0
		BEGIN			
			DECLARE curLeave CURSOR FAST_FORWARD FOR
			SELECT	LM.Leave_ID, Leave_CF_Type
			FROM	T0040_LEAVE_MASTER LM WITH (NOLOCK)
					INNER JOIN (SELECT Cast(Data As Numeric) As Leave_ID FROM dbo.Split(@LeaveIDs, '#') T Where Data <> '') T ON LM.Leave_ID=T.Leave_ID
			WHERE	Cmp_ID =@Cmp_ID AND (leave_cf_type Not In ('None','0'))  

			ORDER BY Leave_Name
					 
			OPEN curLeave
			FETCH NEXT FROM curLeave INTO @Leave_ID,@Leave_CF_Type
			WHILE @@FETCH_STATUS =0
				BEGIN
					
					INSERT INTO #AutoCFLog
					SELECT	RowId 
					FROM	t0100_CF_Auto_Log WITH (NOLOCK)
					WHERE	Cmp_ID =@Cmp_ID AND Leave_Id= @Leave_ID AND CAST(SystemDateTime AS date)=CAST(GetDate() AS date)													

					IF NOT EXISTS(SELECT 1 FROM t0100_CF_Auto_Log WITH (NOLOCK)
									WHERE	Cmp_ID =@Cmp_ID AND Leave_Id= @Leave_ID AND CAST(SystemDateTime AS date)=CAST(GetDate() AS date)
								 )
						BEGIN

						
							SET @Start_Date = @From_Date
							SET @End_Date = @To_Date

							
							IF @Leave_CF_Type  = 'Yearly'
								BEGIN
									SET @Start_Date = DATEADD(YYYY, YEAR(@FROM_DATE) - 1900, CAST('1900-01-01' AS DATETIME))
									IF YEAR(@Start_Date) = YEAR(GETDATE())
										SET @Start_Date = DATEADD(YYYY, -1, @Start_Date)
									SET @End_Date = DATEADD(D, -1, DATEADD(YYYY, 1, @Start_Date))
								END
									SET @For_Date = DATEADD(D, 1,@End_Date)
						
								
								-------------------Jignesh Patel 09-Sep-2021- For Daily-------------
									If @Leave_CF_Type = 'Daily (On Present Day)'
									Begin
									PRINT 'DOPD1'
									select    @Start_Date=dateadd(month, month(Getdate()) - 1, dateadd(year, year(Getdate()) - 1900, 0)) ,
											  @End_Date= dateadd(month, month(Getdate()),     dateadd(year, year(Getdate()) - 1900, -1)) 
								
									---If day('01-Sep-2021') = 1
									If day(getdate()) = 1
									Begin
										SELECT @Start_Date = dateadd(M,-1,@Start_Date),
										@End_Date=DATEADD(day,-1,DATEADD(MM, DATEDIFF(MM,0,dateadd(M,1,@Start_Date)),0))
										----DATEADD(day,-1,DATEADD(MM, DATEDIFF(MM,0,@Start_Date),0))
									End
									
									SET	@For_Date =  @End_Date

									print  @Start_Date
									print @End_Date
									
									--SET @Start_Date='2023-02-01' -- Sajid
									--SET @End_Date='2023-02-28' -- Sajid
									
									
									End 
								-------------------End Fof ------------------

								
									
								
									IF @Leave_CF_Type  = 'Monthly'
										BEGIN
											SET @Start_Date = @Start_Date
									IF Month(@Start_Date) = Month(GETDATE())
											SET @Start_Date = @Start_Date
											SET @End_Date = @End_Date
										END
											SET @For_Date = DATEADD(D, 1,@End_Date)
											--SET @Start_Date='2023-02-01' -- Sajid
											--SET @End_Date='2023-02-28' -- Sajid

										
									
									--Select @Start_Date,@End_Date,@For_Date
								
								-------------------End Fof ------------------
															

								Declare @Curr_Date as datetime
								SET @Curr_Date = Getdate()
								
								--SET @Start_Date='2023-02-01' -- Sajid
								--SET @End_Date='2023-02-28' -- Sajid
								--SET @Curr_Date='2023-02-28' -- Sajid
								--SET @For_Date='2023-03-01' -- Sajid

							TRUNCATE TABLE #LEAVE_CF_DETAIL
							EXEC SP_LEAVE_CF_Display @leave_Cf_ID=0,
													 @Cmp_ID=@Cmp_ID,
													 @From_Date=@Start_Date,
													 @To_Date=@Curr_Date, --@End_Date
													 @For_Date=@For_Date,
													 @Branch_ID='0',@Cat_ID=0,@Grd_ID=0,@Type_ID=0,@Dept_ID=0,@Desig_ID=0,
													 @Emp_ID = 0, -- Sajid
													 --@Emp_ID = 0,
													 @Constraint='',@P_LeavE_ID=@Leave_ID,@Segment_ID =0,@subBranch_ID =0,@Vertical_ID =0,@SubVertical_ID =0	
													 

							---@Emp_ID = 0,
							DECLARE @Is_Advance_Leave_Balance NUMERIC(1,0) -- Added by Sajid 27-03-2023
							DECLARE @Advance_Leave_Balance NUMERIC(18,2) -- Added by Sajid 27-03-2023
							
							--Select * From #LEAVE_CF_DETAIL
							--RETURN

							DECLARE curEmp CURSOR FAST_FORWARD FOR
							SELECT	Emp_ID,CF_P_Days,CF_Leave_Days  ,CF_For_Date,CF_From_Date,CF_To_Date,Advance_Leave_Balance,Is_Advance_Leave_Balance
							FROM	#LEAVE_CF_DETAIL 														

							OPEN	curEmp
							FETCH NEXT FROM curEmp INTO @Emp_ID, @CF_DAYS,@CF_Leave_Days,@CF_For_Date,@CF_From_Date,@CF_To_Date,@Advance_Leave_Balance,@Is_Advance_Leave_Balance
							WHILE @@FETCH_STATUS = 0
								BEGIN 
									
									
									SET	@For_Date =  @CF_To_Date
									If @Leave_CF_Type <> 'Daily (On Present Day)'
									Begin
										
										--IF @Leave_CF_Type  = 'Monthly'
										--BEGIN 
										--		EXEC P0100_LEAVE_CF_DETAIL 
										--		@Leave_CF_ID=@Leave_CF_ID output,
										--		@Cmp_ID=@Cmp_ID,
										--		@Emp_ID=@Emp_ID,
										--		@Leave_ID=@Leave_ID,
										--		@CF_For_Date=@For_Date,
										--		@CF_From_Date=@Start_Date,
										--		@CF_To_Date=@End_Date,
										--		@CF_P_Days=@CF_DAYS,
										--		@CF_Leave_Days=0,
										--		@CF_Type=@Leave_CF_Type,
										--		@tran_type='Insert',
										--		@Leave_CompOff_Dates='',
										--		@Reset_Flag='1',
										--		@User_Id='0',
										--		@IP_Address='192.168.1.255',
										--		@Advance_Leave_Balance=@Advance_Leave_Balance,
										--		@Advance_Leave_Recover_Balance='0',
										--		@New_Joing_Falg='0',
										--		@Login_ID=0,
										--		@Auto_Monthly = 1
										--END
										--ELSE
										--BEGIN
												EXEC P0100_LEAVE_CF_DETAIL 
												@Leave_CF_ID=@Leave_CF_ID output,
												@Cmp_ID=@Cmp_ID,
												@Emp_ID=@Emp_ID,
												@Leave_ID=@Leave_ID,
												@CF_For_Date=@For_Date,
												@CF_From_Date=@Start_Date,
												@CF_To_Date=@End_Date,
												@CF_P_Days=@CF_DAYS,
												@CF_Leave_Days=0,
												@CF_Type=@Leave_CF_Type,
												@tran_type='Insert',
												@Leave_CompOff_Dates='',
												@Reset_Flag='1',
												@User_Id='0',
												@IP_Address='192.168.1.255',
												@Advance_Leave_Balance=@Advance_Leave_Balance,
												@Advance_Leave_Recover_Balance='0',
												@New_Joing_Falg='0',
												@Login_ID=0
										--END
										
									End
								ELSE
								
								Begin
																
							
								If Not Exists(Select 1 From T0100_LEAVE_CF_DETAIL WITH (NOLOCK) Where Emp_Id = @Emp_Id 
																	And Leave_Id = @Leave_ID And CF_For_Date = @CF_From_Date--@For_Date
																	) 
									Begin
											Set @Tran_type_flag = 'Insert'
											SET @Leave_CF_ID= 0
											
									End
								Else
									Begin
											Set @Tran_type_flag = 'Update'
											Select @Leave_CF_ID=Leave_CF_ID From T0100_LEAVE_CF_DETAIL WITH (NOLOCK) Where Emp_Id = @Emp_Id 
																	And Leave_Id = @Leave_ID And CF_For_Date = @CF_From_Date -- @For_Date
									End
											print @Tran_type_flag

											EXEC P0100_LEAVE_CF_DETAIL 
											@Leave_CF_ID= @Leave_CF_ID output,
											@Cmp_ID=@Cmp_ID,
											@Emp_ID=@Emp_ID,
											@Leave_ID=@Leave_ID,
											@CF_For_Date=   @CF_From_Date,--@CF_For_Date, ---@For_Date,
											@CF_From_Date=  @CF_From_Date, ----@Start_Date,
											@CF_To_Date=    @CF_To_Date,   ---- @End_Date,
											@CF_P_Days=@CF_DAYS,
											@CF_Leave_Days=@CF_Leave_Days,
											@CF_Type=@Leave_CF_Type,
											@tran_type=@Tran_type_flag,
											@Leave_CompOff_Dates='',
											@Reset_Flag='1',
											@User_Id='0',
											@IP_Address='192.168.1.255',
											@Advance_Leave_Balance=@Advance_Leave_Balance,
											@Advance_Leave_Recover_Balance='0',
											@New_Joing_Falg='0',
											@Login_ID=0
									End
									FETCH NEXT FROM curEmp INTO @Emp_ID, @CF_DAYS,@CF_Leave_Days ,@CF_For_Date,@CF_From_Date,@CF_To_Date,@Advance_Leave_Balance,@Is_Advance_Leave_Balance
								END
							CLOSE	curEmp
							DEALLOCATE	curEmp
								
							---Daily (On Present Day) Add Jignesh Patel 09-Sep-2021
														

							--INSERT INTO #CF_Detail 
							--exec  SP_LEAVE_CF 0,@Cmp_ID,@Start_Date,@End_Date,@For_Date,0,0,0,0,0,0,0,'',@Leave_ID,0,0
						
							--SELECT @OUT = COUNT(*) from #CF_Detail	
							--SELECT * FROM #LEAVE_CF_DETAIL
							--RETURN
													
							IF @Leave_CF_ID > 0
								BEGIN
 									SET @Is_Success = 1
									SET @Message= 'Carry Forward Process is Done Successfully'
								END		
							ELSE
								BEGIN
									SET @Is_Success = 0
									SET @Message= ''
								END
												
							INSERT INTO dbo.T0100_CF_AUTO_LOG(Cmp_ID,Leave_Id,SystemDateTime,Is_Success,From_Date,To_Date,Comment) 
							VALUES (@Cmp_ID,@Leave_ID,GetDate(),@Is_Success,@Start_Date,@End_Date,@Message)
						
						
							DELETE FROM #CF_Detail
							DELETE FROM #AutoCFLog							
							SET @OUT = 0												
						END
					FETCH NEXT FROM curLeave INTO @Leave_ID,@Leave_CF_Type
				END
			CLOSE curLeave
			DEALLOCATE curLeave
		
			FETCH NEXT FROM curComp into @Cmp_ID,@Cmp_Name
		END
	CLOSE curComp
	DEALLOCATE curComp

	DROP TABLE #CF_Detail
	DROP TABLE #AutoCFLog	
END

