CREATE TABLE [dbo].[T0095_Reim_Opening] (
    [Reim_Op_ID]          NUMERIC (18)    NOT NULL,
    [Emp_ID]              NUMERIC (18)    NOT NULL,
    [Cmp_ID]              NUMERIC (18)    NOT NULL,
    [RC_ID]               NUMERIC (18)    NOT NULL,
    [For_Date]            DATETIME        NOT NULL,
    [Reim_Opening_Amount] NUMERIC (18, 2) NULL,
    [User_Id]             NUMERIC (18)    NULL,
    [System_date]         DATETIME        NULL,
    CONSTRAINT [PK_T0095_Reim_Opening] PRIMARY KEY CLUSTERED ([Reim_Op_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0095_Reim_Opening_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0095_Reim_Opening_T0050_AD_MASTER] FOREIGN KEY ([RC_ID]) REFERENCES [dbo].[T0050_AD_MASTER] ([AD_ID]),
    CONSTRAINT [FK_T0095_Reim_Opening_T0080_EMP_MASTER] FOREIGN KEY ([Emp_ID]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID])
);


GO





CREATE TRIGGER [DBO].[Tri_T0095_ReimClaim_Opening]
ON [dbo].[T0095_Reim_Opening]
FOR  INSERT,UPDATE, DELETE 
AS
	Declare @ReimClaim_Tran_ID as numeric 
	declare @Emp_Id as numeric	
	declare @Cmp_ID as numeric
	declare @RC_ID as numeric
	declare @For_date as datetime
	declare @Reim_Opening_Amount as numeric(18,2)	
	Declare @Temp_Opening_Amount as numeric ( 18,2)
	declare @Temp_Max_Date as datetime
	
	declare @AD_Name as varchar(100)
	declare @ErrString as varchar(200)	
	set @Temp_Max_Date = null
	set @Temp_Opening_Amount = 0
	Declare @Alpha_Emp_Code varchar(50)
	
if exists(SELECT 1 from INSERTED)
begin
	
		select @Emp_Id = emp_Id, @Cmp_ID = Cmp_ID, @For_Date = For_Date,
				@RC_ID = RC_ID , @Reim_Opening_Amount = ins.Reim_Opening_Amount 
				from inserted ins 
				
			select @ReimClaim_Tran_ID  = Isnull(max(Reim_Tran_ID),0) + 1 From T0140_REimClaim_Transacation
			 
			if exists (select Emp_ID from dbo.T0140_REimClaim_Transacation where emp_id = @emp_id and Rc_ID = @RC_ID and Cmp_ID = @Cmp_ID AND For_date=@For_Date )				
				begin	
							
				if exists(select For_Date from dbo.T0140_REimClaim_Transacation where Rc_ID = @RC_ID and for_date <= @for_date and Emp_ID = @Emp_Id) 
						BEGIN
					
						 select @Temp_max_Date = max(For_Date)  from dbo.T0140_REimClaim_Transacation where Rc_ID = @RC_ID and for_date <= @for_date and Emp_ID = @Emp_ID
																				
							select @Temp_Opening_Amount = isnull(Reim_Closing,0)
									from dbo.T0140_REimClaim_Transacation 
									where Rc_ID = @RC_ID and Emp_ID = @Emp_ID and for_Date = @Temp_Max_DAte

							
							Declare @tempReim_Closing as numeric(18,0) --Ripal 07Nov2014
							If @For_date = @Temp_Max_Date
								Begin
									--Ripal 07Nov2014 Start
									Declare @tempfor_date as datetime
									select @tempfor_date = max(For_Date) from dbo.T0140_REimClaim_Transacation 
										where Rc_ID = @RC_ID and for_date < @Temp_max_Date and Emp_ID = @Emp_ID
																	
									select @tempReim_Closing = Reim_Closing
									From T0140_REimClaim_Transacation
									where RC_ID = @RC_ID and Emp_ID = @Emp_ID and for_Date = @tempfor_date
									
									update dbo.T0140_REimClaim_Transacation set 
										Reim_Closing = 0,
										Posting_Amount = @tempReim_Closing
									where RC_ID = @RC_ID and Emp_ID  =  @Emp_ID and for_Date =	 @tempfor_date
									--Ripal 07Nov2014 End
									
									update dbo.T0140_REimClaim_Transacation 
									set 
									Reim_Opening = @Reim_Opening_Amount, 
									Reim_Closing = (@Reim_Opening_Amount + Reim_Credit) -  Reim_Debit
									where RC_ID = @RC_ID
									and Emp_ID  =    @Emp_ID 
									and for_Date =	 @Temp_Max_Date
								End
							Else
								Begin
									--Ripal 07Nov2014 Start							
									select @tempReim_Closing = Reim_Closing
									From T0140_REimClaim_Transacation
									where RC_ID = @RC_ID
									and Emp_ID  =    @Emp_ID 
									and for_Date =	 @Temp_Max_Date
									--Ripal 07Nov2014 End
									
									update dbo.T0140_REimClaim_Transacation 
									set 
									Posting_Amount = @tempReim_Closing,  --Ripal 07Nov2014
									Reim_Closing = 0
									where RC_ID = @RC_ID
									and Emp_ID  =    @Emp_ID 
									and for_Date =	 @Temp_Max_Date
									
								End
							
							
							--Alpesh 17-Sep-2011
							Declare @Chg_For_Date datetime
							Declare @Chg_Tran_Id numeric  
							Declare @Pre_Closing numeric(18,2)							
							
							if not exists (select 1 from dbo.T0140_REimClaim_Transacation where emp_id = @emp_id and rc_ID = @RC_ID and 
										Cmp_ID = @Cmp_ID and for_date = @for_date )
							begin
								insert dbo.T0140_REimClaim_Transacation
								(Reim_Tran_ID,Cmp_ID,RC_ID,Emp_ID,For_Date,                
										Reim_Opening,Reim_Credit,Reim_Debit,Reim_Closing,RC_apr_ID,Sal_tran_ID)
										
								values(@ReimClaim_Tran_ID,@Cmp_ID,@RC_ID,@Emp_Id,@For_Date,
									   @Reim_Opening_Amount,0,0,@Reim_Opening_Amount,NULL,NULL)
							end
							
							--set @Pre_Closing = @Leave_OP_Days
							Select @Pre_Closing=Reim_Closing from T0140_REimClaim_Transacation where emp_id = @emp_id and RC_ID = @RC_ID and 
										Cmp_ID = @Cmp_ID and for_date = @Temp_max_Date
										
							if @Pre_Closing is null
								set @Pre_Closing = 0
																								
							declare cur1 cursor for 
								Select Reim_Tran_ID,For_Date from dbo.T0140_REimClaim_Transacation where RC_ID = @RC_ID and emp_id = @emp_id 
								and Cmp_ID = @Cmp_ID and for_date > @Temp_Max_Date order by for_date
							open cur1
							fetch next from cur1 into @Chg_Tran_Id,@Chg_For_Date
							while @@fetch_status = 0
							begin
								----Added by Hardik 16/12/2011
								--If exists(Select Reim_Op_ID From T0095_Reim_Opening Where Cmp_ID = @Cmp_ID And Emp_Id = @Emp_Id And RC_ID = @RC_ID And For_Date = @Chg_For_Date And Reim_Opening_Amount > 0)
								--	Begin
								--		Goto c;
								--	End
								--Ripal 07Nov2014 start
								if @For_Date = @Chg_For_Date
								   Begin
										set @Pre_Closing = (select Reim_Closing from dbo.T0140_REimClaim_Transacation where Reim_Tran_ID = @Chg_Tran_Id)
								   End
								--Ripal 07Nov2014 End
								
								update dbo.T0140_REimClaim_Transacation set 
									 Reim_Opening = Isnull(@Pre_Closing,0)
									,Reim_Closing = Isnull(@Pre_Closing,0) + Reim_Credit - Reim_Debit								
								where Reim_Tran_ID = @Chg_Tran_Id
						
							--C:
								set @Pre_Closing = (select Reim_Closing from dbo.T0140_REimClaim_Transacation where Reim_Tran_ID = @Chg_Tran_Id)
							
								fetch next from cur1 into @Chg_Tran_Id,@Chg_For_Date
							end
							
							close cur1
							deallocate cur1							

										
							
							--Select @Temp_Max_Date = Max(For_date) From dbo.T0140_REimClaim_Transacation where Emp_Id=@Emp_Id And Cmp_Id=@Cmp_id And For_date >= @For_Date And rc_ID=@RC_ID
							
							--Select @Alpha_Emp_Code = Alpha_Emp_Code from T0080_EMP_MASTER where Emp_ID=@Emp_Id	--Alpesh 20-Aug-2012
							
							
							--Comment:Nilay25082014
							--If Exists(select Reim_Closing from T0140_REimClaim_Transacation  LT Inner join T0050_AD_master LM on
							--	LT.RC_ID = LM.AD_ID and isnull(LM.AD_NOT_EFFECT_SALARY,0) = 1
							--	Where emp_id = @emp_id and LT.RC_ID = @RC_ID and LT.CMP_ID = @CMP_ID and Reim_Closing < 0 and For_Date = @Temp_Max_Date)
							--begin
							--	select @AD_Name = AD_Name from T0050_AD_master where AD_ID = @RC_ID
							--	set @ErrString = 'Balance not available on given Date - ' + @AD_Name + ' for Emp_Code=' + @Alpha_Emp_Code	
							--	RAISERROR (@ErrString, 16, 2) 							
							--End
							--Comment:Nilay25082014					
				 	end			 				 
				 Else
					BEGIN
						goto T;
					END
		end	
	else
	  BEGIN	
T:	  
			insert dbo.T0140_REimClaim_Transacation
				(Reim_Tran_ID,                            
						Cmp_ID,                                  
						RC_ID,                                   
						Emp_ID,                                  
						For_Date,                
						Reim_Opening,                            
						Reim_Credit,                             
						Reim_Debit,                              
						Reim_Closing,                            
						RC_apr_ID,                               
						Sal_tran_ID)
				values(@ReimClaim_Tran_ID,@Cmp_ID,@RC_ID,@Emp_Id,@For_Date,@Reim_Opening_Amount,0,0,@Reim_Opening_Amount,NULL,NULL)		
	
			Select @Pre_Closing=Reim_Closing from T0140_REimClaim_Transacation where emp_id = @emp_id and Rc_ID = @RC_id and 
						Cmp_ID = @Cmp_ID and for_date = @for_Date
						
			if @Pre_Closing is null
				set @Pre_Closing = 0
																				
			declare cur1 cursor for 
				Select Reim_Tran_ID,For_Date from dbo.T0140_REimClaim_Transacation where rc_ID = @RC_ID and emp_id = @emp_id 
				and Cmp_ID = @Cmp_ID and for_date > @for_Date order by for_date
			open cur1
			fetch next from cur1 into @Chg_Tran_Id,@Chg_For_Date
			while @@fetch_status = 0
			begin
				
				If exists(Select Reim_Op_ID From T0095_Reim_Opening Where Cmp_ID = @Cmp_ID And Emp_Id = @Emp_Id And RC_ID = @RC_Id And For_Date = @Chg_For_Date And Reim_Opening_Amount > 0)
					Begin
						Goto e;
					End
			
				update dbo.T0140_REimClaim_Transacation set 
					 Reim_Opening = Isnull(@Pre_Closing,0)
					,Reim_Closing =  Isnull(@Pre_Closing,0) + Reim_Credit - Reim_Debit 									
				where Reim_Tran_ID = @Chg_Tran_Id
		
			   E:
				set @Pre_Closing = (select Reim_Closing from dbo.T0140_REimClaim_Transacation where Reim_Tran_ID = @Chg_Tran_Id)
			
				fetch next from cur1 into @Chg_Tran_Id,@Chg_For_Date
			end
			
			close cur1
			deallocate cur1									
		end 
end	

IF Exists(SELECT 1 from DELETED)
 BEGIN
  if not Exists(SELECT 1 from INSERTED)
  begin
	declare curDel1 cursor for
			select emp_Id, Cmp_ID,For_Date,	del.RC_ID ,Reim_Opening_Amount from deleted del
			
			open curDel1
			fetch next from curDel1 into @emp_id,@Cmp_ID,@for_date,@RC_ID , @Reim_Opening_Amount
			while @@fetch_status = 0
			begin 
				set @Temp_max_Date = null
				set @Temp_Opening_Amount = 0
				
				
				
				if exists(select For_Date from dbo.T0140_REimClaim_Transacation where rc_ID = @RC_ID and for_date < @for_date and Emp_ID = @Emp_Id) 
					begin
						select @Temp_max_Date   = max(For_Date)  from dbo.T0140_REimClaim_Transacation where rc_ID = @RC_ID and for_date < @for_date and Emp_ID = @Emp_ID																	
						
						Select @Pre_Closing=Reim_Closing from T0140_REimClaim_Transacation where emp_id = @emp_id and rc_ID = @RC_ID and 
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
					Select Reim_Tran_ID,For_Date from dbo.T0140_REimClaim_Transacation where RC_ID = @RC_ID and emp_id = @emp_id 
					and Cmp_ID = @Cmp_ID and for_date >= @Temp_Max_Date order by for_date
				open cur1
				fetch next from cur1 into @Chg_Tran_Id,@Chg_For_Date
				while @@fetch_status = 0
				begin
					
					If exists(Select Reim_Op_ID From T0095_Reim_Opening Where Cmp_ID = @Cmp_ID And Emp_Id = @Emp_Id And RC_ID = @RC_ID And For_Date = @Chg_For_Date And Reim_Opening_Amount > 0)
						Begin
							Break;
						End
				
					update dbo.T0140_REimClaim_Transacation set 
						 Reim_Opening = Isnull(@Pre_Closing,0)
						,Reim_Closing = Isnull(@Pre_Closing,0) + Reim_Credit - Reim_Debit 									
					where Reim_Tran_ID = @Chg_Tran_Id
			
				
					set @Pre_Closing = (select Reim_Closing from dbo.T0140_REimClaim_Transacation where Reim_Tran_ID = @Chg_Tran_Id)
				
					fetch next from cur1 into @Chg_Tran_Id,@Chg_For_Date
				end
				
				close cur1
				deallocate cur1					
				
				
				fetch next from curDel1 into @emp_id,@Cmp_ID,@for_date,@RC_ID , @Reim_Opening_Amount
			end 	
			close curDel1
			deallocate curDel1  
	  	end
 end
	



