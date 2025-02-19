

CREATE PROCEDURE [dbo].[Get_Menu_Details_module_wise_Backup_18042024] 
	@cmp_id Numeric = 0,
	@Flag_ESS Varchar(100),
	@privilage_id Numeric = 0,
	@Language Varchar(20) ='en'
AS
BEGIN

	SET NOCOUNT ON;

    declare @Module_Status as varchar(max)
    Declare @AX_Mapping as Numeric
    Declare @Salary_Setting as Numeric    
    Declare @Claim_Setting as Numeric = 0
	DECLARE @SqlQuery nvarchar(max);
    	
	Set @SqlQuery = ''
	
	SELECT	@Module_Status= COALESCE(@Module_Status + ',', '') +  '''' + module_name + ''''
	FROM	T0011_module_detail  WITH (NOLOCK)
	WHERE	Cmp_id = @cmp_id AND module_status = 1	


	SELECT	@AX_Mapping = ISNULL(setting_value,0) 
	FROM	T0040_SETTING   WITH (NOLOCK)
	WHERE	Setting_name = 'AX' AND cmp_id = @cmp_id
	
	SELECT	@Salary_Setting = isnull(Setting_Value,0)   
	FROM	T0040_SETTING   WITH (NOLOCK)
	WHERE	Cmp_ID = @cmp_id AND Setting_Name = 'Salary Cycle Employee Wise'
	
	SELECT	@Claim_Setting = isnull(Setting_Value,0)   
	FROM	T0040_SETTING   WITH (NOLOCK)
	WHERE	Cmp_ID = @cmp_id AND Setting_Name = 'Enable CItywise Claim Application Selection in Claim'

	SET @Flag_ESS = CASE @Flag_ESS 
						WHEN 'A' THEN	'''AP'''	-- For Admin Setting 
						WHEN 'R' THEN	'''AP'''	-- For Report Setting 
						WHEN 'E' THEN	'''EP'''	-- For ESS Setting 
						WHEN 'H' THEN	'''HP'''	-- For HRMS Setting 
						WHEN 'AM' THEN	'''AP'',''AP'''		-- For Admin Master for Menu Search
						WHEN 'EM' THEN	'''EP'',''ER'''			-- For ESS Master for Menu Search
						WHEN 'HM' THEN	'''HP'''			-- For HRMS Master for Menu Search
					 END
	
	
	SET @SqlQuery = 'SELECT	F.FORM_ID,''  '' + F.FORM_NAME + ''  '' AS FORM_NAME, F.FORM_URL, F.FORM_IMAGE_URL, F.UNDER_FORM_ID,
							(CASE WHEN ''' + @Language + '''=''ch'' THEN '' '' + F.CHINESE_ALIAS + '' '' ELSE ''  '' + F.ALIAS + ''  '' END) AS ALIAS, 
							F.Page_Flag, PF.Alias As Parent_Menu,case F.Page_Flag
							when ''AP'' then ''/admin_associates'' + ''/'' + replace(replace(replace(replace(replace(replace(lower(F.Form_url),'' '',''-''),''../'',''''),''~/'',''''),''.aspx'',''''),''_'',''-''),''/'',''-'')
							when ''HP'' then case when F.Form_url = ''admin_associates/Master_hr_Document.aspx'' then ''/admin_associates/master-hr-document''
							else ''/hrms_forms'' + ''/'' + replace(replace(replace(replace(replace(replace(lower(F.Form_url),'' '',''-''),''../'',''''),''~/'',''''),''.aspx'',''''),''_'',''-''),''/'',''-'') end
							when ''EP'' then ''/ess_forms'' + ''/'' + replace(replace(replace(replace(replace(replace(lower(F.Form_url),'' '',''-''),''../'',''''),''~/'',''''),''.aspx'',''''),''_'',''-''),''/'',''-'')
							when ''DA'' then ''/admin_dashboard'' + ''/'' + replace(replace(replace(replace(replace(replace(lower(F.Form_url),'' '',''-''),''../'',''''),''~/'',''''),''.aspx'',''''),''_'',''-''),''/'',''-'')
							when ''ER'' then ''/ess_reports'' + ''/'' + replace(replace(replace(replace(replace(replace(lower(F.Form_url),'' '',''-''),''../'',''''),''~/'',''''),''.aspx'',''''),''_'',''-''),''/'',''-'')
							when ''AR'' then ''/admin_reports'' + ''/'' + replace(replace(replace(replace(replace(replace(lower(F.Form_url),'' '',''-''),''../'',''''),''~/'',''''),''.aspx'',''''),''_'',''-''),''/'',''-'')
							when ''DH'' then ''/hrms_dashboard'' + ''/'' + replace(replace(replace(replace(replace(replace(lower(F.Form_url),'' '',''-''),''../'',''''),''~/'',''''),''.aspx'',''''),''_'',''-''),''/'',''-'')
							when ''IP'' then ''/import_forms'' + ''/'' + replace(replace(replace(replace(replace(replace(lower(F.Form_url),'' '',''-''),''../'',''''),''~/'',''''),''.aspx'',''''),''_'',''-''),''/'',''-'')
							when ''DE'' then ''/ess_dashboard'' + ''/'' + replace(replace(replace(replace(replace(replace(lower(F.Form_url),'' '',''-''),''../'',''''),''~/'',''''),''.aspx'',''''),''_'',''-''),''/'',''-'')
							else case when F.Form_url = ''../Reports/Report_Employee_List.aspx'' then ''/admin_reports/report-employee-list''
							else F.Form_url end end as pageURL,
							''~/'' + case PF.Page_Flag when ''AP'' then
							''admin_associates'' when ''HP'' then ''HRMS'' else '''' end + ''/'' + F.Form_url as pagePath  '
	
	--if @Flag_ESS IN ('AM','EM','HM') 
	--	SET @SqlQuery = @SqlQuery + ' '

	--IF @privilage_id = 0
	--	SET @SqlQuery =  @SqlQuery + '
	--		FROM	T0000_DEFAULT_FORM  F LEFT OUTER JOIN T0000_DEFAULT_FORM PF ON F.Under_Form_ID = PF.Form_ID ' 
	--ELSE
	--	SET @SqlQuery =  @SqlQuery + '
	--		FROM	V0020_PRIVILEGE_MASTER_DETAILS  F LEFT OUTER JOIN T0000_DEFAULT_FORM PF ON F.Under_Form_ID = PF.Form_ID '

	
	IF @privilage_id = 0
		SET @SqlQuery =  @SqlQuery + '
			FROM	T0000_DEFAULT_FORM  F  WITH (NOLOCK) LEFT OUTER JOIN T0000_DEFAULT_FORM PF  WITH (NOLOCK) ON F.Under_Form_ID = PF.Form_ID 
			WHERE	1=1 AND F.Form_Name NOT IN (CASE WHEN ' + CAST(@Claim_Setting as varchar(10)) + ' = ''1'' THEN  ''Claim Application'' ELSE ''Claim Application New'' END)'
	ELSE
		SET @SqlQuery =  @SqlQuery + '
			FROM	V0020_PRIVILEGE_MASTER_DETAILS  F LEFT OUTER JOIN T0000_DEFAULT_FORM PF  WITH (NOLOCK) ON F.Under_Form_ID = PF.Form_ID 
			WHERE	F.Cmp_ID = ' + CAST(@cmp_id AS VARCHAR(100)) + ' AND 
					F.Privilege_ID = ' + CAST(@privilage_id AS VARCHAR(100)) + ' AND F.IS_ACTIVE=1 AND F.Form_Name NOT IN (CASE WHEN ' + CAST(@Claim_Setting as varchar(10)) + ' = ''1'' THEN  ''Claim Application'' ELSE ''Claim Application New'' END) '

	SET @SqlQuery = @SqlQuery + '
					AND F.IS_ACTIVE_FOR_MENU = 1 AND F.FORM_URL IS NOT NULL 
					AND (F.Module_name  in (' + ISNULL(@Module_Status,'''''') + ') OR F.Module_Name IS NULL)  
					AND F.Page_FLag IN (' + @Flag_ESS + ')
					AND F.Under_Form_ID = CASE WHEN F.Module_name = ''Task'' THEN -1 ELSE F.Under_Form_ID END '					

	IF @AX_Mapping <> 1
		SET @SqlQuery = @SqlQuery + ' and F.Form_Name <> ''AX Mapping'' '
		--SET @SqlQuery = @SqlQuery + ' and F.Form_Name <> ''AX Mapping Slab Master'' '
	IF @AX_Mapping <> 1
		SET @SqlQuery = @SqlQuery + ' and F.Form_Name <> ''AX Mapping Slab Master'' '

	IF @Salary_Setting <> 1
		SET @SqlQuery = @SqlQuery  + ' and F.Form_Name not in (''Salary Cycle Transfer'',''Salary Cycle Master'',''Reverse Salary'') '

	
	SET @SqlQuery =  @SqlQuery + '					
					ORDER BY F.SORT_ID, F.SORT_ID_CHECK'
		
	--Select @SqlQuery
	EXEC(@SqlQuery);
    --Print @SqlQuery


--	Select 'Claim' As Form_Name, 'home' As Form_Image_Url 
--		Union All
--	Select 'Control Panel' As Form_Name, 'settings' As Form_Image_Url 
--		Union All
--	Select 'Employee' As Form_Name, 'person' As Form_Image_Url 
--		Union All
--	Select 'Exit' As Form_Name, 'import_contacts' As Form_Image_Url 
--		Union All
--	Select 'HR Management' As Form_Name, 'contacts' As Form_Image_Url 
--		Union All
--	Select 'HRMS' As Form_Name, 'contacts' As Form_Image_Url 
--		Union All
--	Select 'Leave' As Form_Name, 'beach_access' As Form_Image_Url 
--		Union All
--	Select 'Loan LIC Claim' As Form_Name, 'home' As Form_Image_Url 
--		Union All
--	Select 'Loan LIC' As Form_Name, 'home' As Form_Image_Url 
--		Union All
--	Select 'Masters' As Form_Name, 'import_contacts' As Form_Image_Url 
--		Union All
--	Select 'My Reports' As Form_Name, 'assessment' As Form_Image_Url 
--		Union All
--	Select 'My Team' As Form_Name, 'person' As Form_Image_Url 
--		Union All
--	Select 'Reports' As Form_Name, 'assessment' As Form_Image_Url 
--		Union All
--	Select 'Salary Detail' As Form_Name, 'attach_money' As Form_Image_Url 
--		Union All
--	Select 'Salary Details' As Form_Name, 'attach_money' As Form_Image_Url 
--		Union All
--	Select 'Timesheet Management' As Form_Name, 'timer' As Form_Image_Url 
--		Union All
--	Select 'Travel Details' As Form_Name, 'home' As Form_Image_Url 

END