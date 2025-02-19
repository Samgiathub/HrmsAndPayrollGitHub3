CREATE TABLE [dbo].[T0100_LEAVE_CF_DETAIL] (
    [LEAVE_CF_ID]                   NUMERIC (18)    NOT NULL,
    [Cmp_ID]                        NUMERIC (18)    NOT NULL,
    [Emp_ID]                        NUMERIC (18)    NOT NULL,
    [Leave_ID]                      NUMERIC (18)    NOT NULL,
    [CF_For_Date]                   DATETIME        NULL,
    [CF_From_Date]                  DATETIME        NULL,
    [CF_To_Date]                    DATETIME        NULL,
    [CF_P_Days]                     NUMERIC (18, 2) NULL,
    [CF_Leave_Days]                 NUMERIC (22, 8) NOT NULL,
    [CF_Type]                       VARCHAR (50)    NOT NULL,
    [Exceed_CF_Days]                NUMERIC (22, 8) CONSTRAINT [DF__T0100_LEA__Excee__748502E1] DEFAULT ((0)) NULL,
    [Leave_CompOff_Dates]           NVARCHAR (MAX)  NULL,
    [Is_Fnf]                        TINYINT         CONSTRAINT [DF_T0100_LEAVE_CF_DETAIL_Is_Fnf] DEFAULT ((0)) NOT NULL,
    [CF_Laps_Days]                  NUMERIC (18, 2) CONSTRAINT [DF_T0100_LEAVE_CF_DETAIL_CF_Laps_Days] DEFAULT ((0)) NULL,
    [Advance_Leave_Balance]         NUMERIC (18, 2) NULL,
    [Advance_Leave_Recover_Balance] NUMERIC (18, 2) NULL,
    [Last_Modify_Date]              DATETIME        NULL,
    [Last_Modify_By]                NUMERIC (18)    NULL,
    [CF_MODE]                       VARCHAR (16)    NULL,
    [CF_IsMakerChecker]             BIT             CONSTRAINT [DF__T0100_LEA__CF_Is__25FE8EF0] DEFAULT ((0)) NULL,
    CONSTRAINT [PK_T0100_LEAVE_CF_DETAIL] PRIMARY KEY CLUSTERED ([LEAVE_CF_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0100_LEAVE_CF_DETAIL_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0100_LEAVE_CF_DETAIL_T0040_LEAVE_MASTER] FOREIGN KEY ([Leave_ID]) REFERENCES [dbo].[T0040_LEAVE_MASTER] ([Leave_ID]),
    CONSTRAINT [FK_T0100_LEAVE_CF_DETAIL_T0080_EMP_MASTER] FOREIGN KEY ([Emp_ID]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID])
);


GO
CREATE NONCLUSTERED INDEX [IX_T0100_LEAVE_CF_DETAIL_SP_GET_EMP_FNF_DETAIL]
    ON [dbo].[T0100_LEAVE_CF_DETAIL]([Emp_ID] ASC, [Leave_ID] ASC) WITH (FILLFACTOR = 95);


GO
CREATE TRIGGER [dbo].[Tri_T0100_LEAVE_CF_DETAIL]  
ON dbo.T0100_LEAVE_CF_DETAIL  
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
	Declare @CompOff_Leave_Dates    nvarchar(max) -- Added By Gadriwala Muslim 18022015
	Declare @CompOff_Leave_ID		numeric(18,0)
	Declare @Leave_CF_flag Numeric
	DECLARE @COPH_LEAVE_ID			NUMERIC(18,0) 
		SET @COPH_LEAVE_ID = 0
	
	SET @leave_CF_flag = 0

	
	Declare @IsMakerChaker int =0 --Added by ronakk 03092022
	
	Declare @CF_Laps_Days numeric(18,2) --Hardik 21/04/2016
	SET @CF_Laps_Days = 0
	
	Create Table #Leave_CompOff_Approved
	(
		Leave_Date datetime,
		Leave_Period numeric(18,2)
	)
	DECLARE @STRLEAVE_COPH_DATES NVARCHAR(MAX) 
	DECLARE @COPH_DEBIT AS NUMERIC(18,2) 
	CREATE TABLE #LEAVE_APPROVED
	(
		LEAVE_APPR_DATE DATETIME,
		LEAVE_PERIOD NUMERIC(18,2)
	)

	DECLARE @Max_Leave_CF_Year Numeric
	SET @Max_Leave_CF_Year = 0
	SELECT	@Max_Leave_CF_Year = No_Of_Allowed_Leave_CF_Yrs
	FROM	T0040_LEAVE_MASTER LM
			LEFT OUTER JOIN inserted I ON LM.LEAVE_ID=I.Leave_ID
			LEFT OUTER JOIN deleted D ON LM.Leave_ID=D.Leave_ID
	WHERE	COALESCE(I.Leave_ID,D.Leave_ID, 0) > 0
	
	
	 --select * from inserted
	
	IF  UPDATE(Leave_ID) 
		BEGIN
			
			--select * from inserted
			--return
			
			SELECT	@Cmp_ID= Cmp_ID ,@Emp_ID = Emp_ID ,@Leave_Id = ins.Leave_Id, @For_Date = CF_For_Date ,@CF_Leave_Days = ins.CF_Leave_Days,
					@CompOff_Leave_Dates =  IsNull(ins.Leave_CompOff_Dates,''),@CF_Laps_Days = IsNull(CF_Laps_Days,0)  --Hardik 21/04/2016
					,@IsMakerChaker = CF_IsMakerChecker		--Added by ronakk 03092022	
			FROM	inserted ins	



	--			IF @For_Date = '2018-07-01'
	--									SELECT @CF_Laps_Days, *  from inserted
				
	--IF @For_Date = '2018-07-01'
	--							select 'NOrmal', * from T0140_LEAVE_TRANSACTION Where Emp_ID=@Emp_ID and Leave_ID=@Leave_ID AND For_Date=@For_Date
							
			-- Added by rohit for UPDATE the Comp-off flag on 26102012 
			--If 'Comp' = (SELECT IsNull(Default_Short_Name,'') FROM T0040_LEAVE_MASTER WHERE Cmp_ID=@Cmp_ID AND Leave_ID=@Leave_Id)
			--begin
			--SET @leave_CF_flag = 1
			--end
			IF EXISTS (SELECT 1 FROM T0040_LEAVE_MASTER WHERE Cmp_ID=@Cmp_ID AND Leave_ID=@Leave_Id AND (IsNull(Default_Short_Name,'') = 'COMP' OR IsNull(Default_Short_Name,'') = 'COPH' OR IsNull(Default_Short_Name,'') = 'COND') ) 
				begin
					SET @leave_CF_flag = 1
				END	

			SELECT @CompOff_Leave_ID = Leave_ID FROM T0040_LEAVE_MASTER WHERE IsNull(Default_Short_Name,'') = 'COMP' AND Cmp_ID = @Cmp_ID
			SELECT @COPH_LEAVE_ID = LEAVE_ID FROM T0040_LEAVE_MASTER WHERE IsNull(DEFAULT_SHORT_NAME,'') = 'COPH' AND CMP_ID = @CMP_ID -- ADDED by SUmit 29092016
			
			IF @Leave_Id > 0  
				BEGIN
				
					IF @Leave_CF_flag = 0
						BEGIN	
							
							SET @Last_Leave_Closing = 0
							
							IF (@Max_Leave_CF_Year > 0)
								SELECT	@CF_Laps_Days = Laps, @Last_Leave_Closing=CF_Days  FROM dbo.fn_getLastYearCFDays(@emp_Id,@For_Date,@Leave_Id) T														
							ELSE							
							
								SELECT	@Last_Leave_Closing = IsNull(Leave_Closing,0) 
								FROM	T0140_LEAVE_TRANSACTION
								WHERE	For_Date = (SELECT	MAX(for_date) 
													FROM	T0140_LEAVE_TRANSACTION 
													WHERE	For_Date < @For_date AND leave_Id = @leave_id AND Cmp_ID = @Cmp_ID AND emp_Id = @emp_Id) 
										AND Cmp_ID = @Cmp_ID AND leave_id = @leave_Id AND emp_Id = @emp_Id
							
							

						
							IF EXISTS(SELECT 1 FROM T0140_LEAVE_TRANSACTION 
										WHERE For_date = @For_date AND leave_Id = @leave_Id AND Cmp_ID = @Cmp_ID AND Emp_ID = @Emp_Id)
								BEGIN
								
									--Updating Opening, Credit and Laps Days
									
									If @IsMakerChaker <> 1
									Begin
									--Condtion Aded by ronakk 03092022

										UPDATE	T0140_LEAVE_TRANSACTION 
										SET		Leave_Opening = @Last_Leave_Closing,
												Leave_Credit = Leave_Credit + @CF_Leave_Days,
												Comoff_Flag = @leave_CF_flag, 
												CF_Laps_Days = @CF_Laps_Days -- CASE WHEN @Max_Leave_CF_Year > 0 THEN @CF_Laps_Days	ELSE CF_Laps_Days END
										WHERE	Leave_Id = @Leave_Id AND for_date = @For_Date AND Cmp_ID = @Cmp_ID
												AND emp_Id = @emp_Id

									end
									
									
								END
							ELSE
								BEGIN															
									IF @Last_Leave_Closing IS NULL 
										SET @Last_Leave_Closing = 0
									
								
									SELECT @Leave_Tran_ID = IsNull(MAX(Leave_Tran_ID),0) +1 FROM T0140_LEAVE_TRANSACTION							

									INSERT T0140_LEAVE_TRANSACTION(emp_id,Leave_Id,Cmp_ID,For_Date,Leave_Opening,Leave_Credit,
										Leave_Closing,Leave_Used,Leave_Tran_ID,Comoff_Flag,CF_Laps_Days
										,IsMakerChaker) --Added by ronakk 03092022
									VALUES(@emp_id,@leave_Id,@Cmp_ID,@for_Date,@Last_Leave_Closing,@CF_Leave_Days
										,0,0,@Leave_Tran_ID,@Leave_CF_flag,@CF_Laps_Days
										,@IsMakerChaker) --Added by ronakk 03092022												    		

									/*Commented by Nimesh On 14-March-2018 (Following Logic will not work if opening given after Leave CarryForward Date)*/
									--UPDATE T0140_LEAVE_TRANSACTION SET Leave_Opening = Leave_Opening + @CF_Leave_Days -@CF_Laps_Days --added by Hardik 21/04/2016
									--	,Leave_Closing = Leave_Closing + @CF_Leave_Days - @CF_Laps_Days --added by Hardik 21/04/2016
									--	,Comoff_Flag = @leave_CF_flag	
									--WHERE Leave_Id = @Leave_Id AND for_date > @For_Date AND Cmp_ID = @Cmp_ID 
									--	and emp_Id = @emp_Id
										
								END
							
						
						If @IsMakerChaker <> 1
						Begin
						--Condtion Aded by ronakk 03092022
						
						
							--Updating Closing Balance
							UPDATE	T
							SET		Leave_Closing = Leave_Opening + Leave_Credit - (Leave_Used + IsNull(Leave_Adj_L_Mark,0) + IsNull(CompOff_Used,0) + IsNULL(CF_LAPS_DAYS,0))
							FROM	T0140_LEAVE_TRANSACTION  T		
									INNER JOIN T0040_LEAVE_MASTER LM ON T.LEAVE_ID=LM.LEAVE_ID
							WHERE	T.Leave_Id = @Leave_Id AND for_date = @For_Date AND T.Cmp_ID = @Cmp_ID
									AND emp_Id = @emp_Id
						
							
							--Updating Leave Posting if Opening is given
							UPDATE	T
							SET		Leave_Closing = 0,
									Leave_Posting = Leave_Closing
							FROM	T0140_LEAVE_TRANSACTION  T		
							WHERE	T.Leave_Id = @Leave_Id AND for_date = @For_Date AND T.Cmp_ID = @Cmp_ID
									AND emp_Id = @emp_Id AND Leave_Posting IS NOT NULL
							
							
						End



							IF @CompOff_Leave_Dates <> '' -- CompOff  Transfer to Another Leave 18022015
								BEGIN
								
									INSERT	INTO #Leave_CompOff_Approved(Leave_date,Leave_Period)
									SELECT  Left(DATA,CHARINDEX(';',DATA)-1),SUBSTRING(DATA,CHARINDEX(';',DATA)+1,10) 
									FROM	dbo.SPlit(@CompOff_Leave_Dates,'#') 
									WHERE	Data <> ''
								
		  		
								If @IsMakerChaker <> 1
								Begin
								--Condtion Aded by ronakk 03092022
									
									UPDATE	T0140_LEAVE_TRANSACTION 
									SET		CompOff_Debit = Compoff_Debit + LA.Leave_Period,
											CompOff_balance	= CompOff_balance - LA.Leave_Period 
									FROM	T0140_LEAVE_TRANSACTION GOT 
											INNER JOIN #Leave_CompOff_Approved LA on Leave_Date = For_Date 
									WHERE	GOT.Emp_ID = @Emp_Id AND GOT.Cmp_ID = @cmp_ID AND Leave_ID = @CompOff_Leave_ID AND Comoff_Flag = 1

									End



								END

								
						END
					ELSE		--Added by Gadriwala Muslim 02102014 - Start
						BEGIN
							--Added by Sumit on 29092016--START COPH CURRENT MONTH DAYS LEAVE APPLY--------------------------------------------------------
							SET @COPH_DEBIT = 0
							IF EXISTS ( SELECT 1 FROM T0040_LEAVE_MASTER WHERE IsNull(DEFAULT_SHORT_NAME,'') = 'COPH' AND LEAVE_ID = @LEAVE_ID)
								BEGIN
									SET @STRLEAVE_COPH_DATES = ''	 
									
									SELECT @STRLEAVE_COPH_DATES = @STRLEAVE_COPH_DATES + '#' + IsNull(LEAVE_COMPOFF_DATES,'')   
									FROM  DBO.V0130_LEAVE_APPROVAL_DETAILS WHERE LEAVE_ID = @LEAVE_ID 
										AND MONTH(@for_Date) = MONTH(SYSTEM_DATE) 
										AND YEAR(@for_Date) = YEAR(SYSTEM_DATE) 
										AND APPROVAL_STATUS = 'A' AND CMP_ID = @CMP_ID AND emp_Id = @emp_Id
									
									INSERT INTO #LEAVE_APPROVED	(LEAVE_APPR_DATE,LEAVE_PERIOD)
		   							 SELECT  LEFT(DATA,CHARINDEX(';',DATA)-1),SUBSTRING(DATA,CHARINDEX(';',DATA)+1,10) 
									 FROM DBO.SPLIT(@STRLEAVE_COPH_DATES,'#') WHERE  DATA <> ''
									 
								END

							SELECT @COPH_DEBIT = IsNull(LEAVE_PERIOD,0)  FROM #LEAVE_APPROVED WHERE LEAVE_APPR_DATE = @FOR_DATE								
							-- START COPH CURRENT MONTH DAYS LEAVE APPLY
					
							--Ended by Sumit 06092016----
					
							SELECT @Leave_Tran_ID = IsNull(max(Leave_Tran_ID),0) +1 FROM T0140_LEAVE_TRANSACTION
						
							IF EXISTS(SELECT 1 FROM T0140_LEAVE_TRANSACTION WHERE For_date = @For_date AND leave_Id = @leave_Id  
											and Cmp_ID = @Cmp_ID AND emp_id = @emp_id)
								BEGIN


								If @IsMakerChaker <> 1
								Begin
								--Condtion Aded by ronakk 03092022
									
									UPDATE T0140_LEAVE_TRANSACTION set CompOff_Credit = CompOff_Credit + @CF_Leave_Days, CompOff_Debit = CompOff_Debit +  @COPH_DEBIT
											,CompOff_Balance = (CompOff_Balance + @CF_Leave_Days) - @COPH_DEBIT,Comoff_Flag = 1
									WHERE	Leave_Id = @Leave_Id AND for_date = @For_Date AND Cmp_ID = @Cmp_ID
											and emp_Id = @emp_Id	

								End

								END
								ELSE
								BEGIN
								
									INSERT T0140_LEAVE_TRANSACTION(emp_id,Leave_Id,Cmp_ID,For_Date,Leave_Opening,Leave_Credit,
											Leave_Closing,Leave_Used,Leave_Tran_ID,Comoff_Flag,CompOff_Credit,CompOFf_Debit,CompOff_Balance
											,IsMakerChaker ) -- Added by ronakk 03092022
									VALUES(@emp_id,@leave_Id,@Cmp_ID,@for_Date,0,0
											,0,0,@Leave_Tran_ID,1,@CF_Leave_Days,@COPH_DEBIT,(@CF_Leave_Days - @COPH_DEBIT)
											,@IsMakerChaker)  -- Added by ronakk 03092022
								END
						END --Added by Gadriwala Muslim 02102014 - End
				END


		

			If @IsMakerChaker <> 1
			Begin
			--Condtion Aded by ronakk 03092022
			
			/*Following Code Added By Nimesh On 14-March-2018 (To Update The Leave Transaction Balance)*/
			EXEC dbo.P_Update_Leave_Transaction @Emp_ID=@Emp_Id,@Leave_ID=@Leave_Id,@For_Date=@For_Date
			
			End

														
	
			
		END
	ELSE
		BEGIN

		If @IsMakerChaker <> 1
		Begin
		--Condtion Aded by ronakk 03092022


			DECLARE Cur_del CURSOR FOR 
			SELECT leave_Id , Cmp_ID,  emp_Id ,CF_For_Date ,CF_LeavE_Days,IsNull(Leave_CompOff_Dates,'') ,CF_Laps_Days FROM deleted
			OPEN cur_del
			FETCH NEXT FROM cur_del INTO @leave_Id , @Cmp_ID ,  @Emp_Id ,@For_Date ,@CF_Leave_Days,@CompOff_Leave_Dates,@CF_Laps_Days
			WHILE @@FETCH_STATUS =0
				BEGIN
					SET @leave_CF_flag = 0
					IF EXISTS(SELECT 1 FROM T0040_LEAVE_MASTER WHERE Cmp_ID=@Cmp_ID AND Leave_ID=@Leave_Id AND (IsNull(default_Short_Name,'') = 'COMP' OR IsNull(default_Short_Name,'') = 'COPH' OR IsNull(default_Short_Name,'') = 'COND'))
						BEGIN
							SET @leave_CF_flag = 1
						END
			
					SELECT @CompOff_Leave_ID = Leave_ID FROM T0040_LEAVE_MASTER 
					WHERE	IsNull(Default_Short_Name,'') = 'COMP' AND Cmp_ID = @Cmp_ID
					
					Set @Last_Leave_Closing = 0

					IF  @Leave_CF_flag = 0 
						BEGIN
						
							SELECT	@Last_Leave_Closing = CASE WHEN Leave_Posting IS NOT NULL THEN NULL Else IsNull(Leave_Closing,0) END
							FROM	T0140_LEAVE_TRANSACTION
							WHERE	For_Date = (SELECT	MAX(for_date) 
												FROM	T0140_LEAVE_TRANSACTION 
												WHERE	For_Date < @For_date AND leave_Id = @leave_id AND Cmp_ID = @Cmp_ID AND emp_Id = @emp_Id) 
									AND Cmp_ID = @Cmp_ID AND leave_id = @Leave_Id AND Emp_ID = @Emp_Id 
							


							UPDATE	T0140_LEAVE_TRANSACTION 
							SET		Leave_Opening = IsNull(@Last_Leave_Closing,Leave_Opening),
									Leave_Credit = Leave_Credit - @CF_Leave_Days,
									--Leave_Closing = Leave_Closing - @CF_Leave_Days + @CF_Laps_Days,
									CF_Laps_Days = CF_Laps_Days - @CF_Laps_Days,
									Comoff_Flag = @leave_CF_flag 
							WHERE	Leave_ID = @Leave_Id AND Emp_ID = @Emp_Id AND For_Date = @For_Date AND Cmp_ID = @Cmp_ID	

							--Updating Closing Balance
							UPDATE	T
							SET		Leave_Closing = Leave_Opening + Leave_Credit - (Leave_Used + IsNull(Leave_Adj_L_Mark,0) + IsNull(CompOff_Used,0) + IsNULL(CF_LAPS_DAYS,0))
							FROM	T0140_LEAVE_TRANSACTION  T		
									INNER JOIN T0040_LEAVE_MASTER LM ON T.LEAVE_ID=LM.LEAVE_ID
							WHERE	T.Leave_Id = @Leave_Id AND for_date = @For_Date AND T.Cmp_ID = @Cmp_ID
									AND emp_Id = @emp_Id

							--Updating Leave Posting if Opening is given
							UPDATE	T
							SET		Leave_Closing = 0,
									Leave_Posting = Leave_Closing
							FROM	T0140_LEAVE_TRANSACTION  T		
							WHERE	T.Leave_Id = @Leave_Id AND for_date = @For_Date AND T.Cmp_ID = @Cmp_ID
									AND emp_Id = @emp_Id AND Leave_Posting IS NOT NULL
							
							/*Commented by Nimesh On 14-March-2018 (Following Logic will not work if opening given after Leave CarryForward Date)*/
							--UPDATE T0140_LEAVE_TRANSACTION set Leave_Opening = Leave_Opening - @CF_Leave_Days + @CF_Laps_Days --added by Hardik 21/04/2016
							--,Leave_Closing = Leave_Closing - @CF_Leave_Days + @CF_Laps_Days--added by Hardik 21/04/2016
							--,Comoff_Flag = @leave_CF_flag
							--WHERE leave_id = @leave_Id AND emp_id = @emp_id AND for_date > @for_date 
							--and Cmp_ID = @Cmp_ID
								
							IF @CompOff_Leave_Dates <> '' -- CompOff  Transfer to Another Leave 18022015
								begin
									Insert into #Leave_CompOff_Approved(Leave_date,Leave_Period)
									SELECT  Left(DATA,CHARINDEX(';',DATA)-1),SUBSTRING(DATA,CHARINDEX(';',DATA)+1,10) 
									from dbo.SPlit(@CompOff_Leave_Dates,'#') WHERE Data <> ''
								
		  				
									UPDATE T0140_LEAVE_TRANSACTION set CompOff_Debit = Compoff_Debit - LA.Leave_Period,
									CompOff_balance	= CompOff_balance + LA.Leave_Period FROM T0140_LEAVE_TRANSACTION GOT 
									inner join #Leave_CompOff_Approved LA on Leave_Date = For_Date 
									WHERE GOT.Emp_ID = @Emp_Id AND GOT.Cmp_ID = @cmp_ID AND 
									Leave_ID = @CompOff_Leave_ID AND Comoff_Flag = 1
										
								end
									
						end
					ELSE--Added by Gadriwala Muslim 02102014 - Start
						BEGIN
							---ADDED BY Sumit 29092016 -- START COPH CURRENT MONTH DAYS LEAVE APPLY
							SET @COPH_DEBIT = 0
							IF EXISTS (SELECT 1 FROM T0040_LEAVE_MASTER WHERE IsNull(DEFAULT_SHORT_NAME,'') = 'COPH' AND LEAVE_ID = @LEAVE_ID)
								BEGIN
									SET @STRLEAVE_COPH_DATES = ''	 
									SELECT	@STRLEAVE_COPH_DATES = @STRLEAVE_COPH_DATES + '#' + IsNull(LEAVE_COMPOFF_DATES,'')   
									FROM	DBO.V0130_LEAVE_APPROVAL_DETAILS 
									WHERE	LEAVE_ID = @LEAVE_ID 
											AND MONTH(@FOR_DATE) = MONTH(SYSTEM_DATE) 
											AND YEAR(@FOR_DATE) = YEAR(SYSTEM_DATE) 
											AND APPROVAL_STATUS = 'A' AND CMP_ID = @CMP_ID AND EMP_ID = @EMP_ID
									
									INSERT	INTO #LEAVE_APPROVED	(LEAVE_APPR_DATE,LEAVE_PERIOD)
		   							SELECT  LEFT(DATA,CHARINDEX(';',DATA)-1),SUBSTRING(DATA,CHARINDEX(';',DATA)+1,10) 
									FROM	DBO.SPLIT(@STRLEAVE_COPH_DATES,'#') WHERE  DATA <> ''
								END	
							SELECT @COPH_DEBIT = IsNull(LEAVE_PERIOD,0)  FROM #LEAVE_APPROVED WHERE LEAVE_APPR_DATE = @FOR_DATE
							---Ended BY Sumit 29092016 -- END COPH CURRENT MONTH DAYS LEAVE APPLY
							
							UPDATE T0140_LEAVE_TRANSACTION set  CompOff_Credit = CompOff_Credit - @CF_Leave_Days 
										,CompOff_Balance = CompOff_Balance - @CF_Leave_Days,Comoff_Flag = 1
										WHERE leave_id = @leave_Id AND emp_id = @emp_id AND for_date = @for_date 
										and Cmp_ID = @Cmp_ID	
								
										
						END--Added by Gadriwala Muslim 02102014 - End

					/*Following Code Added By Nimesh On 14-March-2018 (To Update The Leave Transaction Balance)*/
					EXEC dbo.P_Update_Leave_Transaction @Emp_ID=@Emp_Id,@Leave_ID=@Leave_Id,@For_Date=@For_Date
					FETCH NEXT FROM cur_del INTO @leave_Id , @Cmp_ID ,  @Emp_Id ,@For_Date ,@CF_Leave_Days,@CompOff_Leave_Dates,@CF_Laps_Days  
				END
			CLOSE cur_Del
			DEALLOCATE cur_Del	
			

			End

		END

GO
CREATE TRIGGER [dbo].[Tri_T0100_LEAVE_CF_DETAIL_Update]
ON dbo.T0100_LEAVE_CF_DETAIL 
FOR UPDATE
AS

	DECLARE @Leave_Tran_ID AS NUMERIC 
	DECLARE @Emp_Id AS NUMERIC
	DECLARE @Grade_Id AS NUMERIC
	DECLARE @Cmp_ID AS NUMERIC
	DECLARE @Leave_Id AS NUMERIC
	DECLARE @For_date AS DATETIME
	DECLARE @Last_Leave_Closing	NUMERIC(18,2)	
	DECLARE @CF_Leave_Days AS NUMERIC(18,2)
	
	DECLARE @Temp_leave_Bal AS NUMERIC ( 18,2)
	DECLARE @Temp_Max_Date AS DATETIME

	-- Check Leave Balance
	DECLARE @Leave_Name AS VARCHAR(100)
	DECLARE @ErrString AS VARCHAR(200)

	DECLARE @CF_Laps_Days NUMERIC(18,1) --Hardik 21/04/2016
	SET @CF_Laps_Days = 0


	-- Added by rohit for UPDATE the Comp-off flag on 26102012 
	DECLARE @Leave_CF_flag Numeric
	SET @leave_CF_flag = 0
	
	SET @Temp_Max_Date = NULL
	SET @Temp_leave_Bal = 0

	SELECT  @Leave_Id = Leave_ID ,@Cmp_ID = Cmp_ID,  @Emp_Id = Emp_ID ,@For_Date =CF_For_Date ,@CF_Leave_Days = CF_LeavE_Days,@CF_Laps_Days = ISNULL(CF_Laps_Days,0) 
	FROM	deleted 
	-- Added by rohit for UPDATE the Comp-off flag on 26102012 

	IF EXISTS(SELECT 1 FROM T0040_LEAVE_MASTER WHERE Cmp_ID = @Cmp_ID AND leave_ID = @Leave_Id AND Default_Short_Name IN ('COMP','COPH','COND'))
		BEGIN
			SET @leave_CF_flag = 1
		END

	DECLARE @Max_Leave_CF_Year Numeric
	SET @Max_Leave_CF_Year = 0

	SELECT	@Max_Leave_CF_Year = No_Of_Allowed_Leave_CF_Yrs
	FROM	T0040_LEAVE_MASTER LM			
	WHERE	Leave_ID = @Leave_Id

	IF @Leave_CF_flag = 0
		BEGIN
			SET @Last_Leave_Closing = 0
							
			IF (@Max_Leave_CF_Year > 0)
				SELECT	@CF_Laps_Days = Laps, @Last_Leave_Closing=CF_Days  FROM dbo.fn_getLastYearCFDays(@emp_Id,@For_Date,@Leave_Id) T														
			ELSE							
				SELECT	@Last_Leave_Closing = IsNull(Leave_Closing,0) 
				FROM	T0140_LEAVE_TRANSACTION
				WHERE	For_Date = (SELECT	MAX(for_date) 
									FROM	T0140_LEAVE_TRANSACTION 
									WHERE	For_Date < @For_date AND leave_Id = @leave_id AND Cmp_ID = @Cmp_ID AND emp_Id = @emp_Id) 
						AND Cmp_ID = @Cmp_ID AND leave_id = @leave_Id AND emp_Id = @emp_Id

			--Updating Opening, Credit and Laps Days
			UPDATE	T0140_LEAVE_TRANSACTION 
			SET		Leave_Opening = @Last_Leave_Closing,
					Leave_Credit = Leave_Credit - @CF_Leave_Days,-- Change "+" to "-" by Hardik 04/02/2019 for Backbone as when they update from Leave carry Forward form it will goes double entries
					Comoff_Flag = @leave_CF_flag, 
					CF_Laps_Days = @CF_Laps_Days											
			WHERE	Leave_Id = @Leave_Id AND for_date = @For_Date AND Cmp_ID = @Cmp_ID
					AND emp_Id = @emp_Id							

			--Updating Closing Balance
			UPDATE	T
			SET		Leave_Closing = Leave_Opening + Leave_Credit - (Leave_Used + IsNull(Leave_Adj_L_Mark,0) + IsNull(CompOff_Used,0))
			FROM	T0140_LEAVE_TRANSACTION  T		
					INNER JOIN T0040_LEAVE_MASTER LM ON T.LEAVE_ID=LM.LEAVE_ID
			WHERE	T.Leave_Id = @Leave_Id AND for_date = @For_Date AND T.Cmp_ID = @Cmp_ID
					AND emp_Id = @emp_Id

			--Updating Leave Posting if Opening is given
			UPDATE	T
			SET		Leave_Closing = 0,
					Leave_Posting = Leave_Closing
			FROM	T0140_LEAVE_TRANSACTION  T		
			WHERE	T.Leave_Id = @Leave_Id AND for_date = @For_Date AND T.Cmp_ID = @Cmp_ID
					AND emp_Id = @emp_Id AND Leave_Posting IS NOT NULL

			/*Following Code Added By Nimesh On 14-March-2018 (To Update The Leave Transaction Balance)*/
			EXEC dbo.P_Update_Leave_Transaction @Emp_ID=@Emp_Id,@Leave_ID=@Leave_Id,@For_Date=@For_Date
			/*Commented by Nimesh On 14-March-2018 (Code Moved After Insert Statement)*/
			--UPDATE	T0140_LEAVE_TRANSACTION 
			--SET		Leave_Credit = Leave_Credit - @CF_Leave_Days,
			--		Leave_Closing = Leave_Closing - @CF_Leave_Days + @CF_Laps_Days,
			--		Comoff_Flag = @leave_CF_flag,
			--		CF_Laps_Days = @CF_Laps_Days
			--WHERE	Leave_ID = @Leave_Id AND Emp_ID = @Emp_Id AND For_Date = @For_date AND Cmp_ID = @Cmp_ID	
				
			/*Commented by Nimesh On 14-March-2018 (Following Logic will not work if opening given after Leave CarryForward Date)*/
			--UPDATE	T0140_LEAVE_TRANSACTION 
			--SET		Leave_Opening = Leave_Opening - @CF_Leave_Days,
			--		Leave_Closing = Leave_Closing - @CF_Leave_Days + @CF_Laps_Days,
			--		Comoff_Flag = @leave_CF_flag
			--WHERE	Leave_ID = @Leave_Id AND Emp_ID = @Emp_Id AND For_Date > @For_date AND Cmp_ID = @Cmp_ID	
		END
	ELSE
		BEGIN	--Changed by Gadriwala Muslim 02102014
			UPDATE	T0140_LEAVE_TRANSACTION 
			SET		CompOff_Credit = CompOff_Credit - @CF_Leave_Days,
					CompOff_Balance = CompOff_Balance - @CF_Leave_Days,
					Comoff_Flag = 1
			WHERE	Leave_ID = @Leave_Id AND Emp_ID = @Emp_Id AND For_Date = @For_date AND Cmp_ID = @Cmp_ID
		END

	SELECT	@Cmp_ID =Cmp_ID,@Emp_ID = Emp_ID,@Leave_Id = INS.Leave_ID, @For_Date = CF_For_Date,@CF_Leave_Days = INS.CF_Leave_Days,@CF_Laps_Days = ISNULL(CF_Laps_Days,0) 
	FROM	inserted INS	
				
	IF EXISTS(SELECT Default_Short_Name FROM T0040_LEAVE_MASTER WHERE Cmp_ID=@Cmp_ID AND Leave_ID=@Leave_Id AND (isnull(Default_Short_Name,'') = 'COMP' or isnull(Default_Short_Name,'') = 'COPH') )
		BEGIN
			SET @leave_CF_flag = 1
		END
		
	IF @leave_Id > 0  
		BEGIN
			IF @Leave_CF_flag = 0 
				BEGIN
					SELECT	@Leave_Tran_ID = IsNull(MAX(Leave_Tran_ID),0) + 1 
					FROM	T0140_LEAVE_TRANSACTION
				
					IF EXISTS(SELECT 1 FROM T0140_LEAVE_TRANSACTION 
								WHERE For_date = @For_date AND Leave_ID = @Leave_Id AND Cmp_ID = @Cmp_ID AND Emp_ID = @Emp_Id)
						BEGIN
							SET @Last_Leave_Closing = 0
							
							IF (@Max_Leave_CF_Year > 0)
								SELECT	@CF_Laps_Days = Laps, @Last_Leave_Closing=CF_Days  FROM dbo.fn_getLastYearCFDays(@emp_Id,@For_Date,@Leave_Id) T														
							ELSE							
								SELECT	@Last_Leave_Closing = IsNull(Leave_Closing,0) 
								FROM	T0140_LEAVE_TRANSACTION
								WHERE	For_Date = (SELECT	MAX(for_date) 
													FROM	T0140_LEAVE_TRANSACTION 
													WHERE	For_Date < @For_date AND leave_Id = @leave_id AND Cmp_ID = @Cmp_ID AND emp_Id = @emp_Id) 
										AND Cmp_ID = @Cmp_ID AND leave_id = @leave_Id AND emp_Id = @emp_Id

							--Updating Opening, Credit and Laps Days
							UPDATE	T0140_LEAVE_TRANSACTION 
							SET		Leave_Opening = @Last_Leave_Closing,
									Leave_Credit = @CF_Leave_Days, -- + Leave_Credit, -- Commented by Hardik 04/02/2020 for Backbone as when they update from Leave carry Forward form it will goes double entries
									Comoff_Flag = @leave_CF_flag, 
									CF_Laps_Days = @CF_Laps_Days											
							WHERE	Leave_Id = @Leave_Id AND for_date = @For_Date AND Cmp_ID = @Cmp_ID
									AND emp_Id = @emp_Id							
							

							/*Commented by Nimesh On 14-March-2018 (Code Moved After Insert Statement)*/
							--UPDATE	T0140_LEAVE_TRANSACTION 
							--SET		Leave_Credit = Leave_Credit + @CF_Leave_Days,
							--		Leave_Closing = Leave_Closing + @CF_Leave_Days - @CF_Laps_Days,
							--		Comoff_Flag = @leave_CF_flag, 
							--		CF_Laps_Days = @CF_Laps_Days
							--WHERE	Leave_Id = @Leave_Id AND for_date = @For_Date AND Cmp_ID = @Cmp_ID AND Emp_ID = @Emp_Id

							/*Commented by Nimesh On 14-March-2018 (Following Logic will not work if opening given after Leave CarryForward Date)*/
							--UPDATE T0140_LEAVE_TRANSACTION set Leave_Opening = Leave_Opening + @CF_Leave_Days
							--	,Leave_Closing = Leave_Closing + @CF_Leave_Days	-  @CF_Laps_Days --added by Hardik 21/04/2016
							--	,Comoff_Flag = @leave_CF_flag
							--WHERE Leave_Id = @Leave_Id AND for_date > @For_Date AND Cmp_ID = @Cmp_ID
							--	and emp_Id = @emp_Id
						END
					ELSE
						BEGIN
							SELECT	@Last_Leave_Closing = IsNull(Leave_Closing,0) 
							FROM	T0140_LEAVE_TRANSACTION
							WHERE	For_Date = (SELECT	MAX(for_date) 
												FROM	T0140_LEAVE_TRANSACTION 
												WHERE	For_Date < @For_date AND Leave_ID = @Leave_Id AND Cmp_ID = @Cmp_ID AND Emp_ID = @Emp_Id) 
									AND Cmp_ID = @Cmp_ID AND Leave_ID = @Leave_Id AND Emp_ID = @Emp_Id
					
							IF @Last_Leave_Closing IS NULL 
								SET @Last_Leave_Closing = 0

							INSERT T0140_LEAVE_TRANSACTION(emp_id,Leave_Id,Cmp_ID,For_Date,Leave_Opening,Leave_Credit,
									Leave_Closing,Leave_Used,Leave_Tran_ID,Comoff_Flag,CF_Laps_Days) --added by Hardik 21/04/2016
							VALUES(@emp_id,@leave_Id,@Cmp_ID,@for_Date,@last_Leave_Closing,@CF_Leave_Days,
									@last_Leave_Closing + @CF_Leave_Days -@CF_Laps_Days,0,@Leave_Tran_ID,@Leave_CF_flag,@CF_Laps_Days) --added by Hardik 21/04/2016

							/*Commented by Nimesh On 14-March-2018 (Following Logic will not work if opening given after Leave CarryForward Date)*/
							--UPDATE T0140_LEAVE_TRANSACTION set Leave_Opening = Leave_Opening + @CF_Leave_Days -@CF_Laps_Days --added by Hardik 21/04/2016
							--	,Leave_Closing = Leave_Closing + @CF_Leave_Days-@CF_Laps_Days --added by Hardik 21/04/2016
							--	,Comoff_Flag = @leave_CF_flag
							--WHERE Leave_Id = @Leave_Id AND for_date > @For_Date AND Cmp_ID = @Cmp_ID
							--	and emp_Id = @emp_Id
										
						END
					--Updating Closing Balance
					UPDATE	T
					SET		Leave_Closing = Leave_Opening + Leave_Credit - (Leave_Used + IsNull(Leave_Adj_L_Mark,0) + IsNull(CompOff_Used,0))
					FROM	T0140_LEAVE_TRANSACTION  T		
							INNER JOIN T0040_LEAVE_MASTER LM ON T.LEAVE_ID=LM.LEAVE_ID
					WHERE	T.Leave_Id = @Leave_Id AND for_date = @For_Date AND T.Cmp_ID = @Cmp_ID
							AND emp_Id = @emp_Id

					--Updating Leave Posting if Opening is given
					UPDATE	T
					SET		Leave_Closing = 0,
							Leave_Posting = Leave_Closing
					FROM	T0140_LEAVE_TRANSACTION  T		
					WHERE	T.Leave_Id = @Leave_Id AND for_date = @For_Date AND T.Cmp_ID = @Cmp_ID
							AND emp_Id = @emp_Id AND Leave_Posting IS NOT NULL

					/*Following Code Added By Nimesh On 14-March-2018 (To Update The Leave Transaction Balance)*/
					EXEC dbo.P_Update_Leave_Transaction @Emp_ID=@Emp_Id,@Leave_ID=@Leave_Id,@For_Date=@For_Date

				END
			ELSE --Changed by Gadriwala Muslim 02102014
				BEGIN
					SELECT	@Leave_Tran_ID = IsNull(MAX(Leave_Tran_ID),0) + 1 
					FROM	T0140_LEAVE_TRANSACTION
				
					IF EXISTS(SELECT * FROM T0140_LEAVE_TRANSACTION 
								WHERE For_date = @For_date AND Leave_ID = @Leave_Id AND Cmp_ID = @Cmp_ID AND Emp_ID = @Emp_Id)
						BEGIN
							UPDATE	T0140_LEAVE_TRANSACTION 
							SET		CompOff_Credit = CompOff_Credit + @CF_Leave_Days,
									CompOff_Balance = CompOff_Balance + @CF_Leave_Days,
									Comoff_Flag = 1
							WHERE	Leave_ID = @Leave_Id AND For_Date = @For_date AND Cmp_ID = @Cmp_ID AND Emp_ID = @Emp_Id
						END
					ELSE
						BEGIN	
									
								insert T0140_LEAVE_TRANSACTION(emp_id,Leave_Id,Cmp_ID,For_Date,Leave_Opening,Leave_Credit,
								Leave_Closing,Leave_Used,Leave_Tran_ID,Comoff_Flag,CompOff_Credit,CompOff_Balance)
								values(@emp_id,@leave_Id,@Cmp_ID,@for_Date,0,0
								,0,0,@Leave_Tran_ID,1,@CF_Leave_Days,@CF_Leave_Days)												    			
						END
				END
		END
