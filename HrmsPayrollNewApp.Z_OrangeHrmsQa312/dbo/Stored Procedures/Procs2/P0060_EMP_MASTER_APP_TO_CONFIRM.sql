CREATE PROCEDURE [dbo].[P0060_EMP_MASTER_APP_TO_CONFIRM]
	/*DECLARE */
	@Emp_Tran_ID BIGINT,
	@Emp_Id INT OUTPUT,
	@Approval_Date	DateTime /*= '2019-04-15' */
	
AS
BEGIN	
	SET NOCOUNT ON;

	Declare @Ref_Emp_Tran_ID BIGINT=0  
	DECLARE @Date_Of_Join as DATETIME
	DECLARE @Pay_Scale_ID As INTEGER 	
	DECLARE @Tran_ID As INTEGER
			
	DECLARE @CMP_ID As INTEGER
	DECLARE @Pay_Scale_Effective_Date As DATETIME
			
	Declare @Alpha_Emp_Code varchar(50)
	Declare @Login_Alias varchar(100) = ''
	Declare @loginname as varchar(50)
	Declare @Domain_Name as varchar(50)
	DECLARE @Emp_Code NUMERIC
	DECLARE @Default_Pwd VARCHAR(MAX)
	DECLARE @W_Tran_ID INT

	
	SET @Ref_Emp_Tran_ID =0  

	Select @CMP_ID= Cmp_ID,@Alpha_Emp_Code=Alpha_Emp_Code,@Date_Of_Join=Date_Of_Join
	FROM   T0060_EMP_MASTER_APP 
	WHERE  Emp_Tran_ID=@Emp_Tran_ID

	
	SELECT @Approval_Date = CONVERT(datetime, convert(varchar(10), @Approval_Date,103),103)
	Set @Approval_Date = @Date_Of_Join
	
	IF EXISTS(SELECT 1 FROM  T0060_EMP_MASTER_APP WHERE Emp_Tran_ID = @Emp_Tran_ID)
		Begin
			
			--This  Reference Emp Tran ID will be used to take data from all child application tables
			SET @Ref_Emp_Tran_ID=@Emp_Tran_ID
			
			--Taking data into temp table which supposed to be inserted in T0080_EMP_MASTER
			SELECT * INTO #T0060_EMP_MASTER_APP_INSERTED FROM T0060_EMP_MASTER_APP WHERE Emp_Tran_ID=@Ref_Emp_Tran_ID
			
			--Taking Next Employee ID 
			Set @Emp_ID=(SELECT IsNull(Max(Emp_ID),0) FROM T0080_EMP_MASTER) + 1
			
			UPDATE #T0060_EMP_MASTER_APP_INSERTED SET Emp_ID=@Emp_ID
			
			
			ALTER TABLE #T0060_EMP_MASTER_APP_INSERTED DROP COLUMN Login_ID
			ALTER TABLE #T0060_EMP_MASTER_APP_INSERTED DROP COLUMN Increment_Id  -- Added by Hardik 09/07/2020, To Update Null Increment_id, as it will give Foreign key error

			DECLARE @COLS VARCHAR(MAX)
			
			SELECT	@COLS = COALESCE(@COLS + ',','') + QUOTENAME(p.name)
			FROM	(SELECT  name FROM tempdb.sys.columns WHERE object_id = object_id('tempdb..#T0060_EMP_MASTER_APP_INSERTED')) T
					INNER JOIN (SELECT  name FROM sys.columns WHERE object_id = object_id('T0080_EMP_MASTER')) P ON T.name=P.name
			
			DECLARE @SQL NVARCHAR(MAX)
			SET @SQL  = 'INSERT INTO T0080_EMP_MASTER(' + @COLS + ') 
						 SELECT ' + @COLS + ' from #T0060_EMP_MASTER_APP_INSERTED'
			
			EXEC (@SQL)
	
			-- Added by Hardik 09/07/2020
			Update E Set Increment_ID = EM.Increment_ID 
			From T0080_EMP_MASTER E INNER JOIN T0060_EMP_MASTER_APP EM ON E.Emp_ID = EM.Emp_ID
			Where Emp_Tran_ID = @Emp_Tran_ID 
			
		
			CREATE TABLE #CopyTables
			(
				ID INT,
				From_Table	VARCHAR(256),
				Table_Name VARCHAR(256),
				Column_Name		VARCHAR(256),
				ForDateColumn	Varchar(128),
				Ref_Table		Varchar(256),
				Ref_Column		Varchar(256),
				New_ID_Value		BIGINT				
			)
			
			INSERT INTO #CopyTables (ID, From_Table, Table_Name, Column_Name, ForDateColumn)
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
			--SELECT 17,  'T0070_EMP_SCHEME_APP',  'T0095_EMP_SCHEME', 'Tran_ID','Effective_Date' UNION ALL			
			SELECT 18,  'T0075_EMP_EARN_DEDUCTION_APP', 'T0100_EMP_EARN_DEDUCTION', 'AD_TRAN_ID','FOR_DATE'
			
			UPDATE	#CopyTables
			SET		Ref_Table = 'T0095_INCREMENT',
					Ref_Column = 'Increment_ID'
			WHERE	ID=18
			
			
			DECLARE @FROM_TABLE_NAME VARCHAR(128)
			DECLARE @TABLE_NAME VARCHAR(128)
			DECLARE @COLUMN_NAME VARCHAR(128)
			DECLARE @ForDate_ColName VARCHAR(128)
			DECLARE @Ref_Table VARCHAR(256)
			DECLARE @Ref_Column VARCHAR(256)
			
			
			DECLARE curTable CURSOR FAST_FORWARD FOR 
			SELECT	From_Table, Table_Name, Column_Name,ForDateColumn,IsNull(Ref_Table,''), IsNull(Ref_Column,'') 
			FROM	#CopyTables order by ID
			OPEN curTable
			
			FETCH NEXT FROM curTable INTO @FROM_TABLE_NAME, @TABLE_NAME, @COLUMN_NAME,@ForDate_ColName, @Ref_Table, @Ref_Column
			
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
							ALTER TABLE #' + @FROM_TABLE_NAME + ' ADD ' + @ForDate_ColName + ' DateTime ' 
							
						
						IF @Ref_Column  <> ''
							BEGIN
								SET @SQL = @SQL + '
											UPDATE	T 
											SET		' + @Ref_Column + '= CT.New_ID_Value
											FROM	#' + @FROM_TABLE_NAME + ' T
													INNER JOIN #CopyTables CT ON CT.Table_Name=''' + @Ref_Table + ''''
							END
					
						
						SET @SQL = @SQL + '
						UPDATE	T
						SET		Emp_ID=@Emp_ID, 
								' + @COLUMN_NAME + ' = T1.TROW_ID + @MaxID, 
								' + @ForDate_ColName + '= @Approval_Date
						FROM	#' + @FROM_TABLE_NAME + ' T
								INNER JOIN (SELECT ROW_NUMBER() OVER(ORDER BY T.' + @COLUMN_NAME + ') AS TROW_ID,Emp_Tran_ID,T.' + @COLUMN_NAME + '
											FROM	#' + @FROM_TABLE_NAME + ' T) T1 ON T.Emp_Tran_ID=T1.Emp_Tran_ID and T.' + @COLUMN_NAME + '=T1.' + @COLUMN_NAME + '
						
						UPDATE	CT
						SET		New_ID_Value = T.' + @COLUMN_NAME + '
						FROM	#CopyTables  CT,#' + @FROM_TABLE_NAME + ' T 
						WHERE	CT.Table_Name=''' + @TABLE_NAME + '''
												
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
					--PRINT  @FROM_TABLE_NAME
					--PRINT @SQL 
					
					exec sp_executesql @SQL, N'@Emp_Tran_ID BIGINT, @Emp_ID INT, @Approval_Date DateTime', @Emp_Tran_ID, @Emp_ID, @Approval_Date
				
					
					FETCH NEXT FROM curTable INTO @FROM_TABLE_NAME, @TABLE_NAME, @COLUMN_NAME,@ForDate_ColName, @Ref_Table, @Ref_Column
				END
			CLOSE curTable
			DEALLOCATE curTable
	 
	 
			Select @W_Tran_ID=Max(ISNULL(W_Tran_ID,0)) 
			FROM   T0100_WEEKOFF_ADJ
			
			Set @Pay_Scale_ID =0		
			--Set @Pay_Scale_Effective_Date =@Approval_Date
			--SET	@Pay_Scale_Effective_Date=@Date_Of_Join
			
			SELECT @Pay_Scale_ID=Pay_Scale_ID
			FROM T0070_EMP_INCREMENT_APP 
			WHERE Emp_Tran_ID =@Emp_Tran_ID
			/*Added binal 30092020*/
			Declare @Default_Holiday  varchar(100)
			Declare @Default_Holiday_Value varchar(150)
			Declare @Alt_W_Name  varchar(100)
			Declare @Alt_W_Full_Day_Cont  varchar(100)

			Select @Default_Holiday=Default_Holiday ,@Alt_W_Name=Alt_W_Name,@Alt_W_Full_Day_Cont=Alt_W_Full_Day_Cont from T0010_COMPANY_MASTER where cmp_ID =@CMP_ID
			
			if @Default_Holiday like '%#%'
			begin
				SET @Default_Holiday_Value = REPLACE(@Default_Holiday, '#', ' 1.0#') +' 1.0'
				--print @Default_Holiday
			end
			else
			begin
				SET @Default_Holiday_Value=@Default_Holiday +'1.0'
			end
			/*Added binal 30092020*/
			/*Updated below binal 30092020*/
			

			
			--select @W_Tran_ID RETURN
			--SELECT @W_Tran_ID=MAX(ISNULL(W_Tran_ID,0))+ 1  FROM T0100_WEEKOFF_ADJ
			--IF Exists(Select 1 From T0100_WEEKOFF_ADJ Where Emp_ID=@Emp_ID and Cmp_ID=@CMP_ID)
			--Begin
			--	UPDATE T0100_WEEKOFF_ADJ
			--	   SET For_Date = @Date_Of_Join
			--		  ,Weekoff_Day = @Default_Holiday
			--		  ,Weekoff_Day_Value = @Default_Holiday_Value
			--		  ,Alt_W_Name =@Alt_W_Name
			--		  ,Alt_W_Full_Day_Cont = Alt_W_Full_Day_Cont
			--		  ,Alt_W_Half_Day_Cont = ''
			--		  ,Is_P_Comp = 0
			--	 WHERE Emp_ID=@Emp_ID and Cmp_ID=@CMP_ID
			
			--END
			--ELSE			
			--BEGIN
			--	INSERT INTO T0100_WEEKOFF_ADJ (W_Tran_ID,Emp_ID,Cmp_ID,For_Date,Weekoff_Day,Weekoff_Day_Value,Alt_W_Name,Alt_W_Full_Day_Cont,Alt_W_Half_Day_Cont,Is_P_Comp)
			--		VALUES	(@W_Tran_ID,@Emp_ID,@CMP_ID,@Date_Of_Join,@Default_Holiday,@Default_Holiday_Value,@Alt_W_Name,@Alt_W_Full_Day_Cont,'',0)
			--END
			
			--Set @Pay_Scale_Effective_Date=getdate()
			
			SET	@Pay_Scale_Effective_Date=@Date_Of_Join
			
			
			Set @Tran_ID=(SELECT IsNull(Max(Tran_ID),0) FROM T0050_EMP_PAY_SCALE_DETAIL) + 1
			
			INSERT INTO T0050_EMP_PAY_SCALE_DETAIL (Cmp_ID,Tran_ID,Emp_ID,Effective_Date,Pay_Scale_ID,System_date)
			VALUES (@CMP_ID,@Tran_ID,@Emp_ID,@Pay_Scale_Effective_Date,@Pay_Scale_ID,GETDATE())
					
			UPDATE	T0100_EMP_EARN_DEDUCTION
			SET FOR_DATE=@Pay_Scale_Effective_Date
			WHERE EMP_ID=@Emp_ID
				
					
					--SELECT * from T0050_EMP_PAY_SCALE_DETAIL where Emp_ID=@Emp_ID
		
			UPDATE	T0060_EMP_MASTER_APP
			SET Approve_Status='A',Emp_ID=@Emp_ID					
			WHERE Emp_Tran_ID = @Emp_Tran_ID

			DECLARE @lEMP_TRAN_ID INT,@FromDate datetime,@ToDate datetime
			--SELECT @lEMP_TRAN_ID = Emp_Tran_ID FROM T0060_EMP_MASTER_APP WHERE Alpha_Emp_Code = @Alpha_Emp_Code AND Approve_Status = 'S'

			SET @FromDate = DAY(GETDATE()) + 1
			SET @ToDate = DATEADD(MONTH,datediff(MONTH,-1, GETDATE()),-1)
			--SET @ToDate = EOMONTH(getdate())



				--Change by ronakk 07092022
			UPDATE T0095_EMP_SCHEME SET emp_id = @Emp_Id,IsMakerChecker = 0 WHERE emp_id = @Emp_Tran_ID and IsMakerChecker=1
			UPDATE T0100_LEAVE_CF_DETAIL SET emp_id = @Emp_Id,CF_IsMakerChecker = 0 WHERE emp_id = @Emp_Tran_ID and CF_IsMakerChecker=1
			UPDATE T0100_LEAVE_CF_Advance_Leave_Balance SET emp_id = @Emp_Id,CF_IsMakerChecker = 0 WHERE emp_id = @Emp_Tran_ID and CF_IsMakerChecker=1
			UPDATE T0100_WEEKOFF_ADJ SET Emp_ID = @Emp_Id,IsMakerChecker = 0 WHERE Emp_ID = @Emp_Tran_ID and IsMakerChecker=1 
			UPDATE T0140_Leave_Transaction SET Emp_ID = @Emp_Id,IsMakerChaker=0 WHERE Emp_ID = @Emp_Tran_ID AND IsMakerChaker=1



			--UPDATE T0095_EMP_SCHEME SET emp_id = @Emp_Id,IsMakerChecker = 0 WHERE emp_id = @lEMP_TRAN_ID
			--UPDATE T0100_LEAVE_CF_DETAIL SET emp_id = @Emp_Id,CF_IsMakerChecker = 0 WHERE emp_id = @lEMP_TRAN_ID
			--UPDATE T0100_LEAVE_CF_Advance_Leave_Balance SET emp_id = @Emp_Id,CF_IsMakerChecker = 0 WHERE emp_id = @lEMP_TRAN_ID
			--UPDATE T0100_WEEKOFF_ADJ SET Emp_ID = @Emp_Id,IsMakerChecker = 0 WHERE Emp_ID = @lEMP_TRAN_ID
			--UPDATE T0140_Leave_Transaction SET Emp_ID = @Emp_Id WHERE Emp_ID = @lEMP_TRAN_ID AND For_Date >= @FromDate and For_Date < @ToDate
			--UPDATE T0140_Leave_Transaction SET Emp_ID = @Emp_Id WHERE Emp_ID = @Emp_Tran_ID AND For_Date >= @FromDate and For_Date <= @ToDate
	
			Select	@Domain_Name = Domain_Name
			From	dbo.T0010_COMPANY_MASTER 
			WHERE CMP_ID = @CMP_ID
	
				If @Alpha_Emp_Code is NOT NULL
					Begin 	
							  
						Set @loginname = cast(@Alpha_Emp_Code as varchar(50)) + @Domain_Name
						set @Login_Alias = isnull(@Login_Alias,@loginname)
					End
				Else
					Begin
					
					--exec Get_Employee_Code @cmp_ID,@Branch_ID,@Date_Of_Join,@Get_Emp_Code output,@Get_Alpha_Code output,1,@Desig_Id,@Cat_ID,@Type_ID,@Date_OF_Birth
				--set @Emp_code = cast(@Get_Emp_code as numeric)
					
						Set @loginname = cast(@Emp_Code as varchar(10)) + @Domain_Name	
						set @Login_Alias = isnull(@Login_Alias,@loginname)
					End	
				
					Set @Default_Pwd ='VuMs/PGYS74='
					--EXEC p0011_Login 0,@Cmp_Id,@loginname,'VuMs/PGYS74=',@Emp_ID,NULL,NULL,'I',2
					EXEC p0011_Login @Login_ID=0,@Cmp_ID=@CMP_ID,@Login_Name=@loginname,@Login_Password=@Default_Pwd,@Emp_ID=@Emp_ID,@Branch_ID=NULL,@Login_Rights_ID=NULL,@trans_type='I',@Is_Default=2, @ChangedBy=0, @ChangedFromIP=''
					EXEC P0110_EMP_LEFT_JOIN_TRAN @Emp_ID,@CMP_ID,@Date_Of_Join,'','',0
		
			--added binal 08102020 moved to page level
			--Declare @Privilege_ID numeric(18,0)
			--Declare @Effect_Date datetime
			--Declare @Login_ID numeric(18,0)
			--Declare @User_Id numeric(18,0)
			--Declare @Increment_ID numeric(18,0)

			--select @Increment_ID=Increment_ID from T0095_INCREMENT With (NoLOCK) where Emp_id = @Emp_ID and Increment_Type='Joining'

			--select @Login_ID=login_id from t0011_login With (NoLOCK) where Emp_id = @Emp_ID 

   --         select	@Privilege_ID=Privilege_Id,@Effect_Date=From_Date from T0090_EMP_PRIVILEGE_DETAILS_APP With (NoLOCK)  where Emp_Tran_ID= @Emp_Tran_ID and Cmp_Id=@CMP_ID
			
			--EXEC P0090_EMP_PRIVILEGE_DETAILS @Trans_Id=0,@Privilege_ID=@Privilege_ID,@Cmp_ID=@CMP_ID,@Login_ID=@Login_Id,@Effect_Date=@Effect_Date,@User_Id=@User_Id,@IP_Address=''

			--Update T0080_EMP_MASTER
			--Set Increment_ID=@Increment_ID
			--Where Emp_ID=@Emp_ID

		   --end added binal 08102020
					
		END
			
END