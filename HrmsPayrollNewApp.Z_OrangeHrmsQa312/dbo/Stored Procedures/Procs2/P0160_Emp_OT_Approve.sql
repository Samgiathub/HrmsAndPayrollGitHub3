
---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0160_Emp_OT_Approve] @Tran_ID NUMERIC OUTPUT
	,@Emp_ID NUMERIC
	,@Cmp_ID NUMERIC
	,@For_Date DATETIME
	,@working_sec VARCHAR(10)
	,@OT_Sec VARCHAR(10)
	,@Approve_OT_Sec VARCHAR(20)
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
	,@User_Id NUMERIC(18, 0) = 0 -- Added for audit trail By Ali 12102013
	,@IP_Address VARCHAR(30) = '' -- Added for audit trail By Ali 12102013
	,@Remark VARCHAR(max) = '' --Added By Gadriwala 09052014
	,@After_Salary TINYINT = 0
AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

-- Added for audit trail By Ali 12102013 -- Start
DECLARE @Old_Emp_Name AS VARCHAR(150)
DECLARE @Old_Emp_Id AS NUMERIC
DECLARE @Old_For_Date AS DATETIME
DECLARE @Old_working_sec AS VARCHAR(10)
DECLARE @Old_OT_Sec AS VARCHAR(10)
DECLARE @Old_Approve_OT_Sec AS VARCHAR(10)
DECLARE @Old_Weekoff_OT_Sec AS VARCHAR(10)
DECLARE @Old_Approve_WO_OT_Sec AS VARCHAR(10)
DECLARE @Old_Holiday_OT_Sec AS VARCHAR(10)
DECLARE @Old_Approve_HO_OT_Sec AS VARCHAR(10)
DECLARE @Old_Is_Approve NUMERIC
DECLARE @OldValue AS VARCHAR(Max)
DECLARE @Old_Comments AS VARCHAR(200)
DECLARE @Old_Remark AS VARCHAR(max) --Added By Gadriwala 09052014

SET @Old_Emp_Name = ''
SET @Old_Emp_Id = 0
SET @Old_For_Date = NULL
SET @Old_working_sec = ''
SET @Old_OT_Sec = ''
SET @Old_Approve_OT_Sec = ''
SET @Old_Weekoff_OT_Sec = ''
SET @Old_Approve_WO_OT_Sec = ''
SET @Old_Holiday_OT_Sec = ''
SET @Old_Approve_HO_OT_Sec = ''
SET @Old_Is_Approve = 0
SET @OldValue = ''
SET @Old_Comments = ''
SET @Old_Remark = '' --Added By Gadriwala 09052014
	-- Added for audit trail By Ali 12102013 -- End

---Added by ronakk 07022023 ----------
IF (
		(
			SELECT Setting_Value
			FROM T0040_SETTING
			WHERE Cmp_ID = @Cmp_ID
				AND Setting_Name = 'Overtime approval based on slab'
			) = 1
		)
BEGIN
	DECLARE @HinN NUMERIC(18, 5)
	---For Hours to Decimal Convertion -----
	WITH HRSTONO AS (
			SELECT @OT_Sec AS TIME
			)

	SELECT @HinN = CAST(LEFT(TIME, 2) AS INT) + CAST(SUBSTRING(TIME, 4, 2) AS INT) / 60.0 + CAST(SUBSTRING(TIME, 7, 2) AS INT) / (60.0 * 60.0)
	FROM HRSTONO;

	---For Hours to Decimal Convertion -----
	---------Decimal To Hours Convertion -----------------
	DECLARE @DTH DECIMAL(5, 2)
	DECLARE @BasicSal NUMERIC(18, 2)

	--set @DTH = 3.5
	SELECT @BasicSal = basic_salary
	FROM V0080_EMP_MASTER_INCREMENT_GET
	WHERE cmp_id = @Cmp_ID
		AND Emp_ID = @Emp_ID

	SELECT TOP 1 @DTH = CASE 
			WHEN @BasicSal < 25000
				THEN For_25_Below_HRS
			ELSE For_25_Above_HRS
			END
	FROM T0000_OT_HRS_CNV
	WHERE OT_Actual_HRS <= @HinN
	ORDER BY OT_Actual_HRS DESC

	SELECT @Approve_OT_Sec = cast(@DTH AS INT) + (((@DTH - cast(@DTH AS INT)) * .60))
		---------Decimal To Hours Convertion -----------------
END

--End by ronakk 07022023 -------------
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
DECLARE @working_Sec_Var AS VARCHAR(20)
DECLARE @OT_Sec_Var AS VARCHAR(20)
DECLARE @Approve_OT_Sec_Var AS VARCHAR(20)
DECLARE @Weekoff_OT_Sec_Var AS VARCHAR(20)
DECLARE @Approve_WO_OT_Sec_Var AS VARCHAR(20)
DECLARE @Holiday_OT_Sec_Var AS VARCHAR(20)
DECLARE @Approve_HO_OT_Sec_Var AS VARCHAR(20)

--First Take Hours into varchar fro formlevel
--So Convert it to second
SET @working_Sec_Num = (dbo.F_Return_Sec(@working_sec))
SET @OT_Sec_Num = (dbo.F_Return_Sec(@OT_Sec))
Set @Approve_OT_Sec_Num = (dbo.F_Return_Sec('0' + @Approve_OT_Sec))  
Set @Approved_Ot_Sec_New= (dbo.F_Return_Sec(@Approve_OT_Sec))

--SET @Approve_OT_Sec_Num = Cast(STUFF((@Approve_OT_Sec), 3, len(@Approve_OT_Sec), '') AS NUMERIC)

--SET @Approve_OT_Sec_Num = REPLACE(@Approve_OT_Sec,':','.' )
--select @Approve_OT_Sec_Num
--SET @Approved_Ot_Sec_New = Cast(STUFF((@Approve_OT_Sec), 3, len(@Approve_OT_Sec), '') AS NUMERIC)

SET @Weekoff_OT_Sec_Num = (dbo.F_Return_Sec(@Weekoff_OT_Sec))
SET @Approve_WO_OT_Sec_Num = (dbo.F_Return_Sec(@Approve_WO_OT_Sec))
SET @Approved_WO_Ot_Sec_New = (dbo.F_Return_Sec(@Approve_WO_OT_Sec))
SET @Holiday_OT_Sec_Num = (dbo.F_Return_Sec(@Holiday_OT_Sec))
SET @Approve_HO_OT_Sec_Num = (dbo.F_Return_Sec(@Approve_HO_OT_Sec))
SET @Approved_HO_Ot_Sec_New = (dbo.F_Return_Sec(@Approve_HO_OT_Sec))
--	Select @working_Sec_NUM,@OT_Sec_NUM,@Approve_OT_Sec_NUM
--After that Convert to hours
SET @working_Sec_Var = dbo.F_Return_Hours(@working_Sec_Num)
SET @OT_Sec_Var = dbo.F_Return_Hours(@OT_Sec_Num)
Set @Approve_OT_Sec_Var = dbo.F_Return_Hours (@Approve_OT_Sec_Num) 

SET @Weekoff_OT_Sec_Var = dbo.F_Return_Hours(@Weekoff_OT_Sec_Num)
SET @Approve_WO_OT_Sec_Var = dbo.F_Return_Hours(@Approve_WO_OT_Sec_Num)
SET @Holiday_OT_Sec_Var = dbo.F_Return_Hours(@Holiday_OT_Sec_Num)
SET @Approve_HO_OT_Sec_Var = dbo.F_Return_Hours(@Approve_HO_OT_Sec_Num)
--	Select @working_Sec_Var,@OT_Sec_Var,@Approve_OT_Sec_Var	
--Replace : to . because it convert to at the end in numeric
SET @working_Sec_Var = Replace(@working_Sec_Var, ':', '.')
SET @OT_Sec_Var = Replace(@OT_Sec_Var, ':', '.')
SET @Approve_OT_Sec_Var = Replace(@Approve_OT_Sec_Var, ':', '.')
SET @Weekoff_OT_Sec_Var = Replace(@Weekoff_OT_Sec_Var, ':', '.')
SET @Approve_WO_OT_Sec_Var = Replace(@Approve_WO_OT_Sec_Var, ':', '.')
SET @Holiday_OT_Sec_Var = Replace(@Holiday_OT_Sec_Var, ':', '.')
SET @Approve_HO_OT_Sec_Var = Replace(@Approve_HO_OT_Sec_Var, ':', '.')
--	Select @working_Sec_Var,@OT_Sec_Var,@Approve_OT_Sec_Var
--  At the last Convert To Numeric
SET @working_Sec_Num = Convert(NUMERIC(18, 2), @working_Sec_Var)
SET @OT_Sec_Num = Convert(NUMERIC(18, 2), @OT_Sec_Var)
SET @Approve_OT_Sec_Num = Convert(NUMERIC(18, 2), @Approve_OT_Sec_Var)
SET @Weekoff_OT_Sec_Num = Convert(NUMERIC(18, 2), @Weekoff_OT_Sec_Var)
SET @Approve_WO_OT_Sec_Num = Convert(NUMERIC(18, 2), @Approve_WO_OT_Sec_Var)
SET @Holiday_OT_Sec_Num = Convert(NUMERIC(18, 2), @Holiday_OT_Sec_Var)
SET @Approve_HO_OT_Sec_Num = Convert(NUMERIC(18, 2), @Approve_HO_OT_Sec_Var)

--Added by Jaina 08-08-2017
SELECT @After_Salary = Setting_Value
FROM T0040_SETTING WITH (NOLOCK)
WHERE Setting_Name = 'After Salary Overtime Payment Process'
	AND Cmp_ID = @Cmp_ID

---	Select @working_Sec_NUM,@OT_Sec_NUM,@Approve_OT_Sec_NUM
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
BEGIN --Nikunj 14-10-2010   
	SET @working_Sec_Num = @OT_Sec_Num
END

-- Alpesh 12-Oct-2011 --
DECLARE @Branch_ID AS NUMERIC
DECLARE @Sal_St_Date AS DATETIME
DECLARE @Sal_End_Date AS DATETIME

IF @Is_Month_Wise IS NULL
	SET @Is_Month_Wise = 0

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

IF @Is_Month_Wise = 1
BEGIN
	SET @For_Date = @Sal_End_Date
END

--- End ---
-- Added by rohit For Restrict overtime Approve when Salary Generated For that month. on 26112013
IF @Tran_Type = 'I'
	OR @Tran_Type = 'U'
BEGIN
	--if exists(select Emp_id from T0200_MONTHLY_SALARY where Emp_ID=@Emp_ID and Month_St_Date <= @For_Date and Month_End_Date >= @For_Date)-- Comment By Nilesh Patel on 16022016
	IF @After_Salary = 0 --Added by Jaina 04-08-2017
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
					'##Salary Already Exist For Same Month##'
					,16
					,2
					)

			RETURN - 1
		END
	END
END

-- Ended by rohit on 26112013
DECLARE @OT_Hours_limit VARCHAR(10)
	DECLARE @Approved_OT_hour numeric(18,2)
	DECLARE @Output VARCHAR(max)

IF @Tran_Type = 'I'
BEGIN

-- /////////////////////////////   Added BY tejas FOr Amman apollo CHM ////////////////////////////////
	IF @Is_Approve = 1
		BEGIN
			SELECT @OT_Hours_limit = Setting_value
			FROM T0040_SETTING
			WHERE Cmp_ID = @Cmp_ID
				AND Setting_Name = 'Add number of Hours to restrict OT Approval'
			IF @OT_Hours_limit > 0
			BEGIN
				SELECT @Approved_OT_hour =  Replace(dbo.f_return_HOURs(dbo.F_Get_OT_QUARTERLYHOURS_New(@Cmp_ID, @Emp_ID, @For_Date,null, 0, 0)),':','.')
				
				SET @Approved_OT_hour = Replace(dbo.f_return_HOURs(dbo.f_return_sec(format((CAST(@Approved_OT_hour as decimal(10,2))),'00.00'))  + dbo.f_return_sec(format((CAST(@Approve_OT_Sec_Num as decimal(10,2))),'00.00'))),':','.') 
		
				IF CAST(@Approved_OT_hour AS NUMERIC(18,2)) > CAST(@OT_Hours_limit AS NUMERIC(18,2))
			BEGIN
				--select @Approved_OT_hour, @OT_Hours_limit
				DECLARE @str NVARCHAR(50) = CAST(@Emp_ID AS VARCHAR) + '-' +  Convert(varchar,@For_Date,103)
				
				INSERT INTO OT_OverLimit_Data
				EXEC SP_Get_OT_Hours_Quarterly @Cmp_ID = @cmp_ID
				,@MonthStr = @str
				,@AfterApprove =1,@salry_Cycle=2,@Rpt_level=0
				--SET @Output = @Output + '#' + CAST(@Emp_ID AS VARCHAR) + '-OT_Hours_limit: ' + @OT_Hours_limit + '-Approved_OT_hour:' + @Approved_OT_hour
				SET @Tran_ID = 0

				
			END
			END
		END
		
	--///////////////////////////////////// End By Tejas  /////////////////////////////////////////////////////////
	SELECT @Tran_ID = Isnull(max(Tran_ID), 0) + 1
	FROM dbo.T0160_OT_Approval WITH (NOLOCK)
	
	IF NOT EXISTS (
			SELECT 1
			FROM dbo.T0160_OT_Approval WITH (NOLOCK)
			WHERE Emp_ID = @Emp_Id
				AND For_Date = @For_Date
			)
	BEGIN
		
		INSERT INTO dbo.T0160_OT_Approval (
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
			,Remark --Added By Gadriwala 09052014
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
			,@Remark --Added By Gadriwala 09052014
			)

		-- Added for audit trail By Ali 12102013 -- Start
		SET @Old_Emp_Name = (
				SELECT ISNULL(Alpha_Emp_Code, '') + ' - ' + ISNULL(Emp_Full_Name, '')
				FROM T0080_EMP_MASTER WITH (NOLOCK)
				WHERE Emp_ID = @Emp_ID
				)
		SET @OldValue = 'New Value' + '#' + 'Employee Name :' + ISNULL(@Old_Emp_Name, '') + '#' + 'For Date :' + cast(ISNULL(@For_Date, '') AS NVARCHAR(11)) + '#' + 'Working Hours :' + CONVERT(NVARCHAR(100), ISNULL(@working_Sec_Num, 0)) + '#' + 'OT Hours :' + CONVERT(NVARCHAR(100), ISNULL(@OT_Sec_Num, '')) + '#' + 'Approved OT :' + CONVERT(NVARCHAR(100), ISNULL(@Approve_OT_Sec_Num, 0)) + '#' + 'WO OT Hours :' + CONVERT(NVARCHAR(100), ISNULL(@Weekoff_OT_Sec_Num, 0)) + '#' + 'WO Approved OT :' + CONVERT(NVARCHAR(100), ISNULL(@Approve_WO_OT_sec_num, 0)) + '#' + 'HO OT Hours :' + CONVERT(NVARCHAR(100), ISNULL(@Holiday_OT_Sec_Num, 0)) + '#' + 'HO Approved OT :' + CONVERT(NVARCHAR(100), ISNULL(@Approve_HO_OT_Sec_Num, 0)) + '#' + 'Status :' + CASE ISNULL(@Is_Approve, 0)
				WHEN 0
					THEN 'Reject'
				ELSE 'Approve'
				END + '#' + 'Comments :' + ISNULL(@Comments, '') + '#' + 'Remark :' + ISNULL(@Remark, '')

		EXEC P9999_Audit_Trail @Cmp_ID
			,@Tran_Type
			,'OT Approval'
			,@Oldvalue
			,@Emp_ID
			,@User_Id
			,@IP_Address
			,1
			-- Added for audit trail By Ali 12102013 -- End
	END
END
ELSE IF @Tran_Type = 'U'
BEGIN
	---- Added for audit trail By Ali 12102013 -- Start
	--Select @Old_Emp_Id = Emp_ID
	--,@Old_For_Date = For_Date
	--,@Old_working_sec = Working_Sec
	--,@Old_OT_Sec = OT_Sec
	--,@Old_Approve_OT_Sec = Approved_OT_Hours
	--,@Old_Weekoff_OT_Sec = Weekoff_OT_Sec
	--,@Old_Approve_WO_OT_Sec = Approved_WO_OT_Hours
	--,@Old_Holiday_OT_Sec = Holiday_OT_Sec
	--,@Old_Approve_HO_OT_Sec = Approved_HO_OT_Hours
	--,@Old_Is_Approve = Is_Approved
	--,@Old_Comments = Comments									
	--from T0160_OT_APPROVAL
	--Where Tran_ID =  @Tran_ID
	--Set @Old_Emp_Name = (Select ISNULL(Alpha_Emp_Code,'') + ' - ' + ISNULL(Emp_Full_Name,'')   from T0080_EMP_MASTER Where Emp_ID = @Emp_ID)
	--set @OldValue = 'old Value' 
	--				+ '#' + 'Employee Name :' + ISNULL( @Old_Emp_Name,'')
	--				+ '#' + 'For Date :' + cast(ISNULL(@Old_For_Date,'') as nvarchar(11))
	--				+ '#' + 'Working Hours :' + CONVERT(nvarchar(100),ISNULL(@Old_working_sec,0))
	--				+ '#' + 'OT Hours :' + CONVERT(nvarchar(100),ISNULL(@Old_OT_Sec,''))
	--				+ '#' + 'Approved OT :' + CONVERT(nvarchar(100),ISNULL(@Old_Approve_OT_Sec,0))
	--				+ '#' + 'WO OT Hours :' + CONVERT(nvarchar(100),ISNULL(@Old_Weekoff_OT_Sec,0))
	--				+ '#' + 'WO Approved OT :' + CONVERT(nvarchar(100),ISNULL(@Old_Approve_WO_OT_Sec,0))
	--				+ '#' + 'HO OT Hours :' + CONVERT(nvarchar(100),ISNULL(@Old_Holiday_OT_Sec,0))
	--				+ '#' + 'HO Approved OT :' + CONVERT(nvarchar(100),ISNULL(@Old_Approve_HO_OT_Sec,0))
	--				+ '#' + 'Status :' + CASE ISNULL(@Old_Is_Approve,0) WHEN 0 THEN 'Reject' ELSE 'Approve' END
	--				+ '#' + 'Comments :' + ISNULL( @Old_Comments,'')
	--				+ '#' +
	--				+ 'New Value'
	--				+ '#' + 'Employee Name :' + ISNULL( @Old_Emp_Name,'')
	--				+ '#' + 'For Date :' + cast(ISNULL(@For_Date,'') as nvarchar(11))
	--				+ '#' + 'Working Hours :' + CONVERT(nvarchar(100),ISNULL(@working_Sec_Num,0))
	--				+ '#' + 'OT Hours :' + CONVERT(nvarchar(100),ISNULL(@OT_Sec_Num,''))
	--				+ '#' + 'Approved OT :' + CONVERT(nvarchar(100),ISNULL(@Approve_OT_Sec_Num,0))
	--				+ '#' + 'WO OT Hours :' + CONVERT(nvarchar(100),ISNULL(@Weekoff_OT_Sec_Num,0))
	--				+ '#' + 'WO Approved OT :' + CONVERT(nvarchar(100),ISNULL(@Approved_WO_Ot_Sec_New,0))
	--				+ '#' + 'HO OT Hours :' + CONVERT(nvarchar(100),ISNULL(@Holiday_OT_Sec_Num,0))
	--				+ '#' + 'HO Approved OT :' + CONVERT(nvarchar(100),ISNULL(@Approved_HO_Ot_Sec_New,0))
	--				+ '#' + 'Status :' + CASE ISNULL(@Is_Approve,0) WHEN 0 THEN 'Reject' ELSE 'Approve' END
	--				+ '#' + 'Comments :' + ISNULL( @Comments,'')
	--exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'OT Approval',@Oldvalue,@Emp_ID,@User_Id,@IP_Address,1
	---- Added for audit trail By Ali 12102013 -- End
	UPDATE dbo.T0160_OT_Approval
	SET Emp_ID = @Emp_ID
		,Cmp_ID = @Cmp_ID
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
		,Remark = @Remark -- Added by Gadriwala 09052014
	WHERE Tran_ID = @Tran_ID
		AND Emp_Id = @Emp_Id
END
ELSE IF @Tran_Type = 'D'
BEGIN
	-- Added for audit trail By Ali 12102013 -- Start
	SELECT @Old_Emp_Id = Emp_ID
		,@Old_For_Date = For_Date
		,@Old_working_sec = Working_Sec
		,@Old_OT_Sec = OT_Sec
		,@Old_Approve_OT_Sec = Approved_OT_Hours
		,@Old_Weekoff_OT_Sec = Weekoff_OT_Sec
		,@Old_Approve_WO_OT_Sec = Approved_WO_OT_Hours
		,@Old_Holiday_OT_Sec = Holiday_OT_Sec
		,@Old_Approve_HO_OT_Sec = Approved_HO_OT_Hours
		,@Old_Is_Approve = Is_Approved
		,@Old_Comments = Comments
		,@Old_Remark = Remark -- Added by Gadriwala 09052014											
	FROM T0160_OT_APPROVAL WITH (NOLOCK)
	WHERE Tran_ID = @Tran_ID

	-- Added by rohit For Restrict overtime Approve when Salary Generated For that month. on 26112013
	-- if exists(select Emp_id from T0200_MONTHLY_SALARY where Emp_ID=@Old_Emp_Id and Month_St_Date <= @Old_For_Date and Month_End_Date >= @Old_For_Date) --Comment by nilesh patel on 16022016
	IF @After_Salary = 0 --Added by Jaina 07-09-2017
	BEGIN
		IF EXISTS (
				SELECT Emp_id
				FROM T0200_MONTHLY_SALARY WITH (NOLOCK)
				WHERE Emp_ID = @Old_Emp_Id
					AND Month_St_Date <= @Old_For_Date
					AND Cutoff_Date >= @Old_For_Date
				) -- Added Cutoff Date by Nilesh Patel on 16022016
		BEGIN
			RAISERROR (
					'##Salary Already Exist For Same Month##'
					,16
					,2
					)

			RETURN - 1
		END
	END

	--Added by Jaina 16-09-2017
	IF EXISTS (
			SELECT 1
			FROM T0210_ESIC_On_Not_Effect_on_Salary WITH (NOLOCK)
			WHERE Emp_ID = @Emp_ID
				AND Cmp_ID = @Cmp_Id
				AND MONTH(For_Date) = MONTH(@For_Date)
				AND YEAR(For_Date) = YEAR(@For_Date)
			)
	BEGIN
		RAISERROR (
				'##Payment Process Exists So You Can not Delete it.##'
				,16
				,1
				)

		RETURN
	END

	-- Ended by rohit on 26112013
	SET @Old_Emp_Name = (
			SELECT ISNULL(Alpha_Emp_Code, '') + ' - ' + ISNULL(Emp_Full_Name, '')
			FROM T0080_EMP_MASTER WITH (NOLOCK)
			WHERE Emp_ID = @Old_Emp_Id
			)
	SET @OldValue = 'old Value' + '#' + 'Employee Name :' + ISNULL(@Old_Emp_Name, '') + '#' + 'For Date :' + cast(ISNULL(@Old_For_Date, '') AS NVARCHAR(11)) + '#' + 'Working Hours :' + CONVERT(NVARCHAR(100), ISNULL(@Old_working_sec, 0)) + '#' + 'OT Hours :' + CONVERT(NVARCHAR(100), ISNULL(@Old_OT_Sec, '')) + '#' + 'Approved OT :' + CONVERT(NVARCHAR(100), ISNULL(@Old_Approve_OT_Sec, 0)) + '#' + 'WO OT Hours :' + CONVERT(NVARCHAR(100), ISNULL(@Old_Weekoff_OT_Sec, 0)) + '#' + 'WO Approved OT :' + CONVERT(NVARCHAR(100), ISNULL(@Old_Approve_WO_Ot_Sec, 0)) + '#' + 'HO OT Hours :' + CONVERT(NVARCHAR(100), ISNULL(@Old_Holiday_OT_Sec, 0)) + '#' + 'HO Approved OT :' + CONVERT(NVARCHAR(100), ISNULL(@Old_Approve_HO_Ot_Sec, 0)) + '#' + 'Status :' + CASE ISNULL(@Old_Is_Approve, 0)
			WHEN 0
				THEN 'Reject'
			ELSE 'Approve'
			END + '#' + 'Comments :' + ISNULL(@Old_Comments, '') + '#' + 'Remark :' + ISNULL(@Old_Remark, '')

	EXEC P9999_Audit_Trail @Cmp_ID
		,@Tran_Type
		,'OT Approval'
		,@Oldvalue
		,@Emp_ID
		,@User_Id
		,@IP_Address
		,1

	-- Added for audit trail By Ali 12102013 -- End
	DELETE
	FROM dbo.T0160_OT_Approval
	WHERE Tran_ID = @Tran_ID

	IF EXISTS (
			SELECT 1
			FROM dbo.T0115_OT_LEVEL_APPROVAL WITH (NOLOCK)
			WHERE Emp_ID = @Old_Emp_Id
				AND For_Date = @Old_For_Date
			)
	BEGIN
		DELETE
		FROM dbo.T0115_OT_LEVEL_APPROVAL
		WHERE Emp_ID = @Old_Emp_Id
			AND For_Date = @Old_For_Date
			AND Rpt_Level = (
				SELECT MAX(Rpt_Level)
				FROM T0115_OT_Level_Approval WITH (NOLOCK)
				WHERE Emp_ID = @Old_Emp_Id
					AND For_date = @Old_For_Date
				) -- Added by Gadriwala Muslim 03112014
	END
END

RETURN