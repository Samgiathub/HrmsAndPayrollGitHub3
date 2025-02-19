CREATE TABLE [dbo].[T0120_LTA_Medical_Approval] (
    [LM_Apr_ID]      NUMERIC (18)    NOT NULL,
    [Cmp_ID]         NUMERIC (18)    NOT NULL,
    [LM_App_ID]      NUMERIC (18)    NOT NULL,
    [Emp_ID]         NUMERIC (18)    NOT NULL,
    [Apr_Date]       DATETIME        NULL,
    [Apr_Code]       VARCHAR (20)    NULL,
    [Apr_Amount]     NUMERIC (18, 2) NULL,
    [APr_Comments]   VARCHAR (500)   NULL,
    [System_Date]    DATETIME        NULL,
    [APR_Status]     INT             NULL,
    [Type_ID]        INT             NULL,
    [Login_id]       NUMERIC (18)    NULL,
    [effect_salary]  INT             NULL,
    [effective_date] DATETIME        NULL,
    CONSTRAINT [PK_T0120_LTA_Medical_Approval] PRIMARY KEY CLUSTERED ([LM_Apr_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0120_LTA_Medical_Approval_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0120_LTA_Medical_Approval_T0080_EMP_MASTER] FOREIGN KEY ([Emp_ID]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID]),
    CONSTRAINT [FK_T0120_LTA_Medical_Approval_T0120_LTA_Medical_Approval] FOREIGN KEY ([LM_App_ID]) REFERENCES [dbo].[T0110_LTA_Medical_Application] ([LM_App_ID])
);


GO




CREATE TRIGGER [DBO].[Tri_T0120_LTA_Medical_Approval]
ON [dbo].[T0120_LTA_Medical_Approval]
FOR  INSERT,update 
AS
--zalak 16-feb-2011
	-------------------LTA & MEDICAL
	declare @Emp_Id as numeric(18,0)
	declare @Cmp_ID as numeric(18,0)
	declare @Type_ID as numeric(18,0)
	declare @LM_Apr_ID as numeric(18,0)
	declare @From_Date as datetime
	declare @to_Date as datetime
	declare @Balance_Opening as numeric(18,2)	
	Declare @Balance_Used as numeric (18,2)
	declare @Balance_op_Used as numeric (18,2)
	declare @Balance_Closing as numeric (18,2)
	declare @amount as numeric(18,2)
	declare @LM_Tran_ID numeric(18,0)
	declare @APR_Status int 
	
	set @Balance_op_Used =0 
	select @APR_Status=APR_Status from inserted ins 
	if isnull(@APR_Status,0)=1
		begin
			select @LM_Apr_ID=LM_Apr_ID,@Emp_Id = emp_Id, @Cmp_ID = Cmp_ID,@Type_ID = Type_ID,@From_Date=Apr_Date,@amount=Apr_Amount from inserted ins 
			select top 1 @Balance_Opening=isnull(Balance_Closing,0) from T0240_LTA_Medical_Transaction  where emp_id=@emp_id and type_id=1 and for_date<=@From_Date order by for_date desc
			if @Balance_Opening is null
				set  @Balance_Opening = 0
			set @Balance_Used=@amount
			set @Balance_Closing = @Balance_Opening - @Balance_Used
							
			If not Exists(select LM_Tran_ID From T0240_LTA_Medical_Transaction  Where cmp_ID = @Cmp_ID and Emp_ID = @Emp_ID  and for_date=@From_Date  and LM_Apr_ID=@LM_Apr_ID)
				 begin
							  	select @LM_Tran_ID = Isnull(max(LM_Tran_ID),0) + 1 	From T0240_LTA_Medical_Transaction 
								insert into T0240_LTA_Medical_Transaction(LM_Tran_ID,Cmp_ID,type_id,Emp_ID,For_Date,Balance_Opening,Balance_Crediated,Balance_Used,Balance_Closing,LM_Apr_ID)
								values(@LM_Tran_ID,@Cmp_ID,@Type_ID,@Emp_Id,@From_Date,@Balance_Opening,0.0,@Balance_Used,@Balance_Closing,@LM_Apr_ID)
				 end
			else
				  begin
						select top 1 @Balance_op_Used=isnull(Balance_Used,0) from T0240_LTA_Medical_Transaction  Where cmp_ID = @Cmp_ID and Emp_ID = @Emp_ID  and for_date=@From_Date  and LM_Apr_ID=@LM_Apr_ID
						if @Balance_op_Used<>@Balance_Used
						  begin
							update T0240_LTA_Medical_Transaction
							set Balance_Used= @Balance_Used
							 Where cmp_ID = @Cmp_ID and Emp_ID = @Emp_ID  and for_date=@From_Date  and LM_Apr_ID=@LM_Apr_ID
						  
							update T0240_LTA_Medical_Transaction
							set Balance_closing=Balance_Opening  - Balance_Used
							 Where cmp_ID = @Cmp_ID and Emp_ID = @Emp_ID  and for_date=@From_Date  and LM_Apr_ID=@LM_Apr_ID
						 
						  end
					end	
			
			 if exists (select LM_Tran_ID from T0240_LTA_Medical_Transaction where emp_id=@emp_id and type_id=@Type_ID and for_date>@From_Date)
					begin
						update T0240_LTA_Medical_Transaction
						set Balance_Opening=(Balance_Opening + @Balance_op_Used)- @Balance_Used
						where emp_id=@emp_id and type_id=@Type_ID and for_date>@From_Date
						
						update T0240_LTA_Medical_Transaction
						set Balance_closing= (Balance_Opening + Balance_Crediated)- Balance_Used
						where emp_id=@emp_id and type_id=@Type_ID and for_date>@From_Date
					end	
			end




GO




CREATE TRIGGER [DBO].[Tri_T0120_LTA_Medical_Approval_DELETE]
ON [dbo].[T0120_LTA_Medical_Approval] 
FOR DELETE 
AS
	
	declare @Emp_Id as numeric 
	declare @Cmp_ID as numeric
	declare @For_Date as datetime
	
	--zalak 16-feb-2011
	-------------------LTA & MEDICAL
		declare @From_Date	datetime	
		declare @sal_tran_id	numeric(18, 0)	
		declare @Balance_Opening as numeric(18, 2)
		declare @Balance_Used as numeric(18, 2)	
		declare @LM_Apr_ID as numeric(18,0)
		
			select @LM_Apr_ID=LM_Apr_ID , @Emp_Id = del.Emp_Id, @Cmp_ID = del.Cmp_ID ,@From_Date = del.Apr_Date from deleted del	
 
				select @Balance_Used = Balance_Used,@Balance_Opening = Balance_Opening  from T0240_LTA_Medical_Transaction where for_date=@From_Date and LM_Apr_ID=@LM_Apr_ID and emp_id=@emp_id and type_id=1
				if exists (select LM_Tran_ID from T0240_LTA_Medical_Transaction where emp_id=@emp_id and type_id=1 and for_date>@From_Date)
						begin
							
							delete  T0240_LTA_Medical_Transaction where for_date=@From_Date and LM_Apr_ID=@LM_Apr_ID and emp_id=@emp_id and type_id=1
					
							update T0240_LTA_Medical_Transaction
							set Balance_Opening=@Balance_Opening + @Balance_Used
							where emp_id=@emp_id and type_id=1 and for_date>@From_Date
							
							update T0240_LTA_Medical_Transaction
							set Balance_closing= Balance_Opening + Balance_Used
							where emp_id=@emp_id and type_id=1 and for_date>@From_Date
						end
				 else
					begin
						delete  T0240_LTA_Medical_Transaction where for_date=@From_Date and LM_Apr_ID=@LM_Apr_ID and emp_id=@emp_id and type_id=1
					end



