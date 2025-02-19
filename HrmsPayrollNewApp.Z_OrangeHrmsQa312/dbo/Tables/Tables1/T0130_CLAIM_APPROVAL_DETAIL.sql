CREATE TABLE [dbo].[T0130_CLAIM_APPROVAL_DETAIL] (
    [Claim_Apr_Dtl_ID]         NUMERIC (18)    NOT NULL,
    [Claim_Apr_ID]             NUMERIC (18)    NOT NULL,
    [Cmp_ID]                   NUMERIC (18)    NOT NULL,
    [Emp_ID]                   NUMERIC (18)    NOT NULL,
    [Claim_ID]                 NUMERIC (18)    NOT NULL,
    [Claim_Apr_Date]           DATETIME        NOT NULL,
    [Claim_App_ID]             NUMERIC (18)    NOT NULL,
    [Claim_Apr_Code]           NUMERIC (18)    NOT NULL,
    [Claim_Apr_Amount]         NUMERIC (18, 3) NOT NULL,
    [Claim_Status]             VARCHAR (30)    NULL,
    [Claim_App_Amount]         NUMERIC (18, 3) NULL,
    [Curr_ID]                  NUMERIC (18)    NULL,
    [Curr_Rate]                NUMERIC (18, 3) NULL,
    [Purpose]                  VARCHAR (500)   NULL,
    [Claim_App_Ttl_Amount]     NUMERIC (18, 3) NULL,
    [S_Emp_ID]                 NUMERIC (18)    NULL,
    [Petrol_KM]                NUMERIC (18, 2) NULL,
    [Claim_Limit]              NUMERIC (18, 2) DEFAULT ((0)) NOT NULL,
    [Claim_Exceed_Amount]      NUMERIC (18, 2) DEFAULT ((0)) NOT NULL,
    [Claim_Model]              VARCHAR (200)   NULL,
    [Claim_IMEI]               VARCHAR (200)   NULL,
    [Claim_NoofPerson]         VARCHAR (500)   NULL,
    [Claim_DateOfPurchase]     SMALLDATETIME   NULL,
    [Claim_BookName]           VARCHAR (200)   NULL,
    [Claim_Subject]            VARCHAR (200)   NULL,
    [Claim_ActualPrice]        FLOAT (53)      NULL,
    [Claim_PriceAfterDiscount] FLOAT (53)      NULL,
    [Claim_FamilyMember]       VARCHAR (200)   NULL,
    [Claim_Relation]           VARCHAR (100)   NULL,
    [Claim_Age]                FLOAT (53)      NULL,
    [Claim_FamilyLimit]        FLOAT (53)      NULL,
    [Claim_FamilyMeberId]      INT             NULL,
    [Claim_UnitName]           VARCHAR (100)   NULL,
    [Claim_UnitFlag]           INT             NULL,
    [Claim_ConversionRate]     FLOAT (53)      NULL,
    [Payment_Process_ID]       NUMERIC (18)    NULL,
    [From_Loc_ID]              NUMERIC (10)    DEFAULT ((0)) NOT NULL,
    [To_Loc_ID]                NUMERIC (10)    DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_T0130_CLAIM_APPROVAL_DETAIL] PRIMARY KEY CLUSTERED ([Claim_Apr_Dtl_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0130_CLAIM_APPROVAL_DETAIL_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0130_CLAIM_APPROVAL_DETAIL_T0080_EMP_MASTER] FOREIGN KEY ([Emp_ID]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID]),
    CONSTRAINT [FK_T0130_CLAIM_APPROVAL_DETAIL_T0120_CLAIM_APPROVAL] FOREIGN KEY ([Claim_Apr_ID]) REFERENCES [dbo].[T0120_CLAIM_APPROVAL] ([Claim_Apr_ID])
);


GO
CREATE TRIGGER [DBO].[Tri_T0130_CLAIM_APPROVAL_DETAIL]
ON [dbo].[T0130_CLAIM_APPROVAL_DETAIL] 
FOR INSERT,Delete
AS
	

	declare @Cmp_ID		numeric
	declare @For_Date	datetime
	declare @Emp_Id		numeric
	declare @Count		numeric

	declare @CLAIM_Tran_ID	numeric
	declare @CLAIM_Id		numeric
	declare @CLAIM_Issue		numeric(18,3)
	declare @Last_Closing		numeric(18,3)
	Declare @claim_Apr_Status	varchar(1)
	Declare @Claim_Limit Numeric(18,2) = 0
	Declare @Exceed_Amount Numeric(18,0) = 0

	select @CLAIM_Tran_ID = Isnull(Max(CLAIM_Tran_ID),0)  +1 From T0140_CLAIM_TRANSACTION
	
	
	IF  update(CLAIM_Apr_ID) 
		begin
		
		select @cmp_ID = cmp_ID,@emp_id = Emp_ID ,@CLAIM_Id = ins.CLAIM_Id ,@CLAIM_Issue = ins.CLAIM_Apr_Amount,@for_Date = CLAIM_apr_Date
				,@claim_Apr_Status = claim_Status,@Claim_Limit = Claim_Limit,@Exceed_Amount = Claim_Exceed_Amount
				from inserted ins	
				--select 111,@CLAIM_Issue
				print @CLAIM_Issue
			--Added by Jaina 12-10-2020
			Declare @Claim_Beyond_Limit tinyint = 0
			Declare @Claim_Beyond_Exceed_Limit_Dedu_Salary tinyint = 0

			select @Claim_Beyond_Limit = CLAIM_ALLOW_BEYOND_LIMIT,@Claim_Beyond_Exceed_Limit_Dedu_Salary = Beyond_Max_Limit_Deduct_In_Salary
			from T0040_CLAIM_MASTER WITH(NOLOCK)
			where Claim_ID=@CLAIM_Id

			if @claim_Apr_Status = 'A' 
				begin	
					if exists(select 1 from T0140_CLAIM_TRANSACTION where for_date = @For_date and CLAIM_Id = @CLAIM_Id  
						and Cmp_ID = @Cmp_ID and emp_id = @Emp_id)
						begin
							
							if @Claim_Beyond_Limit = 1 and @Claim_Beyond_Exceed_Limit_Dedu_Salary = 1
							BEGIN
								update T0140_CLAIM_TRANSACTION set CLAIM_Issue =@Exceed_Amount --CLAIM_Issue + @CLAIM_Issue
									,CLAIM_Closing = @Exceed_Amount	
								where CLAIM_Id = @CLAIM_Id and for_date = @For_Date and Cmp_ID = @Cmp_ID
								and emp_Id = @emp_Id and @CLAIM_Id=(select Claim_ID from T0040_CLAIM_MASTER where Claim_Apr_Deduct_From_Sal=1 and Cmp_ID=@Cmp_ID and Claim_ID=@CLAIM_Id)
							END
							ELSE
							BEGIN
								update T0140_CLAIM_TRANSACTION set CLAIM_Issue =@CLAIM_Issue --CLAIM_Issue + @CLAIM_Issue
									,CLAIM_Closing = @CLAIM_Issue	
								where CLAIM_Id = @CLAIM_Id and for_date = @For_Date and Cmp_ID = @Cmp_ID
								and emp_Id = @emp_Id and @CLAIM_Id=(select Claim_ID from T0040_CLAIM_MASTER where Claim_Apr_Deduct_From_Sal=1 and Cmp_ID=@Cmp_ID and Claim_ID=@CLAIM_Id)
							END

							
							
							--update T0140_CLAIM_TRANSACTION set CLAIM_Opening = @CLAIM_Issue--CLAIM_Opening + @CLAIM_Issue
							--	,CLAIM_Closing =@CLAIM_Issue --CLAIM_Closing + @CLAIM_Issue	
							--where CLAIM_Id = @CLAIM_Id and for_date > @For_Date and Cmp_ID = @Cmp_ID
							--	and emp_Id = @emp_Id and @CLAIM_Id=(select Claim_ID from T0040_CLAIM_MASTER where Claim_Apr_Deduct_From_Sal=1 and Cmp_ID=@Cmp_ID and Claim_ID=@CLAIM_Id)
						end
					else
							begin	
							    
	    						select @Last_Closing = isnull(CLAIM_Closing,0) from T0140_CLAIM_TRANSACTION
	    							where for_date = (select max(for_date) from T0140_CLAIM_TRANSACTION 
	    									where for_date < @For_date
	    								and CLAIM_Id = @CLAIM_id and cmp_ID = @cmp_ID and emp_id = @emp_Id ) 
	    								and cmp_ID = @cmp_ID
	    								and CLAIM_id = @CLAIM_Id  and emp_id = @emp_Id and @CLAIM_Id=(select Claim_ID from T0040_CLAIM_MASTER where Claim_Apr_Deduct_From_Sal=1 and Cmp_ID=@Cmp_ID and Claim_ID=@CLAIM_Id)
				
								if @Last_Closing is null 
									set  @Last_Closing = 0
								if exists(select Claim_ID from T0040_CLAIM_MASTER where Claim_Apr_Deduct_From_Sal=1 and Cmp_ID=@Cmp_ID and Claim_ID=@CLAIM_Id)
								begin
								
								--commented by Mukti(10062021) as discussed with Sandip
								IF @Claim_Beyond_Limit = 1 and @Claim_Beyond_Exceed_Limit_Dedu_Salary = 1  --Added by Jaina 12-10-2020
									BEGIN
											insert T0140_CLAIM_TRANSACTION(CLAIM_Tran_ID,emp_id,CLAIM_Id,cmp_ID,For_Date,CLAIM_Opening,CLAIM_Issue,
													CLAIM_Closing,CLAIM_Return)
											values(@CLAIM_Tran_ID,@emp_id,@CLAIM_Id,@cmp_ID,@For_Date,0,@Exceed_Amount,@Exceed_Amount,0) 				
									END
								ELSE
									BEGIN
											insert T0140_CLAIM_TRANSACTION(CLAIM_Tran_ID,emp_id,CLAIM_Id,cmp_ID,For_Date,CLAIM_Opening,CLAIM_Issue,
												CLAIM_Closing,CLAIM_Return)
											values(@CLAIM_Tran_ID,@emp_id,@CLAIM_Id,@cmp_ID,@For_Date,0,@CLAIM_Issue,@CLAIM_Issue,0) 				
									END
														    		
								End
								
								--update T0140_CLAIM_TRANSACTION set CLAIM_Opening = CLAIM_Opening + @CLAIM_Issue
								--	,CLAIM_Closing = CLAIM_Closing + @CLAIM_Issue	
								--where CLAIM_Id = @CLAIM_Id and for_date > @For_Date and cmp_ID = @cmp_ID
								--	and emp_Id = @emp_Id and @CLAIM_Id=(select Claim_ID from T0040_CLAIM_MASTER where Claim_Apr_Deduct_From_Sal=1 and Cmp_ID=@Cmp_ID and Claim_ID=@CLAIM_Id)

	    					end	
	    		end
	    End
	else
		begin



		 	declare curDel cursor for
				select Del.Cmp_ID ,del.Emp_ID ,del.CLAIM_Id,del.CLAIM_apr_Amount ,CLAIM_apr_Date ,claim_Status from deleted del
			open curDel
			fetch next from curDel into @Cmp_ID,@Emp_ID,@CLAIM_Id , @CLAIM_Issue ,@for_Date ,@claim_Apr_Status
			while @@fetch_status = 0
			begin 
					if @claim_Apr_Status = 'A'
						begin
							
							--delete from T0140_CLAIM_TRANSACTION where Cmp_ID=@Cmp_ID and Emp_ID=@Emp_Id
							--and for_date = @for_date
								update T0140_CLAIM_TRANSACTION set CLAIM_Issue = 0 
									,CLAIM_Closing = 0
								where CLAIM_id = @CLAIM_Id and emp_id = @emp_id and for_date = @For_Date and cmp_ID = @cmp_ID	
								and @CLAIM_Id=(select Claim_ID from T0040_CLAIM_MASTER where Claim_Apr_Deduct_From_Sal=1 and Cmp_ID=@Cmp_ID and Claim_ID=@CLAIM_Id)
										
								--update T0140_CLAIM_TRANSACTION set CLAIM_Opening = CLAIM_Opening - @CLAIM_Issue
								--	,CLAIM_Closing = CLAIM_Closing - @CLAIM_Issue
								--where CLAIM_id = @CLAIM_Id and emp_id = @emp_id and for_date > @for_date and cmp_ID = @cmp_ID	
								--and @CLAIM_Id=(select Claim_ID from T0040_CLAIM_MASTER where Claim_Apr_Deduct_From_Sal=1 and Cmp_ID=@Cmp_ID and Claim_ID=@CLAIM_Id)
						end
				
				--fetch next from curDel into @Cmp_ID, @Emp_ID,@CLAIM_Id , @CLAIM_Issue ,@for_Date 
				  fetch next from curDel into @Cmp_ID, @Emp_ID,@CLAIM_Id , @CLAIM_Issue ,@for_Date,@claim_Apr_Status--- this changed by nikunj at 19-feb-2010
			end				
			close curDel
			deallocate curDel
		end

GO


CREATE TRIGGER [DBO].[Tri_T0130_CLAIM_APPROVAL_DETAIL_Update]
ON [dbo].[T0130_CLAIM_APPROVAL_DETAIL] 
FOR UPDATE
AS
	declare @Pre_CLAIM_Amount numeric 
	Declare @CLAIM_Apr_ID numeric 
	declare @Cmp_ID		numeric
	declare @For_Date	datetime
	declare @Emp_Id		numeric
	declare @Count		numeric

	declare @CLAIM_Tran_ID	numeric
	declare @CLAIM_Id		numeric
	declare @CLAIM_Issue		numeric(18,3)
	declare @Last_Closing		numeric(18,3)
	Declare @claim_Apr_Status	varchar(1)
	

	select @CLAIM_Tran_ID = Isnull(Max(CLAIM_Tran_ID),0)  +1 From T0140_CLAIM_TRANSACTION	
	
	set nocount on
	
		print 1
	
	--declare curDel cursor for
		select Del.Cmp_ID ,del.Emp_ID ,del.CLAIM_Id,del.CLAIM_apr_Amount ,CLAIM_apr_Date ,claim_Status from deleted del
	
		delete from T0140_CLAIM_TRANSACTION --where Cmp_ID=@Cmp_ID
		
	--open curDel
	--fetch next from curDel into @Cmp_ID,@Emp_ID,@CLAIM_Id , @CLAIM_Issue ,@for_Date ,@claim_Apr_Status
	--while @@fetch_status = 0
	--begin 
	
	--	if @claim_Apr_Status ='A'
	--		begin
			
	--				update T0140_CLAIM_TRANSACTION set CLAIM_Issue = CLAIM_Issue - @CLAIM_Issue 
	--					,CLAIM_Closing = CLAIM_Closing - @CLAIM_Issue
	--				where CLAIM_id = @CLAIM_Id and emp_id = @emp_id and for_date = @for_date and cmp_ID = @cmp_ID	
	--				and @CLAIM_Id=(select Claim_ID from T0040_CLAIM_MASTER where Claim_Apr_Deduct_From_Sal=1 and Cmp_ID=@Cmp_ID and Claim_ID=@CLAIM_Id)
					
	--				update T0140_CLAIM_TRANSACTION set CLAIM_Opening = CLAIM_Opening - @CLAIM_Issue
	--					,CLAIM_Closing = CLAIM_Closing - @CLAIM_Issue
	--				where CLAIM_id = @CLAIM_Id and emp_id = @emp_id and for_date > @for_date and cmp_ID = @cmp_ID	
	--				and @CLAIM_Id=(select Claim_ID from T0040_CLAIM_MASTER where Claim_Apr_Deduct_From_Sal=1 and Cmp_ID=@Cmp_ID and Claim_ID=@CLAIM_Id)
	--		end
	--	fetch next from curDel into @Cmp_ID, @Emp_ID,@CLAIM_Id , @CLAIM_Issue ,@for_Date,@claim_Apr_Status 
	--end				
	--close curDel
	--deallocate curDel
						
	

		--select @cmp_ID = cmp_ID,@emp_id = Emp_ID ,@CLAIM_Id = ins.CLAIM_Id ,@CLAIM_Issue = ins.CLAIM_Apr_Amount,@for_Date = CLAIM_apr_Date
		--		,@claim_Apr_Status = claim_Status
		--		from inserted ins	
	
		--if @claim_Apr_Status ='A'
		--	begin
					
				--IF isnull(@CLAIM_Id ,0) > 0 
				--	begin
				--		if exists(select * from T0140_CLAIM_TRANSACTION where for_date = @For_date and CLAIM_Id = @CLAIM_Id  
				--			and Cmp_ID = @Cmp_ID and emp_id = @Emp_id)
				--			begin
				--				update T0140_CLAIM_TRANSACTION set CLAIM_Issue = CLAIM_Issue + @CLAIM_Issue
				--					,CLAIM_Closing = CLAIM_Closing + @CLAIM_Issue	
				--				where CLAIM_Id = @CLAIM_Id and for_date = @For_Date and Cmp_ID = @Cmp_ID
				--					and emp_Id = @emp_Id and @CLAIM_Id=(select Claim_ID from T0040_CLAIM_MASTER where Claim_Apr_Deduct_From_Sal=1 and Cmp_ID=@Cmp_ID and Claim_ID=@CLAIM_Id)
								
				--				update T0140_CLAIM_TRANSACTION set CLAIM_Opening = CLAIM_Opening + @CLAIM_Issue
				--					,CLAIM_Closing = CLAIM_Closing + @CLAIM_Issue	
				--				where CLAIM_Id = @CLAIM_Id and for_date > @For_Date and Cmp_ID = @Cmp_ID
				--					and emp_Id = @emp_Id and @CLAIM_Id=(select Claim_ID from T0040_CLAIM_MASTER where Claim_Apr_Deduct_From_Sal=1 and Cmp_ID=@Cmp_ID and Claim_ID=@CLAIM_Id)
				--			end
				--		else
				--				begin	    
	   -- 							select @Last_Closing = isnull(CLAIM_Closing,0) from T0140_CLAIM_TRANSACTION
	   -- 								where for_date = (select max(for_date) from T0140_CLAIM_TRANSACTION 
	   -- 										where for_date < @For_date
	   -- 									and CLAIM_Id = @CLAIM_id and cmp_ID = @cmp_ID and emp_id = @emp_Id ) 
	   -- 									and cmp_ID = @cmp_ID
	   -- 									and CLAIM_id = @CLAIM_Id  and emp_id = @emp_Id
					
				--					if @Last_Closing is null 
				--						set  @Last_Closing = 0
				--					if exists(select Claim_ID from T0040_CLAIM_MASTER where Claim_Apr_Deduct_From_Sal=1 and Cmp_ID=@Cmp_ID and Claim_ID=@CLAIM_Id)
				--					begin
				--					insert T0140_CLAIM_TRANSACTION(CLAIM_Tran_ID,emp_id,CLAIM_Id,cmp_ID,For_Date,CLAIM_Opening,CLAIM_Issue,
				--						CLAIM_Closing,CLAIM_Return)
				--					values(@CLAIM_Tran_ID,@emp_id,@CLAIM_Id,@cmp_ID,@for_Date,@last_closing,isnull(@CLAIM_Issue,0)
				--						,isnull(@last_closing,0) + isnull(@CLAIM_Issue,0),0)												    		
				--					End
				--					update T0140_CLAIM_TRANSACTION set CLAIM_Opening = CLAIM_Opening + @CLAIM_Issue
				--						,CLAIM_Closing = CLAIM_Closing + @CLAIM_Issue	
				--					where CLAIM_Id = @CLAIM_Id and for_date > @For_Date and cmp_ID = @cmp_ID
				--						and emp_Id = @emp_Id and @CLAIM_Id=(select Claim_ID from T0040_CLAIM_MASTER where Claim_Apr_Deduct_From_Sal=1 and Cmp_ID=@Cmp_ID and Claim_ID=@CLAIM_Id)

	   -- 						end	
	   -- 				End
			--end




