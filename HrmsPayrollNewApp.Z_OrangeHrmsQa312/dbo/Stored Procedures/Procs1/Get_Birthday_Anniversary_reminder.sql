

-----Created By Mukti(08042016)for Birthday,Marriage AND Work anniversary Reminder
CREATE PROCEDURE [dbo].[Get_Birthday_Anniversary_reminder]
   @Cmp_ID NUMERIC(18,0),  
   @pPrivilage_ID  VARCHAR(MAX) = 0,
   @pPrivilage_Department VARCHAR(MAX) = '',	--Added By Jaina 11-08-2016
   @pPrivilage_Vertical VARCHAR(MAX) = '',		--Added By Jaina 11-08-2016
   @pPrivilage_Sub_Vertical VARCHAR(MAX) = ''	--Added By Jaina 11-08-2016
AS  
BEGIN
	
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET ARITHABORT ON;

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
	FROM	T0040_SETTING WITH (NOLOCK)
	WHERE	Setting_Name = 'Show Birthday Reminder Group Company wise' AND Cmp_ID = @Cmp_ID
	    
	DECLARE @Display_Actual_Birthdate TINYINT --Added by Sumit ON 15122016
	SELECT	@Display_Actual_Birthdate=IsNULL(Setting_Value , 0)  
	FROM	T0040_SETTING  WITH (NOLOCK)
	WHERE	Setting_Name = 'Display Actual Birth Date' AND Cmp_ID = @Cmp_ID

	DECLARE @ShowWorkAnni INT
	SELECT	@ShowWorkAnni=IsNull(Setting_Value,0)
	FROM	T0040_SETTING  WITH (NOLOCK)
	WHERE	Setting_Name='Show Work Anniversary Reminder ON Dashboard' AND Cmp_ID=@Cmp_ID 
	
	DECLARE @ShowMarraigeAnniversary INT
	SET @ShowMarraigeAnniversary = 1
	/*End of Admin Settings*/
	
	--Added By Mukti(23032017)start
	IF	@pPrivilage_ID = '' OR @pPrivilage_ID = '0'
		SET @pPrivilage_ID = NULL
	
	IF @pPrivilage_Vertical = '' OR @pPrivilage_Vertical = '0'
		SET @pPrivilage_Vertical = NULL
			
	IF @pPrivilage_Sub_Vertical = '' OR @pPrivilage_Sub_Vertical='0'
		SET @pPrivilage_Sub_Vertical = NULL
		
	IF @pPrivilage_Department = '' OR @pPrivilage_Department='0'
		SET @pPrivilage_Department = NULL
	
	--BRANCH
	IF @pPrivilage_ID IS NULL OR @Show_GrpCmp_Birthday=1
		INSERT	INTO #PRIVILEGE(TRAN_ID, P_TYPE)
		SELECT	BRANCH_ID, 'B' FROM T0030_BRANCH_MASTER B  WITH (NOLOCK) WHERE (CASE WHEN @Show_GrpCmp_Birthday=1 THEN @CMP_ID ELSE Cmp_ID END)=@Cmp_ID
	ELSE
		INSERT	INTO #PRIVILEGE(TRAN_ID, P_TYPE)
		SELECT	CAST(DATA AS NUMERIC), 'B' FROM dbo.Split(@pPrivilage_ID, '#') T 
		WHERE	IsNull(Data,'') <> ''
	
	--VERTICAL
	IF @pPrivilage_Vertical IS NULL	
		INSERT	INTO #PRIVILEGE(TRAN_ID, P_TYPE)
		SELECT	Vertical_ID, 'V' FROM T0040_Vertical_Segment B WITH (NOLOCK) WHERE (CASE WHEN @Show_GrpCmp_Birthday=1 THEN @CMP_ID ELSE Cmp_ID END)=@Cmp_ID
	ELSE
		INSERT	INTO #PRIVILEGE(TRAN_ID, P_TYPE)
		SELECT	CAST(DATA AS NUMERIC), 'V' FROM dbo.Split(@pPrivilage_Vertical, '#') T 
		WHERE	IsNull(Data,'') <> ''
		
	--SUB VERTICAL
	IF @pPrivilage_Sub_Vertical IS NULL	
		INSERT	INTO #PRIVILEGE(TRAN_ID, P_TYPE)
		SELECT	SubVertical_ID, 'S' FROM T0050_SubVertical S WITH (NOLOCK) WHERE (CASE WHEN @Show_GrpCmp_Birthday=1 THEN @CMP_ID ELSE Cmp_ID END)=@Cmp_ID
	ELSE
		INSERT	INTO #PRIVILEGE(TRAN_ID, P_TYPE)
		SELECT	CAST(DATA AS NUMERIC), 'S' FROM dbo.Split(@pPrivilage_Sub_Vertical, '#') T 
		WHERE	IsNull(Data,'') <> ''

	--Department
	IF @pPrivilage_Department IS NULL
		INSERT	INTO #PRIVILEGE(TRAN_ID, P_TYPE)
		SELECT	Dept_Id, 'D' FROM T0040_DEPARTMENT_MASTER D WITH (NOLOCK) WHERE (CASE WHEN @Show_GrpCmp_Birthday=1 THEN @CMP_ID ELSE Cmp_ID END)=@Cmp_ID
	ELSE
		INSERT	INTO #PRIVILEGE(TRAN_ID, P_TYPE)
		SELECT	CAST(DATA AS NUMERIC), 'D' FROM dbo.Split(@pPrivilage_Department, '#') T 
		WHERE	IsNull(Data,'') <> ''


	SELECT	I.Cmp_ID,E.Emp_ID, E.Alpha_Emp_Code,(Initial + ' ' + Emp_First_Name + ' ' + Emp_Last_Name) As Emp_Name,
			Date_Of_Birth,I.Branch_ID,BM.Branch_Name,E.Image_Name,Desg.Desig_Name,DM.Dept_Name,Date_Of_Join,
			0 AS Total_Completed_Years, IsNull(Chk_Birth,1) As Chk_Birth
			,Emp_Annivarsary_Date
			, I.Dept_ID, I.Vertical_ID, I.SubVertical_ID
	INTO	#EMP_DATA
	FROM	(SELECT Emp_ID, Initial, Emp_First_Name, Emp_Last_Name, Alpha_Emp_Code, Image_Name, Date_Of_Join,
				Emp_Annivarsary_Date,
				--CONVERT(DATETIME, CASE WHEN ISNULL(Emp_Annivarsary_Date,'') = '' THEN '01/01/1900' ELSE Emp_Annivarsary_Date END , 103) AS Emp_Annivarsary_Date,
				CASE WHEN @Display_Actual_Birthdate=0 THEN 
					CONVERT(VARCHAR(11),IsNull(Date_Of_Birth, '1900-01-01'),106) 
				ELSE
					CASE WHEN IsNULL(E.Actual_Date_Of_Birth,'1900-01-01') ='1900-01-01' THEN
						IsNull(Date_Of_Birth, '1900-01-01') 
					ELSE 
						E.Actual_Date_Of_Birth 
					END 
				END AS Date_Of_Birth
		FROM	T0080_Emp_master E WITH (NOLOCK)
		WHERE	ISNULL(E.Emp_Left_Date, GETDATE()+1) > GETDATE()) E
		INNER JOIN	T0095_INCREMENT I WITH (NOLOCK) ON I.Emp_ID = e.emp_id 
		INNER JOIN (SELECT	Max(TI.Increment_ID) Increment_Id,TI.Emp_ID 
					FROM	T0095_INCREMENT TI WITH (NOLOCK) 
							INNER JOIN (SELECT	Max(Increment_Effective_Date) AS Increment_Effective_Date,Emp_ID 
										FROM	T0095_INCREMENT WITH (NOLOCK) 
										WHERE	Increment_Effective_Date <= GETDATE() 
										GROUP BY Emp_ID) New_Inc ON TI.Emp_ID = New_Inc.Emp_ID AND TI.Increment_Effective_Date=New_Inc.Increment_Effective_Date
					WHERE	TI.Increment_Effective_Date <= GETDATE() 
					GROUP BY TI.Emp_ID)	Qry2 ON Qry2.Emp_ID=E.Emp_ID AND Qry2.Increment_Id=I.Increment_ID
		INNER JOIN	T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I.Branch_ID = BM.Branch_ID
		LEFT JOIN	T0030_CATEGORY_MASTER CM WITH (NOLOCK) ON I.Cat_ID = CM.Cat_ID
		LEFT JOIN	T0040_DESIGNATION_MASTER Desg WITH (NOLOCK) ON I.Desig_Id = Desg.Desig_ID   --Mukti 11012016
		LEFT JOIN	T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I.Dept_ID = DM.Dept_ID   --Mukti 11012016
		INNER JOIN	(SELECT TRAN_ID FROM #PRIVILEGE P WHERE P_TYPE='B') PB ON I.Branch_ID=PB.TRAN_ID
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

	
---WHERE	IsNULL(CM.Chk_Birth,1) = 1 


	--IF @pPrivilage_ID IS NULL
	--	BEGIN	
	--		SELECT  @pPrivilage_ID = COALESCE(@pPrivilage_ID + '#', '') + CAST(Branch_ID AS NVARCHAR(5))  
	--		FROM	T0030_BRANCH_MASTER 
	--		WHERE	Cmp_ID=@Cmp_ID 
	--		SET @pPrivilage_ID = @pPrivilage_ID + '#0'
	--	END
		
	--IF @pPrivilage_Vertical IS NULL
	--	BEGIN	
	--		SELECT   @pPrivilage_Vertical = COALESCE(@pPrivilage_Vertical + '#', '') + CAST(Vertical_ID AS NVARCHAR(5))  FROM T0040_Vertical_Segment WHERE Cmp_ID=@Cmp_ID 
			
	--		IF @pPrivilage_Vertical IS NULL
	--			SET @pPrivilage_Vertical = '0';
	--		ELSE
	--			SET @pPrivilage_Vertical = @pPrivilage_Vertical + '#0'		
	--	END
	--IF @pPrivilage_Sub_Vertical IS NULL
	--	BEGIN	
	--		SELECT   @pPrivilage_Sub_Vertical = COALESCE(@pPrivilage_Sub_Vertical + '#', '') + CAST(subVertical_ID AS NVARCHAR(5))  FROM T0050_SubVertical WHERE Cmp_ID=@Cmp_ID 
			
	--		IF @pPrivilage_Sub_Vertical IS NULL
	--			SET @pPrivilage_Sub_Vertical = '0';
	--		ELSE
	--			SET @pPrivilage_Sub_Vertical = @pPrivilage_Sub_Vertical + '#0'
	--	END
	--IF @pPrivilage_Department IS NULL
	--	BEGIN
	--		SELECT   @pPrivilage_Department = COALESCE(@pPrivilage_Department + '#', '') + CAST(Dept_ID AS NVARCHAR(5))  FROM T0040_DEPARTMENT_MASTER WHERE Cmp_ID=@Cmp_ID 		
			
	--		IF @pPrivilage_Department IS NULL
	--			SET @pPrivilage_Department = '0';
	--		ELSE
	--			SET @pPrivilage_Department = @pPrivilage_Department + '#0'
	--	END
	--Added By Mukti(23032017)END	
	CREATE TABLE #Birthday 
	(
		Emp_Full_Name		VARCHAR(MAX),     --modified jimit 02022016  
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
		Cmp_Id				NUMERIC 
	)
		
	    
		
	INSERT INTO #Birthday VALUES('&nbsp&nbsp&nbsp<b style="font-size:10px;color:#804D00;"><u>TODAYS BIRTHDAY <u></b>',NULL,'',0,'','',NULL ,1,'','','',0,'','',0)
	If @ShowMarraigeAnniversary = 1
		INSERT INTO #Birthday VALUES('&nbsp&nbsp&nbsp<b style="font-size:10px;color:#804D00;"><u>TODAYS MARRIAGE ANNIVERSARY <u></b>',NULL,'',0,'','',NULL ,3,'','','',0,'','',0)
				
	IF @ShowWorkAnni=1
		BEGIN			
			INSERT INTO #Birthday VALUES('&nbsp&nbsp&nbsp<b style="font-size:10px;color:#804D00;"><u>TODAYS WORK ANNIVERSARY <u></b>',NULL,'',0,'','',NULL ,5,'','','',0,'','',0)
		END
		
	INSERT INTO #Birthday VALUES('&nbsp&nbsp&nbsp<b style="font-size:10px;color:#804D00;"><u>UPCOMING BIRTHDAY <u></b>',NULL,'',0,'','',NULL ,7,'','','',0,'','',0)
	
	If @ShowMarraigeAnniversary = 1
		INSERT INTO #Birthday VALUES('&nbsp&nbsp&nbsp<b style="font-size:10px;color:#804D00;"><u>UPCOMING MARRIAGE ANNIVERSARY <u></b>',NULL,'',0,'','',NULL,9,'','','',0,'','',0)
		
	IF @ShowWorkAnni=1
		BEGIN
			INSERT INTO #Birthday VALUES('&nbsp&nbsp&nbsp<b style="font-size:10px;color:#804D00;"><u>UPCOMING WORK ANNIVERSARY <u></b>',NULL,'',0,'','',NULL,11,'','','',0,'','',0)
		END
	 
	 
	DECLARE @Display_Cmp_Name	VARCHAR(100)
	DECLARE @Display_Cmp_ID		NUMERIC(18,0)
	DECLARE @Todays_Date		VARCHAR(20)  --Mukti 11012016
	
	    
	 
	DECLARE Cur_Today CURSOR FORWARD_ONLY FOR 

	SELECT	dbo.ProperCase(Cmp_name), Cmp_id 
	FROM	T0010_COMPANY_MASTER  WITH (NOLOCK)
	WHERE	(CASE	WHEN @Show_GrpCmp_Birthday = 1 AND is_GroupOFCmp = 1	THEN 1 
					WHEN @Show_GrpCmp_Birthday=0 AND cmp_id=@cmp_id			THEN 1 
					ELSE 0 END) = 1
	OPEN Cur_Today        
	FETCH NEXT FROM Cur_Today INTO  @Display_Cmp_Name , @Display_Cmp_ID

	WHILE @@FETCH_STATUS = 0        
		BEGIN 				
			SET @Todays_Date=(RIGHT('00' + CONVERT(NVARCHAR(2), DATEPART(DAY, GETDATE())), 2) + '-' + UPPER(dbo.F_GET_MONTH_NAME(MONTH(GETDATE()))))	--Added By Ramiz ON 06/10/2016 for Proper Sorting
					
			/*****For Birthday Reminder of todays date(start)*****/
					
			--Today's Birthday Header
			INSERT INTO #Birthday VALUES('&nbsp&nbsp&nbsp<b style="font-size:10px;color:#351224;"><i> '+ @Display_Cmp_Name +' '+ @Todays_Date +' </i></b>' ,NULL,'',0,'','',NULL,2 ,'','','',0,'','',@Display_Cmp_ID) 

			--Today's Birthday
			INSERT	INTO #Birthday
			SELECT	Emp_Name,Date_Of_Birth,(CAST(DAY(Date_Of_Birth) AS VARCHAR(3)) + '-' + UPPER(dbo.F_GET_MONTH_NAME(MONTH(Date_Of_birth)))) AS Month_Name,
					Branch_ID,Branch_Name,Image_Name,ROW_NUMBER() Over (ORDER BY MONTH(Date_Of_Birth),DAY(Date_Of_Birth)), 2,
					Alpha_Emp_Code,Desig_Name,Dept_Name,Emp_ID,'',0 AS Total_Completed_Years,@Display_Cmp_ID
			FROM	#EMP_DATA
			WHERE	Cmp_ID=@Display_Cmp_ID AND Chk_Birth = 1 							
					AND MONTH(Date_Of_Birth)=MONTH(GETDATE()) AND DAY(Date_Of_Birth)=DAY(GETDATE())
					AND YEAR(Date_Of_Birth) > 1900
					
					
			--IF Above TransactiON Does not Returs any employee THEN we have deleted the name of that company also.
			IF @@ROWCOUNT = 0
				DELETE	FROM #Birthday 
				WHERE	Emp_Full_Name ='&nbsp&nbsp&nbsp<b style="font-size:10px;color:#351224;"><i> '+ @Display_Cmp_Name +' '+ @Todays_Date +' </i></b>' AND CAST(Sorting_No AS INT) = 2  --commented By Mukti 12012016 
			/*****For Birthday Reminder of todays date(END)*****/

			/*****For Marriage Anniversary Reminder of todays date(start)*****/				
			If @ShowMarraigeAnniversary = 1
				BEGIN
					--Today's Marriage Anniversary Header
					INSERT	INTO #Birthday VALUES('&nbsp&nbsp&nbsp<b style="font-size:10px;color:#351224;"><i> '+ @Display_Cmp_Name +' '+ @Todays_Date +'</i></b>' ,NULL,'',0,'','',NULL,4,'','','',0,'','',@Display_Cmp_ID)      

					--Today's Marriage Anniversary 
					INSERT	INTO #Birthday
					SELECT	Emp_Name,Emp_Annivarsary_Date AS Date_Of_Birth,'',Branch_ID,Branch_Name,Image_Name,
							ROW_NUMBER() Over (ORDER BY MONTH(Emp_Annivarsary_Date),DAY(Emp_Annivarsary_Date)),4,
							Alpha_Emp_Code,Desig_Name,Dept_Name,Emp_ID,'' AS Date_Of_join,0 AS Total_Completed_Years, Cmp_ID
					FROM	#EMP_DATA ED
					WHERE	Cmp_ID=@Display_Cmp_ID AND chk_Birth = 1
							AND MONTH(Emp_Annivarsary_Date)=MONTH(GETDATE()) AND DAY(Emp_Annivarsary_Date)=DAY(GETDATE())
							AND YEAR(Emp_Annivarsary_Date) > 1900 and Year(Emp_Annivarsary_Date) > Year(GETDATE()) --added by mehul 06102022 year to get proper employee for marriage anniversary  
							
					--Delete the Header if there is no Today's Marriage Anniversary is exists
					IF @@ROWCOUNT = 0
						DELETE	FROM #Birthday 
						WHERE	Emp_Full_Name = '&nbsp&nbsp&nbsp<b style="font-size:10px;color:#351224;"><i> '+ @Display_Cmp_Name +' '+ @Todays_Date +'</i></b>' AND CAST(Sorting_No AS INT) = 4  --commented by Mukti 12012016
				END
					/*****For Marriage Anniversary Reminder of todays date(END)*****/				
						
			/*****For Work anniversary Reminder of todays date(start)*****/				
			IF @ShowWorkAnni = 1
				BEGIN

					--Today's Work Anniversary Header
					INSERT INTO #Birthday VALUES('&nbsp&nbsp&nbsp<b style="font-size:10px;color:#351224;"><i> '+ @Display_Cmp_Name +' '+ @Todays_Date +'</i></b>' ,NULL,'',0,'','',NULL,6,'','','',0,'','',@Display_Cmp_ID)      

					INSERT	INTO #Birthday
					SELECT	Emp_Name,Date_Of_Join AS Date_Of_Birth,'',Branch_ID,Branch_Name,Image_Name,		
							ROW_NUMBER() Over (ORDER BY MONTH(Date_Of_Join),DAY(Date_Of_Join)),6,
							Alpha_Emp_Code,Desig_Name,Dept_Name,Emp_ID,Date_Of_Join,DATEDIFF(YEAR,Date_Of_Join,GETDATE()) AS Total_Completed_Years,Cmp_ID
					FROM	#EMP_DATA ED
					WHERE	Cmp_ID=@Display_Cmp_ID AND Chk_Birth = 1
							AND MONTH(Date_Of_Join)=MONTH(GETDATE()) AND DAY(Date_Of_Join)=DAY(GETDATE()) 
							AND YEAR(Date_Of_Join) > 1900 and Year(GETDATE()) > Year(Date_Of_Join)  --added by mehul 06102022 year to get proper employee for Work anniversary

					--Delete the Header if there is no Today's Work Anniversary
					IF @@ROWCOUNT = 0
						DELETE	FROM #Birthday 
						WHERE	Emp_Full_Name = '&nbsp&nbsp&nbsp<b style="font-size:10px;color:#351224;"><i> '+ @Display_Cmp_Name +' '+ @Todays_Date +'</i></b>' AND CAST(Sorting_No AS INT) = 6  --commented by Mukti 12012016
				END
			/*****For Work anniversary Reminder of todays date(END)*****/
	
			FETCH NEXT FROM Cur_Today INTO  @Display_Cmp_Name,@Display_Cmp_ID
		END        
	CLOSE Cur_Today        
	DEALLOCATE Cur_Today 
		
	
	DECLARE @From_Date	DATETIME
	DECLARE @To_Date	DATETIME

	SET @From_Date = CONVERT(DATETIME, CONVERT(CHAR(10),GETDATE() + 1, 103), 103)
	SET @To_Date =   CONVERT(DATETIME, CONVERT(CHAR(10),GETDATE() + 1, 103), 103) + 7

	DECLARE Cur_Upcoming CURSOR FORWARD_ONLY FOR
			
	SELECT	dbo.ProperCase(Cmp_name), Cmp_id 
	FROM	T0010_COMPANY_MASTER WITH (NOLOCK) 
	WHERE	(CASE	WHEN @Show_GrpCmp_Birthday = 1 AND is_GroupOFCmp = 1	THEN 1 
					WHEN @Show_GrpCmp_Birthday=0 AND cmp_id=@cmp_id			THEN 1 
					ELSE 0 END ) = 1
	OPEN Cur_Upcoming        
			
	FETCH NEXT FROM Cur_Upcoming INTO @Display_Cmp_Name , @Display_Cmp_ID
			
	WHILE @@FETCH_STATUS = 0        
		BEGIN					
			/*****For Birthday Reminder of upcoming date(START)*****/

			--Upcomming Birthday Header
			INSERT INTO #Birthday VALUES( '&nbsp&nbsp&nbsp<b style="font-size:10px;color:#351224;"><i> '+ @Display_Cmp_Name +' </i></b>' ,NULL,'',0,'','',NULL,8,'','','',0,'','',@Display_Cmp_ID)      

			--Upcomming Birthday
			SELECT	Emp_Name AS Emp_Full_Name,Date_Of_Birth,
					(CAST(RIGHT('00' + CONVERT(NVARCHAR(2), DATEPART(DAY, Date_Of_birth)), 2) AS VARCHAR(3)) + '-' + UPPER(dbo.F_GET_MONTH_NAME(MONTH(Date_Of_birth))))  Month_Name,
					Branch_ID,Branch_Name,Image_Name ,ROW_NUMBER() Over (ORDER BY MONTH(Date_Of_Birth),DAY(Date_Of_Birth)) AS Row_ID, 8 AS Sorting_no,
					Alpha_Emp_Code,Desig_Name,Dept_Name,Emp_ID,'' AS Date_Of_join,0 AS Total_Completed_Years,Cmp_Id
			INTO	#UpcomingBDay
			FROM	#EMP_DATA ED
			WHERE	Cmp_ID=@Display_Cmp_ID AND Chk_Birth = 1 
					AND (DATEADD(yy, YEAR(@FROM_DATE) - YEAR(Date_Of_Birth),  Date_Of_Birth) BETWEEN @From_Date AND @To_Date)
					AND YEAR(Date_Of_Birth) > 1900
			ORDER BY MONTH(Date_Of_birth),DAY(Date_Of_Birth)				 
									  
			INSERT	INTO #Birthday
			SELECT	* FROM
			(
				SELECT Emp_Full_Name,Date_Of_Birth,Month_Name,Branch_ID,Branch_Name,Image_Name,Row_ID,Sorting_No,Alpha_Emp_Code,Desig_Name,Dept_Name,Emp_ID ,Date_Of_Join,Total_Completed_Years,Cmp_Id
				FROM #UpcomingBDay
				UniON All
				SELECT ('&nbsp&nbsp&nbsp<b style="font-size:10px;color:#351224;"><i>Date : ' + Month_Name + ' </i></b>') AS Emp_Full_Name,'' AS Date_Of_Birth,Month_Name,0 AS Branch_ID,'' AS Branch_Name,'' AS Image_Name,0 AS Row_ID,Sorting_No,'' AS Alhpa_Emp_Code,'' AS Desig_Name,'' AS Dept_Name,0 AS Emp_ID,'' AS Date_Of_Join,'' AS Total_Completed_Years,cmp_id
				FROM #UpcomingBDay Group BY Month_Name, Sorting_No,Cmp_Id
			) T
			ORDER BY CAST(Month_Name + '-2000' AS DATETIME), Alpha_Emp_Code
							
			--Header should be deleted if there is no Upcomming Birthday exists
			IF @@ROWCOUNT = 0
				DELETE	FROM #Birthday 
				WHERE	Emp_Full_Name = '&nbsp&nbsp&nbsp<b style="font-size:10px;color:#351224;"><i> '+ @Display_Cmp_Name +' </i></b>' AND CAST(Sorting_No AS INT) = 8

			DROP TABLE #UpcomingBDay
			/*****For Birthday Reminder of upcoming date(END)*****/
				
			/*****For Marriage Anniversary Reminder of upcoming date(start)*****/
			If @ShowMarraigeAnniversary = 1
				BEGIN		
				
					--For Upcomming Marriage Anniversary Header
					INSERT INTO #Birthday VALUES( '&nbsp&nbsp&nbsp<b style="font-size:10px;color:#351224;"><i> '+ @Display_Cmp_Name +' </i></b>' ,NULL,'',0,'','',NULL,10,'','','',0,'','',@Display_Cmp_ID)        

					
					--For Upcomming Marriage Anniversary 
					SELECT	Emp_Name AS Emp_Full_Name,Emp_Annivarsary_Date AS Date_Of_Birth, 
							(CAST(RIGHT('00' + CONVERT(NVARCHAR(2), DATEPART(DAY, Emp_Annivarsary_Date)), 2) AS VARCHAR(3)) + '-' + UPPER(dbo.F_GET_MONTH_NAME(MONTH(Emp_Annivarsary_Date)))) AS Month_Name,
							Branch_ID,Branch_Name,Image_Name,ROW_NUMBER() Over (ORDER BY MONTH(Emp_Annivarsary_Date),DAY(Emp_Annivarsary_Date)) AS Row_ID,				
							10 AS Sorting_no,Alpha_Emp_Code,Desig_Name,Dept_Name,Emp_ID,'' AS Date_Of_join,0 AS Total_Completed_Years ,Cmp_Id
					INTO	#UpcomingAnniversary
					FROM	#EMP_DATA ED
					WHERE	Cmp_ID = @Display_Cmp_ID AND Chk_Birth = 1 		
					AND cast(Emp_Annivarsary_Date as date) <> '' AND CAST(IsNULL(cast(Emp_Annivarsary_Date as date),'1900-01-01') AS DATETIME) <> '1900-01-01'
					AND (DATEADD(yy, YEAR(@FROM_DATE) - YEAR(cast(Emp_Annivarsary_Date as date)),  cast(Emp_Annivarsary_Date as date)) BETWEEN @From_Date AND @To_Date)
					AND YEAR(Emp_Annivarsary_Date) > 1900
					ORDER BY MONTH(Emp_Annivarsary_Date),DAY(Emp_Annivarsary_Date)
					-- Deepal 14122022 Date convert to Cast 
					--WHERE	Cmp_ID = @Display_Cmp_ID AND Chk_Birth = 1 														
					--		AND Emp_Annivarsary_Date <> '' AND CAST(IsNULL(Emp_Annivarsary_Date,'1900-01-01') AS DATETIME) <> '1900-01-01'
					--		AND (DATEADD(yy, YEAR(@FROM_DATE) - YEAR(Emp_Annivarsary_Date),  Emp_Annivarsary_Date) BETWEEN @From_Date AND @To_Date)
					--		AND YEAR(Emp_Annivarsary_Date) > 1900
					--ORDER BY MONTH(Emp_Annivarsary_Date),DAY(Emp_Annivarsary_Date) 
					-- Deepal 14122022 Date convert to Cast 
			
					INSERT	INTO #Birthday
					SELECT	*	FROM
					(
						SELECT	Emp_Full_Name,Date_Of_Birth,Month_Name,Branch_ID,Branch_Name,Image_Name,Row_ID,Sorting_No,Alpha_Emp_Code,Desig_Name,Dept_Name,Emp_ID ,Date_Of_Join,Total_Completed_Years,Cmp_Id 
						FROM	#UpcomingAnniversary
						UNION	ALL
						SELECT	('&nbsp&nbsp&nbsp<b style="font-size:10px;color:#351224;"><i>Date : ' + Month_Name + ' </i></b>') AS Emp_Full_Name,'' AS Date_Of_Birth,Month_Name,0 AS Branch_ID,'' AS Branch_Name,'' AS Image_Name,0 AS Row_ID,Sorting_No - 0.00005,'' AS Alhpa_Emp_Code,'' AS Desig_Name,'' AS Dept_Name,0 AS Emp_ID,'' AS Date_Of_Join,'' AS Total_Completed_Years,Cmp_Id
						FROM	#UpcomingAnniversary Group BY Month_Name, Sorting_No,Cmp_Id
					) T
					ORDER BY	CAST(Month_Name + '-2000' AS DATETIME), Alpha_Emp_Code
								

					--Header should be deleted if there is no Upcomming Marriage Anniversary exists
					IF @@ROWCOUNT = 0
					DELETE	FROM #Birthday 
					WHERE	Emp_Full_Name = '&nbsp&nbsp&nbsp<b style="font-size:10px;color:#351224;"><i> '+ @Display_Cmp_Name +' </i></b>' AND CAST(Sorting_No AS INT) = 10
							
					DROP	TABLE #UpcomingAnniversary

				END

				
			/*****For Marriage Anniversary Reminder of upcoming date(END)*****/

			/*****For Work anniversary Reminder of upcoming date(start)*****/
			IF @ShowWorkAnni = 1
				BEGIN
							
					--Upcomming Work Anniversary Header
					INSERT INTO #Birthday VALUES( '&nbsp&nbsp&nbsp<b style="font-size:10px;color:#351224;"><i> '+ @Display_Cmp_Name +' </i></b>' ,NULL,'',0,'','',NULL,12,'','','',0,'','',@Display_Cmp_ID)        
						
					--Upcomming Work Anniversary
					SELECT	Emp_Name AS Emp_Full_Name,Date_Of_Join AS Date_Of_Birth,
							(CAST(RIGHT('00' + CONVERT(NVARCHAR(2), DATEPART(DAY, Date_Of_Join)), 2) AS VARCHAR(3)) + '-' + UPPER(dbo.F_GET_MONTH_NAME(MONTH(Date_Of_Join)))) AS Month_Name,
							Branch_ID,Branch_Name,Image_Name,ROW_NUMBER() Over (ORDER BY MONTH(Date_Of_Join),DAY(Date_Of_Join)) AS Row_ID,
							12 AS Sorting_no,Alpha_Emp_Code,Desig_Name,Dept_Name,Emp_ID,Date_Of_Join,DATEDIFF(YEAR,Date_Of_Join,GETDATE()) AS Total_Completed_Years,Cmp_Id
					INTO	#UpcomingWorkAnniversary --Mukti 11012016
					FROM	#EMP_DATA ED
					WHERE	Cmp_ID=@Display_Cmp_ID AND Chk_Birth = 1 					 
							AND (DATEADD(yy, YEAR(@FROM_DATE) - YEAR(Date_Of_Join),  Date_Of_Join) BETWEEN @From_Date AND @To_Date)
					ORDER BY MONTH(Date_Of_Join),DAY(Date_Of_Join) 
					
					INSERT	INTO #Birthday
					SELECT	*	FROM
					(
						SELECT	Emp_Full_Name,Date_Of_Birth,Month_Name,Branch_ID,Branch_Name,Image_Name,Row_ID,Sorting_No,Alpha_Emp_Code,Desig_Name,Dept_Name,Emp_ID ,Date_Of_Join,Total_Completed_Years,Cmp_Id 
						FROM	#UpcomingWorkAnniversary
						UNION	ALL
						SELECT	('&nbsp&nbsp&nbsp<b style="font-size:10px;color:#351224;"><i>Date : ' + Month_Name + ' </i></b>') AS Emp_Full_Name,'' AS Date_Of_Birth,Month_Name,0 AS Branch_ID,'' AS Branch_Name,'' AS Image_Name,0 AS Row_ID,Sorting_No - 0.00005,'' AS Alhpa_Emp_Code,'' AS Desig_Name,'' AS Dept_Name,0 AS Emp_ID,'' AS Date_Of_Join,'' AS Total_Completed_Years,Cmp_Id
						FROM	#UpcomingWorkAnniversary 
						GROUP BY Month_Name, Sorting_No,Cmp_Id
					) T
					ORDER BY CAST(Month_Name + '-2000' AS DATETIME), Alpha_Emp_Code
					
					--Header should be deleted if there is no Upcomming Marriage Anniversary exists
					IF @@ROWCOUNT = 0
						DELETE	FROM #Birthday 
						WHERE	Emp_Full_Name = '&nbsp&nbsp&nbsp<b style="font-size:10px;color:#351224;"><i> '+ @Display_Cmp_Name +' </i></b>' AND CAST(Sorting_No AS INT) = 12
							
					DROP TABLE #UpcomingWorkAnniversary
				END
				/*****For Work anniversary Reminder of upcoming date(END)*****/
			FETCH NEXT FROM Cur_Upcoming INTO @Display_Cmp_Name,@Display_Cmp_ID
		END
	CLOSE	Cur_Upcoming        
	DEALLOCATE Cur_Upcoming 
	    
		/***********FINAL QUERY************/
		SELECT	Sorting_No,B.Cmp_Id,B.Emp_Full_Name,B.Month_Name,B.Branch_Name,
				(CASE	WHEN E.Image_Name = '' OR E.Image_Name = '0.jpg'  THEN 
						(CASE	WHEN E.GENDer = 'M' THEN 'Emp_default.png' ELSE 'Emp_Default_Female.png' END) 
				ELSE 
					E.Image_Name 
				END) AS Image_Name,
				B.Alpha_Emp_Code,B.Department_Name,B.Designation_Name,B.Emp_Id,
				(CASE	WHEN B.Date_Of_Join = '01/01/1900' THEN 
						'' 
				ELSE 
						CONVERT(VARCHAR(11), B.Date_Of_Join, 103)
				END) AS Date_Of_Join, B.Total_Completed_Years,E.Gender
		 FROM	#Birthday B 
				LEFT OUTER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON B.Emp_Id=E.Emp_ID 
		where B.Cmp_Id = @Cmp_ID -- deepal add the company id condition. 27102022
		 ORDER BY Sorting_No,Cmp_ID
					,CAST((CASE WHEN IsNULL(Month_Name,'') = '' THEN '01-January' ELSE Month_Name END) +
					(CASE WHEN CHARINDEX('January', B.Month_Name) > 0 THEN '-2001' ELSE '-2000' END) AS datetime)
					,Alpha_Emp_Code -- Prakash Patel 25072014
					--Changed else condition in case when from 2001 to 2000 for checking feb leap year 21022022 (mehul)

END



