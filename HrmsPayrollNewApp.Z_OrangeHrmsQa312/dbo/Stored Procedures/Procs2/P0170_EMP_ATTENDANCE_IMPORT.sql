
 
CREATE PROCEDURE [dbo].[P0170_EMP_ATTENDANCE_IMPORT]
	@EMP_CODE			varchar(40),
	@CMP_ID				Int,
	@Month				Int,
	@Year				Int,
	@Att_Detail		nvarchar(max),
	@Att_Detail_2   nvarchar(max),
	@Login_Id			Int,
	@Row_No				int,
	@Log_Status Int = 0 Output,
	@GUID			varchar(2000) = '' --Added by nilesh patel on 15062016
	AS

	SET NOCOUNT ON 
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON
	SET ANSI_WARNINGS OFF;

		Declare @Emp_ID			Numeric
        Declare @Branch_Id as int
        declare @Leave_Approval_Id varchar(40)
        declare @IsImport int -- added by Prakash Patel 27112015
      
		--select @Emp_ID = isnull(Emp_ID,0) ,@Branch_Id = Branch_Id from T0080_Emp_Master where  Cmp_ID =@Cmp_ID and Alpha_Emp_Code = @EMP_CODE
		--Added By Ramiz on 19/02/2016
		select @Emp_ID = isnull(Emp_ID,0) 
		from T0080_Emp_Master E WITH (NOLOCK) where  Cmp_ID =@Cmp_ID and Alpha_Emp_Code = @EMP_CODE
		
		if @Emp_ID is null
		Begin
			Set @Emp_ID = 0
		End

		--- Added by Hardik 06/01/2021 for Gujarat Terce and APHC
		If @Login_Id = 0
			Select Top 1  @Login_Id = Login_ID from T0011_LOGIN WITH (NOLOCK) where Cmp_id =@CMP_ID And Login_Name like 'Admin@%'

		
		if @Emp_ID = 0 
		Begin
			SET @Log_Status = 1
			INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@EMP_CODE ,'Employee Doesn''t exists',@EMP_CODE,'Enter proper Employee Code',GetDate(),'Attendance Import',@GUID)			
			RETURN
		End
	
		if @Month = 0
		Begin
			SET @Log_Status = 1
			INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@EMP_CODE ,'Month Details Doesn''t exists',@EMP_CODE,'Enter proper Month Details',GetDate(),'Attendance Import',@GUID)			
			RETURN
		End

		if @Year = 0
		Begin
			SET @Log_Status = 1
			INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@EMP_CODE ,'Year Details Doesn''t exists',@EMP_CODE,'Enter proper Year Details',GetDate(),'Attendance Import',@GUID)			
			RETURN
		End
		
		
		select @Branch_Id = Branch_Id from  T0095_INCREMENT I1 WITH (NOLOCK)
		INNER JOIN (
					SELECT	MAX(I2.Increment_ID) AS Increment_ID,I2.Emp_ID 
					FROM	T0095_Increment I2 WITH (NOLOCK)
							INNER JOIN (
											SELECT MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE,I3.Emp_ID
											FROM T0095_INCREMENT I3 WITH (NOLOCK)
											WHERE I3.Increment_effective_Date <= dbo.GET_MONTH_END_DATE(@Month,@Year) AND I3.Cmp_ID =@Cmp_ID and I3.Emp_ID=@Emp_ID
											GROUP BY I3.Emp_ID
										) I3 ON I2.Increment_Effective_Date=I3.Increment_Effective_Date AND I2.Emp_ID=I3.Emp_ID																		
					WHERE	I2.Cmp_ID = @Cmp_Id 
					GROUP BY I2.Emp_ID
				) I ON I1.Emp_ID = I.Emp_ID AND I1.Increment_ID=I.Increment_ID --Modified by SUmit on 11/08/2016 branch id wrong issue occured in Dubond Client
				
		
		
		Declare @LogDesc	nvarchar(max)	
		IF EXISTS(SELECT EMP_ID FROM  T0200_MONTHLY_SALARY WITH (NOLOCK) WHERE Cmp_ID=@Cmp_ID and EMP_ID=@EMP_ID AND month(Month_End_Date)=@Month and Year(Month_End_Date)=@Year)
			Begin			
				set @LogDesc = 'Monthly salary Exists ' + ' Emp_Code='+@EMP_CODE +', Month='+cast(@Month as varchar)+', Year='+cast(@Year as varchar)
				set @Log_Status = 1
				Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@EMP_CODE, @LogDesc ,'','Import proper Data',GetDate(),'Import Data',@GUID)
				Raiserror(@LogDesc,16,2)
				--exec Event_Logs_Insert 0,@Cmp_ID,@Emp_Id,@Login_ID,'Import','Monthly salary Exists',@LogDesc,1,''			
				--Raiserror('Salary Exists',16,2)
				return -1
			End  
		
		Declare @Tran_Id		Numeric 
		Select @Tran_Id = isnull(max(Tran_Id),0) + 1  from T0170_EMP_ATTENDANCE_IMPORT WITH (NOLOCK)

		Select * into #tblAtt_Detail from dbo.Split(@Att_Detail ,'#')
		Select * into #tblAtt_Detail2 from dbo.Split(@Att_Detail_2 ,'#')
					
		Declare @PresentDays Numeric(18,2)
		Declare @AbsentDays Numeric(18,2)
		
		select @PresentDays =
		sum(
		Case When isnull(a.Data,'') = 'P' And ISNULL(b.Data,'') ='' then 1 else 0 end 
		+Case When isnull(a.Data,'') = 'P' And ISNULL(b.Data,'') <>'' then 0.5 else 0 end 
		+ Case When isnull(b.Data,'') = 'P' And ISNULL(a.Data,'') <> '' then 0.5 else 0 end 
		)
		from #tblAtt_Detail as A left outer join #tblAtt_Detail2 as B on A.id = B.Id  
			
		select @AbsentDays =
		sum(Case When isnull(a.Data,'') = 'A' And ISNULL(b.Data,'') ='' then 1 else 0 end 
		+ Case When isnull(a.Data,'') = 'A' And ISNULL(b.Data,'') <>'' then 0.5 else 0 end 
		+ Case When isnull(b.Data,'') = 'A' And ISNULL(a.Data,'') <>'' then 0.5 else 0 end 
		)
		from #tblAtt_Detail as A left outer join #tblAtt_Detail2 as B on A.id = B.Id  
		
		
		Declare @WeekOff Numeric(18,0)
		select @WeekOff = isnull(COUNT(*),0) from dbo.Split(@Att_Detail ,'#')where Data ='W'
		
		Declare @Holiday Numeric(18,0)
		select @Holiday = isnull(COUNT(*),0) from dbo.Split(@Att_Detail ,'#')where Data ='HO'
		
		--------- Salary Date ------------------

		   declare @manual_salary_period as numeric(18,0) 
		   declare @Sal_St_Date as datetime
		   declare @Sal_End_Date as datetime
		   
		   declare @Month_St_Date as datetime
		   declare @Month_End_Date as datetime
		   
		   declare @OutOf_Days as int
		   
		  
		  --set @Month_St_Date  = cast('01' + '-' + (cast(@Month as varchar(10)) + '-' +  cast( @Year as varchar(10)) as smalldatetime)  
		  set @Month_St_Date  =  convert(datetime,CAST( '01' as varchar(2)) + '/' +(CAST( @Month as varchar(2))) +'/'+ CAST(@year as varchar(4)) ,103)
		  set @Month_End_Date = dateadd(d,-1,dateadd(m,1,@Month_St_Date))
		  
		  select @Sal_St_Date  =Sal_st_Date ,@manual_salary_period=isnull(Manual_Salary_Period ,0) 
		  from T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @CMP_ID and Branch_ID = @Branch_Id
		  and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@Month_End_Date and Branch_ID = @Branch_ID and Cmp_ID = @Cmp_ID)    


			if isnull(@Sal_St_Date,'') = ''    
				  begin    
						set @Month_St_Date  = @Month_St_Date     
						set @Month_End_Date = @Month_End_Date    

						Set @Sal_St_Date = @Month_St_Date
						Set @Sal_End_Date  = @Month_End_Date

						set @OutOf_Days = @OutOf_Days
				  end     
			 else if day(@Sal_St_Date) =1    
				  begin    
					   --set @Month_St_Date  = @Month_St_Date     
					   --set @Month_End_Date = @Month_End_Date    
					   --set @OutOf_Days = @OutOf_Days  
					   
						set @Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,@Month_St_Date) as varchar(10)) + '-' +  cast(year(@Month_St_Date )as varchar(10)) as smalldatetime)    
						set @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date)) 
						set @OutOf_Days = datediff(d,@Sal_St_Date,@Sal_End_Date) + 1
				   
						Set @Month_St_Date = @Sal_St_Date
						Set @Month_End_Date = @Sal_End_Date 
				          	         
				  end     
			 else if @Sal_St_Date <> ''  and day(@Sal_St_Date) > 1   
				  begin    
						 if @manual_salary_period = 0 
					   begin
					        
					        			        
							set @Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,@Month_St_Date)) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@Month_St_Date) )as varchar(10)) as smalldatetime)    
							--set @Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(month(@Month_St_Date) as varchar(10)) + '-' +  cast(year(@Month_St_Date) as varchar(10)) as smalldatetime)    
					        
							set @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date)) 
							set @OutOf_Days = datediff(d,@Sal_St_Date,@Sal_End_Date) + 1
					   
							Set @Month_St_Date = @Sal_St_Date
							Set @Month_End_Date = @Sal_End_Date 

					
					   end 
					 else
						begin
							select @Sal_St_Date=from_date,@Sal_End_Date=end_date from salary_period where month= month(@Month_St_Date) and YEAR=year(@Month_St_Date)
							set @OutOf_Days = datediff(d,@Sal_St_Date,@Sal_End_Date) + 1
						   
							Set @Month_St_Date = @Sal_St_Date
							Set @Month_End_Date = @Sal_End_Date 
						end   
			  end
		----------------------------------------

		----------- Remove Data From Table---------------		
				delete from T0170_EMP_ATTENDANCE_IMPORT 
				where Emp_ID= @Emp_ID And Cmp_ID= @CMP_ID And [MONTH] = @Month And [Year]=@Year

				Select Leave_Approval_Id,Is_Import into #Leave_Approval_Id from T0130_Leave_Approval_detail WITH (NOLOCK) where Leave_Approval_Id
				in (select Leave_Approval_Id from T0120_Leave_Approval WITH (NOLOCK)
					where Emp_ID= @Emp_ID And Cmp_ID= @CMP_ID )
				--and MONTH(From_Date)=@Month and year(From_Date)=@Year 
				and From_Date>=@Sal_St_Date and From_Date<=@Sal_End_Date
				and  Cmp_ID= @CMP_ID
				
				 
				
				DECLARE Leave_Approval_Cursor CURSOR FOR 
				SELECT Leave_Approval_Id,Is_Import FROM #Leave_Approval_Id 
				
				OPEN Leave_Approval_Cursor

				FETCH NEXT FROM Leave_Approval_Cursor INTO @Leave_Approval_Id,@IsImport

				WHILE @@FETCH_STATUS = 0
					BEGIN
						IF @IsImport = 2 -- put this condition for Aprica pharma, it check Leave enter from webpayroll or direct import from excel sheet 0 as dirct import and 1 as import
							BEGIN
								DELETE from T0130_Leave_Approval_detail where Leave_Approval_Id =@Leave_Approval_Id
								DELETE from T0120_Leave_Approval where Leave_Approval_Id = @Leave_Approval_Id
							END
			
					--in (select Leave_Approval_Id from #Leave_Approval_Id) 
						FETCH NEXT FROM Leave_Approval_Cursor INTO @Leave_Approval_Id,@IsImport
					END 
				CLOSE Leave_Approval_Cursor;
				DEALLOCATE Leave_Approval_Cursor;
				
				-- Comment by Prakash Patel 27112015
				--delete from T0120_Leave_Approval where Leave_Approval_Id in
				--(Select Leave_Approval_Id  from #Leave_Approval_Id )
			
				--------------------------------
			--Added by Jaina 17-01-2019	 Start			    
			Declare @Grd_Id numeric(18,0)
		  	if exists (select 1 from #tblAtt_Detail where data  NOT IN ('A', 'P', 'W', 'HO') and Data <> '')
			BEGIN		
				select @Grd_Id = i.Grd_ID FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN
				( SELECT * FROM dbo.fn_getEmpIncrement(@cmp_id,@EMP_ID,GETDATE()))As GI on GI.Increment_ID = I.Increment_ID
															
				IF not exists (SELECT 1 FROM  T0050_LEAVE_DETAIL LD WITH (NOLOCK) inner join 
											  T0040_LEAVE_MASTER   L WITH (NOLOCK) ON LD.Leave_ID = L.Leave_ID 
								where L.Cmp_ID=@Cmp_Id AND Grd_ID=@Grd_Id 
								AND L.Leave_Code IN (select data from #tblAtt_Detail where data  NOT IN ('A', 'P', 'W', 'HO')  and Data <> ''))
				BEGIN

						SET @Log_Status=1
						Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Emp_Code,'Leave is not assigned to employee grade','','Assign Grade in Leave Detail',GetDate(),'Attendance Import',@GUID)		
						return	
				END	
			END
			--Added by Jaina 17-01-2019	 End
		
		insert into T0170_EMP_ATTENDANCE_IMPORT
		(
		Tran_Id	,
		Emp_ID	,
		Cmp_ID	,
		[Month]	,
		[Year]	,
		Att_Detail ,
		PresentDays,
		WeeklyOff,
		Holiday	,
		Absent	,
		System_Date ,
		Login_Id
		)
		values
		(
		@Tran_Id,
		@Emp_ID,
		@CMP_ID,
		@Month,
		@Year,
		@Att_Detail+'/'+@Att_Detail_2,
		@PresentDays,
		@WeekOff,
		@Holiday,
		@AbsentDays,
		GETDATE(),
		@Login_Id
		)
		
---------------------------------------------------------------------
---------- Leave Import----------------

	declare @LeaveName varchar(40)
	declare @LeaveDate Datetime
	declare @LeaveAssing varchar(40)
	declare @LeavePeriod Decimal(18,2)
	
	Declare @Prev_LeaveName varchar(40)
	Declare @Prev_LeaveDate Datetime
	Declare @Prev_LeaveAssing varchar(40)
	declare @Prev_LeavePeriod Decimal(18,2)

	
	CREATE TABLE #TMP_ATTENDANCE
	(
		ID			INT,
		FOR_DATE	DATETIME,
		DATA_1		VARCHAR(16),
		DATA_2		VARCHAR(16),
		ASSIGN_1	VARCHAR(32),
		ASSIGN_2	VARCHAR(32),
		Period_1	Numeric(9,2),
		Period_2	Numeric(9,2)
	)

	INSERT INTO #TMP_ATTENDANCE(ID, FOR_DATE, DATA_1, DATA_2)
	SELECT	A1.ID, DATEADD(D, A1.ID-1,@Sal_St_Date), ISNULL(A1.Data,'') AS A1_DATA, ISNULL(A2.Data,'') AS A2_DATA	
	FROM	#tblAtt_Detail A1 FULL OUTER JOIN #tblAtt_Detail2 A2 ON A1.Id=A2.Id

	UPDATE	A
	SET		ASSIGN_1 =	CASE	WHEN	DATA_2 = '' THEN
									CASE	WHEN DATA_1 NOT IN ('A', 'P', 'W', 'HO') THEN 
											'Full Day'
										ELSE	
											'' 
									END
								WHEN	DATA_1 NOT IN ('A', 'P', 'W', 'HO', '') THEN
										'First Half'
								ELSE
										''
						END,
			ASSIGN_2 =	CASE	WHEN	DATA_2  NOT IN ('A', 'P', 'W', 'HO', '')  THEN
								'Second Half'
						ELSE
								''
						END
	FROM	#TMP_ATTENDANCE A

	UPDATE	A
	SET		Period_1 = CASE WHEN ASSIGN_1 IN ('First Half', 'Second Half') THEN 0.5 WHEN ASSIGN_1 IN ('Full Day') THEN 1 ELSE 0 END,
			Period_2 = CASE WHEN ASSIGN_2 IN ('First Half', 'Second Half') THEN 0.5 WHEN ASSIGN_2 IN ('Full Day') THEN 1 ELSE 0 END
	FROM	#TMP_ATTENDANCE A

	
	DECLARE Leave_Cursor CURSOR FOR 
	SELECT	Leave_Name,For_Date As LeaveDate, ASSIGN_1 As Leave_Assign, Period_1 As Leave_Period
	FROM	(SELECT	ID, FOR_DATE, DATA_1, ASSIGN_1, LEAVE_NAME, Period_1
			FROM	#TMP_ATTENDANCE A
				INNER JOIN T0040_LEAVE_MASTER L WITH (NOLOCK) ON A.DATA_1=L.Leave_Code
			WHERE	L.Cmp_ID=@CMP_ID) A1
	UNION ALL
	SELECT	Leave_Name,For_Date As LeaveDate, ASSIGN_2 As Leave_Assign, Period_2 As Leave_Period
	FROM	(SELECT	ID, FOR_DATE, DATA_2, ASSIGN_2, LEAVE_NAME, Period_2	
			FROM	#TMP_ATTENDANCE A
				INNER JOIN T0040_LEAVE_MASTER L WITH (NOLOCK) ON A.DATA_2=L.Leave_Code
			WHERE	L.Cmp_ID=@CMP_ID) A2
	ORDER BY LeaveDate
		--select 
		--A.Leave_Name,
		----convert(datetime,CAST( A.id as varchar(2)) + '/' +(CAST( @Month as varchar(2))) +'/'+ CAST(@year as varchar(4)) ,103) as LeaveDate 
		--dateadd(day, A.id-1,@Sal_St_Date) as LeaveDate 
		--,B.Leave_Assign,B.Leave_Period
		--from (select a.Id,a.data,b.Leave_Name from #tblAtt_Detail as a inner join dbo.T0040_LEAVE_MASTER as b
		--on a.Data = b.Leave_Code and b.Cmp_ID = @CMP_ID
		--union all
		--select a.Id,a.data,b.Leave_Name from #tblAtt_Detail2 as a inner join dbo.T0040_LEAVE_MASTER as b
		--on a.Data = b.Leave_Code and b.Cmp_ID = @CMP_ID
		--)  as A
		
		--inner join (
		
		--select 
		--A.id,
		--a.Data,
		----b.data,
		--Case When  isnull(a.Data,'') Not in ('A','P','W','HO') And ISNULL(b.Data,'') ='' then 'Full Day' else 
		--Case When isnull(a.Data,'') <>''  And ISNULL(b.Data,'')in ('A','P') then 'First Half' else 
		--Case When isnull(a.Data,'') in ('A','P') And ISNULL(b.Data,'') <> '' then 'Second Half' else
		--Case When isnull(a.Data,'') not in ('A','P','W','HO')  then 'First Half' else
		--Case When isnull(b.Data,'') not in ('A','P','W','HO')  then 'Second Half' End end end end end as  Leave_Assign
				
		--,Case When  isnull(a.Data,'')Not in ('A','P','W','HO') And ISNULL(b.Data,'') ='' then 1 else 
		--Case When isnull(a.Data,'')  <>''  And ISNULL(b.Data,'')in ('A','P') then 0.5 else 
		--Case When isnull(a.Data,'') in ('A','P') And ISNULL(b.Data,'') <> '' then 0.5  else 
		--Case When isnull(a.Data,'') not in ('A','P','W','HO') And ISNULL(b.Data,'') not in ('A','P','W','HO') then 0.5  end end end end as  Leave_Period
		
		--from #tblAtt_Detail as A Left Outer join #tblAtt_Detail2 as B on A.id = B.Id  
		--) as B on A.id = b.id  order by LeaveDate
		
		OPEN Leave_Cursor

		FETCH NEXT FROM Leave_Cursor 
		INTO @LeaveName, @LeaveDate,@LeaveAssing,@LeavePeriod

		WHILE @@FETCH_STATUS = 0
		BEGIN
			If @Prev_LeaveDate = @LeaveDate And @Prev_LeaveAssing = 'First Half' And @Prev_LeavePeriod = 0.5
				Begin
					Set @LeaveAssing = 'Second Half'
				End
			
		   exec P0120_LEAVE_APPROVAL_IMPORT @CMP_ID,@EMP_CODE,@LeaveName,@LeaveDate,@LeavePeriod
											 ,@LeaveAssing,'',@Login_Id,2,'I',0,0,1
			
			Set @Prev_LeaveDate = @LeaveDate
			Set @Prev_LeaveAssing = @LeaveAssing
			Set @Prev_LeaveName = @LeaveName
			Set @Prev_LeavePeriod = @LeavePeriod
 
		FETCH NEXT FROM Leave_Cursor 
		INTO @LeaveName, @LeaveDate,@LeaveAssing,@LeavePeriod
		END 
		CLOSE Leave_Cursor;
		DEALLOCATE Leave_Cursor;
---------------------------------------
	



