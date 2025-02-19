CREATE Procedure [dbo].[SP_Import_Allowance_Data_New]
	@Cmp_ID						Varchar(20), 
	@FileName					Varchar(100), 
	@GUID						Varchar(2000),
	@Log_Status					numeric output ,
	@Increment_Id				numeric output
AS
			
BEGIN TRY
	SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON 
	SET @Increment_Id = 0 -- Set Output Parameter
	SET @Log_Status = 0 -- Set Output Parameter
	
	IF OBJECT_ID('tempdb..#tmpCols') IS NOT NULL 
			DROP TABLE #tmpFixedCol
	CREATE TABLE #tmpFixedCol
	(
		Row_No				int,
		Cmp_Id				VARCHAR(20),
		Emp_Id				VARCHAR(20),
		Emp_Code			VARCHAR(20), 
		Emp_Name			VARCHAR(100), 
		Branch_Name			VARCHAR(50),
		Joining_Date		DATETIME, 
		Increment_Type		VARCHAR(50),
		Entry_Type			VARCHAR(30),
		Grade				VARCHAR(50),
		Designation			VARCHAR(50), 
		Department			VARCHAR(50), 
		Basic_Salary		NUMERIC(18,2),
		Gross_Salary		NUMERIC(18,2),
		CTC					NUMERIC(18,2), 
		Reason_Name			VARCHAR(50),
		[GUID]				VARCHAR(50)
	)
	
	IF OBJECT_ID('tempdb..#tmpCols') IS NOT NULL 
			DROP TABLE #tmpCols
	CREATE table #tmpCols
	(
		Emp_ID varchar(20),
		Allowance Varchar(100),
		Amount numeric(18,2)
	)
	
	DECLARE @sqlFixedCol VARCHAR(2000)
	SET @sqlFixedCol = 'INSERT INTO #tmpFixedCol
						SELECT  ROW_NUMBER() OVER (ORDER BY Cmp_ID) AS Row_No ,''' + @Cmp_ID + ''' as Cmp_Id , e.Emp_Id, f.Emp_Code 
						,f.Emp_Name ,f.Branch_Name ,f.Joining_Date ,f.Increment_Type ,f.Entry_Type ,f.Grade ,f.Designation 
						,f.Department ,f.Basic_Salary ,f.Gross_Salary ,f.CTC ,f.Reason_Name , ''' + @GUID + ''' as [GUID] 
						FROM ' + @FileName + ' f inner join T0080_EMP_MASTER e on f.Emp_Code = e.Alpha_Emp_Code'
	
	EXEC(@sqlFixedCol)
	
	DECLARE @sql1  NVARCHAR(MAX) = N'', @colNames  NVARCHAR(MAX) = N''		
	SELECT @colNames += ',' + QUOTENAME(name) 
	FROM sys.columns
	WHERE [object_id] = OBJECT_ID(@FILENAME) 
		  AND column_id >= 14
	
	SET @sql1 = N'INSERT INTO #tmpCols
				SELECT Emp_id, Allowance, Amount 
				FROM(
					SELECT f.Emp_Id as Emp_Id, ' + STUFF(@colNames, 1, 1, '') + ' 
					FROM ' + @FILENAME + ' e INNER JOIN  #tmpFixedCol f ON e.Emp_Code = f.Emp_Code
				)d	
				UNPIVOT
				( Amount FOR Allowance IN (' + STUFF(@colNames, 1, 1, '') + ')
				)up'
	
	EXEC(@sql1)
	
	
	DECLARE @Emp_ID				VARCHAR(20) 
	DECLARE @Emp_code			VARCHAR(20) 
	DECLARE @Emp_Name			VARCHAR(100)
	DECLARE @Branch_Name		VARCHAR(50)
	DECLARE @Joining_Date		DATETIME
	DECLARE @Increment_Type		VARCHAR(50)
	DECLARE @Entry_Type			VARCHAR(50)
	DECLARE @Grade				VARCHAR(50)
	DECLARE @Designation		VARCHAR(50)
	DECLARE @Dept				VARCHAR(50)
	DECLARE @Basic_Salary		NUMERIC(18,2)
	DECLARE @Gross_Salary		NUMERIC(18,2)
	DECLARE @CTC				NUMERIC(18,2)
	DECLARE @Reason_name		VARCHAR(50)
	DECLARE @Row_No				NUMERIC
	DECLARE @Increment_Id1		NUMERIC 
	DECLARE @Log_Status_CurXML	NUMERIC 
	
	
	DECLARE @condValue1		INT
	DECLARE @rowCountColFix	INT = 1
	SELECT  @condValue1 = COUNT(1) FROM #tmpFixedCol  --where Row_No = @Row_No
	
	While @rowCountColFix <= @condValue1
	BEGIN 
							 SELECT @Row_No =Row_No, @Cmp_ID = Cmp_ID, @Emp_ID = Emp_Id, @Emp_code = Emp_Code ,@Emp_Name = Emp_Name 
							,@Branch_Name = Branch_Name ,@Joining_Date = Joining_Date ,@Increment_Type = Increment_Type
							,@Entry_Type = Entry_Type ,@Grade = Grade ,@Designation = Designation ,@Dept = Department, @Basic_Salary = Basic_Salary
							,@Gross_Salary = Gross_Salary, @Reason_name = Reason_Name ,@CTC = CTC ,@GUID = [GUID]
							 from #tmpFixedCol where Row_No = @rowCountColFix
							
							EXEC SP_IMPORT_ALLOWANCE_DATA 
								 @Cmp_ID ,@Emp_ID ,@Emp_Name ,@Branch_Name ,@Joining_Date ,@Increment_Type
								,@Entry_Type ,@Grade ,@Designation ,@Dept ,@Basic_Salary ,@Gross_Salary ,@Reason_Name
								,@Increment_Id1  output ,@Row_No ,@Log_Status_CurXML output ,@CTC ,@GUID
							
							IF @Increment_Id1 = 0 
							BEGIN
									SET @Increment_Id = 0
							END
							
							
							IF @Log_Status_CurXML  = 1
							BEGIN
									SET @Increment_Id = 0
									SET @Log_Status = 1
							END
							
							IF @Increment_Id1 <> 0 
							BEGIN
								--print 'Set @Increment_Id'
								SET @Increment_Id = @Increment_Id1
								
								--IF OBJECT_ID('tempdb..#tmpRowCntCols') IS NOT NULL 
								--	drop TABLE #tmpRowCntCols
								
								SELECT ROW_NUMBER() OVER (ORDER BY Emp_ID) AS Row_No1, Emp_ID, Allowance, Amount 
								INTO #tmpRowCntCols FROM #tmpCols WITH (NOLOCK) 
								WHERE Emp_ID = @Emp_ID
								
								
								DECLARE @condtmpCols1	INT
								DECLARE @rowCount		INT = 1
								SELECT @condtmpCols1 = COUNT(1) FROM #tmpRowCntCols where Emp_ID = @Emp_ID
								
								DECLARE @EMP_ID2		VARCHAR(20)
								DECLARE @ALLOWANCE		VARCHAR(100)
								DECLARE @AMOUNT			NUMERIC
								DECLARE @LOG_STATUS1	NUMERIC 
								
								WHILE @rowCount <= @condtmpCols1 
								BEGIN
										SELECT @EMP_ID2 = Emp_ID,@ALLOWANCE = Allowance , @AMOUNT = Amount 
										FROM #tmpRowCntCols with (NOLOCK) where Row_No1 = @rowCount
										
										EXEC SP_Import_Allow_Deduct_Data 
										@Cmp_ID ,@EMP_ID2 ,@Increment_Id ,@Joining_Date
										,@Allowance ,@Amount ,@Row_No ,@Log_Status1 output ,@GUID
										
										IF @Log_Status1 = 1 
										BEGIN
												PRINT 'Error @Log_Status1'
												set @Increment_Id = 0
												set @Log_Status = 1
										END
										
										SET @rowCount = @rowCount + 1;
								END -- End inner While
								EXEC Update_Gross_Amount @Cmp_ID ,@EMP_ID2 ,@Increment_Id  -- Update_Gross_Amount
							END -- End IF @Increment_Id <> 0 
							
							IF @Increment_Type = 'Increment'
							BEGIN
								EXEC Update_PT_Amount @Cmp_ID ,@Emp_ID ,@Increment_Id -- Update_PT_Amount
							END	
							
			SET @rowCountColFix = @rowCountColFix + 1;
	END --END WHILE LOOP 
	
	IF OBJECT_ID('tempdb..#tmpRowCntCols') IS NOT NULL 
				drop TABLE #tmpRowCntCols
	drop table #tmpCols
	drop table #tmpFixedCol
	
	
	DECLARE @fileDrop varchar(500)
	SET @fileDrop  = 'Drop table ' + @FILENAME +' '
	EXEC(@fileDrop)
	
	END TRY
BEGIN CATCH
	print 'Catch'
	Insert Into dbo.T0080_Import_Log Values (@rowCountColFix,@Cmp_Id,@Emp_Id,ERROR_MESSAGE()
	,CONVERT(varchar(11),@Joining_Date,103),'Please check Company Id ,String XML'
	,GetDate(),'SP_Import_Allowance_Data_New',@GUID)
	set @Log_Status = 1
END CATCH;
RETURN
	

	


