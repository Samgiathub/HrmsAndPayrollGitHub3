CREATE TABLE [dbo].[T0100_LEAVE_CF_Advance_Leave_Balance] (
    [LEAVE_Tran_ID]         NUMERIC (18)    NOT NULL,
    [LEAVE_CF_ID]           NUMERIC (18)    NULL,
    [Cmp_ID]                NUMERIC (18)    NULL,
    [Emp_ID]                NUMERIC (18)    NULL,
    [Leave_ID]              NUMERIC (18)    NULL,
    [CF_For_Date]           DATETIME        NULL,
    [CF_From_Date]          DATETIME        NULL,
    [CF_To_Date]            DATETIME        NULL,
    [CF_Type]               VARCHAR (50)    NULL,
    [Is_Fnf]                TINYINT         DEFAULT ((0)) NOT NULL,
    [Advance_Leave_Balance] NUMERIC (18, 2) NOT NULL,
    [Last_Modify_Date]      DATETIME        NULL,
    [Last_Modify_By]        NUMERIC (18)    NULL,
    [CF_IsMakerChecker]     BIT             DEFAULT ((0)) NULL,
    PRIMARY KEY CLUSTERED ([LEAVE_Tran_ID] ASC)
);


GO



CREATE TRIGGER [dbo].[Tri_T0100_LEAVE_CF_Advance_Leave_Balance]  
ON [dbo].[T0100_LEAVE_CF_Advance_Leave_Balance]  
FOR  INSERT,  DELETE   
AS  
	set nocount on
	
	declare @Cmp_ID					numeric
	declare @For_Date				datetime
	declare @Emp_Id					numeric
	declare @Leave_Id				numeric
	declare @CF_Leave_Days			numeric(18,5)

	declare @Code					varchar(50)
	declare @Last_Leave_Closing		numeric(18,5)
	declare @ErrString				varchar(200)
	Declare @Leave_Tran_ID			numeric
	
	Declare @Leave_CF_flag Numeric
	set @leave_CF_flag = 0

		Declare @isMakerChaker int = 0 --Added by ronakk 05092022
	
	
	IF  update (Leave_ID) 
	begin		

		select @Cmp_ID= Cmp_ID ,@Emp_ID = Emp_ID ,@Leave_Id = ins.Leave_Id, @For_Date = CF_For_Date ,
		@CF_Leave_Days = ins.Advance_Leave_Balance 
		,@isMakerChaker = CF_IsMakerChecker --Added by ronakk 05092022
		From inserted ins	

		
		If @leave_Id > 0  
			begin
				if @leave_CF_flag = 0
					begin
						select @Leave_Tran_ID = Isnull(max(Leave_Tran_ID),0) +1 From T0140_LEAVE_TRANSACTION

							if exists(select * from T0140_LEAVE_TRANSACTION where For_date = @For_date and leave_Id = @leave_Id  
										and Cmp_ID = @Cmp_ID and emp_id = @emp_id)
								begin
									
									If @isMakerChaker <> 1
									Begin
									--Condtion by ronakk 05092022

									update T0140_LEAVE_TRANSACTION set Leave_Credit = Leave_Credit + @CF_Leave_Days,
											Leave_Closing = Leave_Opening + @CF_Leave_Days - (Leave_Used + isnull(CF_LAPS_DAYS,0)) --Leave_Closing + @CF_Leave_Days - (Leave_Used + isnull(CF_LAPS_DAYS,0))
											,Comoff_Flag = @leave_CF_flag
									where Leave_Id = @Leave_Id and for_date = @For_Date and Cmp_ID = @Cmp_ID
										and emp_Id = @emp_Id										

										--select Leave_Opening,@CF_Leave_Days,Leave_Used,CF_LAPS_DAYS
										--from  T0140_LEAVE_TRANSACTION where emp_Id = @emp_Id and Leave_Id = @Leave_Id and for_date > @For_Date and Cmp_ID = @Cmp_ID

									update T0140_LEAVE_TRANSACTION set Leave_Opening = Leave_Opening + @CF_Leave_Days
										,Leave_Closing = Leave_Opening + @CF_Leave_Days  - (Leave_Used + isnull(CF_LAPS_DAYS,0))
										,Comoff_Flag = @leave_CF_flag
									where Leave_Id = @Leave_Id and for_date > @For_Date and Cmp_ID = @Cmp_ID
										and emp_Id = @emp_Id
							
									End

								--select * from T0140_LEAVE_TRANSACTION where EMP_ID = 14842 and LEAVE_ID = 1194 and For_date = '2018-07-01 00:00:00'
									
							end
							else
								begin	

								If @isMakerChaker <> 1
									Begin
									--Condtion by ronakk 21092022
									select @Last_Leave_Closing = isnull(Leave_Closing,0) from T0140_LEAVE_TRANSACTION
										where for_date = (select max(for_date) from T0140_LEAVE_TRANSACTION 
												where for_date < @For_date
											and leave_Id = @leave_id and Cmp_ID = @Cmp_ID and emp_Id = @emp_Id) 
											and Cmp_ID = @Cmp_ID
											and leave_id = @leave_Id and emp_Id = @emp_Id
								     End
					


									if @Last_Leave_Closing is null 
										set  @Last_Leave_Closing = 0

									insert T0140_LEAVE_TRANSACTION(emp_id,Leave_Id,Cmp_ID,For_Date,Leave_Opening,Leave_Credit,
										Leave_Closing,Leave_Used,Leave_Tran_ID,Comoff_Flag
										,IsMakerChaker) --Added by ronakk 05092022
									values(@emp_id,@leave_Id,@Cmp_ID,@for_Date,@last_Leave_Closing,@CF_Leave_Days
										,@last_Leave_Closing + @CF_Leave_Days,0,@Leave_Tran_ID,@leave_CF_flag
										,@isMakerChaker) --Added by ronakk 05092022																    		


									If @isMakerChaker <> 1
									Begin
										--Condtion by ronakk 05092022

									update T0140_LEAVE_TRANSACTION set Leave_Opening = Leave_Opening + @CF_Leave_Days
										,Leave_Closing = Leave_Closing + @CF_Leave_Days,Comoff_Flag = @leave_CF_flag	
									where Leave_Id = @Leave_Id and for_date > @For_Date and Cmp_ID = @Cmp_ID 
										and emp_Id = @emp_Id

									end
										
							end
							
					end
				 else		
					begin
						select @Leave_Tran_ID = Isnull(max(Leave_Tran_ID),0) +1 From T0140_LEAVE_TRANSACTION
						
						if exists(select * from T0140_LEAVE_TRANSACTION where For_date = @For_date and leave_Id = @leave_Id  
										and Cmp_ID = @Cmp_ID and emp_id = @emp_id)
							begin

									If @isMakerChaker <> 1
									Begin
										--Condtion by ronakk 05092022

									update T0140_LEAVE_TRANSACTION set CompOff_Credit = CompOff_Credit + @CF_Leave_Days
										,CompOff_Balance = CompOff_Balance + @CF_Leave_Days,Comoff_Flag = 1
									where Leave_Id = @Leave_Id and for_date = @For_Date and Cmp_ID = @Cmp_ID
										and emp_Id = @emp_Id

									End
							end
						else
							begin	
								
									insert T0140_LEAVE_TRANSACTION(emp_id,Leave_Id,Cmp_ID,For_Date,Leave_Opening,Leave_Credit,
										Leave_Closing,Leave_Used,Leave_Tran_ID,Comoff_Flag,CompOff_Credit,CompOff_Balance
										,IsMakerChaker) --Added by ronakk 05092022
									values(@emp_id,@leave_Id,@Cmp_ID,@for_Date,0,0
										,0,0,@Leave_Tran_ID,1,@CF_Leave_Days,@CF_Leave_Days
										,@isMakerChaker) --Added by ronakk 05092022			
							end
						
					end 
			end
	end
else
	begin

		Declare Cur_del cursor for 
		select leave_Id , Cmp_ID,  emp_Id ,CF_For_Date ,Advance_Leave_Balance From deleted

		open cur_del
		fetch next from cur_del into @leave_Id , @Cmp_ID ,  @Emp_Id ,@For_Date ,@CF_Leave_Days
		while @@fetch_Status =0
			begin
					
					if  @leave_CF_flag = 0 
						begin

						 If @isMakerChaker <> 1
							 Begin
										--Condtion by ronakk 05092022

								update T0140_LEAVE_TRANSACTION set Leave_Credit = Leave_Credit - @CF_Leave_Days 
								,Leave_Closing = Leave_Closing - @CF_Leave_Days  --+ (Leave_Used + isnull(CF_LAPS_DAYS,0))
								,Comoff_Flag = @leave_CF_flag
								where leave_id = @leave_Id and emp_id = @emp_id and for_date = @for_date 
								and Cmp_ID = @Cmp_ID	
							
								update T0140_LEAVE_TRANSACTION set Leave_Opening = Leave_Opening - @CF_Leave_Days
								,Leave_Closing = Leave_Closing - @CF_Leave_Days --+ (Leave_Used + isnull(CF_LAPS_DAYS,0))
								,Comoff_Flag = @leave_CF_flag
								where leave_id = @leave_Id and emp_id = @emp_id and for_date > @for_date 
								and Cmp_ID = @Cmp_ID

							End
									
						end
					fetch next from cur_del into @leave_Id , @Cmp_ID ,  @Emp_Id ,@For_Date ,@CF_Leave_Days
			end
		close cur_Del
		deallocate cur_Del
		
	end


