
CREATE PROCEDURE [dbo].[SP_RPT_SCHEME_DETAILS_ESS_GET_Leave] @Cmp_ID NUMERIC
	,@From_Date DATETIME
	,@To_Date DATETIME
	,@Branch_ID NUMERIC
	,@Cat_ID NUMERIC
	,@Grd_ID NUMERIC
	,@Type_ID NUMERIC
	,@Dept_Id NUMERIC
	,@Desig_Id NUMERIC
	,@Emp_ID NUMERIC
	,@Constraint VARCHAR(max)
	,@Report_Type VARCHAR(20) = '' --Ankit 21012016  
AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

IF @Branch_ID = 0
	SET @Branch_ID = NULL

IF @Cat_ID = 0
	SET @Cat_ID = NULL

IF @Grd_ID = 0
	SET @Grd_ID = NULL

IF @Type_ID = 0
	SET @Type_ID = NULL

IF @Dept_ID = 0
	SET @Dept_ID = NULL

IF @Desig_ID = 0
	SET @Desig_ID = NULL

IF @Emp_ID = 0
	SET @Emp_ID = NULL
SET @To_Date = GETDATE()

DECLARE @Emp_Cons TABLE (Emp_ID NUMERIC)

IF @Constraint <> ''
BEGIN
	INSERT INTO @Emp_Cons
	SELECT cast(data AS NUMERIC)
	FROM dbo.Split(@Constraint, '#')
END
ELSE
BEGIN
	INSERT INTO @Emp_Cons
	SELECT DISTINCT I.Emp_Id
	FROM T0095_Increment I WITH (NOLOCK)
	INNER JOIN dbo.T0095_emp_scheme MS ON MS.Emp_ID = I.Emp_ID
	INNER JOIN (
		SELECT max(Increment_effective_Date) AS For_Date
			,Emp_ID
		FROM T0095_Increment WITH (NOLOCK)
		WHERE Increment_Effective_date <= @To_Date
			AND Cmp_ID = @Cmp_ID
		GROUP BY emp_ID
		) Qry ON I.Emp_ID = Qry.Emp_ID
		AND I.Increment_effective_Date = Qry.For_Date
	WHERE i.Cmp_ID = @Cmp_ID
		AND Isnull(Cat_ID, 0) = Isnull(@Cat_ID, Isnull(Cat_ID, 0))
		AND Branch_ID = isnull(@Branch_ID, Branch_ID)
		AND Grd_ID = isnull(@Grd_ID, Grd_ID)
		AND isnull(Dept_ID, 0) = isnull(@Dept_ID, isnull(Dept_ID, 0))
		AND Isnull(Type_ID, 0) = isnull(@Type_ID, Isnull(Type_ID, 0))
		AND Isnull(Desig_ID, 0) = isnull(@Desig_ID, Isnull(Desig_ID, 0))
		AND I.Emp_ID = isnull(@Emp_ID, I.Emp_ID)
		AND I.Emp_ID IN (
			SELECT Emp_Id
			FROM (
				SELECT emp_id
					,cmp_ID
					,join_Date
					,isnull(left_Date, @To_date) AS left_Date
				FROM T0110_EMP_LEFT_JOIN_TRAN WITH (NOLOCK)
				) qry
			WHERE cmp_ID = @Cmp_ID
				AND (
					(
						@From_Date >= join_Date
						AND @From_Date <= left_date
						)
					OR (
						@To_Date >= join_Date
						AND @To_Date <= left_date
						)
					OR Left_date IS NULL
					AND @To_Date >= Join_Date
					)
				OR @To_Date >= left_date
				AND @From_Date <= left_date
			)
END

CREATE TABLE #SCHEME (
	e_id NUMERIC
	,sc_type VARCHAR(50)
	,scheme_ID NUMERIC
	)

CREATE TABLE #EMPSCHEME (
	cmp_id1 NUMERIC
	,Cmp_Name VARCHAR(250)
	,Cmp_Address VARCHAR(250)
	,Emp_ID1 NUMERIC
	,branch_id NUMERIC
	,Alpha_Emp_Code VARCHAR(25)
	,Emp_Full_Name VARCHAR(250)
	,Scheme_Id NUMERIC
	,Leave VARCHAR(250)
	,Scheme_Type VARCHAR(50)
	,Scheme_Name VARCHAR(50)
	,Effective_Date DATETIME
	,rpt_level NUMERIC
	,Rpt_Mgr_1 VARCHAR(500)
	,Rpt_Mgr_2 VARCHAR(200)
	,Rpt_Mgr_3 VARCHAR(200)
	,Rpt_Mgr_4 VARCHAR(200)
	,Rpt_Mgr_5 VARCHAR(200)
	,Rpt_Mgr_6 VARCHAR(200)
	,--added by jaina 19-11-2020  
	Rpt_Mgr_7 VARCHAR(200)
	,Rpt_Mgr_8 VARCHAR(200)
	,Emp_First_Name VARCHAR(250)
	,Max_Level INT
	)

----------------------------------------------------------------  
DECLARE @Columns NVARCHAR(2000)
DECLARE @cmp_id1 NUMERIC
DECLARE @Emp_ID1 NUMERIC
DECLARE @Emp_Code VARCHAR(25)
DECLARE @Emp_Name VARCHAR(250)
DECLARE @Scheme_Id NUMERIC
DECLARE @Leave VARCHAR(250)
DECLARE @Scheme_Type VARCHAR(50)
DECLARE @rpt_level VARCHAR(50)
DECLARE @Effective_Date DATETIME
DECLARE @Cmp_Name VARCHAR(250)
DECLARE @Cmp_Address VARCHAR(250)
DECLARE @Rpt_Mgr_1 VARCHAR(500)
DECLARE @Rpt_Mgr_2 VARCHAR(200)
DECLARE @Rpt_Mgr_3 VARCHAR(200)
DECLARE @Rpt_Mgr_4 VARCHAR(200)
DECLARE @Rpt_Mgr_5 VARCHAR(200)
DECLARE @emp_full_name VARCHAR(250)
DECLARE @emp_First_Name VARCHAR(250)
DECLARE @val NVARCHAR(500)
DECLARE @Emp_ID2 NUMERIC
DECLARE @leave1 VARCHAR(250)
DECLARE @Scheme_Id1 NUMERIC
DECLARE @branch_Id1 NUMERIC
DECLARE @temp XML
DECLARE @temp1 XML
DECLARE @rm_name VARCHAR(250)
DECLARE @e_id NUMERIC
DECLARE @sc_type VARCHAR(50)
DECLARE @scheme_name VARCHAR(50)
DECLARE @HOD AS NUMERIC
DECLARE @e_scheme_ID NUMERIC

SET @Columns = '#'

DECLARE @non_mandatory BIT 
DECLARE @Is_display_rpt_level AS BIT 

IF ISNULL(@Report_Type, '') <> '' 
BEGIN
	DECLARE Emp_Scheme CURSOR
	FOR
	SELECT DISTINCT es.emp_id
		,es.[Type]
		,es.Scheme_ID
	FROM T0095_EMP_SCHEME es WITH (NOLOCK)
	INNER JOIN T0080_EMP_MASTER emp WITH (NOLOCK) ON emp.Emp_ID = es.Emp_ID
		AND emp.Cmp_ID = es.cmp_id
	INNER JOIN (
		SELECT max(effective_date) AS effective_date
			,emp_id
			,IES.Type
		FROM T0095_EMP_SCHEME IES WITH (NOLOCK)
		WHERE Cmp_ID = @cmp_id
			AND Emp_ID IN (
				SELECT *
				FROM @Emp_Cons
				)
			AND effective_date <= @From_Date
			AND IES.Type = @Report_Type
		GROUP BY emp_id
			,Type
		) Tbl1 ON Tbl1.Emp_ID = es.Emp_ID
		AND es.Effective_Date = Tbl1.effective_date
		AND es.Type = Tbl1.Type
	WHERE es.Emp_ID IN (
			SELECT *
			FROM @Emp_Cons
			)
		AND es.Cmp_ID = @cmp_id
		AND es.effective_date <= @From_Date
		AND es.Type = @Report_Type
END
ELSE
BEGIN
	DECLARE Emp_Scheme CURSOR
	FOR
	SELECT DISTINCT es.emp_id
		,es.[Type]
		,es.Scheme_ID
	FROM T0095_EMP_SCHEME es WITH (NOLOCK)
	INNER JOIN T0080_EMP_MASTER emp WITH (NOLOCK) ON emp.Emp_ID = es.Emp_ID
		AND emp.Cmp_ID = es.cmp_id
	INNER JOIN (
		SELECT max(effective_date) AS effective_date
			,emp_id
			,IES.Type
		FROM T0095_EMP_SCHEME IES WITH (NOLOCK)
		WHERE Cmp_ID = @cmp_id
			AND Emp_ID IN (
				SELECT *
				FROM @Emp_Cons
				)
			AND effective_date <= @From_Date
		GROUP BY emp_id
			,Type
		) Tbl1 ON Tbl1.Emp_ID = es.Emp_ID
		AND es.Effective_Date = Tbl1.effective_date
		AND es.Type = Tbl1.Type
	WHERE es.Emp_ID IN (
			SELECT *
			FROM @Emp_Cons
			)
		AND es.Cmp_ID = @cmp_id
		AND es.effective_date <= @From_Date
END

OPEN Emp_Scheme

FETCH NEXT
FROM Emp_Scheme
INTO @e_id
	,@sc_type
	,@e_scheme_ID

WHILE @@fetch_status = 0
BEGIN
	SET @Is_display_rpt_level = 1 --binal  
	SET @non_mandatory = 0 --binal  

	INSERT INTO #SCHEME
	VALUES (
		@e_id
		,@sc_type
		,@e_scheme_ID
		)

	FETCH NEXT
	FROM Emp_Scheme
	INTO @e_id
		,@sc_type
		,@e_scheme_ID
END

--select * from #SCHEME      
CLOSE Emp_Scheme

DEALLOCATE Emp_Scheme

DECLARE @Manager_HR INT

DECLARE Emp_Scheme_Cursor CURSOR
FOR
--(select * from @Emp_Cons)  
(
		SELECT *
		FROM #SCHEME
		)

OPEN Emp_Scheme_Cursor

FETCH NEXT
FROM Emp_Scheme_Cursor
INTO @emp_id1
	,@sc_type
	,@e_scheme_ID

WHILE @@fetch_status = 0
BEGIN
	SET @Is_display_rpt_level = 1 --binal  
	SET @non_mandatory = 0 --binal  

	INSERT INTO #EMPSCHEME (
		emp_id1
		,Scheme_Type
		,Scheme_Id
		,Rpt_Mgr_1
		,Rpt_Mgr_2
		,Rpt_Mgr_3
		,Rpt_Mgr_4
		,Rpt_Mgr_5
		,Rpt_Mgr_6
		,Rpt_Mgr_7
		,Rpt_Mgr_8
		,Max_Level
		) --Change by Jaina 19-11-2020  
	VALUES (
		@emp_id1
		,@sc_type
		,@e_scheme_ID
		,''
		,''
		,''
		,''
		,''
		,''
		,''
		,''
		,1
		)

	SELECT @Scheme_Id1 = es.Scheme_ID
		,@Effective_Date = es.Effective_Date
		,@Scheme_Type = es.[Type]
		,@Emp_Code = emp.Alpha_Emp_Code
		,@Emp_Name = Emp_Full_Name
		,@cmp_name = c.Cmp_Name
		,@cmp_address = Cmp_Address
		,@branch_Id1 = emp.Branch_ID
		,@scheme_name = sm.Scheme_Name
	FROM T0095_EMP_SCHEME es WITH (NOLOCK)
	INNER JOIN T0040_Scheme_Master sm WITH (NOLOCK) ON es.Scheme_ID = sm.Scheme_Id
		AND es.Cmp_ID = sm.Cmp_Id
	INNER JOIN T0080_EMP_MASTER emp WITH (NOLOCK) ON emp.Emp_ID = es.Emp_ID
		AND emp.Cmp_ID = es.cmp_id
	INNER JOIN T0010_COMPANY_MASTER c WITH (NOLOCK) ON c.Cmp_Id = emp.Cmp_ID
	WHERE es.Emp_ID = @emp_id1
		AND es.Cmp_ID = @cmp_id
		AND es.[Type] = @sc_type
		AND es.effective_date <= @From_Date
		AND es.Scheme_ID = @e_scheme_ID

	SET @emp_full_name = ''
	SET @emp_First_Name = ''
	SET @temp = ''
	SET @temp1 = ''
	SET @emp_id2 = 0
	SET @rm_name = ''

	UPDATE #EMPSCHEME
	SET Scheme_Id = @Scheme_Id1
		,Effective_Date = @Effective_Date
		,Alpha_Emp_Code = @Emp_Code
		,Emp_Full_Name = @Emp_Name
		,Scheme_Type = @Scheme_Type
		,Cmp_Name = @Cmp_Name
		,Cmp_Address = @Cmp_Address
		,cmp_id1 = @cmp_id
		,branch_Id = @branch_Id1
		,Scheme_Name = @scheme_name
	WHERE Emp_ID1 = @Emp_ID1
		AND Scheme_Type = @sc_type
		AND Scheme_Id = @e_scheme_ID

	SET @emp_full_name = ''
	SET @emp_First_Name = ''

	IF EXISTS (
			SELECT 1
			FROM T0050_Scheme_Detail WITH (NOLOCK)
			WHERE cmp_id = @cmp_id
				AND (
					Is_RM = 1
					OR Is_PRM = 1
					OR Dyn_Hier_Id > 0
					)
				AND Scheme_Id = @Scheme_Id1
				AND Rpt_Level = 1
			)
	BEGIN
		SET @temp = ''
		SET @rm_name = ''

		DECLARE @Is_PRM_level1 AS TINYINT

		SET @Is_PRM_level1 = 0

		DECLARE @DynHierId AS INT = 0

		--set @temp=(SELECT  ((convert(nvarchar,Alpha_Emp_Code)) + '-' + (convert(nvarchar,EMP_FULL_NAME))) + ', '   
		--FROM T0080_EMP_MASTER E INNER JOIN T0090_EMP_REPORTING_DETAIL ERD ON E.EMP_ID= ERD.R_EMP_ID   
		--WHERE ERD.EMP_ID =@Emp_ID1  for xml path (''))  
		SELECT @Is_PRM_level1 = Is_PRM
			,@DynHierId = Dyn_Hier_Id
		FROM T0050_Scheme_Detail WITH (NOLOCK)
		WHERE cmp_id = @cmp_id
			AND Scheme_Id = @Scheme_Id1
			AND (
				Is_PRM = 1
				OR Dyn_Hier_Id > 0
				)
			AND Rpt_Level = 1

		IF (@Is_PRM_level1 = 1)
		BEGIN
			SET @temp = (
					SELECT DISTINCT ((convert(NVARCHAR, E.Alpha_Emp_Code)) + '-' + (convert(NVARCHAR, E.EMP_FULL_NAME))) + ', '
					FROM T0080_EMP_MASTER E WITH (NOLOCK)
					INNER JOIN t0080_emp_master ERD WITH (NOLOCK) ON Erd.manager_Probation = E.Emp_id
					WHERE ERD.EMP_ID = @Emp_ID1
					FOR XML path('')
					)
		END
		ELSE IF (@DynHierId > 0)
		BEGIN
			SET @temp = (
					SELECT DISTINCT ((convert(NVARCHAR, ERD.Alpha_Emp_Code)) + '-' + (convert(NVARCHAR, ERD.EMP_FULL_NAME))) + ', '
					FROM T0050_Scheme_Detail SD WITH (NOLOCK)
					INNER JOIN T0080_DynHierarchy_Value Dy WITH (NOLOCK) ON SD.Dyn_Hier_Id = DY.DynHierColId
						AND sd.Scheme_Id = @Scheme_Id1
					INNER JOIN T0080_EMP_MASTER ERD WITH (NOLOCK) ON ERD.Emp_ID = dy.DynHierColValue
					WHERE Dy.EMP_ID = @Emp_ID1
						AND Rpt_Level = 1
					FOR XML path('')
					)
		END
		ELSE
		BEGIN
			SET @temp = (
					SELECT DISTINCT ((convert(NVARCHAR, Alpha_Emp_Code)) + '-' + (convert(NVARCHAR, EMP_FULL_NAME))) + ', '
					FROM T0080_EMP_MASTER E WITH (NOLOCK)
					INNER JOIN T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK)
					INNER JOIN --Ankit 28012015  
						(
						SELECT MAX(Effect_Date) AS Effect_Date
							,Emp_ID
						FROM T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)
						WHERE Effect_Date <= GETDATE()
						GROUP BY emp_ID
						) RQry ON ERD.Emp_ID = RQry.Emp_ID
						AND ERD.Effect_Date = RQry.Effect_Date ON E.EMP_ID = ERD.R_EMP_ID WHERE ERD.EMP_ID = @Emp_ID1
					FOR XML path('')
					)
		END

		SET @rm_name = LEFT(cast(@temp AS VARCHAR(500)), LEN(cast(@temp AS VARCHAR(500))) - 1)

		IF @rm_name IS NULL
			OR @rm_name = ''
			SET @rm_name = 'Reporting Manager'

		UPDATE #EMPSCHEME
		SET Rpt_Mgr_1 = @rm_name
		WHERE Emp_ID1 = @Emp_ID1
			AND Scheme_Type = @sc_type
			AND Scheme_Id = @e_scheme_ID
	END
	ELSE IF EXISTS (
			SELECT *
			FROM T0050_Scheme_Detail WITH (NOLOCK)
			WHERE cmp_id = @cmp_id
				AND Is_HR = 1
				AND Scheme_Id = @Scheme_Id1
				AND Rpt_Level = 1
			) --Added by Mukti(05072019)to Select HR for Recruitment scheme  
	BEGIN
		IF EXISTS (
				SELECT 1
				FROM T0011_LOGIN WITH (NOLOCK)
				WHERE Is_HR = 1
					AND cmp_id = @cmp_id
					AND ISNULL(branch_id_multi, '') <> ''
					AND Branch_id_multi <> 0
				)
		BEGIN
			SELECT @Manager_HR = Emp_ID
			FROM T0011_LOGIN WITH (NOLOCK)
			WHERE Is_HR = 1
				AND cmp_id = @cmp_id
				AND ISNULL(branch_id_multi, '') <> ''
				AND @branch_Id1 IN (
					SELECT cast(data AS NUMERIC(18, 0))
					FROM dbo.Split(ISNULL(branch_id_multi, ''), '#')
					WHERE data <> ''
					)
		END
		ELSE
		BEGIN
			SELECT @Manager_HR = Emp_ID
			FROM T0011_LOGIN WITH (NOLOCK)
			WHERE Is_HR = 1
				AND cmp_id = @cmp_id
		END

		SET @emp_full_name = ''
		SELECT @emp_full_name = (Isnull(em.Alpha_Emp_Code, '') + ' - ' + ISNULL(em.Emp_Full_Name, ''))
		FROM dbo.T0080_EMP_MASTER em WITH (NOLOCK)
		WHERE em.Emp_ID = @Manager_HR

		UPDATE #EMPSCHEME
		SET Rpt_Mgr_1 = @emp_full_name
		WHERE Emp_ID1 = @Emp_ID1
			AND Scheme_Type = @sc_type
			AND Scheme_Id = @e_scheme_ID
	END
	ELSE
	BEGIN
		SET @emp_full_name = ''
		SET @emp_first_name = ''
		SELECT @emp_full_name = (Isnull(em.Alpha_Emp_Code, '') + ' - ' + ISNULL(em.Emp_Full_Name, ''))
			,@emp_First_Name = Emp_First_Name
		FROM dbo.T0080_EMP_MASTER em WITH (NOLOCK)
		WHERE (
				em.Emp_ID = (
					SELECT App_Emp_ID
					FROM dbo.T0050_Scheme_Detail WITH (NOLOCK)
					WHERE Scheme_Id = @Scheme_Id1
						AND Cmp_ID = @cmp_id
						AND rpt_level = 1
					)
				)

		UPDATE #EMPSCHEME
		SET Rpt_Mgr_1 = @emp_full_name
		WHERE Emp_ID1 = @Emp_ID1
			AND Scheme_Type = @sc_type
			AND Scheme_Id = @e_scheme_ID
	END

	IF EXISTS (
			SELECT 1
			FROM T0050_Scheme_Detail WITH (NOLOCK)
			WHERE cmp_id = @cmp_id
				AND Scheme_Id = @Scheme_Id1
				AND (
					Is_BM = 1
					OR Is_HOD = 1
					OR Is_PRM = 1
					OR Is_RMToRM = 1
					OR Dyn_Hier_Id > 0
					)
				AND Rpt_Level = 2
			)
	BEGIN
		DECLARE @Is_Hod_chk AS TINYINT
		DECLARE @Is_PRM AS TINYINT
		DECLARE @Is_RMToRM AS TINYINT
		DECLARE @Is_BM AS TINYINT
		DECLARE @DynHierId2 AS INT = 0

		SET @Is_PRM = 0
		SET @Is_Hod_chk = 0
		SET @temp1 = ''
		SET @temp = ''
		SET @rm_name = ''

		SELECT @HOD = Dept_ID
		FROM T0080_emp_master WITH (NOLOCK)
		WHERE Emp_ID = @Emp_ID1

		
		SELECT @Is_Hod_chk = Is_HOD
			,@Is_PRM = Is_PRM
			,@Is_RMToRM = Is_RMToRM
			,@Is_BM = Is_BM
			,@DynHierId2 = Dyn_Hier_Id
		FROM T0050_Scheme_Detail WITH (NOLOCK)
		WHERE cmp_id = @cmp_id
			AND Scheme_Id = @Scheme_Id1
			AND (
				Is_BM = 1
				OR Is_HOD = 1
				OR Is_PRM = 1
				OR Is_RMToRM = 1
				OR Dyn_Hier_Id > 0
				)
			AND Rpt_Level = 2
			
			
		IF (
				@Is_Hod_chk = 0
				AND @Is_PRM = 0
				AND @Is_BM = 1
				)
		BEGIN
			SELECT @branch_Id1 = Branch_ID
			FROM T0095_INCREMENT I1 WITH (NOLOCK)
			INNER JOIN (
				SELECT MAX(I2.Increment_ID) AS Increment_ID
					,I2.Emp_ID
				FROM T0095_INCREMENT I2 WITH (NOLOCK)
				INNER JOIN (
					SELECT MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE
						,I3.EMP_ID
					FROM T0095_INCREMENT I3 WITH (NOLOCK)
					WHERE I3.Increment_Effective_Date <= @To_Date
					GROUP BY I3.Emp_ID
					) I3 ON I2.Increment_Effective_Date = I3.INCREMENT_EFFECTIVE_DATE
					AND I2.Emp_ID = I3.Emp_ID
				WHERE I2.Cmp_ID = @Cmp_Id
				GROUP BY I2.Emp_ID
				) I2 ON I1.Emp_ID = I2.Emp_ID
				AND I1.Increment_ID = I2.INCREMENT_ID
			WHERE I1.Cmp_ID = @Cmp_Id
				AND i1.Emp_ID = @Emp_ID1

		
			SET @temp1 = (
					SELECT ((convert(NVARCHAR, Alpha_Emp_Code)) + '-' + (convert(NVARCHAR, EMP_FULL_NAME))) + ', '
					FROM T0080_EMP_MASTER E WITH (NOLOCK)
					INNER JOIN T0095_MANAGERS ERD WITH (NOLOCK) ON E.EMP_ID = ERD.Emp_id
					INNER JOIN (
						SELECT max(effective_date) AS effective_date
							,Branch_ID
						FROM T0095_MANAGERS IES WITH (NOLOCK)
						WHERE Cmp_ID = @cmp_id
							AND Branch_ID = @branch_Id1
						GROUP BY Branch_ID
						) Tbl1 ON Tbl1.Branch_ID = @branch_Id1
						AND erd.effective_date = tbl1.effective_date
					WHERE ERD.Branch_ID = @branch_Id1
					FOR XML path('')
					)
		END
		ELSE IF (@Is_PRM = 1)
		BEGIN
			SET @temp1 = (
					SELECT DISTINCT ((convert(NVARCHAR, E.Alpha_Emp_Code)) + '-' + (convert(NVARCHAR, E.EMP_FULL_NAME))) + ', '
					FROM T0080_EMP_MASTER E WITH (NOLOCK)
					INNER JOIN t0080_emp_master ERD WITH (NOLOCK) ON Erd.manager_Probation = E.Emp_id
					WHERE ERD.EMP_ID = @Emp_ID1
					FOR XML path('')
					)
		END
				-------------Added By Jimit 16122017  For RMTORM-----------  
		ELSE IF (
				@Is_Hod_chk = 0
				AND @Is_PRM = 0
				AND @Is_RMToRM = 1
				)
		BEGIN

			DECLARE @Emp_Id_Level1 AS NUMERIC = 0

			SET @Emp_Id_Level1 = (
					SELECT TOP 1 E.Emp_ID 
					FROM T0080_EMP_MASTER E WITH (NOLOCK)
					INNER JOIN T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK)
					INNER JOIN (
						SELECT MAX(Effect_Date) AS Effect_Date
							,Emp_ID
						FROM T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)
						WHERE Effect_Date <= GETDATE()
						GROUP BY emp_ID
						) RQry ON ERD.Emp_ID = RQry.Emp_ID
						AND ERD.Effect_Date = RQry.Effect_Date ON E.EMP_ID = ERD.R_EMP_ID WHERE ERD.EMP_ID = @Emp_ID1
					ORDER BY ERD.Row_ID DESC
					)
					
					
			IF @Emp_Id_Level1 <> 0
			BEGIN
				SET @temp1 = (
						SELECT DISTINCT ((convert(NVARCHAR, Alpha_Emp_Code)) + '-' + (convert(NVARCHAR, EMP_FULL_NAME))) + ', '
						FROM T0080_EMP_MASTER E WITH (NOLOCK)
						INNER JOIN T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK)
						INNER JOIN (
							SELECT MAX(Effect_Date) AS Effect_Date
								,Emp_ID
							FROM T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)
							WHERE Effect_Date <= GETDATE()
							GROUP BY emp_ID
							) RQry ON ERD.Emp_ID = RQry.Emp_ID
							AND ERD.Effect_Date = RQry.Effect_Date ON E.EMP_ID = ERD.R_EMP_ID WHERE ERD.EMP_ID = @Emp_Id_Level1
						FOR XML path('')
						)
			END
		END
		
		--------------ended----------------------------  
		IF (@DynHierId2 > 0)
		BEGIN
			SET @temp1 = (
					SELECT DISTINCT ((convert(NVARCHAR, ERD.Alpha_Emp_Code)) + '-' + (convert(NVARCHAR, ERD.EMP_FULL_NAME))) + ', '
					FROM T0050_Scheme_Detail SD WITH (NOLOCK)
					INNER JOIN T0080_DynHierarchy_Value Dy WITH (NOLOCK) ON SD.Dyn_Hier_Id = DY.DynHierColId
						AND sd.Scheme_Id = @Scheme_Id1
					INNER JOIN T0080_EMP_MASTER ERD WITH (NOLOCK) ON ERD.Emp_ID = dy.DynHierColValue
					WHERE Dy.EMP_ID = @Emp_ID1
						AND Rpt_Level = 2
					FOR XML path('')
					)
		END
		ELSE
		BEGIN
			-- Deepal 17062024 - 29697
			--SET @temp1 = (
			--		SELECT ((convert(NVARCHAR, Alpha_Emp_Code)) + '-' + (convert(NVARCHAR, EMP_FULL_NAME))) + ', '
			--		FROM T0080_EMP_MASTER E WITH (NOLOCK)
			--		INNER JOIN T0095_Department_Manager ERD WITH (NOLOCK) ON E.EMP_ID = ERD.Emp_id
			--		INNER JOIN (
			--			SELECT max(effective_date) AS effective_date
			--				,Dept_ID
			--			FROM T0095_Department_Manager IES WITH (NOLOCK)
			--			WHERE Cmp_ID = @cmp_id
			--				AND Dept_ID = @HOD
			--			GROUP BY Dept_ID
			--			) Tbl1 ON Tbl1.Dept_ID = @HOD
			--			AND erd.effective_date = tbl1.effective_date
			--		WHERE ERD.Dept_ID = @HOD
			--		FOR XML path('')
			--		)
			--END Deepal 17062024 - 29697

			SET @temp1 = (
						SELECT DISTINCT ((convert(NVARCHAR, Alpha_Emp_Code)) + '-' + (convert(NVARCHAR, EMP_FULL_NAME))) + ', '
						FROM T0080_EMP_MASTER E WITH (NOLOCK)
						INNER JOIN T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK)
						INNER JOIN (
							SELECT MAX(Effect_Date) AS Effect_Date
								,Emp_ID
							FROM T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)
							WHERE Effect_Date <= GETDATE()
							GROUP BY emp_ID
							) RQry ON ERD.Emp_ID = RQry.Emp_ID
							AND ERD.Effect_Date = RQry.Effect_Date ON E.EMP_ID = ERD.R_EMP_ID WHERE ERD.EMP_ID = @Emp_Id_Level1
						FOR XML path('')
						)
		END

		
		--if @temp1<>''  
		--Begin  
		SET @rm_name = LEFT(cast(@temp1 AS VARCHAR(200)), LEN(cast(@temp1 AS VARCHAR(200))) - 1)

		--End  
		IF (
				@Is_Hod_chk = 0
				AND @Is_PRM = 0
				AND @Is_BM = 1
				)
		BEGIN
			IF @rm_name IS NULL
				OR @rm_name = ''
				SET @rm_name = 'Branch Manager'
		END
		ELSE IF (
				@Is_Hod_chk = 0
				AND @Is_PRM = 1
				)
		BEGIN
			IF @rm_name IS NULL
				OR @rm_name = ''
				SET @rm_name = 'Manager'
		END
		ELSE IF (
				@Is_Hod_chk = 0
				AND @Is_PRM = 0
				AND @Is_RMToRM = 1
				)
		BEGIN
			IF @rm_name IS NULL
				OR @rm_name = ''
				SET @rm_name = 'Reporting to Reporting Manager'
		END
		ELSE
		BEGIN
			IF @rm_name IS NULL
				OR @rm_name = ''
				SET @rm_name = 'Department Manager'
		END

		--binal  
		SELECT @non_mandatory = ISNULL(not_mandatory, 0)
		FROM T0050_Scheme_Detail WITH (NOLOCK)
		WHERE cmp_id = @cmp_id
			AND Scheme_Id = @Scheme_Id1
			AND Rpt_Level = 1

		IF (@non_mandatory = 1)
		BEGIN
			SET @Is_display_rpt_level = 0
		END
		ELSE
		BEGIN
			SELECT @non_mandatory = ISNULL(not_mandatory, 0)
			FROM T0050_Scheme_Detail WITH (NOLOCK)
			WHERE cmp_id = @cmp_id
				AND Scheme_Id = @Scheme_Id1
				AND Rpt_Level = 2

			IF (@non_mandatory = 1)
			BEGIN
				SET @Is_display_rpt_level = 0
			END
		END

		--binal   
		IF (@Is_display_rpt_level = 1) --binal  
		BEGIN --binal  
			UPDATE #EMPSCHEME
			SET Rpt_Mgr_2 = @rm_name
			WHERE Emp_ID1 = @Emp_ID1
				AND Scheme_Type = @sc_type
				AND Scheme_Id = @e_scheme_ID
		END --binal  
	END
	ELSE IF EXISTS (
			SELECT *
			FROM T0050_Scheme_Detail WITH (NOLOCK)
			WHERE cmp_id = @cmp_id
				AND Is_HR = 1
				AND Scheme_Id = @Scheme_Id1
				AND Rpt_Level = 2
			) --Added by Mukti(05072019)to Select HR for Recruitment scheme  
	BEGIN
		IF EXISTS (
				SELECT 1
				FROM T0011_LOGIN WITH (NOLOCK)
				WHERE Is_HR = 1
					AND cmp_id = @cmp_id
					AND ISNULL(branch_id_multi, '') <> ''
					AND Branch_id_multi <> 0
				)
		BEGIN
			SELECT @Manager_HR = Emp_ID
			FROM T0011_LOGIN WITH (NOLOCK)
			WHERE Is_HR = 1
				AND cmp_id = @cmp_id
				AND ISNULL(branch_id_multi, '') <> ''
				AND @branch_Id1 IN (
					SELECT cast(data AS NUMERIC(18, 0))
					FROM dbo.Split(ISNULL(branch_id_multi, ''), '#')
					WHERE data <> ''
					)
		END
		ELSE
		BEGIN
			SELECT @Manager_HR = Emp_ID
			FROM T0011_LOGIN WITH (NOLOCK)
			WHERE Is_HR = 1
				AND cmp_id = @cmp_id
		END

		SET @emp_full_name = ''

		SELECT @emp_full_name = (Isnull(em.Alpha_Emp_Code, '') + ' - ' + ISNULL(em.Emp_Full_Name, ''))
		FROM dbo.T0080_EMP_MASTER em WITH (NOLOCK)
		WHERE em.Emp_ID = @Manager_HR

		--binal  
		SELECT @non_mandatory = ISNULL(not_mandatory, 0)
		FROM T0050_Scheme_Detail WITH (NOLOCK)
		WHERE cmp_id = @cmp_id
			AND Scheme_Id = @Scheme_Id1
			AND Rpt_Level = 1

		IF (@non_mandatory = 1)
		BEGIN
			SET @Is_display_rpt_level = 0
		END
		ELSE
		BEGIN
			SELECT @non_mandatory = ISNULL(not_mandatory, 0)
			FROM T0050_Scheme_Detail WITH (NOLOCK)
			WHERE cmp_id = @cmp_id
				AND Scheme_Id = @Scheme_Id1
				AND Rpt_Level = 2

			IF (@non_mandatory = 1)
			BEGIN
				SET @Is_display_rpt_level = 0
			END
		END

		--binal   
		IF (@Is_display_rpt_level = 1) --binal  
		BEGIN --binal  
			UPDATE #EMPSCHEME
			SET Rpt_Mgr_2 = @emp_full_name
			WHERE Emp_ID1 = @Emp_ID1
				AND Scheme_Type = @sc_type
				AND Scheme_Id = @e_scheme_ID
		END
	END
	ELSE
	BEGIN
		SET @emp_full_name = ''
		SET @emp_First_Name = ''

		SELECT @emp_full_name = (Isnull(em.Alpha_Emp_Code, '') + ' - ' + ISNULL(em.Emp_Full_Name, ''))
			,@emp_First_Name = em.Emp_First_Name
		FROM dbo.T0080_EMP_MASTER em WITH (NOLOCK)
		WHERE (
				em.Emp_ID = (
					SELECT App_Emp_ID
					FROM dbo.T0050_Scheme_Detail WITH (NOLOCK)
					WHERE Scheme_Id = @Scheme_Id1
						AND Cmp_ID = @cmp_id
						AND rpt_level = 2
					)
				)

		--binal  
		SELECT @non_mandatory = ISNULL(not_mandatory, 0)
		FROM T0050_Scheme_Detail WITH (NOLOCK)
		WHERE cmp_id = @cmp_id
			AND Scheme_Id = @Scheme_Id1
			AND Rpt_Level = 1

		IF (@non_mandatory = 1)
		BEGIN
			SET @Is_display_rpt_level = 0
		END
		ELSE
		BEGIN
			SELECT @non_mandatory = ISNULL(not_mandatory, 0)
			FROM T0050_Scheme_Detail WITH (NOLOCK)
			WHERE cmp_id = @cmp_id
				AND Scheme_Id = @Scheme_Id1
				AND Rpt_Level = 2

			IF (@non_mandatory = 1)
			BEGIN
				SET @Is_display_rpt_level = 0
			END
		END

		--binal   
		IF (@Is_display_rpt_level = 1) --binal  
		BEGIN --binal  
			UPDATE #EMPSCHEME
			SET Rpt_Mgr_2 = @emp_full_name
			WHERE Emp_ID1 = @Emp_ID1
				AND Scheme_Type = @sc_type
				AND Scheme_Id = @e_scheme_ID
		END
	END

	-----------------------------------------------------------------------                     
	IF EXISTS (
			SELECT 1
			FROM T0050_Scheme_Detail WITH (NOLOCK)
			WHERE cmp_id = @cmp_id
				AND (
					Is_BM = 1
					OR Is_HOD = 1
					OR Is_PRM = 1
					OR Dyn_Hier_Id > 0
					)
				AND Scheme_Id = @Scheme_Id1
				AND Rpt_Level = 3
			)
	BEGIN
		DECLARE @Is_Hod_lvl3 AS TINYINT

		SET @Is_Hod_lvl3 = 0
		DECLARE @Is_BM_3 AS TINYINT
		DECLARE @Is_Prm_3 AS TINYINT
		DECLARE @Dyn_Hier_Id3 AS TINYINT


		SET @Is_Prm_3 = 0
		SET @temp = ''
		SET @temp1 = ''
		SET @rm_name = ''

		SELECT @HOD = Dept_ID
		FROM T0080_emp_master WITH (NOLOCK)
		WHERE Emp_ID = @Emp_ID1

		SELECT @Is_Hod_lvl3 = Is_HOD
			,@Is_Prm_3 = Is_PRM
			,@Dyn_Hier_Id3 = Dyn_Hier_Id
			,@Is_BM_3 = Is_BM
		FROM T0050_Scheme_Detail WITH (NOLOCK)
		WHERE cmp_id = @cmp_id
			AND Scheme_Id = @Scheme_Id1
			AND (
				Is_HOD = 1
				OR Dyn_Hier_Id > 0
				OR Is_BM = 1
				)
			AND Rpt_Level = 3
			
			
		IF @Is_Hod_lvl3 = 0
		BEGIN
			SELECT @branch_Id1 = Branch_ID
			FROM T0080_emp_master WITH (NOLOCK)
			WHERE Emp_ID = @Emp_ID1

			SET @temp = (
					SELECT ((convert(NVARCHAR, Alpha_Emp_Code)) + '-' + (convert(NVARCHAR, EMP_FULL_NAME))) + ', '
					FROM T0080_EMP_MASTER E WITH (NOLOCK)
					INNER JOIN T0095_MANAGERS ERD WITH (NOLOCK) ON E.EMP_ID = ERD.Emp_id
					INNER JOIN (
						SELECT max(effective_date) AS effective_date
							,Branch_ID
						FROM T0095_MANAGERS IES WITH (NOLOCK)
						WHERE Cmp_ID = @cmp_id
							AND Branch_ID = @branch_Id1
						GROUP BY Branch_ID
						) Tbl1 ON Tbl1.Branch_ID = @branch_Id1
						AND erd.effective_date = tbl1.effective_date
					WHERE ERD.Branch_ID = @branch_Id1
					FOR XML path('')
					)
		END
		ELSE IF (@Is_Prm_3 = 1)
		BEGIN
			SET @temp = (
					SELECT DISTINCT ((convert(NVARCHAR, E.Alpha_Emp_Code)) + '-' + (convert(NVARCHAR, E.EMP_FULL_NAME))) + ', '
					FROM T0080_EMP_MASTER E WITH (NOLOCK)
					INNER JOIN t0080_emp_master ERD WITH (NOLOCK) ON Erd.manager_Probation = E.Emp_id
					WHERE ERD.EMP_ID = @Emp_ID1
					FOR XML path('')
					)
		END

		IF (@Is_Hod_chk = 0 AND @Is_PRM = 0 AND @Is_BM_3 = 1)
		BEGIN
			SELECT @branch_Id1 = Branch_ID
			FROM T0095_INCREMENT I1 WITH (NOLOCK)
			INNER JOIN (
				SELECT MAX(I2.Increment_ID) AS Increment_ID
					,I2.Emp_ID
				FROM T0095_INCREMENT I2 WITH (NOLOCK)
				INNER JOIN (
					SELECT MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE
						,I3.EMP_ID
					FROM T0095_INCREMENT I3 WITH (NOLOCK)
					WHERE I3.Increment_Effective_Date <= @To_Date
					GROUP BY I3.Emp_ID
					) I3 ON I2.Increment_Effective_Date = I3.INCREMENT_EFFECTIVE_DATE
					AND I2.Emp_ID = I3.Emp_ID
				WHERE I2.Cmp_ID = @Cmp_Id
				GROUP BY I2.Emp_ID
				) I2 ON I1.Emp_ID = I2.Emp_ID
				AND I1.Increment_ID = I2.INCREMENT_ID
			WHERE I1.Cmp_ID = @Cmp_Id
				AND i1.Emp_ID = @Emp_ID1
				
		
			SET @temp = (
					SELECT ((convert(NVARCHAR, Alpha_Emp_Code)) + '-' + (convert(NVARCHAR, EMP_FULL_NAME))) + ', '
					FROM T0080_EMP_MASTER E WITH (NOLOCK)
					INNER JOIN T0095_MANAGERS ERD WITH (NOLOCK) ON E.EMP_ID = ERD.Emp_id
					INNER JOIN (
						SELECT max(effective_date) AS effective_date
							,Branch_ID
						FROM T0095_MANAGERS IES WITH (NOLOCK)
						WHERE Cmp_ID = @cmp_id
							AND Branch_ID = @branch_Id1
						GROUP BY Branch_ID
						) Tbl1 ON Tbl1.Branch_ID = @branch_Id1
						AND erd.effective_date = tbl1.effective_date
					WHERE ERD.Branch_ID = @branch_Id1
					FOR XML path('')
					)
					
		END
		else IF (@Dyn_Hier_Id3 > 0)
		BEGIN
			SET @temp = (
					SELECT DISTINCT ((convert(NVARCHAR, ERD.Alpha_Emp_Code)) + '-' + (convert(NVARCHAR, ERD.EMP_FULL_NAME))) + ', '
					FROM T0050_Scheme_Detail SD WITH (NOLOCK)
					INNER JOIN T0080_DynHierarchy_Value Dy WITH (NOLOCK) ON SD.Dyn_Hier_Id = DY.DynHierColId
						AND sd.Scheme_Id = @Scheme_Id1
					INNER JOIN T0080_EMP_MASTER ERD WITH (NOLOCK) ON ERD.Emp_ID = dy.DynHierColValue
					WHERE Dy.EMP_ID = @Emp_ID1
						AND Rpt_Level = 3
					FOR XML path('')
					)
		END
		ELSE
		BEGIN
			SET @temp = (
					SELECT ((convert(NVARCHAR, Alpha_Emp_Code)) + '-' + (convert(NVARCHAR, EMP_FULL_NAME))) + ', '
					FROM T0080_EMP_MASTER E WITH (NOLOCK)
					INNER JOIN T0095_Department_Manager ERD WITH (NOLOCK) ON E.EMP_ID = ERD.Emp_id
					INNER JOIN (
						SELECT max(effective_date) AS effective_date
							,Dept_ID
						FROM T0095_Department_Manager IES WITH (NOLOCK)
						WHERE Cmp_ID = @cmp_id
							AND Dept_ID = @HOD
						GROUP BY Dept_ID
						) Tbl1 ON Tbl1.Dept_ID = @HOD
						AND erd.effective_date = tbl1.effective_date
					WHERE ERD.Dept_ID = @HOD
					FOR XML path('')
					)
		END

		
		SET @rm_name = LEFT(cast(@temp AS VARCHAR(200)), LEN(cast(@temp AS VARCHAR(200))) - 1)

		IF @Is_Hod_chk = 0 --Added by Sumit for HOD 25092015  
		BEGIN
			IF @rm_name IS NULL
				OR @rm_name = ''
				SET @rm_name = 'Branch Manager'
		END
		ELSE
		BEGIN
			IF @rm_name IS NULL
				OR @rm_name = ''
				SET @rm_name = 'Department Manager'
		END

		--if @rm_name is null or @rm_name=''  
		-- set @rm_name='Branch Manager'  
		--binal  
		SELECT @non_mandatory = ISNULL(not_mandatory, 0)
		FROM T0050_Scheme_Detail WITH (NOLOCK)
		WHERE cmp_id = @cmp_id
			AND Scheme_Id = @Scheme_Id1
			AND Rpt_Level = 1

		IF (@non_mandatory = 1)
		BEGIN
			SET @Is_display_rpt_level = 0
		END
		ELSE
		BEGIN
			SELECT @non_mandatory = ISNULL(not_mandatory, 0)
			FROM T0050_Scheme_Detail WITH (NOLOCK)
			WHERE cmp_id = @cmp_id
				AND Scheme_Id = @Scheme_Id1
				AND Rpt_Level = 2

			IF (@non_mandatory = 1)
			BEGIN
				SET @Is_display_rpt_level = 0
			END
			ELSE
			BEGIN
				SELECT @non_mandatory = ISNULL(not_mandatory, 0)
				FROM T0050_Scheme_Detail WITH (NOLOCK)
				WHERE cmp_id = @cmp_id
					AND Scheme_Id = @Scheme_Id1
					AND Rpt_Level = 3

				IF (@non_mandatory = 1)
				BEGIN
					SET @Is_display_rpt_level = 0
				END
			END
		END

		--binal   
		IF (@Is_display_rpt_level = 1) --binal  
		BEGIN --binal             
			UPDATE #EMPSCHEME
			SET Rpt_Mgr_3 = @rm_name
			WHERE Emp_ID1 = @Emp_ID1
				AND Scheme_Type = @sc_type
				AND Scheme_Id = @e_scheme_ID
		END
	END
	ELSE IF EXISTS (
			SELECT *
			FROM T0050_Scheme_Detail WITH (NOLOCK)
			WHERE cmp_id = @cmp_id
				AND Is_HR = 1
				AND Scheme_Id = @Scheme_Id1
				AND Rpt_Level = 3
			) --Added by Mukti(05072019)to Select HR for Recruitment scheme  
	BEGIN
		IF EXISTS (
				SELECT 1
				FROM T0011_LOGIN WITH (NOLOCK)
				WHERE Is_HR = 1
					AND cmp_id = @cmp_id
					AND ISNULL(branch_id_multi, '') <> ''
					AND Branch_id_multi <> 0
				)
		BEGIN
			SELECT @Manager_HR = Emp_ID
			FROM T0011_LOGIN WITH (NOLOCK)
			WHERE Is_HR = 1
				AND cmp_id = @cmp_id
				AND ISNULL(branch_id_multi, '') <> ''
				AND @branch_Id1 IN (
					SELECT cast(data AS NUMERIC(18, 0))
					FROM dbo.Split(ISNULL(branch_id_multi, ''), '#')
					WHERE data <> ''
					)
		END
		ELSE
		BEGIN
			SELECT @Manager_HR = Emp_ID
			FROM T0011_LOGIN WITH (NOLOCK)
			WHERE Is_HR = 1
				AND cmp_id = @cmp_id
		END

		SET @emp_full_name = ''

		SELECT @emp_full_name = (Isnull(em.Alpha_Emp_Code, '') + ' - ' + ISNULL(em.Emp_Full_Name, ''))
		FROM dbo.T0080_EMP_MASTER em WITH (NOLOCK)
		WHERE em.Emp_ID = @Manager_HR

		--binal  
		SELECT @non_mandatory = ISNULL(not_mandatory, 0)
		FROM T0050_Scheme_Detail WITH (NOLOCK)
		WHERE cmp_id = @cmp_id
			AND Scheme_Id = @Scheme_Id1
			AND Rpt_Level = 1

		IF (@non_mandatory = 1)
		BEGIN
			SET @Is_display_rpt_level = 0
		END
		ELSE
		BEGIN
			SELECT @non_mandatory = ISNULL(not_mandatory, 0)
			FROM T0050_Scheme_Detail WITH (NOLOCK)
			WHERE cmp_id = @cmp_id
				AND Scheme_Id = @Scheme_Id1
				AND Rpt_Level = 2

			IF (@non_mandatory = 1)
			BEGIN
				SET @Is_display_rpt_level = 0
			END
			ELSE
			BEGIN
				SELECT @non_mandatory = ISNULL(not_mandatory, 0)
				FROM T0050_Scheme_Detail WITH (NOLOCK)
				WHERE cmp_id = @cmp_id
					AND Scheme_Id = @Scheme_Id1
					AND Rpt_Level = 3

				IF (@non_mandatory = 1)
				BEGIN
					SET @Is_display_rpt_level = 0
				END
			END
		END

		--binal   
		IF (@Is_display_rpt_level = 1) --binal  
		BEGIN --binal     
			UPDATE #EMPSCHEME
			SET Rpt_Mgr_3 = @emp_full_name
			WHERE Emp_ID1 = @Emp_ID1
				AND Scheme_Type = @sc_type
				AND Scheme_Id = @e_scheme_ID
		END
	END
	ELSE
	BEGIN
		SET @emp_full_name = ''
		SET @emp_First_Name = ''

		SELECT @emp_full_name = (Isnull(em.Alpha_Emp_Code, '') + ' - ' + ISNULL(em.Emp_Full_Name, ''))
			,@emp_First_Name = em.Emp_First_Name
		FROM dbo.T0080_EMP_MASTER em WITH (NOLOCK)
		WHERE (
				em.Emp_ID = (
					SELECT App_Emp_ID
					FROM dbo.T0050_Scheme_Detail WITH (NOLOCK)
					WHERE Scheme_Id = @Scheme_Id1
						AND Cmp_ID = @cmp_id
						AND rpt_level = 3
					)
				)

		--PRINT @emp_full_name  
		--binal  
		SELECT @non_mandatory = ISNULL(not_mandatory, 0)
		FROM T0050_Scheme_Detail WITH (NOLOCK)
		WHERE cmp_id = @cmp_id
			AND Scheme_Id = @Scheme_Id1
			AND Rpt_Level = 1

		IF (@non_mandatory = 1)
		BEGIN
			SET @Is_display_rpt_level = 0
		END
		ELSE
		BEGIN
			SELECT @non_mandatory = ISNULL(not_mandatory, 0)
			FROM T0050_Scheme_Detail WITH (NOLOCK)
			WHERE cmp_id = @cmp_id
				AND Scheme_Id = @Scheme_Id1
				AND Rpt_Level = 2

			IF (@non_mandatory = 1)
			BEGIN
				SET @Is_display_rpt_level = 0
			END
			ELSE
			BEGIN
				SELECT @non_mandatory = ISNULL(not_mandatory, 0)
				FROM T0050_Scheme_Detail WITH (NOLOCK)
				WHERE cmp_id = @cmp_id
					AND Scheme_Id = @Scheme_Id1
					AND Rpt_Level = 3

				IF (@non_mandatory = 1)
				BEGIN
					SET @Is_display_rpt_level = 0
				END
			END
		END

		--binal   
		IF (@Is_display_rpt_level = 1) --binal  
		BEGIN --binal     
			UPDATE #EMPSCHEME
			SET Rpt_Mgr_3 = @emp_full_name
			WHERE Emp_ID1 = @Emp_ID1
				AND Scheme_Type = @sc_type
				AND Scheme_Id = @e_scheme_ID
		END
	END

	SET @Emp_ID2 = 0

	SELECT @Emp_ID2 = App_Emp_ID
		,@leave1 = Leave
	FROM T0050_Scheme_Detail WITH (NOLOCK)
	WHERE cmp_id = @cmp_id
		AND Scheme_Id = @Scheme_Id1
		AND Rpt_Level = 4

	DECLARE @Dyn_Hier_Id4 AS INT

	IF @Emp_ID2 = 0
	BEGIN
		SELECT @Dyn_Hier_Id4 = Dyn_Hier_Id
		FROM T0050_Scheme_Detail WITH (NOLOCK)
		WHERE cmp_id = @cmp_id
			AND Scheme_Id = @Scheme_Id1
			AND Rpt_Level = 4
	END

	IF @Dyn_Hier_Id4 > 0
	BEGIN
		SET @emp_full_name = ''

		SELECT DISTINCT @emp_full_name = ((convert(NVARCHAR, ERD.Alpha_Emp_Code)) + '-' + (convert(NVARCHAR, ERD.EMP_FULL_NAME))) --+ ', '   
		FROM T0050_Scheme_Detail SD WITH (NOLOCK)
		INNER JOIN T0080_DynHierarchy_Value Dy WITH (NOLOCK) ON SD.Dyn_Hier_Id = DY.DynHierColId
			AND sd.Scheme_Id = @Scheme_Id1
		INNER JOIN T0080_EMP_MASTER ERD WITH (NOLOCK) ON ERD.Emp_ID = dy.DynHierColValue
		WHERE Dy.EMP_ID = @Emp_ID1
			AND Rpt_Level = 4

		IF (@Is_display_rpt_level = 1) --binal  
		BEGIN --binal  
			UPDATE #EMPSCHEME
			SET Rpt_Mgr_4 = @emp_full_name
			WHERE Emp_ID1 = @Emp_ID1
				AND Scheme_Type = @sc_type
				AND Scheme_Id = @e_scheme_ID
		END
	END
	ELSE IF (@Emp_ID2 > 0)
	BEGIN
		SET @emp_full_name = ''
		SET @emp_First_Name = ''

		SELECT @emp_full_name = (Isnull(em.Alpha_Emp_Code, '') + ' - ' + ISNULL(em.Emp_Full_Name, ''))
			,@emp_First_Name = em.Emp_First_Name
		FROM dbo.T0080_EMP_MASTER em WITH (NOLOCK)
		WHERE (em.Emp_ID = @Emp_ID2)

		--binal  
		SELECT @non_mandatory = ISNULL(not_mandatory, 0)
		FROM T0050_Scheme_Detail WITH (NOLOCK)
		WHERE cmp_id = @cmp_id
			AND Scheme_Id = @Scheme_Id1
			AND Rpt_Level = 1

		IF (@non_mandatory = 1)
		BEGIN
			SET @Is_display_rpt_level = 0
		END
		ELSE
		BEGIN
			SELECT @non_mandatory = ISNULL(not_mandatory, 0)
			FROM T0050_Scheme_Detail WITH (NOLOCK)
			WHERE cmp_id = @cmp_id
				AND Scheme_Id = @Scheme_Id1
				AND Rpt_Level = 2

			IF (@non_mandatory = 1)
			BEGIN
				SET @Is_display_rpt_level = 0
			END
			ELSE
			BEGIN
				SELECT @non_mandatory = ISNULL(not_mandatory, 0)
				FROM T0050_Scheme_Detail WITH (NOLOCK)
				WHERE cmp_id = @cmp_id
					AND Scheme_Id = @Scheme_Id1
					AND Rpt_Level = 3

				IF (@non_mandatory = 1)
				BEGIN
					SET @Is_display_rpt_level = 0
				END
				ELSE
				BEGIN
					SELECT @non_mandatory = ISNULL(not_mandatory, 0)
					FROM T0050_Scheme_Detail WITH (NOLOCK)
					WHERE cmp_id = @cmp_id
						AND Scheme_Id = @Scheme_Id1
						AND Rpt_Level = 4

					IF (@non_mandatory = 1)
					BEGIN
						SET @Is_display_rpt_level = 0
					END
				END
			END
		END

		--binal   
		IF (@Is_display_rpt_level = 1) --binal  
		BEGIN --binal  
			UPDATE #EMPSCHEME
			SET Rpt_Mgr_4 = @emp_full_name
			WHERE Emp_ID1 = @Emp_ID1
				AND Scheme_Type = @sc_type
				AND Scheme_Id = @e_scheme_ID
		END
	END

	SET @Emp_ID2 = 0

	SELECT @Emp_ID2 = App_Emp_ID
		,@leave1 = Leave
	FROM T0050_Scheme_Detail WITH (NOLOCK)
	WHERE cmp_id = @cmp_id
		AND Scheme_Id = @Scheme_Id1
		AND Rpt_Level = 5

	DECLARE @Dyn_Hier_Id5 AS INT

	IF @Emp_ID2 = 0
	BEGIN
		SELECT @Dyn_Hier_Id5 = Dyn_Hier_Id
		FROM T0050_Scheme_Detail WITH (NOLOCK)
		WHERE cmp_id = @cmp_id
			AND Scheme_Id = @Scheme_Id1
			AND Rpt_Level = 5
	END

	IF @Dyn_Hier_Id5 > 0
	BEGIN
		SET @emp_full_name = ''

		SELECT DISTINCT @emp_full_name = ((convert(NVARCHAR, ERD.Alpha_Emp_Code)) + '-' + (convert(NVARCHAR, ERD.EMP_FULL_NAME))) --+ ', '   
		FROM T0050_Scheme_Detail SD WITH (NOLOCK)
		INNER JOIN T0080_DynHierarchy_Value Dy WITH (NOLOCK) ON SD.Dyn_Hier_Id = DY.DynHierColId
			AND sd.Scheme_Id = @Scheme_Id1
		INNER JOIN T0080_EMP_MASTER ERD WITH (NOLOCK) ON ERD.Emp_ID = dy.DynHierColValue
		WHERE Dy.EMP_ID = @Emp_ID1
			AND Rpt_Level = 5

		IF (@Is_display_rpt_level = 1) --binal  
		BEGIN --binal  
			UPDATE #EMPSCHEME
			SET Rpt_Mgr_5 = @emp_full_name
			WHERE Emp_ID1 = @Emp_ID1
				AND Scheme_Type = @sc_type
				AND Scheme_Id = @e_scheme_ID
		END
	END
	ELSE IF (@Emp_ID2 > 0)
	BEGIN
		SET @emp_full_name = ''
		SET @emp_First_Name = ''

		SELECT @emp_full_name = (Isnull(em.Alpha_Emp_Code, '') + ' - ' + ISNULL(em.Emp_Full_Name, ''))
			,@emp_First_Name = em.Emp_First_Name
		FROM dbo.T0080_EMP_MASTER em WITH (NOLOCK)
		WHERE (em.Emp_ID = @Emp_ID2)

		--binal  
		SELECT @non_mandatory = ISNULL(not_mandatory, 0)
		FROM T0050_Scheme_Detail WITH (NOLOCK)
		WHERE cmp_id = @cmp_id
			AND Scheme_Id = @Scheme_Id1
			AND Rpt_Level = 1

		IF (@non_mandatory = 1)
		BEGIN
			SET @Is_display_rpt_level = 0
		END
		ELSE
		BEGIN
			SELECT @non_mandatory = ISNULL(not_mandatory, 0)
			FROM T0050_Scheme_Detail WITH (NOLOCK)
			WHERE cmp_id = @cmp_id
				AND Scheme_Id = @Scheme_Id1
				AND Rpt_Level = 2

			IF (@non_mandatory = 1)
			BEGIN
				SET @Is_display_rpt_level = 0
			END
			ELSE
			BEGIN
				SELECT @non_mandatory = ISNULL(not_mandatory, 0)
				FROM T0050_Scheme_Detail WITH (NOLOCK)
				WHERE cmp_id = @cmp_id
					AND Scheme_Id = @Scheme_Id1
					AND Rpt_Level = 3

				IF (@non_mandatory = 1)
				BEGIN
					SET @Is_display_rpt_level = 0
				END
				ELSE
				BEGIN
					SELECT @non_mandatory = ISNULL(not_mandatory, 0)
					FROM T0050_Scheme_Detail WITH (NOLOCK)
					WHERE cmp_id = @cmp_id
						AND Scheme_Id = @Scheme_Id1
						AND Rpt_Level = 4

					IF (@non_mandatory = 1)
					BEGIN
						SET @Is_display_rpt_level = 0
					END
					ELSE
					BEGIN
						SELECT @non_mandatory = ISNULL(not_mandatory, 0)
						FROM T0050_Scheme_Detail WITH (NOLOCK)
						WHERE cmp_id = @cmp_id
							AND Scheme_Id = @Scheme_Id1
							AND Rpt_Level = 5

						IF (@non_mandatory = 1)
						BEGIN
							SET @Is_display_rpt_level = 0
						END
					END
				END
			END
		END

		--binal   
		IF (@Is_display_rpt_level = 1) --binal  
		BEGIN --binal       
			UPDATE #EMPSCHEME
			SET Rpt_Mgr_5 = @emp_full_name
			WHERE Emp_ID1 = @Emp_ID1
				AND Scheme_Type = @sc_type
				AND Scheme_Id = @e_scheme_ID
		END
	END

	--Added by Jaina 19-11-2020 Start  
	SET @Emp_ID2 = 0

	SELECT @Emp_ID2 = App_Emp_ID
		,@leave1 = Leave
	FROM T0050_Scheme_Detail WITH (NOLOCK)
	WHERE cmp_id = @cmp_id
		AND Scheme_Id = @Scheme_Id1
		AND Rpt_Level = 6

	IF (@Emp_ID2 > 0)
	BEGIN
		SET @emp_full_name = ''
		SET @emp_First_Name = ''

		SELECT @emp_full_name = (Isnull(em.Alpha_Emp_Code, '') + ' - ' + ISNULL(em.Emp_Full_Name, ''))
			,@emp_First_Name = em.Emp_First_Name
		FROM dbo.T0080_EMP_MASTER em WITH (NOLOCK)
		WHERE (em.Emp_ID = @Emp_ID2)

		--binal  
		SELECT @non_mandatory = ISNULL(not_mandatory, 0)
		FROM T0050_Scheme_Detail WITH (NOLOCK)
		WHERE cmp_id = @cmp_id
			AND Scheme_Id = @Scheme_Id1
			AND Rpt_Level = 1

		IF (@non_mandatory = 1)
		BEGIN
			SET @Is_display_rpt_level = 0
		END
		ELSE
		BEGIN
			SELECT @non_mandatory = ISNULL(not_mandatory, 0)
			FROM T0050_Scheme_Detail WITH (NOLOCK)
			WHERE cmp_id = @cmp_id
				AND Scheme_Id = @Scheme_Id1
				AND Rpt_Level = 2

			IF (@non_mandatory = 1)
			BEGIN
				SET @Is_display_rpt_level = 0
			END
			ELSE
			BEGIN
				SELECT @non_mandatory = ISNULL(not_mandatory, 0)
				FROM T0050_Scheme_Detail WITH (NOLOCK)
				WHERE cmp_id = @cmp_id
					AND Scheme_Id = @Scheme_Id1
					AND Rpt_Level = 3

				IF (@non_mandatory = 1)
				BEGIN
					SET @Is_display_rpt_level = 0
				END
				ELSE
				BEGIN
					SELECT @non_mandatory = ISNULL(not_mandatory, 0)
					FROM T0050_Scheme_Detail WITH (NOLOCK)
					WHERE cmp_id = @cmp_id
						AND Scheme_Id = @Scheme_Id1
						AND Rpt_Level = 4

					IF (@non_mandatory = 1)
					BEGIN
						SET @Is_display_rpt_level = 0
					END
					ELSE
					BEGIN
						SELECT @non_mandatory = ISNULL(not_mandatory, 0)
						FROM T0050_Scheme_Detail WITH (NOLOCK)
						WHERE cmp_id = @cmp_id
							AND Scheme_Id = @Scheme_Id1
							AND Rpt_Level = 5

						IF (@non_mandatory = 1)
						BEGIN
							SET @Is_display_rpt_level = 0
						END
						ELSE
						BEGIN
							SELECT @non_mandatory = ISNULL(not_mandatory, 0)
							FROM T0050_Scheme_Detail WITH (NOLOCK)
							WHERE cmp_id = @cmp_id
								AND Scheme_Id = @Scheme_Id1
								AND Rpt_Level = 6

							IF (@non_mandatory = 1)
							BEGIN
								SET @Is_display_rpt_level = 0
							END
						END
					END
				END
			END
		END

		--binal   
		IF (@Is_display_rpt_level = 1) --binal  
		BEGIN --binal       
			UPDATE #EMPSCHEME
			SET Rpt_Mgr_6 = @emp_full_name
			WHERE Emp_ID1 = @Emp_ID1
				AND Scheme_Type = @sc_type
				AND Scheme_Id = @e_scheme_ID
		END
	END

	SET @Emp_ID2 = 0

	SELECT @Emp_ID2 = App_Emp_ID
		,@leave1 = Leave
	FROM T0050_Scheme_Detail WITH (NOLOCK)
	WHERE cmp_id = @cmp_id
		AND Scheme_Id = @Scheme_Id1
		AND Rpt_Level = 7

	IF (@Emp_ID2 > 0)
	BEGIN
		SET @emp_full_name = ''
		SET @emp_First_Name = ''

		SELECT @emp_full_name = (Isnull(em.Alpha_Emp_Code, '') + ' - ' + ISNULL(em.Emp_Full_Name, ''))
			,@emp_First_Name = em.Emp_First_Name
		FROM dbo.T0080_EMP_MASTER em WITH (NOLOCK)
		WHERE (em.Emp_ID = @Emp_ID2)

		--binal  
		SELECT @non_mandatory = ISNULL(not_mandatory, 0)
		FROM T0050_Scheme_Detail WITH (NOLOCK)
		WHERE cmp_id = @cmp_id
			AND Scheme_Id = @Scheme_Id1
			AND Rpt_Level = 1

		IF (@non_mandatory = 1)
		BEGIN
			SET @Is_display_rpt_level = 0
		END
		ELSE
		BEGIN
			SELECT @non_mandatory = ISNULL(not_mandatory, 0)
			FROM T0050_Scheme_Detail WITH (NOLOCK)
			WHERE cmp_id = @cmp_id
				AND Scheme_Id = @Scheme_Id1
				AND Rpt_Level = 2

			IF (@non_mandatory = 1)
			BEGIN
				SET @Is_display_rpt_level = 0
			END
			ELSE
			BEGIN
				SELECT @non_mandatory = ISNULL(not_mandatory, 0)
				FROM T0050_Scheme_Detail WITH (NOLOCK)
				WHERE cmp_id = @cmp_id
					AND Scheme_Id = @Scheme_Id1
					AND Rpt_Level = 3

				IF (@non_mandatory = 1)
				BEGIN
					SET @Is_display_rpt_level = 0
				END
				ELSE
				BEGIN
					SELECT @non_mandatory = ISNULL(not_mandatory, 0)
					FROM T0050_Scheme_Detail WITH (NOLOCK)
					WHERE cmp_id = @cmp_id
						AND Scheme_Id = @Scheme_Id1
						AND Rpt_Level = 4

					IF (@non_mandatory = 1)
					BEGIN
						SET @Is_display_rpt_level = 0
					END
					ELSE
					BEGIN
						SELECT @non_mandatory = ISNULL(not_mandatory, 0)
						FROM T0050_Scheme_Detail WITH (NOLOCK)
						WHERE cmp_id = @cmp_id
							AND Scheme_Id = @Scheme_Id1
							AND Rpt_Level = 5

						IF (@non_mandatory = 1)
						BEGIN
							SET @Is_display_rpt_level = 0
						END
						ELSE
						BEGIN
							SELECT @non_mandatory = ISNULL(not_mandatory, 0)
							FROM T0050_Scheme_Detail WITH (NOLOCK)
							WHERE cmp_id = @cmp_id
								AND Scheme_Id = @Scheme_Id1
								AND Rpt_Level = 6

							IF (@non_mandatory = 1)
							BEGIN
								SET @Is_display_rpt_level = 0
							END
							ELSE
							BEGIN
								SELECT @non_mandatory = ISNULL(not_mandatory, 0)
								FROM T0050_Scheme_Detail WITH (NOLOCK)
								WHERE cmp_id = @cmp_id
									AND Scheme_Id = @Scheme_Id1
									AND Rpt_Level = 7

								IF (@non_mandatory = 1)
								BEGIN
									SET @Is_display_rpt_level = 0
								END
							END
						END
					END
				END
			END
		END

		--binal   
		IF (@Is_display_rpt_level = 1) --binal  
		BEGIN --binal       
			UPDATE #EMPSCHEME
			SET Rpt_Mgr_7 = @emp_full_name
			WHERE Emp_ID1 = @Emp_ID1
				AND Scheme_Type = @sc_type
				AND Scheme_Id = @e_scheme_ID
		END
	END

	SELECT @Emp_ID2 = App_Emp_ID
		,@leave1 = Leave
	FROM T0050_Scheme_Detail WITH (NOLOCK)
	WHERE cmp_id = @cmp_id
		AND Scheme_Id = @Scheme_Id1
		AND Rpt_Level = 8

	IF (@Emp_ID2 > 0)
	BEGIN
		SET @emp_full_name = ''
		SET @emp_First_Name = ''

		SELECT @emp_full_name = (Isnull(em.Alpha_Emp_Code, '') + ' - ' + ISNULL(em.Emp_Full_Name, ''))
			,@emp_First_Name = em.Emp_First_Name
		FROM dbo.T0080_EMP_MASTER em WITH (NOLOCK)
		WHERE (em.Emp_ID = @Emp_ID2)

		--binal  
		SELECT @non_mandatory = ISNULL(not_mandatory, 0)
		FROM T0050_Scheme_Detail WITH (NOLOCK)
		WHERE cmp_id = @cmp_id
			AND Scheme_Id = @Scheme_Id1
			AND Rpt_Level = 1

		IF (@non_mandatory = 1)
		BEGIN
			SET @Is_display_rpt_level = 0
		END
		ELSE
		BEGIN
			SELECT @non_mandatory = ISNULL(not_mandatory, 0)
			FROM T0050_Scheme_Detail WITH (NOLOCK)
			WHERE cmp_id = @cmp_id
				AND Scheme_Id = @Scheme_Id1
				AND Rpt_Level = 2

			IF (@non_mandatory = 1)
			BEGIN
				SET @Is_display_rpt_level = 0
			END
			ELSE
			BEGIN
				SELECT @non_mandatory = ISNULL(not_mandatory, 0)
				FROM T0050_Scheme_Detail WITH (NOLOCK)
				WHERE cmp_id = @cmp_id
					AND Scheme_Id = @Scheme_Id1
					AND Rpt_Level = 3

				IF (@non_mandatory = 1)
				BEGIN
					SET @Is_display_rpt_level = 0
				END
				ELSE
				BEGIN
					SELECT @non_mandatory = ISNULL(not_mandatory, 0)
					FROM T0050_Scheme_Detail WITH (NOLOCK)
					WHERE cmp_id = @cmp_id
						AND Scheme_Id = @Scheme_Id1
						AND Rpt_Level = 4

					IF (@non_mandatory = 1)
					BEGIN
						SET @Is_display_rpt_level = 0
					END
					ELSE
					BEGIN
						SELECT @non_mandatory = ISNULL(not_mandatory, 0)
						FROM T0050_Scheme_Detail WITH (NOLOCK)
						WHERE cmp_id = @cmp_id
							AND Scheme_Id = @Scheme_Id1
							AND Rpt_Level = 5

						IF (@non_mandatory = 1)
						BEGIN
							SET @Is_display_rpt_level = 0
						END
						ELSE
						BEGIN
							SELECT @non_mandatory = ISNULL(not_mandatory, 0)
							FROM T0050_Scheme_Detail WITH (NOLOCK)
							WHERE cmp_id = @cmp_id
								AND Scheme_Id = @Scheme_Id1
								AND Rpt_Level = 6

							IF (@non_mandatory = 1)
							BEGIN
								SET @Is_display_rpt_level = 0
							END
							ELSE
							BEGIN
								SELECT @non_mandatory = ISNULL(not_mandatory, 0)
								FROM T0050_Scheme_Detail WITH (NOLOCK)
								WHERE cmp_id = @cmp_id
									AND Scheme_Id = @Scheme_Id1
									AND Rpt_Level = 7

								IF (@non_mandatory = 1)
								BEGIN
									SET @Is_display_rpt_level = 0
								END
								ELSE
								BEGIN
									SELECT @non_mandatory = ISNULL(not_mandatory, 0)
									FROM T0050_Scheme_Detail WITH (NOLOCK)
									WHERE cmp_id = @cmp_id
										AND Scheme_Id = @Scheme_Id1
										AND Rpt_Level = 8

									IF (@non_mandatory = 1)
									BEGIN
										SET @Is_display_rpt_level = 0
									END
								END
							END
						END
					END
				END
			END
		END

		--binal   
		IF (@Is_display_rpt_level = 1) --binal  
		BEGIN --binal       
			UPDATE #EMPSCHEME
			SET Rpt_Mgr_8 = @emp_full_name
			WHERE Emp_ID1 = @Emp_ID1
				AND Scheme_Type = @sc_type
				AND Scheme_Id = @e_scheme_ID
		END
	END

	--Added by Jaina 19-11-2020 End  
	UPDATE #EMPSCHEME
	SET Max_Level = (
			SELECT (
					(
						CASE 
							WHEN ISNULL(Rpt_Mgr_1, '') <> ''
								THEN 1
							ELSE 0
							END
						) + (
						CASE 
							WHEN ISNULL(Rpt_Mgr_2, '') <> ''
								THEN 1
							ELSE 0
							END
						) + (
						CASE 
							WHEN ISNULL(Rpt_Mgr_3, '') <> ''
								THEN 1
							ELSE 0
							END
						) + (
						CASE 
							WHEN ISNULL(Rpt_Mgr_4, '') <> ''
								THEN 1
							ELSE 0
							END
						) + (
						CASE 
							WHEN ISNULL(Rpt_Mgr_5, '') <> ''
								THEN 1
							ELSE 0
							END
						) + (
						CASE 
							WHEN ISNULL(Rpt_Mgr_6, '') <> ''
								THEN 1
							ELSE 0
							END
						) --Added by Jaina 19-11-2020  
					+ (
						CASE 
							WHEN ISNULL(Rpt_Mgr_7, '') <> ''
								THEN 1
							ELSE 0
							END
						) + (
						CASE 
							WHEN ISNULL(Rpt_Mgr_8, '') <> ''
								THEN 1
							ELSE 0
							END
						)
					)
			FROM #EMPSCHEME
			WHERE Emp_ID1 = @Emp_ID1
				AND Scheme_Type = @sc_type
				AND Scheme_Id = @e_scheme_ID
			)
	WHERE Emp_ID1 = @Emp_ID1
		AND Scheme_Type = @sc_type
		AND Scheme_Id = @e_scheme_ID

	FETCH NEXT
	FROM Emp_Scheme_Cursor
	INTO @emp_id1
		,@sc_type
		,@e_scheme_ID
END

CLOSE Emp_Scheme_Cursor

DEALLOCATE Emp_Scheme_Cursor

IF @Report_Type <> ''
BEGIN
	SELECT Emp_ID1
		,Rpt_Mgr_1
		,Rpt_Mgr_2
		,Rpt_Mgr_3
		,Rpt_Mgr_4
		,Rpt_Mgr_5
		,Rpt_Mgr_6
		,Rpt_Mgr_7
		,Rpt_Mgr_8
		,Max_Level
	FROM #EMPSCHEME --WHERE Scheme_Type = 'Trainee' order by RIGHT(REPLICATE(N' ', 500) + ALPHA_EMP_CODE, 500)  --Change by Jaina 19-11-2020  
END
ELSE
BEGIN
	SELECT *
	FROM #EMPSCHEME
	ORDER BY RIGHT(REPLICATE(N' ', 500) + ALPHA_EMP_CODE, 500)
END

RETURN