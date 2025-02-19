CREATE TABLE [dbo].[T0120_LEAVE_ENCASH_APPROVAL] (
    [Lv_Encash_Apr_ID]       NUMERIC (18)    NOT NULL,
    [Lv_Encash_App_ID]       NUMERIC (18)    NULL,
    [Cmp_ID]                 NUMERIC (18)    NOT NULL,
    [Emp_ID]                 NUMERIC (18)    NOT NULL,
    [Leave_ID]               NUMERIC (18)    NOT NULL,
    [Lv_Encash_Apr_Code]     VARCHAR (20)    NOT NULL,
    [Lv_Encash_Apr_Date]     DATETIME        NOT NULL,
    [Lv_Encash_Apr_Days]     NUMERIC (7, 2)  NULL,
    [Lv_Encash_Apr_Status]   VARCHAR (2)     NOT NULL,
    [Lv_Encash_Apr_Comments] VARCHAR (250)   NOT NULL,
    [Login_ID]               NUMERIC (18)    NOT NULL,
    [System_Date]            DATETIME        NOT NULL,
    [Is_FNF]                 TINYINT         CONSTRAINT [DF_T0120_LEAVE_ENCASH_APPROVAL_Is_FNF] DEFAULT ((0)) NULL,
    [Eff_In_Salary]          TINYINT         NULL,
    [Upto_Date]              DATETIME        NULL,
    [Leave_CompOff_Dates]    VARCHAR (MAX)   NULL,
    [Leave_Encash_Amount]    NUMERIC (18, 2) CONSTRAINT [DF_T0120_LEAVE_ENCASH_APPROVAL_leave_Encash_Amount] DEFAULT ((0)) NOT NULL,
    [Leave_Recover]          NUMERIC (18, 2) NULL,
    [Is_Tax_Free]            TINYINT         DEFAULT ((0)) NOT NULL,
    [Day_Salary]             NUMERIC (18, 2) NULL,
    CONSTRAINT [PK_T0120_LEAVE_ENCASH_APPROVAL] PRIMARY KEY CLUSTERED ([Lv_Encash_Apr_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0120_LEAVE_ENCASH_APPROVAL_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0120_LEAVE_ENCASH_APPROVAL_T0040_LEAVE_MASTER] FOREIGN KEY ([Leave_ID]) REFERENCES [dbo].[T0040_LEAVE_MASTER] ([Leave_ID]),
    CONSTRAINT [FK_T0120_LEAVE_ENCASH_APPROVAL_T0080_EMP_MASTER] FOREIGN KEY ([Emp_ID]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID]),
    CONSTRAINT [FK_T0120_LEAVE_ENCASH_APPROVAL_T0100_LEAVE_ENCASH_APPLICATION] FOREIGN KEY ([Lv_Encash_App_ID]) REFERENCES [dbo].[T0100_LEAVE_ENCASH_APPLICATION] ([Lv_Encash_App_ID])
);


GO



CREATE TRIGGER [DBO].[Tri_T0120_LEAVE_ENCASH_APPROVAL_UPDATe]
ON [dbo].[T0120_LEAVE_ENCASH_APPROVAL] 
FOR UPDATE
AS

		Declare @Lv_Encash_App_ID		numeric 
		Declare @Lv_Encash_Apr_ID		numeric 
		Declare @Lv_Encash_Apr_Status	varchar(1)
		declare @Cmp_ID					numeric
		declare @For_Date				datetime
		declare @Emp_Id					numeric
		declare @Leave_Id				numeric
		declare @Leave_Used				numeric(18,2)--Changes by Falak on 02-FEB-2011
		declare @Last_Leave_Closing		numeric(18,2)--Changes by Falak on 02-FEB-2011
		Declare @Leave_Tran_ID			numeric
		Declare @Apply_Hourly			numeric
		Declare @Str_CompOff_dates  varchar(max) --Changed by Gadriwala Muslim 02102014
		Declare @Default_Short_Name varchar(25) --Changed by Gadriwala Muslim 02102014
		Declare @Eff_In_Salary			tinyint --Changed by Gadriwala Muslim 02102014
		
		select  @Cmp_ID = Cmp_ID,  @Emp_Id = emp_Id ,@Lv_Encash_Apr_Status = Lv_Encash_Apr_Status
				,@Leave_ID=Leave_ID,@For_Date = Lv_Encash_Apr_Date, @Leave_Used = (Case when Lv_Encash_Apr_Days < 0 THEN (Lv_Encash_Apr_Days * -1) ELSE Lv_Encash_Apr_Days END) ,@Str_CompOff_dates = Leave_CompOff_Dates --Changed by Gadriwala Muslim 02102014
		from deleted 
		
		select @apply_hourly = apply_hourly , @Default_Short_Name = isnull(Default_Short_Name,'') from T0040_LEAVE_MASTER
		where Leave_ID = @Leave_Id
		
		if @apply_hourly = 1 and @Default_Short_Name  <> 'COMP' --Changed by Gadriwala Muslim 02102014
		begin
			set @Leave_Used = @leave_used * 8
		end
		
		set @Leave_Used = floor(@Leave_Used*2)/2
		
		Create Table #Encash_CompOff_Approved
		 (
			 Leave_Date datetime,
			 Leave_Period numeric(18,2)
		 )
		
		if @Default_Short_Name = 'COMP' --Changed by Gadriwala Muslim 02102014
			begin
				if @Lv_Encash_Apr_Status ='A' -- when approval then reject 
					begin
								Insert into #Encash_CompOff_Approved(Leave_date,Leave_Period)
										select  Left(DATA,CHARINDEX(';',DATA)-1),SUBSTRING(DATA,CHARINDEX(';',DATA)+1,10) 
										from dbo.SPlit(@Str_CompOff_dates,'#') where Data <> ''
								
									Update T0140_LEAVE_TRANSACTION set 
										CompOff_Debit = Compoff_Debit - LA.Leave_Period,
										CompOff_balance	= CompOff_balance + LA.Leave_Period
										from T0140_LEAVE_TRANSACTION GOT 
										inner join #Encash_CompOff_Approved LA on Leave_Date = For_Date
										Where GOT.Emp_ID = @Emp_Id and GOT.Cmp_ID = @cmp_ID and 
										Leave_ID = @Leave_Id and Comoff_Flag = 1
										
										update T0140_LEAVE_TRANSACTION set 
										Leave_Encash_Days = isnull(Leave_Encash_Days,0) -  @Leave_Used,
										CompOff_Used  = isnull(CompOff_Used,0) - @Leave_Used
										where Leave_Id = @Leave_Id and for_date = @For_Date and Cmp_ID = @Cmp_ID
										and emp_Id = @emp_Id
										
						
					end
			end
		else
			begin
			
				if @Lv_Encash_Apr_Status ='A' -- when approval then reject 
					begin
					
						update T0140_LEAVE_TRANSACTION set Leave_Used = Leave_Used - @Leave_Used 
							,Leave_Closing = Leave_Closing + @Leave_Used
							where leave_id = @leave_Id and emp_id = @emp_id and for_date = @for_date 
							and Cmp_ID = @Cmp_ID	
								
						update T0140_LEAVE_TRANSACTION set Leave_Opening = Leave_Opening + @Leave_Used
							,Leave_Closing = Leave_Closing + @Leave_Used
							where leave_id = @leave_Id and emp_id = @emp_id and for_date > @for_date 
							and Cmp_ID = @Cmp_ID	
					end
			end	

		set @Leave_ID = 0
		set @Emp_Id = 0
		
 		select  @Cmp_ID = Cmp_ID,  @Emp_Id = emp_Id ,@Lv_Encash_Apr_Status = Lv_Encash_Apr_Status
				,@Leave_ID =Leave_ID,@For_Date = Lv_Encash_Apr_Date,@Leave_Used = (Case when Lv_Encash_Apr_Days < 0 THEN (Lv_Encash_Apr_Days * -1) ELSE Lv_Encash_Apr_Days END), -- Lv_Encash_Apr_Days
				@Str_CompOff_dates = Leave_CompOff_Dates, --Changed by Gadriwala Muslim 02102014
 				@Lv_Encash_App_ID = isnull(Lv_Encash_App_ID,0),@Eff_In_Salary=Eff_In_Salary
		from Inserted 
		
		
		
		select @Default_Short_Name = isnull(Default_Short_Name,'') from T0040_LEAVE_MASTER
		where Leave_ID = @Leave_Id
		
		if isnull(@Lv_Encash_App_ID,0) > 0	
					begin
						Update t0100_leave_Encash_Application 
						set Lv_Encash_App_Status = @Lv_Encash_Apr_Status
						where Lv_Encash_App_ID = @Lv_Encash_App_ID
					end 
		IF @Default_Short_Name = 'COMP'  --Changed by Gadriwala Muslim 02102014
			begin
						
					If @leave_Id > 0  and @Lv_Encash_Apr_Status ='A'
					begin
							
						select @Leave_Tran_ID = Isnull(max(Leave_Tran_ID),0) +1 From T0140_LEAVE_TRANSACTION
								
									delete from #Encash_CompOff_Approved
									Insert into #Encash_CompOff_Approved(Leave_date,Leave_Period)
										select  Left(DATA,CHARINDEX(';',DATA)-1),SUBSTRING(DATA,CHARINDEX(';',DATA)+1,10) 
										from dbo.SPlit(@Str_CompOff_dates,'#') where Data <> ''
									
									Update T0140_LEAVE_TRANSACTION set 
											CompOff_Debit = Compoff_Debit + LA.Leave_Period,
											CompOff_balance	= CompOff_balance - LA.Leave_Period
											from T0140_LEAVE_TRANSACTION GOT 
											inner join #Encash_CompOff_Approved LA on Leave_Date = For_Date
											Where GOT.Emp_ID = @Emp_Id and GOT.Cmp_ID = @cmp_ID and 
											Leave_ID = @Leave_Id and Comoff_Flag = 1	
						
						
						if exists(select Emp_ID from T0140_LEAVE_TRANSACTION where For_date = @For_date and leave_Id = @leave_Id  
								and Cmp_ID = @Cmp_ID and emp_id = @emp_id)
								begin
							
										update T0140_LEAVE_TRANSACTION set 
										Leave_Encash_Days = isnull(Leave_Encash_Days,0) +  @Leave_Used,
										CompOff_Used  = isnull(CompOff_Used,0) + @Leave_Used,
										 Eff_In_Salary = @Eff_In_Salary
										where Leave_Id = @Leave_Id and for_date = @For_Date and Cmp_ID = @Cmp_ID
										and emp_Id = @emp_Id
										
								end
							else
								begin	
										insert T0140_LEAVE_TRANSACTION(emp_id,Leave_Id,Cmp_ID,For_Date,Leave_Opening,Leave_Used,
										Leave_Closing,Leave_Credit,Leave_Tran_ID,Leave_Encash_Days,CompOff_Used,Comoff_Flag,Eff_In_Salary)
										values(@emp_id,@leave_Id,@Cmp_ID,@for_Date,0,0
										,0,0,@Leave_Tran_ID,@Leave_Used,@Leave_Used,1,@Eff_In_Salary)												    		
								end			
								
					End
					
			end
		else
			begin
					If @leave_Id > 0  and @Lv_Encash_Apr_Status ='A'
						begin
							select @Leave_Tran_ID = Isnull(max(Leave_Tran_ID),0) +1 From T0140_LEAVE_TRANSACTION
				
							if exists(select Emp_ID from T0140_LEAVE_TRANSACTION where For_date = @For_date and leave_Id = @leave_Id  
								and Cmp_ID = @Cmp_ID and emp_id = @emp_id)
								begin
							
										update T0140_LEAVE_TRANSACTION set Leave_Used = Leave_Used + @Leave_Used
										,Leave_Closing = Leave_Closing - @Leave_Used,Eff_In_Salary = @Eff_In_Salary  	
										where Leave_Id = @Leave_Id and for_date = @For_Date and Cmp_ID = @Cmp_ID
										and emp_Id = @emp_Id

										update T0140_LEAVE_TRANSACTION set Leave_Opening = Leave_Opening - @Leave_Used
										,Leave_Closing = Leave_Closing - @Leave_Used	
										where Leave_Id = @Leave_Id and for_date > @For_Date and Cmp_ID = @Cmp_ID
										and emp_Id = @emp_Id
								end
							else
								begin	
										select @Last_Leave_Closing = isnull(Leave_Closing,0) from T0140_LEAVE_TRANSACTION
										where for_date = (select max(for_date) from T0140_LEAVE_TRANSACTION 
										where for_date < @For_date
										and leave_Id = @leave_id and Cmp_ID = @Cmp_ID and emp_Id = @emp_Id) 
										and Cmp_ID = @Cmp_ID
										and leave_id = @leave_Id and emp_Id = @emp_Id
							
										if @Last_Leave_Closing is null 
											set  @Last_Leave_Closing = 0
							
										insert T0140_LEAVE_TRANSACTION(emp_id,Leave_Id,Cmp_ID,For_Date,Leave_Opening,Leave_Used,
										Leave_Closing,Leave_Credit,Leave_Tran_ID,Eff_In_Salary)
										values(@emp_id,@leave_Id,@Cmp_ID,@for_Date,@last_Leave_Closing,@Leave_Used
										,@last_Leave_Closing - @Leave_Used,0,@Leave_Tran_ID,@Eff_In_Salary)												    		

										update T0140_LEAVE_TRANSACTION set Leave_Opening = Leave_Opening - @Leave_Used
											,Leave_Closing = Leave_Closing - @Leave_Used	
										where Leave_Id = @Leave_Id and for_date > @For_Date and Cmp_ID = @Cmp_ID
										and emp_Id = @emp_Id
								end
						End
			end
			
		
		


GO


CREATE TRIGGER [DBO].[Tri_T0120_Encash_Leave_APPROVAL]
ON [dbo].[T0120_LEAVE_ENCASH_APPROVAL] 
FOR INSERT, DELETE 
AS
	SET NOCOUNT ON
	
	Declare @Lv_Encash_App_ID		NUMERIC 
	Declare @Lv_Encash_Apr_ID		NUMERIC 
	Declare @Lv_Encash_Apr_Status	VARCHAR(1)
	declare @Cmp_ID					NUMERIC
	declare @For_Date				DATETIME
	declare @Emp_Id					NUMERIC
	declare @Leave_Id				NUMERIC
	declare @Leave_Used				NUMERIC(18,2)--Changes by Falak on 02-FEB-2011
	declare @Last_Leave_Closing		NUMERIC(18,2)--Changes by Falak on 02-FEB-2011
	Declare @Leave_Tran_ID			NUMERIC
	Declare @Eff_In_Salary			TINYINT
	Declare @apply_hourly			NUMERIC
	Declare @strCompOff_Dates		VARCHAR(MAX)		--Added by Gadriwala Muslim 02102014
	Declare @Default_Short_Name		VARCHAR(25)	--Added by Gadriwala Muslim 02102014
	DECLARE @FLAG	CHAR(1)
	
	CREATE TABLE #Encash_CompOff_Approved		--Added by Gadriwala Muslim 02102014
	(
		Leave_Date		DATETIME,
		Leave_Period	NUMERIC(18,2)
	)
	
	
	DECLARE curInserted CURSOR FAST_FORWARD FOR 
	SELECT	Lv_Encash_Apr_ID, IsNull(Lv_Encash_App_ID,0), lv_Encash_Apr_DAte, INS.Leave_ID, INS.Cmp_ID, Emp_ID, Lv_Encash_Apr_Status, 
			ISNULL(LM.Default_Short_Name, ''), Apply_Hourly, Leave_CompOff_Dates, 'I' AS FLAG
	FROM	INSERTED INS  
			INNER JOIN T0040_LEAVE_MASTER LM ON INS.Leave_ID = LM.Leave_ID
	UNION ALL
	SELECT	Lv_Encash_Apr_ID, IsNull(Lv_Encash_App_ID,0), lv_Encash_Apr_DAte, DEL.Leave_ID, DEL.Cmp_ID, Emp_ID, Lv_Encash_Apr_Status, 
			ISNULL(LM.Default_Short_Name, ''), Apply_Hourly, Leave_CompOff_Dates, 'D' AS FLAG
	FROM	DELETED DEL
			INNER JOIN T0040_LEAVE_MASTER LM ON DEL.Leave_ID = LM.Leave_ID

	OPEN curInserted

	FETCH NEXT FROM curInserted INTO  @Lv_Encash_Apr_ID, @Lv_Encash_App_ID,  @For_Date, @Leave_Id, @Cmp_ID, @Emp_Id, 
				@Lv_Encash_Apr_Status, @Default_Short_Name, @apply_hourly,@strCompOff_Dates, @FLAG   --Change by Jaina 28-06-2017 Missing @strCompOff_Dates
	WHILE @@FETCH_STATUS = 0
		BEGIN
			 
			IF  UPDATE (Lv_Encash_Apr_ID) AND @FLAG = 'I'
				BEGIN
							
					--select  @Cmp_ID = Cmp_ID,  @Emp_Id = emp_Id	 ,@Lv_Encash_Apr_Status = Lv_Encash_Apr_Status, @Lv_Encash_App_ID = isnull(Lv_Encash_App_ID,0) 
 					--		, @Leave_Id = ins.Leave_Id, @For_Date = lv_Encash_Apr_DAte,@Leave_Used = (Case when ins.lv_encash_apr_Days < 0 THEN (ins.lv_encash_apr_Days * -1) ELSE ins.lv_encash_apr_Days END),@Eff_In_Salary=Eff_In_Salary,@strCompOff_Dates = Leave_CompOff_Dates 
					--from inserted ins  --Changed by Gadriwala Muslim 02102014
 					SELECT  @Leave_Used = (Case when ins.lv_encash_apr_Days < 0 THEN (ins.lv_encash_apr_Days * -1) ELSE ins.lv_encash_apr_Days END),@Eff_In_Salary=Eff_In_Salary,@strCompOff_Dates = Leave_CompOff_Dates 							
					FROM	INSERTED INS  							
					WHERE	Lv_Encash_Apr_ID = @Lv_Encash_Apr_ID AND INS.Leave_ID=@Leave_Id
					
					--SELECT	@apply_hourly = apply_hourly,@Default_Short_Name = isnull(Default_Short_Name,'') 
					--FROM	T0040_LEAVE_MASTER --Changed by Gadriwala Muslim 02102014
					--WHERE	Leave_ID = @Leave_Id
				
				
				
					IF @apply_hourly = 1 and @Default_Short_Name <> 'COMP' --Changed by Gadriwala Muslim 02102014
						SET @Leave_Used = @leave_used * 8
				
					--set @Leave_Used = floor(@Leave_Used*2)/2
				
				
			
					IF ISNULL(@Lv_Encash_App_ID,0) > 0	
						BEGIN
							UPDATE	t0100_leave_Encash_Application 
							SET		Lv_Encash_App_Status = @Lv_Encash_Apr_Status
							WHERE	Lv_Encash_App_ID = @Lv_Encash_App_ID
						END 
						-- Gadriwala Muslim Added 02102014 - Start  
					IF @Default_Short_Name = 'COMP'
						BEGIN
							if  @Lv_Encash_Apr_Status ='A'  If @leave_Id > 0  
								BEGIN
									SELECT @Leave_Tran_ID = Isnull(max(Leave_Tran_ID),0) +1 From T0140_LEAVE_TRANSACTION
								
									INSERT	INTO #Encash_CompOff_Approved(Leave_date,Leave_Period)
									SELECT  Left(DATA,CHARINDEX(';',DATA)-1),SUBSTRING(DATA,CHARINDEX(';',DATA)+1,10) 
									FROM	dbo.SPlit(@strCompOff_Dates,'#') 
									WHERE	Data <> ''
		
									UPDATE	T0140_LEAVE_TRANSACTION 
									SET		CompOff_Debit = Compoff_Debit + LA.Leave_Period,
											CompOff_balance	= CompOff_balance - LA.Leave_Period
									FROM	T0140_LEAVE_TRANSACTION GOT 
											INNER JOIN #Encash_CompOff_Approved LA on Leave_Date = For_Date
									WHERE	GOT.Emp_ID = @Emp_Id and GOT.Cmp_ID = @cmp_ID and 
											Leave_ID = @Leave_Id --and Comoff_Flag = 1	--Comment by Ankit after discuss with Hardikbhai 17072015
										
									IF  EXISTS(SELECT emp_ID FROM T0140_LEAVE_TRANSACTION 
													WHERE For_Date =@For_Date and Leave_ID = @Leave_Id
													AND Cmp_ID = @Cmp_ID and Emp_ID = @Emp_Id)
										BEGIN
											UPDATE	T0140_LEAVE_TRANSACTION 
											SET		CompOff_Used = ISNULL(CompOff_Used,0) + @Leave_used	
													,Eff_In_Salary = @Eff_In_Salary
													,Leave_Encash_Days = isnull(Leave_Encash_Days,0) +  Isnull(@Leave_Used,0)
											WHERE	Leave_ID = @Leave_Id and For_Date = @For_Date and Cmp_ID = @Cmp_ID and Emp_ID = @Emp_ID
										END
									ELSE
										BEGIN
											INSERT INTO T0140_LEAVE_TRANSACTION(emp_id,Leave_Id,Cmp_ID,For_Date,Leave_Opening,Leave_Used,
													Leave_Closing,Leave_Credit,Leave_Tran_ID,Eff_In_Salary,Leave_Encash_days,CompOff_Used,Comoff_Flag)
											VALUES(@emp_id,@leave_Id,@Cmp_ID,@for_Date,0,0,0,0,@Leave_Tran_ID,@Eff_In_Salary,@Leave_Used,@Leave_Used,1)
										END
								END				
						END
					ELSE 	-- Gadriwala Muslim Added 02102014 - End
						BEGIN
							 
							IF  @Lv_Encash_Apr_Status ='A'  If @leave_Id > 0  
								BEGIN
									SELECT	@Leave_Tran_ID = Isnull(max(Leave_Tran_ID),0) +1 
									FROM	T0140_LEAVE_TRANSACTION
											
											
												
									IF EXISTS(SELECT emp_ID FROM T0140_LEAVE_TRANSACTION WHERE For_date = @For_date and leave_Id = @leave_Id  
													AND Cmp_ID = @Cmp_ID and emp_id = @emp_id)
										BEGIN
											
											

											UPDATE T0140_LEAVE_TRANSACTION 
											SET		--Leave_Used = Leave_Used + @Leave_Used , 
													Leave_Closing = Leave_Closing - @Leave_Used 
													,Eff_In_Salary=@Eff_In_Salary	
													--,Eff_In_Salary=1-- commented by mitesh on 10042012
													,Leave_Encash_Days = isnull(Leave_Encash_Days,0) +  Isnull(@Leave_Used,0)
											WHERE	Leave_Id = @Leave_Id and for_date = @For_Date and Cmp_ID = @Cmp_ID and emp_Id = @emp_Id
											
											

											UPDATE	T0140_LEAVE_TRANSACTION 
											SET		Leave_Opening = Leave_Opening - @Leave_Used,
													Leave_Closing = Leave_Closing - @Leave_Used   
													--,Eff_In_Salary=@Eff_In_Salary	
													--,Eff_In_Salary=@Eff_In_Salary -- commented by mitesh on 10042012										
											WHERE	Leave_Id = @Leave_Id and for_date > @For_Date and Cmp_ID = @Cmp_ID and emp_Id = @emp_Id
											
											
										END
									ELSE
										BEGIN	
											SELECT	@Last_Leave_Closing = isnull(Leave_Closing,0) 
											FROM	T0140_LEAVE_TRANSACTION
											WHERE	for_date = (SELECT	MAX(for_date) FROM T0140_LEAVE_TRANSACTION 
																WHERE	for_date < @For_date
																		and leave_Id = @leave_id and Cmp_ID = @Cmp_ID and emp_Id = @emp_Id) 
													and Cmp_ID = @Cmp_ID
													and leave_id = @leave_Id and emp_Id = @emp_Id
					
											IF @Last_Leave_Closing is null 
												SET  @Last_Leave_Closing = 0
										
						

											INSERT T0140_LEAVE_TRANSACTION(emp_id,Leave_Id,Cmp_ID,For_Date,Leave_Opening,Leave_Used,
													Leave_Closing,Leave_Credit,Leave_Tran_ID,Eff_In_Salary,Leave_Encash_days)
											VALUES(@emp_id,@leave_Id,@Cmp_ID,@for_Date,@last_Leave_Closing,0
													--,@last_Leave_Closing - @Leave_Used,0,@Leave_Tran_ID,@Eff_In_Salary)		-- commented by mitesh on 10042012										    		
													,@last_Leave_Closing - @Leave_Used,0,@Leave_Tran_ID,1,@Leave_Used)
													
											
											
											UPDATE T0140_LEAVE_TRANSACTION set Leave_Opening = Leave_Opening - @Leave_Used,
													Leave_Closing = Leave_Closing - @Leave_Used
													--,Eff_In_Salary=@Eff_In_Salary	
													--,Eff_In_Salary=1 -- commented by mitesh on 10042012
											WHERE	Leave_Id = @Leave_Id and for_date > @For_Date and Cmp_ID = @Cmp_ID and emp_Id = @emp_Id
										END 
								END 
						END
				END -- Update Condition
			ELSE
				BEGIN
				
					-- Gadriwala Muslim Added 02102014 - Start  
					--SELECT	@Leave_Id = leave_ID,@Cmp_ID = Cmp_ID,@strCompOff_Dates= Leave_CompOff_Dates  
					--FROM	deleted
					--SELECT	@Default_Short_Name = isnull(Default_short_Name,'')  
					--from T0040_LEAVE_MASTER where Leave_ID = @Leave_ID and Cmp_ID = @Cmp_ID

					--Added by Jaina 21-07-2017									
					SELECT  @Leave_Used = (Case when ins.lv_encash_apr_Days < 0 THEN (ins.lv_encash_apr_Days * -1) ELSE ins.lv_encash_apr_Days END),@Eff_In_Salary=Eff_In_Salary,@strCompOff_Dates = Leave_CompOff_Dates 							
					FROM	DELETED INS  							
					WHERE	Lv_Encash_Apr_ID = @Lv_Encash_Apr_ID AND INS.Leave_ID=@Leave_Id
		
					IF @Default_Short_Name = 'COMP'
						BEGIN
							--DECLARE Cur_l_Del CURSOR  FOR
							--SELECT  Cmp_ID,  emp_Id	 ,Lv_Encash_Apr_Status, isnull(Lv_Encash_App_ID,0),Leave_ID,Leave_CompOff_Dates,(Case when lv_encash_apr_Days < 0 THEN (lv_encash_apr_Days * -1) ELSE lv_encash_apr_Days END),LV_Encash_Apr_Date 
							--FROM	Deleted ins
 					
							--OPEN cur_L_Del
							--FETCH NEXT FROM Cur_l_Del INTO @Cmp_ID,@Emp_ID,	@Lv_Encash_Apr_Status,@Lv_Encash_App_ID,@Leave_ID,@strCompOff_Dates,@Leave_Used,@For_Date  
					
							--WHILE @@FETCH_STATUS =0
							--	BEGIN
									IF ISNULL(@Lv_Encash_App_ID,0) > 0	
										BEGIN
											UPDATE	t0100_leave_Encash_Application 
											SET		Lv_Encash_App_Status = 'P'
											WHERE	Lv_Encash_App_ID = @Lv_Encash_App_ID
										END 
									IF @Lv_Encash_Apr_Status ='A'
										BEGIN
											INSERT	INTO #Encash_CompOff_Approved(Leave_date,Leave_Period)
											SELECT  Left(DATA,CHARINDEX(';',DATA)-1),SUBSTRING(DATA,CHARINDEX(';',DATA)+1,10) 
											FROM	dbo.SPlit(@strCompOff_Dates,'#') 
											WHERE	Data <> ''
											
											
											
											UPDATE	T0140_LEAVE_TRANSACTION 
											SET		CompOff_Debit = Compoff_Debit - LA.Leave_Period,
													CompOff_balance	= CompOff_balance + LA.Leave_Period
											FROM	T0140_LEAVE_TRANSACTION GOT 
													INNER JOIN #Encash_CompOff_Approved LA on Leave_Date = For_Date
											WHERE	GOT.Emp_ID = @Emp_Id and GOT.Cmp_ID = @cmp_ID 
													AND Leave_ID = @Leave_Id and Comoff_Flag = 1
															
											UPDATE	T0140_LEAVE_TRANSACTION 
											SET		CompOff_Used = isnull(CompOff_Used,0) - isnull(@Leave_Used,0)
													,Leave_Encash_Days = isnull(Leave_Encash_Days,0) - isnull(@Leave_Used ,0)
													,Eff_In_Salary=@Eff_In_Salary
											WHERE	leave_id = @leave_Id and emp_id = @emp_id and for_date = @for_date 
													and Cmp_ID = @Cmp_ID		
										END -- Approval Flag
						
							--		FETCH NEXT FROM Cur_l_Del INTO @Cmp_ID,@Emp_ID,	@Lv_Encash_Apr_Status,@Lv_Encash_App_ID,@Leave_ID,@strCompOff_Dates,@Leave_Used,@For_Date 
							--	END
							--CLOSE cur_L_Del
							--DEALLOCATE cur_L_Del
						END
					ELSE -- Gadriwala Muslim Added 02102014 - End 
						BEGIN
							/*
							DECLARE Cur_l_Del CURSOR  FOR
							SELECT  Cmp_ID,  emp_Id	 ,Lv_Encash_Apr_Status, isnull(Lv_Encash_App_ID,0) ,Leave_ID,(Case when lv_encash_apr_Days < 0 THEN (lv_encash_apr_Days * -1) ELSE lv_encash_apr_Days END),
 									LV_Encash_Apr_Date from Deleted ins
 					
							OPEN cur_L_Del
							FETCH NEXT FROM Cur_l_Del INTO @Cmp_ID,@Emp_ID,	@Lv_Encash_Apr_Status,@Lv_Encash_App_ID,@Leave_ID,@Leave_Used,@for_date 
							WHILE @@FETCH_STATUS =0
								BEGIN
									SELECT	@apply_hourly = apply_hourly 
									FROM	T0040_LEAVE_MASTER
									WHERE	Leave_ID = @Leave_Id
									*/
									
					
									IF @apply_hourly = 1
										SET @Leave_Used = @leave_used * 8
					
									--	set @Leave_Used = floor(@Leave_Used*2)/2
					
									IF ISNULL(@Lv_Encash_App_ID,0) > 0	
										BEGIN
											UPDATE	t0100_leave_Encash_Application 
											SET		Lv_Encash_App_Status = 'P'
											WHERE	Lv_Encash_App_ID = @Lv_Encash_App_ID
										END 
						
									IF @Lv_Encash_Apr_Status ='A'
										BEGIN
										
											
											
											UPDATE	T0140_LEAVE_TRANSACTION 
											SET		--Leave_Used = Leave_Used - @Leave_Used ,
													Leave_Closing = ISNULL(Leave_Closing,0) + ISNULL(@Leave_Used,0)
													,Leave_Encash_Days = isnull(Leave_Encash_Days,0) - ISNULL(@Leave_Used ,0)
											WHERE	leave_id = @leave_Id and emp_id = @emp_id and for_date = @for_date 
													and Cmp_ID = @Cmp_ID	
										
																					
											UPDATE	T0140_LEAVE_TRANSACTION 
											SET		Leave_Opening = isnull(Leave_Opening,0) + isnull(@Leave_Used,0)
													,Leave_Closing = isnull(Leave_Closing,0) + isnull(@Leave_Used,0)
											WHERE	leave_id = @leave_Id and emp_id = @emp_id and for_date > @for_date 
													and Cmp_ID = @Cmp_ID	
										END -- Approval Flag
							/*
									FETCH NEXT FROM Cur_l_Del INTO @Cmp_ID,@Emp_ID,	@Lv_Encash_Apr_Status,@Lv_Encash_App_ID,@Leave_ID,@Leave_Used,@for_date 
								END
							CLOSE cur_L_Del
							DEALLOCATE cur_L_Del*/
						END	
				END


			--FETCH NEXT FROM curInserted INTO  @Lv_Encash_Apr_ID,@Leave_Id,@Cmp_ID
			FETCH NEXT FROM curInserted INTO  @Lv_Encash_Apr_ID, @Lv_Encash_App_ID,  @For_Date, @Leave_Id, @Cmp_ID, @Emp_Id, 
				@Lv_Encash_Apr_Status, @Default_Short_Name, @apply_hourly,@strCompOff_Dates, @FLAG   --Change by Jaina 28-06-2017 Missing @strCompOff_Dates
		END
	CLOSE curInserted
	DEALLOCATE curInserted




