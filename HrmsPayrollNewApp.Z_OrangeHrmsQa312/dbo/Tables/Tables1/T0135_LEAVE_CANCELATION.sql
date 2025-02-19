CREATE TABLE [dbo].[T0135_LEAVE_CANCELATION] (
    [LV_Can_Tran_ID]    NUMERIC (18)   NOT NULL,
    [Cmp_ID]            NUMERIC (18)   NOT NULL,
    [Emp_ID]            NUMERIC (18)   NOT NULL,
    [Leave_Approval_ID] NUMERIC (18)   NOT NULL,
    [Leave_ID]          NUMERIC (18)   NOT NULL,
    [Leave_Period]      NUMERIC (18)   NOT NULL,
    [For_Date]          DATETIME       NOT NULL,
    [In_Time]           DATETIME       NULL,
    [Out_Time]          DATETIME       NULL,
    [LV_Can_Day]        NUMERIC (5, 1) NOT NULL,
    [LV_Can_Status]     NUMERIC (1)    NOT NULL,
    [LV_Can_Comments]   VARCHAR (250)  NOT NULL,
    CONSTRAINT [PK_T0135_LEAVE_CANCELATION] PRIMARY KEY CLUSTERED ([LV_Can_Tran_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0135_LEAVE_CANCELATION_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0135_LEAVE_CANCELATION_T0040_LEAVE_MASTER] FOREIGN KEY ([Leave_ID]) REFERENCES [dbo].[T0040_LEAVE_MASTER] ([Leave_ID]),
    CONSTRAINT [FK_T0135_LEAVE_CANCELATION_T0080_EMP_MASTER] FOREIGN KEY ([Emp_ID]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID]),
    CONSTRAINT [FK_T0135_LEAVE_CANCELATION_T0120_LEAVE_APPROVAL] FOREIGN KEY ([Leave_Approval_ID]) REFERENCES [dbo].[T0120_LEAVE_APPROVAL] ([Leave_Approval_ID])
);


GO





CREATE TRIGGER [dbo].[Tri_T0135_LEAVE_CANCELATION_UPDATE]
ON [dbo].[T0135_LEAVE_CANCELATION] 
FOR UPDATE 
AS
	Declare @Leave_ID	numeric 
	Declare @Emp_ID		numeric 
	Declare @Leave_Cancel numeric(18,1)
	Declare @For_Date	Datetime 
	Declare @cmp_ID		numeric 
	Declare @Leave_Used numeric(12,1)
	Declare @Last_Leave_Closing numeric(12,1)
	Declare @Leave_Tran_ID	numeric 
	
/*	
	select @leave_ID = LEave_ID ,@Emp_ID = Emp_ID ,@Leave_Cancel = Lv_Can_Day
				,@For_Date =For_date ,@Cmp_ID =cmp_ID From Deleted
				
				update T0140_LEAVE_TRANSACTION set 
					Leave_Closing = Leave_Closing   - @Leave_Cancel,
					Leave_Cancel = Leave_Cancel- @Leave_Cancel 
				where leave_id = @leave_Id and emp_id = @emp_id and for_date = @for_date 
				and Cmp_ID = @Cmp_ID	
						
				update T0140_LEAVE_TRANSACTION set 
						Leave_Closing = Leave_Closing  - @Leave_Cancel 
				where leave_id = @leave_Id and emp_id = @emp_id and for_date > @for_date 
				and Cmp_ID = @Cmp_ID	
				
	
			select @leave_ID = LEave_ID ,@Emp_ID = Emp_ID ,@Leave_Cancel = Lv_Can_Day
				,@For_Date =For_date ,@Cmp_ID =cmp_ID From inserted 
				
				Select * from T0140_LEAVE_TRANSACTION where Leave_Id = @Leave_Id 
				
					
					update T0140_LEAVE_TRANSACTION set 
						Leave_Closing = Leave_Closing + @Leave_Cancel,
						Leave_Cancel = @Leave_Cancel	
					where Leave_Id = @Leave_Id and for_date = @For_Date and Cmp_ID = @Cmp_ID
						and emp_Id = @emp_Id
						
					

					update T0140_LEAVE_TRANSACTION set 
						Leave_Closing = Leave_Closing + @Leave_Cancel 
					where Leave_Id = @Leave_Id and for_date > @For_Date and Cmp_ID = @Cmp_ID
						and emp_Id = @emp_Id
		
		
*/





GO





CREATE TRIGGER [dbo].[Tri_T0135_LEAVE_CANCELATION]
ON [dbo].[T0135_LEAVE_CANCELATION] 
FOR INSERT, DELETE 
AS

	Declare @Leave_ID	numeric 
	Declare @Emp_ID		numeric 
	Declare @Leave_Cancel numeric(18,1)
	Declare @For_Date	Datetime 
	Declare @cmp_ID		numeric 
	Declare @Leave_Used numeric(12,1)
	Declare @Last_Leave_Closing numeric(12,1)
	Declare @Leave_Tran_ID	numeric 
	
	
	
	IF UPDATE (Lv_Can_Tran_ID) 
		begin
		   
			select @leave_ID = LEave_ID ,@Emp_ID = Emp_ID ,@Leave_Cancel = Lv_Can_Day
				,@For_Date =For_date ,@Cmp_ID =cmp_ID From inserted 
					
			
						
					update T0140_LEAVE_TRANSACTION set 
						Leave_Closing = Leave_Closing + @Leave_Cancel,
						Leave_Cancel = @Leave_Cancel	
					where Leave_Id = @Leave_Id and for_date = @For_Date and Cmp_ID = @Cmp_ID
						and emp_Id = @emp_Id
/*
					update T0140_LEAVE_TRANSACTION set 
						Leave_Closing = Leave_Closing + @Leave_Cancel 
					where Leave_Id = @Leave_Id and for_date > @For_Date and Cmp_ID = @Cmp_ID
						and emp_Id = @emp_Id */
						
								---Alpesh 26-Sep-2011
								Declare @Chg_Tran_Id numeric  
								Declare @For_Date_Cur Datetime
								Declare @Pre_Closing numeric(18,2)
								Declare @Leave_Posting numeric(18,2)
								
								--set @For_Date= @A_From_Date
																				
								select @Pre_Closing = isnull(Leave_Closing,0) from T0140_LEAVE_TRANSACTION
	    							where for_date = (select max(for_date) from T0140_LEAVE_TRANSACTION where for_date <= @For_date
	    												and leave_Id = @leave_id and Cmp_ID = @Cmp_ID and emp_Id = @emp_Id) 
	    								and Cmp_ID = @Cmp_ID
	    								and leave_id = @leave_Id and emp_Id = @emp_Id
	    								    								
							
								if @Pre_Closing is null
									set @Pre_Closing = 0    								

							
								declare cur1 cursor for 
									Select leave_tran_id,For_Date from dbo.T0140_LEAVE_TRANSACTION where leave_id = @leave_Id and emp_id = @emp_id 
									and Cmp_ID = @Cmp_ID and for_date > @For_date order by for_date
								open cur1
								fetch next from cur1 into @Chg_Tran_Id,@For_Date_Cur
								while @@fetch_status = 0
								begin
									--select @For_date,@For_Date_Cur
									--Added by Hardik 16/12/2011
									If exists(Select Leave_Op_Id From T0095_LEAVE_OPENING Where Cmp_ID = @Cmp_ID And Emp_Id = @Emp_Id And Leave_ID = @Leave_Id And For_Date = @For_Date_Cur And Leave_Op_Days > 0)
										Begin
											Goto c;
										End
								
									Select @Leave_Posting = isnull(Leave_Posting,0) from dbo.T0140_LEAVE_TRANSACTION where leave_tran_id = @Chg_Tran_Id
									
									--if @Leave_Posting <> 0
									--	begin
									--		update dbo.T0140_LEAVE_TRANSACTION set 
									--			 Leave_Opening = @Pre_Closing,
									--			 Leave_Closing = @Pre_Closing + Leave_Credit - Leave_Used, 
									--			 Leave_Posting = @Pre_Closing + Leave_Credit - Leave_Used 									
									--		where leave_tran_id = @Chg_Tran_Id
									--		--break
									--	end
									--else										
									
									
										begin
--commented by hardik 16/12/2011											
--											If Not exists (select 1 from dbo.T0140_LEAVE_TRANSACTION where Leave_Posting <> 0 and leave_id = @leave_Id and emp_Id = @emp_Id And For_Date = 
--													(Select MAX(For_Date) From dbo.T0140_LEAVE_TRANSACTION Where For_Date < @For_Date_Cur and leave_id = @leave_Id and emp_Id = @emp_Id ))
												Begin

													update dbo.T0140_LEAVE_TRANSACTION set 
													  Leave_Opening = @Pre_Closing,
													  Leave_Closing = @Pre_Closing + isnull(Leave_Credit,0) + ISNULL(Leave_Cancel,0) - isnull(Leave_Used,0) 									
													 where leave_tran_id = @Chg_Tran_Id
										C:			
													set @Pre_Closing = isnull((select isnull(Leave_Closing,0) from dbo.T0140_LEAVE_TRANSACTION where leave_tran_id = @Chg_Tran_Id),0)
												End
											--commented by hardik 16/12/2011
											--Else
											--	Begin
											--		update dbo.T0140_LEAVE_TRANSACTION set 
											--			Leave_Closing = isnull(Leave_Opening,0) + isnull(Leave_Credit,0) - isnull(Leave_Used,0) 									
											--		Where leave_tran_id = @Chg_Tran_Id

											--		set @Pre_Closing = isnull((select isnull(Leave_Closing,0) from dbo.T0140_LEAVE_TRANSACTION where leave_tran_id = @Chg_Tran_Id),0)
											--	End
										end																
								
									fetch next from cur1 into @Chg_Tran_Id,@For_Date_Cur
								end
								
								close cur1
								deallocate cur1	
								
								--- End 						
		end	
	else
		begin
	
			select @leave_ID = LEave_ID ,@Emp_ID = Emp_ID ,@Leave_Cancel = Lv_Can_Day
				,@For_Date =For_date ,@Cmp_ID =cmp_ID From Deleted
				
				update T0140_LEAVE_TRANSACTION set 
					Leave_Closing = Leave_Closing   - @Leave_Cancel,
					Leave_Cancel = Leave_Cancel - @Leave_Cancel					
				where leave_id = @leave_Id and emp_id = @emp_id and for_date = @for_date 
				and Cmp_ID = @Cmp_ID	
						
				---Alpesh 26-Sep-2011
				select @Pre_Closing = isnull(Leave_Closing,0) from T0140_LEAVE_TRANSACTION
					where for_date = (select max(for_date) from T0140_LEAVE_TRANSACTION where for_date <= @For_date
										and leave_Id = @leave_id and Cmp_ID = @Cmp_ID and emp_Id = @emp_Id) 
						and Cmp_ID = @Cmp_ID
						and leave_id = @leave_Id and emp_Id = @emp_Id
						    								
			
				if @Pre_Closing is null
					set @Pre_Closing = 0    								

			
				declare cur1 cursor for 
					Select leave_tran_id,For_Date from dbo.T0140_LEAVE_TRANSACTION where leave_id = @leave_Id and emp_id = @emp_id 
					and Cmp_ID = @Cmp_ID and for_date > @For_date order by for_date
				open cur1
				fetch next from cur1 into @Chg_Tran_Id,@For_Date_Cur
				while @@fetch_status = 0
				begin
					--select @For_date,@For_Date_Cur
					--Added by Hardik 16/12/2011
					If exists(Select Leave_Op_Id From T0095_LEAVE_OPENING Where Cmp_ID = @Cmp_ID And Emp_Id = @Emp_Id And Leave_ID = @Leave_Id And For_Date = @For_Date_Cur And Leave_Op_Days > 0)
						Begin
							Goto D;
						End
				
					Select @Leave_Posting = isnull(Leave_Posting,0) from dbo.T0140_LEAVE_TRANSACTION where leave_tran_id = @Chg_Tran_Id
					
					--if @Leave_Posting <> 0
					--	begin
					--		update dbo.T0140_LEAVE_TRANSACTION set 
					--			 Leave_Opening = @Pre_Closing,
					--			 Leave_Closing = @Pre_Closing + Leave_Credit - Leave_Used, 
					--			 Leave_Posting = @Pre_Closing + Leave_Credit - Leave_Used 									
					--		where leave_tran_id = @Chg_Tran_Id
					--		--break
					--	end
					--else										
					
					
						begin
--commented by hardik 16/12/2011											
--											If Not exists (select 1 from dbo.T0140_LEAVE_TRANSACTION where Leave_Posting <> 0 and leave_id = @leave_Id and emp_Id = @emp_Id And For_Date = 
--													(Select MAX(For_Date) From dbo.T0140_LEAVE_TRANSACTION Where For_Date < @For_Date_Cur and leave_id = @leave_Id and emp_Id = @emp_Id ))
								Begin

									update dbo.T0140_LEAVE_TRANSACTION set 
									  Leave_Opening = @Pre_Closing,
									  Leave_Closing = @Pre_Closing + isnull(Leave_Credit,0)  - isnull(Leave_Used,0) 									
									 where leave_tran_id = @Chg_Tran_Id
						D:			
									set @Pre_Closing = isnull((select isnull(Leave_Closing,0) from dbo.T0140_LEAVE_TRANSACTION where leave_tran_id = @Chg_Tran_Id),0)
								End
							--commented by hardik 16/12/2011
							--Else
							--	Begin
							--		update dbo.T0140_LEAVE_TRANSACTION set 
							--			Leave_Closing = isnull(Leave_Opening,0) + isnull(Leave_Credit,0) - isnull(Leave_Used,0) 									
							--		Where leave_tran_id = @Chg_Tran_Id

							--		set @Pre_Closing = isnull((select isnull(Leave_Closing,0) from dbo.T0140_LEAVE_TRANSACTION where leave_tran_id = @Chg_Tran_Id),0)
							--	End
						end																
				
					fetch next from cur1 into @Chg_Tran_Id,@For_Date_Cur
				end
				
				close cur1
				deallocate cur1	
				
				--- End 		
				
		end




