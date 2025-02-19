

CREATE PROCEDURE [dbo].[Get_COND_Details]
	@For_Date datetime,
	@Cmp_ID numeric(18,0),
	@Emp_ID  numeric(18,0),
	@leave_ID numeric(18,0),
	@Leave_Application_ID numeric(18,0) = 0,
	@Exec_For numeric(18,0) = 0,
	@Leave_Period numeric(18,2) = 0 -- Added by Gadriwala Muslim 18052015	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON
	CREATE TABLE #COND_OT
		(
			Leave_Tran_ID			numeric,
			Cmp_ID					numeric,
			Emp_ID					numeric,
			For_Date				datetime,
			COND_Credit				numeric(18,2),
			COND_Debit				numeric(18,2),
			COND_balance			numeric(18,2),
			Branch_ID				numeric,
			Is_CompOff				numeric,
			COND_Days_Limit			numeric,
			COND_Type				varchar(4)
		)
	
	declare @branch_id as numeric(18,0)
	declare @COND_Avail_limit as numeric(18,0)
	declare @COND_From_Date as varchar(25)
	
	
	set @COND_Avail_limit = 0
	
	select @branch_id = branch_id from dbo.T0095_INCREMENT IE WITH (NOLOCK) Inner join
	(select MAX(Increment_ID) as Increment_ID from dbo.T0095_INCREMENT  WITH (NOLOCK) 
	where Emp_ID = @Emp_ID and cmp_ID = @cmp_ID and Increment_Effective_Date<=@For_Date)
	qry on Qry.Increment_ID = IE.Increment_ID
	where Emp_ID = @Emp_ID   
	
	
	select @COND_Avail_limit = COND_Avail_limit
	From dbo.T0040_GENERAL_SETTING GS  WITH (NOLOCK) Inner join
	(select max(For_Date) as For_Date from dbo.T0040_GENERAL_SETTING  WITH (NOLOCK) 
			where For_Date <= @For_Date and Branch_ID = @branch_id and Cmp_ID = @Cmp_ID 
	)Qry on Qry.For_Date = GS.For_Date  where cmp_ID = @cmp_ID and Branch_ID = @branch_id
		
	

	set  @COND_From_Date = Convert(varchar(25),DATEADD(D,@COND_Avail_limit * -1,@For_Date))	
				
	Insert into #COND_OT(Leave_Tran_ID,cmp_ID,Emp_ID,For_Date,COND_Credit,COND_Debit,COND_balance,Branch_ID,Is_CompOff,COND_Days_Limit,COND_Type)
				select Leave_Tran_ID,@Cmp_ID,@Emp_ID,For_Date,CompOff_Credit,CompOff_Debit,CompOff_Balance,
				@branch_id,Comoff_Flag,@COND_Avail_limit,'COND' from dbo.T0140_LEAVE_TRANSACTION  WITH (NOLOCK) 
				where Leave_ID = @leave_ID and For_Date >= @COND_From_Date and For_date <=@For_Date and Cmp_ID = @Cmp_ID and Emp_ID = @Emp_ID and Comoff_Flag = 1
				
	Create Table #Leave_Applied
	(
		Leave_Date datetime,
		Leave_Period numeric(18,2)
	 )
	 Create Table #Leave_Approved
	(
		Leave_Appr_Date datetime,
		Leave_Period numeric(18,2)
	 )
	  Create Table #Leave_Level_Approved
	(
		Leave_Appr_Date datetime,
		Leave_Period numeric(18,2)
	 )
	Declare @strLeave_COND_dates varchar(max)
	set @strLeave_COND_dates = ''
	if @Leave_Application_ID = 0 
		begin
			select  @strLeave_COND_dates = @strLeave_COND_dates + '#' + Leave_CompOff_Dates  
			from dbo.V0110_LEAVE_APPLICATION_DETAIL VLAD left  join
			(
				select  Leave_Application_ID from dbo.T0115_Leave_Level_Approval LLA WITH (NOLOCK)  inner join
				(
									select max(Tran_ID) as Tran_ID from  dbo.T0115_Leave_Level_Approval LLA  WITH (NOLOCK) inner join 
									dbo.T0100_LEAVE_APPLICATION  LA  WITH (NOLOCK) on LLA.Leave_Application_ID = LA.Leave_Application_ID and LLA.Emp_ID = La.Emp_ID and Application_Status = 'P'
									where LLA.Emp_ID = @Emp_ID and Approval_Status = 'A' and Leave_ID = @Leave_ID and LLA.cmp_ID = @cmp_ID  group by LLA.Leave_Application_ID
				)sub_Qry on Sub_Qry.Tran_ID = LLA.Tran_ID
				
			 ) Qry on Qry.Leave_Application_ID = VLAD.LEave_Application_ID  
			where Cmp_ID = @Cmp_ID and Emp_ID = @Emp_ID 
			and Application_Status = 'P' and Leave_ID = @leave_ID 
			and  isnull(Leave_CompOff_Dates,'') <> '' 
			and  isnull(Qry.Leave_Application_ID ,0)=0
		end
	else
		begin
		
			
			select  @strLeave_COND_dates = @strLeave_COND_dates + '#' + Leave_CompOff_Dates  
			from dbo.V0110_LEAVE_APPLICATION_DETAIL VLAD left outer join
			(
				select  Leave_Application_ID from dbo.T0115_Leave_Level_Approval LLA  WITH (NOLOCK) inner join
				(
									select max(Tran_ID) as Tran_ID from  dbo.T0115_Leave_Level_Approval LLA  WITH (NOLOCK) inner join 
									dbo.T0100_LEAVE_APPLICATION  LA  WITH (NOLOCK) on LLA.Leave_Application_ID = LA.Leave_Application_ID and LLA.Emp_ID = La.Emp_ID and Application_Status = 'P'
									where LLA.Emp_ID = @Emp_ID and Approval_Status = 'A' and Leave_ID = @Leave_ID and LLA.cmp_ID = @cmp_ID group by LLA.Leave_Application_ID
				)sub_Qry on Sub_Qry.Tran_ID = LLA.Tran_ID
				
			 ) Qry on Qry.Leave_Application_ID <> VLAD.LEave_Application_ID  
			where Cmp_ID = @Cmp_ID and Emp_ID = @Emp_ID 
			and Application_Status = 'P' and Leave_ID = @leave_ID 
			and  isnull(Leave_CompOff_Dates,'') <> '' and VLAD.Leave_Application_ID <> @Leave_Application_ID 
		end	
		
		Insert into #Leave_Applied(Leave_date,Leave_Period)
		select  Left(DATA,CHARINDEX(';',DATA)-1),SUBSTRING(DATA,CHARINDEX(';',DATA)+1,10) 
		from dbo.SPlit(@strLeave_COND_dates,'#') where Data <> ''	
		
		set @strLeave_COND_dates = ''
	
	If @Leave_Application_ID > 0 
		begin
			select @strLeave_COND_dates = @strLeave_COND_dates + '#' + isnull(Leave_CompOff_Dates,'')   
			from  dbo.V0130_Leave_Approval_Details where Leave_Application_ID = @Leave_Application_ID and Approval_Status = 'A' and Cmp_ID = @Cmp_ID
		end		
	set @strLeave_COND_dates = ''
	If @Leave_Application_ID > 0  
		begin
			
			select @strLeave_COND_dates = @strLeave_COND_dates + '#' + isnull(Leave_CompOff_dates,'') 
			from dbo.T0115_Leave_Level_Approval LLA  WITH (NOLOCK) Inner join
			(
				select max(Tran_ID) as Tran_ID from  dbo.T0115_Leave_Level_Approval LLA  WITH (NOLOCK) inner join
				dbo.T0100_LEAVE_APPLICATION LA  WITH (NOLOCK) on LLA.Leave_Application_ID = LA.Leave_Application_ID and LLA.Emp_ID =LA.Emp_ID and LA.Application_Status = 'P'
				where LA.Emp_ID = @Emp_ID and Approval_Status = 'A' and Leave_ID = @Leave_ID   and LA.cmp_ID = @Cmp_ID
				group by LLA.Leave_Application_ID
			 )	Qry on Qry.Tran_ID = LLA.Tran_ID
			where Leave_Application_ID <> @Leave_Application_ID
		end
	else
		begin
			
			select @strLeave_COND_dates = @strLeave_COND_dates + '#' + isnull(Leave_CompOff_dates,'') 
			from dbo.T0115_Leave_Level_Approval LLA  WITH (NOLOCK) inner join 
			(
				select max(Tran_ID) as Tran_ID from  dbo.T0115_Leave_Level_Approval LLA  WITH (NOLOCK)  inner join 
				dbo.T0100_LEAVE_APPLICATION LA WITH (NOLOCK)  on LA.Leave_Application_ID = LLA.Leave_Application_ID and  LA.Emp_ID = LLA.Emp_ID and Application_Status = 'P'
				where LLA.Emp_ID = @Emp_ID and Approval_Status = 'A' and Leave_ID = @Leave_ID and LLA.Cmp_ID = @Cmp_ID
				group by LLA.Leave_Application_ID
			)  Qry on Qry.Tran_ID = LLA.Tran_ID
		end
	
	
	
	Insert into #Leave_Level_Approved(Leave_Appr_Date,Leave_Period)
		select  Left(DATA,CHARINDEX(';',DATA)-1),SUBSTRING(DATA,CHARINDEX(';',DATA)+1,10) 
		from dbo.SPlit(@strLeave_COND_dates,'#') where Data <> ''
		
		
		Update #COND_OT set COND_Debit = COND_Debit + Qry.Leave_Period,
			COND_balance	= COND_balance - Qry.Leave_Period from #COND_OT GOT 
			inner join (select isnull(SUM(leave_Period),0) as Leave_Period,Leave_Date
			from  #Leave_Applied LA Group By Leave_Date) Qry on Qry.Leave_Date = For_Date		
		
			Update #COND_OT set COND_Debit = COND_Debit + Qry.Leave_Period,
			COND_balance	= COND_balance - Qry.Leave_Period from #COND_OT GOT 
			inner join (select isnull(SUM(leave_Period),0) as Leave_Period,Leave_Appr_Date 
			from  #Leave_Level_Approved LA Group By Leave_Appr_Date) Qry on Qry.Leave_Appr_Date = For_Date		
		
			Update #COND_OT set COND_Debit = COND_Debit - Qry.Leave_Period,
			COND_balance	= COND_balance + Qry.Leave_Period from #COND_OT GOT 
			inner join (select isnull(SUM(leave_Period),0) as Leave_Period,Leave_Appr_Date 
			from  #Leave_Approved LA Group By Leave_Appr_Date) Qry on Qry.Leave_Appr_Date = For_Date
	
	Declare @Total_Balance as numeric(18,2)
	set @Total_Balance = 0
	Declare @Leave_Code as varchar(max)
    Declare @Leave_Name as varchar(max)
	Declare @Leave_Display as tinyint
	Declare @COND_Balance as numeric(18,2)
	Declare @Cur_COND_balance numeric(18,2)
	Declare @Cur_For_Date datetime
	Declare @COND_String nvarchar(max)
	Declare @Cur_Total_Balance numeric(18,2)
	
	if @Exec_For = 0
	begin
		select @Total_Balance = isnull(SUM(COND_balance),0) from #COND_OT where COND_balance > 0 Group By Emp_ID
		select *,@Total_Balance as Total_Balance from #COND_OT where COND_balance > 0 order by For_Date
	end
	else if @Exec_For = 1  -- Only Show Data IF Leave_Display 1 of leave
	begin
		
		set @COND_Balance = 0
		set @Leave_Display = 0
		select @Leave_Code = Leave_Code , @Leave_Name = Leave_Name, @Leave_Display = isnull(Display_leave_balance,0) from dbo.T0040_Leave_Master WITH (NOLOCK)  where Leave_ID = @Leave_ID		
		if @Leave_Display = 1
		begin 
			select @COND_Balance = isnull(sum(COND_Balance),0) from #COND_OT 
			if @COND_Balance > 0
			begin 
				Insert into #temp_COPH
					select isnull(sum(COND_credit),0),isnull(Sum(COND_Debit),0),isnull(sum(COND_Balance),0),@Leave_Code,@Leave_Name,@Leave_ID,'' from #COND_OT 
			end
				
		end
	end
	else if @Exec_For = 2  -- COND Show All Data
			begin
							select @Total_Balance = isnull(SUM(COND_Balance),0) from #COND_OT where COND_Balance > 0 Group By Emp_ID
							set @Leave_Display = 0
							select @Leave_Code = Leave_Code , @Leave_Name = Leave_Name from dbo.T0040_Leave_Master where Leave_ID = @Leave_ID and cmp_ID = @cmp_ID		
							
					if @Total_Balance > 0
						begin
				
							
							set @COND_String = ''
									
									Declare Cur_COND cursor for
												select For_Date,COND_Balance,@Total_Balance from #COND_OT
								
									open Cur_COND
												Fetch next from Cur_COND into  @Cur_For_Date,@Cur_COND_balance,@Cur_Total_Balance
										While @@Fetch_Status =0  
										begin
											
												If @COND_String = ''
													set	@COND_String = replace(CONVERT(varchar(11),@Cur_For_Date,106),' ','-')  + ';' + cast(@Cur_COND_balance as varchar(15))
						   					    else
												    set	@COND_String = @COND_String  +  '#' + replace(CONVERT(varchar(11),@Cur_For_Date,106),' ','-')  + ';' + cast(@Cur_COND_balance as varchar(15))
										                    
												Fetch next from Cur_COND into @Cur_For_Date,@Cur_COND_balance,@Cur_Total_Balance
										end
								 	close Cur_COND
								 	deallocate Cur_COND
						
						Insert into #temp_COPH
							select isnull(sum(COND_credit),0) as COND_credit,isnull(Sum(COND_Debit),0) as  COND_Debit,isnull(sum(COND_Balance),0) as COND_Balance ,@Leave_Code as Leave_Code,@Leave_Name as Leave_Name,@Leave_ID as Leave_ID  ,@COND_String as COND_String   from #COND_OT 
					end
				
			end
	   else if @Exec_For = 3   -- COND Leave Approval Using Import
			begin
					select @Total_Balance = isnull(SUM(COND_Balance),0) from #COND_OT where COND_Balance > 0 Group By Emp_ID
						set @Leave_Display = 0
					select @Leave_Code = Leave_Code , @Leave_Name = Leave_Name from dbo.T0040_Leave_Master where Leave_ID = @Leave_ID	and Cmp_ID = @Cmp_ID	
					
							
					if @Total_Balance >= @Leave_Period
						begin
						
							Declare @Temp_Leave_Period numeric(18,2)
							set @Temp_Leave_Period = @Leave_Period
							set @COND_String = ''
									
									Declare Cur_COND cursor for
												select For_Date,COND_Balance,@Total_Balance from #COND_OT
								
									open Cur_COND
												Fetch next from Cur_COND into  @Cur_For_Date,@Cur_COND_balance,@Cur_Total_Balance
										While @@Fetch_Status =0  
										begin
											IF @Temp_Leave_Period >  0 
											  begin		
												If @Cur_COND_balance < = @Temp_Leave_Period	
												  begin
													set @Temp_Leave_Period = @Temp_Leave_Period - @Cur_COND_balance
													If @COND_String = ''
														set	@COND_String = replace(CONVERT(varchar(11),@Cur_For_Date,106),' ','-')  + ';' + cast(@Cur_COND_balance as varchar(15))
						   							else
														set	@COND_String = @COND_String  +  '#' + replace(CONVERT(varchar(11),@Cur_For_Date,106),' ','-')  + ';' + cast(@Cur_COND_balance as varchar(15))
												  end
												else
													begin
														If @COND_String = ''
															set	@COND_String = replace(CONVERT(varchar(11),@Cur_For_Date,106),' ','-')  + ';' + cast(@Temp_Leave_Period as varchar(15))
						   								else
															set	@COND_String = @COND_String  +  '#' + replace(CONVERT(varchar(11),@Cur_For_Date,106),' ','-')  + ';' + cast(@Temp_Leave_Period as varchar(15))
														
														set @Temp_Leave_Period = 0
													end              
											  end
											     
												Fetch next from Cur_COND into @Cur_For_Date,@Cur_COND_balance,@Cur_Total_Balance
										end
								 	close Cur_COND
								 	deallocate Cur_COND
						
						Insert into #temp_CompOff
							select 0 as COND_credit,0 as  COND_Debit,0 as COND_Balance ,@Leave_Code as Leave_Code,@Leave_Name as Leave_Name,@Leave_ID as Leave_ID  ,@COND_String as COND_String   from #COND_OT 
					end
			end
END

