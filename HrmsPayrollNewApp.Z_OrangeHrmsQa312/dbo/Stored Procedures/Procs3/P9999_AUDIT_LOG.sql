
---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P9999_AUDIT_LOG]	
	@TableName			Varchar(128),
	@IDFieldName		Varchar(128),
	@Audit_Module_Name	Varchar(128),
	@User_Id			Numeric,
	@IP_Address			Varchar(128),
	@MandatoryFields	Varchar(256) = '',
	@Audit_Change_Type	Char(1) = 'I'	
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	BEGIN
	
		DECLARE @Cmp_ID NUMERIC
		
		CREATE TABLE #MandatoryColumns(ID INT IDENTITY, ColName Varchar(128))
		
		DECLARE @Sep Char(1)
		SET @Sep = ','
		IF CharIndex('#', @MandatoryFields) > 0
			SET @Sep = '#'
			
		IF LEN(@MandatoryFields) > 0
			INSERT INTO #MandatoryColumns		
			SELECT DATA FROM dbo.Split(@MandatoryFields, @Sep) T
		ELSE
			INSERT INTO #MandatoryColumns		
			SELECT Top 4 Column_Name FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME=@TableName and DATA_TYPE IN ('NUMERIC', 'INT', 'DATETIME')
		
		INSERT INTO #MandatoryColumns VALUES (@IDFieldName)
		
		DECLARE @QUERY NVARCHAR(MAX)
		
		
		--IF OBJECT_ID('tempdb..#DELETED') IS NOT NULL
		--	BEGIN
		--		IF EXISTS(SELECT 1 FROM #DELETED)
		--			AND EXISTS(SELECT 1 FROM #INSERTED)
		--			SET @Audit_Change_Type  = 'U'				
		--		ELSE
		--			SET @Audit_Change_Type  = 'D'				
		--	END
		--ELSE 
		--	SET @Audit_Change_Type  = 'I'
		
		--IF EXISTS(SELECT 1 FROM #INSERTED) 
		--	AND EXISTS(SELECT 1 FROM #DELETED)
		--	SET @Audit_Change_Type  = 'U'
		--ELSE IF NOT EXISTS(SELECT 1 FROM #INSERTED) 
		--		AND EXISTS(SELECT 1 FROM #DELETED) 
		--	SET @Audit_Change_Type  = 'D'
		--ELSE
		--	SET @Audit_Change_Type  = 'I'
		
		
		DECLARE @CAST_COLS VARCHAR(MAX)
		DECLARE @COLS VARCHAR(MAX)
		SELECT	@COLS = COALESCE(@COLS + ',','') + '[' + NAME + ']'  ,
				@CAST_COLS = COALESCE(@CAST_COLS + ',','') + ' IsNull(Cast([' + NAME + '] As Varchar(Max)), ''NULL'') AS [' + NAME + ']'
		FROM	tempdb.sys.columns where object_id=object_id('tempdb..#' + @TableName + '_INSERTED')
		
		CREATE TABLE #AUDIT_LOG(ID INT IDENTITY, ColName Varchar(128), ColValue Varchar(Max), IsNew Bit)
		
		SET @QUERY = 'INSERT INTO #AUDIT_LOG
					  SELECT ColName, ColValue, 1 As IsNew
					  FROM   
							(SELECT ' + @CAST_COLS  + '
							 FROM #' + @TableName + '_INSERTED) p  
					  UNPIVOT  
							(ColValue FOR ColName IN (' + @COLS + '))AS unpvt;'
		
		
		EXEC (@QUERY)



		SET @COLS = NULL
		SET @CAST_COLS = NULL
		
		SELECT	@COLS = COALESCE(@COLS + ',','') + '[' + NAME + ']'  ,
				@CAST_COLS = COALESCE(@CAST_COLS + ',','') + ' IsNull(Cast([' + NAME + '] As Varchar(Max)), ''NULL'') AS [' + NAME + ']'
		FROM	tempdb.sys.columns where object_id=object_id('tempdb..#' + @TableName + '_DELETED')
		
		
		SET @QUERY = 'INSERT INTO #AUDIT_LOG
					  SELECT ColName, ColValue, 0 As IsNew
					  FROM   
							(SELECT ' + @CAST_COLS  + '
							 FROM #' + @TableName + '_DELETED) p  
					  UNPIVOT  
							(ColValue FOR ColName IN (' + @COLS + '))AS unpvt;'
		
		
		EXEC (@QUERY)
		
		
		IF NOT EXISTS(SELECT 1 FROM #AUDIT_LOG)
			RETURN
		
		SELECT TOP 1 @Cmp_ID = ColValue FROM #AUDIT_LOG WHERE IsNumeric(ColValue) = 1 AND ColName='Cmp_ID'
		
		
		DECLARE @NewValues VARCHAR(MAX)
		DECLARE @OldValues VARCHAR(MAX)
		DECLARE @Audit_Modulle_Description VARCHAR(MAX)
		
				
		IF @Audit_Change_Type = 'U'	--UPDATE		
			BEGIN
				SELECT	@NewValues = COALESCE(@NewValues + '#','')  + IsNull(N.ColName, O.ColName) + ' :' + IsNull(N.ColValue, O.ColValue) ,
						@OldValues = COALESCE(@OldValues + '#','')  + IsNull(O.ColName, N.ColName) + ' :' + IsNull(O.ColValue, N.ColValue)
				FROM	(SELECT  * FROM #AUDIT_LOG WHERE IsNew=1) N
						FULL OUTER JOIN (SELECT  * FROM #AUDIT_LOG WHERE IsNew=0) O ON O.ColName=N.ColName AND O.ColValue <> N.ColValue
						LEFT OUTER JOIN #MandatoryColumns C ON N.ColName=C.ColName
				WHERE	(O.ID IS NOT NULL AND N.ID IS NOT NULL) OR C.ColName IS NOT NULL	
				--ORDER BY ISNULL(N.ID, O.ID)									
			END
		ELSE IF @Audit_Change_Type = 'D'	--UPDATE		
			SELECT	@OldValues = COALESCE(@OldValues + '#','')  + O.ColName + ' :' + O.ColValue 
			FROM	#AUDIT_LOG O
			WHERE	IsNew=0	
			ORDER BY ID
		ELSE			
			SELECT	@NewValues = COALESCE(@NewValues + '#','')  + N.ColName + ' :' + N.ColValue
			FROM	#AUDIT_LOG N
			WHERE	IsNew=1								
			ORDER BY ID
			
		
		
		--SET @Audit_Modulle_Description = 'Old Value#' + @OldValues
		--IF @NewValues IS NOT NULL
		--	SET @Audit_Modulle_Description =  IsNull(@Audit_Modulle_Description + '#', '') + 'New Value#' + @NewValues

		IF @Audit_Change_Type = 'D'
			SET @Audit_Modulle_Description =  @OldValues
		ELSE
			SET @Audit_Modulle_Description =  @NewValues
		

						
		DECLARE @IDFieldValue Numeric
		SELECT Top 1 @IDFieldValue = Cast(ColValue As Numeric) FROM #AUDIT_LOG Where IsNumeric(ColValue) = 1 AND ColName=@IDFieldName
		
			
		EXEC P9999_Audit_Trail @Cmp_ID=@Cmp_ID, @Audit_Change_Type=@Audit_Change_Type, @Audit_Module_Name=@Audit_Module_Name,
								@Audit_Modulle_Description=@Audit_Modulle_Description, @Audit_Change_For = @IDFieldValue, 
								@Audit_Change_By=@User_Id,@Audit_Ip=@IP_Address
	END
	
	

