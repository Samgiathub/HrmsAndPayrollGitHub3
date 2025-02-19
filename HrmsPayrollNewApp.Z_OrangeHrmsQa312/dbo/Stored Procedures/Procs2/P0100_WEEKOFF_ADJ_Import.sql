

-- =============================================
-- Author:		Gadriwala Muslim
-- Create date:  19/08/2014
-- Description:	Import Employee Week Off
---13/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0100_WEEKOFF_ADJ_Import]
	@CMP_ID numeric(18,0)
   ,@EMP_CODE varchar(50)
   ,@For_Date datetime
   ,@Week_Off_Days varchar(1000)
   ,@Row_No int = 0
   ,@Log_Status Int = 0 Output
   ,@GUID	Varchar(2000) = '' --Added by nilesh patel on 17062016
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN

Declare @Emp_ID as numeric(18,0)
set @Emp_ID = 0
Declare @Trans_ID as numeric(18,0)
set @Trans_ID = 0

	select @Emp_ID = isnull(Emp_ID,0) from T0080_EMP_MASTER WITH (NOLOCK) where Alpha_Emp_Code = @EMP_CODE and Cmp_ID = @CMP_ID
	
	IF isnull(@Emp_ID,0) = 0
	   Begin
			Set @Log_Status=1
			Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Emp_Code,'Months Salary Exists',@For_Date,'Enter Next Month Effective Date',GetDate(),'Employee Weekoff',@GUID)			
			return 
	   End
	
		  Declare @Sal_St_Date Datetime        
		  Declare @Sal_end_Date Datetime      
		  Declare @manual_salary_Period as numeric(18,0) 
		  set @manual_salary_Period = 0
		  Declare @Salary_Cycle_id as numeric 
		  set @Salary_Cycle_id  = 0    
		  declare @is_salary_cycle_emp_wise as tinyint   
		  set @is_salary_cycle_emp_wise = 0  
		  Declare @TempFromDate datetime
		  Declare @TempToDate datetime
		  
		  SET @TempFromDate = CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(@For_Date)-1),@For_Date),101)
		  SET @TempToDate = CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(DATEADD(mm,1,@For_Date))),DATEADD(mm,1,@For_Date)),101)
		  
          Declare @From_Date datetime
		  Declare @To_Date datetime
		  
		  select @is_salary_cycle_emp_wise = isnull(Setting_Value,0) from T0040_SETTING WITH (NOLOCK) where Cmp_ID = @Cmp_ID and Setting_Name = 'Salary Cycle Employee Wise'    
		  		    
		  IF @is_salary_cycle_emp_wise = 1    
			BEGIN  
				  SELECT @Salary_Cycle_id = SalDate_id from T0095_Emp_Salary_Cycle WITH (NOLOCK) where Emp_id = @Emp_ID AND Effective_date in    
				  (SELECT max(effective_date) as effective_date from T0095_Emp_Salary_Cycle WITH (NOLOCK)    
				  where Emp_id = @Emp_ID AND Effective_date <=  @For_Date    
				  GROUP by Emp_id)          
				  SELECT @Sal_St_Date = Salary_st_date FROM T0040_Salary_Cycle_Master WITH (NOLOCK) where Tran_Id = @Salary_Cycle_id   
		   END  
		   ELSE  
		   BEGIN  
				  select Top 1 @Sal_St_Date = Sal_st_Date ,@manual_salary_Period= isnull(manual_salary_Period ,0)
				  from T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID        
				  and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <= @For_Date and Cmp_ID = @Cmp_ID)        
		   END  
		  
		  if isnull(@Sal_St_Date,'') = ''          
			 begin           
				  set @From_Date  = @TempFromDate           
				  set @To_Date = @TempToDate          
			 end           
		  else if day(@Sal_St_Date) =1        
			 begin          
				  set @From_Date  = @TempFromDate           
				  set @To_Date = @TempToDate          
			 end           
	      else  if @Sal_St_Date <> ''  and day(@Sal_St_Date) > 1         
			 begin               
			   if @manual_salary_Period = 0       
			   Begin  
				    set @Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,@TempFromDate)) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@TempFromDate) )as varchar(10)) as smalldatetime)          
					set @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date))       
					Set @From_Date = @Sal_St_Date      
					Set @To_Date = @Sal_End_Date       
				end      
			  else      
			   begin         
				    select @Sal_St_Date=from_date,@Sal_End_Date=end_date from salary_period where Month(from_date) = Month(@For_Date) And Year(from_date) = Year(@For_Date)
				    Set @From_Date = @Sal_St_Date      
					Set @To_Date = @Sal_End_Date          
			   End       
		  End  
 		
	
					
		if Exists(Select 1 from T0200_MONTHLY_SALARY WITH (NOLOCK) where Emp_ID=@Emp_Id and  Month_End_Date >= @To_Date and Cmp_ID = @Cmp_ID) -- Changed For_date to To_Date Ali 13122013
				Begin
					
					Set @Log_Status=1
					Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Emp_Code,'Months Salary Exists',@For_Date,'Enter Next Month Effective Date',GetDate(),'Employee Weekoff',@GUID)			
					return 
				End
	
	
	
	if @Emp_Id =0
			begin
				Set @Log_Status=1
				Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Emp_Code,'Employee Doesn''t exists',@EMP_CODE,'Enter proper Employee Code',GetDate(),'Employee Weekoff',@GUID)			
				return
			end
	
	If 	@Week_Off_Days <> '' 
	begin
	
		DECLARE @Table TABLE(
        Weeks_day VARCHAR(250)
		)
		
		Declare @Weeks_Day varchar(250)
		set @Weeks_Day = ''
		if exists(select 1 from sys.tables where name ='#t2' )
			begin
				drop table #t2
			end
			
		INSERT INTO @Table SELECT @Week_Off_Days
		;WITH Vals AS (
	        SELECT  
					CAST('<d>' + REPLACE(Weeks_day, ',', '</d><d>') + '</d>' AS XML) XmlColumn
			FROM    @Table
		)
		SELECT  C.value('.','varchar(max)') ColumnValue into #t2
					FROM  Vals  CROSS APPLY Vals.XmlColumn.nodes('/d') AS T(C)
		
		
		Declare @Is_Valid_Name as numeric(18,0)
		set @Is_Valid_Name = 0
		Declare cur_Week_Days CURSOR 
					For select * from #t2
					
					Open cur_Week_Days
					Fetch Next From cur_Week_Days Into @Weeks_Day
				    While @@fetch_Status = 0
					Begin 
						SET @Is_Valid_Name = 0
						if (Upper(@Weeks_Day) = Upper('Monday')) 
						begin
						SET @Is_Valid_Name = 1
						end
						else if (Upper(@Weeks_Day) = Upper('Tuesday')) 
						begin
						SET @Is_Valid_Name = 1
						end
						else if (Upper(@Weeks_Day) = Upper('Wednesday')) 
						begin
						SET @Is_Valid_Name = 1
						end
						else if (Upper(@Weeks_Day) = Upper('Thursday')) 
						begin
						SET @Is_Valid_Name = 1
						end
						else if (Upper(@Weeks_Day) = Upper('Friday')) 
						begin
						SET @Is_Valid_Name = 1
						end
						else if (Upper(@Weeks_Day) = Upper('Saturday')) 
						begin
						SET @Is_Valid_Name = 1
						end
						else if (Upper(@Weeks_Day) = Upper('Sunday')) 
						begin
							SET @Is_Valid_Name = 1
						end
						
						IF @Is_Valid_Name = 0 
						begin
							Set @Log_Status=1
							Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Emp_Code,'Week Day Name Not Valid',@Weeks_Day,'Enter proper Week Day Name',GetDate(),'Employee Weekoff',@GUID)			
							return
						end
						
						Fetch Next From cur_Week_Days Into @Weeks_Day 
					end
					close cur_Week_Days
					deallocate cur_Week_Days
		
		
	 end 
	 
	 Set @Week_Off_Days = REPLACE(@Week_Off_Days,',','#')
			
	if not exists(select 1 from T0100_WEEKOFF_ADJ WITH (NOLOCK) where For_Date = @For_Date and Emp_ID = @Emp_ID and Cmp_ID =@CMP_ID)
		begin
		
			select   @Trans_ID = isnull(max(W_Tran_ID),0) + 1  from  T0100_WEEKOFF_ADJ WITH (NOLOCK)
			
			Insert into T0100_WEEKOFF_ADJ(W_Tran_ID,Emp_ID,CMp_ID,For_Date,Weekoff_Day,Weekoff_day_Value,Alt_W_Name,Alt_W_Full_Day_Cont,Alt_W_Half_DAy_Cont,Is_P_Comp)values
			(@Trans_ID,@Emp_ID,@CMP_ID,@For_Date,@Week_Off_Days,'','','','',0) 
			
		end
	else
		begin
			select   @Trans_ID = W_Tran_ID  from  T0100_WEEKOFF_ADJ WITH (NOLOCK) where For_Date = @For_Date and Emp_ID = @Emp_ID and Cmp_ID =@CMP_ID
			Update T0100_WEEKOFF_ADJ set
			 Weekoff_Day = @Week_Off_Days
			 where W_Tran_ID =@Trans_ID and Emp_ID  = @Emp_ID and Cmp_ID = @CMP_ID
		end
 
END

