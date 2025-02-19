

-- =============================================
-- Author:		<Nimesh>
-- Create date: <11/April/2015>
-- Description:	<To Insert/Update/Delete records in T0050_Emp_Monthly_Shift_Rotation table>
---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0050_EMP_MONTHLY_SHIFT_ROTATION]
	@Cmp_ID			numeric(18,0), 
	@Tran_ID		numeric(18,0) Output,
	@Emp_ID			numeric(18,0),
	@Rotation_ID	numeric(18,0),
	@Effective_Date DateTime,	
	@Transtype		varchar(1),
	@Constraint		varchar(max) = ''
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


BEGIN
	
	IF @Constraint = '0' or @Constraint = ''
		SET	@Constraint = NULL;
	
	IF (@Constraint IS NULL)
	BEGIN
		If (Exists(Select 1 From T0050_Emp_Monthly_Shift_Rotation WITH (NOLOCK) Where Effective_Date=@Effective_Date AND Emp_ID=@Emp_ID) AND @Transtype = 'I') BEGIN
			SET @Transtype = 'U';
			Select @Tran_ID=Tran_ID From T0050_Emp_Monthly_Shift_Rotation WITH (NOLOCK) Where Effective_Date=@Effective_Date AND Emp_ID=@Emp_ID
		END 
		ELSE IF (@Transtype = 'U') BEGIN
			DECLARE @Existing_Tran_ID int;
			Select @Existing_Tran_ID=Tran_ID From T0050_Emp_Monthly_Shift_Rotation WITH (NOLOCK) Where Effective_Date=@Effective_Date AND Emp_ID=@Emp_ID
			IF (@Existing_Tran_ID <> @Tran_ID) BEGIN
				SET @Tran_ID = 0;
				RETURN 0;
			END 			
		END
				
		IF (@Transtype = 'I') BEGIN
			SET @Tran_ID = IsNull((Select Max(Tran_ID) From T0050_Emp_Monthly_Shift_Rotation WITH (NOLOCK)), 0) + 1;
					
			Insert Into T0050_Emp_Monthly_Shift_Rotation(Cmp_ID,Tran_ID,Emp_ID,Rotation_ID,Effective_Date,SysDate)
			Values(@Cmp_ID, @Tran_ID, @Emp_ID, @Rotation_ID, @Effective_Date, GETDATE());	
		END
		ELSE IF (@Transtype = 'U')
			Update T0050_Emp_Monthly_Shift_Rotation SET Rotation_ID=@Rotation_ID,Emp_ID=@Emp_ID,Effective_Date=@Effective_Date,
				SysDate=GETDATE() Where Tran_ID=@Tran_ID
		ELSE IF (@Transtype = 'D')
		BEGIN
			--Removing Shift From Shift Change Detail Table if defined by Rotation
			DECLARE @Next_Effective_Date datetime
			
			SELECT	@Rotation_ID = Rotation_ID, @Effective_Date=Effective_Date, @Emp_ID=Emp_ID
			FROM	T0050_Emp_Monthly_Shift_Rotation WITH (NOLOCK)
			WHERE	Tran_ID=@Tran_ID 
			
			SELECT	@Next_Effective_Date=Min(Effective_Date)
			FROM	T0050_Emp_Monthly_Shift_Rotation WITH (NOLOCK)
			WHERE	Effective_Date > @Effective_Date AND Emp_ID=@Emp_ID
			
			
			Delete From T0050_Emp_Monthly_Shift_Rotation Where Tran_ID=@Tran_ID 
					
			if @Next_Effective_Date IS NOT NULL
				DELETE	FROM T0100_EMP_SHIFT_DETAIL			
				WHERE	For_Date >= @Effective_Date AND For_Date < @Next_Effective_Date AND Rotation_ID=@Rotation_ID
			ELSE
				DELETE	FROM T0100_EMP_SHIFT_DETAIL			
				WHERE	For_Date >= @Effective_Date AND Rotation_ID=@Rotation_ID
		END
	END
	ELSE
	BEGIN
		IF OBJECT_ID('tempdb..#EMP_ROT') IS NOT NULL	
			drop table #EMP_ROT
			
		CREATE TABLE #EMP_ROT
		(
			EMP_ID numeric
		)
		INSERT INTO #EMP_ROT
		SELECT CAST(DATA AS NUMERIC) FROM dbo.Split(@Constraint, '#') Where IsNull(Data, '') <> ''
		
		IF (@Transtype = 'I' OR @Transtype = 'U') 
		BEGIN				
			DECLARE curRot CURSOR FAST_FORWARD FOR 
			SELECT EMP_ID FROM #EMP_ROT
			
			SELECT @Tran_ID=IsNUll(Max(Tran_ID),0) FROM T0050_Emp_Monthly_Shift_Rotation  WITH (NOLOCK)
			
			OPEN curRot
			FETCH NEXT FROM curRot INTO @Emp_ID
			WHILE (@@fetch_status  = 0)
			BEGIN
			
				SET @Tran_ID = @Tran_ID + 1
				
				DELETE FROM T0050_Emp_Monthly_Shift_Rotation where Emp_ID=@Emp_ID AND Effective_Date = @Effective_Date
				
				Insert Into T0050_Emp_Monthly_Shift_Rotation(Cmp_ID,Tran_ID,Emp_ID,Rotation_ID,Effective_Date,SysDate)
				Values(@Cmp_ID, @Tran_ID, @Emp_ID, @Rotation_ID, @Effective_Date, GETDATE());	
				
				FETCH NEXT FROM curRot INTO @Emp_ID
			END
		END
		ELSE IF (@Transtype = 'D')
		BEGIN
			DELETE T 
			FROM T0050_Emp_Monthly_Shift_Rotation T INNER JOIN #EMP_ROT E ON T.Emp_ID=E.EMP_ID
			WHERE Effective_Date = @Effective_Date						
		END		
	END
END


