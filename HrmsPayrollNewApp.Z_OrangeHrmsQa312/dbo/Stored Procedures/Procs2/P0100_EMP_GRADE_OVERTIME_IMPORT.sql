

-- =============================================
-- Author:		<SHAIKH RAMIZ>
-- Create date: <09/03/2018>
-- Description:	<Employee Grade Change Overtime - Import>
-- =============================================
CREATE PROCEDURE [dbo].[P0100_EMP_GRADE_OVERTIME_IMPORT]
    @Alpha_Emp_Code		VARCHAR(100)
   ,@Cmp_ID				NUMERIC
   ,@Overtime_Date		DATETIME
   ,@Overtime_Hours		VARCHAR(100)
   ,@Grade_Name			VARCHAR(100) 
   ,@Amount_Credit		NUMERIC(18,2)	= 0 
   ,@Amount_Debit		NUMERIC(18,2)	= 0 
   ,@Basic_Salary		NUMERIC(18,2)	= 0 
   ,@Log_Status			NUMERIC(18,0)   = 0  OUTPUT 
   ,@Row_No				NUMERIC(18,0)	= 0 
   ,@User_Id			NUMERIC(18,0) = 0
   ,@IP_Address			VARCHAR(30)= ''
   ,@GUID				VARCHAR(500) = ''
   ,@Delete_Tran_ID		VARCHAR(MAX) = ''
   
AS

        SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

	DECLARE @Emp_ID		NUMERIC
	DECLARE @Grd_ID		NUMERIC
	DECLARE @Tran_ID	NUMERIC
	DECLARE @Tran_Type	CHAR
	
	SET @Emp_ID  = 0
	SET @Grd_ID  = 0
	SET @Tran_ID = 0
	SET @Tran_Type = 'I'
	
	IF @Delete_Tran_ID <> ''	--IF DELETE TRAN TYPE IS PASSED THEN TRAN TYPE WILL BE "DELETE"
		SET @Tran_Type = 'D'
	
	SELECT @Emp_ID = Emp_ID FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE UPPER(Alpha_Emp_Code) = UPPER(@Alpha_Emp_Code) AND Cmp_ID = @Cmp_ID
	SELECT @Grd_ID = Grd_ID FROM T0040_GRADE_MASTER WITH (NOLOCK) WHERE UPPER(Grd_Name) = UPPER(@Grade_Name) AND Cmp_ID = @Cmp_ID
	
	
	IF @Tran_Type = 'I' --Single Records during Insert
		BEGIN
			IF @Emp_ID = 0
				BEGIN
					INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Alpha_Emp_Code,'Employee Code Not Exists in Hrms',@Grade_Name,'Verify Employee Code as per employee Master',GETDATE(),'Machine Gradewise Overtime Import',@GUID)  
					SET @Log_Status=1
					RETURN  
				END
			IF @Grd_ID = 0
				BEGIN
					INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Alpha_Emp_Code,'Employee Grade Not Exists in Hrms',@Grade_Name,'Verify Employee Grade Name as per Grade Master',GETDATE(),'Machine Gradewise Overtime Import',@GUID)  
					SET @Log_Status=1
					RETURN  
				END	
				
			IF (@Overtime_Date IS NULL) or (@Overtime_Date = '1900-01-01')
				BEGIN
					INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Alpha_Emp_Code,'Overtime Date Cannot be Blank Exists',@Grade_Name,'Enter Overtime Date',GETDATE(),'Machine Gradewise Overtime Import',@GUID)  
					SET @Log_Status=1
					RETURN  
				END
			
			IF @Overtime_Hours IS NULL
				BEGIN
					INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Alpha_Emp_Code,'Overtime Hours are Required',@Overtime_Hours,'Enter Overtime Hours',GETDATE(),'Machine Gradewise Overtime Import',@GUID)  
					SET @Log_Status=1
					RETURN  
				END
	
			IF EXISTS(SELECT Sal_tran_Id FROM T0200_MONTHLY_SALARY WITH (NOLOCK) WHERE Emp_ID=@Emp_ID AND Cmp_ID=@Cmp_ID AND 
						@Overtime_Date >= Month_St_Date AND @Overtime_Date <= Month_End_Date)
				BEGIN
					INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Alpha_Emp_Code,'Employee Salary Exists',@Grade_Name,'This Months Salary Exists.So You Can not Change Overtime Records',GETDATE(),'Machine Gradewise Overtime Import',@GUID)  
					SET @Log_Status=1
					
					RETURN -1
				END
			ELSE
				BEGIN
					IF EXISTS(SELECT Emp_ID FROM T0100_EMP_GRADE_OVERTIME WITH (NOLOCK) WHERE Emp_ID = @Emp_ID AND For_Date= @Overtime_Date AND Grd_id = @Grd_ID)
						BEGIN 
							UPDATE	T0100_EMP_GRADE_OVERTIME
							SET		Grd_ID = @Grd_ID , OT_Hours = @Overtime_Hours , 
									Amount_Credit = @Amount_Credit , Amount_Debit = @Amount_Debit,
									Import_Date = GETDATE() , Basic_Salary = @Basic_Salary
							WHERE	Emp_ID = @Emp_ID AND For_Date= @Overtime_Date AND Grd_id = @Grd_ID
						END
					ELSE
						BEGIN					
							INSERT INTO T0100_EMP_GRADE_OVERTIME
									(Cmp_ID,Emp_ID,For_Date,OT_Hours,Grd_ID,Amount_Credit,Amount_Debit , Import_Date ,Basic_Salary)
							VALUES     
									(@Cmp_ID, @Emp_ID, @Overtime_Date, @Overtime_Hours, @Grd_ID ,@Amount_Credit , @Amount_Debit, GETDATE() , @Basic_Salary)
						END				
				END
		END
	ELSE IF @Tran_Type = 'D' --Multiple Records for Delete
		BEGIN

			CREATE TABLE #DeleteRecords
			(
				OT_Tran_ID	NUMERIC,
				EMP_ID		NUMERIC,
				FOR_DATE	DATETIME
			)
			INSERT INTO #DeleteRecords
			SELECT OT_Tran_ID, EMP_ID , For_Date 
			FROM T0100_EMP_GRADE_OVERTIME EGO WITH (NOLOCK)
			WHERE EXISTS (SELECT data FROM dbo.Split(@Delete_Tran_ID , '#') T WHERE T.Data = EGO.OT_Tran_ID AND T.Data <> '')
			
			--NOT TO DELETE THOSE RECORDS , WHOSE SALARY IS PROCESSED
			IF EXISTS (	SELECT 1 FROM #DeleteRecords DR 
						INNER JOIN T0200_MONTHLY_SALARY MS WITH (NOLOCK) ON DR.EMP_ID = MS.Emp_ID
						WHERE Cmp_ID=@Cmp_ID AND DR.FOR_DATE >= Month_St_Date AND DR.FOR_DATE <= Month_End_Date)
				BEGIN
					DELETE DR
					FROM #DeleteRecords DR 
					INNER JOIN T0200_MONTHLY_SALARY MS ON DR.EMP_ID = MS.Emp_ID
					WHERE Cmp_ID=@Cmp_ID AND DR.FOR_DATE >= Month_St_Date AND DR.FOR_DATE <= Month_End_Date
			
					SET @Log_Status = 2
				END	
			
			DELETE EGO
			FROM T0100_EMP_GRADE_OVERTIME EGO
			WHERE EXISTS (SELECT OT_Tran_ID FROM #DeleteRecords D WHERE D.OT_Tran_ID = EGO.OT_Tran_ID)

			IF OBJECT_ID('tempdb..#SalaryProcessed') IS NOT NULL
				DROP TABLE #SalaryProcessed
				
		END
	
RETURN


