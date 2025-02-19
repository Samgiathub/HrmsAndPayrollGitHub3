
---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0170_EMP_ATTENDANCE_IMPORT_DELETE] 
	@Cmp_id				int,
	@Tran_ID			varchar(40),
	@Login_ID			int
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	DECLARE @EMP_ID  decimal(12,0)
	DECLARE @Branch_Id as int
 
	DECLARE @Month int
	DECLARE @Year  int
	DECLARE @Alpha_Emp_Code varchar(50)
	DECLARE @LogDesc	nvarchar(max)	
	DECLARE @Leave_Approval_Id varchar(40)
	DECLARE @IsImport int -- added by Prakash Patel 27112015

	Select @EMP_ID = EMP_ID,@Month=[Month],@Year=[Year],
	@Alpha_Emp_Code = Alpha_Emp_Code,@Branch_Id=Branch_Id from V0170_EMP_ATTENDANCE_IMPORT 
	Where Cmp_id=@Cmp_id And Tran_ID = @Tran_ID
	
	IF EXISTS(SELECT EMP_ID FROM  T0200_MONTHLY_SALARY WITH (NOLOCK) WHERE Cmp_ID=@Cmp_ID and EMP_ID=@EMP_ID AND month(Month_End_Date)=@Month and YEAR(Month_End_Date)=@Year)
		Begin		
				
			SET @LogDesc = 'Emp_Code='+@Alpha_Emp_Code +', Month='+cast(@Month as varchar)+', Year='+cast(@Year as varchar)
			Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,@Alpha_Emp_Code,'Monthly salary Exists ' +@LogDesc ,'','Import proper Data',GetDate(),'Import Data Delete','')
				
			--exec Event_Logs_Insert 0,@Cmp_ID,@Emp_Id,@Login_ID,'Import','Monthly salary Exists',@LogDesc,1,''			
			--Raiserror('Salary Exists',16,2)
			RAISERROR('@@ Salary Exist for Month @@',16,2)
			RETURN
			--return -1
		End  

	--------- Salary Date ------------------

	DECLARE @manual_salary_period as numeric(18,0) 
	DECLARE @Sal_St_Date as datetime
	DECLARE @Sal_End_Date as datetime
			   
	DECLARE @Month_St_Date as datetime
	DECLARE @Month_End_Date as datetime
			   
	DECLARE @OutOf_Days as int
			   
			  
	--SET @Month_St_Date  = cast('01' + '-' + (cast(@Month as varchar(10)) + '-' +  cast( @Year as varchar(10)) as smalldatetime)  
	SET @Month_St_Date  =  convert(datetime,CAST( '01' as varchar(2)) + '/' +(CAST( @Month as varchar(2))) +'/'+ CAST(@year as varchar(4)) ,103)
	SET @Month_End_Date = dateadd(d,-1,dateadd(m,1,@Month_St_Date))
			  
	select @Sal_St_Date  =Sal_st_Date ,@manual_salary_period=isnull(Manual_Salary_Period ,0) 
	from T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @CMP_ID and Branch_ID = @Branch_Id
	and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@Month_End_Date and Branch_ID = @Branch_ID and Cmp_ID = @Cmp_ID)    


	if isnull(@Sal_St_Date,'') = ''    
		begin    
			SET @Month_St_Date  = @Month_St_Date     
			SET @Month_End_Date = @Month_End_Date    
			SET @OutOf_Days = @OutOf_Days
		end     
	else if Day(@Sal_St_Date) =1    
		begin    
			--SET @Month_St_Date  = @Month_St_Date     
			--SET @Month_End_Date = @Month_End_Date    
			--SET @OutOf_Days = @OutOf_Days  
						   
			SET @Sal_St_Date =  cast(cast(Day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,@Month_St_Date) as varchar(10)) + '-' +  cast(YEAR(@Month_St_Date )as varchar(10)) as smalldatetime)    
			SET @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date)) 
			SET @OutOf_Days = datediff(d,@Sal_St_Date,@Sal_End_Date) + 1
					   
			SET @Month_St_Date = @Sal_St_Date
			SET @Month_End_Date = @Sal_End_Date 
					          	         
		END     
	ELSE IF @Sal_St_Date <> ''  and Day(@Sal_St_Date) > 1   
		BEGIN    
			IF @manual_salary_period = 0 
				BEGIN
					SET @Sal_St_Date =  CAST(CAST(Day(@Sal_St_Date)as varchar(5)) + '-' + cast(DateName(mm,DateAdd(m,-1,@Month_St_Date)) AS VARCHAR(10)) + '-' +  CAST(YEAR(DateAdd(m,-1,@Month_St_Date) )as varchar(10)) as smalldatetime)    
					SET @Sal_End_Date = DateAdd(D,-1,DateAdd(m,1,@Sal_St_Date)) 
					SET @OutOf_Days = DateDiff(D,@Sal_St_Date,@Sal_End_Date) + 1
						   
					SET @Month_St_Date = @Sal_St_Date
					SET @Month_End_Date = @Sal_End_Date 
				END 
			ELSE
				BEGIN
					select	@Sal_St_Date=from_date,@Sal_End_Date=end_date 
					FROM	salary_period 
					WHERE	MONTH= MONTH(@Month_St_Date) AND YEAR=YEAR(@Month_St_Date)
					SET @OutOf_Days = DateDiff(d,@Sal_St_Date,@Sal_End_Date) + 1
							   
					SET @Month_St_Date = @Sal_St_Date
					SET @Month_End_Date = @Sal_End_Date 
				END   
		END
	----------------------------------------
				
	----------- Remove Data From Table---------------		
	delete from T0170_EMP_ATTENDANCE_IMPORT 
	where Emp_ID= @Emp_ID And Cmp_ID= @CMP_ID And [MONTH] = @Month And [Year]=@Year

	SELECT	Leave_Approval_Id,Is_Import 
	INTO	#Leave_Approval_Id 
	FROM	T0130_Leave_Approval_detail WITH (NOLOCK) 
	WHERE	Leave_Approval_Id IN (SELECT	Leave_Approval_Id FROM T0120_Leave_Approval WITH (NOLOCK)
								  WHERE		Emp_ID= @Emp_ID And Cmp_ID= @CMP_ID )
			AND From_Date>=@Sal_St_Date and From_Date<=@Sal_End_Date
			AND  Cmp_ID= @CMP_ID
				
	DECLARE Leave_Approval_Cursor CURSOR FOR 
	SELECT Leave_Approval_Id,Is_Import FROM #Leave_Approval_Id 
	OPEN Leave_Approval_Cursor
				
	FETCH NEXT FROM Leave_Approval_Cursor INTO @Leave_Approval_Id,@IsImport
	WHILE @@FETCH_STATUS = 0
		BEGIN
			IF @IsImport = 2 -- put this condition for Aprica pharma, it check Leave enter from webpayroll or direct import from excel sheet 0 as dirct import and 1 as import
				BEGIN						
					DELETE FROM T0130_Leave_Approval_detail WHERE Leave_Approval_Id =@Leave_Approval_Id
					--in (select Leave_Approval_Id from #Leave_Approval_Id) 
					DELETE FROM T0120_Leave_Approval WHERE Leave_Approval_Id =@Leave_Approval_Id
				END
							
			FETCH NEXT FROM Leave_Approval_Cursor INTO @Leave_Approval_Id,@IsImport
		END 
	CLOSE Leave_Approval_Cursor;
	DEALLOCATE Leave_Approval_Cursor;
				
	-- Comment by Prakash Patel 27112015
	--delete from T0120_Leave_Approval where Leave_Approval_Id in
	--(Select Leave_Approval_Id  from #Leave_Approval_Id )
	--------------------------------
				

