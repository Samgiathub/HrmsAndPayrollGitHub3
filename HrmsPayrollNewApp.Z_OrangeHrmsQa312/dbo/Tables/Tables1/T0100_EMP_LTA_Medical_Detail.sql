CREATE TABLE [dbo].[T0100_EMP_LTA_Medical_Detail] (
    [LM_ID]           NUMERIC (18)    NOT NULL,
    [Cmp_ID]          NUMERIC (18)    NOT NULL,
    [Emp_ID]          NUMERIC (18)    NOT NULL,
    [From_Date]       DATETIME        NULL,
    [To_Date]         DATETIME        NULL,
    [Mode]            CHAR (1)        NULL,
    [Amount]          NUMERIC (18, 2) NULL,
    [Type_id]         INT             NOT NULL,
    [Carry_fw_amount] INT             NULL,
    [no_IT_claims]    INT             NULL,
    CONSTRAINT [PK_T0100_EMP_LTA_Medical_Detail] PRIMARY KEY CLUSTERED ([LM_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0100_EMP_LTA_Medical_Detail_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0100_EMP_LTA_Medical_Detail_T0080_EMP_MASTER] FOREIGN KEY ([Emp_ID]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID])
);


GO




CREATE TRIGGER [DBO].[Tri_T0100_EMP_LTA_Medical_Detail]
ON [dbo].[T0100_EMP_LTA_Medical_Detail]
FOR  INSERT,update 
AS
	Declare @Leave_Tran_ID as numeric(18,0) 
	declare @Emp_Id as numeric(18,0)
	declare @Cmp_ID as numeric(18,0)
	declare @Type_ID as numeric(18,0)
	declare @For_Date as datetime
	declare @From_Date as datetime
	declare @to_Date as datetime
	declare @Balance_Opening as numeric(18,2)	
	Declare @Balance_Credit as numeric (18,2)
	declare @Balance_Closing as numeric (18,2)
	declare @mode as char
	declare @amount as numeric(18,2)
	declare @LM_Tran_ID numeric(18,0)
	
	
	--''Alpesh 22-Oct-2011
	declare @branch_id numeric(18,0)
	declare @effective_month varchar(100)
	declare @accpected_balance int
	declare @basic_salary numeric(18,2)
	declare @gross_salary numeric(18,2)
	declare @max_limit numeric(18,2)
	declare @Cal_amount_Type int
	declare @Increment_Effective_Date datetime
	declare @Carry_Fw_Amt numeric(18,2)
	
	select @Emp_Id = emp_Id, @Cmp_ID = Cmp_ID, @to_Date = to_Date,@Type_ID = Type_ID,@From_Date=From_Date,@mode=mode,@amount=amount,@Carry_Fw_Amt=Carry_fw_amount from inserted ins 
		
	select @Increment_Effective_Date=Increment_Effective_Date,@branch_id=branch_id,
	@basic_salary=basic_salary,@gross_salary=gross_salary  from t0095_increment I inner join     
     ( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment    
     where Increment_Effective_date <= @to_Date and Cmp_ID = @Cmp_ID group by emp_ID) Qry on    
     I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date    
    Where I.Emp_ID = @Emp_ID     
	
	select  @effective_month=effective_month,@max_limit=max_limit,@Cal_amount_Type=Cal_amount_Type from T0040_LM_SETTING where branch_id=@branch_id and start_date<=@From_Date and end_date>=@to_Date and type_id=@type_id
	
	if @Carry_Fw_Amt is null
		set @Carry_Fw_Amt = 0
	-- End --	
	
	
	--- no effect 
	If not Exists(select LM_Tran_ID From T0240_LTA_Medical_Transaction  Where cmp_ID = @Cmp_ID and
									Emp_ID = @Emp_ID  and type_id=@type_id and
							((@From_Date >= for_date and @From_Date <= for_date) or 
							(@To_Date >= for_date and 	@To_Date <= for_date) or 
							(for_date >= @From_Date and for_date <= @To_Date) or
							(for_date >= @From_Date and for_date <= @To_Date)))
		begin
				if @mode='%' 
					begin
						if @Cal_amount_Type=1
							set @accpected_balance = (@basic_salary * @amount/100) * 12
						else
							set @accpected_balance = (@gross_salary * @amount/100) * 12
					end
				else if @mode like '%F'
					begin 
						if @Cal_amount_Type=1
							set @accpected_balance = @basic_salary * @amount
						else
							set @accpected_balance = @gross_salary * @amount	
					end
				else if @mode like '%R'
					 begin	
						set @accpected_balance = @amount
					 end
					 
					 if @accpected_balance is null
						set @accpected_balance = 0
					 
					 set @Balance_Opening = @Carry_Fw_Amt
					 set @Balance_Credit = @accpected_balance
					 set @Balance_Closing = @Balance_Opening + @Balance_Credit
					 
					 if  @Balance_Opening >0
						begin
							select @LM_Tran_ID = Isnull(max(LM_Tran_ID),0) + 1 From T0240_LTA_Medical_Transaction 
							
							insert into T0240_LTA_Medical_Transaction(LM_Tran_ID,Cmp_ID,type_id,Emp_ID,For_Date,Balance_Opening,Balance_Crediated,Balance_Used,Balance_Closing)
							values(@LM_Tran_ID,@Cmp_ID,@Type_ID,@Emp_Id,@From_Date,@Balance_Opening,@Balance_Credit,0.0,@Balance_Closing)
						end
			end
		else
			begin
				
				declare @bal_op numeric(18,2)
				declare @Balance_Used numeric(18,2)
				declare @temp_LM_Tran_ID numeric
				declare @Pre_Closing numeric(18,2)
				
				Select * from T0240_LTA_Medical_Transaction
				select  @Balance_Opening=isnull(Balance_Opening,0), @Balance_Used=isnull(Balance_Used,0), @Balance_Credit=isnull(Balance_Crediated,0) from T0240_LTA_Medical_Transaction where emp_id=@emp_id and type_id=@type_id and for_date=@from_date and (isnull(sal_tran_id,0)=0 or isnull(lm_apr_id,0)=0)
								
				update T0240_LTA_Medical_Transaction 
				set Balance_Opening = isnull(Balance_Opening,0) + @Carry_Fw_Amt
				   ,Balance_Crediated = isnull(Balance_Crediated,0) + @accpected_balance
				   ,Balance_Closing = isnull(@Balance_Opening,0) + isnull(@Balance_Credit,0) - isnull(@Balance_Used,0)					
				where emp_id=@emp_id and for_date=@from_date  and type_id=@type_id
				
				set @Pre_Closing = 0
				set @Pre_Closing = isnull(@Balance_Opening,0) + isnull(@Balance_Credit,0) - isnull(@Balance_Used,0)					
				
				Declare curLTAMedical cursor for Select LM_Tran_ID from T0240_LTA_Medical_Transaction where emp_id=@emp_id and type_id=@type_id and for_date>@from_date and (isnull(sal_tran_id,0)=0 or isnull(lm_apr_id,0)=0)
				open curLTAMedical
				fetch next from curLTAMedical into @temp_LM_Tran_ID
				while @@fetch_status = 0
				begin
					select  @Balance_Opening=isnull(Balance_Opening,0), @Balance_Used=isnull(Balance_Used,0), @Balance_Credit=isnull(Balance_Crediated,0) from T0240_LTA_Medical_Transaction where LM_Tran_ID = @temp_LM_Tran_ID
					
					update T0240_LTA_Medical_Transaction 
					set Balance_Opening = @Pre_Closing
					   ,Balance_Closing = @Pre_Closing + isnull(Balance_Crediated,0) - isnull(Balance_Used,0) 
					where LM_Tran_ID = @temp_LM_Tran_ID
					
					Select @Pre_Closing = isnull(Balance_Closing,0) from T0240_LTA_Medical_Transaction where LM_Tran_ID = @temp_LM_Tran_ID
					
					fetch next from curLTAMedical into @temp_LM_Tran_ID
			    end
				close curLTAMedical
				deallocate curLTAMedical
				
				--if not exists (select * from t0200_monthly_salary where emp_id=@emp_id and month_st_date>=@from_date)
				--  begin
				--	if @mode='%' or @mode like '%F'
				--		set @Balance_Credit=0
				--	else if @mode like '%R'
				--		set @Balance_Credit=@amount
					
				--	update T0240_LTA_Medical_Transaction 
				--	set 
				--		Balance_Crediated= @Balance_Credit
						
				--	where emp_id=@emp_id and for_date>=@from_date  and type_id=@type_id
				--	update T0240_LTA_Medical_Transaction 
				--	set 
				--		Balance_Closing = Balance_Opening  + Balance_Crediated
				--	where emp_id=@emp_id and for_date>=@from_date  and type_id=@type_id
					
				--end
			end




GO




CREATE TRIGGER [DBO].[Tri_T0100_EMP_LTA_Medical_Detail_DELETE]
ON [dbo].[T0100_EMP_LTA_Medical_Detail]
FOR  DELETE
AS
	declare @Emp_Id as numeric(18,0)
	declare @Cmp_ID as numeric(18,0)
	declare @Type_ID as numeric(18,0)
	declare @From_Date as datetime
	declare @to_Date as datetime
	declare @Balance_Opening as numeric(18,2)	
	Declare @Balance_Crediated as numeric (18,2)
	
	
	Declare curLTAMedical cursor for
	select  emp_Id,Cmp_ID,to_Date,Type_ID,From_Date,amount,Carry_fw_amount from deleted del 
	open curLTAMedical
	fetch next from curLTAMedical into @Emp_Id,@Cmp_ID,@to_Date,@Type_ID,@From_Date,@Balance_Crediated,@Balance_Opening
	while @@fetch_status = 0
	    begin
			select @Balance_Opening=Balance_Opening ,@Balance_Crediated=Balance_Crediated from T0240_LTA_Medical_Transaction Where cmp_ID = @Cmp_ID and Emp_ID = @Emp_ID  and type_id=@type_id and For_Date=@From_Date and (isnull(sal_tran_id,0)=0 or isnull(lm_apr_id,0)=0)
			
			--case 1 
			update T0240_LTA_Medical_Transaction 
			set Balance_Opening =0
			,Balance_Crediated =0
			Where cmp_ID = @Cmp_ID and Emp_ID = @Emp_ID  and type_id=@type_id and For_Date=@From_Date and (isnull(sal_tran_id,0)=0 or isnull(lm_apr_id,0)=0)
			
			update T0240_LTA_Medical_Transaction 
			set Balance_Opening =Balance_Opening - @Balance_Opening
			,Balance_Crediated =Balance_Crediated - @Balance_Crediated
			Where cmp_ID = @Cmp_ID and Emp_ID = @Emp_ID  and type_id=@type_id and For_Date>@From_Date and (isnull(sal_tran_id,0)<>0 or isnull(lm_apr_id,0)<>0)
			
			--case 2
			
			update T0240_LTA_Medical_Transaction 
			set Balance_Closing =(Balance_Opening + Balance_Crediated)- Balance_used
			Where cmp_ID = @Cmp_ID and Emp_ID = @Emp_ID  and type_id=@type_id and For_Date>=@From_Date --and (isnull(sal_tran_id,0)<>0 or isnull(lm_apr_id,0)<>0)
	
	 fetch next from curLTAMedical into @Emp_Id,@Cmp_ID,@to_Date,@Type_ID,@From_Date,@Balance_Crediated,@Balance_Opening
	end
	close curLTAMedical
deallocate curLTAMedical



