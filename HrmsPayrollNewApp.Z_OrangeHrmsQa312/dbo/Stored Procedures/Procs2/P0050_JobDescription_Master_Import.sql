---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0050_JobDescription_Master_Import]	 
      @Cmp_Id				varchar(200) --numeric(18,0)
      ,@Effective_Date		datetime    
      ,@Job_Title			varchar(200)
      ,@Branch				varchar(max)
      ,@Grade				varchar(max)
      ,@Designation			varchar(max)
      ,@Department			varchar(max)      
     -- ,@Exp_Type			int
      ,@Exp_Min				int
      ,@Exp_Max				int     
      ,@Qualification		varchar(max)
      ,@Documents			varchar(max)=''
      ,@Roles				varchar(max)
	  ,@User_Id				numeric(18,0)	
	  ,@IP_Address			varchar(100)
	  ,@Row_No				int
      ,@Log_Status			Int = 0 Output    
      ,@GUID				Varchar(2000) = ''
AS
BEGIN	
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	DECLARE @Job_Id AS INT
	DECLARE @JOB_CODE AS VARCHAR(150)
	DECLARE @JB_CODE AS VARCHAR(150)
	DECLARE @BRANCH_ID AS VARCHAR(500)
	DECLARE @DEPT_ID AS VARCHAR(500)
	DECLARE @GRADE_ID AS VARCHAR(500)
	DECLARE @DESIG_ID AS VARCHAR(500)
	DECLARE @QUAL_ID AS VARCHAR(500)
	DECLARE @Doc_ID as VARCHAR(MAX)
	SET @JB_CODE=0
	SET @BRANCH_ID=''
	SET @DEPT_ID=''
	SET @GRADE_ID=''
	SET @DESIG_ID=''
	SET @QUAL_ID=''
	SET @Doc_ID=''
	
	IF @Qualification='0'
		SET @Qualification=''
	IF @Branch='0'
		SET @Branch=''
	IF @Grade='0'
		SET @Grade=''
	IF @Designation='0'
		SET @Designation=''
	IF @Department='0'
		SET @Department=''
	IF @Documents='0'
		SET @Documents=''
	IF @Roles='0'
		SET @Roles=''	
	
	IF @Job_Title = ''
		BEGIN
			Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,0,'Job Title is required',0,'Enter Job Title',GetDate(),'Job Description Import',@GUID)						
			Set @Log_Status=1
			Return
		END
		
	IF @Roles = ''
		BEGIN
			Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,0,'Roles and Responsibility is required',0,'Enter Roles and Responsibility',GetDate(),'Job Description Import',@GUID)						
			Set @Log_Status=1
			Return
		END

	DECLARE @Exp_Type AS INT	
	IF @Exp_Min >0
		SET @Exp_Type=1

	IF @Branch <> ''
		BEGIN
		--SELECT @Branch
			SELECT Branch_ID,Branch_Name 
			INTO #BRANCH_NAME
			FROM t0030_branch_master WITH (NOLOCK) 
			WHERE cmp_id=@cmp_id and Branch_Name IN (select  cast(data  as varchar(30)) from dbo.Split (@Branch,',')) 
			
			--select * from #BRANCH_NAME
			SELECT @BRANCH_ID= COALESCE(@BRANCH_ID + '#', '') + CAST(BRANCH_ID AS VARCHAR(250))
			FROM #BRANCH_NAME 
			
			IF @BRANCH_ID=''
			BEGIN
				Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,0,'Branch Name not exist',0,'Enter Proper Branch Name',GetDate(),'Job Description Import',@GUID)						
				Set @Log_Status=1
				Return
			END			
		END	
	ELSE	
		BEGIN
			Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,0,'Branch Name is required',0,'Enter Proper Branch Name',GetDate(),'Job Description Import',@GUID)						
			Set @Log_Status=1
			Return
		END		
					
	
	IF @Grade <> ''
		BEGIN
			SELECT Grd_ID,Grd_Name 
			INTO #GRADE_NAME
			FROM T0040_GRADE_MASTER WITH (NOLOCK) 
			WHERE cmp_id=@cmp_id and Grd_Name IN (select  cast(data  as varchar(30)) from dbo.Split (@Grade,',')) 
			
			--select * from #GRADE_NAME
			
			SELECT @GRADE_ID= COALESCE(@GRADE_ID + '#', '') + CAST(Grd_ID AS VARCHAR(250))
			FROM #GRADE_NAME 
			
			IF @GRADE_ID=''
			BEGIN
				Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,0,'Grade Name not exist',0,'Enter Proper Grade Name',GetDate(),'Job Description Import',@GUID)						
				Set @Log_Status=1
				Return
			END			
		END	
		
	IF @Designation <> ''
		BEGIN
			SELECT Desig_ID,Desig_Name 
			INTO #DESIGNATION_NAME
			FROM T0040_DESIGNATION_MASTER WITH (NOLOCK)
			WHERE cmp_id=@cmp_id and Desig_Name IN (select  cast(data  as varchar(30)) from dbo.Split (@Designation,',')) 
			
			--select * from #DESIGNATION_NAME
			SELECT @DESIG_ID= COALESCE(@DESIG_ID + '#', '') + CAST(Desig_ID AS VARCHAR(250))
			FROM #DESIGNATION_NAME 
			
			IF @DESIG_ID=''
			BEGIN
				Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,0,'Designation Name not exist',0,'Enter Proper Designation Name',GetDate(),'Job Description Import',@GUID)						
				Set @Log_Status=1
				Return
			END			
		END	
	ELSE	
		BEGIN
			Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,0,'Designation Name is required',0,'Enter Proper Designation Name',GetDate(),'Job Description Import',@GUID)						
			Set @Log_Status=1
			Return
		END		
		
		
	IF @Department <> ''
		BEGIN
			SELECT Dept_Id,Dept_Name 
			INTO #DEPARTMENT_NAME
			FROM T0040_DEPARTMENT_MASTER WITH (NOLOCK) 
			WHERE cmp_id=@cmp_id and Dept_Name IN (select  cast(data  as varchar(30)) from dbo.Split (@Department,',')) 
			
			--select * from #DEPARTMENT_NAME
			SELECT @DEPT_ID= COALESCE(@DEPT_ID + '#', '') + CAST(Dept_Id AS VARCHAR(250))
			FROM #DEPARTMENT_NAME 
			
			IF @DEPT_ID=''
			BEGIN
				Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,0,'Department Name not exist',0,'Enter Proper Department Name',GetDate(),'Job Description Import',@GUID)						
				Set @Log_Status=1
				Return
			END			
		END	
	ELSE	
		BEGIN
			Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,0,'Department Name is required',0,'Enter Proper Department Name',GetDate(),'Job Description Import',@GUID)						
			Set @Log_Status=1
			Return
		END
		
	IF @Qualification <> '' 
		BEGIN
			SELECT Qual_ID,Qual_Name 
			INTO #QUALIFICATION_NAME
			FROM T0040_QUALIFICATION_MASTER WITH (NOLOCK)
			WHERE cmp_id=@cmp_id and Qual_Name IN (select  cast(data  AS VARCHAR(30)) from dbo.Split (@Qualification,',')) 
			
			--select * from #QUALIFICATION_NAME
			SELECT @QUAL_ID= COALESCE(@QUAL_ID + '#', '') + CAST(Qual_ID AS VARCHAR(250))
			FROM #QUALIFICATION_NAME 
			
			IF @QUAL_ID=''
			BEGIN
				INSERT INTO dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,0,'Qualification not exist',0,'Enter Proper Qualification',GetDate(),'Job Description Import',@GUID)						
				SET @Log_Status=1
				RETURN
			END			
		END	
		
	IF @Documents  <> ''
		BEGIN
			SELECT Doc_ID,Doc_Name 
			INTO #DOCUMENT_NAME
			FROM T0040_DOCUMENT_MASTER WITH (NOLOCK)
			WHERE cmp_id=@cmp_id and Doc_Name IN (select  cast(data  AS VARCHAR(30)) from dbo.Split (@Documents,',')) 
			
			--select * from #DOCUMENT_NAME
			SELECT @Doc_ID= COALESCE(@Doc_ID + '#', '') + CAST(Doc_ID AS VARCHAR(250))
			FROM #DOCUMENT_NAME 
			
			IF @Doc_ID=''
			BEGIN
				INSERT INTO dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,0,'Document not exist',0,'Enter Proper Document',GetDate(),'Job Description Import',@GUID)						
				SET @Log_Status=1
				RETURN
			END			
		END	
		
	--IF @Exp_Type=1 --IF FRESHER
	--	BEGIN
	--		SET @Exp_Min=0
	--		SET @Exp_Max=0
	--	END
		
		SELECT @JB_CODE=isnull(MAX(cast(RIGHT(Job_Code, CHARINDEX(':', REVERSE(Job_Code)) - 1) AS NUMERIC(10))),0)
		FROM T0050_JobDescription_Master WITH (NOLOCK) WHERE cmp_id = @cmp_id		
		
		IF @JB_CODE=0
			SET @JOB_CODE='JD' + @cmp_id + ':1001'
		ELSE
			SET @JOB_CODE='JD' + CAST(@cmp_id AS VARCHAR(15)) +':'+CAST((CAST(@JB_CODE AS INT) + 1)AS VARCHAR(15))				
			
			SELECT @Job_Id = isnull(max(Job_Id),0)+1 FROM T0050_JobDescription_Master WITH (NOLOCK)
			INSERT INTO T0050_JobDescription_Master
			(
				   Job_Id
				  ,Cmp_Id
				  ,Effective_Date
				  ,Job_Code
				  ,Branch_Id
				  ,Grade_Id
				  ,Desig_Id
				  ,Dept_Id
				  ,Qual_Id				 
				  ,Exp_Min
				  ,Exp_Max
				  ,Create_Date
				  ,Create_By
				  ,Attach_Doc
				  ,[status]
				  ,Job_Title
				  ,Document_ID
				  ,Experience_Type
			)
			VALUES
			(
				   @Job_Id
				  ,@Cmp_Id
				  ,@Effective_Date
				  ,@JOB_CODE
				  ,CASE WHEN len(@BRANCH_ID) >0 THEN RIGHT(@BRANCH_ID,len(@BRANCH_ID)-1)ELSE ''END
				  ,CASE WHEN len(@GRADE_ID) > 0 THEN RIGHT(@GRADE_ID,len(@GRADE_ID)-1)ELSE ''END
				  ,CASE WHEN len(@DESIG_ID) >0 THEN RIGHT(@DESIG_ID,len(@DESIG_ID)-1)ELSE ''END
				  ,CASE WHEN len(@DEPT_ID) >0 THEN RIGHT(@DEPT_ID,len(@DEPT_ID)-1)ELSE ''END
				  ,CASE WHEN len(@QUAL_ID) >0 THEN RIGHT(@QUAL_ID,len(@QUAL_ID)-1)ELSE ''END				  
				  ,@Exp_Min
				  ,@Exp_Max
				  ,GETDATE()
				  ,@User_Id
				  ,''
				  ,1
				  ,@Job_Title
				  ,CASE WHEN len(@Doc_ID) >0 THEN RIGHT(@Doc_ID,len(@Doc_ID)-1)ELSE ''END
				  ,@Exp_Type
			)
			--select @Roles
		IF @Roles <>''
			BEGIN		
				if CHARINDEX('#',@Roles) > 0
					BEGIN
						SELECT  cast(data  AS VARCHAR(max))Roles INTO #ROLES	from dbo.Split (@Roles,'#')		
						DECLARE ROLES_DETAILS CURSOR FOR
							select Roles from #ROLES
						OPEN ROLES_DETAILS
							fetch next from ROLES_DETAILS into @Roles
								while @@fetch_status = 0
								Begin
									EXEC P0055_JobResponsibility 0,@Cmp_Id,@Job_Id,@Roles,'I',@User_Id,@IP_Address																			
								fetch next from ROLES_DETAILS into @Roles
							End
						close ROLES_DETAILS	
					END
				ELSE
					BEGIN
						EXEC P0055_JobResponsibility 0,@Cmp_Id,@Job_Id,@Roles,'I',@User_Id,@IP_Address				
					END
			END
	
END
