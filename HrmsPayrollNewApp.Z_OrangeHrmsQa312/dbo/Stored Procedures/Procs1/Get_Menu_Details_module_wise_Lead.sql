

 
 
-- Create by :Nilesh Patel 
-- Created Date : 22-06-2018
-- Description : Module wise hide & show rights
---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[Get_Menu_Details_module_wise_Lead] 
	@cmp_id NUMERIC = 0,
	@Flag_ESS VARCHAR(100),
	@privilage_id NUMERIC = 0
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
    
	DECLARE @SqlQuery NVARCHAR(MAX);
    	
	IF OBJECT_ID('tempdb..#LeadPrivilege') IS NOT NULL 
		DROP TABLE #LeadPrivilege

	CREATE TABLE #LeadPrivilege
	(
		FORM_ID NUMERIC(18,0) 
		, FORM_NAME VARCHAR(104)
		, FORM_URL VARCHAR(504)
		, FORM_ICON_CLASS VARCHAR(104)
		, LEAD_FORM_SORT INT
		, FORM_IMAGE_URL VARCHAR(504)
		, UNDER_FORM_ID NUMERIC(18,0)
		, ALIAS VARCHAR(104)		
		, PAGE_FLAG CHAR(2)
		, PARENT_MENU VARCHAR(104)		
	)

	Set @SqlQuery = ''	
	SET @SqlQuery = 'Insert into #LeadPrivilege
	
					SELECT	F.FORM_ID,ISNULL(F.FORM_NAME,'''') AS FORM_NAME,NULL AS FORM_URL,NULL AS FORM_ICON_CLASS
							,NULL AS LEAD_FORM_SORT,F.FORM_IMAGE_URL, F.UNDER_FORM_ID,F.ALIAS AS ALIAS
							,F.Page_Flag, PF.Alias As Parent_Menu '
					 
	IF @privilage_id = 0
		SET @SqlQuery =  @SqlQuery + '
			FROM	T0000_DEFAULT_FORM  F WITH (NOLOCK) LEFT OUTER JOIN T0000_DEFAULT_FORM PF WITH (NOLOCK) ON F.Under_Form_ID = PF.Form_ID 
			WHERE	1=1  AND F.FORM_NAME LIKE ''%Lead%'' '
	ELSE
		SET @SqlQuery =  @SqlQuery + '
			FROM	V0020_PRIVILEGE_MASTER_DETAILS  F LEFT OUTER JOIN T0000_DEFAULT_FORM PF WITH (NOLOCK) ON F.Under_Form_ID = PF.Form_ID 
			WHERE	F.Cmp_ID = ' + CAST(@cmp_id AS VARCHAR(100)) + ' AND 
					F.Privilege_ID = ' + CAST(@privilage_id AS VARCHAR(100)) + ' AND F.IS_ACTIVE = 1 AND F.FORM_NAME LIKE ''%Lead%'''

	SET @SqlQuery =  @SqlQuery + '					
					ORDER BY F.SORT_ID, F.SORT_ID_CHECK'
		
	PRINT @SqlQuery
	EXEC(@SqlQuery);
	
	-------=======Insert Dashboard with FOrmID 0 for keeping it in First Page=====---------------Ashwin 25/06/2018
	INSERT INTO #LeadPrivilege VALUES(0,'Dashboard','Dashboard.aspx','fa-home',1,'',0,'Dashboard','','')	
	
	-------=======Updating Pages with URL and Page Icons to set in Menu=====---------------Ashwin 25/06/2018
	UPDATE #LeadPrivilege SET FORM_URL = 'LeadApplication.aspx', FORM_ICON_CLASS='md-account', LEAD_FORM_SORT=2 WHERE FORM_NAME = 'Lead Application'	
	UPDATE #LeadPrivilege SET FORM_URL = 'AssignLead.aspx', FORM_ICON_CLASS='md-account-box-mail', LEAD_FORM_SORT=3 WHERE FORM_NAME = 'Lead Assign'
	
	
	SELECT * FROM #LeadPrivilege ORDER BY FORM_ID

END

