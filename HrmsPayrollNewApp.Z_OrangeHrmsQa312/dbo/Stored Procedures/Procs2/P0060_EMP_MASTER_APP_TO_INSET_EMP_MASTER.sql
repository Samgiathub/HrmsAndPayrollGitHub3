


--BEGIN TRAN 

---SELECT  * FROM T0060_EMP_MASTER_APP

-- =============================================
-- Author:		Binal
-- Create date: 20-09-2019
-- Description:	Insert Data In To Employee Tables From Make A checker application
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0060_EMP_MASTER_APP_TO_INSET_EMP_MASTER]
	/*DECLARE */
	@Emp_Tran_ID BIGINT,
	@Emp_Id INT OUTPUT,
	@Approval_Date	DateTime /*= '2019-04-15' */
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


	Declare @Ref_Emp_Tran_ID BIGINT=0  
	
	SET @Ref_Emp_Tran_ID =0  
	
	SELECT @Approval_Date = CONVERT(datetime, convert(varchar(10), @Approval_Date,103),103)
	
	
	IF EXISTS(SELECT 1 FROM  T0060_EMP_MASTER_APP WITH (NOLOCK) WHERE Emp_Tran_ID = @Emp_Tran_ID)
		Begin
			
			--This  Reference Emp Tran ID will be used to take data from all child application tables
			SET @Ref_Emp_Tran_ID=@Emp_Tran_ID
			
			--Taking data into temp table which supposed to be inserted in T0080_EMP_MASTER
			SELECT * INTO #T0060_EMP_MASTER_APP_INSERTED FROM T0060_EMP_MASTER_APP WITH (NOLOCK) WHERE Emp_Tran_ID=@Ref_Emp_Tran_ID
			
			--Taking Next Employee ID 
			Set @Emp_ID=(SELECT Max(IsNull(Emp_ID,0)) FROM T0080_EMP_MASTER WITH (NOLOCK)) + 1
			
			UPDATE #T0060_EMP_MASTER_APP_INSERTED SET Emp_ID=@Emp_ID
			
			
			ALTER TABLE #T0060_EMP_MASTER_APP_INSERTED DROP COLUMN Login_ID
			
			DECLARE @COLS VARCHAR(MAX)
			
			SELECT	@COLS = COALESCE(@COLS + ',','') + QUOTENAME(p.name)
			FROM	(SELECT  name FROM tempdb.sys.columns WHERE object_id = object_id('tempdb..#T0060_EMP_MASTER_APP_INSERTED')) T
					INNER JOIN (SELECT  name FROM sys.columns WHERE object_id = object_id('T0080_EMP_MASTER')) P ON T.name=P.name
			
			DECLARE @SQL NVARCHAR(MAX)
			SET @SQL  = 'INSERT INTO T0080_EMP_MASTER(' + @COLS + ') 
						 SELECT ' + @COLS + ' from #T0060_EMP_MASTER_APP_INSERTED'
			
			
			EXEC (@SQL)
			
			
			
			CREATE TABLE #CopyTables
			(
				ID INT,
				From_Table	VARCHAR(256),
				Table_Name VARCHAR(256),
				Column_Name		VARCHAR(256),
				ForDateColumn	Varchar(128)
			)
			
			INSERT INTO #CopyTables 
			SELECT 1,   'T0070_EMP_INCREMENT_APP',  'T0095_INCREMENT', 'Increment_ID', 'Increment_Effective_Date' UNION ALL			
			SELECT 2,   'T0065_EMP_REPORTING_DETAIL_APP', 'T0090_EMP_REPORTING_DETAIL', 'Row_ID', 'Effect_Date' UNION ALL
			SELECT 3,   'T0065_EMP_SHIFT_DETAIL_APP',  'T0100_EMP_SHIFT_DETAIL', 'Shift_Tran_ID','For_Date' UNION ALL
			SELECT 4,   'T0065_EMP_CHILDRAN_DETAIL_APP',  'T0090_EMP_CHILDRAN_DETAIL', 'Row_ID','FOR_DATE' UNION ALL
			SELECT 5,   'T0065_EMP_CONTRACT_DETAIL_APP', 'T0090_EMP_CONTRACT_DETAIL', 'Tran_ID','FOR_DATE' UNION ALL
			SELECT 6,   'T0065_EMP_DEPENDANT_DETAIL_APP',  'T0090_EMP_DEPENDANT_DETAIL', 'Row_ID','FOR_DATE' UNION ALL			
			SELECT 7,   'T0065_EMP_DOC_DETAIL_APP', 'T0090_EMP_DOC_DETAIL', 'Row_ID','FOR_DATE' UNION ALL			
			SELECT 8,   'T0065_EMP_EMERGENCY_CONTACT_DETAIL_APP',  'T0090_EMP_EMERGENCY_CONTACT_DETAIL', 'Row_ID','FOR_DATE' UNION ALL
			SELECT 9,   'T0065_EMP_EXPERIENCE_DETAIL_APP', 'T0090_EMP_EXPERIENCE_DETAIL', 'Row_ID','FOR_DATE' UNION ALL			
			SELECT 10,  'T0065_EMP_IMMIGRATION_DETAIL_APP', 'T0090_EMP_IMMIGRATION_DETAIL', 'Row_ID','FOR_DATE' UNION ALL			
			SELECT 11,  'T0065_EMP_LANGUAGE_DETAIL_APP', 'T0090_EMP_LANGUAGE_DETAIL', 'Row_ID','FOR_DATE' UNION ALL			
			SELECT 12,  'T0065_EMP_LICENSE_DETAIL_APP', 'T0090_EMP_LICENSE_DETAIL', 'Row_ID','FOR_DATE' UNION ALL			
			SELECT 13,  'T0065_EMP_QUALIFICATION_DETAIL_APP', 'T0090_EMP_QUALIFICATION_DETAIL', 'Row_ID','FOR_DATE' UNION ALL			
			SELECT 14,  'T0065_EMP_SKILL_DETAIL_APP', 'T0090_EMP_SKILL_DETAIL', 'Row_ID','FOR_DATE' UNION ALL			
			SELECT 15,  'T0065_EMP_REFERENCE_DETAIL_APP',  'T0090_EMP_REFERENCE_DETAIL', 'Reference_ID','For_Date' UNION ALL			
			SELECT 16,  'T0070_WEEKOFF_ADJ_APP',  'T0100_WEEKOFF_ADJ', 'W_Tran_ID' ,'For_Date' UNION ALL			
			SELECT 17,  'T0070_EMP_SCHEME_APP',  'T0095_EMP_SCHEME', 'Tran_ID','Effective_Date' UNION ALL			
			SELECT 18,  'T0075_EMP_EARN_DEDUCTION_APP', 'T0100_EMP_EARN_DEDUCTION', 'AD_TRAN_ID','FOR_DATE'
			
			
			
			DECLARE @FROM_TABLE_NAME VARCHAR(128)
			DECLARE @TABLE_NAME VARCHAR(128)
			DECLARE @COLUMN_NAME VARCHAR(128)
			DECLARE @ForDate_ColName VARCHAR(128)
			
			
				 
			DECLARE curTable CURSOR FAST_FORWARD FOR 
			SELECT	From_Table, Table_Name, Column_Name,ForDateColumn FROM #CopyTables
			OPEN curTable
			
			FETCH NEXT FROM curTable INTO @FROM_TABLE_NAME, @TABLE_NAME, @COLUMN_NAME,@ForDate_ColName
			
			WHILE @@fetch_status = 0
				BEGIN
					
				
					SET @SQL  = '
						DECLARE @COLS VARCHAR(MAX)
						DECLARE @SQL VARCHAR(MAX)
						DECLARE @MaxID BIGINT
						
						
						SET @MaxID = IsNull((SELECT MAX(' + @COLUMN_NAME + ') FROM ' + @TABLE_NAME + '),0) ;
						
						SELECT * INTO #' + @FROM_TABLE_NAME + ' FROM  ' + @FROM_TABLE_NAME + ' Where Emp_Tran_ID=@Emp_Tran_ID;
						
						
						IF NOT EXISTS(SELECT 1 FROM tempdb.sys.columns WHERE object_id = object_id(''tempdb..#' + @FROM_TABLE_NAME + ''') AND name=''Emp_ID'') 
							ALTER TABLE #' + @FROM_TABLE_NAME + ' ADD Emp_ID INT
							
						IF NOT EXISTS(SELECT 1 FROM tempdb.sys.columns WHERE object_id = object_id(''tempdb..#' + @FROM_TABLE_NAME + ''') AND name=''' + @ForDate_ColName + ''') AND NOT LEN(''' + @ForDate_ColName + ''') = 0
							ALTER TABLE #' + @FROM_TABLE_NAME + ' ADD ' + @ForDate_ColName + ' DateTime
						
						UPDATE	T
						SET		Emp_ID=@Emp_ID, 
								' + @COLUMN_NAME + ' = T1.TROW_ID + @MaxID, 
								' + @ForDate_ColName + '= @Approval_Date
						FROM	#' + @FROM_TABLE_NAME + ' T
								INNER JOIN (SELECT ROW_NUMBER() OVER(ORDER BY T.' + @COLUMN_NAME + ') AS TROW_ID,Emp_Tran_ID,T.' + @COLUMN_NAME + '
											FROM	#' + @FROM_TABLE_NAME + ' T) T1 ON T.Emp_Tran_ID=T1.Emp_Tran_ID and T.' + @COLUMN_NAME + '=T1.' + @COLUMN_NAME + '
								
						/*
						SELECT   ''' + @FROM_TABLE_NAME + ''' As Table_Name,''' + @COLUMN_NAME + ''',T1.TROW_ID + @MaxID, * 
						FROM	#' + @FROM_TABLE_NAME + ' T
								INNER JOIN (SELECT ROW_NUMBER() OVER(ORDER BY T.' + @COLUMN_NAME + ') AS TROW_ID,Emp_Tran_ID,T.' + @COLUMN_NAME + '
											FROM	#' + @FROM_TABLE_NAME + ' T) T1 ON T.Emp_Tran_ID=T1.Emp_Tran_ID and T.' + @COLUMN_NAME + '=T1.' + @COLUMN_NAME + '
						
						*/
						SET @COLS = NULL;
						SELECT	@COLS = COALESCE(@COLS + '','','''') + QUOTENAME(p.name)
						FROM	(SELECT  name FROM tempdb.sys.columns WHERE object_id = object_id(''tempdb..#' + @FROM_TABLE_NAME + ''')) T
								INNER JOIN (SELECT  name FROM sys.columns WHERE object_id = object_id(''' + @Table_Name + ''')) P ON T.name=P.name;
						
						SET @SQL  = ''INSERT INTO ' + @TABLE_NAME +  '('' + @COLS + '') 
									 SELECT '' + @COLS + '' from #' + @FROM_TABLE_NAME +';''
									 
						
						EXEC(@SQL);
						
						/*
						SELECT ''' + @FROM_TABLE_NAME + ''',  * FROM ' + @FROM_TABLE_NAME + ' WHERE Emp_Tran_ID = @Emp_Tran_ID
						
						SELECT ''' + @Table_Name + ''',  * FROM ' + @TABLE_NAME + ' WHERE Emp_ID = @Emp_ID
						*/
						
					'
					--select  Cast(@SQL as xml)
					
					exec sp_executesql @SQL, N'@Emp_Tran_ID BIGINT, @Emp_ID INT, @Approval_Date DateTime', @Emp_Tran_ID, @Emp_ID, @Approval_Date
				
					
					FETCH NEXT FROM curTable INTO @FROM_TABLE_NAME, @TABLE_NAME, @COLUMN_NAME,@ForDate_ColName
				END
			CLOSE curTable
			DEALLOCATE curTable
	 
			DECLARE @Pay_Scale_ID As INTEGER 	
			DECLARE @Tran_ID As INTEGER
			DECLARE @CMP_ID As INTEGER
			DECLARE @Pay_Scale_Effective_Date As DATETIME
			
			Set @Pay_Scale_ID =0		
			Set @Pay_Scale_Effective_Date =@Approval_Date
			
			
			Select @CMP_ID= Cmp_ID	FROM T0060_EMP_MASTER_APP WITH (NOLOCK) WHERE Emp_Tran_ID=@Ref_Emp_Tran_ID
			
			SELECT @Pay_Scale_ID=Pay_Scale_ID,@Pay_Scale_Effective_Date=Pay_Scale_Effective_Date 
			FROM T0070_EMP_INCREMENT_APP WITH (NOLOCK)
			WHERE Emp_Tran_ID =@Emp_Tran_ID
				
				
			IF 	@Pay_Scale_Effective_Date = NULL
			BEGIN
				Set @Pay_Scale_Effective_Date=@Approval_Date
			END
			
			Set @Tran_ID=(SELECT Max(IsNull(Tran_ID,0)) FROM T0050_EMP_PAY_SCALE_DETAIL WITH (NOLOCK)) + 1
			
			INSERT INTO T0050_EMP_PAY_SCALE_DETAIL (Cmp_ID,Tran_ID,Emp_ID,Effective_Date,Pay_Scale_ID,System_date)
									 VALUES        (@CMP_ID,@Tran_ID,@Emp_ID,@Pay_Scale_Effective_Date,@Pay_Scale_ID,getdate())
					
		END
			
END


