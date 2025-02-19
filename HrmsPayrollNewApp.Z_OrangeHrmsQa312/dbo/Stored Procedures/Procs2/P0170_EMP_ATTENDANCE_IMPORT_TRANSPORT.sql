

 ---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0170_EMP_ATTENDANCE_IMPORT_TRANSPORT]
	@EMP_CODE varchar(40),
	@CMP_ID numeric(18,0),
	@Month Int,
	@Year Int,
	@Att_Detail nvarchar(MAX),
	@Login_Id numeric(18,0),
	@Row_No int = 0,
	@Log_Status Int = 0 Output,
	@GUID Varchar(2000) = '' --Added by nilesh patel on 15062016
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

DECLARE @Emp_ID Numeric(18,0)
DECLARE @Branch_Id Numeric(18,0)
DECLARE @Leave_Approval_Id varchar(40)
DECLARE @IsImport int
DECLARE @LogDesc nvarchar(max)
DECLARE @Tran_Id Numeric(18,0)
DECLARE @PresentDays Numeric(18,2)
DECLARE @AbsentDays Numeric(18,2)
DECLARE @WeekOff Numeric(18,0)
DECLARE @Holiday Numeric(18,0)

Set @Emp_ID = 0
      
SELECT @Emp_ID = ISNULL(Emp_ID,0),@Branch_Id = Branch_Id FROM T0080_Emp_Master WITH (NOLOCK) WHERE Cmp_ID =@Cmp_ID AND Alpha_Emp_Code = @EMP_CODE

if @Emp_ID is null
	Begin
		Set @Emp_ID = 0
	End
	
if @Emp_ID = 0 
	Begin
		SET @Log_Status = 1
		INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@EMP_CODE ,'Employee Doesn''t exists',@EMP_CODE,'Enter proper Employee Code',GetDate(),'Transport Attendance',@GUID)			
		RETURN
	End
	
if @Month = 0
	Begin
		SET @Log_Status = 1
		INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@EMP_CODE ,'Month Details Doesn''t exists',@EMP_CODE,'Enter proper Month Details',GetDate(),'Transport Attendance',@GUID)			
		RETURN
	End

if @Year = 0
	Begin
		SET @Log_Status = 1
		INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@EMP_CODE ,'Year Details Doesn''t exists',@EMP_CODE,'Enter proper Year Details',GetDate(),'Transport Attendance',@GUID)			
		RETURN
	End
 
IF EXISTS(SELECT EMP_ID FROM  T0200_MONTHLY_SALARY WITH (NOLOCK) WHERE Cmp_ID=@Cmp_ID and EMP_ID=@EMP_ID AND month(Month_End_Date)=@Month and Year(Month_End_Date)=@Year)
	BEGIN
		SET @LogDesc = 'Monthly salary Exists ' + ' Emp_Code='+@EMP_CODE +', Month='+cast(@Month as varchar)+', Year='+cast(@Year as varchar)
		SET @Log_Status = 1
		INSERT INTO T0080_Import_Log VALUES(@Row_No,@Cmp_Id,@EMP_CODE, @LogDesc ,'','Import proper Data',GetDate(),'Import Data',@GUID)
		Raiserror(@LogDesc,16,2)
		RETURN -1
	END
	
	SELECT @Tran_Id = ISNULL(MAX(Tran_Id),0) + 1  FROM T0170_EMP_ATTENDANCE_IMPORT_TRANSPORT WITH (NOLOCK)

	SELECT * INTO #tblAtt_DetailTransport from dbo.Split(@Att_Detail ,'#')

	SELECT @PresentDays = SUM(CASE WHEN ISNULL(Data,'') = 'P' THEN 1 ELSE 0 END) FROM #tblAtt_DetailTransport

	SELECT @AbsentDays = SUM(CASE WHEN ISNULL(Data,'') = 'A' THEN 1 ELSE 0 END) FROM #tblAtt_DetailTransport

	SELECT @WeekOff = ISNULL(COUNT(*),0) from dbo.Split(@Att_Detail ,'#')where Data ='W'
			
	SELECT @Holiday = isnull(COUNT(*),0) from dbo.Split(@Att_Detail ,'#')where Data ='HO'
	
	DELETE FROM T0170_EMP_ATTENDANCE_IMPORT_TRANSPORT WHERE Emp_ID= @Emp_ID AND Cmp_ID= @CMP_ID AND [MONTH] = @Month AND [Year]=@Year

	INSERT INTO T0170_EMP_ATTENDANCE_IMPORT_TRANSPORT(Tran_Id,Emp_ID,Cmp_ID,[Month],[Year],Att_Detail,PresentDays,WeeklyOff,
	Holiday,Absent,System_Date,Login_Id)VALUES(@Tran_Id,@Emp_ID,@CMP_ID,@Month,@Year,@Att_Detail,@PresentDays,@WeekOff,@Holiday,
	@AbsentDays,GETDATE(),@Login_Id)
		

--SELECT * FROM #tblAtt_DetailTransport
--RETURN 
		
		----------- Salary Date ------------------

		--   declare @manual_salary_period as numeric(18,0) 
		--   declare @Sal_St_Date as datetime
		--   declare @Sal_End_Date as datetime
		   
		--   declare @Month_St_Date as datetime
		--   declare @Month_End_Date as datetime
		   
		--   declare @OutOf_Days as int
		   
		  
		--  --set @Month_St_Date  = cast('01' + '-' + (cast(@Month as varchar(10)) + '-' +  cast( @Year as varchar(10)) as smalldatetime)  
		--  set @Month_St_Date  =  convert(datetime,CAST( '01' as varchar(2)) + '/' +(CAST( @Month as varchar(2))) +'/'+ CAST(@year as varchar(4)) ,103)
		--  set @Month_End_Date = dateadd(d,-1,dateadd(m,1,@Month_St_Date))
		  
		--  select @Sal_St_Date  =Sal_st_Date ,@manual_salary_period=isnull(Manual_Salary_Period ,0) 
		--  from T0040_GENERAL_SETTING where cmp_ID = @CMP_ID and Branch_ID = @Branch_Id
		--  and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING where For_Date <=@Month_End_Date and Branch_ID = @Branch_ID and Cmp_ID = @Cmp_ID)    


		--	if isnull(@Sal_St_Date,'') = ''    
		--		  begin    
		--			   set @Month_St_Date  = @Month_St_Date     
		--			   set @Month_End_Date = @Month_End_Date    
		--			   set @OutOf_Days = @OutOf_Days
		--		  end     
		--	 else if day(@Sal_St_Date) =1    
		--		  begin    
		--			   --set @Month_St_Date  = @Month_St_Date     
		--			   --set @Month_End_Date = @Month_End_Date    
		--			   --set @OutOf_Days = @OutOf_Days  
					   
		--				set @Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,@Month_St_Date) as varchar(10)) + '-' +  cast(year(@Month_St_Date )as varchar(10)) as smalldatetime)    
		--				set @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date)) 
		--				set @OutOf_Days = datediff(d,@Sal_St_Date,@Sal_End_Date) + 1
				   
		--				Set @Month_St_Date = @Sal_St_Date
		--				Set @Month_End_Date = @Sal_End_Date 
				          	         
		--		  end     
		--	 else if @Sal_St_Date <> ''  and day(@Sal_St_Date) > 1   
		--		  begin    
		--				 if @manual_salary_period = 0 
		--			   begin
					        
					        			        
		--					set @Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,@Month_St_Date)) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@Month_St_Date) )as varchar(10)) as smalldatetime)    
		--					--set @Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(month(@Month_St_Date) as varchar(10)) + '-' +  cast(year(@Month_St_Date) as varchar(10)) as smalldatetime)    
					        
		--					set @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date)) 
		--					set @OutOf_Days = datediff(d,@Sal_St_Date,@Sal_End_Date) + 1
					   
		--					Set @Month_St_Date = @Sal_St_Date
		--					Set @Month_End_Date = @Sal_End_Date 

					
		--			   end 
		--			 else
		--				begin
		--					select @Sal_St_Date=from_date,@Sal_End_Date=end_date from salary_period where month= month(@Month_St_Date) and YEAR=year(@Month_St_Date)
		--					set @OutOf_Days = datediff(d,@Sal_St_Date,@Sal_End_Date) + 1
						   
		--					Set @Month_St_Date = @Sal_St_Date
		--					Set @Month_End_Date = @Sal_End_Date 
		--				end   
		--	  end
		------------------------------------------

		------------- Remove Data From Table---------------		
		--		delete from T0170_EMP_ATTENDANCE_IMPORT 
		--		where Emp_ID= @Emp_ID And Cmp_ID= @CMP_ID And [MONTH] = @Month And [Year]=@Year

		--		Select Leave_Approval_Id,Is_Import into #Leave_Approval_Id from T0130_Leave_Approval_detail where Leave_Approval_Id
		--		in (select Leave_Approval_Id from T0120_Leave_Approval 
		--			where Emp_ID= @Emp_ID And Cmp_ID= @CMP_ID )
		--		--and MONTH(From_Date)=@Month and year(From_Date)=@Year 
		--		and From_Date>=@Sal_St_Date and From_Date<=@Sal_End_Date
		--		and  Cmp_ID= @CMP_ID
				
				
		--		DECLARE Leave_Approval_Cursor CURSOR FOR 
		--		SELECT Leave_Approval_Id,Is_Import FROM #Leave_Approval_Id 
				
		--		OPEN Leave_Approval_Cursor

		--		FETCH NEXT FROM Leave_Approval_Cursor INTO @Leave_Approval_Id,@IsImport

		--		WHILE @@FETCH_STATUS = 0
		--			BEGIN
		--				IF @IsImport = 2 -- put this condition for Aprica pharma, it check Leave enter from webpayroll or direct import from excel sheet 0 as dirct import and 1 as import
		--					BEGIN
		--						DELETE from T0130_Leave_Approval_detail where Leave_Approval_Id =@Leave_Approval_Id
					
		--						DELETE from T0120_Leave_Approval where Leave_Approval_Id = @Leave_Approval_Id
		--					END
				
		--		--in (select Leave_Approval_Id from #Leave_Approval_Id) 
				
		--				FETCH NEXT FROM Leave_Approval_Cursor INTO @Leave_Approval_Id,@IsImport
		--			END 
		--		CLOSE Leave_Approval_Cursor;
		--		DEALLOCATE Leave_Approval_Cursor;
				
		--		-- Comment by Prakash Patel 27112015
		--		--delete from T0120_Leave_Approval where Leave_Approval_Id in
		--		--(Select Leave_Approval_Id  from #Leave_Approval_Id )
		--		--------------------------------
				
		
		--insert into T0170_EMP_ATTENDANCE_IMPORT
		--(
		--Tran_Id	,
		--Emp_ID	,
		--Cmp_ID	,
		--[Month]	,
		--[Year]	,
		--Att_Detail ,
		--PresentDays,
		--WeeklyOff,
		--Holiday	,
		--Absent	,
		--System_Date ,
		--Login_Id
		--)
		--values
		--(
		--@Tran_Id,
		--@Emp_ID,
		--@CMP_ID,
		--@Month,
		--@Year,
		--@Att_Detail+'/',
		--@PresentDays,
		--@WeekOff,
		--@Holiday,
		--@AbsentDays,
		--GETDATE(),
		--@Login_Id
		--)
		
---------------------------------------------------------------------
------------ Leave Import----------------

--	declare @LeaveName varchar(40)
--	declare @LeaveDate Datetime
--	declare @LeaveAssing varchar(40)
--	declare @LeavePeriod Decimal(18,2)
	
--	Declare @Prev_LeaveName varchar(40)
--	Declare @Prev_LeaveDate Datetime
--	Declare @Prev_LeaveAssing varchar(40)
--	declare @Prev_LeavePeriod Decimal(18,2)


	
--	  DECLARE Leave_Cursor CURSOR FOR 
--		select 
--		A.Leave_Name,
--		--convert(datetime,CAST( A.id as varchar(2)) + '/' +(CAST( @Month as varchar(2))) +'/'+ CAST(@year as varchar(4)) ,103) as LeaveDate 
--		dateadd(day, A.id-1,@Sal_St_Date) as LeaveDate 
--		,B.Leave_Assign,B.Leave_Period
--		from (select a.Id,a.data,b.Leave_Name from #tblAtt_Detail as a inner join dbo.T0040_LEAVE_MASTER as b
--		on a.Data = b.Leave_Code and b.Cmp_ID = @CMP_ID
--		union all
--		select a.Id,a.data,b.Leave_Name from #tblAtt_Detail2 as a inner join dbo.T0040_LEAVE_MASTER as b
--		on a.Data = b.Leave_Code and b.Cmp_ID = @CMP_ID
--		)  as A
		
--		inner join (
		
--		select 
--		A.id,
--		a.Data,
--		--b.data,
--		Case When  isnull(a.Data,'') Not in ('A','P','W','HO') And ISNULL(b.Data,'') ='' then 'Full Day' else 
--		Case When isnull(a.Data,'') <>''  And ISNULL(b.Data,'')in ('A','P') then 'First Half' else 
--		Case When isnull(a.Data,'') in ('A','P') And ISNULL(b.Data,'') <> '' then 'Second Half' else
--		Case When isnull(a.Data,'') not in ('A','P','W','HO')  then 'First Half' else
--		Case When isnull(b.Data,'') not in ('A','P','W','HO')  then 'Second Half' End end end end end as  Leave_Assign
				
--		,Case When  isnull(a.Data,'')Not in ('A','P','W','HO') And ISNULL(b.Data,'') ='' then 1 else 
--		Case When isnull(a.Data,'')  <>''  And ISNULL(b.Data,'')in ('A','P') then 0.5 else 
--		Case When isnull(a.Data,'') in ('A','P') And ISNULL(b.Data,'') <> '' then 0.5  else 
--		Case When isnull(a.Data,'') not in ('A','P','W','HO') And ISNULL(b.Data,'') not in ('A','P','W','HO') then 0.5  end end end end as  Leave_Period
		
--		from #tblAtt_Detail as A inner join #tblAtt_Detail2 as B on A.id = B.Id  
--		) as B on A.id = b.id  order by LeaveDate
		
--		OPEN Leave_Cursor

--		FETCH NEXT FROM Leave_Cursor 
--		INTO @LeaveName, @LeaveDate,@LeaveAssing,@LeavePeriod

--		WHILE @@FETCH_STATUS = 0
--		BEGIN
--			If @Prev_LeaveDate = @LeaveDate And @Prev_LeaveAssing = 'First Half' And @Prev_LeavePeriod = 0.5
--				Begin
--					Set @LeaveAssing = 'Second Half'
--				End
			 
--		   --exec P0120_LEAVE_APPROVAL_IMPORT @CMP_ID,@EMP_CODE,@LeaveName,@LeaveDate,@LeavePeriod
--					--						 ,@LeaveAssing,'',@Login_Id,1,'I',0,0,1
--			exec P0120_LEAVE_APPROVAL_IMPORT @CMP_ID,@EMP_CODE,@LeaveName,@LeaveDate,@LeavePeriod
--											 ,@LeaveAssing,'',@Login_Id,2,'I',0,0,1

--			Set @Prev_LeaveDate = @LeaveDate
--			Set @Prev_LeaveAssing = @LeaveAssing
--			Set @Prev_LeaveName = @LeaveName
--			Set @Prev_LeavePeriod = @LeavePeriod
 
--		FETCH NEXT FROM Leave_Cursor 
--		INTO @LeaveName, @LeaveDate,@LeaveAssing,@LeavePeriod
--		END 
--		CLOSE Leave_Cursor;
--		DEALLOCATE Leave_Cursor;
-----------------------------------------
		--select * from T0170_EMP_ATTENDANCE_IMPORT
		
	


