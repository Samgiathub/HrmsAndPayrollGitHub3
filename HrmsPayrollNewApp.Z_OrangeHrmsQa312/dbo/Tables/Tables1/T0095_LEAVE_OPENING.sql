CREATE TABLE [dbo].[T0095_LEAVE_OPENING] (
    [Leave_Op_ID]   NUMERIC (18)    NOT NULL,
    [Emp_Id]        NUMERIC (18)    NOT NULL,
    [Grd_ID]        NUMERIC (18)    NOT NULL,
    [Cmp_ID]        NUMERIC (18)    NOT NULL,
    [Leave_ID]      NUMERIC (18)    NOT NULL,
    [For_Date]      DATETIME        NOT NULL,
    [Leave_Op_Days] NUMERIC (22, 8) NOT NULL,
    CONSTRAINT [PK_T0095_LEAVE_OPENING] PRIMARY KEY CLUSTERED ([Leave_Op_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0095_LEAVE_OPENING_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0095_LEAVE_OPENING_T0040_GRADE_MASTER] FOREIGN KEY ([Grd_ID]) REFERENCES [dbo].[T0040_GRADE_MASTER] ([Grd_ID]),
    CONSTRAINT [FK_T0095_LEAVE_OPENING_T0040_LEAVE_MASTER] FOREIGN KEY ([Leave_ID]) REFERENCES [dbo].[T0040_LEAVE_MASTER] ([Leave_ID]),
    CONSTRAINT [FK_T0095_LEAVE_OPENING_T0080_EMP_MASTER] FOREIGN KEY ([Emp_Id]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID])
);


GO





CREATE TRIGGER [DBO].[Tri_T0095_LEAVE_OPENING_Update]
ON [dbo].[T0095_LEAVE_OPENING] 
FOR UPDATE
AS
set nocount on;
	Declare @Leave_Tran_ID as numeric 
	declare @Emp_Id as numeric
	declare @Grade_Id as numeric
	declare @Cmp_ID as numeric
	declare @Leave_Id as numeric
	declare @For_date as datetime	
	declare @Leave_OP_Days as numeric(22,5)	
	Declare @Leave_OP_Days_Old as Numeric(22,5)--Nikunj For Updating Leave Opening When Alrady There is Leave transaction is there.
		Set @Leave_OP_Days_Old = 0
	Declare @Leave_OP_Days_Diff As Numeric(22,5)
		Set @Leave_OP_Days_Diff = 0
	Declare @Temp_leave_Bal as numeric (22,5)
	declare @Temp_Max_Date as datetime
	-- Check Leave Balance
	declare @Leave_Name as varchar(100)
	declare @ErrString as varchar(200)
	--whole Leave update Trigger Change By Nikunj In Jan-2011. If you Found Any Problem Please First Tell Me Before Change.
	
	
			
			---Select * From dbo.T0140_LEAVE_TRANSACTION Where Cmp_Id=@Cmp_Id and Emp_Id=@Emp_Id 			
			select @Emp_Id = emp_Id, @Cmp_ID = Cmp_ID, @For_Date = For_Date,@leave_id = Leave_id , @Leave_OP_Days = Leave_OP_Days 
				from inserted ins 			
				
				
			select @Leave_Tran_ID  = Isnull(max(Leave_Tran_ID),0) + 1 From dbo.T0140_LEAVE_TRANSACTION 
			
			if exists (select Emp_ID from dbo.T0140_LEAVE_TRANSACTION where emp_id = @emp_id and Leave_id = @leave_id and 
				Cmp_ID = @Cmp_ID )
				begin
					
					if exists(select For_Date from dbo.T0140_LEAVE_TRANSACTION where leave_ID = @Leave_ID and for_date <= @for_date and Emp_ID = @Emp_Id) 
						begin
							select @Temp_max_Date   = max(For_Date)  from dbo.T0140_LEAVE_TRANSACTION where leave_ID = @Leave_ID and for_date <= @for_date and Emp_ID = @Emp_ID
							
																					
							select @Temp_leave_Bal = isnull(Leave_Closing,0) from dbo.T0140_LEAVE_TRANSACTION where leave_ID = @Leave_ID and Emp_ID = @Emp_ID and 
							for_Date = @Temp_Max_DAte

							If @For_date = @Temp_Max_Date
								Begin
									update dbo.T0140_LEAVE_TRANSACTION 
									set 
									Leave_Opening =@Leave_OP_Days,
									Leave_Posting = @Temp_leave_Bal,
									Leave_Closing = (@Leave_OP_Days + Leave_Credit) - Leave_Used
									where Leave_ID = @Leave_Id 
									and Emp_ID  =    @Emp_ID 
									and for_Date =	 @Temp_Max_Date
								End
							Else
								Begin
									update dbo.T0140_LEAVE_TRANSACTION 
									set 
									Leave_Posting = @Temp_leave_Bal,
									Leave_Closing = 0
									where Leave_ID = @Leave_Id 
									and Emp_ID  =    @Emp_ID 
									and for_Date =	 @Temp_Max_Date
								End
							
							
							--Alpesh 17-Sep-2011
							Declare @Chg_For_Date datetime
							Declare @Chg_Tran_Id numeric  
							Declare @Pre_Closing numeric(22,5)							
							

							if not exists (select 1 from dbo.T0140_LEAVE_TRANSACTION where emp_id = @emp_id and Leave_id = @leave_id and 
										Cmp_ID = @Cmp_ID and for_date = @for_date )
							begin
								insert dbo.T0140_LEAVE_TRANSACTION(Leave_Tran_ID,emp_id,Leave_Id,Cmp_ID,For_Date,Leave_Opening,Leave_Closing,Leave_posting,Leave_Used,Leave_Credit)
								values(@Leave_Tran_ID,@emp_id,@leave_Id,@Cmp_ID,@For_Date,@Leave_OP_Days,@Leave_OP_Days,0,0,0)												    		
							end
							
							--Select top 1 @Chg_Tran_Id = leave_tran_id, @Chg_For_Date = for_date from dbo.T0140_LEAVE_TRANSACTION where leave_id = @leave_Id 
							--and emp_id = @emp_id and for_date > @Temp_Max_Date and Cmp_ID = @Cmp_ID order by for_date 
							 
							 
							--update dbo.T0140_LEAVE_TRANSACTION set 
							--	  Leave_Opening = @Leave_OP_Days
							--	 ,Leave_Closing = @Leave_OP_Days + Leave_Credit - Leave_Used 
							--	 ,@Pre_Closing  = @Leave_OP_Days + Leave_Credit - Leave_Used 
							--where leave_tran_id = @Chg_Tran_Id
							
							--set @Pre_Closing = @Leave_OP_Days
							Select @Pre_Closing=Leave_Closing from T0140_LEAVE_TRANSACTION where emp_id = @emp_id and Leave_id = @leave_id and 
										Cmp_ID = @Cmp_ID and for_date = @Temp_max_Date
										
							if @Pre_Closing is null
								set @Pre_Closing = 0

																								
							declare cur1 cursor for 
								Select leave_tran_id,For_Date from dbo.T0140_LEAVE_TRANSACTION where leave_id = @leave_Id and emp_id = @emp_id 
								and Cmp_ID = @Cmp_ID and for_date > @Temp_Max_Date order by for_date
							open cur1
							fetch next from cur1 into @Chg_Tran_Id,@Chg_For_Date
							while @@fetch_status = 0
							begin
								--Added by Hardik 16/12/2011
								If exists(Select Leave_Op_Id From T0095_LEAVE_OPENING Where Cmp_ID = @Cmp_ID And Emp_Id = @Emp_Id And Leave_ID = @Leave_Id And For_Date = @Chg_For_Date And Leave_Op_Days > 0)
									Begin
										Goto c;
									End
							
								update dbo.T0140_LEAVE_TRANSACTION set 
									 Leave_Opening = @Pre_Closing
									,Leave_Closing = @Pre_Closing + Leave_Credit - Leave_Used 									
								where leave_tran_id = @Chg_Tran_Id
						
							C:
								set @Pre_Closing = (select Leave_Closing from dbo.T0140_LEAVE_TRANSACTION where leave_tran_id = @Chg_Tran_Id)
							
								fetch next from cur1 into @Chg_Tran_Id,@Chg_For_Date
							end
							
							close cur1
							deallocate cur1							

							--NIkunj 28-Jan-2011----						
							
							Select @Temp_Max_Date = Max(For_date) From dbo.T0140_leave_transaction where Emp_Id=@Emp_Id And Cmp_Id=@Cmp_id And For_date >= @For_Date And Leave_Id=@Leave_Id
							
							
							If Exists(select Leave_Closing from T0140_LEAVE_TRANSACTION  LT Inner join T0040_LEAVE_MASTER LM on
								LT.Leave_ID = LM.Leave_ID and Leave_Paid_Unpaid ='P' And Leave_Negative_Allow = 0
								Where emp_id = @emp_id and LT.leave_id = @leave_id and LT.CMP_ID = @CMP_ID and Leave_Closing < 0 and For_Date = @Temp_Max_Date)
							begin
								select @Leave_Name = Leave_Name from T0040_LEAVE_MASTER where leave_id = @leave_id 
								set @ErrString = 'Balance not available on given Date - ' + @Leave_Name	
								RAISERROR (@ErrString, 16, 2) 							
							End					
							
						end		
					else
						begin
							insert dbo.T0140_LEAVE_TRANSACTION(Leave_Tran_ID,emp_id,Leave_Id,Cmp_ID,For_Date,Leave_Opening,
								Leave_Closing,Leave_Posting,Leave_Used,Leave_Credit)
							values(@Leave_Tran_ID,@emp_id,@leave_Id,@Cmp_ID,@for_Date,@Leave_OP_Days
								,@Leave_OP_Days,0,0,0)

							--set @Pre_Closing = @Leave_OP_Days
							Select @Pre_Closing=Leave_Closing from T0140_LEAVE_TRANSACTION where emp_id = @emp_id and Leave_id = @leave_id and 
										Cmp_ID = @Cmp_ID and for_date = @for_Date
										
							if @Pre_Closing is null
								set @Pre_Closing = 0
																								
							declare cur1 cursor for 
								Select leave_tran_id,For_Date from dbo.T0140_LEAVE_TRANSACTION where leave_id = @leave_Id and emp_id = @emp_id 
								and Cmp_ID = @Cmp_ID and for_date > @for_Date order by for_date
							open cur1
							fetch next from cur1 into @Chg_Tran_Id,@Chg_For_Date
							while @@fetch_status = 0
							begin
								--Added by Hardik 16/12/2011
								If exists(Select Leave_Op_Id From T0095_LEAVE_OPENING Where Cmp_ID = @Cmp_ID And Emp_Id = @Emp_Id And Leave_ID = @Leave_Id And For_Date = @Chg_For_Date And Leave_Op_Days > 0)
									Begin
										Goto d;
									End
							
								update dbo.T0140_LEAVE_TRANSACTION set 
									 Leave_Opening = @Pre_Closing
									,Leave_Closing = @Pre_Closing + Leave_Credit - Leave_Used 									
								where leave_tran_id = @Chg_Tran_Id
						
							D:
								set @Pre_Closing = (select Leave_Closing from dbo.T0140_LEAVE_TRANSACTION where leave_tran_id = @Chg_Tran_Id)
							
								fetch next from cur1 into @Chg_Tran_Id,@Chg_For_Date
							end
							
							close cur1
							deallocate cur1									
								
						end 	
				end				
			else
				begin
						insert dbo.T0140_LEAVE_TRANSACTION(Leave_Tran_ID,emp_id,Leave_Id,Cmp_ID,For_Date,Leave_Opening,
							Leave_Closing,Leave_Posting,Leave_Used,Leave_Credit)
						values(@Leave_Tran_ID,@emp_id,@leave_Id,@Cmp_ID,@for_Date,@Leave_OP_Days
							,@Leave_OP_Days,0,0,0)		

							--set @Pre_Closing = @Leave_OP_Days
							Select @Pre_Closing=Leave_Closing from T0140_LEAVE_TRANSACTION where emp_id = @emp_id and Leave_id = @leave_id and 
										Cmp_ID = @Cmp_ID and for_date = @for_Date
										
							if @Pre_Closing is null
								set @Pre_Closing = 0
																								
							declare cur1 cursor for 
								Select leave_tran_id,For_Date from dbo.T0140_LEAVE_TRANSACTION where leave_id = @leave_Id and emp_id = @emp_id 
								and Cmp_ID = @Cmp_ID and for_date > @for_Date order by for_date
							open cur1
							fetch next from cur1 into @Chg_Tran_Id,@Chg_For_Date
							while @@fetch_status = 0
							begin
								--Added by Hardik 16/12/2011
								If exists(Select Leave_Op_Id From T0095_LEAVE_OPENING Where Cmp_ID = @Cmp_ID And Emp_Id = @Emp_Id And Leave_ID = @Leave_Id And For_Date = @Chg_For_Date And Leave_Op_Days > 0)
									Begin
										Goto e;
									End
							
								update dbo.T0140_LEAVE_TRANSACTION set 
									 Leave_Opening = @Pre_Closing
									,Leave_Closing = @Pre_Closing + Leave_Credit - Leave_Used 									
								where leave_tran_id = @Chg_Tran_Id
						
							E:
								set @Pre_Closing = (select Leave_Closing from dbo.T0140_LEAVE_TRANSACTION where leave_tran_id = @Chg_Tran_Id)
							
								fetch next from cur1 into @Chg_Tran_Id,@Chg_For_Date
							end
							
							close cur1
							deallocate cur1									
							
				end 





GO


CREATE TRIGGER [dbo].[Tri_T0050_LEAVE_OPENING]
ON [dbo].[T0095_LEAVE_OPENING]
FOR  INSERT,  DELETE 
AS
	Declare @Leave_Tran_ID as numeric 
	declare @Emp_Id as numeric
	declare @Grade_Id as numeric
	declare @Cmp_ID as numeric
	declare @Leave_Id as numeric
	declare @For_date as datetime
	declare @Leave_OP_Days as numeric(22,5)	
	Declare @Temp_leave_Bal as numeric ( 22,5)
	declare @Temp_Max_Date as datetime

	-- Check Leave Balance
	declare @Leave_Name as varchar(100)
	declare @ErrString as varchar(200)	
	set @Temp_Max_Date = null
	set @Temp_leave_Bal = 0
	Declare @Alpha_Emp_Code varchar(50)
	
	DECLARE @LEAVE_OP_ID AS NUMERIC(18,0)  --Added by Jaina 17-03-2017
	SET @LEAVE_OP_ID = 0
	
	IF UPDATE (Leave_Id) 
		begin
			select @Emp_Id = emp_Id, @Cmp_ID = Cmp_ID, @For_Date = For_Date,@leave_id = Leave_id , @Leave_OP_Days = Leave_OP_Days 
				from inserted ins 
				
								
			select @Leave_Tran_ID  = Isnull(max(Leave_Tran_ID),0) + 1 From dbo.T0140_LEAVE_TRANSACTION 
			
			if exists (select Emp_ID from dbo.T0140_LEAVE_TRANSACTION where emp_id = @emp_id and Leave_id = @leave_id and 
				Cmp_ID = @Cmp_ID )
				begin
					
					if exists(select For_Date from dbo.T0140_LEAVE_TRANSACTION where leave_ID = @Leave_ID and for_date < @for_date and Emp_ID = @Emp_Id) 
						begin

							If Not Exists (Select 1 From dbo.T0140_LEAVE_TRANSACTION where leave_ID = @Leave_ID and for_date = Dateadd(dd,-1,@for_date) and Emp_ID = @Emp_Id)
								Begin
									select @Leave_Tran_ID  = Isnull(max(Leave_Tran_ID),0) + 1 From dbo.T0140_LEAVE_TRANSACTION
									
									INSERT dbo.T0140_LEAVE_TRANSACTION(Leave_Tran_ID,emp_id,Leave_Id,Cmp_ID,For_Date,Leave_Opening,Leave_Closing,Leave_Used,Leave_Credit,Leave_Posting)
									--VALUES(@Leave_Tran_ID,@emp_id,@leave_Id,@Cmp_ID,Dateadd(dd,-1,@for_date),@Temp_leave_Bal,@Temp_leave_Bal,0,0,@Temp_leave_Bal)												    		
									SELECT TOP 1  @Leave_Tran_ID,Emp_ID, Leave_ID,Cmp_ID, Dateadd(dd,-1,@for_date),Leave_Closing,Leave_Closing,0,0,Leave_Closing
									FROM dbo.T0140_LEAVE_TRANSACTION 
									WHERE leave_ID = @Leave_ID and Emp_ID = @Emp_ID and for_Date < Dateadd(dd,-1,@for_date)
									ORDER BY For_Date DESC
								End	

							select @Temp_max_Date   = max(For_Date)  from dbo.T0140_LEAVE_TRANSACTION where leave_ID = @Leave_ID and for_date < @for_date and Emp_ID = @Emp_ID
							
							select @Temp_leave_Bal = isnull(Leave_Closing,0) from dbo.T0140_LEAVE_TRANSACTION where leave_ID = @Leave_ID and Emp_ID = @Emp_ID and 
							for_Date = @Temp_Max_DAte

							If @For_date = @Temp_Max_Date
								Begin
									update dbo.T0140_LEAVE_TRANSACTION 
									set 
									Leave_Opening =@Leave_OP_Days,
									Leave_Posting = @Temp_leave_Bal,
									Leave_Closing = (@Leave_OP_Days + Leave_Credit) -  Leave_Used
									where Leave_ID = @Leave_Id 
									and Emp_ID  =    @Emp_ID 
									and for_Date =	 @Temp_Max_Date
								End
							Else
								Begin
									update dbo.T0140_LEAVE_TRANSACTION 
									set 
									Leave_Posting = @Temp_leave_Bal,
									Leave_Closing = 0
									where Leave_ID = @Leave_Id 
									and Emp_ID  =    @Emp_ID 
									and for_Date =	 @Temp_Max_Date
								End
							
							
							--Alpesh 17-Sep-2011
							Declare @Chg_For_Date datetime
							Declare @Chg_Tran_Id numeric  
							Declare @Pre_Closing numeric(22,5)							
							

							if not exists (select 1 from dbo.T0140_LEAVE_TRANSACTION where emp_id = @emp_id and Leave_id = @leave_id and 
										Cmp_ID = @Cmp_ID and for_date = @for_date )
								begin
									select @Leave_Tran_ID  = Isnull(max(Leave_Tran_ID),0) + 1 From dbo.T0140_LEAVE_TRANSACTION 
								
									insert dbo.T0140_LEAVE_TRANSACTION(Leave_Tran_ID,emp_id,Leave_Id,Cmp_ID,For_Date,Leave_Opening,Leave_Closing,Leave_Used,Leave_Credit)
									values(@Leave_Tran_ID,@emp_id,@leave_Id,@Cmp_ID,@For_Date,@Leave_OP_Days,@Leave_OP_Days,0,0)												    		
								end
							else  --- Added by Hardik 18/01/2021 for Westrock client
								begin
									update dbo.T0140_LEAVE_TRANSACTION 
									set 
									Leave_Opening =@Leave_OP_Days,
									Leave_Closing = (@Leave_OP_Days + Leave_Credit) -  Leave_Used
									where Leave_ID = @Leave_Id 
									and Emp_ID  =    @Emp_ID 
									and for_Date =	 @for_date
								end
							
							--Select top 1 @Chg_Tran_Id = leave_tran_id, @Chg_For_Date = for_date from dbo.T0140_LEAVE_TRANSACTION where leave_id = @leave_Id 
							--and emp_id = @emp_id and for_date > @Temp_Max_Date and Cmp_ID = @Cmp_ID order by for_date 
							 
							 
							--update dbo.T0140_LEAVE_TRANSACTION set 
							--	  Leave_Opening = @Leave_OP_Days
							--	 ,Leave_Closing = @Leave_OP_Days + Leave_Credit - Leave_Used 
							--	 ,@Pre_Closing  = @Leave_OP_Days + Leave_Credit - Leave_Used 
							--where leave_tran_id = @Chg_Tran_Id
							
							--set @Pre_Closing = @Leave_OP_Days
							Select @Pre_Closing=Leave_Closing from T0140_LEAVE_TRANSACTION where emp_id = @emp_id and Leave_id = @leave_id and 
										Cmp_ID = @Cmp_ID and for_date = @Temp_max_Date
										
							if @Pre_Closing is null
								set @Pre_Closing = 0
																								
							declare cur1 cursor for 
								Select leave_tran_id,For_Date from dbo.T0140_LEAVE_TRANSACTION where leave_id = @leave_Id and emp_id = @emp_id 
								and Cmp_ID = @Cmp_ID and for_date > @Temp_Max_Date order by for_date
							open cur1
							fetch next from cur1 into @Chg_Tran_Id,@Chg_For_Date
							while @@fetch_status = 0
							begin
								--Added by Hardik 16/12/2011
								If exists(Select Leave_Op_Id From T0095_LEAVE_OPENING Where Cmp_ID = @Cmp_ID And Emp_Id = @Emp_Id And Leave_ID = @Leave_Id And For_Date = @Chg_For_Date And Leave_Op_Days <> 0)
									Begin
										Goto c;
									End
							
								update dbo.T0140_LEAVE_TRANSACTION set 
									 Leave_Opening = @Pre_Closing
									,Leave_Closing = @Pre_Closing + Leave_Credit - Leave_Used 									
								where leave_tran_id = @Chg_Tran_Id
						
							C:
								set @Pre_Closing = (select Leave_Closing from dbo.T0140_LEAVE_TRANSACTION where leave_tran_id = @Chg_Tran_Id)
							
								fetch next from cur1 into @Chg_Tran_Id,@Chg_For_Date
							end
							
							close cur1
							deallocate cur1							

							--NIkunj 28-Jan-2011----						
							
							Select @Temp_Max_Date = Max(For_date) From dbo.T0140_leave_transaction where Emp_Id=@Emp_Id And Cmp_Id=@Cmp_id And For_date >= @For_Date And Leave_Id=@Leave_Id
							
							Select @Alpha_Emp_Code = Alpha_Emp_Code from T0080_EMP_MASTER where Emp_ID=@Emp_Id	--Alpesh 20-Aug-2012
							
							If Exists(select Leave_Closing from T0140_LEAVE_TRANSACTION  LT Inner join T0040_LEAVE_MASTER LM on
								LT.Leave_ID = LM.Leave_ID and Leave_Paid_Unpaid ='P' And Leave_Negative_Allow = 0
								Where emp_id = @emp_id and LT.leave_id = @leave_id and LT.CMP_ID = @CMP_ID and Leave_Closing < 0 and For_Date = @Temp_Max_Date)
							begin
								select @Leave_Name = Leave_Name from T0040_LEAVE_MASTER where leave_id = @leave_id 
								set @ErrString = 'Balance not available on given Date - ' + @Leave_Name + ' for Emp_Code=' + @Alpha_Emp_Code	
								RAISERROR (@ErrString, 16, 2) 							
							End					
							
						end		
					else
						begin
							If Not Exists (Select 1 From dbo.T0140_LEAVE_TRANSACTION where leave_ID = @Leave_ID and for_date = Dateadd(dd,-1,@for_date) and Emp_ID = @Emp_Id)
								Begin
									select @Leave_Tran_ID  = Isnull(max(Leave_Tran_ID),0) + 1 From dbo.T0140_LEAVE_TRANSACTION
									
									INSERT dbo.T0140_LEAVE_TRANSACTION(Leave_Tran_ID,emp_id,Leave_Id,Cmp_ID,For_Date,Leave_Opening,Leave_Closing,Leave_Used,Leave_Credit,Leave_Posting)
									--VALUES(@Leave_Tran_ID,@emp_id,@leave_Id,@Cmp_ID,Dateadd(dd,-1,@for_date),@Temp_leave_Bal,@Temp_leave_Bal,0,0,@Temp_leave_Bal)												    		
									SELECT TOP 1  @Leave_Tran_ID,Emp_ID, Leave_ID,Cmp_ID, Dateadd(dd,-1,@for_date),Leave_Closing,Leave_Closing,0,0,Leave_Closing
									FROM dbo.T0140_LEAVE_TRANSACTION 
									WHERE leave_ID = @Leave_ID and Emp_ID = @Emp_ID and for_Date < Dateadd(dd,-1,@for_date)
									ORDER BY For_Date DESC
								End	
								
							select @Leave_Tran_ID  = Isnull(max(Leave_Tran_ID),0) + 1 From dbo.T0140_LEAVE_TRANSACTION
							insert dbo.T0140_LEAVE_TRANSACTION(Leave_Tran_ID,emp_id,Leave_Id,Cmp_ID,For_Date,Leave_Opening,
								Leave_Closing,Leave_Used,Leave_Credit)
							values(@Leave_Tran_ID,@emp_id,@leave_Id,@Cmp_ID,@for_Date,@Leave_OP_Days
								,@Leave_OP_Days,0,0)

							--set @Pre_Closing = @Leave_OP_Days
							Select @Pre_Closing=Leave_Closing from T0140_LEAVE_TRANSACTION where emp_id = @emp_id and Leave_id = @leave_id and 
										Cmp_ID = @Cmp_ID and for_date = @for_Date
										
							if @Pre_Closing is null
								set @Pre_Closing = 0
																								
							declare cur1 cursor for 
								Select leave_tran_id,For_Date from dbo.T0140_LEAVE_TRANSACTION where leave_id = @leave_Id and emp_id = @emp_id 
								and Cmp_ID = @Cmp_ID and for_date > @for_Date order by for_date
							open cur1
							fetch next from cur1 into @Chg_Tran_Id,@Chg_For_Date
							while @@fetch_status = 0
							begin
								--Added by Hardik 16/12/2011
								If exists(Select Leave_Op_Id From T0095_LEAVE_OPENING Where Cmp_ID = @Cmp_ID And Emp_Id = @Emp_Id And Leave_ID = @Leave_Id And For_Date = @Chg_For_Date And Leave_Op_Days <> 0)
									Begin
										Goto d;
									End
							
								update dbo.T0140_LEAVE_TRANSACTION set 
									 Leave_Opening = @Pre_Closing
									,Leave_Closing = @Pre_Closing + Leave_Credit - Leave_Used 									
								where leave_tran_id = @Chg_Tran_Id
						
							D:
								set @Pre_Closing = (select Leave_Closing from dbo.T0140_LEAVE_TRANSACTION where leave_tran_id = @Chg_Tran_Id)
							
								fetch next from cur1 into @Chg_Tran_Id,@Chg_For_Date
							end
							
							close cur1
							deallocate cur1									
						end 	
				end				
			else
				begin
					If Not Exists (Select 1 From dbo.T0140_LEAVE_TRANSACTION where leave_ID = @Leave_ID and for_date = Dateadd(dd,-1,@for_date) and Emp_ID = @Emp_Id)
						Begin
							select @Leave_Tran_ID  = Isnull(max(Leave_Tran_ID),0) + 1 From dbo.T0140_LEAVE_TRANSACTION
							
							INSERT dbo.T0140_LEAVE_TRANSACTION(Leave_Tran_ID,emp_id,Leave_Id,Cmp_ID,For_Date,Leave_Opening,Leave_Closing,Leave_Used,Leave_Credit,Leave_Posting)
							--VALUES(@Leave_Tran_ID,@emp_id,@leave_Id,@Cmp_ID,Dateadd(dd,-1,@for_date),@Temp_leave_Bal,@Temp_leave_Bal,0,0,@Temp_leave_Bal)												    		
							SELECT TOP 1  @Leave_Tran_ID,Emp_ID, Leave_ID,Cmp_ID, Dateadd(dd,-1,@for_date),Leave_Closing,Leave_Closing,0,0,Leave_Closing
							FROM dbo.T0140_LEAVE_TRANSACTION 
							WHERE leave_ID = @Leave_ID and Emp_ID = @Emp_ID and for_Date < Dateadd(dd,-1,@for_date)
							ORDER BY For_Date DESC
						End	

						select @Leave_Tran_ID  = Isnull(max(Leave_Tran_ID),0) + 1 From dbo.T0140_LEAVE_TRANSACTION
						
						insert dbo.T0140_LEAVE_TRANSACTION(Leave_Tran_ID,emp_id,Leave_Id,Cmp_ID,For_Date,Leave_Opening,
							Leave_Closing,Leave_Used,Leave_Credit)
						values(@Leave_Tran_ID,@emp_id,@leave_Id,@Cmp_ID,@for_Date,@Leave_OP_Days
							,@Leave_OP_Days,0,0)
							
							
							--set @Pre_Closing = @Leave_OP_Days
							Select @Pre_Closing=Leave_Closing from T0140_LEAVE_TRANSACTION where emp_id = @emp_id and Leave_id = @leave_id and 
										Cmp_ID = @Cmp_ID and for_date = @for_Date
										
							if @Pre_Closing is null
								set @Pre_Closing = 0
																								
							declare cur1 cursor for 
								Select leave_tran_id,For_Date from dbo.T0140_LEAVE_TRANSACTION where leave_id = @leave_Id and emp_id = @emp_id 
								and Cmp_ID = @Cmp_ID and for_date > @for_Date order by for_date
							open cur1
							fetch next from cur1 into @Chg_Tran_Id,@Chg_For_Date
							while @@fetch_status = 0
							begin
								--Added by Hardik 16/12/2011
								If exists(Select Leave_Op_Id From T0095_LEAVE_OPENING Where Cmp_ID = @Cmp_ID And Emp_Id = @Emp_Id And Leave_ID = @Leave_Id And For_Date = @Chg_For_Date And Leave_Op_Days <> 0)
									Begin
										Goto e;
									End
							
								update dbo.T0140_LEAVE_TRANSACTION set 
									 Leave_Opening = @Pre_Closing
									,Leave_Closing = @Pre_Closing + Leave_Credit - Leave_Used 									
								where leave_tran_id = @Chg_Tran_Id
						
							E:
								set @Pre_Closing = (select Leave_Closing from dbo.T0140_LEAVE_TRANSACTION where leave_tran_id = @Chg_Tran_Id)
							
								fetch next from cur1 into @Chg_Tran_Id,@Chg_For_Date
							end
							
							close cur1
							deallocate cur1									
						end 	
		end
	
	else
		begin
			
			declare curDel1 cursor for
			select emp_Id, Cmp_ID,For_Date,	Leave_id ,Leave_OP_Days,Leave_Op_ID from deleted del
			
			open curDel1
			fetch next from curDel1 into @emp_id,@Cmp_ID,@for_date,@Leave_Id , @Leave_OP_Days,@Leave_Op_ID
			while @@fetch_status = 0
			begin 
				set @Temp_max_Date = null
				set @Temp_leave_Bal = 0
				
				--Alpesh 17-Dec-2011
				
				if exists(select For_Date from dbo.T0140_LEAVE_TRANSACTION where leave_ID = @Leave_ID and for_date < @for_date and Emp_ID = @Emp_Id) 
					begin
						select @Temp_max_Date   = max(For_Date)  from dbo.T0140_LEAVE_TRANSACTION where leave_ID = @Leave_ID and for_date < @for_date and Emp_ID = @Emp_ID
						
						--select @Temp_leave_Bal = isnull(Leave_Posting,0) from dbo.T0140_LEAVE_TRANSACTION where leave_ID = @Leave_ID and Emp_ID = @Emp_ID and 
						--for_Date = @Temp_Max_Date						
						
						Update T
						Set Leave_Closing = (Leave_Opening + Leave_Credit) - (Leave_Used + Isnull(Leave_Adj_L_Mark,0)+ Isnull(Leave_Encash_Days,0) + Isnull(Back_Dated_Leave,0) + Isnull(Arrear_Used,0)+Isnull(CF_Laps_Days,0)),
							Leave_Posting = null
						From dbo.T0140_LEAVE_TRANSACTION T
						where Leave_ID = @Leave_ID and Emp_ID = @Emp_ID and for_Date = @Temp_Max_Date And Leave_Posting Is not null
						
						
						Select @Pre_Closing=Leave_Closing from T0140_LEAVE_TRANSACTION where emp_id = @emp_id and Leave_id = @leave_id and 
						Cmp_ID = @Cmp_ID and for_date = @Temp_max_Date
					end		
				else
					begin
						set @Temp_max_Date = @For_date
						set @Pre_Closing = 0		
					end
							
				if @Pre_Closing is null
					set @Pre_Closing = 0
																					
				declare cur1 cursor for 
					Select leave_tran_id,For_Date from dbo.T0140_LEAVE_TRANSACTION where leave_id = @leave_Id and emp_id = @emp_id 
					and Cmp_ID = @Cmp_ID and for_date > @Temp_Max_Date order by for_date
				open cur1
				fetch next from cur1 into @Chg_Tran_Id,@Chg_For_Date
				while @@fetch_status = 0
				begin
					--Added by Hardik 16/12/2011
										
					If exists(Select Leave_Op_Id From T0095_LEAVE_OPENING 
								Where Cmp_ID = @Cmp_ID And Emp_Id = @Emp_Id And Leave_ID = @Leave_Id 
										And For_Date = @Chg_For_Date And Leave_Op_Days <> 0 AND Leave_Op_ID = @Leave_Op_ID)	--Change by Jaina 17-03-2017					
						Begin
							Break;
						End
				
					update dbo.T0140_LEAVE_TRANSACTION set 
						 Leave_Opening = @Pre_Closing
						,Leave_Closing = @Pre_Closing + Leave_Credit - Leave_Used 									
					where leave_tran_id = @Chg_Tran_Id
					
				
					set @Pre_Closing = (select Leave_Closing from dbo.T0140_LEAVE_TRANSACTION where leave_tran_id = @Chg_Tran_Id)
				
					fetch next from cur1 into @Chg_Tran_Id,@Chg_For_Date
				end
				
				close cur1
				deallocate cur1					
				
				--Added by Jaina 02-07-2018 Start
				if exists (SELECT 1 from T0140_LEAVE_TRANSACTION WHERE Cmp_ID=@Cmp_ID and Leave_ID = @Leave_Id 
						and Leave_Credit = 0 AND Leave_Used = 0 AND Isnull(Leave_Posting,0) = 0 
						AND isnull(Leave_Adj_L_Mark,0) = 0 AND Arrear_Used = 0 AND Leave_Encash_Days = 0 
						AND CompOff_Credit = 0 and CompOff_Debit = 0 AND CompOff_Balance = 0 and CompOff_Used = 0
						AND Half_Payment_Days = 0 and CF_Laps_Days = 0 
						and Emp_ID =@emp_id)
				BEGIN
						
						DELETE from T0140_LEAVE_TRANSACTION WHERE Cmp_ID=@Cmp_ID and Leave_ID = @Leave_Id 
						and Leave_Credit = 0 AND Leave_Used = 0 AND Isnull(Leave_Posting,0) = 0
						AND isnull(Leave_Adj_L_Mark,0) = 0 AND Arrear_Used = 0 AND Leave_Encash_Days = 0 
						AND CompOff_Credit = 0 and CompOff_Debit = 0 AND CompOff_Balance = 0 and CompOff_Used = 0
						AND Half_Payment_Days = 0 and CF_Laps_Days = 0 
						and Emp_ID =@emp_id
						And Not Exists(Select 1 From T0095_LEAVE_OPENING Where Emp_Id=@emp_id And Leave_ID = @Leave_Id and For_Date = T0140_LEAVE_TRANSACTION.For_Date)
				END
				--Added by Jaina 02-07-2018 End
				
				fetch next from curDel1 into @emp_id,@Cmp_ID,@for_date,@Leave_Id , @Leave_OP_Days,@Leave_Op_ID
			end 	
			close curDel1
			deallocate curDel1
		
		end




