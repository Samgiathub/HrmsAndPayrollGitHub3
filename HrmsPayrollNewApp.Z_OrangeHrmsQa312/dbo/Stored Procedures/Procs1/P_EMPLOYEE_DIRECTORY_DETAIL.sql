
---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P_EMPLOYEE_DIRECTORY_DETAIL]    
	@CMP_ID				 NUMERIC,
	@EMP_ID				 NUMERIC,
	@EMPLOYEESTATUS		 VARCHAR(25),
	@SEARCH				 VARCHAR(MAX) = ''
 
AS    
		SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON  
		SET ANSI_WARNINGS OFF;

		IF @SEARCH <> ''
			SET @SEARCH = @SEARCH
		ELSE
			SET @SEARCH = ' AND 1=1 '	
				
		IF @EMPLOYEESTATUS <> ''
			SET @EMPLOYEESTATUS = @EMPLOYEESTATUS
		ELSE
			SET @EMPLOYEESTATUS = ' AND 1=1 '
	
		DECLARE @SQL AS VARCHAR(MAX)
		SET @SQL = ''	
		
		DECLARE @SELECT_COLS VARCHAR(MAX)
		--SET @SELECT_COLS = 'BRANCH_NAME [Branch],ISNULL(DEPT_NAME,'''') [Department],ISNULL(DESIG_NAME,'''') [Designation],
		--					Convert(Char(10),DATE_OF_JOIN, 103) [Date Of Joining],
		--					ISNULL(WORK_EMAIL,'''') [Work Email ID],ISNULL(WORK_TEL_NO,'''') [Work Phone No]
		--					'--,ISNULL(Emp_Last_Name,'''') [Employee Last Name] ,ISNULL(Emp_first_Name,'''') [Employee first Name],
							--	ISNULL(Extension_No,'''') [Extension No],ISNULL(MOBILE_NO,'''') [Mobile No],'
		 
		SELECT	@SELECT_COLS = COALESCE(@SELECT_COLS + ',','') + DBField + ' ' + '[' + Field_Label + ']'
		FROM	T0040_EMPLOYEE_DIRECTORY_COLUMNS WITH (NOLOCK)
		WHERE	IS_SHOW = 1 AND CMP_ID = @CMP_ID
		ORDER By SORT_INDEX ASC

		print @SELECT_COLS

		DECLARE @TEMP_COLS VARCHAR(MAX)
		SELECT	@TEMP_COLS = COALESCE(@TEMP_COLS + ',', '') + QUOTENAME(SUBSTRING(DATA , 0, CHARINDEX(']', DATA)))
		FROM	dbo.Split(@SELECT_COLS, '[') t
		WHERE	IsNull(DATA,'') <> '' AND ID > 1
		
		
		DECLARE @ALTER_COLS VARCHAR(MAX)
		SELECT	@ALTER_COLS = COALESCE(@ALTER_COLS + ';', '') + 'ALTER TABLE #EMP_DETAIL ADD ' + DATA + ' VARCHAR(1024)'
		FROM	dbo.Split(@TEMP_COLS, ',') t
		WHERE	IsNull(DATA,'') <> '' 
				
		CREATE TABLE #EMP_DETAIL
		(
			--ALPHA_EMP_CODE	VARCHAR(128),
			--GENDER			VARCHAR(32),
			--EMP_FULL_NAME	VARCHAR(256),
			IMAGE_NAME		VARCHAR(256)
		)
		
		EXEC (@ALTER_COLS)
		
		

		SET @SQL = 'INSERT	INTO	#EMP_DETAIL
					SELECT	CASE WHEN IMAGE_NAME = '''' OR IMAGE_NAME = ''0.JPG'' THEN 
									CASE WHEN GENDER=''MALE'' THEN 
										''EMP_DEFAULT.PNG'' 
									ELSE 
										''EMP_DEFAULT_FEMALE.PNG'' 
									END  
							ELSE 
								IMAGE_NAME 
							END AS IMAGE_NAME,' + @SELECT_COLS + '											
					FROM	V0080_EMPLOYEE_MASTER 
					WHERE	CMP_ID = ' + CONVERT(VARCHAR(5),@CMP_ID) + ' AND EMP_ID <> ' + CONVERT(VARCHAR(5),@EMP_ID) + '
							 ' + @EMPLOYEESTATUS +  @SEARCH
		
		EXEC (@SQL)		
		PRINT @SQL
		
	

		DECLARE @HTML_COLS VARCHAR(MAX)
		SELECT	@HTML_COLS = COALESCE(@HTML_COLS + '+', '') + '''<span title="' + REPLACE(REPLACE(DATA, '[', ''), ']', '') + '" class="Text_2">'' + ' + DATA + ' + ''</span>'' '
		FROM	dbo.Split(@TEMP_COLS, ',') T
		WHERE	Data <> ''
		
		PRINT @SQL
		SET  @SQL = 'SELECT	IMAGE_NAME,' + @HTML_COLS + ' AS HtmlDetail
					FROM	#EMP_DETAIL'
		
		
					
		PRINT @SQL
		EXEC (@SQL)
		--SELECT	ALPHA_EMP_CODE,GENDER, EMP_FULL_NAME,'<span title="Branch" class="Text_2">' + Branch + '</span><br /><span title="Designation" class="Text_2">' + Designation + '</span><br />'
		--FROM	#EMP_DETAIL
		
				
		
RETURN
