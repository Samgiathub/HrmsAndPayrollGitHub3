CREATE TABLE [dbo].[T0190_Emp_Arrear_Detail] (
    [Arrear_ID]         NUMERIC (18)    NOT NULL,
    [Cmp_ID]            NUMERIC (18)    NOT NULL,
    [Emp_ID]            NUMERIC (18)    NOT NULL,
    [For_Month]         NUMERIC (18)    NOT NULL,
    [For_Year]          NUMERIC (18)    NOT NULL,
    [Days]              NUMERIC (18, 2) CONSTRAINT [DF_T0190_Emp_Arrear_Detail_Days] DEFAULT ((0)) NOT NULL,
    [Leave_Adjustment]  TINYINT         NULL,
    [Effective_Month]   NUMERIC (18)    NULL,
    [Effective_Year]    NUMERIC (18)    NULL,
    [Is_Absent]         TINYINT         NULL,
    [Adjust_With_Leave] NUMERIC (18)    NULL,
    [Remarks]           NVARCHAR (100)  NULL,
    CONSTRAINT [PK_T0190_Emp_Arrear_Detail_1] PRIMARY KEY CLUSTERED ([Arrear_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0190_Emp_Arrear_Detail_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0190_Emp_Arrear_Detail_T0080_EMP_MASTER] FOREIGN KEY ([Emp_ID]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID])
);


GO
CREATE NONCLUSTERED INDEX [IX_T0190_Emp_Arrear_Detail]
    ON [dbo].[T0190_Emp_Arrear_Detail]([Arrear_ID] ASC) WITH (FILLFACTOR = 80);


GO



-- =============================================
-- Author:		<Hiral>
-- ALTER date: <23 May, 2013>
-- Description:	<Description,,>
-- =============================================
CREATE TRIGGER [DBO].[tr_T0190_Emp_Arrear_Delete]
   ON  [dbo].[T0190_Emp_Arrear_Detail]
   FOR DELETE
AS 
BEGIN
	SET NOCOUNT ON;
	DECLARE @Cmp_ID				AS NUMERIC(18,0)
	DECLARE @Days				AS NUMERIC(18,2)
	DECLARE @Emp_ID				AS NUMERIC(18,0)
	DECLARE @For_Month			AS NUMERIC(18,0)
	DECLARE @For_Year			AS NUMERIC(18,0)
	DECLARE @Leave_Adjustment	AS TINYINT
	DECLARE @Effective_Month	AS NUMERIC(18,0)
	DECLARE @Effective_Year		AS NUMERIC(18,0)
	DECLARE @Is_Absent			AS TINYINT
	DECLARE @Leave_ID			AS NUMERIC(18,0)
	
	SELECT @Cmp_ID = Cmp_ID, @Days = Days, @Emp_ID = Emp_ID, @Leave_ID = Adjust_With_Leave, @For_Month = For_Month, 
			 @For_Year = For_Year, @Leave_Adjustment = Leave_Adjustment,
			 @Effective_Month = Effective_Month, @Effective_Year = Effective_Year, @Is_Absent = Is_Absent
		FROM deleted  
	
	-- ===== T0190_Monthly_Present_Import(Start) ===== --
	IF isnull(@Leave_Adjustment,0) = 0
		Begin
			DECLARE @Pre_Days AS NUMERIC(18,2)
			DECLARE @Cum_Days AS NUMERIC(18,2)
			
			set @Pre_Days = 0
			set @Cum_Days = 0			
			
			DECLARE Cur_Arrear_Days CURSOR 
			FOR SELECT Days FROM T0190_Emp_Arrear_Detail WHERE Emp_Id = @Emp_ID  
				AND Effective_Month = @Effective_Month AND Effective_Year = @Effective_Year
			OPEN Cur_Arrear_Days
			FETCH NEXT FROM Cur_Arrear_Days INTO @Pre_Days
			WHILE @@FETCH_STATUS = 0
				BEGIN
					SET @Cum_Days = @Cum_Days + @Pre_Days
					FETCH NEXT FROM Cur_Arrear_Days INTO @Pre_Days
				END
			CLOSE Cur_Arrear_Days
			DEALLOCATE Cur_Arrear_Days

			IF EXISTS (SELECT Tran_ID FROM T0190_Monthly_Present_Import WHERE Emp_ID = @Emp_ID AND 
					MONTH = @Effective_Month AND YEAR = @Effective_Year)
				BEGIN
					UPDATE T0190_Monthly_Present_Import
						SET Extra_Days = @Cum_Days
						WHERE Emp_ID = @Emp_ID AND MONTH = @Effective_Month AND YEAR = @Effective_Year
				END
		End
	-- ===== T0190_Monthly_Present_Import(End) ===== --	
	
	
	-- ====================================================================================== --	
	-- ===== T0140_LEAVE_TRANSACTION (Start) ===== --
	IF isnull(@Is_Absent,0) = 0
		Begin
			DECLARE @Leave_Closing AS NUMERIC(18,2)
			DECLARE @Chg_Tran_Id NUMERIC
			DECLARE @For_Date_Cur DATETIME
			DECLARE @Leave_Posting NUMERIC(18,2)
			DECLARE @Month_Last_Date DATETIME
			DECLARE @Leave_Opening AS NUMERIC(18,2)
					
			SET @Month_Last_Date = DATEADD(DAY,-1,DATEADD(MONTH,@For_Month,DATEADD(YEAR,@For_Year-1900,0)))
					
			IF EXISTS (SELECT Leave_Tran_ID FROM T0140_LEAVE_TRANSACTION WHERE Emp_ID = @Emp_ID AND Leave_ID = @Leave_ID 
					AND For_Date = @Month_Last_Date  AND Arrear_Used <> 0)
				BEGIN
				
					SELECT @Leave_Closing = ISNULL(Leave_Opening,0) + ISNULL(Leave_Credit,0) - ISNULL(Leave_Used,0) 
						FROM T0140_LEAVE_TRANSACTION WHERE Emp_ID = @Emp_ID AND Leave_ID = @Leave_ID 
						AND For_Date = @Month_Last_Date  AND Arrear_Used <> 0
					
					UPDATE T0140_LEAVE_TRANSACTION 
						SET Leave_Closing = @Leave_Closing,
							Arrear_Used = ISNULL(Arrear_Used,0) - ABS(@Days)
						WHERE Emp_ID = @Emp_ID AND Leave_ID = @Leave_ID 
							AND For_Date = @Month_Last_Date  AND Arrear_Used <> 0					
					
					DECLARE cur1 CURSOR FOR 
						SELECT leave_tran_id,For_Date FROM dbo.T0140_LEAVE_TRANSACTION WHERE leave_id = @leave_Id AND emp_id = @emp_id 
						AND Cmp_ID = @Cmp_ID AND for_date > @Month_Last_Date ORDER BY for_date
					OPEN cur1
					FETCH NEXT FROM cur1 INTO @Chg_Tran_Id,@For_Date_Cur
					WHILE @@FETCH_STATUS = 0
					BEGIN
						
						IF EXISTS(SELECT Leave_Op_Id FROM T0095_LEAVE_OPENING WHERE Cmp_ID = @Cmp_ID AND Emp_Id = @Emp_Id AND Leave_ID = @Leave_Id AND For_Date = @For_Date_Cur AND Leave_Op_Days > 0)
							BEGIN
								GOTO E;
							END
						SELECT @Leave_Posting = ISNULL(Leave_Posting,0) FROM dbo.T0140_LEAVE_TRANSACTION WHERE leave_tran_id = @Chg_Tran_Id
									BEGIN
										UPDATE dbo.T0140_LEAVE_TRANSACTION SET 
										  Leave_Opening = @Leave_Closing,
										  Leave_Closing = @Leave_Closing + ISNULL(Leave_Credit,0) - ISNULL(Leave_Used,0) - ISNULL(Arrear_Used, 0)
										 WHERE leave_tran_id = @Chg_Tran_Id
								E:		
										SET @Leave_Closing = ISNULL((SELECT ISNULL(Leave_Closing,0) FROM dbo.T0140_LEAVE_TRANSACTION WHERE leave_tran_id = @Chg_Tran_Id),0)
									END
						
						FETCH NEXT FROM cur1 INTO @Chg_Tran_Id,@For_Date_Cur
					END			
					CLOSE cur1
					DEALLOCATE cur1		
				END
		End
		
	-- ===== T0140_LEAVE_TRANSACTION (End) ===== --
END



GO



-- =============================================
-- Author:		<Hiral>
-- ALTER date: <21 May, 2013>
-- Description:	<>
-- =============================================
--select * from T0190_Emp_Arrear_Detail  order by for_month,for_year
--select * from t0190_monthly_present_import
--select * from t0140_leave_transaction

CREATE TRIGGER [DBO].[tr_T0190_Emp_Arrear_Insert] 
   ON  [dbo].[T0190_Emp_Arrear_Detail]
   FOR INSERT
AS 
BEGIN
	SET NOCOUNT ON;
	DECLARE @Cmp_ID				AS NUMERIC(18,0)
	DECLARE @Days				AS NUMERIC(18,2)
	DECLARE @Emp_ID				AS NUMERIC(18,0)
	DECLARE @For_Month			AS NUMERIC(18,0)
	DECLARE @For_Year			AS NUMERIC(18,0)
	DECLARE @Leave_Adjustment	AS TINYINT
	DECLARE @Effective_Month	AS NUMERIC(18,0)
	DECLARE @Effective_Year		AS NUMERIC(18,0)
	DECLARE @Is_Absent			AS TINYINT
	DECLARE @Leave_ID			AS NUMERIC(18,0)
	
	SELECT @Cmp_ID = Cmp_ID, @Days = Days, @Emp_ID = Emp_ID, @Leave_ID = Adjust_With_Leave, @For_Month = For_Month, 
			 @For_Year = For_Year, @Leave_Adjustment = Leave_Adjustment, 
			 @Effective_Month = Effective_Month, @Effective_Year = Effective_Year, @Is_Absent = Is_Absent
		FROM inserted ins 
	
	-- ===== T0190_Monthly_Present_Import(Start) ===== --	
	IF isnull(@Leave_Adjustment,0) = 0
		BEGIN
			DECLARE @Pre_Days AS NUMERIC(18,2) 
			DECLARE @Cum_Days AS NUMERIC(18,2) 
			
			set @Cum_Days = 0
			set @Pre_Days = 0
			
			DECLARE Cur_Arrear_Days CURSOR
			FOR SELECT Days FROM T0190_Emp_Arrear_Detail WHERE Emp_Id = @Emp_ID 
				AND Effective_Month = @Effective_Month AND Effective_Year = @Effective_Year
			OPEN Cur_Arrear_Days
			FETCH NEXT FROM Cur_Arrear_Days INTO @Pre_Days
			WHILE @@FETCH_STATUS = 0
				BEGIN
					SET @Cum_Days = @Cum_Days + @Pre_Days
					--fetch max for month
					FETCH NEXT FROM Cur_Arrear_Days INTO @Pre_Days					
				END
			CLOSE Cur_Arrear_Days
			DEALLOCATE Cur_Arrear_Days
			
			IF NOT EXISTS (SELECT Tran_ID FROM T0190_Monthly_Present_Import WHERE Emp_ID = @Emp_ID AND 
					MONTH = @Effective_Month AND YEAR = @Effective_Year)
				BEGIN
					DECLARE @Tran_ID AS NUMERIC(18,0)
					
					SELECT @Tran_ID = ISNULL(MAX(Tran_ID),0) + 1 FROM T0190_Monthly_Present_Import
					
					INSERT INTO T0190_Monthly_Present_Import
						(Tran_ID, Emp_ID, Cmp_ID, MONTH, YEAR, For_Date, P_Days, Extra_Days, Extra_Day_Month, 
						 Extra_Day_Year, Cancel_Weekoff_Day, Cancel_Holiday, Over_Time)
						VALUES(@Tran_ID, @Emp_ID, @Cmp_ID,@Effective_Month ,@Effective_Year , GETDATE(), 0, @Cum_Days,
						 @For_Month, @For_Year, 0, 0, 0)
				END
			ELSE
				BEGIN
					UPDATE T0190_Monthly_Present_Import
						SET Extra_Days = @Cum_Days
						WHERE Emp_ID = @Emp_ID AND MONTH = @Effective_Month AND YEAR = @Effective_Year
				END	
		END
	-- ===== T0190_Monthly_Present_Import(End) ===== --	
	
	
	-- ====================================================================================== --	
	-- ===== T0140_LEAVE_TRANSACTION (Start) ===== --

	IF isnull(@Is_Absent,0) = 0
		BEGIN
			DECLARE @Leave_Tran_ID AS NUMERIC(18,0)
			DECLARE @For_Date AS DATETIME
			DECLARE @Month_Last_Date AS DATETIME
			DECLARE @Last_Leave_Closing AS NUMERIC(18,2)
			DECLARE @Pre_Closing AS NUMERIC(18,2)
			DECLARE @Chg_Tran_Id NUMERIC
			DECLARE @For_Date_Cur DATETIME
			DECLARE @Leave_Posting NUMERIC(18,2)
			
			SELECT @Leave_Tran_ID = ISNULL(MAX(Leave_Tran_ID),0) + 1 FROM T0140_LEAVE_TRANSACTION
			SET @Month_Last_Date = DATEADD(DAY,-1,DATEADD(MONTH,@For_Month,DATEADD(YEAR,@For_Year-1900,0)))
			
			SELECT @Last_Leave_Closing = ISNULL(Leave_Closing,0) 
				FROM T0140_LEAVE_TRANSACTION
				WHERE For_Date = (SELECT MAX(For_Date) FROM T0140_LEAVE_TRANSACTION 
										WHERE For_Date < @Month_Last_Date
											AND leave_Id = @leave_id AND Cmp_ID = @Cmp_ID AND emp_Id = @emp_Id) 
					AND Cmp_ID = @Cmp_ID AND Leave_id = @Leave_ID AND Emp_Id = @emp_Id
			
			IF @Last_Leave_Closing IS NULL 
				SET  @Last_Leave_Closing = 0
				
			IF EXISTS(SELECT Leave_Tran_ID FROM T0140_LEAVE_TRANSACTION 
						WHERE Cmp_ID = @Cmp_ID AND For_Date = @Month_Last_Date AND Emp_Id = @Emp_ID
							AND Leave_Id = @Leave_ID )
				BEGIN
					UPDATE T0140_LEAVE_TRANSACTION
						SET Arrear_Used = ISNULL(Arrear_Used,0) + ABS(@Days),
							Leave_Closing = Leave_Closing - ABS(@Days)
						WHERE Cmp_ID = @Cmp_ID AND For_Date = @Month_Last_Date AND Emp_Id = @Emp_ID
							AND Leave_Id = @Leave_ID
				END
			ELSE
				BEGIN
					INSERT INTO T0140_LEAVE_TRANSACTION
						(Leave_Tran_ID, Cmp_ID, Leave_ID, Emp_ID, For_Date, Leave_Opening, Leave_Credit, Leave_Used, 
						 Leave_Closing, Leave_Encash_Days, Comoff_Flag, Arrear_Used)
						VALUES(@Leave_Tran_ID, @Cmp_ID, @Leave_ID, @Emp_ID, @Month_Last_Date, @Last_Leave_Closing, 0, 0,
						 @Last_Leave_Closing - ABS(@Days), 0, 0, ABS(@Days))
				END			 
				
				 
			SET @For_Date= @Month_Last_Date
			
			
			SELECT @Pre_Closing = ISNULL(Leave_Closing,0) FROM T0140_LEAVE_TRANSACTION
				WHERE for_date = (SELECT MAX(for_date) FROM T0140_LEAVE_TRANSACTION WHERE for_date <= @For_date
								AND leave_Id = @leave_id AND Cmp_ID = @Cmp_ID AND emp_Id = @emp_Id) 
					AND Cmp_ID = @Cmp_ID
					AND leave_id = @leave_Id AND emp_Id = @emp_Id
			
			IF @Pre_Closing IS NULL
				SET @Pre_Closing = 0

			DECLARE cur1 CURSOR FOR 
				SELECT leave_tran_id,For_Date FROM dbo.T0140_LEAVE_TRANSACTION WHERE leave_id = @leave_Id AND emp_id = @emp_id 
				AND Cmp_ID = @Cmp_ID AND for_date > @For_date ORDER BY for_date
			OPEN cur1
			FETCH NEXT FROM cur1 INTO @Chg_Tran_Id,@For_Date_Cur
			WHILE @@FETCH_STATUS = 0
			BEGIN
				
				IF EXISTS(SELECT Leave_Op_Id FROM T0095_LEAVE_OPENING WHERE Cmp_ID = @Cmp_ID AND Emp_Id = @Emp_Id AND Leave_ID = @Leave_Id AND For_Date = @For_Date_Cur AND Leave_Op_Days > 0)
					BEGIN
						GOTO E;
					END
				SELECT @Leave_Posting = ISNULL(Leave_Posting,0) FROM dbo.T0140_LEAVE_TRANSACTION WHERE leave_tran_id = @Chg_Tran_Id
				
				
							BEGIN
								UPDATE dbo.T0140_LEAVE_TRANSACTION SET 
								  Leave_Opening = @Pre_Closing,
								  Leave_Closing = @Pre_Closing + ISNULL(Leave_Credit,0) - ISNULL(Leave_Used,0) - ISNULL(Arrear_Used,0)
								 WHERE leave_tran_id = @Chg_Tran_Id
						E:		
								SET @Pre_Closing = ISNULL((SELECT ISNULL(Leave_Closing,0) FROM dbo.T0140_LEAVE_TRANSACTION WHERE leave_tran_id = @Chg_Tran_Id),0)
							END
				
				FETCH NEXT FROM cur1 INTO @Chg_Tran_Id,@For_Date_Cur
			END
			
			CLOSE cur1
			DEALLOCATE cur1	
		END	
	-- ===== T0140_LEAVE_TRANSACTION (End) ===== --								
END


