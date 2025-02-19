
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0060_EMP_MASTER_APP_COPY_APPROVE_DATA_TRANSFER]
	-- Add the parameters for the stored procedure here
	 @Emp_Tran_ID bigint output,
	 --@Status char(1)='P',
	 @Approve_Status char(1)='P',
	 @Approve_By_Emp_ID int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

    -- Insert statements for procedure here
	
	Declare @current_emp_id int 
	Declare @ref_emp_id int
	Declare @Rpt_Level int=1
	Declare @Ref_Emp_Tran_ID bigint=0  
	
	SET @current_emp_id =0 
	 
	

	Set @ref_emp_id=@Approve_By_Emp_ID
	
	declare @PreviousStatus char(1)

	SELECT @current_emp_id=Approved_Emp_ID,@Ref_Emp_Tran_ID=Ref_Emp_Tran_ID , @PreviousStatus=Approve_Status
	FROM	 T0060_EMP_MASTER_APP WITH (NOLOCK)
	WHERE	Emp_Tran_ID = @Emp_Tran_ID	
	
	--Select  @current_emp_id as current_emp_id
	--Select  @ref_emp_id as ref_emp_id
	
	IF @PreviousStatus ='P'
		BEGIN
			IF @ref_emp_id = @current_emp_id
				BEGIN
					DECLARE @TempEmpTranID INT
					SELECT @TempEmpTranID = Ref_Emp_Tran_ID FROM T0060_EMP_MASTER_APP WITH (NOLOCK) WHERE Emp_Tran_ID = @Emp_Tran_ID
					EXEC SP_Delete_Maker_A_Checker_Pending_Next_Level_Data @Emp_Tran_ID
					select @Emp_Tran_ID, * from T0075_EMP_EARN_DEDUCTION_APP WITH (NOLOCK)
					set @Emp_Tran_ID = @TempEmpTranID
				END
			ELSE
				BEGIN
					RETURN
				END				
		END
	ELSE
		BEGIN	
			IF @ref_emp_id = @current_emp_id
			BEGIN
				RETURN
			END
		END
	
	
	SET @Rpt_Level =1
	SET @Ref_Emp_Tran_ID =0  
	
	
	
	IF EXISTS(SELECT 1 FROM  T0060_EMP_MASTER_APP  WITH (NOLOCK) WHERE Emp_Tran_ID = @Emp_Tran_ID)
		Begin
			--select Old Report level for update after insert new entry
			set @Rpt_Level =(SELECT Rpt_Level FROM  T0060_EMP_MASTER_APP WITH (NOLOCK) WHERE Emp_Tran_ID = @Emp_Tran_ID)
			Set @Ref_Emp_Tran_ID=@Emp_Tran_ID
			SELECT * INTO #T0060_EMP_MASTER_APP_INSERTED FROM T0060_EMP_MASTER_APP WITH (NOLOCK) WHERE Emp_Tran_ID=@Ref_Emp_Tran_ID
			
			Set @Emp_Tran_ID=(SELECT Max(IsNull(Emp_Tran_ID,0)) FROM T0060_EMP_MASTER_APP WITH (NOLOCK)) + 1
			
			SELECT @Emp_Tran_ID = Max(IsNull(Emp_Tran_ID,0)) FROM T0060_EMP_MASTER_APP WITH (NOLOCK)
			SET @Emp_Tran_ID =  IsNull(@Emp_Tran_ID,0) + 1
			
			
			
			UPDATE	#T0060_EMP_MASTER_APP_INSERTED 
			SET		Emp_Tran_ID=@Emp_Tran_ID,Rpt_Level = Rpt_Level + 1,Approve_Status=@Approve_Status,
					Approved_Emp_ID=@Approve_By_Emp_ID,Approved_Date=getdate(),Ref_Emp_Tran_ID=@Ref_Emp_Tran_ID
			
			Insert INTO T0060_EMP_MASTER_APP SELECT * from #T0060_EMP_MASTER_APP_INSERTED
			
			
			--select  * from T0065_EMP_SHIFT_DETAIL_APP
			
			DECLARE @SQL AS NVARCHAR(MAX)
			SET @SQL = 'IF EXISTS(SELECT 1 FROM  @@TABLE_NAME WHERE Emp_Tran_ID = @Ref_Emp_Tran_ID)
							Begin
								SET @Max_Tran_ID=0
								SELECT @Max_Tran_ID = Max(@@Column_Name) FROM @@TABLE_NAME
								SET @Max_Tran_ID =  IsNull(@Max_Tran_ID,0) + 1								
								
								SELECT * INTO #@@TABLE_NAME FROM @@TABLE_NAME WHERE Emp_Tran_ID=@Ref_Emp_Tran_ID
								UPDATE #@@TABLE_NAME SET Emp_Tran_ID = @Emp_Tran_ID
								INSERT INTO @@TABLE_NAME SELECT * from #@@TABLE_NAME								
							END'
				--Select * from T0075_EMP_EARN_DEDUCTION_APP
							
			CREATE TABLE #CHILD_TABLES
			(
				ID INT,
				Table_Name Varchar(256),
				Column_Name		Varchar(256)
			)
			
			INSERT INTO #CHILD_TABLES 
			SELECT 1, 'T0070_EMP_INCREMENT_APP', 'Increment_ID' UNION ALL			
			SELECT 2, 'T0065_EMP_REPORTING_DETAIL_APP', 'Row_ID' UNION ALL
			SELECT 3, 'T0065_EMP_SHIFT_DETAIL_APP', 'Shift_Tran_ID' UNION ALL
			SELECT 4, 'T0065_EMP_CHILDRAN_DETAIL_APP', 'Row_ID' UNION ALL
			SELECT 5, 'T0065_EMP_CONTRACT_DETAIL_APP', 'Tran_ID' UNION ALL
			SELECT 6, 'T0065_EMP_DEPENDANT_DETAIL_APP', 'Row_ID' UNION ALL			
			SELECT 7, 'T0065_EMP_DOC_DETAIL_APP', 'Row_ID' UNION ALL			
			SELECT 8, 'T0065_EMP_EMERGENCY_CONTACT_DETAIL_APP', 'Row_ID' UNION ALL
			SELECT 9, 'T0065_EMP_EXPERIENCE_DETAIL_APP', 'Row_ID' UNION ALL			
			SELECT 10, 'T0065_EMP_IMMIGRATION_DETAIL_APP', 'Row_ID' UNION ALL			
			SELECT 11, 'T0065_EMP_LANGUAGE_DETAIL_APP', 'Row_ID' UNION ALL	
			SELECT 18, 'T0075_EMP_EARN_DEDUCTION_APP', 'AD_TRAN_ID'		
			--SELECT 12, 'T0065_EMP_LICENSE_DETAIL_APP', 'Row_ID' UNION ALL			
			--SELECT 13, 'T0065_EMP_QUALIFICATION_DETAIL_APP', 'Row_ID' UNION ALL			
			--SELECT 14, 'T0065_EMP_SKILL_DETAIL_APP', 'Row_ID' UNION ALL			
			--SELECT 15, 'T0065_EMP_REFERENCE_DETAIL_APP', 'Reference_ID' UNION ALL			
			--SELECT 16, 'T0070_WEEKOFF_ADJ_APP', 'W_Tran_ID' UNION ALL			
			--SELECT 17, 'T0070_EMP_SCHEME_APP', 'Tran_ID' UNION ALL			
			

			
			DECLARE @EXECUTOR NVARCHAR(MAX)
			
			
			SELECT	@EXECUTOR = COALESCE(@EXECUTOR +';', '') + REPLACE(REPLACE(@SQL, '@@TABLE_NAME', Table_Name), '@@Column_Name', Column_Name)
			FROM	#CHILD_TABLES
			
			SET @EXECUTOR = 'DECLARE @Max_Tran_ID INT ' + @EXECUTOR
			
			EXEC sp_executesql @EXECUTOR, N'@Ref_Emp_Tran_ID  BIGINT, @Emp_Tran_ID BIGINT', @Ref_Emp_Tran_ID, @Emp_Tran_ID	
			
			
	END 
END



