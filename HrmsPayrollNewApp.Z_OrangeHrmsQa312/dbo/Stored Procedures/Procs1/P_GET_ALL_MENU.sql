
CREATE PROCEDURE [dbo].[P_GET_ALL_MENU]
	@cmp_id Numeric,
	@Flag_ESS Varchar(12) = 'A',
	@Privilege_ID Numeric = 0
AS
BEGIN

	SET NOCOUNT ON;

    declare @Module_Status as VARCHAR(1024)
    Declare @AX_Mapping as Numeric
    Declare @Salary_Setting as Numeric    
    
	SELECT	@AX_Mapping = ISNULL(setting_value,0) 
	FROM	T0040_SETTING  WITH (NOLOCk)
	WHERE	Setting_name = 'AX' AND cmp_id = @cmp_id
	
	SELECT	@Salary_Setting = isnull(Setting_Value,0)   
	FROM	T0040_SETTING  WITH (NOLOCk)
	WHERE	Cmp_ID = @cmp_id AND Setting_Name = 'Salary Cycle Employee Wise'
	
	SET @Flag_ESS = CASE SUBSTRING(@Flag_ESS ,1,1)
						WHEN 'A' THEN	'AP,AR'	-- For Admin Setting & Reports
						WHEN 'E' THEN	'EP,ER'	-- For ESS Setting 
						WHEN 'H' THEN	'HP'	-- For HRMS Setting 						
					 END
	
	CREATE TABLE #Category
	(
		ID INT IDENTITY,
		Flag Char(2),
		Category Varchar(64),
		CatURLPrefix  Varchar(128)
	)
	INSERT INTO #Category
	SELECT	'AP', 'Payroll Form',''
	UNION ALL
	SELECT	'EP', 'Payroll Form',''
	UNION ALL
	SELECT	'HP', 'HRMS Form',''
	UNION ALL
	SELECT	'AR', 'Report','../Reports/'
	UNION ALL
	SELECT	'ER', 'Report',''
	

	CREATE TABLE #MENU
	(		
		ROW_ID		INT,
		FORM_ID		INT,
		Alias		Varchar(128),
		FORM_NAME	Varchar(128),
		FORM_URL	Varchar(512),
		FORM_IMAGE_URL Varchar(512),
		UNDER_FORM_ID INT,
		Page_Flag	Varchar(2),
		Parent_Menu	Varchar(128),
		Category	Varchar(64),
		ActualURL	Varchar(512)
	)
	
	DECLARE @SqlQuery NVARCHAR(max);
    		
	SET @SqlQuery = 'INSERT INTO #MENU
					 SELECT ROW_NUMBER() OVER(ORDER BY F.SORT_ID,F.Sort_Id_Check,F.FORM_ID) AS ROW_ID,
							F.FORM_ID,F.Alias,F.FORM_NAME, IsNull(C.CatURLPrefix,'''') + replace(F.FORM_URL,''~/'', '''') FORM_URL, F.FORM_IMAGE_URL, F.UNDER_FORM_ID,
							F.Page_Flag, PF.Alias As Parent_Menu, C.Category,F.FORM_URL ActualURL
					 '
	DECLARE @Where NVARCHAR(2048)
	SET @Where = 'AND F.IS_ACTIVE_FOR_MENU = 1
					AND (EXISTS (SELECT 1 FROM dbo.Split(@Module_Status,'','') T Where T.Data=F.Module_Name) OR F.Module_Name IS NULL OR F.Module_Name IS NOT NULL)  
					AND EXISTS(SELECT 1 FROM dbo.Split(@Flag_ESS, '','') T Where T.Data=F.Page_Flag)'
	
	IF @AX_Mapping <> 1
		SET @Where = @Where + ' and F.Form_Name <> ''AX Mapping'' '
		SET @Where = @Where + ' and F.Form_Name <> ''AX Mapping Slab Master'' '
		

	IF @Salary_Setting <> 1
		SET @Where = @Where  + ' and F.Form_Name not in (''Salary Cycle Transfer'',''Salary Cycle Master'',''Reverse Salary'') '

		
	IF @Privilege_ID = 0
		BEGIN
			
			SET @SqlQuery =  @SqlQuery + '
				FROM	T0000_DEFAULT_FORM  F WITH (NOLOCk) LEFT OUTER JOIN T0000_DEFAULT_FORM PF WITH (NOLOCk) ON F.Under_Form_ID = PF.Form_ID 
						INNER JOIN #Category C ON F.Page_Flag = C.Flag
				WHERE	1=1 ' + @Where
			exec sp_executesql @SqlQuery, N'@Module_Status Varchar(1024), @Flag_ESS Varchar(12)',@Module_Status, @Flag_ESS			
		END
	ELSE
		BEGIN
			SET @SqlQuery =  @SqlQuery + '
				FROM	V0020_PRIVILEGE_MASTER_DETAILS  F WITH (NOLOCk) LEFT OUTER JOIN T0000_DEFAULT_FORM PF WITH (NOLOCk) ON F.Under_Form_ID = PF.Form_ID 
						INNER JOIN #Category C ON F.Page_Flag = C.Flag
				WHERE	F.Cmp_ID = @Cmp_id AND F.Privilege_ID = @Privilege_ID AND F.IS_ACTIVE=1 ' + @Where

			exec sp_executesql @SqlQuery, N'@Cmp_id Numeric,@Privilege_ID Numeric, @Module_Status Varchar(1024), @Flag_ESS Varchar(12)',@cmp_id,@Privilege_ID,@Module_Status, @Flag_ESS
		END

	;WITH R(ROW_ID,Form_ID,Under_Form_ID,Sort_Order,Chk_ID) AS
	(
		SELECT	ROW_ID, Form_ID, Under_Form_ID, CAST((RIGHT('000' + CAST(ROW_ID AS VARCHAR),4)) AS VARCHAR(512)) AS Sort_Order, CAST((RIGHT('00000' + CAST(ROW_ID AS VARCHAR),5)) AS VARCHAR(1024)) AS Chk_ID
		FROM	#MENU T1
		WHERE	UNDER_FORM_ID = -1
		UNION ALL
		SELECT	T2.ROW_ID, T2.Form_ID,T2.Under_Form_ID,CAST((R.Sort_Order + RIGHT('000' + CAST(T2.ROW_ID AS VARCHAR),4)) AS VARCHAR(512)) As Sort_Order
		,CAST((R.Chk_ID + ' ' + RIGHT('00000' + CAST(T2.ROW_ID AS VARCHAR),5)) AS VARCHAR(1024)) As Chk_ID
		FROM	#MENU T2 INNER JOIN R ON T2.Under_Form_ID=R.Form_ID
	)
	SELECT	R.Sort_Order,M.FORM_ID,M.Alias,M.FORM_NAME,M.FORM_URL,M.Parent_Menu,M.Category
	FROM	R INNER JOIN #MENU M ON M.Form_ID=R.Form_ID
	WHERE	M.Under_Form_ID <> -1 AND M.FORM_URL IS NOT NULL 			
			AND IsNull(Form_URL,'') NOT IN ('', 'home.aspx')
			AND IsNull(ActualURL,'') <> ''
	ORDER BY R.Sort_Order

END