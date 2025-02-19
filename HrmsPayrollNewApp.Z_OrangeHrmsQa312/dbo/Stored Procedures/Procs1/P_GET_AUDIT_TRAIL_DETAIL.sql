
---25/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P_GET_AUDIT_TRAIL_DETAIL]
	@Audit_Trail_ID		NUMERIC
AS
	BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

		CREATE TABLE #JOIN_TEMPLATE(ID INT IDENTITY, TableName Varchar(128), IDColName Varchar(128), DisplayColName Varchar(128))
		INSERT INTO #JOIN_TEMPLATE
		SELECT 'T0010_Company_Master', 'Cmp_ID', 'Cmp_Name'
		UNION 
		SELECT 'T0030_Branch_Master', 'Branch_ID', 'Branch_Name'


		DECLARE @Audit_Modulle_Description Varchar(Max)

		SELECT @Audit_Modulle_Description = Audit_Modulle_Description
		FROM T9999_AUDIT_TRAIL WITH (NOLOCK)
		WHERE Audit_Trail_Id = @Audit_Trail_ID

	
		CREATE TABLE #NewValue(ID INT IDENTITY, ColName Varchar(128), ColValue Varchar(Max))
		CREATE TABLE #OldValue(ID INT IDENTITY, ColName Varchar(128), ColValue Varchar(Max))

		DECLARE @CharPos INT = 0
		DECLARE @LastIndex INT = 0
		DECLARE @StrPart Varchar(Max)

		DECLARE @IsNew BIT
		SET @IsNew = 0

		SET @CharPos = CharIndex('#', @Audit_Modulle_Description)
		
		WHILE (@LastIndex < LEN(@Audit_Modulle_Description)) --AND @LastIndex < @CharPos
			BEGIN								
				SET @StrPart =  LTrim(substring(@Audit_Modulle_Description, @LastIndex, @CharPos - @LastIndex))
				if @StrPart = 'old Value'
					SET @IsNew= 0
				Else if @StrPart = 'New Value'
					SET @IsNew= 1
					
				
				IF CHARINDEX(':', @StrPart) > 0
					BEGIN
						IF @IsNew = 1
							INSERT INTO #NewValue
							SELECT	SUBSTRING(@StrPart, 0, CHARINDEX(':', @StrPart)-1), SUBSTRING(@StrPart, CHARINDEX(':', @StrPart)+1, LEN(@StrPart))
						ELSE
							INSERT INTO #OldValue
							SELECT	SUBSTRING(@StrPart, 0, CHARINDEX(':', @StrPart)-1), SUBSTRING(@StrPart, CHARINDEX(':', @StrPart)+1, LEN(@StrPart))
					END
			
			
				SET @LastIndex = @CharPos +1
				SET @CharPos = CharIndex('#', @Audit_Modulle_Description,@LastIndex )
				IF @CharPos  = 0 and @LastIndex > 0
					SET @CharPos = LEN(@Audit_Modulle_Description)
			END
			
		UPDATE #NewValue SET  ColName=LTRIM(RTRIM(ColName)), ColValue= LTRIM(RTRIM(ColValue)) 
		UPDATE #OldValue SET  ColName=LTRIM(RTRIM(ColName)), ColValue= LTRIM(RTRIM(ColValue)) 

		
		
		DELETE	T
		FROM	#NewValue T
				INNER JOIN  #OldValue T1 ON T.ColName=T1.ColName AND T.ColValue = T1.ColValue
		Where	NOT EXISTS(SELECT TOP 4 1 FROM #NewValue N WHERE T.ID=N.ID AND N.ColName Like '%ID')

		DELETE	T
		FROM	#OldValue T
				LEFT OUTER JOIN  #NewValue T1 ON T.ColName=T1.ColName 
		WHERE	T1.ColName Is Null


		DECLARE @IDColName VARCHAR(128)
		DECLARE @DisplayColName VARCHAR(128)
		DECLARE @TableName Varchar(128)

		DECLARE @Template Varchar(1024)
		DECLARE @Sql Varchar(1024)
		DECLARE @Query Varchar(1024)
		SET @Template = 'IsNull((Select Top 1 @DisplayColName FROM @TableName Where @IDColName = @ColValue), @ColValue)'

		DECLARE curIDField CURSOR Fast_Forward FOR
		SELECT	DISTINCT IDColName, DisplayColName, TableName
		FROM	#JOIN_TEMPLATE T1		
		WHERE	Exists(select 1 from #NewValue N Where N.ColName=T1.IDColName)
				OR Exists(select 1 from #OldValue N Where N.ColName=T1.IDColName)
		OPEN curIDField 
		FETCH NEXT FROM curIDField INTO @IDColName, @DisplayColName, @TableName
		WHILE @@FETCH_STATUS = 0
			BEGIN 
				SET @Query = REPLACE(REPLACE(REPLACE(@Template, '@TableName', @TableName), '@DisplayColName', @DisplayColName), '@IDColName', @IDColName)
				
				SET @Query = 'UPDATE	L
							SET		ColValue = ' + Replace(@Query, '@ColValue', 'ColValue') + ',
									ColName = IsNull(''' + @DisplayColName + ''', ColName)							
							FROM	#TableName L							
							WHERE	(ColName = ''' + @IDColName + ''')'
					
				SET @SQL = REPLACE(@Query, '#TableName', '#NewValue')		
				EXEC(@SQL)
				
				SET @SQL = REPLACE(@Query, '#TableName', '#OldValue')		
				EXEC(@SQL)
				
				FETCH NEXT FROM curIDField INTO @IDColName, @DisplayColName, @TableName
			END
		CLOSE curIDField
		DEALLOCATE curIDField

			
		DECLARE @Html Varchar(Max)
				

		SELECT @Html = COALESCE(@Html, '') + '<tr><td>' + IsNull(O.ColName, N.ColName) + '</td><td>' + IsNull(O.ColValue, '-') + '</td><td>' + IsNull(N.ColValue, '-') + '</td></tr>'
		FROM #NewValue N FULL OUTER JOIN #OldValue O ON N.ColName=O.ColName					
				
		print @Html
		SET @Html = '<table style="width:100%;">
						<tr>
							<td style="font-weight:bold;">Field Name</td>
							<td style="font-weight:bold;">Old Value</td>
							<td style="font-weight:bold;">New Value</td>
						</tr>' + @Html + 
						'</table>'
						
		
		SELECT @Html As AMD
	END




