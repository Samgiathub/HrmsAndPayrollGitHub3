

-- =============================================
-- Author:		<Ankit>
-- Create date: <26092015,,>
-- Description:	<Employee Grade Change - Import,,>
---19/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0100_EMP_GRADE_DETAIL_IMPORT]
   @Alpha_Emp_Code	VARCHAR(100)
   ,@Cmp_ID			NUMERIC
   ,@For_Date		DATETIME
   ,@To_Date		DATETIME = NULL
   ,@Grade_Name		VARCHAR(100)
   ,@User_Id		NUMERIC(18,0)	= 0 
   ,@IP_Address		VARCHAR(30)		= '' 
   ,@Log_Status		NUMERIC(18,0)   = 0  OUTPUT 
   ,@Row_No			NUMERIC(18,0)	= 0 
   ,@GUID			Varchar(2000) = '' --Added by nilesh patel on 15062016
   
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	DECLARE @Emp_ID		NUMERIC
	DECLARE @Grd_ID		NUMERIC
	DECLARE @Tran_ID	NUMERIC
	SET @Emp_ID  = 0
	SET @Grd_ID  = 0
	SET @Tran_ID = 0
	 
	--Declare @Max_Grd_ID numeric
	--Declare @Old_Emp_Id as numeric
	--Declare @Old_Emp_Name as varchar(100)
	--Declare @Old_Grd_ID numeric
	--Declare @Old_Shift_Name as varchar(200)
	--Declare @New_Shift_Name as varchar(200)
	--Declare @Old_for_Date as datetime
	--Declare @OldValue as varchar(max)
	--Set @Old_Emp_Id = 0 
	--Set @Old_Emp_Name  = ''
	--Set @Old_Grd_ID = 0
	--Set @Old_Shift_Name = ''
	--Set @New_Shift_Name = ''
	--Set @Old_for_Date = ''
	--Set @OldValue = ''
	
	SELECT @Emp_ID = Emp_ID FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE UPPER(Alpha_Emp_Code) = UPPER(@Alpha_Emp_Code) AND Cmp_ID = @Cmp_ID
	SELECT @Grd_ID = Grd_ID FROM T0040_GRADE_MASTER WITH (NOLOCK) WHERE UPPER(Grd_Name) = UPPER(@Grade_Name) AND Cmp_ID = @Cmp_ID
	
	IF @Emp_ID = 0
		BEGIN
			INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Alpha_Emp_Code,'Employee Code not Exists in Hrms',@Grade_Name,'Verify Employee Code as per Hrms employee Master',GETDATE(),'Employee Grade Change',@GUID)  
			SET @Log_Status=1
			RETURN  
		END
	IF @Grd_ID = 0
		BEGIN
			INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Alpha_Emp_Code,'Employee Grade not Exists in Hrms',@Grade_Name,'Verify Employee Grade Name as per Hrms Grade Master',GETDATE(),'Employee Grade Change',@GUID)  
			SET @Log_Status=1
			RETURN  
		END	
		
	IF @For_Date IS NULL
		BEGIN
			INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Alpha_Emp_Code,'From Date not Exists',@Grade_Name,'Enter From Date Details',GETDATE(),'Employee Grade Change',@GUID)  
			SET @Log_Status=1
			RETURN  
		END
	
	IF @To_Date IS NULL
		BEGIN
			INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Alpha_Emp_Code,'To Date not Exists',@Grade_Name,'Enter To Date Details',GETDATE(),'Employee Grade Change',@GUID)  
			SET @Log_Status=1
			RETURN  
		END
	
	IF ISNULL(@To_Date,'') = ''
		SET @To_Date = @For_Date								
									
		--BEGIN
			
			WHILE (@For_Date <= @To_Date)
				BEGIN
					IF EXISTS(SELECT Sal_tran_Id FROM T0200_MONTHLY_SALARY WITH (NOLOCK) WHERE Emp_ID=@Emp_ID AND Cmp_ID=@Cmp_ID AND 
								@For_Date >= Month_St_Date AND @For_Date <= Month_End_Date)
						BEGIN
							--RAISERROR('@@This Months Salary Exists.So You Can not Change Grade.@@',16,2)
							INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Alpha_Emp_Code,'Employee Salary Exists',@Grade_Name,'This Months Salary Exists.So You Can not Change Grade',GETDATE(),'Employee Grade Change',@GUID)  
							SET @Log_Status=1
							
							RETURN -1
						END
					ELSE
						BEGIN
							IF EXISTS(SELECT Emp_ID FROM T0100_EMP_GRADE_DETAIL WITH (NOLOCK) WHERE Emp_ID = @Emp_ID AND For_Date= @For_Date AND Grd_id = @Grd_ID)
								BEGIN 
									UPDATE	T0100_EMP_GRADE_DETAIL
									SET		Grd_id = @Grd_ID
									WHERE	Emp_ID = @Emp_ID AND For_Date= @For_Date AND Grd_id = @Grd_ID
								END
							ELSE
								BEGIN	
									SELECT @Tran_ID = ISNULL(MAX(Tran_ID),0) + 1 	FROM T0100_EMP_GRADE_DETAIL WITH (NOLOCK)
									
									INSERT INTO T0100_EMP_GRADE_DETAIL
											   (Tran_ID, Emp_ID, Cmp_ID, Grd_ID, For_Date , System_Date)
									VALUES     (@Tran_ID, @Emp_ID, @Cmp_ID, @Grd_ID, @For_Date , GETDATE())
								END
					
							--Set @Old_Emp_Name = (Select ISNULL(Alpha_Emp_Code,'') + ' - ' + ISNULL(Emp_Full_Name,'')  from T0080_EMP_MASTER where Emp_ID = @Emp_ID)
							--Set @Old_Shift_Name = (select Shift_Name from T0040_SHIFT_MASTER where Grd_ID = @Grd_ID  AND Cmp_ID = @Cmp_ID)
							
							--set @OldValue = 'New Value' + '#'+ 'Employee Name :' + ISNULL( @Old_Emp_Name,'') 
							--		+ '#' + 'Shift Name :' + ISNULL(@Old_Shift_Name,'') 												
							--		+ '#' + 'Shift Type :' + CASE ISNULL(@Shift_type,0) WHEN 0 THEN 'Regular' ELSE 'Temporary' END
							--		+ '#' + 'For date :' + cast(ISNULL(@For_Date,'') as nvarchar(11)) 
							--exec P9999_Audit_Trail @Cmp_ID,@tran_type,'Shift Change',@Oldvalue,@Emp_ID,@User_Id,@IP_Address,1 
												
						END
						
					SET @For_Date = DATEADD(DAY,1,@For_Date)
					
				END
			
			
		--END
	
	
RETURN

