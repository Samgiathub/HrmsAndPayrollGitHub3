CREATE TABLE [dbo].[T0150_Travel_Settlement_Approval] (
    [Tran_id]                   NUMERIC (18)    NOT NULL,
    [Travel_Set_Application_id] NUMERIC (18)    NOT NULL,
    [cmp_id]                    NUMERIC (18)    NOT NULL,
    [emp_id]                    NUMERIC (18)    NOT NULL,
    [manager_emp_id]            NUMERIC (18)    CONSTRAINT [DF_T0150_Travel_Settlement_Approval_manager_emp_id] DEFAULT ((0)) NOT NULL,
    [pending_amount]            NUMERIC (18, 2) CONSTRAINT [DF_T0150_Travel_Settlement_Approval_amount] DEFAULT ((0)) NOT NULL,
    [Manager_comment]           NVARCHAR (300)  NULL,
    [is_apr]                    TINYINT         CONSTRAINT [DF_T0150_Travel_Settlement_Approval_is_apr] DEFAULT ((0)) NULL,
    [Approval_date]             DATETIME        NULL,
    [Advance_amount]            NUMERIC (18, 2) CONSTRAINT [DF_T0150_Travel_Settlement_Approval_Advance_amount] DEFAULT ((0)) NOT NULL,
    [Expance_Incured]           NUMERIC (18, 2) CONSTRAINT [DF_T0150_Travel_Settlement_Approval_Expance_Incured] DEFAULT ((0)) NOT NULL,
    [Approved_Expance]          NUMERIC (18, 2) CONSTRAINT [DF_T0150_Travel_Settlement_Approval_Approved_Expance] DEFAULT ((0)) NOT NULL,
    [Amount_Differnce]          NUMERIC (18, 2) CONSTRAINT [DF_T0150_Travel_Settlement_Approval_Amount_Differnce] DEFAULT ((0)) NOT NULL,
    [Adjust_Amount]             NUMERIC (18, 2) CONSTRAINT [DF_T0150_Travel_Settlement_Approval_Adjust_Amount] DEFAULT ((0)) NOT NULL,
    [Payment_Type]              NVARCHAR (100)  NULL,
    [cheque_No]                 NUMERIC (18)    NULL,
    [Travel_Amt_In_Salary]      TINYINT         DEFAULT ((0)) NOT NULL,
    [Effect_Salary_date]        DATETIME        DEFAULT (NULL) NULL,
    CONSTRAINT [PK_T0150_Travel_Settlement_Approval] PRIMARY KEY CLUSTERED ([Tran_id] ASC) WITH (FILLFACTOR = 80)
);


GO




CREATE TRIGGER [DBO].[Tri_T0150_Travel_Settlement_Approval]
   ON  [dbo].[T0150_Travel_Settlement_Approval]
   FOR INSERT 
AS 
BEGIN
	
	SET NOCOUNT ON;
	
	Declare @cmp_id numeric(18,0)
	Declare @emp_id numeric(18,0)
	Declare @pending_amount numeric(18,0)
	Declare @approval_date datetime
	declare @is_aprrove tinyint
	declare @travel_app_tran_id numeric(18,0)
	
	
	set @cmp_id = 0
	set @emp_id = 0
	set @pending_amount =0
	set @is_aprrove = 0
	set @travel_app_tran_id = 0
    
 	select @cmp_id = cmp_id, @emp_id = emp_id, @pending_amount = pending_amount, @is_aprrove = is_apr , @travel_app_tran_id =Tran_id from inserted 
 	
 	--select @approval_date = cast(getdate() as DATE)
 	select @approval_date = convert(nvarchar(11),getdate(),106)
 	 	
 	 
 		if @is_aprrove  = 1
 			begin
	 			
 				if not exists (SELECT 1 from T0150_Travel_Settlement_Expense_Transaction where cmp_id = @cmp_id AND emp_id = @emp_id AND for_date = @approval_date)
 					begin
			 			
			 			--SELECT @pending_amount
 						declare @tran_id numeric(18,0)
 						declare @opening_amount numeric(18,2)
			 			
 						set @tran_id = 0
 						set @opening_amount = 0
			 			
 						Select @tran_id = isnull(tran_id,0) + 1 from T0150_Travel_Settlement_Expense_Transaction
 						Select @opening_amount = isnull(Closing_Amount,0) from T0150_Travel_Settlement_Expense_Transaction  where emp_id = @emp_id and 
 							for_date = (Select max(for_date) from T0150_Travel_Settlement_Expense_Transaction where for_date <= @approval_date AND emp_id = @emp_id )
			 			
			 			--if @pending_amount > 0
			 			--	begin
 								INSERT INTO T0150_Travel_Settlement_Expense_Transaction
										  (Tran_id, Cmp_id, Emp_id, For_Date, Opening_Amount, Amount, Closing_Amount, Travel_Settelment_ID)
								VALUES     (@tran_id,@cmp_id,@emp_id,@approval_date,@opening_amount,@pending_amount,@opening_amount + @pending_amount,cast(@travel_app_tran_id AS NVARCHAR))
							--end
						
 					end
 				else
 					begin
	 				
 						update T0150_Travel_Settlement_Expense_Transaction  set Amount = Amount + @pending_amount , Closing_Amount = Closing_Amount + @pending_amount ,  Travel_Settelment_ID = Travel_Settelment_ID + ',' + cast(@travel_app_tran_id as NVARCHAR)
 						WHERE cmp_id = @cmp_id AND emp_id = @emp_id AND for_date = @approval_date 
	 				
 						update T0150_Travel_Settlement_Expense_Transaction  set Opening_Amount = Opening_Amount + @pending_amount , Closing_Amount = Closing_Amount + @pending_amount 
 						WHERE cmp_id = @cmp_id AND emp_id = @emp_id AND for_date > @approval_date 
	 					
 					end
	 				
 			end

END



GO




CREATE TRIGGER [DBO].[Tri_T0150_Travel_Settlement_Approval_Delete]
   ON  [dbo].[T0150_Travel_Settlement_Approval]
   FOR Delete 
AS 
BEGIN
	
	SET NOCOUNT ON;
	
	Declare @cmp_id numeric(18,0)
	Declare @emp_id numeric(18,0)
	Declare @pending_amount numeric(18,0)
	Declare @approval_date datetime
	declare @is_aprrove tinyint
	
	
	
	set @cmp_id = 0
	set @emp_id = 0
	set @pending_amount =0
	set @is_aprrove = 0
    
 	select @cmp_id = cmp_id, @emp_id = emp_id, @pending_amount = pending_amount, @is_aprrove = is_apr from DELETED 
 	
 	 	--select @approval_date = cast(getdate() as DATE)
		select @approval_date = convert(nvarchar(11),getdate(),106)
 	
 	if @is_aprrove  = 1
 		begin
 		
 			if exists (SELECT 1 from T0150_Travel_Settlement_Expense_Transaction where cmp_id = @cmp_id AND emp_id = @emp_id AND for_date = @approval_date AND amount = @pending_amount)
 				begin
		 			
 					DELETE T0150_Travel_Settlement_Expense_Transaction WHERE cmp_id = @cmp_id AND emp_id = @emp_id AND for_date = @approval_date AND amount = @pending_amount
 					
 					update T0150_Travel_Settlement_Expense_Transaction  set Opening_Amount = Opening_Amount - @pending_amount , Closing_Amount = Closing_Amount - Amount 
 					WHERE cmp_id = @cmp_id AND emp_id = @emp_id AND for_date > @approval_date 
					
 				end
 			else
 				begin
 					
 					update T0150_Travel_Settlement_Expense_Transaction  set Amount = Amount - @pending_amount , Closing_Amount = Closing_Amount - @pending_amount 
 					WHERE cmp_id = @cmp_id AND emp_id = @emp_id AND for_date = @approval_date 
 				
 					update T0150_Travel_Settlement_Expense_Transaction  set Opening_Amount = Opening_Amount - @pending_amount , Closing_Amount = Closing_Amount - @pending_amount 
 					WHERE cmp_id = @cmp_id AND emp_id = @emp_id AND for_date > @approval_date 
 					
 				end
 		end

END


