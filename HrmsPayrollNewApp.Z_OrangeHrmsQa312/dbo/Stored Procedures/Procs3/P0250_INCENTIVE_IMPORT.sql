


---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0250_INCENTIVE_IMPORT]
	  
	  @Data AS VARCHAR(MAX)
	 ,@Emp_Code varchar(100)
	 ,@Cmp_Id AS NUMERIC(18,0)
	 ,@Year AS NUMERIC(18,0)
	 ,@Month AS NUMERIC(18,0)
	 ,@Branch_Name as varchar(100)
	 ,@Desig_Name as varchar(100)
	 --,@Type as varchar(2)
	 ,@Log_Status int  = 0 OUTPUT
	 ,@Row_No as Int 
	 ,@Login_ID as numeric(18,0)
	 ,@Tran_Type as char(1)
	 ,@GUID Varchar(256) = ''
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
		
	
	DECLARE @EMP_ID  AS NUMERIC(18,0),@BRANCH_ID AS NUMERIC(18,0),@DESIG_ID AS NUMERIC(18,0)
	SET @EMP_ID = 0
	SET @YEAR=ISNULL(@YEAR,0)
	SET @MONTH=ISNULL(@MONTH,0)
	DECLARE @FOR_DATE AS DATETIME
	DECLARE @TYPE AS VARCHAR(2)
	
	DECLARE @HASRESULT VARCHAR(MAX) 
	DECLARE @W_ERROR VARCHAR(MAX) 
	
	
	IF @Emp_Code = ''
	BEGIN
		INSERT INTO DBO.T0080_IMPORT_LOG VALUES (@ROW_NO,@CMP_ID,@EMP_CODE,'Emp_Code is not specified',@EMP_CODE,'Please specify the Emp_code of the employee',GETDATE(),'INCENTIVE IMPORT',@GUID)						
		--SET @HasResult = cast(@Emp_Code as varchar(100)) + ','	
		SET @LOG_STATUS=1			
		RETURN
	END
	
	IF @Branch_Name = ''
	BEGIN
		INSERT INTO DBO.T0080_IMPORT_LOG VALUES (@ROW_NO,@CMP_ID,@EMP_CODE,'Branch_Name is not specified',@EMP_CODE,'Please specify the Branch_Name of the employee',GETDATE(),'INCENTIVE IMPORT',@GUID)						
		SET @LOG_STATUS=1	
		--SET @HasResult = cast(@Emp_Code as varchar(100)) + ','		
		RETURN
	END
	
	IF @Desig_Name = ''
	BEGIN
		INSERT INTO DBO.T0080_IMPORT_LOG VALUES (@ROW_NO,@CMP_ID,@EMP_CODE,'Designation_Name is not specified',@EMP_CODE,'Please specify the Designation_Name of the employee',GETDATE(),'INCENTIVE IMPORT',@GUID)						
		SET @LOG_STATUS=1
		--SET @HasResult = cast(@Emp_Code as varchar(100)) + ','					
		RETURN
	END
	
	IF @Year = 0
	BEGIN
	
		INSERT INTO DBO.T0080_IMPORT_LOG VALUES (@ROW_NO,@CMP_ID,@EMP_CODE,'Year is not specified',@EMP_CODE,'Please specify the Year of the employee',GETDATE(),'INCENTIVE IMPORT',@GUID)						
		SET @LOG_STATUS=1		
		--SET @HasResult = cast(@Emp_Code as varchar(100)) + ','					
		RETURN
	END
	
	IF @Month = 0
	BEGIN
		INSERT INTO DBO.T0080_IMPORT_LOG VALUES (@ROW_NO,@CMP_ID,@EMP_CODE,'Month is not specified',@EMP_CODE,'Please specify the Month of the employee',GETDATE(),'INCENTIVE IMPORT',@GUID)						
		SET @LOG_STATUS=1			
		--SET @HasResult = cast(@Emp_Code as varchar(100)) + ','					
		RETURN
	END
	

	
	SELECT @EMP_ID=EMP_ID FROM  DBO.T0080_EMP_MASTER WITH (NOLOCK)
			WHERE CMP_ID = @CMP_ID AND ALPHA_EMP_CODE = @EMP_CODE
		
	SELECT @BRANCH_ID=BRANCH_ID FROM DBO.T0030_BRANCH_MASTER WITH (NOLOCK)
			WHERE  CMP_ID = @CMP_ID AND BRANCH_NAME = @BRANCH_NAME
			SET @BRANCH_ID=ISNULL(@BRANCH_ID,0)
			
	SELECT @DESIG_ID=DESIG_ID FROM DBO.T0040_DESIGNATION_MASTER WITH (NOLOCK)
			WHERE  CMP_ID = @CMP_ID AND DESIG_NAME = @DESIG_NAME
			SET @DESIG_ID=ISNULL(@DESIG_ID,0)	
			
		
	IF (@Year<>0 AND @Month<>0)
		BEGIN
			SELECT @FOR_DATE=CAST(CAST(@Year AS VARCHAR(5)) +'-' + CAST(@Month AS VARCHAR(5)) + '-' +  '01' AS DATETIME)
			
		END 		
		
		
	IF NOT EXISTS (SELECT 1 FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Emp_ID = @Emp_ID AND CMP_ID = @CMP_ID)
		BEGIN	
				INSERT INTO DBO.T0080_IMPORT_LOG VALUES (@ROW_NO,@CMP_ID,@Emp_Code,'Employee Not Exists',@EMP_CODE,'ENTER PROPER EMPLOYEE',GETDATE(),'INCENTIVE IMPORT',@GUID)						
				SET @LOG_STATUS=1
				--SET @HasResult = cast(@Emp_Code as varchar(100)) + ','			
				RETURN	
		END
	
	
	--declare @data xml
	--set @data = '<person>
	--				<Emp_Code>Jon</Emp_Code>
	--				<EmpName>Johnson</EmpName>
	--				<Branch>Johnson</Branch>
	--		</person>'

	--select 
	--	Record.value('(person/firstName)[1]', 'nvarchar(max)') as FirstName,
	--	Record.value('(person/lastName)[1]', 'nvarchar(max)') as FirstName
	--from #XMLTable T
	
	create table #XMLTable (Record XML)
	insert into #XMLTable values (cast(@data as XML))
	
		
	DECLARE @r TABLE (Record XML)
	INSERT INTO @r 
	SELECT * from #XMLTable
	

	create table #XML(CMP_ID NUMERIC(18,0),ID int identity,Emp_ID numeric(18,0),Branch_ID numeric(18,0),Desig_ID numeric(18,0),FOR_DATE DATETIME,LOGIN_ID NUMERIC(18,0),EMP_CODE NVARCHAR(100),ROW_NO INT,GUID VARCHAR(128), colName varchar(128), colValue varchar(128)) --ADDED ON EMP_CODE NUMERIC(18,0) 05022018
		
	INSERT INTO #XML
	SELECT  @CMP_ID,@EMP_ID,@BRANCH_ID,@DESIG_ID,@FOR_DATE,@LOGIN_ID,@EMP_CODE,@ROW_NO,@GUID,Cast(c.query('data(colName)') as Varchar(128)) as colName, Cast(c.query('data(colValue)') as Varchar(128)) as colValue	
	FROM @r r CROSS APPLY Record.nodes('root/column') x(c)
	
	
	DECLARE @ID AS NUMERIC(18,0),@PARA_NAME AS VARCHAR(128),@PARA_VALUE AS VARCHAR(128),@PARA_ID AS NUMERIC(18,0)	

		DECLARE curincentive CURSOR fast_forward FOR 
				SELECT DISTINCT id, Ltrim(Rtrim(colname)),colvalue 
				FROM   #xml IE 
				WHERE  id > 6 AND Isnumeric(colvalue) = 1 
				ORDER  BY id 

				OPEN curincentive 
				FETCH next FROM curincentive INTO @ID, @PARA_NAME, @PARA_VALUE 
				WHILE @@FETCH_STATUS = 0 
				  BEGIN 
				  	  SET @Type = LEFT(@PARA_NAME, 2); 
					  SET @PARA_NAME = RIGHT(@PARA_NAME, Len(@PARA_NAME) - 3); 

						
					  IF NOT EXISTS(SELECT 1 
									FROM   dbo.t0190_emp_incentive_import WITH (NOLOCK)
									WHERE  emp_id = @EMP_ID 
										   AND cmp_id = @CMP_ID 
										   AND branch_id = @BRANCH_ID 
										   AND desig_id = @DESIG_ID 
										   AND para_name = @PARA_NAME
										   and For_Date=@FOR_DATE) 
						BEGIN 							
							IF ( @Type = 'PM' ) 
							  SELECT @PARA_ID = para_id 
							  FROM   t0040_parameter_master WITH (NOLOCK)
							  WHERE  cmp_id = @CMP_ID 
									 AND para_name = @PARA_NAME 
							ELSE IF( @Type = 'IM' ) 
							  SELECT @PARA_ID = inc_tran_id 
							  FROM   t0040_incentive_master WITH (NOLOCK)
							  WHERE  cmp_id = @CMP_ID 
									 AND incentive_name = @PARA_NAME 
							ELSE 
							  SELECT @PARA_ID = inc_tran_id 
							  FROM   t0040_incentive_master WITH (NOLOCK)
							  WHERE  cmp_id = @CMP_ID 
									 AND calc_on = @PARA_NAME 
							
							INSERT INTO DBO.T0190_EMP_INCENTIVE_IMPORT 
										(EMP_ID, 
										 CMP_ID, 
										 BRANCH_ID, 
										 DESIG_ID, 
										 PARA_NAME, 
										 PARA_VALUE, 
										 PARA_TYPE, 
										 PARA_ID, 
										 FOR_DATE, 
										 LOGIN_ID, 
										 SYSTEM_DATE,
										 FORMULA) 
							VALUES      ( @EMP_ID, 
										  @CMP_ID, 
										  @BRANCH_ID, 
										  @DESIG_ID, 
										  @PARA_NAME, 
										  CAST(@PARA_VALUE AS NUMERIC(18, 2)), 
										  @TYPE, 
										  @PARA_ID, 
										  @FOR_DATE, 
										  @LOGIN_ID, 
										  GETDATE(),
										  '') 
						END 
					  ELSE 
						BEGIN 
							
							
					  IF EXISTS(SELECT 1 
									FROM   DBO.T0190_EMP_INCENTIVE_IMPORT WITH (NOLOCK)
									WHERE  EMP_ID = @EMP_ID 
										   AND CMP_ID = @CMP_ID 
										   AND BRANCH_ID = @BRANCH_ID 
										   AND DESIG_ID = @DESIG_ID 
										   AND PARA_NAME = @PARA_NAME
										   AND FOR_DATE=@FOR_DATE) 
											  BEGIN
												
											IF EXISTS(SELECT 1 FROM DBO.T0220_INCENTIVE_PROCESS WITH (NOLOCK)
												WHERE			EMP_ID = @EMP_ID 
																AND CMP_ID = @CMP_ID 
																AND BRANCH_ID = @BRANCH_ID 
																AND DESIG_ID = @DESIG_ID 
																--AND PARA_NAME = @PARA_NAME
																AND FOR_DATE=@FOR_DATE)
													BEGIN
														
														SET @w_error = 'Incentive Process Exists ' + ' Emp_Code='+@EMP_CODE
														INSERT INTO dbo.t0080_import_log 
														VALUES	(@ROW_NO,@CMP_ID,@EMP_CODE,@w_error,@EMP_CODE, 
																@w_error,Getdate(),'INCENTIVE IMPORT',@GUID) 
																
														RAISERROR(@w_error,16,2) 
														SET @LOG_STATUS=-1 
															--SET @HasResult = cast(@Emp_Code as varchar(100)) + ','		
															--RAISERROR('INCENTIVE PROCESS REFERENCE EXIST.',16,2) 
															--RETURN
															--Goto ABC;
													END
												ELSE
													BEGIN
												
														DELETE FROM DBO.T0190_EMP_INCENTIVE_IMPORT
																WHERE	EMP_ID = @EMP_ID 
																		AND CMP_ID = @CMP_ID 
																		AND BRANCH_ID = @BRANCH_ID 
																		AND DESIG_ID = @DESIG_ID 
																		AND PARA_NAME = @PARA_NAME
																		AND FOR_DATE=@FOR_DATE
														---- REINSERT IMPORT RECORDS ---
														IF ( @Type = 'PM' ) 
															  SELECT @PARA_ID = para_id 
															  FROM   t0040_parameter_master WITH (NOLOCK)
															  WHERE  cmp_id = @CMP_ID 
																	 AND para_name = @PARA_NAME 
														ELSE IF( @Type = 'IM' ) 
															  SELECT @PARA_ID = inc_tran_id 
															  FROM   t0040_incentive_master WITH (NOLOCK)
															  WHERE  cmp_id = @CMP_ID 
																	 AND incentive_name = @PARA_NAME 
														ELSE 
															  SELECT @PARA_ID = inc_tran_id 
															  FROM   t0040_incentive_master WITH (NOLOCK)
															  WHERE  cmp_id = @CMP_ID 
																	 AND calc_on = @PARA_NAME 
														INSERT INTO DBO.T0190_EMP_INCENTIVE_IMPORT 
																		(EMP_ID, 
																		 CMP_ID, 
																		 BRANCH_ID, 
																		 DESIG_ID, 
																		 PARA_NAME, 
																		 PARA_VALUE, 
																		 PARA_TYPE, 
																		 PARA_ID, 
																		 FOR_DATE, 
																		 LOGIN_ID, 
																		 SYSTEM_DATE,
																		 FORMULA) 
															VALUES      ( @EMP_ID, 
																		  @CMP_ID, 
																		  @BRANCH_ID, 
																		  @DESIG_ID, 
																		  @PARA_NAME, 
																		  CAST(@PARA_VALUE AS NUMERIC(18, 2)), 
																		  @TYPE, 
																		  @PARA_ID, 
																		  @FOR_DATE, 
																		  @LOGIN_ID, 
																		  GETDATE(),
																		  '') 
														---- END ---
												
													END
											  END
										  ELSE 
											  BEGIN
												
												SET @w_error = 'Invalid Records' + ' Emp_Code='+@EMP_CODE
												INSERT INTO dbo.t0080_import_log 
												VALUES      (@ROW_NO,@CMP_ID,@Emp_Code,@w_error,@EMP_CODE,@w_error,Getdate(), 
															 'INCENTIVE IMPORT',@GUID) 
												--SET @HasResult = cast(@Emp_Code as varchar(100)) + ','	
												--SET @LOG_STATUS=1 
												--RAISERROR('ENTER TOTAL MANDATORY INFORMATION',16,2) 
												--RETURN
												--Goto ABC; 
											  END
							
						END 

					  ---END 
					 -- ABC:
						--IF IsNull(@HasResult,'') <> ''
						--	SET @Log_Status = @Log_Status + @HasResult
						
					  FETCH next FROM curincentive INTO @ID, @PARA_NAME, @PARA_VALUE 
				  END 

				CLOSE curincentive 
				DEALLOCATE curincentive 
				--A:
				--select @HasResult
				--if @HasResult = '' 
				--	begin
				--		Set @Log_Status = '0'
				--		return 
				--	End	
				--Else
				--	begin
				--		Set @Log_Status = '1'
				--		--Set @Log_Status_Details = @Status_Details
				--		return  
				--	End

			
		EXEC DBO.P0050_INCENTIVE_CALCULATE_PARAMETER_VALUES 
		
END

