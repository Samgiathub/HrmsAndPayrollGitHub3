

-- =============================================
-- Author:		Nimesh Parmar
-- Create date: 05-Sep-2017
-- Description:	To load the data from employee master to sync with WCL ERP application
---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P_GET_EMP_DATA_FOR_SYNC] 
	@Cmp_ID Numeric = 0, 
	@From_Date DateTime = NULL,
	@To_Date DateTime = NULL
AS
BEGIN	
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


	IF @Cmp_ID = 0
		SET @Cmp_ID = NULL;

	IF @To_Date IS NULL
		SET @To_Date = GETDATE();

	IF @From_Date IS NULL
		SELECT @From_Date=MIN(C.From_Date) FROM T0010_COMPANY_MASTER C WITH (NOLOCK) WHERE CMP_ID=ISNULL(@CMP_ID, CMP_ID)

	CREATE TABLE #EMP_CONS
	(
		EMP_ID			NUMERIC,
		R_Emp_ID		NUMERIC,
		INCREMENT_ID	NUMERIC,
		Modify_Date		DATETIME,		
	)

	CREATE UNIQUE NONCLUSTERED INDEX IX_EMP_CONS ON #EMP_CONS(EMP_ID) INCLUDE(INCREMENT_ID, R_Emp_ID);

	INSERT INTO #EMP_CONS(EMP_ID,R_Emp_ID, INCREMENT_ID,Modify_Date)
	SELECT	I.EMP_ID,RPD.R_Emp_ID, I.INCREMENT_ID, 
			(CASE	WHEN I.System_Date > E.System_Date AND I.System_Date > RPD.System_Date THEN 
							I.System_Date 
					WHEN E.System_Date > RPD.System_Date THEN 
							E.System_Date 
					ELSE 
							RPD.System_Date 
			END) AS Modify_Date
	FROM	T0095_INCREMENT I WITH (NOLOCK) 
			INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON I.Emp_ID=E.Emp_ID
			INNER JOIN (SELECT	I1.EMP_ID, MAX(INCREMENT_ID) AS INCREMENT_ID
						FROM	T0095_INCREMENT I1 WITH (NOLOCK) 
								INNER JOIN (SELECT	EMP_ID, MAX(Increment_Effective_Date) AS Increment_Effective_Date
											FROM	T0095_INCREMENT I2 WITH (NOLOCK) 
											WHERE	Increment_Effective_Date <= @To_Date
											GROUP BY  I2.EMP_ID) I2 ON I1.Emp_ID=I2.Emp_ID AND I1.Increment_Effective_Date=I2.Increment_Effective_Date
						GROUP BY I1.EMP_ID) I1 ON I.Increment_ID=I1.Increment_ID
			LEFT OUTER JOIN (SELECT	RPD.Emp_ID,RPD.R_Emp_ID,ERPC.System_Date
							 FROM	T0090_EMP_REPORTING_DETAIL RPD	WITH (NOLOCK)								
									INNER JOIN (SELECT	RPD1.Emp_ID, MAX(RPD1.Row_ID) AS ROW_ID
												FROM	T0090_EMP_REPORTING_DETAIL RPD1 WITH (NOLOCK) 
														INNER JOIN (SELECT	RPD2.Emp_ID, MAX(RPD2.Effect_Date) AS Effect_Date
																	FROM	T0090_EMP_REPORTING_DETAIL RPD2 WITH (NOLOCK) 
																	WHERE	RPD2.Effect_Date <= @To_Date
																	GROUP BY RPD2.Emp_ID) RPD2 ON RPD1.Emp_ID=RPD2.Emp_ID
												GROUP BY RPD1.Emp_ID) RPD1 ON RPD.Emp_ID=RPD1.Emp_ID AND RPD.Row_ID=RPD1.ROW_ID
									CROSS APPLY (SELECT MAX(System_Date) AS System_Date FROM T0090_EMP_REPORTING_DETAIL_Clone ERPC WITH (NOLOCK) WHERE ERPC.Row_ID=RPD.Row_ID) ERPC									
							) RPD ON I.EMP_ID=RPD.Emp_ID
	WHERE	(
				(I.System_Date BETWEEN @From_Date AND @To_Date)
				OR (E.System_Date BETWEEN @From_Date AND @To_Date)
				OR (RPD.System_Date BETWEEN @From_Date AND @To_Date)
			)
			AND I.Cmp_ID=ISNULL(@Cmp_ID, I.Cmp_ID)
	
	

	CREATE TABLE #EMP_DATA
	(
		EMP_ID			NUMERIC,
		EmpCode			VARCHAR(64),
		Department		VARCHAR(64),
		Grade			VARCHAR(64),
		Designation		VARCHAR(64),
		MangerEmailID	VARCHAR(256),
		MangerName		VARCHAR(128),
		WorkEmail		VARCHAR(256),
		Date_Of_Join	DATETIME,
		Date_Of_Birth	DATETIME,
		Emp_Type		VARCHAR(64),
		Branch			VARCHAR(128),
		Modify_Date		DATETIME
	)
	CREATE NONCLUSTERED INDEX IX_EMP_DATA ON #EMP_DATA(EMP_ID)

	INSERT	INTO #EMP_DATA(EMP_ID,EmpCode,Department,Grade,Designation,MangerEmailID,MangerName,WorkEmail,Date_Of_Join,Date_Of_Birth,Emp_Type,Branch,Modify_Date)
	SELECT	EC.EMP_ID, E.Alpha_Emp_Code AS EmpCode, D.Dept_Name As Department, IsNull(G.Grd_Name,'') As Grade, IsNull(DG.Desig_Name,'') AS Designation, 
			IsNull(RE.Work_Email,'') AS MangerEmailID,IsNull(RE.Emp_Full_Name,'') AS MangerName, IsNull(E.Work_Email,'') As Work_Email, 
			E.Date_Of_Join, IsNull(E.Date_Of_Birth, '1900-01-01') As Date_Of_Birth, IsNull(T.Type_Name,'') AS Emp_Type, B.Branch_Name As Branch,EC.Modify_Date
	FROM	#EMP_CONS EC
			INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON EC.EMP_ID=E.Emp_ID
			INNER JOIN T0095_INCREMENT I WITH (NOLOCK) ON EC.INCREMENT_ID=I.INCREMENT_ID
			INNER JOIN T0030_BRANCH_MASTER B WITH (NOLOCK) ON I.Branch_ID=B.Branch_ID
			INNER JOIN T0040_DEPARTMENT_MASTER D WITH (NOLOCK) ON I.Dept_ID=D.Dept_Id
			LEFT OUTER JOIN T0040_DESIGNATION_MASTER DG WITH (NOLOCK) ON I.Desig_Id=DG.Desig_ID
			LEFT OUTER JOIN T0040_GRADE_MASTER G WITH (NOLOCK) ON I.Grd_ID=G.Grd_ID
			LEFT OUTER JOIN T0040_TYPE_MASTER T WITH (NOLOCK) ON I.Type_ID=T.Type_ID
			LEFT OUTER JOIN T0080_EMP_MASTER RE WITH (NOLOCK) ON EC.R_Emp_ID=RE.Emp_ID
	
	--INSERT INTO #EMP_DATA
	--VALUES(1, '20275', 'TECHNICAL SERVICES', 'E-7', 'ASSISTANT GENERAL MANAGER', 'PrakashSharma@wondercementsltd.onmicrosoft.com', 'PrakashSharma', 'amitmathur@wondercementsltd.onmicrosoft.com', '2014-08-07', '1991-08-17', 'PLANT', 'JAIPUR');

	SELECT * FROM #EMP_DATA
	ORDER BY Modify_Date Desc, EmpCode Asc
	
END

