

---20/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0080_EMP_MASTER_UPDATE_IMPORT_Backup_Divyaraj_05122024] 
	 @Cmp_ID NUMERIC(18, 0)
	,@Alpha_Emp_Code VARCHAR(30)
	,@Column_Name VARCHAR(100)
	,@Column_Value VARCHAR(100)
	,@tran_type VARCHAR(1)
	,@GUID VARCHAR(500) = '' -- Added by nilesh patel on 07052016 
	,@User_Id NUMERIC(18, 0) = 0 -- Added by nilesh patel on 07052016 
	,@IP_Address VARCHAR(30) = '' -- Added by nilesh patel on 07052016 
AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

DECLARE @Emp_id NUMERIC
DECLARE @emp_Id_sup NUMERIC
DECLARE @qry VARCHAR(1000)
DECLARE @Inc_id NUMERIC
DECLARE @Inc_Eff_date DATETIME
DECLARE @Date_of_Retirement DATETIME
DECLARE @Emp_FirstName AS VARCHAR(50) --Added By Jimit 06012018
DECLARE @Emp_LastName AS VARCHAR(50) --Added By Jimit 06012018
DECLARE @Emp_Dob AS VARCHAR(20) --Added By Jimit 06012018
DECLARE @EMP_Joning_DATE AS DATETIME --ADDED BY Jimit 14032019

SET @Inc_id = 0
SET @qry = ''
SET @Inc_Eff_date = NULL

DECLARE @str_New_value VARCHAR(max);
DECLARE @qry_1 NVARCHAR(Max)
DECLARE @OldValue VARCHAR(Max)

SET @OldValue = ''

DECLARE @Flag_ID CHAR(1)

SET @Flag_ID = 0

DECLARE @Emailmsg INT = 0

IF EXISTS (
		SELECT Emp_ID
		FROM dbo.T0080_EMP_MASTER WITH (NOLOCK)
		WHERE Cmp_ID = @Cmp_ID
			AND Alpha_Emp_Code = @Alpha_Emp_Code
		)
BEGIN
	SELECT @Emp_Id = Emp_Id --,@Inc_id = Increment_ID 
		,@Emp_FirstName = Emp_First_Name
		,@Emp_LastName = Emp_Last_Name
		,@Emp_Dob = Date_Of_Birth
		,@EMP_Joning_DATE = date_Of_Join
	FROM Dbo.T0080_Emp_Master WITH (NOLOCK)
	WHERE Cmp_ID = @Cmp_ID
		AND Alpha_Emp_Code = @Alpha_Emp_Code

	--Added increment condition by nilesh patel on 24042018 -- Designation is not update properly -- GTPL client -- Emp Code : 01001
	SELECT @Inc_id = I.Increment_ID
		,@Inc_Eff_date = Increment_Effective_Date
	FROM T0095_INCREMENT I WITH (NOLOCK)
	INNER JOIN (
		SELECT MAX(I2.Increment_ID) AS Increment_ID
			,I2.Emp_ID
		FROM T0095_INCREMENT I2 WITH (NOLOCK)
		INNER JOIN (
			SELECT MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE
				,I3.EMP_ID
			FROM T0095_INCREMENT I3 WITH (NOLOCK)
			INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON EM.Emp_ID = I3.EMp_ID
			WHERE I3.Increment_Effective_Date <= GETDATE()
				AND I3.Emp_ID = @Emp_Id
			GROUP BY I3.Emp_ID
			) I3 ON I2.Increment_Effective_Date = I3.INCREMENT_EFFECTIVE_DATE
			AND I2.Emp_ID = I3.Emp_ID
		GROUP BY I2.Emp_ID
		) I2 ON I.Increment_ID = I2.INCREMENT_ID
	WHERE I.Emp_ID = @Emp_Id

	--Select @Inc_Eff_date = Increment_Effective_Date from T0095_INCREMENT where Increment_ID  = @Inc_id
	IF EXISTS (
			SELECT Emp_ID
			FROM dbo.T0080_EMP_MASTER WITH (NOLOCK)
			WHERE Cmp_ID = @Cmp_ID
				AND Alpha_Emp_Code = @Alpha_Emp_Code
				AND Emp_ID <> @Emp_ID
				AND Emp_left <> 'Y'
			)
	BEGIN
		SET @Emp_ID = 0

		RETURN
	END

	/*  This Code is Added By Ramiz on 15-Mar-2016
		
			@Inc_Salary_Id --> This Increment_ID will update that field which we are going to use in Salary
			@Inc_id --> This Increment Id will update the Max Entry , even if it is of Transfer , as we need to display it in Employee Master
		*/
	DECLARE @INC_SALARY_ID NUMERIC

	SET @INC_SALARY_ID = 0;

	IF EXISTS (
			SELECT Increment_Type
			FROM T0095_INCREMENT WITH (NOLOCK)
			WHERE Increment_ID = @Inc_id
				AND Increment_Type = 'Transfer'
			)
	BEGIN
		SELECT @Inc_Salary_Id = I.Increment_Id
		FROM T0095_INCREMENT I WITH (NOLOCK)
		INNER JOIN (
			SELECT MAX(Increment_ID) AS Increment_ID
			FROM T0095_INCREMENT I1 WITH (NOLOCK)
			WHERE Emp_ID = @Emp_ID
				AND Increment_Type <> 'Transfer'
			) I1 ON I.Increment_ID = I.Increment_ID
			AND Increment_Type <> 'Transfer'
		WHERE Emp_ID = @Emp_ID
			AND Cmp_ID = @Cmp_ID
	END

	/* Code Ended By Ramiz on 15-Mar-2016		*/
	--Added By Jimit 14032019
	IF @Column_Name = 'Date_of_Birth'
	BEGIN
		IF @Column_Value > GETDATE()
		BEGIN
			INSERT INTO dbo.T0080_Import_Log
			VALUES (
				0
				,@Cmp_Id
				,@Alpha_Emp_Code
				,'Future Birth Date is not Allowed.'
				,0
				,'Enter Valid Birth Date'
				,GETDATE()
				,'Employee Master'
				,''
				)

			RETURN
		END

		IF DATEDIFF(YEAR, @Column_Value, @EMP_Joning_DATE) < 18
		BEGIN
			INSERT INTO dbo.T0080_Import_Log
			VALUES (
				0
				,@Cmp_Id
				,@Alpha_Emp_Code
				,'Employee Age below 18yrs.'
				,0
				,'Enter Valid Birth date'
				,GETDATE()
				,'Employee Master'
				,''
				)

			RETURN
		END
	END

	--Ended			
	IF @Column_Name = 'Emp_Superior'
		OR @Column_Name = 'Manager'
	BEGIN
		DECLARE @Effect_Date DATETIME --Ankit 13022015

		SELECT @emp_Id_sup = Emp_Id
			,@Effect_Date = Date_Of_Join
		FROM dbo.T0080_Emp_Master WITH (NOLOCK)
		WHERE Cmp_Id = @cmp_Id
			AND Alpha_Emp_Code = @Column_Value

		SET @Column_Value = @emp_Id_sup

		IF NOT EXISTS (
				SELECT Row_ID
				FROM T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)
				WHERE Cmp_ID = @Cmp_ID
					AND Emp_ID = @Emp_ID
					AND R_Emp_ID = @emp_Id_sup
				)
		BEGIN
			IF @emp_Id_sup IS NOT NULL
			BEGIN
				EXEC P0090_EMP_REPORTING_DETAIL 0
					,@Emp_ID
					,@Cmp_ID
					,'Supervisor'
					,@emp_Id_sup
					,'Direct'
					,'i'
					,0
					,0
					,''
					,@Effect_Date

				UPDATE T0080_EMP_MASTER
				SET Emp_Superior = @emp_Id_sup
				WHERE Emp_ID = @Emp_id
			END
		END

		SET @Flag_ID = 1
			--set @Column_Name = ''
	END
	ELSE IF @Column_Name = 'Old_Ref_Code'
	BEGIN
		DECLARE @str_Old_Ref_Code VARCHAR(200)

		SELECT @str_Old_Ref_Code = Old_Ref_No
		FROM T0080_Emp_Master WITH (NOLOCK)
		WHERE Emp_ID = @Emp_Id
			AND Cmp_Id = @Cmp_ID

		SET @OldValue = 'Old Value' + '#Old_Ref_No : ' + Isnull(@str_Old_Ref_Code, '')

		UPDATE T0080_EMP_MASTER
		SET Old_Ref_No = @Column_Value
		WHERE Emp_ID = @Emp_id

		SET @Flag_ID = 1
			--set @Column_Name = ''					
	END
	ELSE IF @Column_Name = 'Alias'
	BEGIN
		IF NOT EXISTS (
				SELECT 1
				FROM T0011_LOGIN WITH (NOLOCK)
				WHERE Login_Alias = @Column_Value
					AND Emp_ID <> @Emp_id
				)
		BEGIN
			DECLARE @str_Login_Alias VARCHAR(200)

			SELECT @str_Login_Alias = Login_Alias
			FROM T0011_LOGIN WITH (NOLOCK)
			WHERE Emp_ID = @Emp_Id
				AND Cmp_Id = @Cmp_ID

			SET @OldValue = 'Old Value' + '#Login_Alias : ' + Isnull(@str_Login_Alias, '')

			UPDATE T0011_LOGIN
			SET Login_Alias = @Column_Value
			WHERE Emp_ID = @Emp_id
		END

		SET @Flag_ID = 1
			--set @Column_Name = ''					
	END
	ELSE IF @Column_Name = 'Cost_Center_code'
	BEGIN
		DECLARE @cc_id AS NUMERIC

		SET @cc_id = 0

		DECLARE @str_Cost_Center_code NUMERIC(18, 0)
		DECLARE @str_Cost_Center_Name VARCHAR(200)

		SELECT @str_Cost_Center_code = Center_ID
		FROM T0095_INCREMENT WITH (NOLOCK)
		WHERE Emp_ID = @Emp_Id
			AND Cmp_Id = @Cmp_ID
			AND Increment_ID = @Inc_id

		IF @str_Cost_Center_code <> 0
		BEGIN
			SELECT @str_Cost_Center_Name = Center_Name
			FROM dbo.T0040_COST_CENTER_MASTER WITH (NOLOCK)
			WHERE Cmp_Id = @cmp_Id
				AND Center_ID = @str_Cost_Center_code
		END

		SET @OldValue = 'Old Value' + '#Cost_Center_code : ' + Isnull(@str_Cost_Center_Name, '')

		SELECT @cc_id = Center_ID
		FROM dbo.T0040_COST_CENTER_MASTER WITH (NOLOCK)
		WHERE Cmp_Id = @cmp_Id
			AND Center_Code = @Column_Value --Here Name was Compared with code , so it was not Updating ( Changed by Ramiz on 20/01/2016 )

		UPDATE T0095_INCREMENT
		SET Center_ID = @cc_id
		WHERE Emp_ID = @Emp_id
			AND Increment_ID = @Inc_id

		SET @Flag_ID = 1
			--set @Column_Name = ''					
	END
	ELSE IF @Column_Name = 'Branch_Name'
	BEGIN
		DECLARE @branch_id AS NUMERIC

		SET @branch_id = 0

		SELECT @branch_id = Branch_ID
		FROM dbo.T0030_BRANCH_MASTER WITH (NOLOCK)
		WHERE Cmp_Id = @cmp_Id
			AND upper(Branch_Name) = upper(@Column_Value)

		IF @branch_id <> 0 --This Condition is Added By Ramiz on 09/10/2015 as it is a Mandatory field and it cannot be set as Blank
		BEGIN
			DECLARE @str_Branch_ID NUMERIC(18, 2)
			DECLARE @str_Branch_Name VARCHAR(200)

			SELECT @str_Branch_ID = Branch_ID
			FROM T0095_INCREMENT WITH (NOLOCK)
			WHERE Emp_ID = @Emp_Id
				AND Cmp_Id = @Cmp_ID
				AND Increment_ID = @Inc_id

			IF @str_Branch_ID <> 0
			BEGIN
				SELECT @str_Branch_Name = Branch_Name
				FROM T0030_BRANCH_MASTER WITH (NOLOCK)
				WHERE Branch_ID = @str_Branch_ID
					AND Cmp_Id = @Cmp_ID
			END

			SET @OldValue = 'Old Value' + '#Branch_Name : ' + Isnull(@str_Branch_Name, '')

			UPDATE T0095_INCREMENT
			SET Branch_ID = @branch_id
			WHERE Emp_ID = @Emp_id
				AND Increment_ID = @Inc_id
		END

		SET @Flag_ID = 1
			--set @Column_Name = ''					
	END
			-- Added by rohit for Category on 24-jan-2013
	ELSE IF @Column_Name = 'Category'
	BEGIN
		DECLARE @Cat_Id AS NUMERIC

		SET @Cat_Id = 0

		SELECT @Cat_Id = Cat_ID
		FROM dbo.T0030_CATEGORY_MASTER WITH (NOLOCK)
		WHERE Cmp_Id = @cmp_Id
			AND upper(Cat_Name) = upper(@Column_Value)

		DECLARE @str_Category NUMERIC(18, 0)
		DECLARE @str_Category_Name VARCHAR(200)

		SELECT @str_Category = Cat_id
		FROM T0095_INCREMENT WITH (NOLOCK)
		WHERE Emp_ID = @Emp_Id
			AND Cmp_Id = @Cmp_ID
			AND Increment_ID = @Inc_id

		IF @str_Branch_ID <> 0
		BEGIN
			SELECT @str_Category_Name = Cat_Name
			FROM T0030_CATEGORY_MASTER WITH (NOLOCK)
			WHERE Cat_ID = @str_Category
				AND Cmp_Id = @Cmp_ID
		END

		SET @OldValue = 'Old Value' + '#Category : ' + Isnull(@str_Category_Name, '')

		UPDATE T0095_INCREMENT
		SET Cat_id = @Cat_Id
		WHERE Emp_ID = @Emp_id
			AND Increment_ID = @Inc_id

		--set @Column_Name = ''					
		SET @Flag_ID = 1
	END
			-- Ended by rohit
	ELSE IF @Column_Name = 'Grade'
	BEGIN
		DECLARE @Gr_id AS NUMERIC

		SET @Gr_id = 0

		SELECT @Gr_id = Grd_ID
		FROM dbo.T0040_GRADE_MASTER WITH (NOLOCK)
		WHERE Cmp_Id = @cmp_Id
			AND Grd_Name = @Column_Value

		IF @Gr_id <> 0 --This Condition is Added By Ramiz on 09/10/2015 as it is a Mandatory field and it cannot be set as Blank
		BEGIN
			DECLARE @str_Grade NUMERIC(18, 0)

			SELECT @str_Grade = Grd_ID
			FROM T0095_INCREMENT WITH (NOLOCK)
			WHERE Emp_ID = @Emp_Id
				AND Cmp_Id = @Cmp_ID
				AND Increment_ID = @Inc_id

			DECLARE @str_Grade_Name VARCHAR(200)

			IF @str_Grade <> 0
			BEGIN
				SELECT @str_Grade_Name = Grd_Name
				FROM T0040_GRADE_MASTER WITH (NOLOCK)
				WHERE Grd_ID = @str_Grade
					AND Cmp_Id = @Cmp_ID
			END

			SET @OldValue = 'Old Value' + '#Grade : ' + Isnull(@str_Grade_Name, '')

			UPDATE T0095_INCREMENT
			SET Grd_ID = @Gr_id
			WHERE Emp_ID = @Emp_id
				AND Increment_ID = @Inc_id
		END

		SET @Flag_ID = 1
			--set @Column_Name = ''					
	END
	ELSE IF @Column_Name = 'Designation'
	BEGIN
		DECLARE @desig_id AS NUMERIC

		SET @desig_id = 0

		SELECT @desig_id = Desig_ID
		FROM dbo.T0040_DESIGNATION_MASTER WITH (NOLOCK)
		WHERE Cmp_Id = @cmp_Id
			AND Desig_Name = @Column_Value

		IF @desig_id <> 0 --This Condition is Added By Ramiz as it is a Mandatory field and it cannot be set as Blank
		BEGIN
			DECLARE @str_Designation NUMERIC(18, 0)

			SELECT @str_Designation = Desig_Id
			FROM T0095_INCREMENT WITH (NOLOCK)
			WHERE Emp_ID = @Emp_Id
				AND Cmp_Id = @Cmp_ID
				AND Increment_ID = @Inc_id

			DECLARE @str_Designation_Name VARCHAR(200)

			IF @str_Designation <> 0
			BEGIN
				SELECT @str_Designation_Name = Desig_Name
				FROM T0040_DESIGNATION_MASTER WITH (NOLOCK)
				WHERE Desig_ID = @str_Designation
					AND Cmp_Id = @Cmp_ID
			END

			SET @OldValue = 'Old Value' + '#Designation : ' + Isnull(@str_Designation_Name, '')

			UPDATE T0095_INCREMENT
			SET Desig_Id = @desig_id
			WHERE Emp_ID = @Emp_id
				AND Increment_ID = @Inc_id
		END

		SET @Flag_ID = 1
			--set @Column_Name = ''	
	END
	ELSE IF @Column_Name = 'Department'
	BEGIN
		DECLARE @dept_id AS NUMERIC

		SET @dept_id = 0

		SELECT @dept_id = Dept_ID
		FROM dbo.T0040_DEPARTMENT_MASTER WITH (NOLOCK)
		WHERE Cmp_Id = @cmp_Id
			AND Dept_Name = @Column_Value

		DECLARE @str_Department NUMERIC(18, 0)

		SELECT @str_Department = Dept_Id
		FROM T0095_INCREMENT WITH (NOLOCK)
		WHERE Emp_ID = @Emp_Id
			AND Cmp_Id = @Cmp_ID
			AND Increment_ID = @Inc_id

		DECLARE @str_Department_Name VARCHAR(200)

		IF @str_Department <> 0
		BEGIN
			SELECT @str_Department_Name = Dept_Name
			FROM T0040_DEPARTMENT_MASTER WITH (NOLOCK)
			WHERE Dept_Id = @str_Department
				AND Cmp_Id = @Cmp_ID
		END

		SET @OldValue = 'Old Value' + '#Department : ' + Isnull(@str_Department_Name, '')

		UPDATE T0095_INCREMENT
		SET Dept_Id = @dept_id
		WHERE Emp_ID = @Emp_id
			AND Increment_ID = @Inc_id

		SET @Flag_ID = 1
			--set @Column_Name = ''					
	END
			-- Added By Sajid 06-05-2022
			--else if @Column_Name = 'General_Shift' 
			--		begin	
			--			declare @Shift_ID as numeric
			--			set @Shift_ID = 0
			--			Select @Shift_ID = Shift_ID  From dbo.T0040_SHIFT_MASTER WITH (NOLOCK) Where Cmp_Id=@cmp_Id and Shift_Name = @Column_Value
			--			Declare @str_General_Shift Numeric(18,0)
			--			Select @str_General_Shift =  Shift_ID  From T0080_EMP_MASTER WITH (NOLOCK) Where Emp_ID = @Emp_Id  And Cmp_Id = @Cmp_ID and Increment_ID = @Inc_id
			--			Declare @str_Shift_Name varchar(200)
			--			if @str_General_Shift <> 0	
			--				Begin
			--					Select @str_Department_Name = Shift_Name From T0040_SHIFT_MASTER WITH (NOLOCK) Where Shift_ID = @str_General_Shift and Cmp_Id =  @Cmp_ID
			--				End
			--			Set @OldValue = 'Old Value' + '#General_Shift : ' + Isnull(@str_Shift_Name,'')
			--			update T0080_EMP_MASTER set Shift_ID = @Shift_ID  where Emp_ID = @Emp_id and Increment_ID = @Inc_id
			--			update T0100_EMP_SHIFT_DETAIL set Shift_ID = @Shift_ID  where Emp_ID = @Emp_id 
			--			Set @Flag_ID = 1
			--			--set @Column_Name = ''					
			--		end	
			-- Added By Sajid 25-01-2022 START
	ELSE IF @Column_Name = 'Band_Name'
	BEGIN
		DECLARE @BandID AS NUMERIC

		SET @BandID = 0

		SELECT @BandID = BandID
		FROM dbo.tblBandMaster WITH (NOLOCK)
		WHERE Cmp_Id = @cmp_Id
			AND BandName = @Column_Value

		IF @BandID <> 0
		BEGIN
			DECLARE @str_Band NUMERIC(18, 0)

			SELECT @str_Band = Band_Id
			FROM T0095_INCREMENT WITH (NOLOCK)
			WHERE Emp_ID = @Emp_Id
				AND Cmp_Id = @Cmp_ID
				AND Increment_ID = @Inc_id

			DECLARE @str_BandName VARCHAR(200)

			IF @str_Band <> 0
			BEGIN
				SELECT @str_BandName = BandName
				FROM tblBandMaster WITH (NOLOCK)
				WHERE BandId = @str_Band
					AND Cmp_Id = @Cmp_ID
			END

			SET @OldValue = 'Old Value' + '#Band_Name : ' + Isnull(@str_BandName, '')

			UPDATE T0095_INCREMENT
			SET Band_Id = @BandID
			WHERE Emp_ID = @Emp_id
				AND Increment_ID = @Inc_id
		END

		SET @Flag_ID = 1
			--set @Column_Name = ''					
	END
			-- Added By Sajid 25-01-2022 END
	ELSE IF @Column_Name = 'Employee_Type'
	BEGIN
		DECLARE @Type_id AS NUMERIC

		SET @Type_Id = 0

		SELECT @Type_Id = T.TYPE_ID
		FROM dbo.T0040_TYPE_MASTER T WITH (NOLOCK)
		WHERE T.Type_Name = @Column_Value
			AND cmp_id = @Cmp_ID

		DECLARE @str_Employee_Type NUMERIC(18, 0)

		SELECT @str_Employee_Type = Type_ID
		FROM T0095_INCREMENT WITH (NOLOCK)
		WHERE Emp_ID = @Emp_Id
			AND Cmp_Id = @Cmp_ID
			AND Increment_ID = @Inc_id

		IF @str_Employee_Type <> 0
		BEGIN
			DECLARE @str_Employee_Name VARCHAR(200)

			SELECT @str_Employee_Name = Type_Name
			FROM T0040_TYPE_MASTER WITH (NOLOCK)
			WHERE Type_ID = @str_Employee_Type
				AND Cmp_ID = @Cmp_ID
		END

		SET @OldValue = 'Old Value' + '#Employee_Type : ' + Isnull(@str_Employee_Name, '')

		UPDATE T0095_INCREMENT
		SET Type_ID = @Type_id
		WHERE Emp_ID = @Emp_id
			AND Increment_ID = @Inc_id

		SET @Flag_ID = 1
			--set @Column_Name = ''					
	END
	ELSE IF @Column_Name = 'Salary_Cycle'
	BEGIN
		DECLARE @Salary_Cycle_id AS NUMERIC

		SET @Salary_Cycle_id = 0

		SELECT @Salary_Cycle_id = SCM.Tran_Id
		FROM dbo.T0040_Salary_Cycle_Master SCM WITH (NOLOCK)
		WHERE SCM.Name = @Column_Value
			AND cmp_id = @Cmp_ID

		DECLARE @str_Salary_Cycle NUMERIC(18, 0)

		SELECT @str_Salary_Cycle = SalDate_id
		FROM T0095_INCREMENT WITH (NOLOCK)
		WHERE Emp_ID = @Emp_Id
			AND Cmp_Id = @Cmp_ID
			AND Increment_ID = @Inc_id

		IF @str_Salary_Cycle <> 0
		BEGIN
			DECLARE @str_Salary_Cycle_Name VARCHAR(200)

			SELECT @str_Salary_Cycle_Name = Name
			FROM T0040_Salary_Cycle_Master WITH (NOLOCK)
			WHERE Tran_Id = @str_Salary_Cycle
				AND Cmp_Id = @Cmp_ID
		END

		SET @OldValue = 'Old Value' + '#Salary_Cycle : ' + Isnull(@str_Salary_Cycle_Name, '')

		UPDATE T0095_INCREMENT
		SET SalDate_id = @Salary_Cycle_id
		WHERE Emp_ID = @Emp_id
			AND Increment_ID = @Inc_id

		IF NOT EXISTS (
				SELECT 1
				FROM T0095_Emp_Salary_Cycle WITH (NOLOCK)
				WHERE Emp_id = @Emp_ID
					AND Effective_date = @Inc_Eff_date
				)
		BEGIN
			INSERT INTO T0095_Emp_Salary_Cycle (
				Cmp_id
				,Emp_id
				,SalDate_id
				,Effective_date
				)
			VALUES (
				@Cmp_ID
				,@Emp_ID
				,@Salary_Cycle_id
				,@Inc_Eff_date
				)
		END
		ELSE
		BEGIN
			UPDATE T0095_Emp_Salary_Cycle
			SET SalDate_id = @Salary_Cycle_id
			WHERE Effective_date = @Inc_Eff_date
				AND Emp_ID = @Emp_ID
		END

		SET @Flag_ID = 1
			--set @Column_Name = ''					
	END

	--Added By Jimit 08012018
	IF @Column_Name = 'Esic_no'
		OR @Column_Name = 'Pf_No'
		OR @Column_Name = 'Pan_No'
		OR @Column_Name = 'Uan_No'
	BEGIN
		IF Object_ID('tempdb..#COLUMN_VALUE') IS NULL
		BEGIN
			CREATE TABLE #COLUMN_VALUE (
				COLUMN_NAME VARCHAR(50)
				,Column_Value VARCHAR(50)
				)
		END
	END
	
	--ENded
	IF @Column_Name = 'Esic_no'
	BEGIN
		--Added By Jimit 06012018
		INSERT INTO #COLUMN_VALUE (
			COLUMN_NAME
			,Column_Value
			)
		EXEC P_EMP_UAN_PAN_VALIDATION @Cmp_ID
			,@Emp_ID
			,@Emp_FirstName
			,@Emp_LastName
			,@Emp_Dob
			,''
			,'ESIC'
			,@Column_Value

		IF EXISTS (
				SELECT 1
				FROM #COLUMN_VALUE
				)
		BEGIN
			RETURN
		END

		SET @Column_Name = 'Sin_no'
	END
	ELSE IF @Column_Name = 'Pf_No'
	BEGIN
		--Added By Jimit 06012018
		INSERT INTO #COLUMN_VALUE (
			COLUMN_NAME
			,Column_Value
			)
		EXEC P_EMP_UAN_PAN_VALIDATION @Cmp_ID
			,@Emp_ID
			,@Emp_FirstName
			,@Emp_LastName
			,@Emp_Dob
			,''
			,'PF'
			,@Column_Value

		IF EXISTS (
				SELECT 1
				FROM #COLUMN_VALUE
				)
		BEGIN
			RETURN
		END

		SET @Column_Name = 'SSN_no'
	END
	ELSE IF @Column_Name = 'Pan_No' --Added By Jimit 06012018
	BEGIN
		INSERT INTO #COLUMN_VALUE (
			COLUMN_NAME
			,Column_Value
			)
		EXEC P_EMP_UAN_PAN_VALIDATION @Cmp_ID
			,@Emp_ID
			,@Emp_FirstName
			,@Emp_LastName
			,@Emp_Dob
			,''
			,'PAN'
			,@Column_Value

		IF EXISTS (
				SELECT 1
				FROM #COLUMN_VALUE
				)
		BEGIN
			RETURN
		END

		SET @Column_Name = 'Pan_no'
	END
	ELSE IF @Column_Name = 'Uan_No' --Added By Jimit 06012018
	BEGIN
		INSERT INTO #COLUMN_VALUE (
			COLUMN_NAME
			,Column_Value
			)
		EXEC P_EMP_UAN_PAN_VALIDATION @Cmp_ID
			,@Emp_ID
			,@Emp_FirstName
			,@Emp_LastName
			,@Emp_Dob
			,''
			,'UAN'
			,@Column_Value

		IF EXISTS (
				SELECT 1
				FROM #COLUMN_VALUE
				)
		BEGIN
			RETURN
		END

		SET @Column_Name = 'Uan_No'
	END
			--else if @Column_Name = 'Pf_No'
			--	begin
			--		set @Column_Name = 'SSN_no'
			--	end
	ELSE IF @Column_Name = 'Personal_Email'
	BEGIN
		SET @Column_Name = 'Other_email'
	END
	ELSE IF @Column_Name = 'Official_Email'
	BEGIN
		SET @Column_Name = 'work_email'
	END
	ELSE IF @Column_Name = 'Next_Increment_Date' --ADDED BY MUKTI(11032021)
	BEGIN
		DECLARE @NEXT_INCR_DATE VARCHAR(25)
		DECLARE @TYPE CHAR(2)
		DECLARE @TRAN_ID INT
		DECLARE @LAST_INCR_DATE AS DATETIME

		SELECT @NEXT_INCR_DATE = SUBSTRING(@Column_Value, CHARINDEX('-', @Column_Value) + 1, LEN(@Column_Value))

		SELECT @TYPE = SUBSTRING(@Column_Value, 1, CHARINDEX('-', @Column_Value) - 1)

		SELECT TOP 1 @TRAN_ID = TRAN_ID
			,@LAST_INCR_DATE = Next_Increment_Date
		FROM T0110_Emp_NextIncrement_Details
		WHERE EMP_ID = @Emp_id
			AND CMP_ID = @Cmp_ID
		ORDER BY Next_Increment_Date DESC

		SET @Column_Name = 'Next_Increment_Date'

		IF @LAST_INCR_DATE > CONVERT(DATETIME, @NEXT_INCR_DATE, 103)
		BEGIN
			INSERT INTO dbo.T0080_Import_Log
			VALUES (
				0
				,@Cmp_Id
				,@Alpha_Emp_Code
				,'Next Increment date is small than Last Increment Date'
				,0
				,'Enter proper Next Increment Date'
				,GETDATE()
				,'Employee Master'
				,''
				)

			RETURN
		END

		IF @TYPE = 'N'
		BEGIN
			INSERT INTO T0110_Emp_NextIncrement_Details
			VALUES (
				@Cmp_ID
				,@Emp_id
				,CONVERT(DATETIME, @NEXT_INCR_DATE, 103)
				,GETDATE()
				,@User_Id
				)
		END
		ELSE
		BEGIN
			SET @qry = 'Update dbo.T0110_Emp_NextIncrement_Details Set Next_Increment_Date  = ' + CONVERT(DATETIME, @NEXT_INCR_DATE, 103) + ' Where Emp_Id = ' + CAST(@Emp_Id AS NVARCHAR) + ' AND TRAN_ID=' + CAST(@TRAN_ID AS VARCHAR(15)) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR)
		END

		EXEC (@QRY)

		RETURN
	END
	
	
	
	IF @Column_Name = 'Bank_Account_No'
	BEGIN
		SET @Column_Name = 'Inc_Bank_AC_No'

		DECLARE @str_Inc_Bank_AC_No VARCHAR(100)

		SET @qry_1 = 'Select @str_Inc_Bank_AC_No = ' + Cast(@Column_Name AS VARCHAR(500)) + ' From T0095_Increment Where Emp_ID = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR) + 'and Increment_ID =' + CAST(@Inc_id AS NVARCHAR)

		EXEC sp_executesql @qry_1
			,N'@str_Inc_Bank_AC_No varchar(max) output'
			,@str_Inc_Bank_AC_No OUTPUT

		SET @OldValue = 'Old Value' + '#' + @Column_Name + ' : ' + @str_Inc_Bank_AC_No
		SET @qry = 'Update dbo.T0095_Increment	Set	' + @Column_Name + ' = ''' + @Column_Value + ''' Where Emp_Id = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR) + 'and Increment_ID =' + CAST(@Inc_id AS NVARCHAR)
	END
			-- Added By rohit for Update BankName And Paymennt Mode on 01 Sep 2012	
	ELSE IF @Column_Name = 'Bank_Name'
	BEGIN
		SET @Column_Name = 'Bank_Id'

		DECLARE @str_Bank_Id VARCHAR(200)

		SET @qry_1 = 'Select @str_Bank_Id = ' + Cast(@Column_Name AS VARCHAR(500)) + ' From T0095_Increment Where Emp_ID = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR) + 'and Increment_ID =' + CAST(@Inc_id AS NVARCHAR)

		EXEC sp_executesql @qry_1
			,N'@str_Bank_Id varchar(max) output'
			,@str_Bank_Id OUTPUT

		SET @OldValue = 'Old Value' + '#' + @Column_Name + ' : ' + @str_Bank_Id

		SELECT @Column_Value = Bank_id
		FROM T0040_BANK_MASTER
		WHERE Bank_Name = @Column_Value
			AND Cmp_Id = @Cmp_ID

		SET @qry = 'Update dbo.T0095_Increment	Set	' + @Column_Name + ' = ''' + @Column_Value + ''' Where Emp_Id = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR) + 'and Increment_ID =' + Cast(@Inc_id AS NVARCHAR)
	END
	ELSE IF @Column_Name = 'Payment_Mode'
	BEGIN
		SET @Column_Name = 'Payment_Mode'

		DECLARE @str_Payment_Mode VARCHAR(200)

		SET @qry_1 = 'Select @str_Payment_Mode = ' + Cast(@Column_Name AS VARCHAR(500)) + ' From T0095_Increment Where Emp_ID = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR) + 'and Increment_ID =' + CAST(@Inc_id AS NVARCHAR)

		EXEC sp_executesql @qry_1
			,N'@str_Payment_Mode varchar(max) output'
			,@str_Payment_Mode OUTPUT

		SET @OldValue = 'Old Value' + '#' + @Column_Name + ' : ' + @str_Payment_Mode
		SET @qry = 'Update dbo.T0095_Increment	Set	' + @Column_Name + ' = ''' + @Column_Value + ''' Where Emp_Id = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR) + 'and Increment_ID =' + cast(@Inc_id AS NVARCHAR)
	END
			-------------------------------------------------------------------------------------------------------
	ELSE IF @Column_Name = 'Enroll_No'
	BEGIN
		IF Isnull(@Column_Value, 0) <> 0
		BEGIN
			IF EXISTS (
					SELECT 1
					FROM T0010_COMPANY_MASTER WITH (NOLOCK)
					WHERE Cmp_Id = @Cmp_ID
						AND is_GroupOFCmp = 1
					)
			BEGIN
				IF Object_ID('tempdb..#GroupCompany') IS NOT NULL
				BEGIN
					DROP TABLE #GroupCompany
				END

				CREATE TABLE #GroupCompany (Cmp_ID NUMERIC(18, 0))

				INSERT INTO #GroupCompany
				SELECT Cmp_ID
				FROM T0010_COMPANY_MASTER WITH (NOLOCK)
				WHERE is_GroupOFCmp = 1

				IF EXISTS (
						SELECT 1
						FROM T0080_EMP_MASTER EM WITH (NOLOCK)
						INNER JOIN #GroupCompany GC ON EM.Cmp_ID = GC.Cmp_ID
						WHERE EM.Enroll_No = @Column_Value
							AND Emp_Left_Date IS NULL
						)
				BEGIN
					RETURN
				END
			END
			ELSE
			BEGIN
				IF EXISTS (
						SELECT 1
						FROM T0080_EMP_MASTER EM WITH (NOLOCK)
						WHERE EM.Enroll_No = @Column_Value
							AND Emp_Left_Date IS NULL
						)
				BEGIN
					RETURN
				END
			END
		END

		DECLARE @str_Enroll_No VARCHAR(200)

		SET @qry_1 = 'Select @str_Enroll_No = ' + Cast(@Column_Name AS VARCHAR(500)) + ' From T0080_EMP_MASTER WITH (NOLOCK) Where Emp_ID = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR)

		EXEC sp_executesql @qry_1
			,N'@str_Enroll_No varchar(max) output'
			,@str_Enroll_No OUTPUT

		SET @OldValue = 'Old Value' + '#' + @Column_Name + ' : ' + @str_Enroll_No
		SET @qry = 'Update dbo.T0080_EMP_MASTER	Set	' + @Column_Name + ' = ' + @Column_Value + ' Where Emp_Id = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR)
	END
	ELSE IF @Column_Name = 'Dealer_Code'
	BEGIN
		DECLARE @str_Dealer_Code VARCHAR(200)

		SET @qry_1 = 'Select @str_Dealer_Code = ' + Cast(@Column_Name AS VARCHAR(500)) + ' From T0080_EMP_MASTER WITH (NOLOCK) Where Emp_ID = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR)

		EXEC sp_executesql @qry_1
			,N'@str_Dealer_Code varchar(max) output'
			,@str_Dealer_Code OUTPUT

		SET @OldValue = 'Old Value' + '#' + @Column_Name + ' : ' + @str_Dealer_Code
		SET @qry = 'Update dbo.T0080_EMP_MASTER	Set	' + @Column_Name + ' = ''' + @Column_Value + ''' Where Emp_Id = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR)
	END
			--Start add by Paras 31/07/2013
	ELSE IF @Column_Name = 'OT_Applicable'
	BEGIN
		SET @Column_Name = 'Emp_OT'

		DECLARE @str_Emp_OT VARCHAR(200)

		SET @qry_1 = 'Select @str_Emp_OT = ' + Cast(@Column_Name AS VARCHAR(500)) + ' From T0095_Increment WITH (NOLOCK) Where Emp_ID = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR) + 'and Increment_ID =' + cast(@Inc_id AS NVARCHAR)

		EXEC sp_executesql @qry_1
			,N'@str_Emp_OT varchar(max) output'
			,@str_Emp_OT OUTPUT

		SET @OldValue = 'Old Value' + '#' + @Column_Name + ' : ' + @str_Emp_OT
		SET @qry = 'Update dbo.T0095_Increment	Set	' + @Column_Name + ' = ''' + @Column_Value + ''' Where Emp_Id = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR) + 'and Increment_ID =' + cast(@Inc_id AS NVARCHAR)
	END
	ELSE IF @Column_Name = 'PT_Applicable'
	BEGIN
		SET @Column_Name = 'Emp_PT'

		DECLARE @str_Emp_PT VARCHAR(200)

		SET @qry_1 = 'Select @str_Emp_PT = ' + Cast(@Column_Name AS VARCHAR(500)) + ' From T0095_Increment WITH (NOLOCK) Where Emp_ID = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR) + 'and Increment_ID =' + cast(@Inc_id AS NVARCHAR)

		EXEC sp_executesql @qry_1
			,N'@str_Emp_PT varchar(max) output'
			,@str_Emp_PT OUTPUT

		SET @OldValue = 'Old Value' + '#' + @Column_Name + ' : ' + @str_Emp_PT
		SET @qry = 'Update dbo.T0095_Increment	Set	' + @Column_Name + ' = ''' + @Column_Value + ''' Where Emp_Id = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR) + 'and Increment_ID =' + cast(@Inc_id AS NVARCHAR)
	END
	ELSE IF @Column_Name = 'OT_Minimum_Limit'
	BEGIN
		SET @Column_Name = 'Emp_OT_Min_Limit'

		DECLARE @str_Emp_OT_Min_Limit VARCHAR(200)

		SET @qry_1 = 'Select @str_Emp_OT_Min_Limit = ' + Cast(@Column_Name AS VARCHAR(500)) + ' From T0095_Increment WITH (NOLOCK) Where Emp_ID = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR) + 'and Increment_ID =' + cast(@Inc_id AS NVARCHAR)

		EXEC sp_executesql @qry_1
			,N'@str_Emp_OT_Min_Limit varchar(max) output'
			,@str_Emp_OT_Min_Limit OUTPUT

		SET @OldValue = 'Old Value' + '#' + @Column_Name + ' : ' + @str_Emp_OT_Min_Limit
		SET @qry = 'Update dbo.T0095_Increment	Set	' + @Column_Name + ' = ''' + @Column_Value + ''' Where Emp_Id = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR) + 'and Increment_ID =' + cast(@Inc_id AS NVARCHAR)
	END
	ELSE IF @Column_Name = 'OT_Maximum_Limit'
	BEGIN
		SET @Column_Name = 'Emp_OT_Max_Limit'

		DECLARE @str_Emp_OT_Max_Limit VARCHAR(200)

		SET @qry_1 = 'Select @str_Emp_OT_Max_Limit = ' + Cast(@Column_Name AS VARCHAR(500)) + ' From T0095_Increment WITH (NOLOCK) Where Emp_ID = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR) + 'and Increment_ID =' + cast(@Inc_id AS NVARCHAR)

		EXEC sp_executesql @qry_1
			,N'@str_Emp_OT_Max_Limit varchar(max) output'
			,@str_Emp_OT_Max_Limit OUTPUT

		SET @OldValue = 'Old Value' + '#' + @Column_Name + ' : ' + @str_Emp_OT_Max_Limit
		SET @qry = 'Update dbo.T0095_Increment	Set	' + @Column_Name + ' = ''' + @Column_Value + ''' Where Emp_Id = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR) + 'and Increment_ID =' + cast(@Inc_id AS NVARCHAR)
	END
	ELSE IF @Column_Name = 'DBRD_Code' --Hardik 06/09/2013
	BEGIN
		SET @Column_Name = 'DBRD_Code'

		DECLARE @str_DBRD_Code VARCHAR(200)

		SET @qry_1 = 'Select @str_DBRD_Code = ' + Cast(@Column_Name AS VARCHAR(500)) + ' From T0080_EMP_MASTER WITH (NOLOCK) Where Emp_ID = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR)

		EXEC sp_executesql @qry_1
			,N'@str_DBRD_Code varchar(max) output'
			,@str_DBRD_Code OUTPUT

		SET @OldValue = 'Old Value' + '#' + @Column_Name + ' : ' + @str_DBRD_Code
		SET @qry = 'Update dbo.T0080_EMP_MASTER	Set	' + @Column_Name + ' = ''' + @Column_Value + ''' Where Emp_Id = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR)
	END
			--End Add by paras 31/07/2013
			-- Added By Gadriwala 05082013 - Start	
	ELSE IF @Column_Name = 'Business_Segment'
	BEGIN
		SET @Column_Name = 'segment_ID'

		DECLARE @str_segment_ID VARCHAR(200)

		SET @qry_1 = 'Select @str_segment_ID = ' + Cast(@Column_Name AS VARCHAR(500)) + ' From T0095_Increment WITH (NOLOCK) Where Emp_ID = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR) + 'and Increment_ID =' + CAST(@Inc_id AS NVARCHAR)

		EXEC sp_executesql @qry_1
			,N'@str_segment_ID varchar(max) output'
			,@str_segment_ID OUTPUT

		SET @OldValue = 'Old Value' + '#' + @Column_Name + ' : ' + @str_segment_ID

		SELECT @Column_Value = segment_ID
		FROM T0040_Business_Segment WITH (NOLOCK)
		WHERE Segment_Name = @Column_Value
			AND Cmp_ID = @Cmp_ID

		SET @qry = 'Update dbo.T0095_Increment	Set	' + @Column_Name + ' = ' + @Column_Value + ' Where Emp_Id = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR)
	END
	ELSE IF @Column_Name = 'Vertical'
	BEGIN
		SET @Column_Name = 'Vertical_ID'

		DECLARE @str_Vertical_ID VARCHAR(200)

		SET @qry_1 = 'Select @str_Vertical_ID = ' + Cast(@Column_Name AS VARCHAR(500)) + ' From T0095_Increment WITH (NOLOCK) Where Emp_ID = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR) + 'and Increment_ID =' + CAST(@Inc_id AS NVARCHAR)

		EXEC sp_executesql @qry_1
			,N'@str_Vertical_ID varchar(max) output'
			,@str_Vertical_ID OUTPUT

		SET @OldValue = 'Old Value' + '#' + @Column_Name + ' : ' + @str_Vertical_ID

		SELECT @Column_Value = Vertical_ID
		FROM T0040_Vertical_Segment WITH (NOLOCK)
		WHERE Vertical_Name = @Column_Value
			AND Cmp_ID = @Cmp_ID

		SET @qry = 'Update dbo.T0095_Increment	Set	' + @Column_Name + ' = ' + @Column_Value + ' Where Emp_Id = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR)
	END
	ELSE IF @Column_Name = 'Sub-Vertical'
		OR @Column_Name = 'Sub_Vertical'
	BEGIN
	
		SET @Column_Name = 'subVertical_ID'

		DECLARE @str_subVertical_ID VARCHAR(200)

		SET @qry_1 = 'Select @str_subVertical_ID = ' + Cast(@Column_Name AS VARCHAR(500)) + ' From T0095_Increment WITH (NOLOCK) Where Emp_ID = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR) + 'and Increment_ID =' + CAST(@Inc_id AS NVARCHAR)

		EXEC sp_executesql @qry_1
			,N'@str_subVertical_ID varchar(max) output'
			,@str_subVertical_ID OUTPUT

		SET @OldValue = 'Old Value' + '#' + @Column_Name + ' : ' + @str_subVertical_ID

		SELECT @Column_Value = subVertical_ID
		FROM T0050_SubVertical WITH (NOLOCK)
		WHERE subVertical_Name = @Column_Value
			AND Cmp_ID = @Cmp_ID

		SET @qry = 'Update dbo.T0095_Increment	Set	' + @Column_Name + ' = ' + @Column_Value + ' Where Emp_Id = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR)
	END
	ELSE IF @Column_Name = 'Sub-Branch'
		OR @Column_Name = 'Sub_Branch'
	BEGIN
		SET @Column_Name = 'SubBranch_ID'

		DECLARE @str_SubBranch_ID VARCHAR(200)

		SET @qry_1 = 'Select @str_SubBranch_ID = ' + Cast(@Column_Name AS VARCHAR(500)) + ' From T0095_Increment WITH (NOLOCK) Where Emp_ID = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR) + 'and Increment_ID =' + CAST(@Inc_id AS NVARCHAR)

		EXEC sp_executesql @qry_1
			,N'@str_SubBranch_ID varchar(max) output'
			,@str_SubBranch_ID OUTPUT

		SET @OldValue = 'Old Value' + '#' + @Column_Name + ' : ' + @str_SubBranch_ID

		SELECT @Column_Value = SubBranch_ID
		FROM T0050_SubBranch WITH (NOLOCK)
		WHERE SubBranch_Name = @Column_Value
			AND Cmp_ID = @Cmp_ID

		SET @qry = 'Update dbo.T0095_Increment	Set	' + @Column_Name + ' = ' + @Column_Value + ' Where Emp_Id = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR)
	END
	ELSE IF @Column_Name = 'Min_OT_Limit'
	BEGIN
		SET @Column_Name = 'Emp_OT_Min_Limit'

		DECLARE @str_Emp_OT_Min_Limit_1 VARCHAR(200)

		SET @qry_1 = 'Select @str_Emp_OT_Min_Limit_1 = ' + Cast(@Column_Name AS VARCHAR(500)) + ' From T0095_Increment WITH (NOLOCK) Where Emp_ID = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR) + 'and Increment_ID =' + CAST(@Inc_id AS NVARCHAR)

		EXEC sp_executesql @qry_1
			,N'@str_Emp_OT_Min_Limit_1 varchar(max) output'
			,@str_Emp_OT_Min_Limit_1 OUTPUT

		SET @OldValue = 'Old Value' + '#' + @Column_Name + ' : ' + @str_Emp_OT_Min_Limit_1
		SET @qry = 'Update dbo.T0095_Increment	Set	' + @Column_Name + ' = ''' + @Column_Value + ''' Where Emp_Id = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR) + ' and Increment_ID =' + cast(@Inc_id AS NVARCHAR)
	END
	ELSE IF @Column_Name = 'Max_OT_Limit'
	BEGIN
		SET @Column_Name = 'Emp_OT_Max_Limit'

		DECLARE @str_Emp_OT_Max_Limit_1 VARCHAR(200)

		SET @qry_1 = 'Select @str_Emp_OT_Max_Limit_1 = ' + Cast(@Column_Name AS VARCHAR(500)) + ' From T0095_Increment WITH (NOLOCK) Where Emp_ID = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR) + 'and Increment_ID =' + CAST(@Inc_id AS NVARCHAR)

		EXEC sp_executesql @qry_1
			,N'@str_Emp_OT_Max_Limit_1 varchar(max) output'
			,@str_Emp_OT_Max_Limit_1 OUTPUT

		SET @OldValue = 'Old Value' + '#' + @Column_Name + ' : ' + @str_Emp_OT_Max_Limit_1
		SET @qry = 'Update dbo.T0095_Increment	Set	' + @Column_Name + ' = ''' + @Column_Value + ''' Where Emp_Id = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR) + ' and Increment_ID =' + cast(@Inc_id AS NVARCHAR)
	END
	ELSE IF @Column_Name = 'Late_Mark'
	BEGIN
		SET @Column_Name = 'Emp_Late_Mark'

		DECLARE @str_Emp_Late_Mark VARCHAR(200)

		SET @qry_1 = 'Select @str_Emp_Late_Mark = ' + Cast(@Column_Name AS VARCHAR(500)) + ' From T0095_Increment WITH (NOLOCK) Where Emp_ID = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR) + 'and Increment_ID =' + CAST(@Inc_id AS NVARCHAR)

		EXEC sp_executesql @qry_1
			,N'@str_Emp_Late_Mark varchar(max) output'
			,@str_Emp_Late_Mark OUTPUT

		SET @OldValue = 'Old Value' + '#' + @Column_Name + ' : ' + @str_Emp_Late_Mark
		--set @qry = 'Update dbo.T0095_Increment	Set	' + @Column_Name + ' = ' + @Column_Value  + ' Where Emp_Id = ' +   CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR) + ' and Increment_ID =' + cast(@Inc_id  AS NVARCHAR)
		SET @qry = 'Update dbo.T0095_Increment	Set	' + @Column_Name + ' = ' + @Column_Value + ' Where Emp_Id = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR) + ' and Increment_ID IN ( ' + cast(@Inc_id AS NVARCHAR) + ',' + cast(@Inc_Salary_Id AS NVARCHAR) + ' )' --Added By Ramiz on 01-Dec-2016
	END
	ELSE IF @Column_Name = 'Early_Mark' --Added by Nimesh on 16-Dec-2015
	BEGIN
		SET @Column_Name = 'Emp_Early_mark'

		DECLARE @str_Emp_Early_mark VARCHAR(200)

		SET @qry_1 = 'Select @str_Emp_Early_mark = ' + Cast(@Column_Name AS VARCHAR(500)) + ' From T0095_Increment WITH (NOLOCK) Where Emp_ID = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR) + 'and Increment_ID =' + CAST(@Inc_id AS NVARCHAR)

		EXEC sp_executesql @qry_1
			,N'@str_Emp_Early_mark varchar(max) output'
			,@str_Emp_Early_mark OUTPUT

		SET @OldValue = 'Old Value' + '#' + @Column_Name + ' : ' + @str_Emp_Early_mark
		--set @qry = 'Update dbo.T0095_Increment	Set	' + @Column_Name + ' = ' + @Column_Value  + ' Where Emp_Id = ' +   CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR) + ' and Increment_ID =' + cast(@Inc_id  AS NVARCHAR)
		SET @qry = 'Update dbo.T0095_Increment	Set	' + @Column_Name + ' = ' + @Column_Value + ' Where Emp_Id = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR) + ' and Increment_ID IN ( ' + cast(@Inc_id AS NVARCHAR) + ',' + cast(@Inc_Salary_Id AS NVARCHAR) + ' )' --Added By Ramiz on 01-Dec-2016
	END
	ELSE IF @Column_Name = 'Full_PF'
	BEGIN
		SET @Column_Name = 'Emp_Full_Pf'

		DECLARE @str_Emp_Full_Pf VARCHAR(200)

		SET @qry_1 = 'Select @str_Emp_Full_Pf = ' + Cast(@Column_Name AS VARCHAR(500)) + ' From T0095_Increment WITH (NOLOCK) Where Emp_ID = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR) + 'and Increment_ID =' + CAST(@Inc_id AS NVARCHAR)

		EXEC sp_executesql @qry_1
			,N'@str_Emp_Full_Pf varchar(max) output'
			,@str_Emp_Full_Pf OUTPUT

		SET @OldValue = 'Old Value' + '#' + @Column_Name + ' : ' + @str_Emp_Full_Pf
		SET @qry = 'Update dbo.T0095_Increment	Set	' + @Column_Name + ' = ' + @Column_Value + ' Where Emp_Id = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR) + ' and Increment_ID =' + cast(@Inc_id AS NVARCHAR)
	END
	ELSE IF @Column_Name = 'Fix_Salary'
	BEGIN
		SET @Column_Name = 'Emp_Fix_Salary'

		DECLARE @str_Emp_Fix_Salary VARCHAR(200)

		SET @qry_1 = 'Select @str_Emp_Fix_Salary = ' + Cast(@Column_Name AS VARCHAR(500)) + ' From T0095_Increment WITH (NOLOCK) Where Emp_ID = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR) + 'and Increment_ID =' + CAST(@Inc_id AS NVARCHAR)

		EXEC sp_executesql @qry_1
			,N'@str_Emp_Fix_Salary varchar(max) output'
			,@str_Emp_Fix_Salary OUTPUT

		SET @OldValue = 'Old Value' + '#' + @Column_Name + ' : ' + @str_Emp_Fix_Salary
		SET @qry = 'Update dbo.T0095_Increment	Set	' + @Column_Name + ' = ' + @Column_Value + ' Where Emp_Id = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR) + ' and Increment_ID =' + cast(@Inc_id AS NVARCHAR)
	END
	ELSE IF @Column_Name = 'Company_Full_PF'
	BEGIN
		SET @Column_Name = 'Emp_Auto_vpf'

		DECLARE @str_Emp_Auto_vpf VARCHAR(200)

		SET @qry_1 = 'Select @str_Emp_Auto_vpf = ' + Cast(@Column_Name AS VARCHAR(500)) + ' From T0095_Increment WITH (NOLOCK) Where Emp_ID = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR) + 'and Increment_ID =' + CAST(@Inc_id AS NVARCHAR)

		EXEC sp_executesql @qry_1
			,N'@str_Emp_Auto_vpf varchar(max) output'
			,@str_Emp_Auto_vpf OUTPUT

		SET @OldValue = 'Old Value' + '#' + @Column_Name + ' : ' + @str_Emp_Auto_vpf
		SET @qry = 'Update dbo.T0095_Increment	Set	' + @Column_Name + ' = ' + @Column_Value + ' Where Emp_Id = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR) + ' and Increment_ID =' + cast(@Inc_id AS NVARCHAR)
	END
	ELSE IF @Column_Name = 'Weekday_OT_Rate'
	BEGIN
		SET @Column_Name = 'Emp_Weekday_OT_Rate'

		DECLARE @str_Emp_Weekday_OT_Rate VARCHAR(200)

		SET @qry_1 = 'Select @str_Emp_Weekday_OT_Rate = ' + Cast(@Column_Name AS VARCHAR(500)) + ' From T0095_Increment WITH (NOLOCK) Where Emp_ID = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR) + 'and Increment_ID =' + CAST(@Inc_id AS NVARCHAR)

		EXEC sp_executesql @qry_1
			,N'@str_Emp_Weekday_OT_Rate varchar(max) output'
			,@str_Emp_Weekday_OT_Rate OUTPUT

		SET @OldValue = 'Old Value' + '#' + @Column_Name + ' : ' + @str_Emp_Weekday_OT_Rate
		--set @qry = 'Update dbo.T0095_Increment	Set	' + @Column_Name + ' = ' + @Column_Value  + ' Where Emp_Id = ' +   CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR) + ' and Increment_ID =' + cast(@Inc_id  AS NVARCHAR)
		SET @qry = 'Update dbo.T0095_Increment	Set	' + @Column_Name + ' = ' + @Column_Value + ' Where Emp_Id = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR) + ' and Increment_ID IN ( ' + cast(@Inc_id AS NVARCHAR) + ',' + cast(@Inc_Salary_Id AS NVARCHAR) + ' )' --Added By Ramiz on 15-Mar-2016
	END
	ELSE IF @Column_Name = 'WeekOff_OT_Rate'
	BEGIN
		SET @Column_Name = 'Emp_WeekOff_OT_Rate'

		DECLARE @str_Emp_WeekOff_OT_Rate VARCHAR(200)

		SET @qry_1 = 'Select @str_Emp_WeekOff_OT_Rate = ' + Cast(@Column_Name AS VARCHAR(500)) + ' From T0095_Increment WITH (NOLOCK) Where Emp_ID = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR) + 'and Increment_ID =' + CAST(@Inc_id AS NVARCHAR)

		EXEC sp_executesql @qry_1
			,N'@str_Emp_WeekOff_OT_Rate varchar(max) output'
			,@str_Emp_WeekOff_OT_Rate OUTPUT

		SET @OldValue = 'Old Value' + '#' + @Column_Name + ' : ' + @str_Emp_WeekOff_OT_Rate
		--set @qry = 'Update dbo.T0095_Increment	Set	' + @Column_Name + ' = ' + @Column_Value  + ' Where Emp_Id = ' +   CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR) + ' and Increment_ID =' + cast(@Inc_id  AS NVARCHAR)
		SET @qry = 'Update dbo.T0095_Increment	Set	' + @Column_Name + ' = ' + @Column_Value + ' Where Emp_Id = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR) + ' and Increment_ID IN ( ' + cast(@Inc_id AS NVARCHAR) + ',' + cast(@Inc_Salary_Id AS NVARCHAR) + ' )' --Added By Ramiz on 15-Mar-2016
	END
	ELSE IF @Column_Name = 'Holiday_OT_Rate'
	BEGIN
		SET @Column_Name = 'Emp_Holiday_OT_Rate'

		DECLARE @str_Emp_Holiday_OT_Rate VARCHAR(200)

		SET @qry_1 = 'Select @str_Emp_Holiday_OT_Rate = ' + Cast(@Column_Name AS VARCHAR(500)) + ' From T0095_Increment WITH (NOLOCK) Where Emp_ID = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR) + 'and Increment_ID =' + CAST(@Inc_id AS NVARCHAR)

		EXEC sp_executesql @qry_1
			,N'@str_Emp_Holiday_OT_Rate varchar(max) output'
			,@str_Emp_Holiday_OT_Rate OUTPUT

		SET @OldValue = 'Old Value' + '#' + @Column_Name + ' : ' + @str_Emp_Holiday_OT_Rate
		--set @qry = 'Update dbo.T0095_Increment	Set	' + @Column_Name + ' = ' + @Column_Value  + ' Where Emp_Id = ' +   CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR) + ' and Increment_ID =' + cast(@Inc_id  AS NVARCHAR)
		SET @qry = 'Update dbo.T0095_Increment	Set	' + @Column_Name + ' = ' + @Column_Value + ' Where Emp_Id = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR) + ' and Increment_ID IN ( ' + cast(@Inc_id AS NVARCHAR) + ',' + cast(@Inc_Salary_Id AS NVARCHAR) + ' )' --Added By Ramiz on 15-Mar-2016
	END
	ELSE IF @Column_Name = 'Late_Coming_Limit'
	BEGIN
		SET @Column_Name = 'Emp_Late_Limit'

		DECLARE @str_Emp_Late_Limit VARCHAR(200)

		SET @qry_1 = 'Select @str_Emp_Late_Limit = ' + Cast(@Column_Name AS VARCHAR(500)) + ' From T0095_Increment WITH (NOLOCK) Where Emp_ID = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR) + 'and Increment_ID =' + CAST(@Inc_id AS NVARCHAR)

		EXEC sp_executesql @qry_1
			,N'@str_Emp_Late_Limit varchar(max) output'
			,@str_Emp_Late_Limit OUTPUT

		SET @OldValue = 'Old Value' + '#' + @Column_Name + ' : ' + @str_Emp_Late_Limit
		--set @qry = 'Update dbo.T0095_Increment	Set	' + @Column_Name + ' = ''' + @Column_Value  + ''' Where Emp_Id = ' +   CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR) + ' and Increment_ID =' + cast(@Inc_id  AS NVARCHAR)
		SET @qry = 'Update dbo.T0095_Increment	Set	' + @Column_Name + ' = ''' + @Column_Value + ''' Where Emp_Id = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR) + ' and Increment_ID IN ( ' + cast(@Inc_id AS NVARCHAR) + ',' + cast(@Inc_Salary_Id AS NVARCHAR) + ' )' --Added By Ramiz on 15-Mar-2016
	END
	ELSE IF @Column_Name = 'Emp_early_limit' --Ankit 15072015
	BEGIN
		SET @Column_Name = 'Emp_early_limit'

		DECLARE @str_Emp_early_limit VARCHAR(200)

		SET @qry_1 = 'Select @str_Emp_early_limit = ' + Cast(@Column_Name AS VARCHAR(500)) + ' From T0095_Increment WITH (NOLOCK) Where Emp_ID = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR) + 'and Increment_ID =' + CAST(@Inc_id AS NVARCHAR)

		EXEC sp_executesql @qry_1
			,N'@str_Emp_early_limit varchar(max) output'
			,@str_Emp_early_limit OUTPUT

		SET @OldValue = 'Old Value' + '#' + @Column_Name + ' : ' + @str_Emp_early_limit
		--set @qry = 'Update dbo.T0095_Increment	Set	' + @Column_Name + ' = ''' + @Column_Value  + ''' Where Emp_Id = ' +   CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR) + ' and Increment_ID =' + cast(@Inc_id  AS NVARCHAR)
		SET @qry = 'Update dbo.T0095_Increment	Set	' + @Column_Name + ' = ''' + @Column_Value + ''' Where Emp_Id = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR) + ' and Increment_ID IN ( ' + cast(@Inc_id AS NVARCHAR) + ',' + cast(@Inc_Salary_Id AS NVARCHAR) + ' )' --Added By Ramiz on 15-Mar-2016
	END
	ELSE IF @Column_Name = 'Is_LWF'
	BEGIN
		SET @Column_Name = 'Is_LWF'

		DECLARE @str_Is_LWF VARCHAR(200)

		SET @qry_1 = 'Select @str_Is_LWF = ' + Cast(@Column_Name AS VARCHAR(500)) + ' From T0080_EMP_MASTER WITH (NOLOCK) Where Emp_ID = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR)

		EXEC sp_executesql @qry_1
			,N'@str_Is_LWF varchar(max) output'
			,@str_Is_LWF OUTPUT

		SET @OldValue = 'Old Value' + '#' + @Column_Name + ' : ' + @str_Is_LWF
		SET @qry = 'Update dbo.T0080_EMP_MASTER	Set	' + @Column_Name + ' = ' + @Column_Value + ' Where Emp_Id = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR) -- + ' and Increment_ID =' + cast(@Inc_id  AS NVARCHAR)
	END
	ELSE IF @Column_Name = 'Min_Compoff_Limit'
	BEGIN
		SET @Column_Name = 'CompOff_Min_hrs'

		DECLARE @str_CompOff_Min_hrs VARCHAR(200)

		SET @qry_1 = 'Select @str_CompOff_Min_hrs = ' + Cast(@Column_Name AS VARCHAR(500)) + ' From T0080_EMP_MASTER WITH (NOLOCK) Where Emp_ID = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR)

		EXEC sp_executesql @qry_1
			,N'@str_CompOff_Min_hrs varchar(max) output'
			,@str_CompOff_Min_hrs OUTPUT

		SET @OldValue = 'Old Value' + '#' + @Column_Name + ' : ' + @str_CompOff_Min_hrs
		SET @qry = 'Update dbo.T0080_EMP_MASTER	Set	' + @Column_Name + ' = ''' + @Column_Value + ''' Where Emp_Id = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR)
	END
	ELSE IF @Column_Name = 'Confirmation_Date'
	BEGIN
		SET @Column_Name = 'Emp_Confirm_Date'

		DECLARE @str_Emp_Confirm_Date VARCHAR(200)

		SET @qry_1 = 'Select @str_Emp_Confirm_Date = ' + Cast(@Column_Name AS VARCHAR(500)) + ' From T0080_EMP_MASTER WITH (NOLOCK) Where Emp_ID = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR)

		EXEC sp_executesql @qry_1
			,N'@str_Emp_Confirm_Date varchar(max) output'
			,@str_Emp_Confirm_Date OUTPUT

		SET @OldValue = 'Old Value' + '#' + @Column_Name + ' : ' + @str_Emp_Confirm_Date
		SET @qry = 'Update dbo.T0080_EMP_MASTER	Set	' + @Column_Name + ' = ''' + @Column_Value + ''' Where Emp_Id = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR)
	END
	ELSE IF @Column_Name = 'Is_Probation'
	BEGIN
		SET @Column_Name = 'is_on_Probation'

		DECLARE @str_is_on_Probation VARCHAR(200)

		SET @qry_1 = 'Select @str_is_on_Probation = ' + Cast(@Column_Name AS VARCHAR(500)) + ' From T0080_EMP_MASTER WITH (NOLOCK) Where Emp_ID = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR)

		EXEC sp_executesql @qry_1
			,N'@str_is_on_Probation varchar(max) output'
			,@str_is_on_Probation OUTPUT

		SET @OldValue = 'Old Value' + '#' + @Column_Name + ' : ' + @str_is_on_Probation
		SET @qry = 'Update dbo.T0080_EMP_MASTER	Set	' + @Column_Name + ' = ' + @Column_Value + ' Where Emp_Id = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR)
	END
	ELSE IF @Column_Name = 'Probation'
	BEGIN
		SET @Column_Name = 'Probation'

		DECLARE @str_Probation VARCHAR(200)

		SET @qry_1 = 'Select @str_Probation = ' + Cast(@Column_Name AS VARCHAR(500)) + ' From T0080_EMP_MASTER WITH (NOLOCK) Where Emp_ID = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR)

		EXEC sp_executesql @qry_1
			,N'@str_Probation varchar(max) output'
			,@str_Probation OUTPUT

		SET @OldValue = 'Old Value' + '#' + @Column_Name + ' : ' + @str_Probation
		SET @qry = 'Update dbo.T0080_EMP_MASTER	Set	' + @Column_Name + ' = ' + @Column_Value + ' Where Emp_Id = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR)
	END
	ELSE IF @Column_Name = 'Gender'
	BEGIN
		IF @Column_Value = 0
		BEGIN
			SET @Column_Value = 'M'
		END
		ELSE
		BEGIN
			SET @Column_Value = 'F'
		END

		DECLARE @str_Gender VARCHAR(200)

		SET @qry_1 = 'Select @str_Gender = ' + Cast(@Column_Name AS VARCHAR(500)) + ' From T0080_EMP_MASTER WITH (NOLOCK) Where Emp_ID = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR)

		EXEC sp_executesql @qry_1
			,N'@str_Gender varchar(max) output'
			,@str_Gender OUTPUT

		SET @OldValue = 'Old Value' + '#' + @Column_Name + ' : ' + @str_Gender
		SET @qry = 'Update dbo.T0080_EMP_MASTER	Set	' + @Column_Name + ' = ''' + @Column_Value + ''' Where Emp_Id = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR)
	END
	ELSE IF @Column_Name = 'Dress_Code'
	BEGIN
		SET @Column_Name = 'Emp_Dress_Code'

		DECLARE @str_Emp_Dress_Code VARCHAR(200)

		SET @qry_1 = 'Select @str_Emp_Dress_Code = ' + Cast(@Column_Name AS VARCHAR(500)) + ' From T0080_EMP_MASTER WITH (NOLOCK) Where Emp_ID = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR)

		EXEC sp_executesql @qry_1
			,N'@str_Emp_Dress_Code varchar(max) output'
			,@str_Emp_Dress_Code OUTPUT

		SET @OldValue = 'Old Value' + '#' + @Column_Name + ' : ' + @str_Emp_Dress_Code
		SET @qry = 'Update dbo.T0080_EMP_MASTER	Set	' + @Column_Name + ' = ''' + @Column_Value + ''' Where Emp_Id = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR)
	END
	ELSE IF @Column_Name = 'Shirt_Size'
	BEGIN
		SET @Column_Name = 'Emp_Shirt_Size'

		DECLARE @str_Emp_Shirt_Size VARCHAR(200)

		SET @qry_1 = 'Select @str_Emp_Shirt_Size = ' + Cast(@Column_Name AS VARCHAR(500)) + ' From T0080_EMP_MASTER WITH (NOLOCK) Where Emp_ID = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR)

		EXEC sp_executesql @qry_1
			,N'@str_Emp_Shirt_Size varchar(max) output'
			,@str_Emp_Shirt_Size OUTPUT

		SET @OldValue = 'Old Value' + '#' + @Column_Name + ' : ' + @str_Emp_Shirt_Size
		SET @qry = 'Update dbo.T0080_EMP_MASTER	Set	' + @Column_Name + ' = ''' + @Column_Value + ''' Where Emp_Id = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR)
	END
	ELSE IF @Column_Name = 'Pent_Size'
	BEGIN
		SET @Column_Name = 'Emp_Pent_Size'

		DECLARE @str_Emp_Pent_Size VARCHAR(200)

		SET @qry_1 = 'Select @str_Emp_Pent_Size = ' + Cast(@Column_Name AS VARCHAR(500)) + ' From T0080_EMP_MASTER WITH (NOLOCK) Where Emp_ID = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR)

		EXEC sp_executesql @qry_1
			,N'@str_Emp_Pent_Size varchar(max) output'
			,@str_Emp_Pent_Size OUTPUT

		SET @OldValue = 'Old Value' + '#' + @Column_Name + ' : ' + @str_Emp_Pent_Size
		SET @qry = 'Update dbo.T0080_EMP_MASTER	Set	' + @Column_Name + ' = ''' + @Column_Value + ''' Where Emp_Id = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR)
	END
	ELSE IF @Column_Name = 'Shoe_Size'
	BEGIN
		SET @Column_Name = 'Emp_Shoe_Size'

		DECLARE @str_Emp_Shoe_Size VARCHAR(200)

		SET @qry_1 = 'Select @str_Emp_Shoe_Size = ' + Cast(@Column_Name AS VARCHAR(500)) + ' From T0080_EMP_MASTER WITH (NOLOCK) Where Emp_ID = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR)

		EXEC sp_executesql @qry_1
			,N'@str_Emp_Shoe_Size varchar(max) output'
			,@str_Emp_Shoe_Size OUTPUT

		SET @OldValue = 'Old Value' + '#' + @Column_Name + ' : ' + @str_Emp_Shoe_Size
		SET @qry = 'Update dbo.T0080_EMP_MASTER	Set	' + @Column_Name + ' = ''' + @Column_Value + ''' Where Emp_Id = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR)
	END
	ELSE IF @Column_Name = 'Canteen_Code'
	BEGIN
		SET @Column_Name = 'Emp_Canteen_Code'

		DECLARE @str_Emp_Canteen_Code VARCHAR(200)

		SET @qry_1 = 'Select @str_Emp_Canteen_Code = ' + Cast(@Column_Name AS VARCHAR(500)) + ' From T0080_EMP_MASTER WITH (NOLOCK) Where Emp_ID = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR)

		EXEC sp_executesql @qry_1
			,N'@str_Emp_Canteen_Code varchar(max) output'
			,@str_Emp_Canteen_Code OUTPUT

		SET @OldValue = 'Old Value' + '#' + @Column_Name + ' : ' + @str_Emp_Canteen_Code
		SET @qry = 'Update dbo.T0080_EMP_MASTER	Set	' + @Column_Name + ' = ''' + @Column_Value + ''' Where Emp_Id = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR)
	END
	ELSE IF @Column_Name = 'Permanent_Tehsil'
	BEGIN
		SET @Column_Name = 'Tehsil'

		DECLARE @str_Tehsil VARCHAR(200)

		SET @qry_1 = 'Select @str_Tehsil = ' + Cast(@Column_Name AS VARCHAR(500)) + ' From T0080_EMP_MASTER WITH (NOLOCK) Where Emp_ID = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR)

		EXEC sp_executesql @qry_1
			,N'@str_Tehsil varchar(max) output'
			,@str_Tehsil OUTPUT

		SET @OldValue = 'Old Value' + '#' + @Column_Name + ' : ' + @str_Tehsil
		SET @qry = 'Update dbo.T0080_EMP_MASTER	Set	' + @Column_Name + ' = ''' + @Column_Value + ''' Where Emp_Id = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR)
	END
	ELSE IF @Column_Name = 'Permanent_District'
	BEGIN
		SET @Column_Name = 'District'

		DECLARE @str_District VARCHAR(200)

		SET @qry_1 = 'Select @str_District = ' + Cast(@Column_Name AS VARCHAR(500)) + ' From T0080_EMP_MASTER WITH (NOLOCK) Where Emp_ID = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR)

		EXEC sp_executesql @qry_1
			,N'@str_District varchar(max) output'
			,@str_District OUTPUT

		SET @OldValue = 'Old Value' + '#' + @Column_Name + ' : ' + @str_District
		SET @qry = 'Update dbo.T0080_EMP_MASTER	Set	' + @Column_Name + ' = ''' + @Column_Value + ''' Where Emp_Id = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR)
	END
	ELSE IF @Column_Name = 'Working_Tehsil'
	BEGIN
		SET @Column_Name = 'Tehsil_Wok'

		DECLARE @str_Tehsil_Wok VARCHAR(200)

		SET @qry_1 = 'Select @str_Tehsil_Wok = ' + Cast(@Column_Name AS VARCHAR(500)) + ' From T0080_EMP_MASTER WITH (NOLOCK) Where Emp_ID = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR)

		EXEC sp_executesql @qry_1
			,N'@str_Tehsil_Wok varchar(max) output'
			,@str_Tehsil_Wok OUTPUT

		SET @OldValue = 'Old Value' + '#' + @Column_Name + ' : ' + @str_Tehsil_Wok
		SET @qry = 'Update dbo.T0080_EMP_MASTER	Set	' + @Column_Name + ' = ''' + @Column_Value + ''' Where Emp_Id = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR)
	END
	ELSE IF @Column_Name = 'Working_District'
	BEGIN
		SET @Column_Name = 'District_Wok'

		DECLARE @str_District_Wok VARCHAR(200)

		SET @qry_1 = 'Select @str_District_Wok = ' + Cast(@Column_Name AS VARCHAR(500)) + ' From T0080_EMP_MASTER WITH (NOLOCK) Where Emp_ID = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR)

		EXEC sp_executesql @qry_1
			,N'@str_District_Wok varchar(max) output'
			,@str_District_Wok OUTPUT

		SET @OldValue = 'Old Value' + '#' + @Column_Name + ' : ' + @str_District_Wok
		SET @qry = 'Update dbo.T0080_EMP_MASTER	Set	' + @Column_Name + ' = ''' + @Column_Value + ''' Where Emp_Id = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR)
	END
	ELSE IF @Column_Name = 'Permanent_Thana'
	BEGIN
		SET @Column_Name = 'Thana_Id'

		DECLARE @P_Thana_Id AS NUMERIC

		SET @P_Thana_Id = 0

		IF EXISTS (
				SELECT Thana_Id
				FROM T0030_Thana_Master WITH (NOLOCK)
				WHERE Cmp_Id = @Cmp_ID
					AND UPPER(ThanaName) = UPPER(@Column_Value)
				)
		BEGIN
			SELECT @P_Thana_Id = Thana_Id
			FROM dbo.T0030_Thana_Master WITH (NOLOCK)
			WHERE Cmp_Id = Cmp_Id
				AND ThanaName = @Column_Value
		END
		ELSE
		BEGIN
			SELECT @P_Thana_Id = Isnull(max(Thana_Id), 0) + 1
			FROM dbo.T0030_Thana_Master WITH (NOLOCK)

			INSERT INTO T0030_Thana_Master
			VALUES (
				@P_Thana_Id
				,@Cmp_ID
				,@Column_Value
				)
		END

		DECLARE @str_Thana_Id VARCHAR(200)

		SET @qry_1 = 'Select @str_Thana_Id = ' + Cast(@Column_Name AS VARCHAR(500)) + ' From T0080_EMP_MASTER WITH (NOLOCK) Where Emp_ID = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR)

		EXEC sp_executesql @qry_1
			,N'@str_Thana_Id varchar(max) output'
			,@str_Thana_Id OUTPUT

		SET @OldValue = 'Old Value' + '#' + @Column_Name + ' : ' + @str_Thana_Id
		SET @Column_Value = CAST(@P_Thana_Id AS NVARCHAR)
		SET @qry = 'Update dbo.T0080_EMP_MASTER	Set	' + @Column_Name + ' = ' + @Column_Value + ' Where Emp_Id = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR)
	END
	ELSE IF @Column_Name = 'Working_Thana'
	BEGIN
		SET @Column_Name = 'Thana_Id_Wok'

		DECLARE @W_Thana_Id AS NUMERIC

		SET @W_Thana_Id = 0

		IF EXISTS (
				SELECT Thana_Id
				FROM T0030_Thana_Master WITH (NOLOCK)
				WHERE Cmp_Id = @Cmp_ID
					AND UPPER(ThanaName) = UPPER(@Column_Value)
				)
		BEGIN
			SELECT @W_Thana_Id = Thana_Id
			FROM dbo.T0030_Thana_Master WITH (NOLOCK)
			WHERE Cmp_Id = Cmp_Id
				AND ThanaName = @Column_Value
		END
		ELSE
		BEGIN
			SELECT @W_Thana_Id = Isnull(max(Thana_Id), 0) + 1
			FROM dbo.T0030_Thana_Master WITH (NOLOCK)

			INSERT INTO T0030_Thana_Master
			VALUES (
				@W_Thana_Id
				,@Cmp_ID
				,@Column_Value
				)
		END

		DECLARE @str_Thana_Id_Wok VARCHAR(200)

		SET @qry_1 = 'Select @str_Thana_Id_Wok = ' + Cast(@Column_Name AS VARCHAR(500)) + ' From T0080_EMP_MASTER WITH (NOLOCK) Where Emp_ID = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR)

		EXEC sp_executesql @qry_1
			,N'@str_Thana_Id_Wok varchar(max) output'
			,@str_Thana_Id_Wok OUTPUT

		SET @OldValue = 'Old Value' + '#' + @Column_Name + ' : ' + @str_Thana_Id_Wok
		SET @Column_Value = CAST(@W_Thana_Id AS NVARCHAR)
		SET @qry = 'Update dbo.T0080_EMP_MASTER	Set	' + @Column_Name + ' = ' + @Column_Value + ' Where Emp_Id = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR)
	END
	ELSE IF @Column_Name = 'Bank_Account_No_2'
	BEGIN
		SET @Column_Name = 'Inc_Bank_AC_No_Two'

		DECLARE @str_Inc_Bank_AC_No_Two VARCHAR(200)

		SET @qry_1 = 'Select @str_Inc_Bank_AC_No_Two = ' + Cast(@Column_Name AS VARCHAR(500)) + ' From T0095_Increment WITH (NOLOCK) Where Emp_ID = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR) + 'and Increment_ID =' + CAST(@Inc_id AS NVARCHAR)

		EXEC sp_executesql @qry_1
			,N'@str_Inc_Bank_AC_No_Two varchar(max) output'
			,@str_Inc_Bank_AC_No_Two OUTPUT

		SET @OldValue = 'Old Value' + '#' + @Column_Name + ' : ' + @str_Inc_Bank_AC_No_Two
		SET @qry = 'Update dbo.T0095_Increment	Set	' + @Column_Name + ' = ''' + @Column_Value + ''' Where Emp_Id = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR) + 'and Increment_ID =' + CAST(@Inc_id AS NVARCHAR)
	END
	ELSE IF @Column_Name = 'Emp_Childran'
	BEGIN
		SET @Column_Name = 'Emp_Childran'

		DECLARE @str_Emp_Childran VARCHAR(200)

		SET @qry_1 = 'Select @str_Emp_Childran = ' + Cast(@Column_Name AS VARCHAR(500)) + ' From T0095_Increment WITH (NOLOCK) Where Emp_ID = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR) + 'and Increment_ID =' + CAST(@Inc_id AS NVARCHAR)

		EXEC sp_executesql @qry_1
			,N'@str_Emp_Childran varchar(max) output'
			,@str_Emp_Childran OUTPUT

		SET @OldValue = 'Old Value' + '#' + @Column_Name + ' : ' + @str_Emp_Childran
		SET @qry = 'Update dbo.T0095_Increment	Set	' + @Column_Name + ' = ''' + @Column_Value + ''' Where Emp_Id = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR) + 'and Increment_ID =' + CAST(@Inc_id AS NVARCHAR)
	END
	ELSE IF @Column_Name = 'Bank_Name_2'
	BEGIN
		SET @Column_Name = 'Bank_ID_Two'

		DECLARE @str_Bank_ID_Two VARCHAR(200)

		SET @qry_1 = 'Select @str_Bank_ID_Two = ' + Cast(@Column_Name AS VARCHAR(500)) + ' From T0095_Increment WITH (NOLOCK) Where Emp_ID = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR) + 'and Increment_ID =' + CAST(@Inc_id AS NVARCHAR)

		EXEC sp_executesql @qry_1
			,N'@str_Bank_ID_Two varchar(max) output'
			,@str_Bank_ID_Two OUTPUT

		SET @OldValue = 'Old Value' + '#' + @Column_Name + ' : ' + @str_Bank_ID_Two

		SELECT @Column_Value = Bank_id
		FROM T0040_BANK_MASTER WITH (NOLOCK)
		WHERE Bank_Name = @Column_Value
			AND Cmp_Id = @Cmp_ID

		SET @qry = 'Update dbo.T0095_Increment	Set	' + @Column_Name + ' = ''' + @Column_Value + ''' Where Emp_Id = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR) + 'and Increment_ID =' + Cast(@Inc_id AS NVARCHAR)
	END
			--Added by Hardik 20/02/2015
	ELSE IF @Column_Name = 'Bank_Branch_Name'
	BEGIN
		SET @Column_Name = 'Bank_Branch_Name'

		DECLARE @str_Bank_Branch_Name VARCHAR(200)

		SET @qry_1 = 'Select @str_Bank_Branch_Name = ' + Cast(@Column_Name AS VARCHAR(500)) + ' From T0095_Increment WITH (NOLOCK) Where Emp_ID = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR) + 'and Increment_ID =' + CAST(@Inc_id AS NVARCHAR)

		EXEC sp_executesql @qry_1
			,N'@str_Bank_Branch_Name varchar(max) output'
			,@str_Bank_Branch_Name OUTPUT

		SET @OldValue = 'Old Value' + '#' + @Column_Name + ' : ' + @str_Bank_Branch_Name
		SET @qry = 'Update dbo.T0095_Increment	Set	' + @Column_Name + ' = ''' + @Column_Value + ''' Where Emp_Id = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR) + 'and Increment_ID =' + Cast(@Inc_id AS NVARCHAR)
	END
	ELSE IF @Column_Name = 'Bank_Branch_Name_Two'
	BEGIN
		SET @Column_Name = 'Bank_Branch_Name_Two'

		DECLARE @str_Bank_Branch_Name_Two VARCHAR(200)

		SET @qry_1 = 'Select @str_Bank_Branch_Name_Two = ' + Cast(@Column_Name AS VARCHAR(500)) + ' From T0095_Increment WITH (NOLOCK) Where Emp_ID = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR) + 'and Increment_ID =' + CAST(@Inc_id AS NVARCHAR)

		EXEC sp_executesql @qry_1
			,N'@str_Bank_Branch_Name_Two varchar(max) output'
			,@str_Bank_Branch_Name_Two OUTPUT

		SET @OldValue = 'Old Value' + '#' + @Column_Name + ' : ' + @str_Bank_Branch_Name_Two
		SET @qry = 'Update dbo.T0095_Increment	Set	' + @Column_Name + ' = ''' + @Column_Value + ''' Where Emp_Id = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR) + 'and Increment_ID =' + Cast(@Inc_id AS NVARCHAR)
	END
	ELSE IF @Column_Name = 'Payment_Mode_Two'
	BEGIN
		SET @Column_Name = 'Payment_Mode_Two'

		DECLARE @str_Payment_Mode_Two VARCHAR(200)

		SET @qry_1 = 'Select @str_Payment_Mode_Two = ' + Cast(@Column_Name AS VARCHAR(500)) + ' From T0095_Increment WITH (NOLOCK) Where Emp_ID = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR) + 'and Increment_ID =' + CAST(@Inc_id AS NVARCHAR)

		EXEC sp_executesql @qry_1
			,N'@str_Payment_Mode_Two varchar(max) output'
			,@str_Payment_Mode_Two OUTPUT

		SET @OldValue = 'Old Value' + '#' + @Column_Name + ' : ' + @str_Payment_Mode_Two
		SET @qry = 'Update dbo.T0095_Increment	Set	' + @Column_Name + ' = ''' + @Column_Value + ''' Where Emp_Id = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR) + 'and Increment_ID =' + cast(@Inc_id AS NVARCHAR)
	END
			--Gadriwala Muslim 09052014 - End
	ELSE IF @Column_Name = 'Is_Metro_City' --Gadriwala Muslim 26072014 - End
	BEGIN
		SET @Column_Name = 'is_Metro_City'

		DECLARE @str_is_Metro_City VARCHAR(200)

		SET @qry_1 = 'Select @str_is_Metro_City = ' + Cast(@Column_Name AS VARCHAR(500)) + ' From T0095_Increment WITH (NOLOCK) Where Emp_ID = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR) + 'and Increment_ID =' + CAST(@Inc_id AS NVARCHAR)

		EXEC sp_executesql @qry_1
			,N'@str_is_Metro_City varchar(max) output'
			,@str_is_Metro_City OUTPUT

		SET @OldValue = 'Old Value' + '#' + @Column_Name + ' : ' + @str_is_Metro_City
		SET @qry = 'Update dbo.T0095_Increment	Set	' + @Column_Name + ' = ' + @Column_Value + ' Where Emp_Id = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR) + 'and Increment_ID =' + cast(@Inc_id AS NVARCHAR)
	END
			--Added by Nimesh 2015-05-11 (Salary On and Currency)			
	ELSE IF @Column_Name = 'Wages_Type'
	BEGIN
		SET @Column_Name = 'Wages_Type'

		DECLARE @str_Wages_Type VARCHAR(200)

		SET @qry_1 = 'Select @str_Wages_Type = ' + Cast(@Column_Name AS VARCHAR(500)) + ' From T0095_Increment WITH (NOLOCK) Where Emp_ID = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR) + 'and Increment_ID =' + CAST(@Inc_id AS NVARCHAR)

		EXEC sp_executesql @qry_1
			,N'@str_Wages_Type varchar(max) output'
			,@str_Wages_Type OUTPUT

		SET @OldValue = 'Old Value' + '#' + @Column_Name + ' : ' + @str_Wages_Type
		SET @qry = 'Update dbo.T0095_Increment	Set	' + @Column_Name + ' = ''' + @Column_Value + ''' Where Emp_Id = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR) + 'and Increment_ID =' + cast(@Inc_id AS NVARCHAR)
	END
	ELSE IF @Column_Name = 'Salary_Basis_On'
	BEGIN
		SET @Column_Name = 'Salary_Basis_On'

		DECLARE @str_Salary_Basis_On VARCHAR(200)

		SET @qry_1 = 'Select @str_Salary_Basis_On = ' + Cast(@Column_Name AS VARCHAR(500)) + ' From T0095_Increment WITH (NOLOCK) Where Emp_ID = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR) + 'and Increment_ID =' + CAST(@Inc_id AS NVARCHAR)

		EXEC sp_executesql @qry_1
			,N'@str_Salary_Basis_On varchar(max) output'
			,@str_Salary_Basis_On OUTPUT

		SET @OldValue = 'Old Value' + '#' + @Column_Name + ' : ' + @str_Salary_Basis_On
		SET @qry = 'Update dbo.T0095_Increment	Set	' + @Column_Name + ' = ''' + @Column_Value + ''' Where Emp_Id = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR) + 'and Increment_ID =' + cast(@Inc_id AS NVARCHAR)
	END
	ELSE IF @Column_Name = 'Curr_Name'
	BEGIN
		SET @Column_Name = 'Curr_ID'
		SET @Column_Value = (
				SELECT TOP 1 Curr_ID
				FROM dbo.T0040_CURRENCY_MASTER WITH (NOLOCK)
				WHERE Cmp_ID = @Cmp_ID
					AND Curr_Name = @Column_Value
				)

		DECLARE @str_Curr_ID VARCHAR(200)

		SET @qry_1 = 'Select @str_Curr_ID = ' + Cast(@Column_Name AS VARCHAR(500)) + ' From T0095_Increment WITH (NOLOCK) Where Emp_ID = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR) + 'and Increment_ID =' + CAST(@Inc_id AS NVARCHAR)

		EXEC sp_executesql @qry_1
			,N'@str_Curr_ID varchar(max) output'
			,@str_Curr_ID OUTPUT

		SET @OldValue = 'Old Value' + '#' + @Column_Name + ' : ' + @str_Curr_ID
		SET @qry = 'Update dbo.T0095_Increment	Set	' + @Column_Name + ' = ' + @Column_Value + ' Where Emp_Id = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR) + 'and Increment_ID =' + cast(@Inc_id AS NVARCHAR)

		IF (@Column_Value IS NULL)
			SET @qry = '';
	END
	ELSE IF @Column_Name = 'Late_Dedu_Type'
	BEGIN
		SET @Column_Name = 'late_Dedu_type'

		DECLARE @str_late_Dedu_type VARCHAR(200)

		SET @qry_1 = 'Select @str_late_Dedu_type = ' + Cast(@Column_Name AS VARCHAR(500)) + ' From T0095_Increment WITH (NOLOCK) Where Emp_ID = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR) + 'and Increment_ID =' + CAST(@Inc_id AS NVARCHAR)

		EXEC sp_executesql @qry_1
			,N'@str_late_Dedu_type varchar(max) output'
			,@str_late_Dedu_type OUTPUT

		SET @OldValue = 'Old Value' + '#' + @Column_Name + ' : ' + @str_late_Dedu_type
		SET @qry = 'Update dbo.T0095_Increment	Set	' + @Column_Name + ' = ''' + @Column_Value + ''' Where Emp_Id = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR) + 'and Increment_ID =' + cast(@Inc_id AS NVARCHAR)
	END
	ELSE IF @Column_Name = 'Emp_Early_Limit'
	BEGIN
		SET @Column_Name = 'Emp_Early_Limit';

		DECLARE @str_Emp_Early_Limit_1 VARCHAR(200)

		SET @qry_1 = 'Select @str_Emp_Early_Limit_1 = ' + Cast(@Column_Name AS VARCHAR(500)) + ' From T0095_Increment WITH (NOLOCK) Where Emp_ID = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR) + 'and Increment_ID =' + CAST(@Inc_id AS NVARCHAR)

		EXEC sp_executesql @qry_1
			,N'@str_Emp_Early_Limit_1 varchar(max) output'
			,@str_Emp_Early_Limit_1 OUTPUT

		SET @OldValue = 'Old Value' + '#' + @Column_Name + ' : ' + @str_Emp_Early_Limit_1
		SET @qry = 'Update dbo.T0095_Increment	Set	' + @Column_Name + ' = ''' + @Column_Value + ''' Where Emp_Id = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR) + 'and Increment_ID =' + cast(@Inc_id AS NVARCHAR)
	END
	ELSE IF @Column_Name = 'Early_Dedu_Type'
	BEGIN
		SET @Column_Name = 'Early_Dedu_type'

		DECLARE @str_Early_Dedu_type VARCHAR(200)

		SET @qry_1 = 'Select @str_Early_Dedu_type = ' + Cast(@Column_Name AS VARCHAR(500)) + ' From T0095_Increment WITH (NOLOCK) Where Emp_ID = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR) + 'and Increment_ID =' + CAST(@Inc_id AS NVARCHAR)

		EXEC sp_executesql @qry_1
			,N'@str_Early_Dedu_type varchar(max) output'
			,@str_Early_Dedu_type OUTPUT

		SET @OldValue = 'Old Value' + '#' + @Column_Name + ' : ' + @str_Early_Dedu_type
		SET @qry = 'Update dbo.T0095_Increment	Set	' + @Column_Name + ' = ''' + @Column_Value + ''' Where Emp_Id = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR) + 'and Increment_ID =' + cast(@Inc_id AS NVARCHAR)
	END
			--End: Nimesh			
	ELSE IF @Column_Name = 'UAN_No' --Hardik 08/10/2014
	BEGIN
		SET @Column_Name = 'UAN_No'

		DECLARE @str_UAN_No VARCHAR(200)

		SET @qry_1 = 'Select @str_UAN_No = ' + Cast(@Column_Name AS VARCHAR(500)) + ' From T0080_Emp_Master WITH (NOLOCK) Where Emp_ID = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR)

		EXEC sp_executesql @qry_1
			,N'@str_UAN_No varchar(max) output'
			,@str_UAN_No OUTPUT

		SET @OldValue = 'Old Value' + '#' + @Column_Name + ' : ' + @str_UAN_No
		SET @qry = 'Update dbo.T0080_Emp_Master	Set	' + @Column_Name + ' = ' + @Column_Value + ' Where Emp_Id = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR)
	END
	ELSE IF @Column_Name IN (
			SELECT replace(column_name, ' ', '_')
			FROM T0081_CUSTOMIZED_COLUMN WITH (NOLOCK)
			WHERE Cmp_Id = @Cmp_ID
				AND Active = 1
			)
	BEGIN
	
		DECLARE @mst_tran_id AS NUMERIC(18, 0)

		--select @mst_tran_id = Tran_Id  from T0081_CUSTOMIZED_COLUMN WITH (NOLOCK) where Cmp_Id=@Cmp_ID and Active=1 and column_name =  replace(cast(@Column_Name as varchar(max)),'_',' ')
		SELECT @mst_tran_id = Tran_Id
		FROM T0081_CUSTOMIZED_COLUMN WITH (NOLOCK)
		WHERE Cmp_Id = @Cmp_ID
			AND Active = 1
			AND column_name = cast(@Column_Name AS VARCHAR(max))

		IF EXISTS (
				SELECT 1
				FROM T0082_Emp_Column WITH (NOLOCK)
				WHERE mst_Tran_Id = @mst_tran_id
					AND cmp_Id = @Cmp_ID
					AND Emp_Id = @emp_id
				)
		BEGIN
			SET @qry = 'Update dbo.T0082_Emp_Column	Set	 value =''' + @Column_Value + ''' Where Emp_Id = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR) + 'and mst_tran_id = ' + cast(@mst_tran_id AS NVARCHAR) + ''
		END
		ELSE
		BEGIN
			SET @qry = 'insert into dbo.T0082_Emp_Column (mst_Tran_Id,cmp_Id,Emp_Id,Value,sys_Date) values (' + cast(@mst_tran_id AS NVARCHAR) + ',' + CAST(@Cmp_ID AS NVARCHAR) + ',' + CAST(@Emp_Id AS NVARCHAR) + ',''' + @Column_Value + ''', getdate())'

			PRINT @qry
		END
	END
	ELSE IF @Column_Name = 'Date_of_Birth' --Added by nilesh patel on 29012015
	BEGIN
		SET @Column_Name = 'Date_of_Birth'

		SELECT @Date_of_Retirement = Date_of_Retirement
		FROM T0080_EMP_MASTER WITH (NOLOCK)
		WHERE Emp_ID = @Emp_Id
			AND Cmp_ID = @Cmp_ID

		DECLARE @Retirement_Year NUMERIC(18, 0)

		SET @Retirement_Year = 0

		SELECT @Retirement_Year = Setting_Value
		FROM T0040_SETTING WITH (NOLOCK)
		WHERE cmp_id = @Cmp_ID
			AND Setting_Name = 'Employee Retirement Age'

		DECLARE @str_Date_of_Birth VARCHAR(200)

		SET @qry_1 = 'Select @str_Date_of_Birth = ' + Cast(@Column_Name AS VARCHAR(500)) + ' From T0080_Emp_Master WITH (NOLOCK)Where Emp_ID = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR)

		EXEC sp_executesql @qry_1
			,N'@str_Date_of_Birth varchar(max) output'
			,@str_Date_of_Birth OUTPUT

		IF @str_Date_of_Birth <> ''
			SET @OldValue = 'Old Value' + '#' + @Column_Name + ' : ' + Replace(Convert(VARCHAR(11), @str_Date_of_Birth, 106), ' ', '-')
		ELSE
			SET @OldValue = 'Old Value' + '#' + @Column_Name + ' : ' + @str_Date_of_Birth

		IF @Retirement_Year = 0
		BEGIN
			SET @qry = 'Update dbo.T0080_Emp_Master	Set	' + @Column_Name + ' = ''' + @Column_Value + ''' Where Emp_Id = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR)
		END
		ELSE IF @Date_of_Retirement IS NOT NULL
		BEGIN
			SET @qry = 'Update dbo.T0080_Emp_Master	Set	' + @Column_Name + ' = ''' + @Column_Value + ''' Where Emp_Id = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR)
		END
		ELSE
		BEGIN
			SET @qry = 'Update dbo.T0080_Emp_Master	Set	 ' + @Column_Name + ' = ''' + @Column_Value + ''' , Date_of_Retirement = DATEADD(YEAR,' + CAST(@Retirement_Year AS NVARCHAR) + ',''' + @Column_Value + ''')  Where Emp_Id = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR)
		END
	END
	ELSE IF @Column_Name = 'Date_of_Retirement' --Added by nilesh patel on 29012015
	BEGIN
		SET @Column_Name = 'Date_of_Retirement'

		DECLARE @str_Date_of_Retirement VARCHAR(200)

		SET @qry_1 = 'Select @str_Date_of_Retirement = ' + Cast(@Column_Name AS VARCHAR(500)) + ' From T0080_Emp_Master WITH (NOLOCK) Where Emp_ID = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR)

		EXEC sp_executesql @qry_1
			,N'@str_Date_of_Retirement varchar(max) output'
			,@str_Date_of_Retirement OUTPUT

		SET @OldValue = 'Old Value' + '#' + @Column_Name + ' : ' + @str_Date_of_Retirement
		SET @qry = 'Update dbo.T0080_Emp_Master	Set	' + @Column_Name + ' = ''' + @Column_Value + ''' Where Emp_Id = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR)
	END
	ELSE IF @Column_Name = 'HO_CompOff_Applicable_within_Days' --Ankit 09102015
	BEGIN
		DECLARE @str_CompOff_HO_App_Days VARCHAR(200)

		SELECT @str_CompOff_HO_App_Days = CompOff_HO_App_Days
		FROM T0080_Emp_Master WITH (NOLOCK)
		WHERE Emp_ID = @Emp_Id
			AND Cmp_Id = @Cmp_ID

		SET @OldValue = 'Old Value' + '#CompOff_HO_App_Days : ' + @str_CompOff_HO_App_Days
		SET @qry = 'Update dbo.T0080_EMP_MASTER	Set	CompOff_HO_App_Days  = ' + CAST(@Column_Value AS NVARCHAR) + ' Where Emp_Id = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR)
	END
	ELSE IF @Column_Name = 'HO_CompOff_Avail_within_days' --Ankit 09102015
	BEGIN
		DECLARE @str_CompOff_HO_Avail_Days VARCHAR(200)

		SELECT @str_CompOff_HO_Avail_Days = CompOff_HO_Avail_Days
		FROM T0080_Emp_Master WITH (NOLOCK)
		WHERE Emp_ID = @Emp_Id
			AND Cmp_Id = @Cmp_ID

		SET @OldValue = 'Old Value' + '#CompOff_HO_Avail_Days : ' + @str_CompOff_HO_Avail_Days
		SET @qry = 'Update dbo.T0080_EMP_MASTER	Set	CompOff_HO_Avail_Days  = ' + CAST(@Column_Value AS NVARCHAR) + ' Where Emp_Id = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR)
	END
	ELSE IF @Column_Name = 'WO_CompOff_Applicable_within_Days' --Ankit 09102015
	BEGIN
		DECLARE @str_CompOff_WO_App_Days VARCHAR(200)

		SELECT @str_CompOff_WO_App_Days = CompOff_WO_App_Days
		FROM T0080_Emp_Master WITH (NOLOCK)
		WHERE Emp_ID = @Emp_Id
			AND Cmp_Id = @Cmp_ID

		SET @OldValue = 'Old Value' + '# CompOff_WO_App_Days  : ' + @str_CompOff_WO_App_Days
		SET @qry = 'Update dbo.T0080_EMP_MASTER	Set	CompOff_WO_App_Days  = ' + CAST(@Column_Value AS NVARCHAR) + ' Where Emp_Id = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR)
	END
	ELSE IF @Column_Name = 'WO_CompOff_Avail_within_days' --Ankit 09102015
	BEGIN
		DECLARE @str_CompOff_WO_Avail_Days VARCHAR(200)

		SELECT @str_CompOff_WO_Avail_Days = CompOff_WO_Avail_Days
		FROM T0080_Emp_Master WITH (NOLOCK)
		WHERE Emp_ID = @Emp_Id
			AND Cmp_Id = @Cmp_ID

		SET @OldValue = 'Old Value' + '# CompOff_WO_Avail_Days : ' + @str_CompOff_WO_Avail_Days
		SET @qry = 'Update dbo.T0080_EMP_MASTER	Set	CompOff_WO_Avail_Days  = ' + CAST(@Column_Value AS NVARCHAR) + ' Where Emp_Id = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR)
	END
	ELSE IF @Column_Name = 'WD_CompOff_Applicable_within_Days' --Ankit 09102015
	BEGIN
		DECLARE @str_CompOff_WD_App_Days VARCHAR(200)

		SELECT @str_CompOff_WD_App_Days = CompOff_WD_App_Days
		FROM T0080_Emp_Master WITH (NOLOCK)
		WHERE Emp_ID = @Emp_Id
			AND Cmp_Id = @Cmp_ID

		SET @OldValue = 'Old Value' + '# CompOff_WD_App_Days : ' + @str_CompOff_WD_App_Days
		SET @qry = 'Update dbo.T0080_EMP_MASTER	Set	CompOff_WD_App_Days  = ' + CAST(@Column_Value AS NVARCHAR) + ' Where Emp_Id = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR)
	END
	ELSE IF @Column_Name = 'WD_CompOff_Avail_within_days' --Ankit 09102015
	BEGIN
		DECLARE @str_CompOff_WD_Avail_Days VARCHAR(200)

		SELECT @str_CompOff_WD_Avail_Days = CompOff_WD_Avail_Days
		FROM T0080_Emp_Master WITH (NOLOCK)
		WHERE Emp_ID = @Emp_Id
			AND Cmp_Id = @Cmp_ID

		SET @OldValue = 'Old Value' + '#  CompOff_WD_Avail_Days : ' + @str_CompOff_WD_Avail_Days
		SET @qry = 'Update dbo.T0080_EMP_MASTER	Set	CompOff_WD_Avail_Days  = ' + CAST(@Column_Value AS NVARCHAR) + ' Where Emp_Id = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR)
	END
			--ADDED BY RAMIZ ON 11/03/2016
	ELSE IF (
			@COLUMN_NAME = 'SKILL TYPE'
			OR @COLUMN_NAME = 'SKILL_TYPE'
			)
	BEGIN
		SET @COLUMN_NAME = 'SKILLTYPE_ID'

		IF (@COLUMN_VALUE IS NULL)
		BEGIN
			SET @QRY = '';
		END
		ELSE
		BEGIN
			SET @COLUMN_VALUE = (
					SELECT TOP 1 SKILLTYPE_ID
					FROM DBO.T0040_SKILLTYPE_MASTER WITH (NOLOCK)
					WHERE CMP_ID = @CMP_ID
						AND SKILL_NAME = @COLUMN_VALUE
					)
			SET @QRY = 'UPDATE DBO.T0080_EMP_MASTER	SET	SKILLTYPE_ID  = ' + CAST(@COLUMN_VALUE AS NVARCHAR) + ' WHERE EMP_ID = ' + CAST(@EMP_ID AS NVARCHAR) + ' AND CMP_ID = ' + CAST(@CMP_ID AS NVARCHAR)
		END
	END
	ELSE IF @COLUMN_NAME = 'IS_PHYSICALLY_DISABLED'
	BEGIN
		SET @COLUMN_NAME = 'IS_PHYSICAL'

		DECLARE @str_IS_PHYSICAL VARCHAR(200)

		SET @qry_1 = 'Select @str_IS_PHYSICAL = ' + Cast(@Column_Name AS VARCHAR(500)) + ' From T0095_INCREMENT WITH (NOLOCK) Where Emp_ID = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR) + 'AND INCREMENT_ID =' + CAST(@INC_ID AS NVARCHAR)

		EXEC sp_executesql @qry_1
			,N'@str_IS_PHYSICAL varchar(max) output'
			,@str_IS_PHYSICAL OUTPUT

		SET @OldValue = 'Old Value' + '#' + @Column_Name + ' : ' + @str_IS_PHYSICAL
		SET @QRY = 'UPDATE DBO.T0095_INCREMENT	SET	' + @COLUMN_NAME + ' = ''' + @COLUMN_VALUE + ''' WHERE EMP_ID = ' + CAST(@EMP_ID AS NVARCHAR) + ' AND CMP_ID = ' + CAST(@CMP_ID AS NVARCHAR) + 'AND INCREMENT_ID =' + CAST(@INC_ID AS NVARCHAR)
	END
			--ENDED BY RAMIZ ON 11/03/2016					
	ELSE IF @COLUMN_NAME = 'Present_State_Name' --Ankit 05042016
	BEGIN
		SET @Column_Name = 'Present_State'

		DECLARE @str_Present_State VARCHAR(200)

		SET @qry_1 = 'Select @str_Present_State = ' + Cast(@Column_Name AS VARCHAR(500)) + ' From T0080_EMP_MASTER WITH (NOLOCK) Where Emp_ID = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR)

		EXEC sp_executesql @qry_1
			,N'@str_Present_State varchar(max) output'
			,@str_Present_State OUTPUT

		SET @OldValue = 'Old Value' + '#' + @Column_Name + ' : ' + @str_Present_State
		SET @qry = 'Update dbo.T0080_EMP_MASTER	Set	' + @Column_Name + ' = ''' + @Column_Value + ''' Where Emp_Id = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR)
	END
	ELSE IF @Column_Name = 'Customer_Audit' --Added By Jaina 09-09-2016
	BEGIN
		IF @Column_Value = ''
			SET @Column_Value = 0
		SET @qry = 'Update dbo.T0095_Increment	Set	' + @Column_Name + ' = ' + @Column_Value + ' Where Emp_Id = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR) + ' and Increment_ID =' + cast(@Inc_id AS NVARCHAR)
	END
	ELSE IF @Column_Name = 'Sales_Code' --Added By Ramiz 08122016
	BEGIN
		DECLARE @str_Sales_code VARCHAR(200)

		SET @qry_1 = 'Select @str_Sales_code = ' + Cast(@Column_Name AS VARCHAR(500)) + ' From T0095_Increment WITH (NOLOCK) Where Emp_ID = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR) + 'AND INCREMENT_ID =' + CAST(@INC_ID AS NVARCHAR)

		EXEC sp_executesql @qry_1
			,N'@str_Sales_code varchar(max) output'
			,@str_Sales_code OUTPUT

		SET @OldValue = 'Old Value' + '#' + @Column_Name + ' : ' + @str_Sales_code
		SET @qry = 'Update dbo.T0095_Increment	Set	' + @Column_Name + ' = ''' + @Column_Value + ''' Where Emp_Id = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR) + ' and Increment_ID =' + cast(@Inc_id AS NVARCHAR)
	END
	ELSE IF @Column_Name = 'Fix_OT_Hour_Rate_WD' --Added By Ramiz 28052018
	BEGIN
		DECLARE @str_Fix_OT_Hour_Rate_WD VARCHAR(200)

		SET @qry_1 = 'Select @str_Fix_OT_Hour_Rate_WD = ' + Cast(@Column_Name AS VARCHAR(500)) + ' From T0095_Increment WITH (NOLOCK) Where Emp_ID = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR) + 'AND INCREMENT_ID =' + CAST(@INC_ID AS NVARCHAR)

		EXEC sp_executesql @qry_1
			,N'@str_Fix_OT_Hour_Rate_WD varchar(max) output'
			,@str_Fix_OT_Hour_Rate_WD OUTPUT

		SET @OldValue = 'Old Value' + '#' + @Column_Name + ' : ' + @str_Fix_OT_Hour_Rate_WD
		SET @qry = 'Update dbo.T0095_Increment	Set	' + @Column_Name + ' = ''' + @Column_Value + ''' Where Emp_Id = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR) + ' and Increment_ID IN ( ' + cast(@Inc_id AS NVARCHAR) + ',' + cast(@Inc_Salary_Id AS NVARCHAR) + ' )'
	END
	ELSE IF @Column_Name = 'Fix_OT_Hour_Rate_WO_HO' --Added By Ramiz 28052018
	BEGIN
		DECLARE @str_Fix_OT_Hour_Rate_WOHO VARCHAR(200)

		SET @qry_1 = 'Select @str_Fix_OT_Hour_Rate_WOHO = ' + Cast(@Column_Name AS VARCHAR(500)) + ' From T0095_Increment WITH (NOLOCK) Where Emp_ID = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR) + 'AND INCREMENT_ID =' + CAST(@INC_ID AS NVARCHAR)

		EXEC sp_executesql @qry_1
			,N'@str_Fix_OT_Hour_Rate_WOHO varchar(max) output'
			,@str_Fix_OT_Hour_Rate_WOHO OUTPUT

		SET @OldValue = 'Old Value' + '#' + @Column_Name + ' : ' + @str_Fix_OT_Hour_Rate_WOHO
		SET @qry = 'Update dbo.T0095_Increment	Set	' + @Column_Name + ' = ''' + @Column_Value + ''' Where Emp_Id = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR) + ' and Increment_ID IN ( ' + cast(@Inc_id AS NVARCHAR) + ',' + cast(@Inc_Salary_Id AS NVARCHAR) + ' )'
	END
	ELSE IF @COLUMN_NAME = 'PHYSICALLY_DISABLED_PERCENTAGE' --added by Krushna 05-07-2018
	BEGIN
		SET @COLUMN_NAME = 'Physical_Percent'

		DECLARE @str_DISABLED_PERCENTAGE VARCHAR(200)

		SET @qry_1 = 'Select @str_DISABLED_PERCENTAGE = ' + Cast(@Column_Name AS VARCHAR(500)) + ' From T0095_INCREMENT WITH (NOLOCK) Where Emp_ID = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR) + 'AND INCREMENT_ID =' + CAST(@INC_ID AS NVARCHAR)

		EXEC sp_executesql @qry_1
			,N'@str_DISABLED_PERCENTAGE varchar(max) output'
			,@str_DISABLED_PERCENTAGE OUTPUT

		SET @OldValue = 'Old Value' + '#' + @Column_Name + ' : ' + @str_IS_PHYSICAL
		SET @QRY = 'UPDATE DBO.T0095_INCREMENT	SET	' + @COLUMN_NAME + ' = ''' + @COLUMN_VALUE + ''' WHERE EMP_ID = ' + CAST(@EMP_ID AS NVARCHAR) + ' AND CMP_ID = ' + CAST(@CMP_ID AS NVARCHAR) + 'AND INCREMENT_ID =' + CAST(@INC_ID AS NVARCHAR)
	END
			--------------------------------------------------------------------------Added by ronakk 07062022 -----------------------------------------------------
	ELSE IF @Column_Name = 'Emp_Fav_Sports_Name'
	BEGIN
		DECLARE @str_Emp_FavSportName NVARCHAR(1000)
		DECLARE @str_Emp_FavSportId NVARCHAR(500)

		SELECT @str_Emp_FavSportName = Emp_Fav_Sport_Name
			,@str_Emp_FavSportId = Emp_Fav_Sport_id
		FROM T0080_EMP_MASTER
		WHERE Emp_ID = @Emp_Id
			AND Cmp_Id = @Cmp_ID

		SET @OldValue = 'Old Value' + '#' + 'Emp_Fav_Sport_Name' + ' : ' + @str_Emp_FavSportName + '#, Old Value' + '#' + 'Emp_Fav_Sport_id' + ' : ' + @str_Emp_FavSportId + ' #'

		DECLARE @FavSportVal NVARCHAR(1000) = @Column_Value
		DECLARE @SportID AS NVARCHAR(max)
		DECLARE @SportName AS NVARCHAR(max)

		SELECT @SportID = COALESCE(@SportID + ',' + cast(FS_ID AS NVARCHAR), cast(FS_ID AS NVARCHAR))
			,@SportName = COALESCE(@SportName + ',' + cast(Sport_Name AS NVARCHAR), cast(Sport_Name AS NVARCHAR))
		FROM T0040_Fav_Sport_Master
		WHERE Cmp_ID = @Cmp_ID
			AND Sport_Name IN (
				SELECT cast(data AS NVARCHAR)
				FROM dbo.Split(@FavSportVal, ',') T
				WHERE T.Data <> ''
				)

		DECLARE @NewVal AS NVARCHAR(max)

		SET @NewVal = 'New Value' + '#' + 'Emp_Fav_Sport_Name' + ' : ' + @SportName + '#, New Value' + '#' + 'Emp_Fav_Sport_id' + ' : ' + @SportID + ' #'
		SET @OldValue = @NewVal + ' ' + @OldValue
		SET @qry = 'Update dbo.T0080_EMP_MASTER
						Set	Emp_Fav_Sport_id = ''' + @SportID + ''' , Emp_Fav_Sport_Name = ''' + @SportName + '''  Where Emp_Id = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR)
	END
	ELSE IF @Column_Name = 'Employee_Hobby'
	BEGIN
		DECLARE @str_Emp_HobbyName NVARCHAR(1000)
		DECLARE @str_Emp_HobbyId NVARCHAR(500)

		SELECT @str_Emp_HobbyName = Emp_Hobby_Name
			,@str_Emp_HobbyId = Emp_Hobby_id
		FROM T0080_EMP_MASTER
		WHERE Emp_ID = @Emp_Id
			AND Cmp_Id = @Cmp_ID

		SET @OldValue = 'Old Value' + '#' + 'Emp_Hobby_Name' + ' : ' + @str_Emp_HobbyName + '#, Old Value' + '#' + 'Emp_Hobby_id' + ' : ' + @str_Emp_HobbyId + ' #'

		DECLARE @HobbyVal NVARCHAR(1000) = @Column_Value
		DECLARE @HobbyID AS NVARCHAR(max)
		DECLARE @HobName AS NVARCHAR(max)

		SELECT @HobbyID = COALESCE(@HobbyID + ',' + cast(H_ID AS NVARCHAR), cast(H_ID AS NVARCHAR))
			,@HobName = COALESCE(@HobName + ',' + cast(HobbyName AS NVARCHAR), cast(HobbyName AS NVARCHAR))
		FROM T0040_Hobby_Master
		WHERE Cmp_ID = @Cmp_ID
			AND HobbyName IN (
				SELECT cast(data AS NVARCHAR)
				FROM dbo.Split(@HobbyVal, ',') T
				WHERE T.Data <> ''
				)

		DECLARE @New AS NVARCHAR(max)

		SET @New = 'New Value' + '#' + 'Emp_Hobby_Name' + ' : ' + @HobName + '#, New Value' + '#' + 'Emp_Hobby_id' + ' : ' + @HobbyID + ' #'
		SET @OldValue = @New + ' ' + @OldValue
		SET @qry = 'Update dbo.T0080_EMP_MASTER
						Set	Emp_Hobby_id = ''' + @HobbyID + ''' , Emp_Hobby_Name = ''' + @HobName + '''  Where Emp_Id = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR)
	END
	ELSE IF @Column_Name = 'Emp_Fav_Food'
	BEGIN
		DECLARE @str_Emp_Fav_Food VARCHAR(200)

		SET @qry_1 = 'Select @str_Emp_Fav_Food = Emp_Fav_Food From T0080_EMP_MASTER  WITH (NOLOCK) Where Emp_ID = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR)

		EXEC sp_executesql @qry_1
			,N'@str_Emp_Fav_Food varchar(max) output'
			,@str_Emp_Fav_Food OUTPUT

		SET @OldValue = 'Old Value' + '#Emp_Fav_Food : ' + @str_Emp_Fav_Food
		SET @qry = 'Update dbo.T0080_EMP_MASTER
						Set	Emp_Fav_Food = ''' + @Column_Value + ''' Where Emp_Id = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR)
	END
	ELSE IF @Column_Name = 'Emp_Fav_Restaurant'
	BEGIN
		DECLARE @str_Emp_Fav_Restro VARCHAR(200)

		SET @qry_1 = 'Select @str_Emp_Fav_Restro = Emp_Fav_Restro From T0080_EMP_MASTER  WITH (NOLOCK) Where Emp_ID = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR)

		EXEC sp_executesql @qry_1
			,N'@str_Emp_Fav_Restro varchar(max) output'
			,@str_Emp_Fav_Restro OUTPUT

		SET @OldValue = 'Old Value' + '#Emp_Fav_Restro : ' + @str_Emp_Fav_Restro
		SET @qry = 'Update dbo.T0080_EMP_MASTER
						Set	Emp_Fav_Restro = ''' + @Column_Value + ''' Where Emp_Id = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR)
	END
	ELSE IF @Column_Name = 'Emp_Fav_Travel_Destination'
	BEGIN
		DECLARE @str_Emp_Fav_Trv_Dst VARCHAR(200)

		SET @qry_1 = 'Select @str_Emp_Fav_Trv_Dst = Emp_Fav_Trv_Destination From T0080_EMP_MASTER  WITH (NOLOCK) Where Emp_ID = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR)

		EXEC sp_executesql @qry_1
			,N'@str_Emp_Fav_Trv_Dst varchar(max) output'
			,@str_Emp_Fav_Trv_Dst OUTPUT

		SET @OldValue = 'Old Value' + '#Emp_Fav_Trv_Destination : ' + @str_Emp_Fav_Trv_Dst
		SET @qry = 'Update dbo.T0080_EMP_MASTER
						Set	Emp_Fav_Trv_Destination = ''' + @Column_Value + ''' Where Emp_Id = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR)
	END
	ELSE IF @Column_Name = 'Emp_Fav_Festival'
	BEGIN
		DECLARE @str_Emp_Fav_Fest VARCHAR(200)

		SET @qry_1 = 'Select @str_Emp_Fav_Fest = Emp_Fav_Festival From T0080_EMP_MASTER  WITH (NOLOCK) Where Emp_ID = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR)

		EXEC sp_executesql @qry_1
			,N'@str_Emp_Fav_Fest varchar(max) output'
			,@str_Emp_Fav_Fest OUTPUT

		SET @OldValue = 'Old Value' + '#Emp_Fav_Festival : ' + @str_Emp_Fav_Fest
		SET @qry = 'Update dbo.T0080_EMP_MASTER
						Set	Emp_Fav_Festival = ''' + @Column_Value + ''' Where Emp_Id = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR)
	END
	ELSE IF @Column_Name = 'Emp_Fav_Sport_Person'
	BEGIN
		DECLARE @str_Emp_Fav_SpPer VARCHAR(200)

		SET @qry_1 = 'Select @str_Emp_Fav_SpPer = Emp_Fav_SportPerson From T0080_EMP_MASTER  WITH (NOLOCK) Where Emp_ID = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR)

		EXEC sp_executesql @qry_1
			,N'@str_Emp_Fav_SpPer varchar(max) output'
			,@str_Emp_Fav_SpPer OUTPUT

		SET @OldValue = 'Old Value' + '#Emp_Fav_SportPerson : ' + @str_Emp_Fav_SpPer
		SET @qry = 'Update dbo.T0080_EMP_MASTER
						Set	Emp_Fav_SportPerson = ''' + @Column_Value + ''' Where Emp_Id = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR)
	END
	ELSE IF @Column_Name = 'Emp_Fav_Singer'
	BEGIN
		DECLARE @str_Emp_Fav_Singer VARCHAR(200)

		SET @qry_1 = 'Select @str_Emp_Fav_Singer = Emp_Fav_Singer From T0080_EMP_MASTER  WITH (NOLOCK) Where Emp_ID = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR)

		EXEC sp_executesql @qry_1
			,N'@str_Emp_Fav_Singer varchar(max) output'
			,@str_Emp_Fav_Singer OUTPUT

		SET @OldValue = 'Old Value' + '#Emp_Fav_Singer : ' + @str_Emp_Fav_Singer
		SET @qry = 'Update dbo.T0080_EMP_MASTER
						Set	Emp_Fav_Singer = ''' + @Column_Value + ''' Where Emp_Id = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR)
	END
	ELSE IF @Column_Name = 'FullPension' -- Deepal 01102024
	BEGIN
		SET @Column_Name = 'FullPension'
		IF @Column_Value = '1'
			SET @Column_Value = 1
		ELSE
			SET @Column_Value = 0

		SET @qry = 'Update dbo.T0095_Increment	Set	' + @Column_Name + ' = ' + @Column_Value + ' Where Emp_Id = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR) + ' and Increment_ID =' + cast(@Inc_id AS NVARCHAR)
	END -- Deepal 01102024
			-----------------------------------------------------------------------------End  by ronakk 07062022 -----------------------------------------------------------------		
	ELSE IF @Column_Name <> ''
		AND @Flag_ID <> 1 --and @Column_Name <> 'Is_for_Mobile_Access'  --Restricting the Import Provision of Mobile Acces , As Validations are only Checked at Page Level;
	BEGIN
	
		DECLARE @str_Other VARCHAR(200)

		SET @qry_1 = 'Select @str_Other = ' + Cast(@Column_Name AS VARCHAR(500)) + ' From T0080_EMP_MASTER  WITH (NOLOCK) Where Emp_ID = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR)

		EXEC sp_executesql @qry_1
			,N'@str_Other varchar(max) output'
			,@str_Other OUTPUT

		SET @OldValue = 'Old Value' + '#' + @Column_Name + ' : ' + @str_Other
		SET @qry = 'Update dbo.T0080_EMP_MASTER
						Set	' + @Column_Name + ' = ''' + @Column_Value + ''' Where Emp_Id = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR)
	END
	ELSE IF @Column_Name = 'Leave_Encash_Working_days' --Added By Jimit 03022018
	BEGIN
		DECLARE @Leave_Encash_Working_days NUMERIC(18, 2)

		SELECT @Leave_Encash_Working_days = Leave_Encash_Working_days
		FROM T0080_Emp_Master WITH (NOLOCK)
		WHERE Emp_ID = @Emp_Id
			AND Cmp_Id = @Cmp_ID

		SET @OldValue = 'Old Value' + '# Leave_Encash_Working_days : ' + @Leave_Encash_Working_days
		SET @qry = 'Update dbo.T0080_EMP_MASTER	Set	Leave_Encash_Working_days  = ' + CAST(@Column_Value AS NVARCHAR) + ' Where Emp_Id = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR)
	END
	ELSE IF @Column_Name = 'Emp_Cast'
	BEGIN
		--set @Column_Name = 'Emp_Cast'
		DECLARE @str_Emp_Cast VARCHAR(200)

		SET @qry_1 = 'Select @str_Emp_Cast = ' + Cast(@Column_Name AS VARCHAR(500)) + ' From T0080_EMP_MASTER  WITH (NOLOCK) Where Emp_ID = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR)

		EXEC sp_executesql @qry_1
			,N'@str_Emp_Cast varchar(max) output'
			,@str_Emp_Cast OUTPUT

		SET @OldValue = 'Old Value' + '#' + @Column_Name + ' : ' + @str_Emp_Cast
		SET @qry = 'Update dbo.T0080_EMP_MASTER
						Set	' + @Column_Name + ' = ''' + @Column_Value + ''' Where Emp_Id = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR)
	END
	ELSE IF @Column_Name = 'Emp_Cast_Join'
	BEGIN
		--set @Column_Name = 'Emp_Cast_Join'
		DECLARE @str_Emp_Cast_Join VARCHAR(200)

		SET @qry_1 = 'Select @str_Emp_Cast_Join = ' + Cast(@Column_Name AS VARCHAR(500)) + ' From T0080_EMP_MASTER  WITH (NOLOCK) Where Emp_ID = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR)

		EXEC sp_executesql @qry_1
			,N'@str_Emp_Cast_Join varchar(max) output'
			,@str_Emp_Cast_Join OUTPUT

		SET @OldValue = 'Old Value' + '#' + @Column_Name + ' : ' + @str_Emp_Cast_Join
		SET @qry = 'Update dbo.T0080_EMP_MASTER
						Set	' + @Column_Name + ' = ''' + @Column_Value + ''' Where Emp_Id = ' + CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR)
	END
	

	EXEC (@QRY)

	DECLARE @NewValue VARCHAR(Max)

	SET @NewValue = ''

	IF @Column_Name = 'Emp_Fav_Sports_Name'
		OR @Column_Name = 'Employee_Hobby'
	BEGIN
		SET @NewValue = @OldValue
	END
	ELSE
	BEGIN
		SET @NewValue = 'New Value' + '#' + @Column_Name + ' : ' + @Column_Value + '#' + @OldValue
	END

	UPDATE T0080_EMP_MASTER
	SET System_Date = GETDATE()
	WHERE Emp_ID = @Emp_id

	EXEC P9999_Audit_Trail @Cmp_ID
		,@Tran_Type
		,'Employee Update'
		,@NewValue
		,@Emp_Id
		,@User_Id
		,@IP_Address
		,1
		,@GUID

	----- Add by jignesh Patel 25-02-2020-----
	IF @Column_Name = 'Branch_Name'
		OR @Column_Name = 'Grade'
		OR @Column_Name = 'Department'
		OR @Column_Name = 'Designation'
	BEGIN
		IF Isnull(@branch_id, 0) = 0
		BEGIN
			INSERT INTO dbo.T0080_Import_Log
			VALUES (
				0
				,@Cmp_Id
				,@Alpha_Emp_Code
				,'Branch Name is Not Proper'
				,0
				,'Please Enter Branch Name'
				,GETDATE()
				,'Employee Update'
				,''
				)
		END

		IF Isnull(@Gr_id, 0) = 0
		BEGIN
			INSERT INTO dbo.T0080_Import_Log
			VALUES (
				0
				,@Cmp_Id
				,@Alpha_Emp_Code
				,'Grade Name is Not Proper'
				,0
				,'Please Enter Grade Name'
				,GETDATE()
				,'Employee Update'
				,''
				)
		END

		IF Isnull(@dept_id, 0) = 0
		BEGIN
			INSERT INTO dbo.T0080_Import_Log
			VALUES (
				0
				,@Cmp_Id
				,@Alpha_Emp_Code
				,'Department Name is Not Proper'
				,0
				,'Please Enter Department Name'
				,GETDATE()
				,'Employee Update'
				,''
				)
		END

		IF Isnull(@desig_id, 0) = 0
		BEGIN
			INSERT INTO dbo.T0080_Import_Log
			VALUES (
				0
				,@Cmp_Id
				,@Alpha_Emp_Code
				,'Designation Name is Not Proper'
				,0
				,'Please Enter Designation Name'
				,GETDATE()
				,'Employee Update'
				,''
				)
		END
	END

	------------ End ---------------
	SET @Column_Name = ''
END

RETURN