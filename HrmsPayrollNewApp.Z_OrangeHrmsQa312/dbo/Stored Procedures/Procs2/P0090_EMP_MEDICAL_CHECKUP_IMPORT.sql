
---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0090_EMP_MEDICAL_CHECKUP_IMPORT]
	@Cmp_ID			numeric(18,0)
   ,@Alpha_Emp_Code	varchar(30)
   ,@For_Date		datetime
   ,@Column_Name	varchar(100)
   ,@Column_Value	varchar(100)
   ,@tran_type		varchar(1)
   ,@Log_Status		INT = 0	OUTPUT
   ,@Row_No			numeric
   ,@GUID			varchar(500) = ''
   ,@User_Id		numeric(18,0) = 0
   ,@IP_Address		varchar(30)= ''
 AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	DECLARE @EMP_ID NUMERIC
	DECLARE @MEDICAL_ID AS NUMERIC
	DECLARE @SQL_QRY VARCHAR(MAX)
	DECLARE @MAX_TRAN_ID AS NUMERIC
	DECLARE @TRAN_ID AS NUMERIC
	
	Declare @OldValue Varchar(Max)
	Set @OldValue = ''
	
	/* VALIDAING EMPLOYEE */
	IF EXISTS(SELECT EMP_ID FROM dbo.T0080_EMP_MASTER WITH (NOLOCK) WHERE Cmp_ID= @Cmp_ID and Alpha_Emp_Code = @Alpha_Emp_Code)
		BEGIN
			SELECT @Emp_Id = Emp_Id FROM dbo.T0080_Emp_Master WITH (NOLOCK) WHERE Cmp_ID = @Cmp_ID and  Alpha_Emp_Code = @Alpha_Emp_Code
			
			IF EXISTS(SELECT Emp_ID FROM dbo.T0080_EMP_MASTER WITH (NOLOCK) WHERE Cmp_ID= @Cmp_ID and  Alpha_Emp_Code = @Alpha_Emp_Code and Emp_ID <> @Emp_ID and Emp_Left <> 'Y')
				BEGIN
					SET @Log_Status = 1
					INSERT INTO dbo.T0080_Import_Log 
					VALUES (@Row_No,@Cmp_Id,@Alpha_Emp_Code ,'Duplicate Active Employees',@Alpha_Emp_Code,'Duplicate Active Employees',@For_Date,'Medical Detail Import',@GUID)			
					RETURN
				END
		END
	ELSE
		BEGIN
			SET @Log_Status = 1
			INSERT INTO dbo.T0080_Import_Log 
			VALUES (@Row_No,@Cmp_Id,@Column_Name ,'Employee Code does not Exists',@Column_Name,'Enter Proper Employee Code',@For_Date,'Medical Detail Import',@GUID)			
			RETURN
		END
	

	/* VALIDAING MEDICAL RECORDS */
	IF EXISTS (SELECT Ins_Tran_ID FROM T0040_INSURANCE_MASTER WITH (NOLOCK) where Cmp_ID = @Cmp_ID AND Ins_Name = @Column_Name and Type = 'Medical')
		BEGIN
			SELECT @MEDICAL_ID = ISNULL(Ins_Tran_ID,0) 
			FROM T0040_INSURANCE_MASTER WITH (NOLOCK)
			WHERE Cmp_ID = @Cmp_ID AND Ins_Name = @Column_Name and Type = 'Medical'
		END
	ELSE
		BEGIN
			SET @Log_Status = 1
			INSERT INTO dbo.T0080_Import_Log 
			VALUES (@Row_No,@Cmp_Id,@Column_Name ,'Record does not Exists',@Column_Name,'Enter Proper Medical Checkup Name',@For_Date,'Medical Detail Import',@GUID)			
			RETURN
		END
	
	/* IF SAME RECORDS EXISTS , THEN UPDATE */	
	IF EXISTS ( SELECT 1 FROM T0090_EMP_MEDICAL_CHECKUP WITH (NOLOCK) WHERE cmp_Id = @Cmp_ID AND Emp_Id = @EMP_ID AND Medical_ID = @MEDICAL_ID AND For_Date = @For_Date)
		BEGIN
			SET @TRAN_TYPE = 'U'
			SELECT @TRAN_ID = Tran_Id FROM T0090_Emp_Medical_Checkup WITH (NOLOCK)
			WHERE Cmp_Id = @Cmp_ID AND Emp_Id = @EMP_ID AND Medical_ID = @MEDICAL_ID AND For_Date = @For_Date
		END	
	
	SELECT @MAX_TRAN_ID = ISNULL(MAX(Tran_Id),0) + 1 FROM T0090_Emp_Medical_Checkup WITH (NOLOCK)


	IF @tran_type = 'I'
		BEGIN
			SET @OldValue = 'Old Value ' + '#'+ @Column_Name +' : ''' + @Column_Value +''''
			
			SET @SQL_QRY = 'INSERT INTO dbo.T0090_EMP_MEDICAL_CHECKUP
							(Tran_Id , cmp_Id , Emp_Id , Medical_ID , For_Date , Description)
							VALUES
							('+ CAST(@MAX_TRAN_ID AS NVARCHAR) +' , '+ CAST(@Cmp_ID AS NVARCHAR) +' , '+ CAST(@EMP_ID AS NVARCHAR)  +' , '+ CAST(@MEDICAL_ID AS NVARCHAR) +' , '''+ CONVERT(VARCHAR, @For_Date , 106) +''' , '''+ @Column_Value +''' )'
							
		END
	ELSE
		BEGIN
			SET @OldValue = 'Old Value ' + '#'+ @Column_Name +' : ''' + @Column_Value +''''
			
			SET @SQL_QRY = 'Update dbo.T0090_EMP_MEDICAL_CHECKUP 
							SET	Description = ''' + @Column_Value + ''' 
							WHERE TRAN_ID = '+ CAST(@TRAN_ID AS NVARCHAR)
		END
	
	EXEC (@SQL_QRY)
	
	
	/* AUDIT TRAIL PORTION*/
	DECLARE @NewValue VARCHAR(MAX)
	SET @NewValue = ''
	SET @NewValue = 'New Value' + '#'+ @Column_Name + ' : ' + @Column_Value +'#'+ @OldValue
	
	EXEC P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Medical Details Import',@NewValue,@Emp_Id,@User_Id,@IP_Address,1,@GUID
	
	SET @Column_Name=''
	SET @Column_Value = ''
	
	/******	IF EXECUTION OF SP TAKES TOO MUCH TIME , EXECUTE THIS INDEXING QUERY	******
	
	CREATE UNIQUE NONCLUSTERED INDEX [NCIX_Audit_Trail] ON [dbo].[T9999_Audit_Trail] 
	(
		[Cmp_ID] ASC,
		[Audit_Change_Type] ASC,
		[Audit_Module_Name] ASC,
		[Audit_Change_For] ASC,
		[Audit_Trail_Id] ASC
	)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
	GO

	dbcc dbreindex('T9999_Audit_Trail')
	*/
RETURN
