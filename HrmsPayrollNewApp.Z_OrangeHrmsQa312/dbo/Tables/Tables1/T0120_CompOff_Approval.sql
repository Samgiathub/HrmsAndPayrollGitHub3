CREATE TABLE [dbo].[T0120_CompOff_Approval] (
    [CompOff_Appr_ID]   NUMERIC (18)    NOT NULL,
    [CompOff_App_ID]    NUMERIC (18)    NULL,
    [Cmp_ID]            NUMERIC (18)    NOT NULL,
    [Emp_ID]            NUMERIC (18)    NOT NULL,
    [S_Emp_ID]          NUMERIC (18)    NULL,
    [Extra_Work_Date]   DATETIME        NOT NULL,
    [Approve_Date]      DATETIME        NOT NULL,
    [Extra_Work_Hours]  VARCHAR (10)    NOT NULL,
    [Sanctioned_Hours]  VARCHAR (10)    NOT NULL,
    [Extra_Work_Reason] VARCHAR (250)   NULL,
    [Approve_Status]    CHAR (1)        NOT NULL,
    [Approve_Comments]  VARCHAR (250)   NULL,
    [Contact_No]        VARCHAR (30)    NULL,
    [Email_ID]          VARCHAR (50)    NULL,
    [Login_ID]          NUMERIC (18)    NOT NULL,
    [System_Datetime]   DATETIME        NOT NULL,
    [CompOff_Days]      NUMERIC (18, 2) NOT NULL,
    CONSTRAINT [PK_T0120_CompOff_Approval] PRIMARY KEY CLUSTERED ([CompOff_Appr_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0120_CompOff_Approval_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0120_CompOff_Approval_T0080_EMP_MASTER] FOREIGN KEY ([Emp_ID]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID]),
    CONSTRAINT [FK_T0120_CompOff_Approval_T0080_EMP_MASTER1] FOREIGN KEY ([S_Emp_ID]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID]),
    CONSTRAINT [FK_T0120_CompOff_Approval_T0100_CompOff_Application] FOREIGN KEY ([CompOff_App_ID]) REFERENCES [dbo].[T0100_CompOff_Application] ([Compoff_App_ID])
);


GO
CREATE NONCLUSTERED INDEX [T0120_CompOff_Approval]
    ON [dbo].[T0120_CompOff_Approval]([Cmp_ID] ASC, [Emp_ID] ASC, [Extra_Work_Date] ASC, [Approve_Date] ASC, [Approve_Status] ASC) WITH (FILLFACTOR = 80);


GO



CREATE TRIGGER [dbo].[Tri_T0120_COMPOFF_APPROVAL]
   ON  [dbo].[T0120_CompOff_Approval]
   FOR INSERT,DELETE,UPDATE
AS 
BEGIN	
	
	SET NOCOUNT ON;
    declare @Cmp_ID as numeric
    declare @For_Date as datetime
    declare @Emp_Id as numeric
    
    declare @CompOff_Appr_ID as numeric
    declare @Leave_Id as numeric

    declare @CompOff_Open as numeric(18,2)      
    declare @CompOff_Open_Cur as numeric(18,2) 

    declare @Last_Leave_Closing as numeric(18,2)
    declare @Last_Leave_Used as numeric(18,2)        
    declare @A_For_Date as datetime
   
    Declare @Leave_Tran_ID as numeric
    Declare @Approval_Status as varchar(1)
    Declare @Total_CompOff_Open as numeric(18,2)
    Declare @Leave_Paid_Unpaid varchar(1)  
    Declare @Leave_negative_Allow	tinyint
    
    Declare @Leave_Close as numeric
    Declare @Leave_Open as numeric
    Declare @Leave_Use as numeric
    Declare @Leave_Cr as numeric
    Declare @Leave_Posting as numeric
    Declare @Leave_Can as numeric
    Declare @Leave_Encash as numeric
   
    Declare @Emp_Code numeric(18,0)    

    set @Total_CompOff_Open = 0
    set @Leave_negative_Allow =0    
   
   IF update (CompOff_Appr_ID) 
     BEGIN
        select  @Cmp_ID = Cmp_ID,  @Emp_Id = Emp_ID	 ,@Approval_Status = Approve_Status 
        from inserted 
        
        select @Emp_Code = Emp_Code from T0080_Emp_Master where emp_id = @Emp_Id
        select @Leave_Id = leave_ID, @Leave_negative_Allow = isnull(Leave_negative_Allow,0), @Leave_Paid_Unpaid = Leave_Paid_Unpaid  from T0040_LEAVE_MASTER where Default_Short_Name = 'COMP' and Cmp_ID = @Cmp_ID 
        
        select @CompOff_Appr_ID = ins.CompOff_Appr_ID, @For_Date = ins.Extra_Work_Date	,@A_For_Date = ins.Extra_Work_Date
		,@CompOff_Open = ins.CompOff_Days , @Total_CompOff_Open = ins.CompOff_Days  			
		From inserted ins			
		
        IF @Leave_Id > 0
           BEGIN
             IF @Approval_Status = 'A'    
			  BEGIN	
			 /*  IF Exists(Select Emp_ID from T0140_LEAVE_TRANSACTION where Cmp_ID= @Cmp_ID and Leave_ID = @Leave_Id and Emp_ID = @Emp_Id)
			     BEGIN
			     
					
			      
                   select @Last_Leave_Closing = isnull(Leave_Closing,0), @Last_Leave_Used = ISNULL(Leave_Used,0) from T0140_LEAVE_TRANSACTION
	    	       where for_date = (select max(for_date) from T0140_LEAVE_TRANSACTION 
	    		                 where for_date < @For_date
	    						 and Leave_Id = @Leave_ID and Cmp_ID = @Cmp_ID and emp_Id = @emp_Id) 
	    			and Cmp_ID = @Cmp_ID
	    			and Leave_Id = @Leave_ID and emp_Id = @emp_Id
	    			
	    			
	    		 END
	    	   ELSE
	    	     BEGIN
	    	       EXEC dbo.P0095_LEAVE_OPENING 0, @Emp_ID, 0, @Cmp_ID, @Leave_ID, 0, @For_Date, 'I' 
	    	       select @Last_Leave_Closing = isnull(Leave_Closing,0), @Last_Leave_Used = ISNULL(Leave_Used,0) from T0140_LEAVE_TRANSACTION
	    	       where for_date = (select max(for_date) from T0140_LEAVE_TRANSACTION 
	    		                 where for_date < @For_date
	    						 and Leave_Id = @Leave_ID and Cmp_ID = @Cmp_ID and emp_Id = @emp_Id) 
	    			and Cmp_ID = @Cmp_ID
	    			and Leave_Id = @Leave_ID and emp_Id = @emp_Id
	    	     END	*/
	    		/*	IF @Last_Leave_Closing is null 
				 set  @Last_Leave_Closing = 0
					IF @Last_Leave_Used is null
                 set @Last_Leave_Used = 0 					
                   */
			       select @Leave_Tran_ID = Isnull(max(Leave_Tran_ID),0) + 1 From T0140_LEAVE_TRANSACTION   
				     			
	    			IF exists(select For_date from T0140_LEAVE_TRANSACTION where For_date = @For_date and leave_Id = @leave_Id  
										and Cmp_ID = @Cmp_ID and emp_id = @emp_id)
				       BEGIN
						 			--CompOff_Credit,CompOff_Debit,CompOFF_Balance								 
							Update T0140_LEAVE_TRANSACTION 
							Set/* Leave_opening = @Last_Leave_Closing, Leave_Credit = @CompOff_Open
							   ,Leave_Closing = @Last_Leave_Closing + isnull(@CompOff_Open,0) - @Last_Leave_Used - Leave_Encash_Days, Comoff_Flag = 1,*/
							   CompOff_Credit = CompOff_Credit + isnull(@CompOff_Open,0), CompOFF_Balance = (CompOff_Credit +isnull(@CompOff_Open,0)) - isnull(CompOff_Debit,0) -- Changed By Gadriwala Muslim 01092014
							   ,Comoff_Flag = 1
						 where Leave_Id = @Leave_Id and for_date = @For_Date and Cmp_ID = @Cmp_ID
						   and emp_Id = @emp_Id
															
							/*Set @Last_Leave_Closing = (select isnull(Leave_Closing,0) from dbo.T0140_LEAVE_TRANSACTION 
						                               where Leave_Id = @Leave_Id 
							                             and for_date = @For_Date and Cmp_ID = @Cmp_ID and emp_Id = @emp_Id)
							Set @Last_Leave_Used = (select isnull(Leave_Used,0) from dbo.T0140_LEAVE_TRANSACTION 
						           where Leave_Id = @Leave_Id 
							         and for_date = @For_Date and Cmp_ID = @Cmp_ID and emp_Id = @emp_Id)*/
						 
				       END	
				    ELSE
				       BEGIN
				         Insert into T0140_LEAVE_TRANSACTION(Emp_ID,Leave_ID,Cmp_ID,For_Date,Leave_Opening,Leave_Used,
												Leave_Closing,Leave_Credit,Leave_Tran_ID,Comoff_Flag,CompOff_Credit,CompOff_Debit,CompOFF_Balance)
						 values(@Emp_ID,@Leave_ID,@Cmp_ID,@For_Date,0,0
												,0,0,@Leave_Tran_ID,1,@CompOff_Open,0,@CompOff_Open)
	    				 
				       END
			  	
			  --      Declare @Chg_Tran_Id numeric  
					--Declare @For_Date_Cur Datetime
					--Declare @Pre_Closing numeric(18,2)
					
					--set @For_Date= @A_For_Date
					
					--select @Pre_Closing = isnull(Leave_Closing,0) from T0140_LEAVE_TRANSACTION
	    --						where for_date = (select max(for_date) from T0140_LEAVE_TRANSACTION where for_date <= @For_date
	    --											and leave_Id = @leave_id and Cmp_ID = @Cmp_ID and emp_Id = @emp_Id) 
	    --						  and Cmp_ID = @Cmp_ID
	    --						  and leave_id = @leave_Id and emp_Id = @emp_Id
	    			  
	    --			if @Pre_Closing is null
					--				set @Pre_Closing = 0  
						
					--declare cur1 cursor for 
					--				Select leave_tran_id,For_Date from dbo.T0140_LEAVE_TRANSACTION where leave_id = @leave_Id and emp_id = @emp_id 
					--				and Cmp_ID = @Cmp_ID and for_date > @For_date order by for_date
					--open cur1
					--fetch next from cur1 into @Chg_Tran_Id,@For_Date_Cur
					--while @@fetch_status = 0
					--			BEGIN
					--			   IF exists(Select Leave_Op_Id From T0095_LEAVE_OPENING Where Cmp_ID = @Cmp_ID And Emp_Id = @Emp_Id And Leave_ID = @Leave_Id And For_Date = @For_Date_Cur And Leave_Op_Days > 0)
					--					BEGIN
					--						Goto c;
					--					END
					--					BEGIN
					--					   Update dbo.T0140_LEAVE_TRANSACTION 
					--					      Set Leave_Opening = @Pre_Closing,
					--							  Leave_Closing = @Pre_Closing + isnull(Leave_Credit,0) - isnull(Leave_Used,0) - ISNULL(leave_encash_days,0)									
					--						where Leave_tran_id = @Chg_Tran_Id
					--					C:			
					--						  Set @Pre_Closing = isnull((select isnull(Leave_Closing,0) from dbo.T0140_LEAVE_TRANSACTION where leave_tran_id = @Chg_Tran_Id),0)
					--					END
					--			   fetch next from cur1 into @Chg_Tran_Id,@For_Date_Cur
					--			END
					--close cur1
					--deallocate cur1
			   END
           END
     END
   ELSE 
     BEGIN
       Select  @Cmp_ID = Cmp_ID,  @Emp_Id = Emp_Id ,@Approval_Status = Approve_Status from deleted 
				   
	   IF @Approval_Status ='A'
	     BEGIN
	       declare curDel cursor local for
	          select CompOff_Appr_ID, Extra_Work_Date, CompOff_Days  From deleted
	          select @Leave_Id = leave_ID from T0040_LEAVE_MASTER where Default_Short_Name = 'COMP' and Cmp_ID = @Cmp_ID 
	          open curDel
			  fetch next from curDel into @CompOff_Appr_ID, @A_For_Date, @Total_CompOff_Open
			  while @@fetch_status = 0
			  BEGIN
			    set @For_Date= @A_For_Date
			   
				--select @Last_Leave_Closing = ISNULL(Leave_Closing,0), @Last_Leave_Used = ISNULL(Leave_Used,0) from T0140_LEAVE_TRANSACTION
	   -- 	         where for_date = (select max(for_date) from T0140_LEAVE_TRANSACTION 
	   -- 		                 where for_date < @For_date
	   -- 						 and Leave_Id = @Leave_Id and Cmp_ID = @Cmp_ID and emp_Id = @emp_Id) 
	   -- 			and Cmp_ID = @Cmp_ID
	   -- 			and Leave_Id = @Leave_Id and emp_Id = @emp_Id
	    				    						   
					--Update T0140_LEAVE_TRANSACTION 
					--Set Leave_Opening = Isnull(@Last_Leave_Closing,0), Leave_Credit = isnull(Leave_Credit,0) - @Total_CompOff_Open 
					--,Leave_Closing = Isnull(@Last_Leave_Closing,0), Comoff_Flag = 1
					--where leave_id = @Leave_Id and emp_id = @emp_id and for_date = @for_date 
					--  and Cmp_ID = @Cmp_ID
					  	
					--Update T0140_LEAVE_TRANSACTION 
					--Set Leave_Closing = Leave_Opening+Leave_Credit - Leave_Used - Leave_Encash_Days
					--where leave_id = @Leave_Id and emp_id = @emp_id and for_date = @for_date 
					--  and Cmp_ID = @Cmp_ID  	
					
					  -- Added by Gadriwala Muslim 04092014 - Start
					 Update T0140_LEAVE_TRANSACTION 
					Set CompOff_Credit = (CompOff_Credit - @Total_CompOff_Open),CompOFF_Balance = CompOFF_Balance - @Total_CompOff_Open
					where leave_id = @Leave_Id and emp_id = @emp_id and for_date = @for_date 
					  and Cmp_ID = @Cmp_ID  
					  -- Added by Gadriwala Muslim 04092014 - End
					  
			  fetch next from curDel into @CompOff_Appr_ID, @A_For_Date, @Total_CompOff_Open 	
			  END
			  
			  --set @For_Date= @A_For_Date
			  
			  --select @Pre_Closing = isnull(Leave_Closing,0) from T0140_LEAVE_TRANSACTION
					--where for_date = (select max(for_date) from T0140_LEAVE_TRANSACTION where for_date <= @For_date
					--					and leave_Id = @Leave_Id and Cmp_ID = @Cmp_ID and emp_Id = @emp_Id) 
					--	and Cmp_ID = @Cmp_ID
					--	and leave_id = @leave_Id and emp_Id = @emp_Id
			  
			  --if @Pre_Closing is null
				 --set @Pre_Closing = 0
			  
			  --declare cur1 cursor for 
				 -- Select Leave_Tran_ID,For_Date from dbo.T0140_LEAVE_TRANSACTION where leave_id = @leave_Id and emp_id = @emp_id 
					--	 and Cmp_ID = @Cmp_ID and for_date > @For_date order by for_date
				 -- open cur1
				 -- fetch next from cur1 into @Chg_Tran_Id,@For_Date_Cur
				 -- while @@fetch_status = 0
					--BEGIN
					--  If Exists(Select Leave_Op_Id From T0095_LEAVE_OPENING Where Cmp_ID = @Cmp_ID And Emp_Id = @Emp_Id And Leave_ID = @Leave_Id And For_Date = @For_Date_Cur And Leave_Op_Days > 0)
					--     BEGIN
					--       Goto E;
					--     END
					--     BEGIN
					--		Update dbo.T0140_LEAVE_TRANSACTION 
					--		Set Leave_Opening = isnull(@Pre_Closing,0),
					--			Leave_Closing = isnull(@Pre_Closing,0) + isnull(Leave_Credit,0) - isnull(Leave_Used,0) - ISNULL(leave_encash_days,0)
					--			where leave_tran_id = @Chg_Tran_Id
					--	 E:		
					--	   	Set @Pre_Closing = isnull((select isnull(Leave_Closing,0) from dbo.T0140_LEAVE_TRANSACTION where leave_tran_id = @Chg_Tran_Id),0)
					--     END
				 -- fetch next from cur1 into @Chg_Tran_Id,@For_Date_Cur
					--END
			  --close cur1
			  --deallocate cur1
		      close curDel
		      deallocate curDel	
		 END
     END  
	
	
   --Select @Leave_Close = ISNULL(Leave_Closing, 0), @Leave_Open = ISNULL(Leave_Opening, 0), @Leave_Use = ISNULL(Leave_Used, 0), @Leave_Cr = ISNULL(Leave_Credit, 0),
   --       @Leave_Posting = ISNULL(Leave_Posting, 0),  @Leave_Can = ISNULL(Leave_Cancel, 0), @Leave_Encash = ISNULL(Leave_Encash_Days, 0)
   --       From T0140_LEAVE_TRANSACTION where Cmp_ID = @Cmp_ID and Leave_ID = @Leave_Id and Emp_ID = @Emp_Id 
   
   --IF(@Leave_Close = 0 And @Leave_Open = 0 And  @Leave_Use = 0 And @Leave_Cr = 0 And @Leave_Posting = 0 And @Leave_Can = 0 And @Leave_Encash = 0)
   --   BEGIN
   --     DELETE From T0140_LEAVE_TRANSACTION Where Cmp_ID = @Cmp_ID and Leave_ID = @Leave_Id and Emp_ID = @Emp_Id
   --   END
   
    DELETE From T0140_LEAVE_TRANSACTION 
	Where Cmp_ID = @Cmp_ID and Leave_ID = @Leave_Id and Emp_ID = @Emp_Id 
	and CompOff_Credit = 0 and CompOff_Debit = 0 and CompOff_Balance = 0 and CompOff_Used = 0 and 
	ISNULL(Leave_Closing, 0) = 0 and ISNULL(Leave_Opening, 0) = 0 and ISNULL(Leave_Used, 0) = 0 and
	ISNULL(Leave_Credit, 0) = 0 and ISNULL(Leave_Posting, 0) = 0 and ISNULL(Leave_Cancel, 0) = 0 and 
	ISNULL(Leave_Encash_Days, 0) = 0
END


