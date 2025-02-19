


-----Created By Mukti(08042016)for Birthday,Marriage AND Work anniversary Reminder
CREATE PROCEDURE [dbo].[P_GetReminders]
   @Emp_ID NUMERIC(18,0)    
AS  
BEGIN
	
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET ARITHABORT ON;

	DECLARE @pBranch_ID	Varchar(Max)
	DECLARE @pPrivilage_Department VARCHAR(MAX)
	DECLARE @pPrivilage_Vertical VARCHAR(MAX)
	DECLARE @pPrivilage_Sub_Vertical VARCHAR(MAX)
	DECLARE @Cmp_ID INT

	
	DECLARE @Privilege_ID  INT
	SELECT	TOP 1 @Privilege_ID = EP.Privilege_Id
	FROM	T0090_EMP_PRIVILEGE_DETAILS EP WITH (NOLOCK)
			INNER JOIN T0011_LOGIN L  WITH (NOLOCK) ON EP.Login_Id=L.Login_ID
	Where	L.Emp_ID=@Emp_ID AND EP.From_Date < GETDATE()
	ORDER BY EP.From_Date DESC, EP.Trans_Id DESC


	SELECT @Cmp_ID = Cmp_ID FROM T0080_EMP_MASTER  WITH (NOLOCK) Where Emp_ID=@Emp_ID
	
	IF @Privilege_ID > 0
		BEGIN
			SELECT	@pPrivilage_Department= Department_Id_Multi, @pPrivilage_Vertical=Vertical_ID_Multi, @pPrivilage_Sub_Vertical=SubVertical_ID_Multi,@pBranch_ID=Branch_Id_Multi
			FROM	T0020_PRIVILEGE_MASTER WITH (NOLOCK) 
			WHERE	Privilege_ID=@Privilege_ID
		END
	CREATE TABLE #PRIVILEGE
	(
		ID		INT		IDENTITY(1,1),
		TRAN_ID	NUMERIC,
		P_TYPE	CHAR(1)
	)
	CREATE UNIQUE CLUSTERED INDEX IX_PRIVILEGE ON #PRIVILEGE(TRAN_ID, P_TYPE);
	
	
	/*Admin Settings*/	
	DECLARE @Show_GrpCmp_Birthday AS NUMERIC(18,0)	     
	SELECT	@Show_GrpCmp_Birthday = IsNULL(Setting_Value , 0)  
	FROM	T0040_SETTING  WITH (NOLOCK) 
	WHERE	Setting_Name = 'Show Birthday Reminder Group Company wise' AND Cmp_ID = @Cmp_ID
	    
	DECLARE @Display_Actual_Birthdate TINYINT --Added by Sumit ON 15122016
	SELECT	@Display_Actual_Birthdate=IsNULL(Setting_Value , 0)  
	FROM	T0040_SETTING  WITH (NOLOCK) 
	WHERE	Setting_Name = 'Display Actual Birth Date' AND Cmp_ID = @Cmp_ID

	DECLARE @ShowWorkAnni INT
	SELECT	@ShowWorkAnni=IsNull(Setting_Value,0)
	FROM	T0040_SETTING WITH (NOLOCK)  
	WHERE	Setting_Name='Show Work Anniversary Reminder ON Dashboard' AND Cmp_ID=@Cmp_ID 
	
	DECLARE @ShowMarraigeAnniversary INT
	SET @ShowMarraigeAnniversary = 1
	/*End of Admin Settings*/

	IF	@pBranch_ID = '' OR @pBranch_ID = '0'
		SET @pBranch_ID = NULL
	
	--Added By Mukti(23032017)start
	IF	@Privilege_ID = '' OR @Privilege_ID = '0'
		SET @Privilege_ID = NULL
	
	IF @pPrivilage_Vertical = '' OR @pPrivilage_Vertical = '0'
		SET @pPrivilage_Vertical = NULL
			
	IF @pPrivilage_Sub_Vertical = '' OR @pPrivilage_Sub_Vertical='0'
		SET @pPrivilage_Sub_Vertical = NULL
		
	IF @pPrivilage_Department = '' OR @pPrivilage_Department='0'
		SET @pPrivilage_Department = NULL
	
	
	
	--BRANCH
	IF @pBranch_ID IS NULL OR @Show_GrpCmp_Birthday=1
		INSERT	INTO #PRIVILEGE(TRAN_ID, P_TYPE)
		SELECT	BRANCH_ID, 'B' FROM T0030_BRANCH_MASTER B  WITH (NOLOCK) WHERE (CASE WHEN @Show_GrpCmp_Birthday=1 THEN @CMP_ID ELSE Cmp_ID END)=@Cmp_ID
	ELSE
		INSERT	INTO #PRIVILEGE(TRAN_ID, P_TYPE)
		SELECT	CAST(DATA AS NUMERIC), 'B' FROM dbo.Split(@pBranch_ID, '#') T 
		WHERE	IsNull(Data,'') <> ''
	
	--VERTICAL
	IF @pPrivilage_Vertical IS NULL	
		INSERT	INTO #PRIVILEGE(TRAN_ID, P_TYPE)
		SELECT	Vertical_ID, 'V' FROM T0040_Vertical_Segment B  WITH (NOLOCK) WHERE (CASE WHEN @Show_GrpCmp_Birthday=1 THEN @CMP_ID ELSE Cmp_ID END)=@Cmp_ID
	ELSE
		INSERT	INTO #PRIVILEGE(TRAN_ID, P_TYPE)
		SELECT	CAST(DATA AS NUMERIC), 'V' FROM dbo.Split(@pPrivilage_Vertical, '#') T 
		WHERE	IsNull(Data,'') <> ''
		
	--SUB VERTICAL
	IF @pPrivilage_Sub_Vertical IS NULL	
		INSERT	INTO #PRIVILEGE(TRAN_ID, P_TYPE)
		SELECT	SubVertical_ID, 'S' FROM T0050_SubVertical S  WITH (NOLOCK) WHERE (CASE WHEN @Show_GrpCmp_Birthday=1 THEN @CMP_ID ELSE Cmp_ID END)=@Cmp_ID
	ELSE
		INSERT	INTO #PRIVILEGE(TRAN_ID, P_TYPE)
		SELECT	CAST(DATA AS NUMERIC), 'S' FROM dbo.Split(@pPrivilage_Sub_Vertical, '#') T 
		WHERE	IsNull(Data,'') <> ''

	--Department
	IF @pPrivilage_Department IS NULL
		INSERT	INTO #PRIVILEGE(TRAN_ID, P_TYPE)
		SELECT	Dept_Id, 'D' FROM T0040_DEPARTMENT_MASTER D  WITH (NOLOCK) WHERE (CASE WHEN @Show_GrpCmp_Birthday=1 THEN @CMP_ID ELSE Cmp_ID END)=@Cmp_ID
	ELSE
		INSERT	INTO #PRIVILEGE(TRAN_ID, P_TYPE)
		SELECT	CAST(DATA AS NUMERIC), 'D' FROM dbo.Split(@pPrivilage_Department, '#') T 
		WHERE	IsNull(Data,'') <> ''

		
	SELECT	I.Cmp_ID,E.Emp_ID, E.Alpha_Emp_Code
			,(Initial + ' ' + Emp_First_Name + ' ' + Emp_Last_Name) As Emp_Name
			,Date_Of_Birth
			,I.Branch_ID,BM.Branch_Name,E.Image_Name,Desg.Desig_Name,DM.Dept_Name
			,Date_Of_Join
			,0 AS Total_Completed_Years, IsNull(Chk_Birth,1) As Chk_Birth
			,Emp_Annivarsary_Date
			, I.Dept_ID, I.Vertical_ID, I.SubVertical_ID
	INTO	#EMP_DATA
	FROM	(SELECT Emp_ID, Initial, Emp_First_Name, Emp_Last_Name, Alpha_Emp_Code, Image_Name, Date_Of_Join,
				--Emp_Annivarsary_Date,
				CONVERT(date, CASE WHEN ISNULL(convert(varchar(50), cast(Emp_Annivarsary_Date as date),13),'') = '' THEN '01/01/1900' ELSE convert(varchar(50), cast(Emp_Annivarsary_Date as date),13) END , 103) AS Emp_Annivarsary_Date, -- Deepal changes done 26120222 in GTPL issue  23740
				CASE WHEN @Display_Actual_Birthdate=0 THEN 
					CONVERT(VARCHAR(11),IsNull(Date_Of_Birth, '1900-01-01'),106) 
				ELSE
					CASE WHEN IsNULL(E.Actual_Date_Of_Birth,'1900-01-01') ='1900-01-01' THEN
						IsNull(Date_Of_Birth, '1900-01-01') 
					ELSE 
						E.Actual_Date_Of_Birth 
					END 
				END AS Date_Of_Birth
		FROM	T0080_Emp_master E   WITH (NOLOCK) 
		WHERE	ISNULL(E.Emp_Left_Date, GETDATE()+1) > GETDATE()
		) E
		INNER JOIN	T0095_INCREMENT I  WITH (NOLOCK) ON I.Emp_ID = e.emp_id 
		INNER JOIN (SELECT	Max(TI.Increment_ID) Increment_Id,TI.Emp_ID 
					FROM	T0095_INCREMENT TI  WITH (NOLOCK) 
							INNER JOIN (SELECT	Max(Increment_Effective_Date) AS Increment_Effective_Date,Emp_ID 
										FROM	T0095_INCREMENT  WITH (NOLOCK) 
										WHERE	Increment_Effective_Date <= GETDATE() 
										GROUP BY Emp_ID) New_Inc ON TI.Emp_ID = New_Inc.Emp_ID AND TI.Increment_Effective_Date=New_Inc.Increment_Effective_Date
					WHERE	TI.Increment_Effective_Date <= GETDATE() 
					GROUP BY TI.Emp_ID)	Qry2 ON Qry2.Emp_ID=E.Emp_ID AND Qry2.Increment_Id=I.Increment_ID
		INNER JOIN	T0030_BRANCH_MASTER BM  WITH (NOLOCK) ON I.Branch_ID = BM.Branch_ID
		LEFT JOIN	T0030_CATEGORY_MASTER CM  WITH (NOLOCK) ON I.Cat_ID = CM.Cat_ID
		LEFT JOIN	T0040_DESIGNATION_MASTER Desg  WITH (NOLOCK) ON I.Desig_Id = Desg.Desig_ID   --Mukti 11012016
		LEFT JOIN	T0040_DEPARTMENT_MASTER DM  WITH (NOLOCK) ON I.Dept_ID = DM.Dept_ID   --Mukti 11012016
		INNER JOIN	(SELECT TRAN_ID FROM #PRIVILEGE P WHERE P_TYPE='B') PB ON I.Branch_ID=(CASE WHEN PB.TRAN_ID =0 THEN I.Branch_ID ELSE PB.TRAN_ID	END) 
		 
		--INNER JOIN	(SELECT TRAN_ID FROM #PRIVILEGE P WHERE P_TYPE='V') PV ON I.Vertical_ID=PB.TRAN_ID
		--INNER JOIN	(SELECT TRAN_ID FROM #PRIVILEGE P WHERE P_TYPE='D') PD ON I.Dept_ID=PB.TRAN_ID
		--INNER JOIN	(SELECT TRAN_ID FROM #PRIVILEGE P WHERE P_TYPE='S') PS ON I.SubVertical_ID=PB.TRAN_ID
		
		
		IF EXISTS(SELECT 1 FROM #PRIVILEGE P WHERE P_TYPE='V')
			DELETE	E 
			FROM	#EMP_DATA E 
			WHERE	NOT EXISTS(SELECT 1 FROM #PRIVILEGE P WHERE E.Vertical_ID=P.TRAN_ID AND P_TYPE='V')
					AND ISNULL(E.Vertical_ID,0) <> 0
		
		IF EXISTS(SELECT 1 FROM #PRIVILEGE P WHERE P_TYPE='D')
			DELETE	E 
			FROM	#EMP_DATA E 
			WHERE	NOT EXISTS(SELECT 1 FROM #PRIVILEGE P WHERE E.Dept_ID=P.TRAN_ID AND P_TYPE='D')			
					AND ISNULL(E.Dept_ID,0) <> 0

		IF EXISTS(SELECT 1 FROM #PRIVILEGE P WHERE P_TYPE='S')
			DELETE	E 
			FROM	#EMP_DATA E 
			WHERE	NOT EXISTS(SELECT 1 FROM #PRIVILEGE P WHERE E.SubVertical_ID=P.TRAN_ID AND P_TYPE='S')			
					AND ISNULL(E.SubVertical_ID,0) <> 0

	
	CREATE TABLE #Birthday 
	(
		Emp_Full_Name		VARCHAR(256),     --modified jimit 02022016  
		Date_Of_birth		DATETIME,
		Month_Name			VARCHAR(20),			--modified jimit 02022016 due to error when size is 10 for month name (2-FEBRUARY) contains 11 charactrer
		Branch_ID			NUMERIC,
		Branch_Name			VARCHAR(100),
		Image_Name			VARCHAR(100), -- Prakash Patel 25072014
		Row_Id				NUMERIC,
		Sorting_No			NUMERIC, --Added by Ramiz 30/09/2015
		Alpha_Emp_Code		VARCHAR(100),--Mukti 08012016
		Designation_Name	VARCHAR(100),--Mukti 08012016
		Department_Name		VARCHAR(100),--Mukti 08012016
		Emp_Id				NUMERIC,--Mukti 08012016
		Date_Of_Join		DATETIME, --Mukti 05022016
		Total_Completed_Years INT, --Mukti 05022016
		Cmp_Id				NUMERIC,
		ReminderType		Char(2),
		Emp_Annivarsary_Date DATETIME, --binal 24062020
	)
		
	    
	
	DECLARE @From_Date	DATETIME
	DECLARE @To_Date	DATETIME

	SET @From_Date = CONVERT(DATETIME, CONVERT(CHAR(10),GETDATE(), 103), 103)
	SET @To_Date =   CONVERT(DATETIME, CONVERT(CHAR(10),GETDATE() + 8, 103), 103)

	DECLARE @FromRange varchar(8)
	DECLARE @ToRange varchar(8)
	SELECT	@FromRange  = CONVERT(varchar(8), RIGHT(CONVERT(VARCHAR(10), @From_Date, 112),8)),
			@ToRange  = CONVERT(varchar(8), RIGHT(CONVERT(VARCHAR(10), @To_Date, 112),8))

	 
	 
	SELECT	Cmp_id 
	INTO	#Company
	FROM	T0010_COMPANY_MASTER  WITH (NOLOCK) 
	WHERE	(CASE	WHEN @Show_GrpCmp_Birthday = 1 AND is_GroupOFCmp = 1	THEN 1 
					WHEN @Show_GrpCmp_Birthday=0 AND cmp_id=@cmp_id			THEN 1 
					ELSE 0 END) = 1
	
	
	/*For Birthday Reminder*/
	BEGIN	
	--select * from #EMP_DATA
print 'a'	
		INSERT	INTO #Birthday (Emp_Full_Name, Date_Of_birth, Month_Name, Branch_ID, Branch_Name, Image_Name, Row_Id, Sorting_No, Alpha_Emp_Code, Designation_Name, Department_Name, Emp_Id, Date_Of_Join, Total_Completed_Years, Cmp_Id, ReminderType,Emp_Annivarsary_Date)
		SELECT	Emp_Name,Date_Of_Birth,
				--RIGHT(CONVERT(VARCHAR(10), Date_Of_Birth, 112), 4) As Month_Name,
				CONVERT(INT, Cast(Case When Month(@From_Date) > Month(Date_Of_Birth) Then Year(@From_Date)+1 Else Year(@From_Date) End as varchar(4)) + RIGHT(CONVERT(VARCHAR(10), Date_Of_Birth, 112), 4)) As Month_Name,
				--(CAST(DAY(Date_Of_Birth) AS VARCHAR(3)) + '-' + UPPER(dbo.F_GET_MONTH_NAME(MONTH(Date_Of_birth)))) AS Month_Name,
				Branch_ID,Branch_Name,Image_Name,ROW_NUMBER() Over (ORDER BY MONTH(Date_Of_Birth),DAY(Date_Of_Birth)), 2,
				Alpha_Emp_Code,Desig_Name,Dept_Name,Emp_ID,'',0 AS Total_Completed_Years,C.Cmp_Id, 'TB',Emp_Annivarsary_Date
		FROM	#EMP_DATA ED
				INNER JOIN #Company C ON ED.Cmp_ID=C.Cmp_Id
		WHERE	Chk_Birth = 1 
				--AND CONVERT(varchar(8), RIGHT(CONVERT(VARCHAR(10), Date_Of_Birth, 112), 8)) BETWEEN @FromRange AND @ToRange					
				AND CONVERT(INT, Cast(Case When Month(@From_Date) > Month(Date_Of_Birth) Then Year(@From_Date)+1 Else Year(@From_Date) End as varchar(4)) + RIGHT(CONVERT(VARCHAR(10), Date_Of_Birth, 112), 4))  BETWEEN @FromRange AND @ToRange	
				AND YEAR(Date_Of_Birth) > 1900

		UPDATE	#Birthday
		SET		ReminderType = 'UB'
		WHERE	CAST(Month_Name AS INT) > @FromRange AND ReminderType = 'TB'
	END
	/*For Marriage Anniversary*/
	If @ShowMarraigeAnniversary = 1
		BEGIN
			INSERT	INTO #Birthday (Emp_Full_Name, Date_Of_birth, Month_Name, Branch_ID, Branch_Name, Image_Name, Row_Id, Sorting_No, Alpha_Emp_Code, Designation_Name, Department_Name, Emp_Id, Date_Of_Join, Total_Completed_Years, Cmp_Id, ReminderType,Emp_Annivarsary_Date)
			SELECT	Emp_Name,Emp_Annivarsary_Date AS Date_Of_Birth,
					--RIGHT(CONVERT(VARCHAR(10), Emp_Annivarsary_Date, 112), 4) As Month_Name,
					CONVERT(INT, Cast(Case When Month(@From_Date) > Month(Emp_Annivarsary_Date) Then Year(@From_Date)+1 Else Year(@From_Date) End as varchar(4)) + RIGHT(CONVERT(VARCHAR(10), Emp_Annivarsary_Date, 112), 4)) As Month_Name,
					Branch_ID,Branch_Name,Image_Name,
					ROW_NUMBER() Over (ORDER BY MONTH(Emp_Annivarsary_Date),DAY(Emp_Annivarsary_Date)),4,
					Alpha_Emp_Code,Desig_Name,Dept_Name,Emp_ID,'' AS Date_Of_join,0 AS Total_Completed_Years,C.Cmp_Id, 'TM',Emp_Annivarsary_Date
			FROM	#EMP_DATA ED
					INNER JOIN #Company C ON ED.Cmp_ID=C.Cmp_Id
			WHERE	chk_Birth = 1
					--AND CONVERT(INT, RIGHT(CONVERT(VARCHAR(10), Emp_Annivarsary_Date, 112), 4)) BETWEEN @FromRange AND @ToRange							
					AND CONVERT(INT, Cast(Case When Month(@From_Date) > Month(Emp_Annivarsary_Date) Then Year(@From_Date)+1 Else Year(@From_Date) End as varchar(4)) + RIGHT(CONVERT(VARCHAR(10), Emp_Annivarsary_Date, 112), 4))  BETWEEN @FromRange AND @ToRange	
					AND YEAR(Emp_Annivarsary_Date) > 1900
		
			UPDATE	#Birthday
			SET		ReminderType = 'UM'
			WHERE	CAST(Month_Name AS INT) > @FromRange AND ReminderType = 'TM'
		END

	IF @ShowWorkAnni = 1
		BEGIN
			INSERT	INTO #Birthday (Emp_Full_Name, Date_Of_birth, Month_Name, Branch_ID, Branch_Name, Image_Name, Row_Id, Sorting_No, Alpha_Emp_Code, Designation_Name, Department_Name, Emp_Id, Date_Of_Join, Total_Completed_Years, Cmp_Id, ReminderType,Emp_Annivarsary_Date)
			SELECT	Emp_Name,Date_Of_Join AS Date_Of_Birth,
					--RIGHT(CONVERT(VARCHAR(10), Date_Of_Join, 112), 4) As Month_Name,
					CONVERT(INT, Cast(Case When Month(@From_Date) > Month(Date_Of_Join) Then Year(@From_Date)+1 Else Year(@From_Date) End as varchar(4)) + RIGHT(CONVERT(VARCHAR(10), Date_Of_Join, 112), 4)) As Month_Name,
					Branch_ID,Branch_Name,Image_Name,		
					ROW_NUMBER() Over (ORDER BY MONTH(Date_Of_Join),DAY(Date_Of_Join)),6,
					Alpha_Emp_Code,Desig_Name,Dept_Name,Emp_ID,Date_Of_Join,DATEDIFF(YEAR,Date_Of_Join,GETDATE()) AS Total_Completed_Years,C.Cmp_ID, 'TW',Emp_Annivarsary_Date
			FROM	#EMP_DATA ED
					INNER JOIN #Company C ON ED.Cmp_ID=C.Cmp_Id
			WHERE	Chk_Birth = 1 
					--AND CONVERT(INT, RIGHT(CONVERT(VARCHAR(10), Date_Of_Join, 112), 4)) BETWEEN @FromRange AND @ToRange							
					AND CONVERT(INT, Cast(Case When Month(@From_Date) > Month(Date_Of_Join) Then Year(@From_Date)+1 Else Year(@From_Date) End as varchar(4)) + RIGHT(CONVERT(VARCHAR(10), Date_Of_Join, 112), 4))  BETWEEN @FromRange AND @ToRange	
					AND YEAR(Date_Of_Join) > 1900
			
			UPDATE	#Birthday
			SET		ReminderType = 'UW'
			WHERE	CAST(Month_Name AS INT) > @FromRange AND ReminderType = 'TW'
		END

	ALTER TABLE #Birthday  ADD AnnDate DateTime
	UPDATE #Birthday SET AnnDate = DateAdd(yyyy, year(getdate()) - year(Date_Of_birth),  Date_Of_birth)
	UPDATE #Birthday SET AnnDate = DATEADD(YYYY,1, AnnDate) WHERE AnnDate < CONVERT(DATETIME, CONVERT(VARCHAR(10), GETDATE(), 103),103)

	UPDATE	B
	SET		Image_Name = (CASE	WHEN E.Image_Name = '' OR E.Image_Name = '0.jpg'  THEN 
									(CASE	WHEN E.GENDer = 'M' THEN 'Emp_default.png' ELSE 'Emp_Default_Female.png' END) 
							ELSE 
								E.Image_Name 
							END),
			Emp_Full_Name  = E.Alpha_Emp_Code + ' - ' + E.Emp_Full_Name
	FROM	#Birthday B
			INNER JOIN T0080_EMP_MASTER E  WITH (NOLOCK) ON B.Emp_Id=E.Emp_ID
			
	
	/***********FINAL QUERY************/
	SELECT	Emp_Full_Name As EmpName,
			Case When SUBSTRING(ReminderType,1,1) = 'T' Then 'Today' Else Convert(Varchar(11),AnnDate,106) End As timelineTag,
			Case When IsNull(BM.Comp_Name,'') <> '' THen BM.Comp_Name Else C.Cmp_Name End As CmpName,
			B.Branch_Name As Branch, Department_Name As DeptName, Designation_Name As DesigName,
			Convert(Varchar(11),AnnDate,106) As AnnDate,B.Image_Name,B.ReminderType,
			Convert(Varchar(6),Date_Of_birth,106) As Date_Of_birth,
			Convert(Varchar(11),Date_Of_Join,106) As Date_Of_Join,
			 Convert(Varchar(11),Emp_Annivarsary_Date,106) As Emp_Annivarsary_Date
	FROM	#Birthday B 
			INNER JOIN T0010_COMPANY_MASTER C  WITH (NOLOCK) ON B.CMP_ID=C.CMP_ID
			INNER JOIN T0030_BRANCH_MASTER BM  WITH (NOLOCK) ON B.Branch_ID = BM.Branch_ID
	Where	IsNull(Month_Name, '0101') <> '0101' --AND Month_Name <> ''
	order by Month_Name
	
	
	--ORDER BY Sorting_No,Cmp_ID,
	--		CAST('2000' + Month_Name   AS NUMERIC), Alpha_Emp_Code
	--SELECT	Sorting_No,B.Cmp_Id,B.Emp_Full_Name,B.Month_Name,B.Branch_Name,
	--		(CASE	WHEN E.Image_Name = '' OR E.Image_Name = '0.jpg'  THEN 
	--				(CASE	WHEN E.GENDer = 'M' THEN 'Emp_default.png' ELSE 'Emp_Default_Female.png' END) 
	--		ELSE 
	--			E.Image_Name 
	--		END) AS Image_Name,
	--		B.Alpha_Emp_Code,B.Department_Name,B.Designation_Name,B.Emp_Id,
	--		(CASE	WHEN B.Date_Of_Join = '01/01/1900' THEN 
	--				'' 
	--		ELSE 
	--				CONVERT(VARCHAR(11), B.Date_Of_Join, 103)
	--		END) AS Date_Of_Join, B.Total_Completed_Years,E.Gender, ReminderType, Convert(Varchar(6),CONVERT(DATETIME, '2000' + Month_Name) , 106) As AnnDate
	--FROM	#Birthday B 
	--		LEFT OUTER JOIN T0080_EMP_MASTER E ON B.Emp_Id=E.Emp_ID 
	--Where	IsNull(Month_Name, '0101') <> '0101' AND Month_Name <> ''
	--ORDER BY Sorting_No,Cmp_ID,
	--		CAST('2000' + Month_Name   AS NUMERIC), Alpha_Emp_Code
	--		--CAST((CASE WHEN IsNULL(Month_Name,'') = '' THEN '01-January' ELSE Month_Name END) + (CASE WHEN CHARINDEX('JANUARY', B.Month_Name) > 0 THEN '-2001' ELSE '-2000' END) AS DATETIME),Alpha_Emp_Code -- Prakash Patel 25072014
END



