
-- =============================================
-- Author:		<Gadriwala Muslim >
-- Create date: <09102014>
-- Description:	<OT LEVEL APPROVAL >
---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0115_OT_LEVEL_APPROVAL] @Tran_ID NUMERIC OUTPUT
	,@Emp_ID NUMERIC
	,@Cmp_ID NUMERIC
	,@For_Date DATETIME
	,@working_sec VARCHAR(10)
	,@OT_Sec VARCHAR(10)
	,@Approve_OT_Sec VARCHAR(10)
	,@Comments VARCHAR(1000)
	,@Is_Approve NUMERIC
	,@P_Days_Count DECIMAL
	,@Flag INT
	,@System_Date DATETIME
	,@Login_ID NUMERIC
	,@Tran_Type VARCHAR(1)
	,@Is_Month_Wise TINYINT = 0
	,@Weekoff_OT_Sec VARCHAR(10)
	,@Approve_WO_OT_Sec VARCHAR(10)
	,@Holiday_OT_Sec VARCHAR(10)
	,@Approve_HO_OT_Sec VARCHAR(10)
	,@User_Id NUMERIC(18, 0) = 0
	,@IP_Address VARCHAR(30) = ''
	,@Remark VARCHAR(max) = ''
	,@S_Emp_ID NUMERIC(18, 0)
	,@Rpt_Level TINYINT
	,@Final_Approver TINYINT
	,@is_Fwd_OT_Rej TINYINT
AS
BEGIN
	SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON

	DECLARE @working_Sec_Num AS NUMERIC(18, 2)
	DECLARE @OT_Sec_Num AS NUMERIC(18, 2)
	DECLARE @Approve_OT_Sec_Num AS NUMERIC(18, 2)
	DECLARE @Approved_Ot_Sec_New AS NUMERIC(18, 0)
	DECLARE @Weekoff_OT_Sec_Num AS NUMERIC(18, 2)
	DECLARE @Approve_WO_OT_Sec_Num AS NUMERIC(18, 2)
	DECLARE @Approved_WO_Ot_Sec_New AS NUMERIC(18, 0)
	DECLARE @Holiday_OT_Sec_Num AS NUMERIC(18, 2)
	DECLARE @Approve_HO_OT_Sec_Num AS NUMERIC(18, 2)
	DECLARE @Approved_HO_Ot_Sec_New AS NUMERIC(18, 0)
	DECLARE @working_Sec_Var AS VARCHAR(10)
	DECLARE @OT_Sec_Var AS VARCHAR(10)
	DECLARE @Approve_OT_Sec_Var AS VARCHAR(10)
	DECLARE @Weekoff_OT_Sec_Var AS VARCHAR(10)
	DECLARE @Approve_WO_OT_Sec_Var AS VARCHAR(10)
	DECLARE @Holiday_OT_Sec_Var AS VARCHAR(10)
	DECLARE @Approve_HO_OT_Sec_Var AS VARCHAR(10)

	SET @working_Sec_Num = (dbo.F_Return_Sec(@working_sec))
	SET @OT_Sec_Num = (dbo.F_Return_Sec(@OT_Sec))

	IF @Approve_OT_Sec = '00:00'
		SET @Approve_OT_Sec = '0:00'
	SET @Approve_OT_Sec_Num = (dbo.F_Return_Sec(@Approve_OT_Sec))
	SET @Approved_Ot_Sec_New = (dbo.F_Return_Sec(@Approve_OT_Sec))
	SET @Weekoff_OT_Sec_Num = (dbo.F_Return_Sec(@Weekoff_OT_Sec))
	SET @Approve_WO_OT_Sec_Num = (dbo.F_Return_Sec(@Approve_WO_OT_Sec))
	SET @Approved_WO_Ot_Sec_New = (dbo.F_Return_Sec(@Approve_WO_OT_Sec))
	SET @Holiday_OT_Sec_Num = (dbo.F_Return_Sec(@Holiday_OT_Sec))
	SET @Approve_HO_OT_Sec_Num = (dbo.F_Return_Sec(@Approve_HO_OT_Sec))
	SET @Approved_HO_Ot_Sec_New = (dbo.F_Return_Sec(@Approve_HO_OT_Sec))
	SET @working_Sec_Var = dbo.F_Return_Hours(@working_Sec_Num)
	SET @OT_Sec_Var = dbo.F_Return_Hours(@OT_Sec_Num)
	SET @Approve_OT_Sec_Var = dbo.F_Return_Hours(@Approve_OT_Sec_Num)
	SET @Weekoff_OT_Sec_Var = dbo.F_Return_Hours(@Weekoff_OT_Sec_Num)
	SET @Approve_WO_OT_Sec_Var = dbo.F_Return_Hours(@Approve_WO_OT_Sec_Num)
	SET @Holiday_OT_Sec_Var = dbo.F_Return_Hours(@Holiday_OT_Sec_Num)
	SET @Approve_HO_OT_Sec_Var = dbo.F_Return_Hours(@Approve_HO_OT_Sec_Num)
	SET @working_Sec_Var = Replace(@working_Sec_Var, ':', '.')
	SET @OT_Sec_Var = Replace(@OT_Sec_Var, ':', '.')
	SET @Approve_OT_Sec_Var = Replace(@Approve_OT_Sec_Var, ':', '.')
	SET @Weekoff_OT_Sec_Var = Replace(@Weekoff_OT_Sec_Var, ':', '.')
	SET @Approve_WO_OT_Sec_Var = Replace(@Approve_WO_OT_Sec_Var, ':', '.')
	SET @Holiday_OT_Sec_Var = Replace(@Holiday_OT_Sec_Var, ':', '.')
	SET @Approve_HO_OT_Sec_Var = Replace(@Approve_HO_OT_Sec_Var, ':', '.')
	SET @working_Sec_Num = Convert(NUMERIC(18, 2), @working_Sec_Var)
	SET @OT_Sec_Num = Convert(NUMERIC(18, 2), @OT_Sec_Var)
	SET @Approve_OT_Sec_Num = Convert(NUMERIC(18, 2), @Approve_OT_Sec_Var)
	SET @Weekoff_OT_Sec_Num = Convert(NUMERIC(18, 2), @Weekoff_OT_Sec_Var)
	SET @Approve_WO_OT_Sec_Num = Convert(NUMERIC(18, 2), @Approve_WO_OT_Sec_Var)
	SET @Holiday_OT_Sec_Num = Convert(NUMERIC(18, 2), @Holiday_OT_Sec_Var)
	SET @Approve_HO_OT_Sec_Num = Convert(NUMERIC(18, 2), @Approve_HO_OT_Sec_Var)

	--Added by Jaina 07-09-2017
	DECLARE @After_Salary AS TINYINT = 0

	SELECT @After_Salary = Setting_Value
	FROM T0040_SETTING WITH (NOLOCK)
	WHERE Setting_Name = 'After Salary Overtime Payment Process'
		AND Cmp_ID = @Cmp_ID

	IF @Flag = 1
	BEGIN
		SET @Approve_OT_Sec_Num = @Approve_OT_Sec_Num * - 1 ---for negative Ot
		SET @Approved_Ot_Sec_New = @Approved_Ot_Sec_New * - 1
		SET @Approve_WO_OT_Sec_Num = @Approve_WO_OT_Sec_Num * - 1 ---for negative Ot
		SET @Approved_WO_Ot_Sec_New = @Approved_WO_Ot_Sec_New * - 1
		SET @Approve_HO_OT_Sec_Num = @Approve_HO_OT_Sec_Num * - 1 ---for negative Ot
		SET @Approved_HO_Ot_Sec_New = @Approved_HO_Ot_Sec_New * - 1
	END

	IF IsNULL(@working_Sec_Num, 0) = 0 --Why i do thiss because when week off work going to transfer ot then it will not shows u working hours so whatever ot is working hour so i put this here.	
	BEGIN
		SET @working_Sec_Num = @OT_Sec_Num
	END

	DECLARE @Branch_ID AS NUMERIC
	DECLARE @Sal_St_Date AS DATETIME
	DECLARE @Sal_End_Date AS DATETIME

	SELECT @Branch_ID = Branch_ID
	FROM T0095_Increment I WITH (NOLOCK)
	INNER JOIN (
		SELECT max(Increment_Id) AS Increment_Id
			,Emp_ID
		FROM T0095_Increment WITH (NOLOCK) --Changed by Hardik 10/09/2014 for Same Date Increment
		WHERE Increment_Effective_date <= @For_Date
			AND Cmp_ID = @Cmp_ID
		GROUP BY emp_ID
		) Qry ON I.Emp_ID = Qry.Emp_ID
		AND I.Increment_Id = Qry.Increment_Id
	WHERE I.Emp_ID = @Emp_ID

	SELECT @Sal_St_Date = Sal_St_Date
	FROM T0040_GENERAL_SETTING WITH (NOLOCK)
	WHERE cmp_ID = @cmp_ID
		AND Branch_ID = @Branch_ID
		AND For_Date = (
			SELECT max(For_Date)
			FROM T0040_GENERAL_SETTING WITH (NOLOCK)
			WHERE For_Date <= @For_Date
				AND Branch_ID = @Branch_ID
				AND Cmp_ID = @Cmp_ID
			)

	IF isnull(@Sal_St_Date, '') = ''
	BEGIN
		SET @Sal_St_Date = cast('01' + '-' + cast(datename(mm, @For_Date) AS VARCHAR(10)) + '-' + cast(year(@For_Date) AS VARCHAR(10)) AS SMALLDATETIME)
		SET @Sal_End_Date = dateadd(d, - 1, dateadd(m, 1, @Sal_St_Date))
	END
	ELSE IF day(@Sal_St_Date) = 1
		AND month(@Sal_St_Date) = 1
	BEGIN
		SET @Sal_St_Date = cast(cast(day(@Sal_St_Date) AS VARCHAR(5)) + '-' + cast(datename(mm, @For_Date) AS VARCHAR(10)) + '-' + cast(year(@For_Date) AS VARCHAR(10)) AS SMALLDATETIME)
		SET @Sal_End_Date = dateadd(d, - 1, dateadd(m, 1, @Sal_St_Date))
	END
	ELSE
	BEGIN
		SET @Sal_St_Date = cast(cast(day(@Sal_St_Date) AS VARCHAR(5)) + '-' + cast(datename(mm, dateadd(m, - 1, @For_Date)) AS VARCHAR(10)) + '-' + cast(year(dateadd(m, - 1, @For_Date)) AS VARCHAR(10)) AS SMALLDATETIME)
		SET @Sal_End_Date = dateadd(d, - 1, dateadd(m, 1, @Sal_St_Date))
	END

	DECLARE @OT_Hours_limit VARCHAR(10)
	DECLARE @Approved_OT_hour numeric(18,2)
	DECLARE @Output VARCHAR(max)

	IF Upper(@Tran_Type) = 'I'
	BEGIN
		
		IF @Is_Approve = 1
		BEGIN
			SELECT @OT_Hours_limit = Setting_value
			FROM T0040_SETTING
			WHERE Cmp_ID = @Cmp_ID
				AND Setting_Name = 'Add number of Hours to restrict OT Approval'
			
			IF 	@OT_Hours_limit > 0
				SELECT @Approved_OT_hour =  Replace(dbo.f_return_HOURs(dbo.F_Get_OT_QUARTERLYHOURS_New(@Cmp_ID, @Emp_ID, @For_Date,null, 2, @Rpt_Level)),':','.')
			
			SET @Approved_OT_hour = Replace(dbo.f_return_HOURs(dbo.f_return_sec(format((CAST(@Approved_OT_hour as decimal(10,2))),'00.00'))  + dbo.f_return_sec(format((CAST(@Approve_OT_Sec_Num as decimal(10,2))),'00.00'))),':','.') 
		
		IF CAST(@Approved_OT_hour AS NUMERIC(18,2)) > CAST(@OT_Hours_limit AS NUMERIC(18,2)) and @OT_Hours_limit > 0
			BEGIN
				--select @Approved_OT_hour, @OT_Hours_limit
				DECLARE @str NVARCHAR(50) = CAST(@Emp_ID AS VARCHAR) + '-' +  Convert(varchar,@For_Date,103)
				
				INSERT INTO OT_OverLimit_Data
			EXEC SP_Get_OT_Hours_Quarterly @Cmp_ID = @cmp_ID
				,@MonthStr = @str
				,@AfterApprove =1,@salry_Cycle=2,@Rpt_level=@Rpt_Level
				--SET @Output = @Output + '#' + CAST(@Emp_ID AS VARCHAR) + '-OT_Hours_limit: ' + @OT_Hours_limit + '-Approved_OT_hour:' + @Approved_OT_hour
				SET @Tran_ID = 0

				RETURN
			END
		END
		
		IF @After_Salary = 0 --Added by Jaina 07-09-2017
		BEGIN
			IF EXISTS (
					SELECT Emp_id
					FROM T0200_MONTHLY_SALARY WITH (NOLOCK)
					WHERE Emp_ID = @Emp_ID
						AND Month_St_Date <= @For_Date
						AND Cutoff_Date >= @For_Date
					)
			BEGIN
				RAISERROR (
						'##Salary Exist For month##'
						,16
						,2
						)

				RETURN - 1
			END
		END

		IF EXISTS (
				SELECT 1
				FROM T0115_OT_LEVEL_APPROVAL WITH (NOLOCK)
				WHERE Emp_ID = @Emp_ID
					AND Tran_ID = @Tran_ID
					AND For_date = @For_Date
					AND S_Emp_Id = @S_Emp_ID
					AND Rpt_Level = @Rpt_Level
				)
		BEGIN
			SET @Tran_ID = 0

			SELECT @Tran_ID

			RETURN
		END
		
		SELECT @Tran_ID = Isnull(max(Tran_ID), 0) + 1
		FROM dbo.T0115_OT_LEVEL_APPROVAL WITH (NOLOCK)
		
		INSERT INTO dbo.T0115_OT_LEVEL_APPROVAL (
			Tran_ID
			,Emp_ID
			,Cmp_ID
			,For_Date
			,Working_sec
			,OT_Sec
			,Approved_OT_Sec
			,Comments
			,System_Date
			,Login_ID
			,Is_Approved
			,Approved_OT_Hours
			,P_Days_Count
			,Is_Month_Wise
			,Weekoff_OT_Sec
			,Approved_WO_OT_Sec
			,Approved_WO_OT_Hours
			,Holiday_OT_Sec
			,Approved_HO_OT_Sec
			,Approved_HO_OT_Hours
			,Remark
			,s_EMP_ID
			,RPT_Level
			,Final_Approver
			,Is_Fwd_OT_Rej
			)
		VALUES (
			@Tran_ID
			,@Emp_ID
			,@Cmp_ID
			,@For_Date
			,@Working_sec_Num
			,@OT_Sec_Num
			,@Approved_Ot_Sec_New
			,@Comments
			,@System_Date
			,@Login_ID
			,@Is_Approve
			,@Approve_OT_Sec_Num
			,@P_Days_Count
			,@Is_Month_Wise
			,@Weekoff_OT_Sec_Num
			,@Approved_WO_Ot_Sec_New
			,@Approve_WO_OT_sec_num
			,@Holiday_OT_Sec_Num
			,@Approved_HO_Ot_Sec_New
			,@Approve_HO_OT_Sec_Num
			,@Remark
			,@S_Emp_Id
			,@Rpt_Level
			,@Final_Approver
			,@Is_Fwd_OT_Rej
			)
	END

	IF Upper(@Tran_Type) = 'U'
	BEGIN
		IF @After_Salary = 0 --Added by Jaina 07-09-2017
		BEGIN
			IF EXISTS (
					SELECT Emp_id
					FROM T0200_MONTHLY_SALARY WITH (NOLOCK)
					WHERE Emp_ID = @Emp_ID
						AND Month_St_Date <= @For_Date
						AND Cutoff_Date >= @For_Date
					)
			BEGIN
				RAISERROR (
						'##Salary Exist For month##'
						,16
						,2
						)

				RETURN - 1
			END
		END

		IF NOT EXISTS (
				SELECT 1
				FROM T0115_OT_LEVEL_APPROVAL WITH (NOLOCK)
				WHERE Emp_ID = @Emp_ID
					AND Tran_ID = @Tran_ID
					AND For_date = @For_Date
					AND S_Emp_Id = @S_Emp_ID
					AND Rpt_Level = @Rpt_Level
				)
		BEGIN
			SET @Tran_ID = 0

			SELECT @Tran_ID

			RETURN
		END

		UPDATE dbo.T0115_OT_LEVEL_APPROVAL
		SET Emp_ID = @Emp_ID
			,For_Date = @For_Date
			,Working_sec = @Working_sec_Num
			,OT_Sec = @OT_Sec_Num
			,Approved_OT_Sec = @Approved_Ot_Sec_New
			,Comments = @Comments
			,System_Date = @System_Date
			,Login_ID = @Login_ID
			,Is_Approved = @Is_Approve
			,Approved_OT_Hours = @Approve_OT_Sec_Num
			,P_Days_Count = @P_Days_Count
			,Is_Month_Wise = @Is_Month_Wise
			,Weekoff_OT_Sec = @Weekoff_OT_Sec_Num
			,Approved_WO_OT_Sec = @Approved_WO_Ot_Sec_New
			,Approved_WO_OT_Hours = @Approve_WO_OT_sec_num
			,Holiday_OT_Sec = @Holiday_OT_Sec_Num
			,Approved_HO_OT_Sec = @Approved_HO_Ot_Sec_New
			,Approved_HO_OT_Hours = @Approve_HO_OT_Sec_Num
			,Remark = @Remark
			,s_EMP_ID = @S_Emp_Id
			,RPT_Level = @Rpt_Level
			,Final_Approver = @Final_Approver
			,Is_Fwd_OT_Rej = @Is_Fwd_OT_Rej
		WHERE Emp_ID = @Emp_ID
			AND Tran_ID = @Tran_ID
			AND S_Emp_Id = @S_Emp_ID
			AND Rpt_Level = @Rpt_Level
	END

	IF Upper(@Tran_Type) = 'D'
	BEGIN
		IF @After_Salary = 0 --Added by Jaina 07-09-2017
		BEGIN
			IF EXISTS (
					SELECT Emp_id
					FROM T0200_MONTHLY_SALARY WITH (NOLOCK)
					WHERE Emp_ID = @Emp_ID
						AND Month_St_Date <= @For_Date
						AND Cutoff_Date >= @For_Date
					)
			BEGIN
				RAISERROR (
						'##Salary Exist For month##'
						,16
						,2
						)

				RETURN - 1
			END
		END

		DELETE
		FROM dbo.T0115_OT_LEVEL_APPROVAL
		WHERE Tran_ID = @Tran_ID
	END
END