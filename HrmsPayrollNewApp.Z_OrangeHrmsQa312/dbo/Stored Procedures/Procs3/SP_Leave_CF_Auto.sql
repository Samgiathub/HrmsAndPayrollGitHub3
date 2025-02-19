

---25/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_Leave_CF_Auto]
	@Cmp_Id Numeric,
	@Leave_Id Numeric
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


	DECLARE @From_Date datetime
	DECLARE @To_Date datetime
	DECLARE @Current_Date datetime

	SET @Current_Date = CONVERT(DATETIME, CONVERT(CHAR(10), GETDATE(), 103), 103)
	--set @Current_Date = '2018-04-01'
	SET @From_Date = dbo.GET_MONTH_ST_DATE(month(@Current_Date),YEAR(@Current_Date))
	SET @To_Date = dbo.GET_MONTH_END_DATE(month(@Current_Date),YEAR(@Current_Date))
	--SET @Current_Date = CONVERT(DATETIME, CONVERT(CHAR(10), GETDATE(), 103), 103)

	DECLARE @EMP_ID NUMERIC
	SET @EMP_ID = 0
	IF OBJECT_ID('tempdb..#tmpCF') IS NOT NULL	/*Create this temp table before executing this procedure*/
		SELECT @EMP_ID = ID FROM #tmpCF /*For Testing Only Added By Nimesh*/		
	
	
	CREATE table #CF_Detail
	(
		LEAVE_CF_ID numeric,
		Cmp_ID numeric,
		Emp_ID numeric,
		Leave_ID numeric,
		CF_For_Date datetime,
		CF_From_Date datetime,
		CF_To_Date datetime,
		CF_P_Days numeric(18,2),
		CF_Leave_Days numeric(18,2),
		CF_Type varchar(100),
		Exceed_CF_Days numeric(18,2),
		Leave_CompOff_Dates varchar(250),
		Is_Fnf numeric,
		Alpha_Emp_Code varchar(100),
		Emp_Full_Name varchar(500),
		Leave_Name varchar(500),
		new_join_flag bit,
		date_of_join datetime,
		diff numeric,
		Advance_leave_Balance numeric(18,2),
		Advance_Leave_Recover_balance numeric(18,2),
		Is_Advance_Leave_Balance numeric(18,2)
	)


	DECLARE @LEAVE_CF_ID As Numeric
	DECLARE @CF_P_Days As numeric(18,2)
	DECLARE @CF_Leave_Days As numeric(18,2)
	DECLARE @CF_Type as varchar(100)
	DECLARE @Leave_CompOff_Dates varchar(500)
	DECLARE @Advance_Leave_Balance numeric(18,2)
	DECLARE @Advance_Leave_Recover_balance numeric(18,2)
	DEclare	@New_Joing_Falg bit
	DECLARE @new_join_flag bit


	DECLARE CF_Leave cursor fast_forward For
	SELECT	DISTINCT LM.Leave_ID,LM.Cmp_ID 
	FROM	T0040_LEAVE_MASTER LM WITH (NOLOCK)			
	WHERE	LM.Cmp_ID=@Cmp_ID AND LM.Leave_ID=@Leave_Id 

	OPEN CF_Leave
	FETCH next from CF_Leave INTO @Leave_Id,@Cmp_Id
	WHILE @@FETCH_STATUS =0
		Begin
		
		
			insert INTO #CF_Detail	
			exec SP_LEAVE_CF_Display @leave_Cf_ID=0,@Cmp_ID=@Cmp_Id,@From_Date=@From_Date,@To_Date=@To_Date,
			@For_Date=@Current_Date,@Branch_ID=0,@Cat_ID=0,@Grd_ID=0,@Type_ID=0,@Dept_ID=0,@Desig_ID=0,@Emp_ID = @EMP_ID,
			@Constraint='',@P_LeavE_ID=@Leave_Id,@Segment_ID =0,@subBranch_ID =0,@Vertical_ID =0,@SubVertical_ID =0
		
		
	
			FETCH next from CF_Leave INTO @Leave_Id,@Cmp_Id
		END
	CLOSE CF_Leave
	DEALLOCATE CF_Leave		
	
	

	delete from #CF_Detail where CF_Leave_Days=0 AND Advance_leave_Balance = 0

	DECLARE @CF_TO_DATE DATETIME
	DECLARE @CF_For_Date DATETIME
	DECLARE @CF_FROM_DATE DATETIME
	DECLARE @CF_MODE VARCHAR(16)

	DECLARE Emp_CF_Leave cursor fast_forward For
	select LEAVE_CF_ID,Leave_ID,Cmp_ID,Emp_ID,CF_For_Date,CF_From_Date,CF_To_Date,CF_P_Days,CF_Leave_Days,CF_Type,Leave_CompOff_Dates,
		Advance_leave_Balance,Advance_Leave_Recover_balance,new_join_flag
	FROM #CF_Detail  ORDER BY Emp_ID 

	OPEN Emp_CF_Leave
	FETCH next from Emp_CF_Leave INTO @LEAVE_CF_ID,@Leave_Id,@Cmp_Id,@Emp_Id,@CF_For_Date,@CF_FROM_DATE,@CF_TO_DATE,@CF_P_Days,@CF_Leave_Days,@CF_Type,@Leave_CompOff_Dates,
					@Advance_leave_Balance,@Advance_Leave_Recover_balance,@new_join_flag
	WHILE @@FETCH_STATUS =0
		Begin				
			--SET @CF_TO_DATE = @Current_Date-1;
			
			EXEC P0100_LEAVE_CF_DETAIL @Leave_CF_ID=@Leave_CF_ID output,@Cmp_ID=@Cmp_Id,@Emp_ID=@Emp_Id,@Leave_ID=@Leave_Id,
					@CF_For_Date=@CF_For_Date,@CF_From_Date=@CF_FROM_DATE,@CF_To_Date=@CF_TO_DATE,
					@CF_P_Days=@CF_P_Days,@CF_Leave_Days=@CF_Leave_Days,@CF_Type=@CF_Type,@tran_type='Insert',@Leave_CompOff_Dates=@Leave_CompOff_Dates,
					@Reset_Flag='1',@Advance_Leave_Balance=@Advance_leave_Balance,
					@Advance_Leave_Recover_Balance=@Advance_Leave_Recover_balance,@New_Joing_Falg=@new_join_flag

			UPDATE T0100_LEAVE_CF_DETAIL SET CF_For_Date=@CF_For_Date WHERE LEAVE_CF_ID=@Leave_CF_ID
			
	
			FETCH next from Emp_CF_Leave INTO @LEAVE_CF_ID,@Leave_Id,@Cmp_Id,@Emp_Id,@CF_For_Date,@CF_FROM_DATE,@CF_TO_DATE,@CF_P_Days,@CF_Leave_Days,@CF_Type,@Leave_CompOff_Dates,
					@Advance_leave_Balance,@Advance_Leave_Recover_balance,@new_join_flag
		END
	CLOSE Emp_CF_Leave
	DEALLOCATE Emp_CF_Leave		
		
	--select * from #CF_Detail
	--SELECT * FROM T0100_LEAVE_CF_DETAIL where Emp_ID=17209


END
